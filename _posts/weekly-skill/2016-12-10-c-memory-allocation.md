---
layout: post
title: "C内存分配与处理"
category: "c/c++"
---

唉哟我去，赵岩的《C语言点滴》错误太多了，不堪入目🙈啊。

# 一. C 数据类型一览

![](http://beginman.qiniudn.com/2016-12-10-14813512775739.jpg)

# 二. C 内存映象

![](http://beginman.qiniudn.com/2016-12-10-14813516235205.jpg)


| 区 | 存储 |
| --- | --- |
| 栈区 | 局部变量，返回值,形参等(短生命周期),自动分配和释放，快如闪电，但容量小. |
| 堆区 | 动态(malloc/free),自己管理内存 |
| 静态区 | 全局变量，static |
| 常量区 | 常量(不可变) |
| 代码区 | 程序 |

>“栈和堆是对向增长的，它们的容量并不是无限的，而是一定的。当使用递归函数的时候，如果调用的层数太深，栈会不断地增长，最后就会造成栈溢出（stack overflow）的错误。”


```c
// 最简单的递归函数
// 这段程序运行不到一分钟就产生"栈溢出"异常而终止
void main()
{
    main();
}
```

程序中，变量位置的不同决定了其在内存中的映象：

```c
int a = 4;              // 全局变量, 保存在静态存储器
static float f = 2.0f;  // 静态变量, 保存在静态存储器

int foo(int i)
{
    i++;        // 函数实参i, 保存在栈上
    return i;
}

int main(int argc, char **argv)
{
    int *p, k = 5;              // 局部变量 p,k保存在栈上
    char *pstr = "hello";       // hello字符串保存在常量存储区, pstr保存栈上
    char astr[10] = "hello";    // hello字符串以及变量astr都保存在栈上

    char *l = (char*)malloc(1); // 变量p,保存在栈上, p 指向的内存在堆上
    free(l);                    // 释放在堆上申请的内存

    int m = foo(k);
    printf("m=%d\n", m);
}
```

# 三.内存分配与释放

内存分配函数：`malloc`和`calloc`, loc 读`[loʊk]`, 内存释放`free`。

注意**分配的时候都没有数据类型的概念，分配的基本单位就是字节**。如果你想分配10 个int 类型的数，不能写成malloc(10)，而应该写成 `malloc(sizeof(int) * 10)`

分别声明如下：

```c
// size 为需要分配的内存空间的大小，以字节（Byte）计, 并返回该空间的首地址
void	*malloc(size_t size);      

// 从堆上获得size * n的字节空间，并返回该空间的首地址
void	*calloc(size_t n, size_t size);

// 重新分配
void * realloc(void * p,int n);

// 由于形参为void指针，free函数可以接受任意类型的指针实参。
void	 free(void *);     
```

## 3.1 malloc and calloc and realloc

分配成功返回指向该内存的地址，失败则返回 NULL。

注意：函数的返回值类型是 `void *`，**void 类型明显有泛型的概念，用户需要把void 类型强制转换成需要的类型**, void 并不是说没有返回值或者返回空指针，而是返回的指针类型未知。所以在使用 malloc() 时通常需要进行强制类型转换，将 void 指针转换成我们希望的类型，例如：

```c
char *ptr = (char *)malloc(10);  // 分配10个字节的内存空间，用来存放字符
```

**malloc与calloc的不同：**

- malloc函数分配得到的内存空间是未初始化的
- **函数calloc 会将所分配的内存空间中的每一位都初始化为零**。为字符类型或整数类型的元素分配内存，那么这些元素将保证会被初始化为0；指针类型的元素分配内存初始化为空指针NULL；实型数据分配内存，初始化为浮点型的零”
- malloc可以配合memset模拟calloc
- malloc速度快。
- 如果分配内存并初始化，推荐用calloc， 快一些。

如下实例：

```c
size_t size = sizeof(int);
int count = 1;

int *pm = (int *)malloc(count * size);
if (pm == NULL) exit(1);
printf("*pm=%d\n", *pm);

memset(pm, 0, count * size);    // 将pm指向的空间清0
printf("*pm=%d\n", *pm);

int *pc = calloc(count, size);
printf("*pc=%d\n", *pc);

free(pm);
free(pc);
pm = NULL;
pc = NULL;
```

**realloc函数**

    void * realloc(void * p,int n);

>其中，指针p必须为指向堆内存空间的指针，即由malloc函数、calloc函数或realloc函数分配空间的指针。realloc函数将指针p指向的内存块的大小改变为n字节。如果n小于或等于p之前指向的空间大小，那么。保持原有状态不变。如果n大于原来p之前指向的空间大小，那么，系统将重新为p从堆上分配一块大小为n的内存空间，同时，将原来指向空间的内容依次复制到新的内存空间上，p之前指向的空间被释放。relloc函数分配的空间也是未初始化的。


## 3.2 free

**free函数只是释放指针指向的内容，而该指针仍然指向原来指向的地方，此时，指针为`野指针`，如果此时操作该指针会导致不可预期的错误。安全做法是：在使用free函数释放指针指向的空间之后，将指针的值置为NULL**

```c
free(p);
p = NULL;
```

# 小实验

来指出哪些地方会出错：

```c
char *gp = "hello";     
char ga[] = "hello";   

char *f() {
    char *p = "hello"; 
    char a[] = "hello";
    p[0] = 'A';     // ?
    gp[0] = 'B';    // ?
    gp = a;         
    gp[0] = 'C';    // ?
    printf("gp=%s\n", gp);  // 请问这里输出什么？
    return a;       // ?
}

int main(int argc, char **argv)
{
    char *str = f();
    str[0] = 'D';   // ?
    ga[0] = 'E';    // ?
    // 请问输出什么？
    printf("gp=%s, str=%s, ga=%s\n", gp, str, ga);
    return 0;
}
```

假如这是一道面试题，那么考的就是**内存映象，搞明白它们的存储位置就能解出这道题。** 

首先分析下程序，试图改变保存在常量存储区字符串的操作都是不合法的，因为gp 和p 指向的“hello”和“hello”保存在常量存储区

其次，数组ga 和a 的内容，或者保存在静态存储区，或者保存在栈上，它们都是独立的，有自己的存储空间，所以允许对数组的内容进行修改。但是，数组`char a[]`在栈上生成，当函数f 结束的时候，所有的局部变量都从栈中弹出而消失，所以数组`char a[]`和其内容都不再存在。这个时候，即使用str 得到了数组的地址，也是指向一个不存在的数组。所以str[0]='D';也是不允许的。

最后。指针gp 和p 所指向的内容不可修改，但是并不意味着指针本身的值、也就是指针的指向不可修改。我们完全可以写出gp=a 的语句，这个时候，gp 指向数组a，这样，gp[0]='C'就是合法的了。看来，指针只是指向一个存储地点，不同的存储地点有不同的行为，所以，指针也就有了对应的特性，这些特性并不是指针带来的，而是由字符串处在不同的存储地点带来的。

看下面注释过的程序：

```c
char *gp = "hello";     // 字符串hello 保存在常量存储区, 而指针gp保存在静态存储区
char ga[] = "hello";   // hello和数组ga保存在静态存储区

char *f() {
    char *p = "hello"; // hello保存在常量存储器, 指针p保存在栈上
    char a[] = "hello";// hello和数组a 保存在栈上
//    p[0] = 'A';   // runtime error -> bus error
//    gp[0] = 'B';  // runtime error -> bus error
    gp = a;
    gp[0] = 'C';    // OK
    printf("gp=%s\n", gp);
    return p;       // 把 a 改成 p， return p;
}

int main(int argc, char **argv)
{
    char *str = f();
//    str[0] = 'D'; // runtime error -> bus error
    ga[0] = 'E';    // ok
    printf("gp=%s, str=%s, ga=%s\n", gp, str, ga);
    return 0;
}
```

输出如下：
    
    gp=Cello
    gp=, str=hello, ga=Eello

个中原因就不说了，见上面。

# 参考

- [《C语言点滴》]
- [C中堆管理——浅谈malloc,calloc,realloc函数之间的区别](http://www.cppblog.com/sandywin/archive/2011/09/14/155746.html)



