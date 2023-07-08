---
title: "在 Linux 監控 Wifi 訊號強度"
date: 2023-07-08T15:16:57+08:00
tags: [linux, wifi]
---
平常都習慣使用圖形介面設定 wifi，臨時要用 command line 完全不知道要從哪邊下手。以下是我找到的方法。

## 查看 Wifi 訊號強度

執行以下指令查看 `/proc/net/wireless` 檔案就可以知道目前 wifi 的狀況
```
$ cat /proc/net/wireless
Inter-| sta-|   Quality        |   Discarded packets               | Missed | WE
 face | tus | link level noise |  nwid  crypt   frag  retry   misc | beacon | 22
wlp2s0: 0000   70.  -34.  -256        0      0      0      0     63        0
```
看 Quality 欄的 link 跟 level 就是我們想找的訊號強弱
- link: 連線品質，數值是 0 到 70， 70 最好
- level: 訊號強弱，單位 dBm，值越大代表訊號越好，通常是負值

## 監控 Wifi 訊號強度

加上 `watch` 指令就可以持續的監控 wifi 訊號強度的變化
```
$ watch -n 1 cat /proc/net/wireless
```

## 使用 iwconfig 查看

另外也可以用 `iwconfig` 指令查詢 wifi 強度

```
$ iwconfig wlp2s0 | grep Quality
          Link Quality=70/70  Signal level=-31 dBm
```

## Reference
- [Wireless connection: Link Quality: What does &quot;31/70&quot; indicate? - Super User](https://superuser.com/questions/866005/wireless-connection-link-quality-what-does-31-70-indicate)
- [A tool to measure signal strength of wireless - Ask Ubuntu](https://askubuntu.com/questions/95676/a-tool-to-measure-signal-strength-of-wireless)
