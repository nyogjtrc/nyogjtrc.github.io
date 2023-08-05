---
title: "修正 tmux 無法正常顯示 24-bit True color"
date: 2023-08-05T20:45:03+08:00
tags: [tmux]
---

在設定 [Git diff 強化工具: delta](/posts/2023/03/git-diff-improved-tool-delta/) 時，發現我的 terminal 顯示的顏色不正常。

我的 terminal 環境用 Alacritty + Tmux，網路上馬上找到跟我遇到一樣問題的同學: [24 bit/True color not working in tmux 2.3 · Issue #696 · tmux/tmux](https://github.com/tmux/tmux/issues/696)

我的環境如下:
- Alacritty 0.7.0
- Tmux 3.2a

## 測試顏色

使用以下指令測試顏色
```
awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
}'
```

alacritty 結果:
![](/posts/2023/08/true-color-right.png)

alacritty + tmux 結果:
![](/posts/2023/08/true-color-wrong.png)

## 解決方案

在 .tmux.conf 使用 `terminal-overrides` 加入 `Tc` 的設定

設定如下:
```
set -ga terminal-overrides ",xterm-256color:Tc"
```

### Reference
- [24 bit/True color not working in tmux 2.3 · Issue #696 · tmux/tmux](https://github.com/tmux/tmux/issues/696)
- https://github.com/termstandard/colors
