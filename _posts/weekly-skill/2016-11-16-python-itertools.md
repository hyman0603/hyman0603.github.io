---
layout: post
title: "Python iterator模块"
category: "python"
tags: [iterator, 迭代器]
---

# 一. infinite iterator

无尽迭代：

```python
count(start, [step]) -> start, start+step, start+2*step, ...
cycle(iterable) -> p0, p1, ... plast, p0, p1, ...
repeat(object[, times]) -> e, e, e, ... endlessly or up to n times 
```

## 1.1 count

start default 0, step default 1

```python
In [6]: for i in izip(count(1, step=2), ['a', 'b', 'c']):
   ...:     print i
   ...:
(1, 'a')
(3, 'b')
(5, 'c')
```

## 1.2 cycle

实例：

```python
In [7]: i = 0

In [8]: for item in cycle(['a', 'b', 'c']):
   ...:     i += 1
   ...:     print (i, item)
   ...:     if i == 10: break
   ...:
(1, 'a')
(2, 'b')
(3, 'c')
(4, 'a')
(5, 'b')
(6, 'c')
(7, 'a')
(8, 'b')
(9, 'c')
(10, 'a')
```


## 1.3 repeat

实例：

```python
In [23]: for i in repeat('repeat it', 3):
   ...:     print i
   
In [24]: i = 0

In [25]: for r in repeat('repeat endless'): # times default is 0
    ...:     i += 1
    ...:     if i == 4: break
    ...:     print r
    ...:
repeat endless
repeat endless
repeat endless
```

# 二.处理输入序列迭代器

处理输入序列迭代器:

```bash
chain(*iterables) -> iter all items from iterables
chain.from_iterable(iterable) --> chain object
chain.next() x.next() -> the next value, or raise StopIteration

compress(data, selectors) --> iterator over selected data

dropwhile(predicate, iterable) --> dropwhile object

groupby(iterable[, keyfunc]) -> create an iterator which returns
(key, sub-iterator) grouped by each value of key(value).

ifilter(function or None, sequence) --> ifilter object

islice(iterable, [start,] stop [, step]) --> islice object

imap(func, *iterables) --> imap object
starmap(function, sequence) --> starmap object

tee(iterable, n=2) --> tuple of n independent iterators.

izip(iter1 [,iter2 [...]]) --> izip object
izip_longest(iter1 [,iter2 [...]], [fillvalue=None]) --> izip_longest object
```

## 2.1 chain

实例：

```python
In [27]: list(chain([1, 2, 3], "abc", ['x', 'y', 'z']))
Out[27]: [1, 2, 3, 'a', 'b', 'c', 'x', 'y', 'z']

# chain.from_iterable
In [29]: chain.from_iterable('abc')
Out[29]: <itertools.chain at 0x107729350>

In [30]: list(chain.from_iterable('abc'))
Out[30]: ['a', 'b', 'c']

# chain.next
In [36]: chain.next(chain.from_iterable('abc'))
Out[36]: 'a'

In [37]: chain.from_iterable('abc').next()
Out[37]: 'a'
```

## 2.2 compress

实例：

```python
In [42]: list(compress(['a', 'b', 'c', 'd'], selectors=[1,False,None, 23]))
Out[42]: ['a', 'd']

In [47]: list(compress('abcdefgh', map(lambda x: x > 5 , [4, 5, 6, 8])))
Out[47]: ['c', 'd']
```

## 2.3 dropwhile and takewhile

**字面意思，drop直到发现满足条件(函数predicate(item)为False)就停止drop不在处理后续，并返回剩下项。而takewhile整相反,创建一个迭代器，生成iterable中predicate(item)为True的项，只要predicate计算为False，迭代就会立即停止。**

```python
In [48]: def drop(x):
    ...:     print "item:", x
    ...:     return (x < 2)
    ...:
    
In [51]: for i in dropwhile(drop, [-1, 0, 2, 3, -2, -1, 5]):
    ...:     print 'Yielding: ', i
    ...:
item: -1
item: 0
item: 2
Yielding:  2
Yielding:  3
Yielding:  -2
Yielding:  -1
Yielding:  5

# takewhile
def should_take(x):
    print 'Testing:', x
    return (x<2)

for i in takewhile(should_take, [ -1, 0, 1, 2, 3, 4, 1, -2 ]):
    print 'Yielding:', i

Testing: -1
Yielding: -1
Testing: 0
Yielding: 0
Testing: 1
Yielding: 1
Testing: 2    
```


## 2.4 groupby

**这就比较常用：**

```python

In [60]: a = ['aa', 'bcd', 'abc', 'cd', 'abcde']

In [61]: for i, k in groupby(a, len):
    ...:     print i, list(k)
    ...:
2 ['aa']
3 ['bcd', 'abc']
2 ['cd']
5 ['abcde']

```

