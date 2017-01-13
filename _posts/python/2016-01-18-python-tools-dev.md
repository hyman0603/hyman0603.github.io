---
layout: post
title: "Python 项目工具构建"
description: "Python 项目工具构建"
category: "python"
tags: [python]
---

对于项目开发，一整套pythonic规范应该是：

1. pip工具使用，更加方便，通过更改PyPI源安装第三方package更加省时省力
2. 目录结构规范，需求明确后开始编写项目代码
3. 单元测试
4. 代码规范检查，如Pylint工具的使用
5. 代码审查
6. 打包
7. 为包编写单元测试
8. 包发布到PyPI，或私有 pypi 服务器上
9. 自动化测试
10. 自动化部署

ref:

- [python 基础设施讨论贴](https://gist.github.com/onlytiancai/3878168)
- [Python项目自动化部署最佳实践@搜狐](http://www.the5fire.com/auto-deploy-tool-for-python-app.html)
- [如何将你的Python项目用Github保管, 并在Pypi上发布, 和部署你的在线文档网站¶](http://python-with-github-pypi-and-readthedoc-guide.readthedocs.org/)
- [我们在360如何使用Python](http://blogs.360.cn/blog/how-360-uses-python-0/)

# 一.PyPI
PyPI(Python Package Index, Python包索引)，使用源码，`setuptools`，`pip`等方式安装第三方包。

使用easy_install或pip安装Python第三方库，默认的源地址是：https://pypi.python.org/simple/，国内访问比较慢且需要使用https协议。国内推荐用豆瓣pip源，比较快：

	# 手动指定源，可以在pip后面跟-i 来指定源
	sudo pip install web.py -i http://pypi.douban.com/simple

注意，后面要有`/simple`目录.如果要**改成默认源**，则修改`~/.pip/pip.conf`(无则创建)：
	
	[global]                                 
	index-url = http://pypi.douban.com/simple    

配置好了，我们安装[`yolk` (Command-line tool for querying PyPI and Python packages installed on your system.)](https://pypi.python.org/pypi/yolk)来试一下：
	
	➜  mypy  sudo pip install yolk -v                                 
	Password:
	Downloading/unpacking yolk
	  http://pypi.douban.com/simple/yolk/ uses an insecure transport scheme (http). Consider using https if pypi.douban.com has it available
	  Using version 0.4.3 (newest of versions: 0.4.3, 0.4.2, 0.4.1, 0.4.0, 0.3.0, 0.2.0, 0.1.0, 0.0.7, 0.0.6, 0.0.5, 0.0.4, 0.0.3, 0.0.2)
	  Downloading yolk-0.4.3.tar.gz (86kB): 
	  .......
	  
看到pip源已经是豆瓣的了。

# 二.目录结构规范

对于写第三方库类的目录结构，可参考一些开源库的写法，如：

- [Flask-RBAC](https://github.com/shonenada/flask-rbac)
- [requests](https://github.com/kennethreitz/requests)

基本套路一样。

如果是web framework, like django, tornado, flask则有如下建议：

1. **参考开源项目的目录结构**，如[Tornado Links](https://github.com/tornadoweb/tornado/wiki/Links)列举的, 或[June 论坛](https://github.com/pythoncn/june/tree/tornado-master), 之前翻译的一篇[Writing-an-API-with-Tornado](http://beginman.cn/tornado/2016/01/18/Writing-an-API-with-Tornado/)则给出了具体的参考。
2. flask目录结构在[《Flask Web开发：基于Python的Web应用开发实战》](http://book.douban.com/subject/26274202/)一书中作者给出了大型项目组织结构，还是挺好的。可参考这里[组织你的项目](https://spacewander.github.io/explore-flask-zh/4-organizing_your_project.html),[**Flask Web Development —— 大型应用程序结构（上）**](https://segmentfault.com/a/1190000002411388)。flask的目录结构比tornado而已还是有章可循的。
3. django目录结构可直接看django文档,很搞笑的是基本上每个django版本上django项目目录结构还有可能不一致。这种情况就依据django文档和开源项目。可以参考这篇文章[Django项目结构](http://kinegratii.com/articles/2015-01-20-the-structure-of-django-project)

注意：**首先参考文档，文档上没有则参考开源项目的写法。**

# 三.单元测试
## 3.1 unittest
代码内，简单的可以使用[doctests](https://docs.python.org/2/library/doctest.html).使用最多的还是[unittest](https://docs.python.org/2/library/unittest.html).

写单元测试唯一要矫正的就是：**不要偷懒！**

如何进行有效的单元测试：

1. 测试先行，遵循单元测试基本步骤：
	- 创建测试计划
	- 编写测试用例，准备测试数据
	- 编写测试脚本
	- 执行测试
	- 修正代码缺陷后重新测试直到满意
2. 遵循单元测试基本原则
	- 一致性。100次和一次执行结果应该一致，对于不确定性的结果尽量避免，如果测了多次你的结果还不一样，那就说明程序不严谨或者有问题。
	- 原子性。意味着单元测试的结果返回只有两种，True或False.不存在部分成果部分失败，如果这样就说明单元测试设计的不合理。
	- 单一职责。测试应该基于情景和行为，而不是方法，如果一个方法对应多种行为，应该有多个测试用例，而一个行为就是多个方法也只需一个测试用例。
	- 隔离性。不能依赖具体的环境，如数据库环境，环境变量等。单元测试所有输入应该是确定的，方法和行为结果是可预测的。所以最好不要存在if条件选择。
3. 使用单元测试框架。

之前看到这篇文章[**Python中单元测试**](http://pm.readthedocs.org/zh_CN/latest/unittest/python.html)觉得讲的很不错。作者给出的单元测试框架图很好：

>其实这里讲解的就是Python标准库，unittest模块，又叫PyUnit。类似其它编程语言，也都有对应的所谓XUnit，X可以替换为Java等其它编程语言等。这里只是简单讲解下unittest模块中的几个概念，当然其他XUnit也会有类似概念。

**test fixture**

貌似平时习惯直接就叫fixture了，如果非得翻译个中文名称，叫“装置”不知道合不合适，也就是测试需要的装备。理解上可以直接对应到上面提到过的setUp和tearDown。所谓fixture就是：比如，程序运行的前提需要数据库，还得准备测试用的数据，常见的那些对数据库的操作程序就会如此；又比如，程序运行的前提得访问某个网页，常见的那些爬虫程序就会如此。类似这些，得需要准备好这些fixtures，而这个装置能有所谓清理和还原的功效（tearDown），这样不至于各个测试执行的时候有环境污染造成各种诡异情况。

**test case**

这个最直白，也听的最多，叫测试用例。理解上可以直接对应到上面提到过的TestCase这个类。对于测试用例来说，就是针对功能代码，模拟一些输入，来验证输出是否符合预期。

**test suite**

测试套件，也好理解，就是包含了一堆test case的集合。使用上可以根据具体场景来归类各个test case吧，比如：根据业务逻辑分（模块A、模块B）；根据测试逻辑分（全功能测试、冒烟测试）。当然，测试套件也可以包含一堆其它测试套件。

**test runner**

跑测试的家伙，你把各个测试丢给他，他去执行，然后把测试结果形成一份报告让你看。

关系画个示例图，应该可以更好理解这除了test runner外的几个概念的关系吧：

![](http://pm.readthedocs.org/zh_CN/latest/_images/concept_relationship.png)

![](http://pm.readthedocs.org/zh_CN/latest/_images/order.png)

例子参考 [**unittest — Unit testing framework**](https://docs.python.org/2/library/unittest.html) (一定要多看文档。)
	
	import unittest
	
	class TestStringMethods(unittest.TestCase):
	
	  def test_upper(self):
	      self.assertEqual('foo'.upper(), 'FOO')
	
	  def test_isupper(self):
	      self.assertTrue('FOO'.isupper())
	      self.assertFalse('Foo'.isupper())
	
	  def test_split(self):
	      s = 'hello world'
	      self.assertEqual(s.split(), ['hello', 'world'])
	      # check that s.split fails when the separator is not a string
	      with self.assertRaises(TypeError):
	          s.split(2)
	
	if __name__ == '__main__':
	    unittest.main()

## 3.2 Mock

[Python Mock的入门](https://segmentfault.com/a/1190000002965620)
	   
# 四.代码规范检查
代码规范和整洁能看出一个人的**气质（主要是气质）**，python代码规范要准从[PEP 8 -- Style Guide for Python Code](https://www.python.org/dev/peps/pep-0008/)。编写代码时可参考：

- [PEP 8 -- Style Guide for Python Code](https://www.python.org/dev/peps/pep-0008/)
- [Google Python 风格指南 - 中文版](http://zh-google-styleguide.readthedocs.org/en/latest/google-python-styleguide/)
- pycharm 编辑器有PEP8代码规范提示
- 第三方库[pep8, Simple Python style checker in one Python file](https://github.com/PyCQA/pep8)
- 更强大的[pylint](http://www.pylint.org/)
 
之前用过[pep8](https://github.com/PyCQA/pep8)觉得挺不错的，但是没坚持下来这个好习惯，在创业型公司里，我身兼多职，确实忙不过来（借口：囧），于是乎就专门写功能性代码而没有走标准的软件开发流程，如单元测试，代码规范都没有去处理。

pylint确实很强大啊，为啥呢？因为光看文档就一大堆。。，好失败啊，自己竟然没有用过，只是以前bb过。现在让我也来尝尝鲜。那就先从[A Beginner’s Guide to Code Standards in Python - Pylint Tutorial](http://docs.pylint.org/tutorial.html)开始吧。

pylint分析代码，输出分为两部分：一是源码分析结构，另外是统计报告。统计报告的信息如下：

1. Statistics by type: 检查的模块，函数，类等数量，以及它们中存在文档注释以及不良命名的比例
2. Raw metrics: 代码、注释、文档、空行等占模块代码量的百分百统计
3. Duplication: 重复代码的统计百分比
4. Messages by category: 按照消息类别分类统计的信息以及和上一次运行结果的对比
5. Messages: 具体的消息ID以及它们出现的次数

消息以MESSAGE_TYPE:LINE_NUM:[OBJECT:]MESSAGE的形式输出，分五类：

1. (C)惯例：违反了编码风格标准
2. (R)重构：写的非常糟糕的代码
3. (W)警告：某些Python特定的问题
4. (E)错误：很可能是代码中的bug
5. (F)致命错误： 阻止pylint进一步运行的错误

执行分析：

	pylint [options] module_or_package

关于pylint QA，可参考[Frequently Asked Questions](http://docs.pylint.org/faq.html#running-pylint)

# 五.打包发布
对于小项目直接copy就行，对于大团队或项目则需要**下载-安装-升级-卸载**处理来解决如下问题：

1. 程序发布，版本更新
2. 保证版本同步，有版本信息能让团队成员了然

可使用`distutils`标准库来完成：

1. 包的构建，安装，发布（打包）
2. PyPI登记，上传
3. 定义扩展指令协议

>随着项目规模的变大，以及几个子项目的启动，**代码复用**开始成为一个问题。有很多代码在多个库当中被使用，**应该被抽取出来成为单独的模块**。但是这些模块和模块的依赖关系会比较复杂，比如一个应用可能需要依赖pypi上开源的库，同时需要依赖一个内部的库，而内部的库又依赖开源的库。如何解决这种情况下的依赖管理和自动包管理呢？实际上setuptools 和 easy_install 已经提供了完善的依赖管理。

打包步骤如下：

### 1.编写setup.py文件
这是一个入口，如下目录组织：
	
	➜  mypy  tree
	.
	|	├── pretty_sql
	│   ├── __init__.py
	│   ├── __init__.pyc
	│   ├── pretty.py
	│   └── pretty.pyc
	├── requirements.txt
	├── setup.py
	└── tests
	    ├── __init__.py
	    └── test.py
	
可参考flask项目的[setup.py](https://github.com/mitsuhiko/flask/blob/master/setup.py) 发现需要的元素很多，如果要上传PyPI,则需要遵循[PEP 241 -- Metadata for Python Software Packages](https://www.python.org/dev/peps/pep-0241/),则需要更多元数据。

如果简单的`python setup.py develop`则可以手动写setup.py,看这个项目的[setup.py](https://github.com/sihrc/tornado-boilerplate/blob/master/setup.py)写的很好。

那么就需要智能化工具：`pastescript`,一个良好插件机制的命令行工具。安装后了就可以使用`paster`命令构建适用于setuptools的包文件结构。

	sudo pip install pastescript  
	
通过`yolk`工具，可看到其内部注册命令行入口paster,这是插件协议实现的细节。
	
	➜  mypy  yolk --entry-map pastescript
	{'console_scripts': {'paster': EntryPoint.parse('paster = paste.script.command:run')},
	....
	
关于`paster`的使用可以`paster -h`, fuck,在我的mac os x系统中一直报错`pkg_resources.DistributionNotFound: Flup`, 解决方案就是:

	pip search Flup
	
`pip search`相关库然后找到对应的安装:

	pip install Flup

安装后才试试，又出错，缺少些乱七八糟的玩意，那就一路search和install. 全部安装库清单如下：

	pip install flup
	pip install WSGIUtils
	pip install Cheetah
	pip install python-openid
	
PS. (`sudo`权限安装), 安装OK了再查看help: 

	➜  mypy  paster --help                 
	Usage: paster [paster_options] COMMAND [command_options]
	
	Options:
	  --version         show program's version number and exit
	  --plugin=PLUGINS  Add a plugin to the list of commands (plugins are Egg
	                    specs; will also require() the Egg)
	  -h, --help        Show this help message
	
	Commands:
	  create       Create the file layout for a Python distribution
	  help         Display help
	  make-config  Install a package and create a fresh config file/directory
	  points       Show information about entry points
	  post         Run a request for the described application
	  request      Run a request for the described application
	  serve        Serve the described application
	  setup-app    Setup an application, given a config file


如果看具体每个命令的帮助，则：

	paster help create   

`create`命令创建一个Python包项目， `-t(--template)`参数指定使用模板.**看帮助，看帮助，看帮助（重要三遍）**

如下使用它来构建包：

	➜  mypy  paster create -t basic_package pretty-sql
	Selected and implied templates:
	  PasteScript#basic_package  A basic setuptools-enabled package
	
	Variables:
	  egg:      pretty_sql
	  package:  prettysql
	  project:  pretty-sql
	Enter version (Version (like 0.1)) ['']: 0.1
	Enter description (One-line description of the package) ['']: Simple and named pretty datas for mysql query or other
	Enter long_description (Multi-line description (in reST)) ['']: Balabalabal....
	Enter keywords (Space-separated keywords/tags) ['']: named pretty mysql data dict dict-liked
	Enter author (Author name) ['']: BeginMan
	Enter author_email (Author email) ['']: xinxinyu2011@163.com
	Enter url (URL of homepage) ['']: http://beginman.cn
	Enter license_name (License name) ['']: MIT License
	Enter zip_safe (True/False: if the package can be distributed as a .zip file) [False]: 
	Creating template basic_package
	Creating directory ./pretty-sql
	  Recursing into +package+
	    Creating ./pretty-sql/prettysql/
	    Copying __init__.py to ./pretty-sql/prettysql/__init__.py
	  Copying setup.cfg to ./pretty-sql/setup.cfg
	  Copying setup.py_tmpl to ./pretty-sql/setup.py
	Running /usr/bin/python setup.py egg_info
	➜  mypy  tree
	.
	├── pretty-sql
	│   ├── pretty_sql.egg-info
	│   │   ├── PKG-INFO
	│   │   ├── SOURCES.txt
	│   │   ├── dependency_links.txt
	│   │   ├── entry_points.txt
	│   │   ├── not-zip-safe
	│   │   └── top_level.txt
	│   ├── prettysql
	│   │   └── __init__.py
	│   ├── setup.cfg
	│   └── setup.py
	├── pretty_sql
	│   ├── __init__.py
	│   ├── __init__.pyc
	│   ├── pretty.py
	│   └── pretty.pyc
	├── requirements.txt
	├── setup_cp.py
	└── tests
	    ├── __init__.py
	    └── test.py
	
这里在我的mypy目录下生成了以项目名pretty-sql命名的安装包文件夹和项目文件夹，如上。

如果是公司项目，比较省力的做法实现编写好模板文件，写上公司信息，版本信息等，通过`--config=your-prj-setup.cfg`参数就直接生成项目而不再交互式输入了。

# 六.为包编写单元测试
## 1. unittest

unittest能够自动匹配以`test`开头的方法

为包编写单元测试，由于多文件，则可以使用unittest的测试发现(test discover)功能:

	python -m unittest discover

递归查找当前目录下`test*.py`文件进行单元测试。

## 2.nose

[**nose, nose extends unittest to make testing easier.**](https://nose.readthedocs.org/en/latest/) 是Python平台的一个测试工具,比unittest更加强大。

	pip install nose

安装后则使用nosetests命令，如：`nosetests -h`查看帮助。

基本使用：

	nosetests [options] [(optional) test files or directories]

或是在家目录下写一个.noserc的配置文件（或是在项目目录下新建一个setup.cfg文件）：
	
	[nosetests]
	verbosity=3
	with-doctest=1

看这个项目[tornado-boilerplate/setup.cfg](https://github.com/sihrc/tornado-boilerplate/blob/master/setup.cfg)它的setup.cfg就罗列了nosetests配置项，在安装的时候就先测试。

nose自动递归查找从Python源文件，目录和包中收集测试，任何匹配正则表达式（默认为：`(?:^|[b_.-])[Tt]est`）的源文件，目录和包都会被搜集用作测试。

在一个测试目录或包中，任何匹配`testMatch`的Python源文件都会被检查用作测试例子。在一个模块中，名字匹配`testMatch`的函数和类 和`TestCase`的子类都会被用作测试。

具体使用可参考[nose文档](https://nose.readthedocs.org/en/latest/testing.html).

## 3.TDD(测试驱动开发)
>TDD全称Test Driven Development，是一种软件开发的流程,其开发过程是从功能需求的test case开始，先添加一个test case，然后运行所有的test case看看有没有问题，再实现test case所要测试的功能，然后再运行test case，查看是否有case失败，然后重构代码，再重复以上步骤。其理念主要是确保两

比如开发一个求序列平均数的例子:

	def avg(seq):
		pass
		
1. 先编写基本功能函数
2. 编写测试用例，对尽可能的输入如字符串，数值，空值等测试检查
3. 测试失败，则增强功能函数
4. 接下来再进行测试用例，测试失败后再健全和增强
5. 不断循环直到符合要求
6. 重构
7. 测试
8. 完工

这一流程的好处是：

1. 程序健壮性
2. 确保所有的需求都能被照顾到。
3. 在代码不断增加和重构的过程中，可以检查所有的功能是否正确。

但对于小公司比较难，因为时间太紧，人手不够。

# 八.发布到PyPI

[教你如何将你的Python项目用Github保管, 并在Pypi上发布, 和部署你的在线文档网站](https://github.com/MacHu-GWU/Python-with-GitHub-PyPI-and-Readthedoc-Guide)

[发布python的包至pypi服务器](http://yejinxin.github.io/distribute-python-packages-to-pypi-server/)

如果是公司内部的项目，不方便放到外网上去，则要搭建自己的内网pypi源。

[如何搭建自己的pypi私有源服务器](http://yijingping.github.io/2013/07/25/setting-up-your-own-pypi-server.html)

# 九.自动化测试

待完成

# 十.自动化部署

待完成

参考：

- [《编写高质量代码，改善Python程序的91个建议》](https://book.douban.com/subject/25910544/)
- [TDD并不是看上去的那么美](http://coolshell.cn/articles/3649.html)
