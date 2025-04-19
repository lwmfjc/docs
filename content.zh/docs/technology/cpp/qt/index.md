---
title: qt学习
description: qt学习
categories:
  - 学习
tags:
  - cpp
  - qt
date: 2025-04-19T15:58:12+08:00
lastmod: 2025-04-19T15:58:12+08:00
cssAttach:
  - book01
cssclasses:
  - book01
---
# 下载(视频所用版本)  
![](img/ly-20250419195232719.png)  

- MinGW: https://www.123912.com/s/u5pSjv-32uAH?提取码:M27Z  
	- 要记得设置环境变量
- qt库： https://download.qt.io/archive/qt/4.7/qt-win-opensource-4.7.0-mingw.exe  
- Qt Creator： https://download.qt.io/archive/qtcreator/2.0/qt-creator-win-opensource-2.0.1.exe  

# 编译
- 下载源码  
  `https://download.qt.io/archive/qt/4.7/qt-everywhere-opensource-src-4.7.0.zip`
- 修改`E:\Qt\qt-src\qt-everywhere-opensource-src-4.7.0\mkspecs\win32-g++\qmake.conf`,修改`QMAKE_LFLAGS = -static -enable-stdcall-fixup -Wl,-enable-auto-import -Wl,-enable-runtime-pseudo-reloc`(仅添加`-static`) 
- 打开`Qt4.7.0CommandPrompt`，`cd E:\Qt\qt-src\qt-everywhere-opensource-src-4.7.0`
## 静态编译
我用的是视频0087集的办法，也可以用 `https://www.cnblogs.com/atggg/p/16878575.html`试试 
```shell
#configure -confirm-license -opensource -platform win32-g++ -debug-and-release -static -static-runtime -nomake examples -nomake tests -skip qtwebengine -prefix "E:\Qt\qt-src\qt-everywhere-opensource-src-4.7.0\lystatic" -opengl desktop -no-angle
configure -platform win32-g++ -static  -no-exceptions -release -prefix "E:\Qt\qt-src\qt-everywhere-opensource-src-4.7.0\lystatic"
mingw32-make -j4       # 编译（-j4 表示 4 线程加速）
mingw32-make install   # 安装到指定目录
```
在项目的xxx.pro最后一行添加`CONFIG += static`
## 动态编译
```shell
configure -platform win32-g++ -shared -release
```
## qtCreator
- Qt Creator → 工具 (Tools) → 选项 (Options) → Kits
	- qmake.exe
	- Qt 4.7.0 (Static)
