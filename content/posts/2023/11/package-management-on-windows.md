---
title: "Windows 上的套件管理工具"
date: 2023-11-11T02:02:11+08:00
tags: [windows]
---
平常工作使用 Linux 或是 Mac 都有很完善的套件管理工具可以使用。

自己的 Windows 桌機雖然是休閒用途，但是前前後後也裝了不少的程式，照顧上有點小麻煩。
所以在 Windows 上也要找找適合的工具使用。

Chocolatey 是目前支援套件數最多的工具，目前版本: v2.2.2

環境需求
- Windows 11 或 Windows 10 - 22H2 以上版本
- Windows PowerShell v2.0 或以上版本

我的測試環境
- Windows 10 專業版 - 22H2
- PowerShell v5.1

## 安裝 Windows Terminal

為了讓我們可以眼睛更舒服的進行接下來的工作，首先要安裝 Windows Terminal。由微軟自家推行而且功能畫面都比以往更加強大的 CLI 應用程式。

你可以在 Microsoft Store 搜尋「Windows Terminal」安裝，或是從以下網址安裝
- <https://apps.microsoft.com/detail/windows-terminal/9N0DX20HK701?hl=zh-tw&gl=tw>

## 安裝 chocolatey

我們需要開啟有「系統管理員」權限的 Terminal，並確定 Terminal 是執行 PowerShell

執行以下指令進行安裝
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

安裝完畢後，執行 choco 指令，如果跟下圖一樣有看到版本編號，就是成功能
![](/posts/2023/11/terminal-choco.png)

## 升級 chocolatey

自行升級 chocolatey 的指令如下
```
choco upgrade chocolatey
```

## 開始安裝套件

首先要尋找我們先安裝的套件
- 到 <https://community.chocolatey.org/packages> 搜尋
- 執行指令搜尋 `choco search <套件>`

找到套件就可以下指令安裝，例如要安裝 git，指令如下
```plain
choco install git
```
可以查詢安裝了哪些套件，指令如下

```plain
choco list
```

## 好用指令

- choco info <套件>: 查看套件的說明
- choco export: 匯出目前安裝的套件清單
- choco uninstall <套件>: 解除安裝套件
- choco upgrade <套件>: 升級套件
- choco upgrade all: 升級所有套件

## Reference

- <https://chocolatey.org/>
- [指令式軟體安裝服務比較：Chocolatey、Scoop 與 winget-黑暗執行緒](https://blog.darkthread.net/blog/chocolatey-scoop-winget/)
