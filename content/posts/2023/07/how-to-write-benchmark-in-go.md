---
title: "如何寫 Go 的效能測試(Benchmark)"
date: 2023-07-15T01:22:43+08:00
tags: [go, test, benchmark]
---

go 的測試工具 `go test` 有 benchmark 工具可以使用。
不用自己寫工具就可以很輕鬆的測試程式碼效能。

## 開始寫 benchmark 測試
- 建立 `_test.go` 結尾的檔案
- function 要以 `Benchmark` 開頭
- 使用 `b *testing.B` 參數
- 將要測試的程式放到 `b.N` 的 for 迴圈內

範例如下:
```go
// main.go
func Sum(s []int) int {
	sum := 0
	for i := 0; i < len(s); i++ {
		sum += s[i]
	}
	return sum
}
```

```go
// main_test.go
func BenchmarkSum(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Sum([]int{1, 2, 3})
	}
}
```

## 執行 benckmark
- 執行 `go test` 指令加上 `-bench` 參數
- `-bench` 一樣支援使用正規表達式，執行符合的測試

```bash
go test -bench=.
```

輸出結果:
```bash
BenchmarkSum-8          610364305                1.978 ns/op
PASS
```

輸出結果說明
- `-8` 代表 `GOMAXPROCS` 的值，也就是使用的核心數
- 迴圈執行 610364305 次
- 執行速度為每次 1.978 ns

## 一些 benchmark 相關指令參數

`-benchtime t`
- 指定 benchmark 測試迴圈跑滿多少時間 ex. -benchtime 10s, 跑 10 秒
- 預設值為 1 秒
- 可以用 x 指定執行次數 ex. -benchtime 100x, 跑 100 次

`-count n`
- 指定 benchmark 要跑幾輪測試
- 預設 1 次

`-cpu 1,2,4`
- 指令使用核心數量清單

`-benchmem`
- 印出執行 benchmark 的記憶體分配統計

## 測試 json decode 到 Map 跟 struct

我們準備另一個 benchmark 測試

```go
// main.go
type Book struct {
	Title  string `json:"title"`
	Author string `json:"author"`
}
```

```go
// main_test.go
func BenchmarkDecode2Struct(b *testing.B) {
	jsonString := []byte("{\"title\":\"Document\",\"author\":\"me\"}")
	for i := 0; i < b.N; i++ {
		b := Book{}
		json.Unmarshal(jsonString, &b)
	}
}

func BenchmarkDecode2Map(b *testing.B) {
	jsonString := []byte("{\"title\":\"Document\",\"author\":\"me\"}")
	for i := 0; i < b.N; i++ {
		m := make(map[string]string)
		json.Unmarshal(jsonString, &m)
	}
}
```

這次測試我們增加一些內容，先是多測幾次比較誤差，並統計記憶體使用情況，指令跟結果如下：

```bash
go test -bench=. -count=5 -benchmem
goos: darwin
goarch: amd64
pkg: github.com/nyogjtrc/practice-go/example-benchmark
cpu: Intel(R) Core(TM) i5-8279U CPU @ 2.40GHz
BenchmarkSum-8                  448784319                2.662 ns/op           0 B/op          0 allocs/op
BenchmarkSum-8                  446790114                2.732 ns/op           0 B/op          0 allocs/op
BenchmarkSum-8                  441891258                2.702 ns/op           0 B/op          0 allocs/op
BenchmarkSum-8                  449093973                2.669 ns/op           0 B/op          0 allocs/op
BenchmarkSum-8                  445117809                2.673 ns/op           0 B/op          0 allocs/op
BenchmarkDecode2Struct-8         1542450               778.2 ns/op           264 B/op          7 allocs/op
BenchmarkDecode2Struct-8         1548220               783.6 ns/op           264 B/op          7 allocs/op
BenchmarkDecode2Struct-8         1534435               787.3 ns/op           264 B/op          7 allocs/op
BenchmarkDecode2Struct-8         1538522               790.6 ns/op           264 B/op          7 allocs/op
BenchmarkDecode2Struct-8         1545883               795.0 ns/op           264 B/op          7 allocs/op
BenchmarkDecode2Map-8             874519              1190 ns/op             616 B/op         14 allocs/op
BenchmarkDecode2Map-8             913914              1206 ns/op             616 B/op         14 allocs/op
BenchmarkDecode2Map-8            1010119              1204 ns/op             616 B/op         14 allocs/op
BenchmarkDecode2Map-8             893706              1208 ns/op             616 B/op         14 allocs/op
BenchmarkDecode2Map-8             954352              1195 ns/op             616 B/op         14 allocs/op
PASS
ok      github.com/nyogjtrc/practice-go/example-benchmark       24.121s
```

輸出結果說明
- `B/op`: 每次迴圈的記憶體用量
- `allocs/op`: 每次迴圈的記憶體分配次數



## Reference
- https://pkg.go.dev/testing#hdr-Benchmarks
- https://pkg.go.dev/cmd/go#hdr-Testing_flags
