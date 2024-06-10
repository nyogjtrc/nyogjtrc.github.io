---
title: "剖析 zsh 啟動時間"
date: 2024-06-10T09:12:14+08:00
tags: [terminal, zsh, profiling]
draft: true
---
在上一篇文章([用 zsh-bench 來測試 zsh 啟動速度](/posts/2024/06/test-the-zsh-startup-speed-with-zsh-bench/))用 zsh-bench 測試 zsh 的啟動速度。這邊還有另外兩個測試 zsh 啟動速度的方法，一個比較簡單用是 time 指令，另一個是用 zsh 的 profiling 工具，可以看到詳細的時間花費。

## 測試啟動時間

指令如下:
```bash
time zsh -i -c exit
```

會拿到簡單的啟動時間花費:
```bash
$ time zsh -i -c exit
zsh -i -c exit  0.08s user 0.10s system 59% cpu 0.307 total
```

## 使用 zsh 內建的 profiling 模組

- 編輯 `.zshrc`
- 開頭加上 `zmodload zsh/zprof`
- 結尾加上 `zprof`


```bash
zmodload zsh/zprof
...
zprof
```

啟動 zsh 就可以看到以下結果:
```bash
num  calls                time                       self            name
-----------------------------------------------------------------------------------
 1)    5         189.83    37.97   98.79%    147.38    29.48   76.70%  pmodload
 2)    2          17.52     8.76    9.12%     17.52     8.76    9.12%  promptinit
 3)    1           9.89     9.89    5.15%      9.89     9.89    5.15%  compinit
 4)    1           4.50     4.50    2.34%      4.50     4.50    2.34%  async_init
 5)   10           2.83     0.28    1.47%      2.83     0.28    1.47%  (anon) [/Users/x/.zprezto/init.zsh:117]
 6)    3           2.18     0.73    1.14%      2.18     0.73    1.14%  is-at-least
 7)    2           6.58     3.29    3.43%      2.08     1.04    1.08%  async
 8)    1           1.50     1.50    0.78%      1.50     1.50    0.78%  _history-substring-search-function-callable
 9)    8           1.06     0.13    0.55%      1.06     0.13    0.55%  add-zsh-hook
10)   10           1.05     0.11    0.55%      1.02     0.10    0.53%  add-zle-hook-widget
11)    2           7.46     3.73    3.88%      0.74     0.37    0.39%  prompt_sorin_setup
12)    1           0.53     0.53    0.28%      0.53     0.53    0.28%  (anon) [/Users/x/.zprezto/modules/history-substring-search/init.zsh:117]
13)    1           0.31     0.31    0.16%      0.31     0.31    0.16%  (anon) [/Users/x/.zprezto/modules/utility/init.zsh:117]
14)    1           8.97     8.97    4.67%      0.18     0.18    0.10%  set_prompt
15)    3           0.16     0.05    0.08%      0.16     0.05    0.08%  compdef
16)    3           0.28     0.09    0.15%      0.12     0.04    0.06%  complete
17)    1           9.04     9.04    4.70%      0.07     0.07    0.03%  prompt
18)    1           0.03     0.03    0.02%      0.03     0.03    0.02%  (anon) [/opt/homebrew/Cellar/zsh/5.9/share/zsh/functions/add-zle-hook-widget:28]
19)    1           0.02     0.02    0.01%      0.02     0.02    0.01%  bashcompinit
20)    2           0.01     0.01    0.01%      0.01     0.01    0.01%  is-darwin
...
```

看來現在的啟動時間都花費在 pmodload 上 (prezto 載入模組)，有空再來看看是不是有什麼模組是可以關掉了


## Reference

- <https://stevenvanbael.com/profiling-zsh-startup>
- <https://ellie.wtf/notes/profiling-zsh>
- <https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#The-zsh_002fzprof-Module>
