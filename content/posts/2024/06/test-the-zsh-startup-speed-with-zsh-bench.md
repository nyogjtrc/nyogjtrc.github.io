---
title: "用 zsh-bench 來測試 zsh 啟動速度"
date: 2024-06-03T23:30:56+08:00
tags: [terminal, zsh, prezto, benchmark]
---

在調效 zsh 環境時 ([使用 Prezto 取代 Oh-My-Zsh](/posts/2024/05/replace-oh-my-zsh-with-prezto/))，找到一個算是簡單上手的效能測試工具 zsh-bench (<https://github.com/romkatv/zsh-bench>)，在設定 prezto 時就是用它來比較各種設定下的 zsh 啟動速度。


## 執行 zsh-bench

git clone 該 repo
```bash
git clone https://github.com/romkatv/zsh-bench
```

執行 zsh-bench
```bash
cd zsh-bench
./zsh-bench
```

zsh-bench 提供的測試數據不是單純的跑分，而是以平常的使用情境來測試運行速度

- first prompt lag (ms)
   - 從打開 shell 到畫面出現提示可以打字的時間
- first command lag (ms)
   - 從打開 shell 到第一次輸入指令開始執行的時間
- command lag (ms)	
   - 不輸入任何指令，直接按下 enter 所花費的時間
- input lag (ms)	
   - 按下按鍵到畫面出現
- exit time (ms)	
   - 執行 `zsh -lic "exit"` 的時間

## 我的實測記錄

### oh my zsh + 啟用 plugin + 使用 nvm

plugin 設定
```bash
plugins=(
    docker
    git
    golang
    nvm
    python
    kubectl
)
```

zsh-bench 結果
```bash
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=0
has_git_prompt=0
first_prompt_lag_ms=750.918
first_command_lag_ms=755.486
command_lag_ms=5.033
input_lag_ms=0.783
exit_time_ms=673.386
```

### oh my zsh + 啟用 plugin + 關掉 nvm

zsh-bench 結果
```bash
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=0
has_git_prompt=0
first_prompt_lag_ms=249.180
first_command_lag_ms=253.719
command_lag_ms=4.979
input_lag_ms=0.789
exit_time_ms=185.060
```

### prezto + 啟用 module + 使用 nodenv

module 設定
```bash
zstyle ':prezto:load' pmodule \
  'environment' \
  'editor' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'git' \
  'node' \
  'completion' \
  'history-substring-search' \
  'prompt'
```

zsh-bench 結果
```bash
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=0
has_git_prompt=0
first_prompt_lag_ms=254.377
first_command_lag_ms=264.029
command_lag_ms=13.849
input_lag_ms=0.876
exit_time_ms=227.798
```

### prezto + 啟用 module + 關掉 node module

zsh-bench 結果
```bash
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=0
has_git_prompt=0
first_prompt_lag_ms=147.989
first_command_lag_ms=157.487
command_lag_ms=13.841
input_lag_ms=0.756
exit_time_ms=121.408
```

### prezto + 啟用 module + 使用 nodenv

module 設定
```bash
zstyle ':prezto:load' pmodule \
  'environment' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'git' \
  'node' \
  'completion' \
  'history-substring-search' \
  'prompt'
```

zsh-bench 結果
```bash
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=0
has_git_prompt=0
first_prompt_lag_ms=181.414
first_command_lag_ms=188.616
command_lag_ms=8.634
input_lag_ms=0.781
exit_time_ms=157.997
```

### prezto + 啟用 module + 關掉 node module

module 設定
```bash
zstyle ':prezto:load' pmodule \
  'environment' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'git' \
  'completion' \
  'history-substring-search' \
  'prompt'
```

zsh-bench 結果
```bash
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=0
has_git_prompt=0
first_prompt_lag_ms=104.002
first_command_lag_ms=111.134
command_lag_ms=8.674
input_lag_ms=0.806
exit_time_ms=84.383
```

## 總結

- 在兩邊設定相似的情況下，prezto 的體感啟動速度有比較快
- 我的實測數據跟 zsh-bench 內整理的測試結果感覺有一些差距，不過這個有在我的預期內，畢竟一些方便的 module 就是會想要打開來用看看，同時也讓速度慢了些許
- nvm 其實是速度慢的最大兇手，其實只要先解決它就會大大的進步

