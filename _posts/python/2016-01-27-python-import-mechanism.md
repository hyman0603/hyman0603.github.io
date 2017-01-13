---
layout: post
title: "python 导入机制"
category: "python"
tags: [python]
---
> python的导入就是猜猜我在哪？...

>读开源项目代码最高效的学习之一， 推荐：[如何更有效地学习开源项目的代码?](https://www.zhihu.com/question/19637879)

# 一.python模块导入机制

>每个py文件被称之为**模块**，每个具有`__init__.py`文件的目录被称为**包**,只要模
块或者包所在的目录在`sys.path`中，就可以使用import 模块或import 包来使用。

python模块导入时按优先级高低的搜索路径如下：

1. 程序主目录，执行程序则包含执行代码文件的目录，如：python sub/a.py，交互模式(如输入python)下为当前工作目录
2. PYTHONPATH中的目录
3. python安装目录,UNIX下，默认路径一般为/usr/local/lib/python/
4. 3.x 中`.pth` 文件内容

上述以列表的形式组合在`sys.path`中。如果模块路径存储在了sys.path 里就可直接import。

**第一次导入的步骤：**

1. 如上文的查找
2. 找到后，被导入的模块可能编译字节码
3. 加入sys.models中，生成内存映射关系，存放内存中
 
随后再导入则跳过上面的三个步骤。如果不想跳过则`reload()`处理。

# 二.命名空间和作用域

觉得这个基础教程:[Python 模块](http://www.runoob.com/python/python-modules.html)写的很不错, 我所认知的基本上从这里总结而来。

在此之前需要弄清楚以下知识点：

- python中一切皆对象，变量，类，字符串等都是对象
- 什么是变量，有变量一定会对应一块内存对象，python中没有什么声明定义，就是**引用**，那如何理解变量，**变量是拥有匹配对象的名字（标识符），相当于K-V结构。**
- 那什么又是命名空间呢？命名空间（Namespace）表示标识符（identifier）的可见范围，命名空间是对作用域的一种特殊的抽象，它包含了处于该**作用域**内的标识符，在python中命名空间是一个包含了变量名称们（键）和它们各自相应的对象们（值）的字典，也就是**K-V字典集**。
- 那什么是作用域(scope)呢？这个比较容易理解了，就是有效部分。

如C++多种不同的作用域声明：

	namespace N
	{                        // 命名空间作用域，仅是群组织别名
	   class C
	   {                     // 类作用域，定义/声明成员变量和函数
	      void f (bool b)
	      {                  // 函数作用域，包含可执行语句
	         if (b)
	         {               // 条件执行语句的无名作用域
	           ...
	         }
	      }
	   };
	}

同理 Python也一样。一个Python表达式可以访问局部命名空间和全局命名空间里的变量。如果一个局部变量和一个全局变量重名，则局部变量会覆盖全局变量，且每个函数都有自己的命名空间。类的方法的作用域规则和通常函数的一样。

Python会智能地猜测一个变量是局部的还是全局的，它假设任何在函数内赋值的变量都是局部的。那么这里声明是**全局变量**还是**局部变量**， 就需要分别用`global`语句和`locate`语句来显式声明了。


`globals()`和`locals()`函数可被用来返回全局和局部命名空间里字典。


# 三.常见问题

## 3.1 如何防止交叉引用

应该有N个办法吧：

- **不要全局导入，可改为局部作用域内导入**。如from XXX import YYY改为import XXX
- **函数内导入（惰性导入），使用的时候再导入**
- **把导入放在文件尾部而非顶部**
- **把公共部分抽出来，单独写到一个py模块中**
- **把两个文件合并成一个文件**

## 3.2 tornado使用相对路径导入 
注意，在**tornado使用相对路径导入**，则每次有变动后，autoreload就会报错：

	from ..error import ServerError, RouteNotFound, TenglishError
	ValueError: Attempted relative import beyond toplevel package

我在这个帖子[Tornado's autoreload is awesome, useful for auto recompile.
](http://python-tornado.narkive.com/VrzMzRnS/tornado-s-autoreload-is-awesome-useful-for-auto-recompile)找了好久也没找出一个解决方案，有建议通过模块的`__main__ .py`文件来处理：

	if sys.argv[0].endswith("__main__.py"):
		sys.argv[0] = "python -m theprojectname"

有建议直接使用`autoreload.py`提供的USAGE：
	
	Usage:
	python -m tornado.autoreload -m module.to.run [args...]
	python -m tornado.autoreload path/to/script.py [args...]

我都尝试了，但每次更改文件都会出现上面的问题，不知道是我没处理好还是怎么的。不得已改成import硬编码形式。**推荐使用相对路径，减少硬编码，不得已为之才使用硬编码。**

## 3.3 导入异常

如我的tornado项目，我将相对路径改成觉得路径，然后启动项目：

	python app.py
	
	Traceback (most recent call last):
		ImportError: No module named Tenglish.config

报错了，来看看我这项目组织架构：

	➜  Tenglish git:(master) ✗ tree
	.
	├── __init__.py
	├── app.py
	├── config.py
	├── db
	│   ├── __init__.py
	│   ├── user_db.py
	├── error
	│   ├── __init__.py
	├── routes
	│   ├── __init__.py
	│   ├── handler.py
	│   ├── user.py
	├── tests
	│   ├── __init__.py
	│   ├── db
	│   │   ├── __init__.py
	│   │   ├── test_db.py
	│   │   └── test_user_db.py
	│   ├── mocks
	│   │   ├── __init__.py
	│   ├── test_app.py
	│   ├── test_config.py
	│   └── testutils
	│       ├── __init__.py
	│       ├── mongo_unit.py
	└── utils
	    ├── __init__.py
	    ├── auth.py

是一个很正常的项目，再看看app.py:
	
	import tornado.ioloop
	import tornado.web
	import sys
	import os
	print sys.path
	import Tenglish.config as CONFIG
	from Tenglish.routes.user import AuthRoute
	
	
	def main(debug=True, port=CONFIG.PORT):
	    application = tornado.web.Application([
	        AuthRoute
	    ], debug=debug, autoreload=debug)
	    application.listen(port)
	    print '** theme english start with port:%s **' % port
	    tornado.ioloop.IOLoop.current().start()
	
	if __name__ == '__main__':
	    main()	

也是一个很正常的文件，但是如果把`import Tenglish.config as CONFIG`改成`import config as CONCIG`则这一行就不会出错，那么问题出在哪了呢？？

记得上面说过的python模块导入机制，这里看下程序主目录，在app.py里`print sys.path`输出的是`['/Users/fangpeng/mypro/theme-english/Tenglish', .....]` 一大堆，不管你是`python app.py`还是`python Tenglish/app.py`还是`python /path/to/yourprojcet/app.py`该项目的程序主目录还是不变，依然是/Users/fangpeng/mypro/theme-english/Tenglish, 因为我们导入时按照`projectName.module`导入的，如`from Tenglish.routes.user import AuthRoute`, 这样一来，在程序主目录/Users/fangpeng/mypro/theme-english/Tenglish下就要找Tenglish包(有`__init__.py`的正常包)当然找不到了，所以我们需要**在当前程序主目录下向外层目录扩展**，在app.py 在头部插入如下代码：

	import sys
	import os
	sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../"))
	
	if __name__ == '__main__':
	    reload(sys)
	    print sys.path
	    main()

则再次运行app.py，可看到在path中添加了相对外层的目录：
	
	['../', '/Users/fangpeng/mypro/theme-english/Tenglish',...]

那么这样，import config和import Tenglish.config都能使用了。

那么**还有一招就是`setup.py`安装该项目**，这样就不用考虑上面的问题了，也不用sys.path.insert(..)了， 这样比较**规范**些，以安装包的形式运行：
	
	#setup.py
	"""
	Tenglish setup
	For development:
	    `python setup.py develop`
	"""
	from setuptools import setup, find_packages
	import os
	if __name__ == "__main__":
	    setup(
	        name = "Tenglish",
	        packages = find_packages(),
	        install_requires = open(os.path.join(
	            os.path.dirname(__file__),
	            "req.txt"), 'rb').readlines(),
	        version = "0.1.0"
	    )


Python的import真不如Golang的import方便啊。

# 四.知识点汇总
我想你应该知道`__init__.py`的作用，在导入包时`__init__.py`会优先导入，进行初始化工作。

`__init__.py`可以为空，也可以写一些代码用来初始化工作，如自动加载子模块

	# myapp/format/__init__.py
	from . import jpg
	from . import png
	
常见用法就是**把多文件中定义统一到一个单独的逻辑命名空间中**

比如我们看`requests`项目的`__init__.py` [代码](https://github.com/kennethreitz/requests/blob/master/requests/__init__.py) 定义了一些`__title__ `,`__version__ `等，然后有导入了一堆子模块。

如果想精准控制导入项，可使用`__all__`来控制。

如果想直接让包或zip文件运行，如python mypackage, 则需要`__main__.py`来控制。解释器会把`__main__.py`文件作为主程序来执行。

对于import远程加载数据等**钩子机制**，觉得真心不如go方便，go直接写url路径即可。

参考：

- [Python 模块](http://www.runoob.com/python/python-modules.html)
- [wiki 命名空间](https://zh.wikipedia.org/wiki/%E5%91%BD%E5%90%8D%E7%A9%BA%E9%97%B4)
- [wiki 作用域](https://zh.wikipedia.org/wiki/%E4%BD%9C%E7%94%A8%E5%9F%9F)
- 《Python Cookbook》

