---
title: "把 CLI 的色彩主題換成 Catppuccin"
date: 2024-05-19T22:01:04+08:00
tags: [vim, terminal]
---

最近發現了一個有趣的東西，名為「Catppuccin」的色彩主題 (themes)。
- <https://github.com/catppuccin/catppuccin>

Catppuccin 的配色看起來十分柔和，提供了一個亮色跟三個暗色共四種配色:
- Latte
- Frappé
- Macchiato
- Mocha
比較誇張的是這個色彩主題支援的包山包海的應用程式跟網站。


我這次打算換成次暗的 Macchiato，以下記錄我這次安裝的設定。

## Vim

- <https://github.com/catppuccin/vim>
- 使用 Plug 安裝
- 將 airline theme 也一同換上 Catppuccin

```vim
Plug 'catppuccin/vim', { 'as': 'catppuccin' }

if isdirectory(expand("~/.vim/plugged/catppuccin/"))
    set termguicolors
    colorscheme catppuccin_macchiato
endif

let g:airline_theme = 'catppuccin_macchiato'
```

調整前 (gruvbox)

![](/posts/2024/05/vim-before.png)

調整後

![](/posts/2024/05/vim-after.png)

## Alacritty

- <https://github.com/catppuccin/alacritty>
- 下載 toml 檔
    ```bash
    curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-macchiato.toml
    ```

- 在 alacritty.toml import catppuccin 的 toml 檔
    ```toml
    import = [
      # uncomment the flavour you want below:
      #"~/.config/alacritty/catppuccin-latte.toml"
      # "~/.config/alacritty/catppuccin-frappe.toml"
      "~/.config/alacritty/catppuccin-macchiato.toml"
      # "~/.config/alacritty/catppuccin-mocha.toml"
    ]
    ```

調整前

![](/posts/2024/05/alacritty-before.png)


調整後

![](/posts/2024/05/alacritty-after.png)




