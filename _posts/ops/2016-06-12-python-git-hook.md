---
layout: post
title: "Python git钩子"
description: "检查代码，服务器端更新，自动化部署"
category: "ops"
tags: [ops,git,python]
---

# git 钩子与Python操作

## 一. git 钩子
在本地git项目下，[钩子](https://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E9%92%A9%E5%AD%90)有客户端钩子和服务端钩子，其都在`.git/hooks` 下，所有`*.sample`的文件都是示例钩子，如果将`.sample`去掉并**赋予可执行权限**则就有钩子了。这些脚本可以使用 shell, python, ruby 等任何可以调用 shell 命令的语言实现。

如果需要使用提交前的 hook 需要将 `pre-commit.sample` 文件重命名为 `pre-commit`. 如下测试：

	$ cat .git/hooks/pre-commit
	#!/bin/bash
	echo "不允许操作"
	exit 1


最后的返回码确定是否进行commit, 如果是0表示正常，非0则不允许commit.也就是**钩子以非零值退出，Git 将放弃该操作。** 如下示例：
	
	$ git ci -m "try commit"
	不允许提交

	# 修改 pre-commit 将 exit 1改为 exit 0, 再次尝试
	$ git ci -m "try commit"
	允许提交
	On branch master
	Your branch is ahead of 'origin/master' by 2 commits.
	...

如果在提交时不想进行 pre-commit, 只需要添加 `--no-verify` 参数即可。

	git commit --no-verify -m '提交信息'

## 二. python代码检查

我们可使用 pyflakes, pep8, flake8 检查 Python 语法，下面着重学习flake8, 先过一遍文档 [Flake8](https://flake8.readthedocs.io/en/latest/)

再终端查看帮助：

	`flake8 --help`

**Flake8包装了下列工具（套件）：**

- PyFlakes：静态检查Python代码逻辑错误的工具。
- pep8： 静态检查PEP 8编码风格的工具。
- Ned Batchelder’s McCabe script：静态分析Python代码复杂度的工具。

它综合上述三者的功能，在简化操作的同时，还提供了扩展开发接口。

**有如下特性：**

1.如果文件包含`# flake8: noqa` 则跳过

2.lines that contain a `# noqa` comment at the end will not issue warnings.

3.a Git and a Mercurial hook.(支持钩子，这个十分牛逼)

4.a McCabe complexity checker.(静态分析Python代码复杂度的工具)

在[Flake8简介](http://www.malike.net.cn/blog/2013/10/23/flake8-tutorial/)这篇博客中讲到：

>由于默认禁用代码条件复杂度检查，需要通过`–max-complexity`激活该功能：
`flake8 --max-complexity 12 .`
该功能对于发现代码过度复杂非常有用，根据Thomas J. McCabe, Sr（[Cyclomatic complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity)的创造者）研究，**代码复杂度不宜超过10，而Flake8官网建议值为12。**

5.通过flake8可扩展。扩展的入口点。

我们可使用

	flake8 --version
	2.5.4 (pep8: 1.7.0, pyflakes: 1.0.0, mccabe: 0.4.0) CPython 2.7.10 on Darwin
	
查看有哪些扩展，默认就是上面的三个，当然我们也可以[扩展](https://flake8.readthedocs.io/en/latest/extensions.html), 比如添加`TODO`扩展，则可用[flake8-todo](https://github.com/schlamar/flake8-todo)

	pip install flake8-todo
	flake8 --version
	2.5.4 (pep8: 1.7.0, pyflakes: 1.0.0, flake8-todo: 0.4, mccabe: 0.4.0) CPython 2.7.10 on Darwin
	
	flake8  mp.py
	mp.py:8:3: T000 Todo note found.
	mp.py:9:1: F821 undefined name 'ab'
	mp.py:11:1: E302 expected 2 blank lines, found 1
	mp.py:11:39: E261 at least two spaces before inline comment
	mp.py:24:27: E231 missing whitespace after ','
	mp.py:24:37: E231 missing whitespace after ','
	mp.py:24:48: E231 missing whitespace after ','


flake8足够强大，完全可取代[pep8](http://pep8.readthedocs.io/en/latest/)，这个pep8的安装 pip install pycodestyle。 使用也是`pycodestyle ..` 好奇葩啊，那么为什么还叫pep8呢。 我只知道[PEP 8规范](https://www.python.org/dev/peps/pep-0008/)

下面还有几个工具，如autopep8和pyflakes

- [autopep8 : A tool that automatically formats Python code to conform to the PEP 8 style guide](https://github.com/hhatto/autopep8)
- [pyflakes : A simple program which checks Python source files for errors.](https://github.com/pyflakes/pyflakes)

auto..顾名思义就是自动转换，这个可以尝试使用，自动将py文件转换为符合PEP8规范的文件。

到这里python代码检查的工具基本上看完了，那么就利用它们配合git钩子来实战吧

我参考（抄袭）了[使用 Git hook 实现自动代码检查](http://tonsh.github.io/git/2013/12/10/git-pre-commit.html)也实现了一个Git hook 实现自动代码检查钩子。[**pyhook.py**](https://github.com/BeginMan/pytool/blob/master/ops/pyhook.py),只不过我用的是flake8而非pep8。

之前写过webhook工具，叫[**smartwebhook**](https://github.com/BeginMan/smartwebhook)服务器端自动更新的钩子.

如果需要部署，那当属fabric自动化部署, 如这个脚本[**fabfile.py**](https://github.com/BeginMan/pytool/blob/master/ops/fabfile.py)。那么配合客户端钩子进行代码检查、服务器端钩子进行更新操作和fabric自动化部署，就使得整个项目的开发相得益彰，更加规范。

好了，我之前的博客[Python 项目工具构建](http://beginman.cn/python/2016/01/18/python-tools-dev/)貌似应该接上了。。。