why? **groupby, 先排序后分组。**

> You must be careful to sort the data by the criteria before you call groupby or it won't work. 

```python
In [62]: for i, k in groupby(sorted(a, key=lambda x: len(x)), len):
    ...:     print i, list(k)
    ...:
2 ['aa', 'cd']
3 ['bcd', 'abc']
5 ['abcde']
```

`groupby` 经常配合 `itemgetter`使用，如下：

```python
In [63]: from operator import itemgetter

In [64]: d = dict(a=1, b=2, c=1, d=2, e=1, f=2, g=3)

In [65]: di = sorted(d.iteritems(), key=itemgetter(1))

In [66]: for k, g in groupby(di, key=itemgetter(1)):
    ...:     print k, map(itemgetter(0), g)
    ...:
1 ['a', 'c', 'e']
2 ['b', 'd', 'f']
3 ['g']
```

**多字段分组：**, 如 按年龄、分数分组并排序：

```python
def group_by_multi():
    result = {}
    grouper = itemgetter("age", "score")
    ls = [
        {'name': 'jack', 'age': 10, 'score': 78},
        {'name': 'rose', 'age': 14, 'score': 88},
        {'name': 'angle', 'age': 10, 'score': 74},
        {'name': 'tom', 'age': 10, 'score': 79},
        {'name': 'lory', 'age': 10, 'score': 74},
        {'name': 'tina', 'age': 14, 'score': 88},
    ]

    for key, grp in groupby(sorted(ls, key=grouper), grouper):
        value = list(grp)
        scores = {}
        for k, v in groupby(value, itemgetter('score')):
            v = list(v)
            scores.setdefault(k, []).append(v)
            result.setdefault(key[0], []).append(scores)
    return result
    
# out:
{
  "10": [
    {
      "74": [
        [
          {
            "age": 10,
            "score": 74,
            "name": "angle"
          },
          {
            "age": 10,
            "score": 74,
            "name": "lory"
          }
        ]
      ]
    },
    {
      "78": [
        [
          {
            "age": 10,
            "score": 78,
            "name": "jack"
          }
        ]
      ]
    },
    {
      "79": [
        [
          {
            "age": 10,
            "score": 79,
            "name": "tom"
          }
        ]
      ]
    }
  ],
  "14": [
    {
      "88": [
        [
          {
            "age": 14,
            "score": 88,
            "name": "rose"
          },
          {
            "age": 14,
            "score": 88,
            "name": "tina"
          }
        ]
      ]
    }
  ]
}
```



## 2.5 ifilter and ifilterfalse

> 创建一个迭代器，仅生成iterable中predicate(item)为True的项，如果predicate为None，将返回iterable中所有计算为True的项

实例：

```python
In [114]: list(ifilter(None, [1, 2, 0, -1, None, True, {}]))
Out[114]: [1, 2, -1, True]

In [115]: list(ifilterfalse(None, [1, 2, 0, -1, None, True, {}]))
Out[115]: [0, None, {}]

In [116]: def check_item(x):
     ...:     print "Testing:", x
     ...:     return x < 1
     ...:

In [117]: for i in ifilter(check_item, [-1, 0, 1, 2, 3, 4, 1, -2]):
     ...:     print "Yielding:", i
     ...:
Testing: -1
Yielding: -1
Testing: 0
Yielding: 0
Testing: 1
Testing: 2
Testing: 3
Testing: 4
Testing: 1
Testing: -2
Yielding: -2
```

## 2.6 islice

返回的迭代器是返回了输入迭代器根据索引来选取的项

    itertools.islice(iterable, start, stop[, step])


>创建一个迭代器，生成项的方式类似于切片返回值： iterable[start : stop : step]，将跳过前start个项，迭代在stop所指定的位置停止，step指定用于跳过项的步幅。 
>与切片不同，负值不会用于任何start，stop和step， 
>如果省略了start，迭代将从0开始，如果省略了step，步幅将采用1.
>返回序列seq的从start开始到stop结束的步长为step的元素的迭代器

实例：

```python
In [122]: list(islice("abcedfg", 3))
Out[122]: ['a', 'b', 'c']

In [123]: list(islice(count(), 3))
Out[123]: [0, 1, 2]

In [124]: list(islice("abcedfg", 2, 5))
Out[124]: ['c', 'e', 'd']
```



## 2.7 imap and starmap

`imap`: **它类似于内置函数 map() , 只是imap在迭代器结束后就停止(而不是插入None值来补全所有的输入).**

