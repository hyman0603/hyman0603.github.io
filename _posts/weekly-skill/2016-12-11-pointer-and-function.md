---
layout: post
title: "C函数和指针"
category: "c/c++"
---

这节是看《C语言点滴》关于指针的总结笔记📒。

# 一. 用指针类型作参数形参

> **利用函数中的指针形参，可以改变传入函数的实参的值。**

这个是指针经典用法之一，不累述了。赵岩《C语言点滴》可真是一点一滴，不过指针这块讲解的很不错，比如下面的例子，想改变p的值。

*版本1.指针做形参*

```c
void f(int *ptr)
{
    ptr = (int *)malloc(sizeof(int));
    *ptr = 999;
}

int main(int argc, char **argv)
{
    int *p, k = 5;
    p = &k;
    f(p);
    printf("%d\n", *p);

}
```

这是一段高危代码，不仅没输出999反而内存泄漏。

ps:**其实呢，如果我们在f函数中不动态分配内存的话，这段代码是没问题的。**

>**因为函数调用遵循单向值传递**，所以，进入函数时，p 把自身保存的地址传递给ptr，它们同时指向k。在函数f中ptr 指向了malloc 申请的一块内存后，当程序退出，**ptr 因为是局部变量，在栈上定义，所以伴随着函数出栈而消失**。这里带来了两个问题，第一，指针p 的指向并没有被改变；第二，malloc 申请的内存由于没有任何指针指向，所以不能利用free 来释放，造成了内存的泄露。”

![](http://beginman.qiniudn.com/2016-12-13-14813900042985.jpg)

**解决方案：**

1. **利用函数返回值**
2. **利用指向指针类型的指针**


```c
// 1. 利用函数返回值
int *f()
{
    int *ptr = (int *)malloc(sizeof(int));
    *ptr = 999;
    return ptr;
}

int main(int argc, char **argv)
{
    int *p, k = 5;
    p = &k;
    printf("%d\n", *p);
    p = f();
    printf("%d\n", *p);

    free(p);    // 避免内存泄漏

}

// 2. 利用指向指针类型的指针
void f(int **ptr)
{
    *ptr = (int *)malloc(sizeof(int));
    **ptr = 999;
}

int main(int argc, char **argv)
{
    int *p, k = 5;
    p = &k;
    printf("%d\n", *p);
    f(&p);  // 传入的是指针变量的地址
    printf("%d\n", *p);

    free(p);    // 避免内存泄漏

}

```



# 二. 函数返回指针类型

常见错误：

```c
char* func(int i)
{
    char str[100];    // 大小不确定
    return str;   // error 
}
```

函数中数组str定义在栈上，所以str 会随着函数的结束而消失，虽然通过函数返回了一个指针，但是指向一个消失变量的指针还有什么意义呢？

**不完美的解决方案：**

利用malloc 函数从堆申请出一片内存，这块内存不会伴随着函数的退出而消失。所以使用完这个函数后，我们必须调用free 函数来释放内存。

```c
char* func(int i)
{
    char *str = (char *) malloc(100);
    return str;
}
```

这个解决方案之所以不完美是因为我们还要free来释放内存.

**更好的接口定义：**

允许函数传入一个地址。当使用这个函数时，你可以通过指针p 传入一个数组，或者传入一个malloc 函数分配的内存。如果你使用malloc 函数分配的内存，你应该有责任使用free 来释放这片内存。另外，这个函数还把传入的地址返回，这样这个函数就可以直接用在表达式中

```c
char* func(int i, char *p) 
{
    // 具体实现...
    return p;
}

char a[100];    // 或 char *a = malloc(n);
printf("%s", func(1, a));
```


# 三. 函数指针

**指向一个函数，函数指针最常见的一个用处就是："回调函数"**

函数指针的声明和数组指针有点类似：

```c
int (*p)[3];    // 数组指针，指向的是一个数组
int (pf)();     // 函数指针，指向的就是一个函数，这个函数返回一个整数

pf=＆func;       // 取地址运算符 来让函数指针pf 指向一个特定的函数func

// 用如下方式皆可调用func这个函数
pf();
(*pf)();    
```

如下实例：

```c
int f(int i, int j)
{
    return i+j;
}

int main(int argc, char **argv)
{
    int (*fp)();
    fp = &f;
    int m = (*fp)(1, 2);
    int n = fp(1, 2);
    printf("%d, %d", m, n);

}
```

下面实现一个支持多种类型的冒泡排序算法：

```c
#include <stdio.h>
#include <stdlib.h>

/*
 * 第一个参数为要排序的数组
 * 第二个参数为数组内的数量
 * 第三个参数为数组元素类型所占的空间字节大小
 * 第四个参数为函数指针
 */
void sort(void *data,
          int n,
          int type_size,
          int (*ptr)(const void *, const void *))
{
    int i, j;
    void *temp = malloc(type_size);
    void *addr_1, *addr_2;
    for (i = 0; i < n - 1; ++i) {
        for (j = i+1; j < n; ++j) {
            addr_1 = data + i * type_size;
            addr_2 = data + j * type_size;
            if (ptr(addr_1, addr_2) > 0) {
                memcpy(temp, addr_1, type_size);
                memcpy(addr_1, addr_2, type_size);
                memcpy(addr_2, temp, type_size);
            }
        }
    }
    free(temp);
}

/*
 * 浮点数比较程序
 */
int comp_double(const void *a, const void *b)
{
    if (*(double *)a - *(double *)b > 0) {
        return 1;
    } else if (*(double *)a - *(double *)b < 0.001) {
        return 0;
    }
    return -1;
}

/*
 * 整数比较
 */
int comp_int(const void *a, const void *b)
{
    return *(int *)a > *(int *)b;
}


int main(int argc, char **argv)
{
    double n[] = {19.23, 0.32, 88.32, 20.31, 2.193};
    sort(n, 5, sizeof(double), &comp_double);
    for (int i = 0; i <5; ++i) {
        printf("%10.3f", n[i]);
    }

    printf("\n");
    
    int m[] = {2, 3, 1, 8, 3, 4};
    sort(m, 6, sizeof(int), &comp_int);
    for (int i = 0; i <5; ++i) {
        printf("%10d", m[i]);
    }

    printf("\n");
}
```

标准库中有qsort 函数，采用快速排序算法，比冒泡排序效率要高。qsort 函数采用的也是这种基于回调函数的方法。


(完)~

