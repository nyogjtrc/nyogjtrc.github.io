---
title: '管理 vim bundle '
date: 2013-10-28T09:42:00+08:00
tags: [vim, pathogen]
---
身為一個 vim 的愛用者, 看著自己一堆 vim 設定跟 script 亂七八糟的, 不知道如何下手.
原本自己有建立一個 git repo 做一些簡單的整理, 但是 vim plugin 五花八門, 實在不好整理

現在已經有幾套工具, 讓你整理 vim 套件輕鬆上手, 分別是 [pathogen][1], [vundle][2].

簡單筆記一下 [pathogen][1], 我也只用過 [pathogen][1]...
pathogen 讓 vim plugin 可以用 bundle 的方式管理

然後配合 ``git submodule`` 指令, 簡單的安裝跟管理套件

## 安裝 pathogen

只要將 pathogen.vim 放到 ``~/.vim/autoload/pathogen.vim`` 即可

或是, 照著 pathogen 的說明安裝

``` bash
$ mkdir -p ~/.vim/autoload ~/.vim/bundle; \
$ curl -Sso ~/.vim/autoload/pathogen.vim \
    https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
```

再設定以下設定到 .vimrc

``` vim
execute pathogen#infect()
```

上面是 pathogen 作者提供的安裝方法, 可是這樣就沒辦法用 git 去自動更新了

換用 git submodule 的方法

``` bash
$ git submodule add git@github.com:tpope/vim-pathogen.git bundle/vim-pathogen/
```

設定 .vimrc

``` vim
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
```

## 使用

這邊以 nerdtree 為例

``` bash
# 安裝 nerdtree
$ git submodule add git://github.com/scrooloose/nerdtree.git bundle/nerdtree
```

之後要更新所有的 plugin 只要用 git submodule 的指令就可以了

``` bash
$ git submodule foreach git pull origin master
$ git commit -m 'update submodule'
```

## 總結

附上 我自己的 vimrc https://github.com/nyogjtrc/vimrc

有機會再來試試 vundle

## Reference

- http://jameslaicreative.com/moving-up-upgrading-from-pathogen-to-vundle/
- http://lepture.com/work/manage-vim/
- http://lepture.com/work/vundle-vs-pathogen
- http://aknow-work.blogspot.tw/2013/05/github-vundle-vim.html
- http://stevelosh.com/blog/2010/09/coming-home-to-vim/

[1]: https://github.com/tpope/vim-pathogen
[2]: https://github.com/gmarik/vundle

