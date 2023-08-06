---
title: 'ubuntu 8.10 上安裝嘸蝦米'
date: 2009-02-21T14:39:00+08:00
tags: [ubuntu]
---


這是用gcin來打嘸蝦米的方法~

開啟 terminal，依序鍵入下列指令

先更新一下 apt-get
```sh
sudo apt-get update
```

安裝gcin
```sh
sudo apt-get install gcin
```

把預設輸入法換成 gcin
```sh
im-switch -s gcin
```

安裝嘸蝦米的表格檔
```sh
sudo /usr/share/gcin/script/noseeing-inst
```

上列指令都執行後，重新登入，你就可以快樂的打嘸蝦米了 ^.<

