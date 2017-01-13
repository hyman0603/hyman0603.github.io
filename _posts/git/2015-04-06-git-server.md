---
layout: post
title: "搭建git服务器"
description: "搭建git服务器"
category: "git"
tags: [git]
---

<h2>1.生成 SSH 公钥</h2>

<p>首先在自己的电脑上生成SSH公钥，只需要一个命令就可以了。</p>

<pre><code>$ ssh-keygen
</code></pre>

<p>这样，就在电脑下生成了一个.ssh的文件夹，里面有两个文件，分别是：id_rsa(密钥)和id_rsa.pub(公钥)。服务器上需要用到公钥里面的内容，可以发送给服务器管理者。</p>

<!--more-->

<h2>2.架设服务器</h2>

<p>首先，创建一个 'git' 用户并为其创建一个 .ssh 目录。</p>

<pre><code>$ sudo adduser git
$ su git
$ cd
$ mkdir .ssh 
$ cd .ssh
$ touch authorized_keys
</code></pre>

<p>接下来，把开发者的 SSH 公钥添加到这个用户的 <code>authorized_keys</code> 文件中。</p>

<pre><code>scp ~/.ssh/id_rsa.pub git@your.server.com:~/.ssh/  //scp将公钥复制到服务器中
ssh git@your.server.com 
cd ~/.ssh 
cat id_rsa.pub &gt;&gt; authorized_keys     //重定向到authorized_keys
</code></pre>

<p>现在可以使用 <code>–bare</code> 选项运行 <code>git init</code> 来设定一个空仓库，这会初始化一个不包含工作目录的仓库。</p>

<pre><code>$ mkdir project.git
$ cd project.git
$ git --bare init
</code></pre>

<p>这时，开发人员就可以把它加为远程仓库，推送一个分支，从而把第一个版本的工程上传到仓库里了。</p>

<h2>3.初始化远程分支和数据</h2>

<p>接下来在自己本地进行数据初始化</p>

<pre><code>$ makedir myproject
$ cd myproject
$ git init
$ &gt;a.txt
$ git add -A
$ git commit -m 'initial commit'

$ git remote add origin ssh@106.163.xx.xx/root/project.git

$ git push origin master
</code></pre>

<p>然后对其他人添加只他的公钥加进去后，把项目Clone下来：</p>

<pre><code>$ git clone ssh@106.163.xx.xx/root/project.git
</code></pre>

<p>就可以一同操作了，但注意每次push项目之前，应该先git pull。</p>

<h2>4.禁止git密码登录</h2>

<p>作为一个额外的防范措施，你可以用 Git 自带的 git-shell 简单工具来把 git 用户的活动限制在仅与 Git 相关。把它设为 git 用户登入的 shell，那么该用户就不能拥有主机正常的 shell 访问权。为了实现这一点，需要指明用户的登入shell 是 git-shell ，而不是 bash 或者 csh。你可能得编辑 /etc/passwd 文件。</p>

<pre><code>$ sudo vim /etc/passwd
</code></pre>

<p>在文件末尾，你应该能找到类似这样的行：</p>

<pre><code>git:x:1000:1000::/home/git:/bin/sh
把 bin/sh 改为 /usr/bin/git-shell （或者用 which git-shell 查看它的位置）。该行修改后的样子如下：

git:x:1000:1000::/home/git:/usr/bin/git-shell
</code></pre>

<p>现在 git 用户只能用 SSH 连接来推送和获取 Git 仓库，而不能直接使用主机 shell。如果你需要添加公钥的时候就需要用root用户进行操作了。</p>

<p><img src="http://ritter.readthedocs.org/en/latest/_images/git.png" alt="" /></p>

<p>图片来源：<a href="http://ritter.readthedocs.org/en/latest/refer/git.html">GIT Tools</a></p>

<h2>5.参考</h2>

<p><a href="https://ruby-china.org/topics/5040">https://ruby-china.org/topics/5040</a></p>
