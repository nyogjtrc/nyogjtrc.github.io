---
title: "將 AppImage 加入 Gnome 的 Application 清單"
date: 2023-08-28T23:53:14+08:00
tags: [linux, appimage]
---
AppImage 是目前 Linux 上很常見的應用程式格式，不需要安裝，可以相容於各大 Linux 發行版。

下載 AppImage 檔後，要執行它的方法很簡單 (以下用 Hepta-0.369.1.AppImage)

先讓檔案可以執行

```
$ chmod +x Hepta-0.369.1.AppImage
```

接著就可以啟動它

```
$ ./Hepta-0.369.1.AppImage
```

只不過，AppImage 在桌面環境下，都必需要打開終端機輸入指令，使用上多少有些不方便。但是沒關係，我們可以把 AppImage 應用程式加到 Gnome 的 Application 清單中。

## 將 AppImage 加入 Gnome 的 Application 清單

首先到 `~/.local/share/applications` 建立 `hepta.desktop` 檔案，內容如下:
```
[Desktop Entry]
Type=Application
Version=1.0
Name=Hepta
Comment=Heptabase empowers you to visually make sense of your learning, research, and projects.
Exec=/home/nyo/bin/Hepta-0.369.1.AppImage
Icon=/home/nyo/bin/hepta.svg
Terminal=false
```
- Exec: 設定成 AppImage 位置的絕對路徑
- Icon: 設定成 icon 位置的絕對路徑

執行以下指令更新 Application 清單

```
$ update-desktop-database ~/.local/share/applications -v
```

現在按下 Super 鍵，你鍵入 Hepta，你可以看到應用程式選項了

## Reference

- https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html
- https://wiki.archlinux.org/title/desktop_entries
- [How to Add AppImage Application to Menu in Ubuntu (Linux) - DEV Community](https://dev.to/msamgan/how-to-add-appimage-application-to-menu-in-ubuntu-linux-8o2)
- https://appimage.org/
