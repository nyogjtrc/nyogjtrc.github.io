---
title: "使用 retry-go 制定再試策略"
date: 2024-03-23T23:23:02+08:00
tags: [go]
---
現在寫程式常常都會有大量的 API 溝通，現實世界常會遇到像是網路不穩定等等的情況，這時有再試策略 (retry strategy) 就很重要了。

retry-go 是一個可以讓我們自定再試策略 (retry strategy) 的套件。

寫這篇文章的當下是 v4.5.1

使用以下指令安裝套件
```bash
go get github.com/avast/retry-go/v4
```

## Retry 使用方式

用 `retry.Do()` 執行要再試的內容，以下是用 test function 寫的範例：
```go
func TestRetryBasic(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Hello, world!"))
	}))
	defer ts.Close()

	var body []byte
	err := retry.Do(
		func() error {
			resp, err := http.Get(ts.URL)
			if err != nil {
				return err
			}
			defer resp.Body.Close()

			if resp.StatusCode != http.StatusOK {
				return fmt.Errorf("status code: %d", resp.StatusCode)
			}

			body, err = io.ReadAll(resp.Body)
			if err != nil {
				return err
			}
			return nil
		},
	)
	assert.NoError(t, err)

	fmt.Println("body:", string(body))
}
```

執行測試的結果如下：
```bash
go test retry_test.go -v -run=TestRetryBasic
=== RUN   TestRetryBasic
body: Hello, world!
--- PASS: TestRetryBasic (0.01s)
PASS
ok      command-line-arguments  1.325s
```

在不加入任何改動時，會以預設的設定執行 retry，預設值如下:
```go
func newDefaultRetryConfig() *Config {
	return &Config{
		attempts:         uint(10),
		attemptsForError: make(map[error]uint),
		delay:            100 * time.Millisecond,
		maxJitter:        100 * time.Millisecond,
		onRetry:          func(n uint, err error) {},
		retryIf:          IsRecoverable,
		delayType:        CombineDelay(BackOffDelay, RandomDelay),
		lastErrorOnly:    false,
		context:          context.Background(),
		timer:            &timerImpl{},
	}
}
```

- attempts: retry 上限次數，預設  10 次
- delay: 每次 retry 的基本延遲時間，配上不同的的 delay type 會有不一樣的結果，預設 100 ms
- delayType: 延遲時間的規則，預設是後移 (backoff) 組合隨機 (random)

## 改變 Retry 的延遲時間

只要使用 retry-go 的 Option function 就可以自定義再試策略 (retry strategy)。

如果我想要設定成
- retry 5 次
- 每次固定延遲 500 ms 

程式碼如下：
```go
var body []byte
err := retry.Do(
    func() error {
        resp, err := http.Get(ts.URL)
        if err != nil {
            return err
        }
        defer resp.Body.Close()

        if resp.StatusCode != http.StatusOK {
            return fmt.Errorf("status code: %d", resp.StatusCode)
        }

        body, err = io.ReadAll(resp.Body)
        if err != nil {
            return err
        }
        return nil
    },
    retry.Attempts(5), // retry 5 次
    retry.Delay(500*time.Millisecond), // 每次延遲 500 ms 
    retry.DelayType(retry.FixedDelay), // 固定的延遲時間
)
```

## 設定中止 Retry 的規則

我們會遇到要中止 retry 的情況，例如 http 400, 401 等。可以用 RetryIf() 寫中止或繼續 retry 的規則，並搭配 OnRetry() 寫 log。

如果我想設定的條件是
- http status 400, 401, 403 時中止 retry
- 其他 status 繼續

