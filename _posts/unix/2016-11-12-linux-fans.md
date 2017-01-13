---
layout: post
title: "《Linux就是这个范》笔记 1.基础"
category: "docker"
tags: [docker, redis, nodejs]
---

**发行版本**

![](http://beginman.qiniudn.com/2016-11-21-14789234689848.jpg)

**架构设计**

![](http://beginman.qiniudn.com/2016-11-21-14789235355920.jpg)

Linux的图形界面效率比Windows要差，因为Linux靠多层软件协作，而Windows平铺直人。

书中作者搞了个蜜汁感动的小技巧，图片隐藏文字，不过作者搞的顺序不对，要把文字插入图片二进制文件顶部而不是尾部，这样`less`或`head`就可看到。

```bash
$ echo "hi,你好吗？,我的电话xxx,房间号：xxx, 嘿嘿嘿。。。">love.txt
$ cat love.txt me.jpg > love_me.jpg

# 对方收到图片，破解密语：
$ less love_me.jpg
...
```

![](http://beginman.qiniudn.com/2016-11-21-14789242517091.jpg)

真是让人蜜汁感动啊。

刚才上面的操作引出了文本处理的命令，`cat`/`more`/`less`/`echo`等就不解释了，Easy. 说下`head`和`tail`, 如其名：

- head: 查看文件头部内容
- tail: 查看文件尾部内容，常用命令选项是`-f`，跟随文件内容增长，显示文件的最新内容。

**Bash快捷键**

[Bash Shell常用快捷键](https://github.com/hokein/Wiki/wiki/Bash-Shell%E5%B8%B8%E7%94%A8%E5%BF%AB%E6%8D%B7%E9%94%AE)这个更好些。



