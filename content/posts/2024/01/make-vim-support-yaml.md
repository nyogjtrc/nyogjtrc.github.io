---
title: "讓 Vim 支援 YAML 檔"
date: 2024-01-20T19:23:46+08:00
tags: [vim, yaml]
---

來更新 vim 設定，在寫 yaml 時可以舒服一點。

目前版本是 Vim 9.0

## 設定縮排

我習慣的 yaml 縮排是兩個空白，在 vim 就針對 yaml 檔設定：
```vim
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
```

## 語法

原本有裝 [stephpy/vim-yaml](https://github.com/stephpy/vim-yaml) 這個 plugin，這次就刪掉了

- 解 VIM 7.4 處理速度太慢，更新停在 2021
- 目前 VIM 原生就有，似乎也沒有以往的問題，就暫時不需要使用額外的 plugin



## 加強縮排顯示

yaml 檔常常會有大量的縮排，所以增加了一個 [nathanaelkane/vim-indent-guides](https://github.com/preservim/vim-indent-guides) plugin，強調縮排顯示，vimrc 增加以下設定：

```vim
Plug 'nathanaelkane/vim-indent-guides'

" 預設啟用
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size=1
let g:indent_guides_start_level=2
```

## 語法檢查

[ale](https://github.com/dense-analysis/ale) 是 vim 上的語法檢查 plugin，支援多種語法檢查工具，yaml 檔案支援 yamllint。只要裝好 ale 跟 yamllint 就能夠以預設的設定運作。

安裝 ale, vimrc 增加設定：
```vim
Plug 'w0rp/ale'
```


安裝 yamllint，執行指令：
```vim
brew install yamllint
```



如果覺得 yamllint 預設的規則太嚴格，可以調整成 releaxed

建立檔案 `~/.config/yamllint/config`，內容如下：
```vim
extends: relaxed
```



## Reference

- [Setting up Vim for YAML editing](https://www.arthurkoziel.com/setting-up-vim-for-yaml/)
- https://github.com/adrienverge/yamllint
