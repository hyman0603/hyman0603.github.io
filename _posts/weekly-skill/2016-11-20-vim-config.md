---
layout: post
title: "wks-02:Vim配置文件语法学习"
category: "一周新技术"
tags: vim
---

上一周新技术[wks-01:Vagrant学习](http://beginman.cn/2016/11/13/vagrant/) 对Vagrant有所了解，这周来学习vim配置文件语法。

**这篇博客的目标：**

1. 知道Vim的基本术语，如"buffer"、"window"、 "normal mode"、"insert mode"、"text mode"。
2. 搞懂vim配置文件
3. 搞懂其语法
4. 写自己的一套简单的配置

[这是我的vim配置文件](https://gist.github.com/BeginMan/baac945fc21df885e19e5cb16ad99c45), 效果如下：

![](http://beginman.qiniudn.com/2016-11-21-14797259160690.jpg)

当然这都是从别人的博客里学来的，虽然一直用vim但是都是小打小闹，这一次希望有所突破，那就从配置文件入手吧。


# 一.Vimrc文件

`~/.vimrc`，每次启动vim时，vim都会自动执行其代码。在VIM中执行`:echo $MYVIMRC`可查看路径。

# 二.打印命令

`echo`和`echom`命令，在vim中可执行`:help command`来查看命令的帮助手册。

如果要打印信息，输入`:echo "字符串"`,或`:echom '字符串'`, 字符串单双引号都行，就在屏幕底部打印出来。它们的用法一样，差别就是：

>`:echo`命令 会打印输出，但是一旦你的脚本运行完毕，那些输出信息就会消失。使用`:echom`打印的信息 会保存下来，你可以执行`:messages`命令再次查看那些信息。

如果在vimrc文件中添加一行代码，则每次打开vim就会打印你所编写的内容，如下：

```bash
# vim ~/.vimrc
echo ">^.^<, 加油Beginman!"

# 打开 vim
$ vim
$ >^.^<, 加油Beginman!
```

注释：`"`

# 三.设置选项

主要有两种选项：

1. 布尔选项（值为"on"或"off"）
2. 键值选项

执行方式：`:set 选项名`

比如，显示和隐藏行号

```bash
:set number     # 显示
:set nonumber   # 隐藏
```

**VIM中有很多`no`前缀表示反义。**

number是一个布尔选项：可以off、可以on

所有的布尔选项都是这种配置方法。

- `:set <name>`打开选项
- `:set no<name>`关闭选项。
- `:set <name>!` 来回切换
- `:set <name>?` 查看选项当前值
- `:set <name>=<value>` 键值选项, 有些选项并不只有off或on两种状态，它们需要一个值, 比如`:set numberwidth=10` 改变行号的列宽。

同理，这些`<name>` 都是命令，可`:help <name>`来查看帮助手册。

# 四.基本映射

这个必须要掌握，很牛逼。

先尝试一个小例子，在normal模式下， `:map - x`, 然后将光标置于文本某处，键入`-`, 可发现vim删除了当前光标下的字符，就如同你按下`x`一样。再搞一个`:map - dd` 则删除一行。

**映射的格式**：

    映射命令  按键组合 命令组合
    maptype  key     action

**maptype表示映射的类型**，分为两大类，带nore的和不带nore的, 具体类型通过`:help map-overview`可以查到。如：`nmap c ^i#<Esc>j`, 意思就是映射normal模式下的按键c为：`^i#<Esc>j`，就是在该行开头加上`#`号，然后下移一行。

常用的映射类型如下：

- map: 在所有模式下可用的映射
- vmap：在visual和select模式下可用的映射
- nmap：在normal模式下可用的映射
- imap：在insert模式下可用的映射
- omap：用于motion的一部分的映射。比如vw就是visual模式下选中一个词，可以用omap定义类似于w这样的动作操作符。
- cmap：用于在命令行下（输入:或/之类后）可用的映射

**key表示映射的键**: 各种特殊符号具体的表示方式见`:help key-notation`

**action就是映射出来的动作**。可以是一串字符串，或者调用一个函数，还可以是调用一个vim命令

比如在编辑模式下，将ESC键映射为jk: `inoremap jk <ESC>`

对**特殊字符**的处理，使用`<keyname>`告诉Vim一个特殊的按键。

```bash
:map <space> viw
```

你也可以映射修饰键入Ctrl和Alt。执行：

```bash
:map <c-d> dd
```

Ctrl+d将执行dd命令。

**删除映射：`:nunmap key`**


## 4.1 模式映射

就是上面的maptype类型，nmap模式下vmap就不能用，反之亦然。比如

```perl
" 在normal模式下，按下\。Vim会删除当前行
:nmap \ dd

" visual模式并选中一些文字，按下\。Vim将把选中文本转换成大写格式。
:vmap \ U
```

分别在normal模式和visual模式测试`\`按键，注意不同模式下的效应。

**insert模式:**

```bash
" 在insert模式下通过按键Ctrl+d删除整行。这个映射很实用
:imap <c-d> dd
```

然而我怎么试， 都仅仅是在文件中添加了两个d字符！ 它压根没用。

>问题就在于Vim只按我们说的做。这个例子中，我们说：“当我按下`<c-d>`时，相当于我 按了两次d”。而当你在insert模式下，按下两次d的作用就是输入两个字符d。

要想让这个映射按我们的期望执行，我们需要更加明确的指令。修改映射并运行如下命令：

```bash
:imap <c-d> <esc>dd
```

`<esc>`告诉Vim按下ESC按键，即退出insert模式

现在再试试这个映射。它能够正常工作，但是注意你是如何回到normal模式的。这是因为我们 告诉Vim`<c-d>`要退出insert模式并删除一行，但是我们没有告诉它再回到insert模式。

运行如下命令，修复映射问题：

```bash
:imap <c-d> <esc>ddi
```

结尾的`i`告诉Vim进入insert模式，至此我们的映射才最终完成。

还有一个实用技巧，在插入模式下将光标下的单词改成大写，这样就不再一直按着shift键了。关于Vim大小写处理，参考[**用vim处理字符的大小写转换**](http://blog.csdn.net/ruixj/article/details/3765385)

```bash
" <c-u>将当前光标所在的单词转换为大写
imap <c-b> <esc>gUwi
```


## 4.2 精确映射

有几点需要注意：

**1.映射可能会被Vim解释成其它的映射**

```bash
:nmap - dd
:nmap \ -
```

如上键`\`被映射`-`, `-`被映射为`dd`, 所以键入`\`就会删除整行(`dd`), 这样很容易造成歧义，可使用`nummap`删除它们。

```bash
# 删除映射
:nunmap -
:nunmap \
```

**2.映射会递归**

比如：`:nmap dd O<esc>jddk` 就会递归，陷入死循环。当你按下dd后，Vim解释为：

- dd存在映射，执行映射的内容。
    1. 新建一行。
    2. 退出insert模式。
    3. 向下移动一行。
    4. dd存在映射，执行映射的内容。
        - 新建一行。
        - 退出insert模式。
        - 向下移动一行。
        - dd存在映射，执行映射的内容。然后一直这样....

**3.映射无效**

如安装一个插件，映射了相同的键，那么两者冲突，有一个映射就无效。

那么上述的解决方案就是**非递归映射（Non-recursive mapping）！**，比如`nnoremap`

```bash
:nmap x dd
:nnoremap \ x
``` 

这样就不会递归，按下`\`时，Vim忽略了`x`的映射。

> **在任何时候，我们都应该使用非递归的映射命令**，每一个`*map`系列的命令都有个对应的`*noremap`命令，包括：noremap/nnoremap、 vnoremap和inoremap。这些命令将不递归解释映射的内容。我们只想在`*map` 星号与map中间加上`nore`就成了非递归映射命令，拯救自己于火海。


## 4.3 Leaders

leader键，如其名，领导者或称前缀，以这个键为基石配合多种键进行操作，如下例子：

```bash
" norma模式下快读敲入 `-d` 删除一行
:nnoremap -d dd
" 键入`-c` 删除一行并进入insert模式
:nnoremap -c ddO
```

>这就意味着你可以用一个你不常用的按键（如`-`）作为“前缀”，后接其它字符作为一个整体 进行映射。你需要多敲一个按键以执行这些映射，多一个按键而已，很容易就记住了。称这个“前缀”为“leader”。

设置leader键命令如下：

```bash
" 使用`,`做leader键比较合适，正好在右手边上
:let mapleader = ","
```

当你创建新的映射时，你可以使用`<leader>`表示“我设置的leader按键”。运行命令：

```bash
:nnoremap <leader>d dd
```

现在试试按下你的leader按键和d。Vim会删除当前行。

更详细可看手册：`:help mapleader`

## 4.4 在Vimrc中处理映射

这一节讲的是小技巧，如下:

- 在vim中正疯狂coding时，发现有一个映射很好用，如何立即将其加到`~/.vimrc`而不退出当前vim呢？
- 如何不退出VIM使vimrc立即生效呢？


第一个技巧，快速编辑vimrc, 在定义leader键下，输入如下：

```bash
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
```

那么在新的vim窗口中，键入`<leader>ev` 就以vsplit打开一个新的纵向分屏。好，那么现在编辑它吧。编辑之后如何让它立即生效呢？

第二技巧：重读映射配置

就像`.bashrc`文件一样，我们要`source`一下才会生效， vimrc一样。加个映射来解决这个问题：

```bash
:nnoremap <leader>sv :source $MYVIMRC<cr>
```

`:help myvimrc` 获取更多信息。

## 4.5 Abbreviations(缩写)

有点像拼写检查，比如 输入 adn 输入空格键，Vim会将其替换为and。

```bash
:iabbrev adn and
```

Abbreviations不仅仅只能纠错笔误。我们可以加几个日常编辑中常用的abbreviations。 运行如下命令：

```bash
:iabbrev @@    steve@stevelosh.com
:iabbrev ccopy Copyright 2013 Steve Losh, all rights reserved.
```

mappings也能实现，为什么不用呢？

比如：`:inoremap ssig -- <cr>Steve Losh<cr>steve@stevelosh.com`

原因就是：**mappings不管被映射字符串的前后字符是什么, 它只在文本中查找指定的字符串并替换他们。** 比如 输入 goodssig 也会被处理。运行下面的命令删除上面的mappings并用一个abbreviation替换它：

```bash
:iunmap ssig
:iabbrev ssig -- <cr>Steve Losh<cr>steve@stevelosh.com

```

这次Vim会注意ssig的前后字符，只会在需要的时候替换它。



## 4.6 更多的Mappings

Map拆分顺序从左到右，组个解释。如下：normal模式，移动光标至一个单词， 输入`<leader>"`。Vim将那个单词用双引号包围

```bash
:nnoremap <leader>" viw<esc>a"<esc>hbi"<esc>lel
```

拆分如下：

- `viw`: 高亮选中单词
- `<esc>`: 退出visual模式，此时光标会在单词的最后一个字符上
- `a`: 移动光标至当前位置之 后 并进入insert模式
- `"`: 插入一个"
- `<esc>`: 返回到normal模式
- `h`: 左移一个字符
- `b`: 移动光标至单词头部
- `i`: 移动光标至当前位置之 前 并进入insert模式
- `"`: 插入一个"
- `<esc>`: 返回到normal模式
- `l`: 右移一个字符，光标置于单词的头部
- `e`: 移动光标至单词尾部
- `l`: 右移一个字符，置光标位置在第一个添加的引号上

**在Vim中有很多默认的方式可以退出插入模式：** `<esc>`, `<c-c>`, `<c-[>`

# 五.变量

## 5.1 标量变量

命名方式为：**作用域:变量名**，常用的有如下几种：

- b:name —— 只对当前buffer有效的变量
- w:name —— 只对当前窗口有效的变量
- g:name —— 全局变量
- v:name —— vim预定义变量
- a:name —— 函数的参变量

浏览`:help internal-variables`中的作用域列表

## 5.2 特殊变量

如下特殊变量：

- `$NAME` —— 环境变量（一般变量名都是大写， 如`$VIMRUNTIME`表示vim运行路径）
- `&name` —— 选项（vim处理某些事情的时候的默认设置）
- `@r` —— register

注：使用`set`命令可以改变或查看选项设置，例如：`:set ignorecase`

## 5.3 变量赋值

`:let 变量名=值`

如下输入变量值

```bash
:let w:myname="Beginman"
:echo w:myname
```

**释放变量** `:unlet! 变量名`

## 5.4 运算符(和perl基本一样)

数学运算：`+ - * / % `.

逻辑运算：`== != > >= < <= ?`:

正则匹配运算符`=~ !~`

# 六.条件语句

## 6.1 多行语句

在VIM命令行模式下，**多行语句的处理方式有两种**：

- `:`
- `|`

如: 

```bash
# 分开成三行来写
:if 0
:    echom "ZERO"
:endif
 
# 用管道符(|)来隔开每一行
:echom "foo" | echom "bar"
```

**这样都比较繁琐，所以最好写在vimrc文件里。**

## 6.2 if

if 语法如下：

```bash
if 条件
    语句块
elseif 条件
    语句块
else
    语句块
endif
```

## 6.3 while

语法：

```bash
语句块
[break/continue]
endwhile
```

# 七.函数

## 7.1定义函数

>**没有作用域限制的Vimscript函数必须以一个大写字母开头！即使限定了作用域，也最好也用一个大写字母开头**


定义一个函数了语法：

```bash
function 函数名(参数)
    函数体
endfunc
```

执行下面的命令：

```bash
:function Meow()
:  echom "Meow!"
:endfunction
```

运行它：

```bash
:call Meow()
```

不出所料，Vim显示Meow!

**返回一个值**。执行下面的命令：

```bash
:function GetMeow()
:  return "Meow String!"
:endfunction
```

现在执行这个命令试试：`:echom GetMeow()`

Vim将调用这个函数并把结果传递给echom，显示Meow String!。

## 7.2 调用函数

**调用函数: `call`命令， 注意：当你使用call时，返回值会被丢弃， 所以这种方法仅在函数具有副作用时才有用。**

第二种方法是在表达式里调用函数。这次不需要使用call，你只需引用函数的名字。 执行下面的命令：

    :echom GetMeow()


# 八.自动命令

使用`autocmd`命令，比如新建文件时，如果autocmd匹配文件类型成功，则根据模版自动生成文件头。

```perl
autocmd BufNewFile *.py 0r $HOME/.vim/vim_template/vim_header_for_python
autocmd BufNewFile *.py ks|call CreatedTime()|'s
autocmd BufNewFile,BufRead *.py ks|call LastMod()|'s

autocmd BufNewFile *.sh 0r $HOME/.vim/vim_template/vim_header_for_sh
autocmd BufNewFile *.sh ks|call FileName()|'s
autocmd BufNewFile *.sh ks|call CreatedTime()|'s

fun LastMod()
	if line("$") > 10
		let l = 10
	else
		let l = line("$")
	endif
	exe "silent! 1," . l . "g/Last modified:.*/s/Last modified:.*/Last modified: " .strftime("%Y-%m-%d %T")
endfun

fun FileName()
  if line("$") > 10
    let l = 10
  else
    let l = line("$")
  endif
  exe "1," . l . "g/File Name:.*/s/File Name:.*/File Name: " .expand("%")
endfun

fun CreatedTime()
  if line("$") > 10
    let l = 10
  else
    let l = line("$")
  endif
  exe "1," . l . "g/Created Time:.*/s/Created Time:.*/Created Time: " .strftime("%Y-%m-%d %T")
endfun
" end auto add file header
```

在下设置Python模板： vim ~/.vim/vim_template/vim_header_for_python

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    :Author: beginman.cn
    :Mail:  pythonsuper@gmail.com
    :Created Time:
    :Last modified:
    :Copyright: (c) 2016 by beginman.
    :License: MIT, see LICENSE for more details.
"""
```

那么每次新建py就会引用该模板，或打开py文件则就会更改Created Time和Last modified的值

上面的代码解释如下：

- `ks`: 保存当前位置到 's' 标记
- `call LastMod()`: 调用 LastMod() 函数完成工作
- `'s`:光标回到旧的位置
- `silent!` 不显示错误信息，比如打开一个使用上述模板的py，如果没匹配上就有错误msg比较烦人。

LastMode() 函数先检查文件是否少于 10 行，然后用 "`:g`" 命令查找包含 "Last
Modified:" 的行。在这些行上执行 "`:s`" 命令实现从已有的时间到当前时间的替换。
"`:execute`" 命令使 "`:g`" 和 "`:s`" 命令可以使用表达式。日期用`strftime()`函数取
得。它可以用别的参数取得不同格式的日期字符串。

至此，一个简单的vimrc就搞定了。关于vim的学习不是一蹴而就的，我看很多博客都以**每天学点vim xxx**的形式进行学习，所以， vim是在每天的使用过程中不断的熟悉的。

# 参考

- [《笨方法学Vimscript》](http://learnvimscriptthehardway.onefloweroneworld.com/)
- [vim 配置文件语法](http://blog.csdn.net/trochiluses/article/details/21776365)

（完）~



