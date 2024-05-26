---
title: "使用 Prezto 取代 Oh-My-Zsh"
date: 2024-05-26T21:09:03+08:00
tags: [terminal, zsh, prezto]
---


我的 terminal 環境目前是 oh-my-zsh，使用上常常會在開啟或是輸入指令有明顯的 lag，oh-my-zsh 雖然有大量的 plugin 可以使用，但是實際上我會用到的 plugin 也就少數的特定幾個而已。是時候該讓 omz 退休，換上其他更有效率的 framework。

## Prezto

- <https://github.com/sorin-ionescu/prezto>
- README 介紹是 zsh 的 framework
- 看到其他人分享的使用情況，執行的效率會比 oh-my-zsh 快很多

## 安裝 Prezto

- 確認你有裝 `zsh`
- clone repository
   ```bash
   git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
   ```
- 建立 zsh 組態檔
   - prezto 提供了建立 link 的指令
   ```bash
   setopt EXTENDED_GLOB
   for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
     ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
   done
   ```
   - 但是為了方更之後設定 prezto，我選擇從 `.zprezto/runcoms/` 資料夾裡複製 config 檔到 `$HOME` 底下
   ```bash
   zlogin
   zlogout
   zpreztorc
   zprofile
   zshenv
   zshrc
   ```
   - ps. 如果有一樣的檔案記得備份

## 調整設定

### terminal 主題

有 prompt 指令可以快速的預覽各個主題

- 主題清單: `prompt -l` 
- 預覽: `prompt -p <主題>`
- 切換: `prompt <主題>`


選好之後到 `.zpreztorc` 修改以下主題設定

```bash
zstyle ':prezto:module:prompt' theme 'sorin'
```



### 啟用模組

在 `.zpreztorc` 啟用的模組，以下是我啟用的模組

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

## nvm 太慢了，換成 nodenv

換 prezto 為了讓 terminal 可以快一點，偏偏載入 nvm 時，速度有感變慢，所以在這邊也要跟 nvm 說 byebye 了。

安裝 `nodenv`

```bash
brew install nodenv
```

裝目前的 LTS 版本

```bash
nodenv install 20.13.1
nodenv global 20.13.1
```

## 載入以前自己寫的環境設定

以往在使用 oh-my-zsh 時，有寫一些自己的 function 跟 aliase

編輯 `.zshrc` 直接載入
```bash
# import my functions
if [[ -s "$HOME/.dotfiles/zsh/functions.zsh" ]]; then
    source "$HOME/.dotfiles/zsh/functions.zsh"
fi

# import my aliases
if [[ -s "$HOME/.dotfiles/zsh/aliases.zsh" ]]; then
    source "$HOME/.dotfiles/zsh/aliases.zsh"
fi
```



## 總結

- 剛裝好的體感速度是有快一點，但是有可能是因為還有東西還沒要載入
- 給一點時間觀察一下實際使用的感覺





## Reference

- <https://www.creepingcoder.com/2019/09/28/start-using-prezto/>
- <https://wikimatze.de/better-zsh-with-prezto/>


