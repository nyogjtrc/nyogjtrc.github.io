---
title: '移除 BOM'
date: 2013-11-29T15:46:00+08:00
tags: [bom]
---
**[BOM][bom] (byte order mark)** 一個萬國碼的標記, 不會顯示在你的銀幕上, 但會讓你的程式死光光.
清掉 [BOM][bom] 留給你的程式一條活路

# 編輯器

多數的編輯器都可以設定 編碼為 **UTF-8 no BOM**

vim 的設定, 可以參考 [remove BOM character using vim][2]

## 找出 BOM

grep
```bash
$ grep -rl $'\xEF\xBB\xBF' .
```

find + grep
```bash
$ find /path/to/dir/ -type f -print  -exec hd -n 3 {} \;  | grep -1 "ef bb bf"
```
## 移除 BOM

find + sed
```bash
$ find . -type f -exec sed '1s/^\xEF\xBB\xBF//' -i.bak {} \; -exec rm {}.bak \;
```
sed
```bash
$ sed -i '1 s/^\xef\xbb\xbf//' ./*
```

## Referece

- http://stackoverflow.com/questions/204765/elegant-way-to-search-for-utf-8-files-with-bom
- [PHP 判斷/移除 BOM(UTF-8)](http://blog.longwin.com.tw/2008/06/php_check_remove_bom_utf8_2008/)

[bom]: http://en.wikipedia.org/wiki/Byte_Order_Mark
[2]: /posts/2013/07/remove-bom-in-vim/
