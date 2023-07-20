---
title: 'Ubuntu 15.10 無法用 Chrome 開外部連結'
date: 2016-03-08T03:44:00+08:00
tags: [ubuntu, chrome]
---
設定 Chrome 為預設瀏灠器後，開其他程式裡的連結都會直接開啟一個空白新視窗。

## 解決方案

看起來是程式沒有接到網址，ask ubuntu 上已經有人提供解法，只要修改 google-chrome.desktop 的設定即可。
位置： `~/.local/share/applications/google-chrome.desktop`

原檔案內容：
```
[Desktop Entry]
...
Exec=/opt/google/chrome/chrome
...
```

只要在 Exec 設定後面加個 ` %U` 即可

修正後檔案內容：
```
[Desktop Entry]
...
Exec=/opt/google/chrome/chrome %U
...
```

## Reference
- http://askubuntu.com/questions/689449/15-10-chrome-external-links-are-opened-as-blank-tabs-in-new-browser-window
