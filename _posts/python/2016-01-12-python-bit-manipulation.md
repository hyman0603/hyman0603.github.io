---
layout: post
title: "Python 位操作"
subtitle: "沉下心，打好CS基础是多么重要！理论和系统编程都要兼顾。"
header-img: "img/in-post/advanced_computer_science.jpg"
category: "python"
tags: [python]
---
>位操作是程序设计中对位模式按位，或二进制数的一元和二元操作。计算机里面所有数据都存储为0，1串，所有的运算归根到底都转为二进制数的运算。

PS: 我该好好回去多啃基本CS教材了,之前总结的笔记[《计算机科学概论》](https://github.com/BeginMan/BookNotes/tree/master/CS/Computer_Science_Illuminated)算他妈白瞎了~

![](http://img3.duitang.com/uploads/item/201601/20/20160120135638_JcBsQ.jpeg)

# 一.概念性总结

几个基本概念

- 机器数：一个数在计算机中的二进制表示形式,最高位存放符号, 正数为0, 负数为1
- 真值：将带符号位的机器数对应的真正数值称为机器数的真值(除符号位外的真正数值), 如：有符号数 10000011，其最高位1代表负，其真正数值是 -3 
- 高位与低位：计算机中存储的基本单位是字节(Byte)，一字节等于8bit（1B=8bit）。程序语言中的数据类型，像int,long,double的存储空间为2-8个字节不等，这就要考虑**如何跨多个字节来存储这些数据类型对应的数据了**。

其实也就是说，高位字节与低位字节是出现在多字节的情景中。Google出这篇文章：[C语言中的高位字节和低位字节是什么意思?](http://c.biancheng.net/cpp/html/1614.html),讲的很生动：

>通常我们从最高有效位(most significant digit)开始**自左向右**书写一个数字。在理解有效位这个概念时，可以想象一下你的支票数额的第一位增加1和最后一位增加1之间的巨大区别，前者肯定会让你喜出望外。

>计算机内存中一个字节的位相当于二进制数的位，这意味着最低有效位表示1 (2x0)，倒数第二个有效位表示2 (2×1)，倒数第三个有效位表示4 (2×2×1)，依此类推。如果用内存中的两个字节表示一个16位的数，那么其中的一个字节将存放最低的8位有效位，而另一个字节将存放最高的8位有效位，见图10．5。存放最低的8位有效位的字节被称为最低有效位字节或低位字节，而存放最高的8位有效位的字节被称为最高有效位字节或高位字节。

![](https://raw.githubusercontent.com/BeginMan/beginman.github.io/master/img/in-post/t15.png)


之前总结过：[top2: 二进制数值和计数系统](https://github.com/BeginMan/BookNotes/blob/master/CS/Computer_Science_Illuminated/top2.md)


# 二.位操作

**位操作是程序设计中对位模式按位，或二进制数的一元和二元操作。**, 首先有必要看看[wiki 位操作](https://zh.wikipedia.org/wiki/%E4%BD%8D%E6%93%8D%E4%BD%9C) 来复习一下。

位运算符有：

- 取反(NOT):	一元操作，对二进制每位执行逻辑反，1->0, 0->1, 值得注意的是此操作符与"逻辑非（!）"操作符不同
- 按位或(OR): 按位或处理两个长度相同的二进制数，两个相应的二进位中只要有一个为1，该位的结果值为1
- 按位异或（XOR): 对等长二进制模式按位，或二进制数的每一位执行逻辑异按位或操作。操作的结果是如果某位不同则该位为1，否则该位为0
- 按位与（AND）：处理两个长度相同的二进制数，两个相应的二进位都为1，该位的结果值才为1，否则为0
- 移位：将一个二进制数中的每一位全部都向一个方向移动指定位，溢出的部分将被舍弃，而空缺的部分填入一定的值。

![](http://segmentfault.com/img/bVp6Uv)

如下例子：

	>>> 0b1010 & 0b1100
	8   #1000
	>>> 0b1010 | 0b1100
	14  #1110
	>>> 0b1010 ^ 0b1100
	6   #0110
	>>> 0b1010 << 2
	40  #101000
	>>> 0b1010 >> 2
	2   #10
	>>> ~0b1010
	-11 #10000000 00000000 00000000 00001011
	>>> type(0b1010)
	<type 'int'>


注意：

> `0b` is a prefix for binary numbers;
> `0o` is a prefix for octal numbers
> `0x` is a prefix for hexadecimal numbers;

For example:
	
	In [139]: 0b10
	Out[139]: 2
	
	In [140]: 0o10
	Out[140]: 8
	
	In [141]: 0x10
	Out[141]: 16
	
一下代码在Python和JS(ECMAScript 6)脚本中都可执行.其中在JS中，还类似Python的语法，int第二个参数直接转换：

	# python
	int('10', 2)
	
	# JS
	parseInt('10', 2)

将2进制`10`转换为十进制，为2

上面`0b`开头的0、1串表示整型数字，在32位操作系统中，Python中int类型一般占32个二进制位，以最后一个求反运算为例子，1010的补码为00000000 00000000 00000000 00001010


# 二.原码，补码，反码，移码

计算机中对数字的表示有三种方式：

- 原码
- 反码
- 补码.

>计算机的硬件结构中**只有加法器**，所以大部分的运算都必须**最终转换为加法**，按位运算就把数字转换为机器语言，二进制的数字来运算的一种运算形式。在计算机系统中，**数值一律用补码来表示(存储)。**

推荐阅读：[**原码, 反码, 补码 详解**](http://www.cnblogs.com/zhangziqiu/archive/2011/03/30/computercode.html)

1. **原码**: 是指一个二进制数左边加上符号位后所得到的码，且当二进制数大于0时，符号位为0；二进制数小于0时，符号位为1；二进制数等于0时，符号位可以为0或1(+0/-0)。
2. **反码**: 正数的反码是其本身；负数的反码是在其原码的基础上，符号位不变，其余各个位取反。
3. **补码**: 正数的补码是其本身；负数的补码是在其原码的基础上，符号位不变，其余各位取反，最后+1。 (**即在反码的基础上+1**)。
4. **移码**: 符号位取反的补码，一般用做浮点数的阶码，引入的目的是为了保证浮点数的机器零为全0。

如下图解：

![](http://img.blog.csdn.net/20140504195529828?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2xjY29tZW9u/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

>**计算机中数字存储为补码形式，各个数之间的运算也是对它们的补码做运算，而且得到的结果也是补码**

如下图：

![](http://segmentfault.com/img/bVp6Ux)

# 三.Python按位操作

前面概念性的东西看了一遍，大致了解，下面用python来实现。

Python中的按位运算符有：左移运算符（`<<`），右移运算符（`>>`）,按位与（`&`），按位或（`|`），取反（`～`）。这些运算符中只有取反是单目运算符，其他的都是双目运算符。

参考[Bitwise operation and usage](http://stackoverflow.com/questions/1746613/bitwise-operation-and-usage)测试例子可以总结：

- `AND` is 1 only if both of its inputs are 1, otherwise it's 0.
- `OR` is 1 if one or both of its inputs are 1, otherwise it's 0.
- `XOR` is 1 only if exactly one of its inputs are 1, otherwise it's 0.
- `NOT` is 1 only if its input is 0, otherwise it's 0.

eg:

	AND | 0 1     OR | 0 1     XOR | 0 1    NOT | 0 1
	----+-----    ---+----     ----+----    ----+----
	 0  | 0 0      0 | 0 1       0 | 0 1        | 1 0
	 1  | 0 1      1 | 1 1       1 | 1 0


## 3.1 判断奇偶

`num & 0x1`

	>>> 13&0b1
	1
	>>> 10&0b1
	0
	>>> 10&0x1
	0
	>>> 13&0x1
	1

## 3.2 数字互换

	>>> def swap(n1, n2):
	...     n1 ^= n2
	...     n2 ^= n1
	...     n1 ^= n2
	...     return n1, n2
	... 
	>>> swap(1, 3)
	(3, 1)


## 案例：纯Py实现Ping命令

[pyping.py](https://github.com/BeginMan/pytool/blob/master/unp/ICMP_Ping/pyping.py)

# 参考：

- [位操作基础篇之位操作全面总结](http://blog.csdn.net/morewindows/article/details/7354571)
- [你不知道的按位运算](http://segmentfault.com/a/1190000003789802)




