---
layout: post
title: "总结下Git分支的操作"
category: "git"
tags: [git, github]
---

今天中午吃罢饭，看之前束之高阁的[《Github入门与实践》](https://book.douban.com/subject/26462816/) 觉得狠补下git分支的知识。

从master衍生分支，不同的分支进行不同作业，等作业完成后再合并到master分支, 分支保证能**并行开发。**， 如下图是接下来要实验的例子的最终效果。

![](http://beginman.qiniudn.com/2016-11-18-14794496652544.jpg)


# 一.分支基础命令

`git branch --help` 命令先大致瞄一眼使用帮助。

- `git branch`: 查看本地分支
- `git branch -r`: 查看远程分支
- `git branch [name]` 创建分支，新分支创建后不会自动切换为当前分支
- `git checkout [name]` 切换分支, `git checkout -` 表示切换上一分支。
- `git checkout -b [name]` 创建新分支并立即切换到新分支
- `git branch -d [name]` 删除分支, `-d`只能删除已合并的分支，对于未有合并的分支是无法删除的。如果想强制删除一个分支，可以使用`-D`选项
- `git merge [name]` 合并分支, 与当前分支合并
- ` git push origin [name]` 创建远程分支(本地分支push到远程)
- `git push origin :heads/[name]` 删除远程分支 

**分支和标签的命令相似, 如下是tag命令**

- 查看版本：$ git tag
- 创建版本：$ git tag [name]
- 删除版本：$ git tag -d [name]
- 查看远程版本：$ git tag -r
- 创建远程版本(本地版本push到远程)：$ git push origin [name]
- 删除远程版本：$ git push origin :refs/tags/[name]

对于远程分支如下：

```bash
# 查看远程分支
$ git branch -r
    origin/HEAD -> origin/master
    origin/master
# 查看所有分支（local and remote）
$ git branch -a
    * master
    remotes/origin/HEAD -> origin/master
    remotes/origin/master
```

这里有origin, master, HEAD组合，要弄明白上列显示，就要先清楚，**git操作是基于local repository 和 remote repository的**。`git clone`时，会将远程仓库命名为origin, 这里的origin只是一个别名，是git远程仓库地址的别名，执行`git remote -v`可知：

```bash
$ git remote -v
origin	git@git.coding.net:beginman/yapis.git (fetch)
origin	git@git.coding.net:beginman/yapis.git (push)
```

`git clone `根据你指定的remote server/repository/branch，拷贝一个副本到你本地，然后建立一个指向它的master分支的指针，所以origin/master就是远程分支，同时，Git 会在本地建立一个属于你自己的本地master分支，它指向的是你刚刚从remote server传到你本地的副本。所以上面的第一行的master就是local branch。

**那HEAD指向当前工作的branch(HEAD 就是当前活跃分支的游标)**。也就是master分支。

# 二.分支流

**git推荐的分支流如下：**

1. (长期分支)master分支为长期稳定分支，保存发布或即将发布的代码。
2. (长期分支)develop 或 next 的平行分支，专门用于后续的开发，或仅用于稳定性测试。
3. (短期分支)比如iss53 分支用于修复某一个问题，修复成功后合并master然后可删掉该短期分支。
4. (特性分支)topic, 一个特性分支是指一个短期的，用来实现单一特性或与其相关工作的分支。（PS，其实也即是(短期分支)比如iss53）。


**随着提交对象不断右移的指针, 所以master分支总是稳定的，落后的。**

![](https://git-scm.com/figures/18333fig0318-tn.png)

工作流如下：

![](https://git-scm.com/figures/18333fig0319-tn.png)

# 三. 分支技巧

`git merge --help` 合并分支命令，如 `git merge [branch-name]`, 默认不会提交合并日志，加上`--no-ff`参数可在历史记录中记录本次的合并操作， 这样可使用`git log --merges` 查看分支合并日志。

比如如下操作，在分支develop开发完毕新功能后合并到master分支，然后用git log 看下。

```bash
# develop branch ... done
$ git add -A && git commit -m "添加app启动入口"     # 在develop分支提交
$ git checkout -    # 切换到master分支
$ git merge --no-ff -m "合并develop分支" develop  # 合并分支

$ git log --graph  # 以图表形式查看
*   commit f43a2960c99f9a3a543ddeafb7b5e495dd1496ab
|\  Merge: bef16d2 83580ad
| | Author: beginman <xinxinyu2011@163.com>
| | Date:   Fri Nov 18 15:27:09 2016 +0800
| |
| |     合并develop分支
| |
| * commit 83580adec8dda1f8b329de4b4d1615e746d7b390
| | Author: beginman <xinxinyu2011@163.com>
| | Date:   Fri Nov 18 15:26:01 2016 +0800
| |
| |     添加app启动入口 
```

# 四.常见问题

**问题1：push问题**

>我从master分支创建了一个issue5560分支，做了一些修改后，使用git push origin master提交，但是显示的结果却是'Everything up-to-date'，发生问题的原因是git push origin master 在没有track远程分支的本地分支中默认提交的master分支，因为master分支默认指向了origin master 分支，这里要使用git push origin issue5560：master 就可以把issue5560推送到远程的master分支了。

**如果想把本地的某个分支test提交到远程仓库，并作为远程仓库的master分支，或者作为另外一个名叫test的分支，那么可以这么做。**

```bash
# 提交本地test分支作为远程的master分支, github就会自动创建一个test分支
$ git push origin test:master       
# 提交本地test分支作为远程的test分支
$ git push origin test:test             
```

**如果想删除远程的分支呢？类似于上面，如果`:`左边的分支为空，那么将删除`:`右边的远程的分支。**

```bash
# 远程的test将被删除，但是本地还会保存的
$ git push origin :test              
```

**问题2：gitlab或github下fork后如何同步源的新更新内容？**

这里来自[知乎高浩阳的答案](https://www.zhihu.com/question/28676261)

1.给fork配置上游仓库 

```bash

$ git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git
$ git remote -v  # 查看是否成功

```

2.同步fork

从上游仓库 fetch 分支和提交点，提交给本地 master，并会被存储在一个本地分支 upstream/master ,然后merge到本地master分支上。

```bash
$ git fetch upstream

$ git checkout master
# 把 upstream/master 分支合并到本地 master 上，这样就完成了同步，并且不会丢掉本地修改的内容。 
$ git merge upstream/master

# 如果想更新到 GitHub 的 fork 上，直接
$ git push origin master
```

# 五.回溯

从一个小demo开始，从远程clone一个库，新建feature-A分支并更改Readme.md文件内容，然后合并到master。

```bash
$ git clone git@git.coding.net:beginman/demo.git
$ cd demo
$ git checkout -b feature-A
$ echo "writed by feature-A" >> README.md
$ git add -A && git ci -m "fA 修改了Readme.md"

$ git checkout -
$ git merge --no-ff -m "feature-A分支合并到master" feature-A
$ git log --graph

*   commit 461fd5de026bdc771d332b5f05926afd84712bc1
|\  Merge: 1304a56 0cc7217
| | Author: beginman <xinxinyu2011@163.com>
| | Date:   Fri Nov 18 15:56:11 2016 +0800
| |
| |     feature-A分支合并到master
| |
| * commit 0cc72176161fde780b150a633d25a164089feb2a
|/  Author: beginman <xinxinyu2011@163.com>
|   Date:   Fri Nov 18 15:54:52 2016 +0800
|
|       fA 修改了Readme.md
|
* commit 1304a56c89139a6e1ff1ae57d3597f4711cb6c41
  Author: i团队 <xinxinyu2011@163.com>
  Date:   Fri Nov 18 15:53:04 2016 +0800

      Initial commit
```

然后回溯到创建feature-A分支前。

>要让仓库的 HEAD、暂存区、当前工作树回溯到指定状态,需要用 到git rest --hard命令。只要提供目标时间点的哈希值,就完全恢复至该时间点的状态

```bash
$ git reset --hard 1304a56c89139a6e1ff1ae57d3597f4711cb6c41
HEAD is now at 1304a56 Initial commit
```

现在回到原点了，来看下我的操作：

```bash
1304a56 HEAD@{0}: reset: moving to 1304a56c89139a6e1ff1ae57d3597f4711cb6c41
461fd5d HEAD@{1}: merge feature-A: Merge made by the 'recursive' strategy.
1304a56 HEAD@{2}: checkout: moving from feature-A to master
0cc7217 HEAD@{3}: commit: fA 修改了Readme.md
1304a56 HEAD@{4}: checkout: moving from master to feature-A
1304a56 HEAD@{5}: clone: from git@git.coding.net:beginman/demo.git
```

然后创建fix-B分支并修改Readme

```bash
$ git checkout -b fix-B
$ echo "writed by fix-B" >> README.md
$ git add README.md
$ git commit -m "Fix B"
```

那么现在的状态是：

![](http://beginman.qiniudn.com/2016-11-18-14794571984946.jpg)



接下来恢复到 feature-A 分支合并后的状态，通过 `git reflog`命令,查看当前仓库的操作日志。在日志中找出 回溯历史之前的哈希值,通过 `git reset --hard` 命令恢复到回溯历史前的状态。

找到这一行，表示 feature-A 特性分支合并后的状态,对应哈希值 为 461fd5d。我们将 HEAD、暂存区、工作树恢复到这个时间点的状态。

    461fd5d HEAD@{4}: merge feature-A: Merge made by the 'recursive' strategy.
    
恢复, 先checkout到master分支后才reset.

```bash
$ git checkout master
$ git reset --hard 461fd5d
HEAD is now at 461fd5d feature-A分支合并到master
```

那么恢复了feature-A后的状态图如下：

![](http://beginman.qiniudn.com/2016-11-18-14794572611174.jpg)


接下来制造冲突了，合并fix-B分支。

```bash
$ git merge --no-ff -m "merge fix-B" fix-B

Auto-merging README.mdCONFLICT (content): Merge conflict in README.mdRecorded preimage for 'README.md'Automatic merge failed; fix conflicts and then commit the result.
```

修改README.md冲突内容后，提交解决后的结果

```bash
$ git add README.md
$ git commit -m "Fix conflict"
```

小技巧， `git commit --amend` 修改提交信息。 上一条提交信息记为了"Fix conflict",但它其实是fix-B分支的合并,解决合并时发生的冲突只是过程之一,这样标记实在不妥。 于是,我们要修改这条提交信息， 修改为 "Merge branch 'fix-B'" 或者快速修改，加`-m` 参数， 如：

```bash
git commit --amend -m "XXXX"
```

(完)~


