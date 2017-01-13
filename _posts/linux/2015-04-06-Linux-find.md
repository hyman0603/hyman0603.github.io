---
layout: post
title: "13个实用的Linux find命令示例"
description: "13个实用的Linux find命令示例"
category: "linux"
tags: [linux基础]
---

<p><strong>注:本文摘自<a href="http://my.oschina.net/lijsf">青崖白鹿</a>,翻译的<a href="http://www.oschina.net/translate/15-practical-linux-find-command-examples">妈咪，我找到了! -- 15个实用的Linux find命令示例</a>, 感谢翻译的好文.</strong></p>

<hr />

<p>除了在一个目录结构下查找文件这种基本的操作，你还可以用find命令实现一些实用的操作，使你的命令行之旅更加简易。
本文将介绍15种无论是于新手还是老鸟都非常有用的Linux find命令。
首先，在你的home目录下面创建下面的空文件，来测试下面的find命令示例。</p>

<pre><code># vim create_sample_files.sh
touch MybashProgram.sh
touch mycprogram.c
touch MyCProgram.c
touch Program.c

mkdir backup
cd backup

touch MybashProgram.sh
touch mycprogram.c
touch MyCProgram.c
touch Program.c

# chmod +x create_sample_files.sh

# ./create_sample_files.sh

# ls -R 

backup                  MybashProgram.sh  MyCProgram.c
create_sample_files.sh  mycprogram.c      Program.c

./backup:
MybashProgram.sh  mycprogram.c  MyCProgram.c  Program.c
</code></pre>

<h2>1. 用文件名查找文件</h2>

<p>这是find命令的一个基本用法。下面的例子展示了用MyCProgram.c作为查找名在当前目录及其子目录中查找文件的方法。</p>

<pre><code># find -name "MyCProgram.c"
./backup/MyCProgram.c
./MyCProgram.c
</code></pre>

<h2>2.用文件名查找文件，忽略大小写</h2>

<p>这是find命令的一个基本用法。下面的例子展示了用MyCProgram.c作为查找名在当前目录及其子目录中查找文件的方法，忽略了大小写。</p>

<pre><code># find -iname "MyCProgram.c"
./mycprogram.c
./backup/mycprogram.c
./backup/MyCProgram.c
./MyCProgram.c
</code></pre>

<!--more-->

<h2>3. 使用mindepth和maxdepth限定搜索指定目录的深度</h2>

<p>在root目录及其子目录下查找passwd文件。</p>

<pre><code># find / -name passwd
./usr/share/doc/nss_ldap-253/pam.d/passwd
./usr/bin/passwd
./etc/pam.d/passwd
./etc/passwd
</code></pre>

<p>在root目录及其1层深的子目录中查找passwd. (例如root — level 1, and one sub-directory — level 2)</p>

<pre><code># find -maxdepth 2 -name passwd
./etc/passwd
</code></pre>

<p>在第二层子目录和第四层子目录之间查找passwd文件。</p>

<pre><code># find -mindepth 3 -maxdepth 5 -name passwd
./usr/bin/passwd
./etc/pam.d/passwd
</code></pre>

<h2>4. 在find命令查找到的文件上执行命令</h2>

<p>下面的例子展示了find命令来计算所有不区分大小写的文件名为“MyCProgram.c”的文件的MD5验证和。{}将会被当前文件名取代。</p>

<pre><code>find -iname "MyCProgram.c" -exec md5sum {} \;
d41d8cd98f00b204e9800998ecf8427e  ./mycprogram.c
d41d8cd98f00b204e9800998ecf8427e  ./backup/mycprogram.c
d41d8cd98f00b204e9800998ecf8427e  ./backup/MyCProgram.c
d41d8cd98f00b204e9800998ecf8427e  ./MyCProgram.c
</code></pre>

<h2>5. 相反匹配</h2>

<p>显示所有的名字不是MyCProgram.c的文件或者目录。由于maxdepth是1，所以只会显示当前目录下的文件和目录。</p>

<pre><code>find -maxdepth 1 -not -iname "MyCProgram.c"
.
./MybashProgram.sh
./create_sample_files.sh
./backup
./Program.c
</code></pre>

<h2>6. 使用inode编号查找文件</h2>

<p>任何一个文件都有一个独一无二的inode编号，借此我们可以区分文件。创建两个名字相似的文件，例如一个有空格结尾，一个没有。</p>

<pre><code>touch "test-file-name"
# touch "test-file-name "
[Note: There is a space at the end]

# ls -1 test*
test-file-name
test-file-name
</code></pre>

<p>从ls的输出不能区分哪个文件有空格结尾。使用选项-i，可以看到文件的inode编号，借此可以区分这两个文件。</p>

<pre><code>ls -i1 test*
16187429 test-file-name
16187430 test-file-name
</code></pre>

<p>你可以如下面所示在find命令中指定inode编号。在此，find命令用inode编号重命名了一个文件。</p>

