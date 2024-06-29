---
title: "在 GCP 建立有 Desktop 環境的 VM"
date: 2024-06-29T19:13:03+08:00
tags: [linux, gcp, debian]
---

記錄一下在 GCP 上開一台有桌面環境的 VM 的過程

## 開一台 VM

- 到 GCP 的 compute engine，建立一台 VM，以下是這次測試選用的設定
   - e2-medium (2 vCPU, 4 GB)
   - Spot
- 等待 VM 建立完成
- 從 VM 列表上點 SSH 連線，會開啟一個 SSH 的 web terminal 登入 VM

## 安裝 Chrome Remote Desktop

- 在 SSH 視窗，輸入以下指令，安裝 Chrome Remote Desktop
   ```bash
   curl https://dl.google.com/linux/linux_signing_key.pub \
       | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/chrome-remote-desktop.gpg
   echo "deb [arch=amd64] https://dl.google.com/linux/chrome-remote-desktop/deb stable main" \
       | sudo tee /etc/apt/sources.list.d/chrome-remote-desktop.list
   sudo apt-get update
   sudo DEBIAN_FRONTEND=noninteractive \
       apt-get install --assume-yes chrome-remote-desktop
   ```

## 安裝 X Window

- 這次測試選擇安裝 Xfce (輕量級的桌面系統)
   ```bash
   sudo DEBIAN_FRONTEND=noninteractive \
       apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver
   ```
- 設定 Chrome Remote Desktop 預設使用 Xfce
   ```bash
   sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'
   ```

## 設定 Chrome Remote Desktop 服務
- 打開 <https://remotedesktop.google.com/headless> ，並確定你有登入任一個你要使用的 google 帳號
- 點開會出現「設定其他電腦」畫面
   ![set-up-another-computer.png](/posts/2024/06/set-up-another-computer.png)
- 點擊「開始」，出現「透過下列網址在遠端電腦下載並安裝 Chrome 遠端桌面」畫面
- 點擊「繼續」，出現「授權 Chrome 遠端桌面設定新電腦。」畫面
- 點擊「授權」，出現設定指令
- 複製 Linux 用的指令，貼到 SSH 的視窗執行
   ```bash
   DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="4/0ATx3LY71DU2nq2CmTa0uorP4VgjKPKqv9oCvMybpDLyaBXAQqGdqVals3lsLjlmfidEpIg" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname)
   ```
- 依提示「Enter a PIN of at least six digits」輸入 PIN 碼
- 檢查 Chrome Remote Desktop 服務是否運作
   ```bash
   sudo systemctl status chrome-remote-desktop@$USER
   ```
- 有順利運作的話，可以看到 running 的狀態
   ```bash
   ● chrome-remote-desktop@user.service - Chrome Remote Desktop instance for user
        Loaded: loaded (/lib/systemd/system/chrome-remote-desktop@.service; enabled; preset: enabled)
        Active: active (running) since Fri 2024-06-00 00:00:00 UTC; 1min 10s ago
   ```

## 登入 Desktop

- 打開 <https://remotedesktop.google.com/>
- 在「遠端存取」的畫面，可以看到 VM 出現了
   ![remote-devices.png](/posts/2024/06/remote-devices.png)
- 點擊 VM，輸入 PIN 碼，點擊前進按扭
- 成功登入 Linux 桌面了
   ![vm-desktop.png](/posts/2024/06/vm-desktop.png)
- 可以開始在桌面環境工作了



## Reference

- <https://cloud.google.com/architecture/chrome-desktop-remote-on-compute-engine>