測試程式碼如下：
```go
func TestRetryStrategy(t *testing.T) {
	testCases := []struct {
		name         string
		statusCode   int
		keepRetrying bool
	}{
		{
			name:         "RetryWhenInternalServerError",
			statusCode:   http.StatusInternalServerError,
			keepRetrying: true,
		},
		{
			name:         "RetryWhenBadGateway",
			statusCode:   http.StatusBadGateway,
			keepRetrying: true,
		},
		{
			name:         "RetryWhenGatewayTimeout",
			statusCode:   http.StatusGatewayTimeout,
			keepRetrying: true,
		},
		{
			name:         "RetryWhenRequestTimeout",
			statusCode:   http.StatusRequestTimeout,
			keepRetrying: true,
		},
		{
			name:         "RetryWhenTooManyRequests",
			statusCode:   http.StatusTooManyRequests,
			keepRetrying: true,
		},
		{
			name:         "StoppedWhenBadRequest",
			statusCode:   http.StatusBadRequest,
			keepRetrying: false,
		},
		{
			name:         "StoppedWhenUnauthorized",
			statusCode:   http.StatusUnauthorized,
			keepRetrying: false,
		},
		{
			name:         "StoppedWhenForbidden",
			statusCode:   http.StatusForbidden,
			keepRetrying: false,
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			tsCounter := 0
			ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				tsCounter++
				if tsCounter < 2 {
					w.WriteHeader(tc.statusCode)
					return
				}
				w.WriteHeader(http.StatusOK)
				w.Write([]byte("Hello, world!"))
			}))
			defer ts.Close()

			err := retry.Do(
				func() error {
					resp, err := http.Get(ts.URL)
					if err != nil {
						return err
					}
					defer resp.Body.Close()

					if resp.StatusCode != http.StatusOK {
						return fmt.Errorf("status code: %d", resp.StatusCode)
					}
					return nil
				},
				retry.OnRetry(func(n uint, err error) {
					fmt.Printf("retrying: %d, error: %s\n", n, err)
				}),
				retry.RetryIf(func(err error) bool {
					switch err.Error() {
					case "status code: 400", "status code: 401", "status code: 403":
						return false
					default:
						return true
					}
				}),
			)
			if tc.keepRetrying {
				assert.NoError(t, err)
			} else {
				assert.Error(t, err)
				assert.Equal(t, fmt.Sprintf("status code: %d", tc.statusCode), errors.Unwrap(err).Error())
			}
		})
	}
}

```

執行結果如下
```bash
go test -v retry_test.go -run=TestRetryStrategy
=== RUN   TestRetryStrategy
=== RUN   TestRetryStrategy/RetryWhenInternalServerError
retrying: 0, error: status code: 500
=== RUN   TestRetryStrategy/RetryWhenBadGateway
retrying: 0, error: status code: 502
=== RUN   TestRetryStrategy/RetryWhenGatewayTimeout
retrying: 0, error: status code: 504
=== RUN   TestRetryStrategy/RetryWhenRequestTimeout
retrying: 0, error: status code: 408
=== RUN   TestRetryStrategy/RetryWhenTooManyRequests
retrying: 0, error: status code: 429
=== RUN   TestRetryStrategy/StoppedWhenBadRequest
=== RUN   TestRetryStrategy/StoppedWhenUnauthorized
=== RUN   TestRetryStrategy/StoppedWhenForbidden
--- PASS: TestRetryStrategy (0.77s)
    --- PASS: TestRetryStrategy/RetryWhenInternalServerError (0.13s)
    --- PASS: TestRetryStrategy/RetryWhenBadGateway (0.14s)
    --- PASS: TestRetryStrategy/RetryWhenGatewayTimeout (0.11s)
    --- PASS: TestRetryStrategy/RetryWhenRequestTimeout (0.19s)
    --- PASS: TestRetryStrategy/RetryWhenTooManyRequests (0.20s)
    --- PASS: TestRetryStrategy/StoppedWhenBadRequest (0.00s)
    --- PASS: TestRetryStrategy/StoppedWhenUnauthorized (0.00s)
    --- PASS: TestRetryStrategy/StoppedWhenForbidden (0.00s)
PASS
ok      command-line-arguments  2.196s
```
可以看到程式如 RetryIf() 的條件在運作


## Reference

- <https://github.com/avast/retry-go>
