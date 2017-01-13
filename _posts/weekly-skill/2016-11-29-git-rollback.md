---
layout: post
title: "git回滚策略"
category: "git"
---

[之前总结git 分支的时候，有tag命令](http://beginman.cn/2016/11/18/git-branch/#section)

今天看一篇博客[传送门](http://f2e.souche.com/blog/npm-assistor/)觉得他们git处理很值得借鉴，如下图：

![](http://beginman.qiniudn.com/2016-12-12-14804017731657.jpg)

**GitFlow 流程 :**

![](http://image-2.plusman.cn/image/GitFlowV2.jpg)

http://image-2.plusman.cn/image/GitFlowV2.jpg 浏览器打开，查看大图


# 通过tag 自动回滚

打 tag 的主要目的是什么？最最主要的作用是标记你的每次发布，然后在你发布的过程中如果出现问题了，你可以迅速知道你应该把代码回滚到何处。

```bash
# 先列出按照时间倒叙的 tag 列表
git tag -n --sort=-taggerdate
1.0.1-beta.1    考勤成员contact_id保留
1.0.1           考勤成员contact_id保留

# 然后取出第一行
git tag -n --sort=-taggerdate|head -1
1.0.1-beta.1    考勤成员contact_id保留

git tag -n --sort=-taggerdate|head -1|awk '{print $1}'

git reset --hard <tag> # 回滚指定版本

```

这个很牛逼，比如研究tornado源码的时候可先从简单的v1.0.0看起，那么就可以这样：

```bash
$ git clone https://github.com/tornadoweb/tornado.git
$ git reset --hard v1.0.0
```

（完~）