```python

In [126]: list(imap(lambda x: x * 2, range(5)))
Out[126]: [0, 2, 4, 6, 8]

In [127]: list(imap(None, range(5)))
Out[127]: [(0,), (1,), (2,), (3,), (4,)]

In [131]: for i in imap(lambda x, y: (x, y, x*y), range(3), range(6)):
     ...:     print '%d * %d = %d' % i
     ...:
0 * 0 = 0
1 * 1 = 1
2 * 2 = 4

# map 插入None值补全所有的输入
In [144]: for m in map(lambda x, y: (x,y), range(3), range(6)):
     ...:     print m
     ...:
     ...:
(0, 0)
(1, 1)
(2, 2)
(None, 3)
(None, 4)
(None, 5)
```

starmap: 对序列seq的每个元素作为func的参数列表执行, 返回执行结果的迭代器

```python

def starmap(function, iterable):
    # starmap(pow, [(2,5), (3,2), (10,3)]) --> 32 9 1000
    for args in iterable:
        yield function(*args)
        
values = [(0, 5), (1, 6), (2, 7), (3, 8), (4, 9)]
for i in starmap(lambda x,y:(x, y, x*y), values):
    print '%d * %d = %d' % i
```

## 2.8 tee

把一个迭代器分为n个迭代器, 返回一个元组.默认是两个

```python
In [158]: map(lambda x: list(x), tee('abc', 5))
Out[158]:
[['a', 'b', 'c'],
 ['a', 'b', 'c'],
 ['a', 'b', 'c'],
 ['a', 'b', 'c'],
 ['a', 'b', 'c']]
```


## 2.9 izip and izip_longest

`izip`: 返回一个合并了多个迭代器为一个元组的迭代器. 它类似于内置函数zip(), 只是它返回的是一个迭代器而不是一个列表。

`izip_longest`: 与izip()相同，但是迭代过程会持续到所有输入迭代变量iter1,iter2等都耗尽为止，如果没有使用fillvalue关键字参数指定不同的值，则使用None来填充已经使用的迭代变量的值。

```python
In [165]: list(izip([1,2,3], "abcdefg"))
Out[165]: [(1, 'a'), (2, 'b'), (3, 'c')]

In [166]: list(izip_longest([1,2,3], "abcdefg"))
Out[166]:
[(1, 'a'),
 (2, 'b'),
 (3, 'c'),
 (None, 'd'),
 (None, 'e'),
 (None, 'f'),
 (None, 'g')]
```

# 三.组合生成器

## 3.1 product
返回`*iterables`元素的笛卡尔积的元祖，`repeat`关键字参数表示指定重复生成序列的次数。

```python

product('ab', range(3)) --> ('a',0) ('a',1) ('a',2) ('b',0) ('b',1) ('b',2)
product((0,1), (0,1), (0,1)) --> (0,0,0) (0,0,1) (0,1,0) (0,1,1) (1,0,0) ...

In [168]: list(product([1, 2, 3], "ab"))
Out[168]: [(1, 'a'), (1, 'b'), (2, 'a'), (2, 'b'), (3, 'a'), (3, 'b')]
In [172]: list(product('ab', repeat=1))
Out[172]: [('a',), ('b',)]

In [173]: list(product('ab', repeat=2))
Out[173]: [('a', 'a'), ('a', 'b'), ('b', 'a'), ('b', 'b')]
```

## 3.2 permutations

排列,创建一个迭代器，返回iterable中所有长度为r的项目序列,如果省略了r，那么序列的长度与iterable中的项目数量相同.

```python
In [178]: list(permutations("abc", 2))
Out[178]: [('a', 'b'), ('a', 'c'), ('b', 'a'), ('b', 'c'), ('c', 'a'), ('c', 'b')]

In [179]: list(permutations("abc"))
Out[179]:
[('a', 'b', 'c'),
 ('a', 'c', 'b'),
 ('b', 'a', 'c'),
 ('b', 'c', 'a'),
 ('c', 'a', 'b'),
 ('c', 'b', 'a')]

```

## 3.3 combinations

创建一个迭代器，返回iterable中所有长度为r的子序列，返回的子序列中的项按输入iterable中的顺序排序 (**不带重复**)

```python
In [181]: list(combinations("abc", 2))
Out[181]: [('a', 'b'), ('a', 'c'), ('b', 'c')]
```

## 3.4 combinations_with_replacement

创建一个迭代器，返回iterable中所有长度为r的子序列，返回的子序列中的项按输入iterable中的顺序排序 (带重复)

```python
In [182]: list(combinations_with_replacement("abc", 2))
Out[182]: [('a', 'a'), ('a', 'b'), ('a', 'c'), ('b', 'b'), ('b', 'c'), ('c', 'c')]
```


# 参考:

- [PYTHON-进阶-ITERTOOLS模块小结](http://wklken.me/posts/2013/08/20/python-extra-itertools.html)
- [2.7.8文档](http://python.usyiyi.cn/python_278/library/itertools.html)


