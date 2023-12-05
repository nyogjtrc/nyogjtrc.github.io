---
title: "試用 Copilot + Vim"
date: 2023-12-05T20:59:42+08:00
tags: [vim, copilot]
---

Github Copilot 是 Github 推出的 AI 程式開發工具，只要你先設計好程式要怎麼運作，剩下的 Copilot 就會幫你完成了。

要使用 Copilot 首先要在 Github 訂閱 Copilot，再來要在 IDE 裝好套件就可以開始使用了。

Github Copilot 官方有提供 vim/neovim 的套件: [github/copilot.vim: Neovim plugin for GitHub Copilot](https://github.com/github/copilot.vim)。2022 八月時支援 vim 9([Copilot.vim 1.5.0 · github/copilot.vim@da286d8](https://github.com/github/copilot.vim/commit/da286d8c52159026f9cba16cd0f98b609c056841))

## 環境

- neovim 或 vim: 9\.0.0185 以上版本

- node.js

## 使用 vim-plug 安裝

- 在 `.vimrc` 加入以下設定

   ```plain
   " Copilot
   Plug 'github/copilot.vim'
   ```

- 輸入 `:PlugInstall` 安裝套件

- 輸入 :Copilot setup 設定 Copilot，會引導你登入 Github 取得授權

- 完成之後就可以開始使用 Copilot，而 Copilot 的設定檔會存放在 `~/.config/github-copilot`。

## 實測

簡單的用 gin 寫一個 sample，打一半的程式碼或是註解，都可以變成 Copilot 提供建議的素材

![](/posts/2023/12/copilot-vim-sample.png)