<pre><code>find -inum 16187430 -exec mv {} new-test-file-name \;
# ls -i1 *test*
16187430 new-test-file-name
16187429 test-file-name
</code></pre>

<h2>7. 根据文件权限查找文件</h2>

<p>下面的操作时合理的：</p>

<p>找到具有指定权限的文件</p>

<p>忽略其他权限位，检查是否和指定权限匹配</p>

<p>根据给定的八进制/符号表达的权限搜索</p>

<p>此例中，假设目录包含以下文件。注意这些文件的权限不同。</p>

<pre><code>ls -l
total 0
-rwxrwxrwx 1 root root 0 2009-02-19 20:31 all_for_all
-rw-r--r-- 1 root root 0 2009-02-19 20:30 everybody_read
---------- 1 root root 0 2009-02-19 20:31 no_for_all
-rw------- 1 root root 0 2009-02-19 20:29 ordinary_file
-rw-r----- 1 root root 0 2009-02-19 20:27 others_can_also_read
----r----- 1 root root 0 2009-02-19 20:27 others_can_only_read
</code></pre>

<p>找到具有组读权限的文件。使用下面的命令来找到当前目录下对同组用户具有读权限的文件，忽略该文件的其他权限。</p>

<pre><code>find . -perm -g=r -type f -exec ls -l {} \;
-rw-r--r-- 1 root root 0 2009-02-19 20:30 ./everybody_read
-rwxrwxrwx 1 root root 0 2009-02-19 20:31 ./all_for_all
----r----- 1 root root 0 2009-02-19 20:27 ./others_can_only_read
-rw-r----- 1 root root 0 2009-02-19 20:27 ./others_can_also_read
</code></pre>

<p>找到对组用户具有只读权限的文件。</p>

<pre><code>find . -perm g=r -type f -exec ls -l {} \;
----r----- 1 root root 0 2009-02-19 20:27 ./others_can_only_read
</code></pre>

<p>找到对组用户具有只读权限的文件(使用八进制权限形式)。</p>

<pre><code>find . -perm 040 -type f -exec ls -l {} \;
----r----- 1 root root 0 2009-02-19 20:27 ./others_can_only_read
</code></pre>

<h2>8. 找到home目录及子目录下所有的空文件(0字节文件)</h2>

<p>下面命令的输出文件绝大多数都是锁定文件盒其他程序创建的place hoders</p>

<pre><code>find ~ -empty
</code></pre>

<p>只列出你home目录里的空文件。</p>

<pre><code>find . -maxdepth 1 -empty
</code></pre>

<p>只列出当年目录下的非隐藏空文件</p>

<pre><code>find . -maxdepth 1 -empty -not -name ".*"
</code></pre>

<h2>9. 查找5个最大的文件</h2>

<p>下面的命令列出当前目录及子目录下的5个最大的文件。这会需要一点时间，取决于命令需要处理的文件数量。</p>

<pre><code>find . -type f -exec ls -s {} \; | sort -n -r | head -5
</code></pre>

<h2>10. 查找5个最小的文件</h2>

<p>方法同查找5个最大的文件类似，区别只是sort的顺序是降序。</p>

<pre><code>find . -type f -exec ls -s {} \; | sort -n  | head -5
</code></pre>

<p>上面的命令中，很可能你看到的只是空文件(0字节文件)。如此，你可以使用下面的命令列出最小的文件，而不是0字节文件。</p>

<pre><code>find . -not -empty -type f -exec ls -s {} \; | sort -n  | head -5
</code></pre>

<h2>11. 使用-type查找指定文件类型的文件</h2>

<pre><code># 只查找socket文件
find . -type s

#查找所有的目录
find . -type d

#查找所有的一般文件
find . -type f

#查找所有的隐藏文件
find . -type f -name ".*"

#查找所有的隐藏目录
find -type d -name ".*"
</code></pre>

<h2>12. 通过和其他文件比较修改时间查找文件</h2>

<p>显示在指定文件之后做出修改的文件。下面的find命令将显示所有的在ordinary_file之后创建修改的文件。</p>

<pre><code>ls -lrt
total 0
-rw-r----- 1 root root 0 2009-02-19 20:27 others_can_also_read
----r----- 1 root root 0 2009-02-19 20:27 others_can_only_read
-rw------- 1 root root 0 2009-02-19 20:29 ordinary_file

# find -newer ordinary_file
.
./everybody_read
./all_for_all
./no_for_all
</code></pre>

<h2>13. 通过文件大小查找文件</h2>

<p>使用-size选项可以通过文件大小查找文件。</p>

<p>查找比指定文件大的文件</p>

<pre><code>find ~ -size +100M
</code></pre>

<p>查找比指定文件小的文件</p>

<pre><code>find ~ -size -100M
</code></pre>

<p>查找符合给定大小的文件</p>

<pre><code>find ~ -size 100M
</code></pre>

<p><strong>注意: – 指比给定尺寸小，+ 指比给定尺寸大。没有符号代表和给定尺寸完全一样大。</strong></p>
