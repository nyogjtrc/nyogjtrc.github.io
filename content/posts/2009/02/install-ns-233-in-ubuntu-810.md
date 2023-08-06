---
title: '安裝 NS-2.33 到 ubuntu 8.10'
date: 2009-02-27T16:05:00+08:00
tags: [ubuntu]
---

NS-2 目前的版本的是2.33 請到 [http://isi.edu/nsnam/ns/][1] 抓 allinone 版本  
  
我的 ubuntu 在先前有裝 Lazybuntu，Lazybuntu 會更改 source.list 可能會造成套件衝突，所以我復原 Lazybuntu 改的 source.list(這個不一定要動)  
  
接著輸入：  
```sh
$ sudo apt-get update  
```
更新清單，就開始安裝 NS-2 需要的軟體了  
  
```sh
$ sudo apt-get install build-essential  
```
(後面這些軟體系統會自動補齊 dpkg-dev g++ g++-4.3 libstdc++6-4.3-dev patch)  
  
```sh
$ sudo apt-get install libxmu-dev  
```
(後面這些軟體系統會自動補齊 libice-dev libpthread-stubs0 libpthread-stubs0-dev libsm-dev libx11-dev libxau-dev libxcb-xlib0-dev libxcb1-dev libxdmcp-dev libxext-dev libxi-dev libxmu-headers libxt-dev x11proto-core-dev x11proto-input-dev x11proto-kb-dev x11proto-xext-dev xtrans-dev)  
  
安裝 gnuplot, gawk  
```sh
$ sudo apt-get install gnuplot gawk  
```
(後面這些軟體系統會自動補齊 gnuplot-nox gnuplot-x11 libwxbase2.6-0 libwxgtk2.6-0)  
  
把 ns-allinone-2.33.tar.gz 移到家目錄下解壓縮  
```sh
$ tar -zxvf ns-allinone-2.33.tar.gz  
```
  
到 ns-allinone-2.33 資料夾下進行安裝  
```sh
$ cd ns-allinone-2.33  
$ ./install  
```
  
經過一段時間的等待，NS-2 安裝完成  
接著修改家目錄底下的 .bashrc 檔案  
```sh
$vi ~/.bashrc  
```
  

```sh
# for ns2
export PATH=$PATH:/home/nyogjtrc/ns-allinone-2.33/bin:/home/nyogjtrc/ns-allinone-2.33/tcl8.4.14/unix:/home/nyogjtrc/ns-allinone-2.33/tk8.4.14/unix  
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/nyogjtrc/ns-allinone-2.33/otcl-1.13:/home/nyogjtrc/ns-allinone-2.33/lib  
export TCL_LIBRARY=$TCL_LIBRARY:/home/nyogjtrc/ns-allinone-2.33/tcl8.4.14/library
```

  
最後!到 NS2-2.33 資料夾下，執行驗證~(這個不跑好像沒差...XD)  
```sh
$ ./validate  
```
  
驗證完成後，會有"validate overall report: all tests passed"的句子出現...  
不然就是...重裝!?  
  
完成，做作業去...

[1]: http://isi.edu/nsnam/ns/
