---
title: "Mac 產生的 ._ 檔案"
date: 2024-03-10T23:53:00+08:00
tags: [mac]
---
我在移動 Mac 檔到其他系統時，都會出現 `._` 開頭的檔案。一開始只是隨手刪除，但是每次都會產生這些垃圾檔案，實在是有點惱人。

## 為什麼會有 .\_ 開頭的檔案?

Mac 會存一些附加資訊到檔案裡，當移動檔案到非 Mac 的檔案系統時，就會產生 .\_ 檔案來存放附加資訊

## dot_clean

Mac 有內建 dot_clean 指令，可以清理這些  .\_ 的檔案。

使用方式很簡單

```bash
dot_clean <需要 ._ 檔案清理目錄>
```

## Reference

- [macos - Why are dot underscore .\_ files created, and how can I avoid them? - Ask Different](https://apple.stackexchange.com/questions/14980/why-are-dot-underscore-files-created-and-how-can-i-avoid-them)
