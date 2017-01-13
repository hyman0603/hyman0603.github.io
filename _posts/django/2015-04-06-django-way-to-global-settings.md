---
layout: post
title: "django全局变量的几种方式"
description: "django全局变量的几种方式"
category: "django"
tags: [django]
---

<p>不要重复造轮子,是python哲学之一.在django中会遇到一些需要全局变量的东西,如request信息,user信息,或者自己造的信息等,或许都需要在模板中进行渲染.对于这种需求,django提供了好几种方式,接下来一一讲解.</p>

<h1>一.构造Context处理器</h1>

<p>你需要一段context来解析模板。 一般情况下，这是一个 django.template.Context 的实例，不过在Django中还可以用一个特殊的子类， django.template.RequestContext ，这个用起来稍微有些不同。 RequestContext 默认地在模板context中加入了一些变量，如 HttpRequest 对象或当前登录用户的相关信息。</p>

<p>当你不想在一系例模板中都明确指定一些相同的变量时，你应该使用 RequestContext 。 例如，考虑这两个视图：</p>

<pre><code>from django.template import loader, Context

def view_1(request):
    # ...
    t = loader.get_template('template1.html')
    c = Context({
        'app': 'My app',
        'user': request.user,
        'ip_address': request.META['REMOTE_ADDR'],
        'message': 'I am view 1.'
    })
    return t.render(c)

def view_2(request):
    # ...
    t = loader.get_template('template2.html')
    c = Context({
        'app': 'My app',
        'user': request.user,
        'ip_address': request.META['REMOTE_ADDR'],
        'message': 'I am the second view.'
    })
    return t.render(c)
</code></pre>

<p>（注意，在这些例子中，我们故意 不 使用 render_to_response() 这个快捷方法，而选择手动载入模板，手动构造context对象然后渲染模板。 是为了能够清晰的说明所有步骤。）</p>

<!--more-->

<p>每个视图都给模板传入了三个相同的变量：app、user和ip_address。 如果我们把这些冗余去掉会不会更好？</p>

<p>创建 RequestContext 和 context处理器 就是为了解决这个问题。 Context处理器允许你设置一些变量，它们会在每个context中自动被设置好，而不必每次调用 render_to_response() 时都指定。 要点就是，当你渲染模板时，你要用 RequestContext 而不是 Context</p>

<p>最直接的做法是用context处理器来创建一些处理器并传递给 RequestContext 。上面的例子可以用context processors改写如下：</p>

<pre><code>from django.template import loader, RequestContext

def custom_proc(request):
    "A context processor that provides 'app', 'user' and 'ip_address'."
    return {
        'app': 'My app',
        'user': request.user,
        'ip_address': request.META['REMOTE_ADDR']
    }

def view_1(request):
    # ...
    t = loader.get_template('template1.html')
    c = RequestContext(request, {'message': 'I am view 1.'},
            processors=[custom_proc])
    return t.render(c)

def view_2(request):
    # ...
    t = loader.get_template('template2.html')
    c = RequestContext(request, {'message': 'I am the second view.'},
            processors=[custom_proc])
    return t.render(c)
</code></pre>

<p>我们来通读一下代码：</p>

<p>首先，我们定义一个函数 custom_proc 。这是一个context处理器，它接收一个 HttpRequest 对象，然后返回一个字典，这个字典中包含了可以在模板context中使用的变量。 它就做了这么多。</p>

<p>我们在这两个视图函数中用 RequestContext 代替了 Context 。在context对象的构建上有两个不同点。 一， RequestContext 的第一个参数需要传递一个 HttpRequest 对象，就是传递给视图函数的第一个参数（ request ）。二， RequestContext 有一个可选的参数 processors ，这是一个包含context处理器函数的列表或者元组。 在这里，我们传递了我们之前定义的处理器函数 curstom_proc 。</p>

<p>每个视图的context结构里不再包含 app 、 user 、 ip_address 等变量，因为这些由 custom_proc 函数提供了。</p>

<p>每个视图 仍然 具有很大的灵活性，可以引入我们需要的任何模板变量。 在这个例子中， message 模板变量在每个视图中都不一样。</p>

<p>在第四章，我们介绍了 render_to_response() 这个快捷方式，它可以简化调用 loader.get_template() ,然后创建一个 Context 对象，最后再调用模板对象的 render()过程。 为了讲解context处理器底层是如何工作的，在上面的例子中我们没有使用 render_to_response() 。但是建议选择 render_to_response() 作为context的处理器。这就需要用到context_instance参数：</p>

<pre><code>from django.shortcuts import render_to_response
from django.template import RequestContext

def custom_proc(request):
    "A context processor that provides 'app', 'user' and 'ip_address'."
    return {
        'app': 'My app',
        'user': request.user,
        'ip_address': request.META['REMOTE_ADDR']
    }

def view_1(request):
    # ...
    return render_to_response('template1.html',
        {'message': 'I am view 1.'},
        context_instance=RequestContext(request, processors=[custom_proc]))

def view_2(request):
    # ...
    return render_to_response('template2.html',
        {'message': 'I am the second view.'},
        context_instance=RequestContext(request, processors=[custom_proc]))
</code></pre>

<p>在这，我们将每个视图的模板渲染代码写成了一个单行。</p>

<h1>二.自定义方法替换</h1>

<p>如自定义一个方法,里面包含全局变量,然后views方法中return 调用该自定义方法,这个理念同上面的,只能处理部分,且每次都要手动添加.</p>

<pre><code># in utils.py:
def mp_render(request, template, context={}):
    context['user'] = request.user
   #... 所有的全局变量写在这里
    return render_to_response(template, context)

# in views.py:
from utils import mp_render

def views_meth1(request):
    return mp_render(request, 'template_1.html')

def views_meth2(request):
    return mp_render(request, 'template_2.html')

def views_meth3(request):
    return mp_render(request, 'template_3.html')
</code></pre>

<h1>三.TEMPLATE_CONTEXT_PROCESSORS构造全局变量</h1>

<p>虽然这是一种改进，但是，请考虑一下这段代码的简洁性，我们现在不得不承认的是在 另外 一方面有些过分了。 我们以代码冗余（在 processors 调用中）的代价消除了数据上的冗余（我们的模板变量）。 由于你不得不一直键入 processors ，所以使用context处理器并没有减少太多的输入量。</p>

<p>Django因此提供对 全局 context处理器的支持。 TEMPLATE_CONTEXT_PROCESSORS 指定了哪些context processors总是默认被使用。这样就省去了每次使用 RequestContext 都指定 processors 的麻烦。6</p>

<p>默认情况下， TEMPLATE_CONTEXT_PROCESSORS 设置如下：</p>

<pre><code>TEMPLATE_CONTEXT_PROCESSORS = (
    'django.core.context_processors.auth',
    'django.core.context_processors.debug',
    'django.core.context_processors.i18n',
    'django.core.context_processors.media',
)
</code></pre>

<p>接下来设置自己的 processors, 如在项目根目录新建utils工具目录app,里面包含utils.py类用于处理部分全局性的通用变量,在settings_processors.py中用于处理所有的全局变量. 则settings.py配置如下:</p>

<pre><code>TEMPLATE_CONTEXT_PROCESSORS = (
    'django.core.context_processors.auth',
    'django.core.context_processors.debug',
    'django.core.context_processors.i18n',
    'django.core.context_processors.media',
    'mysite.utils.settings_processors.settings'
)
</code></pre>

<p>在settings_processors.py编程如下:</p>

<pre><code>from django.conf import settings as _settings
def settings(request):
    """
    TEMPLATE_CONTEXT_PROCESSORS
    """
    context = { 'settings': _settings }
    user = request.user
    try:
          #..... 这里设置全局变量
    except Exception,e:
        log.error("settings:%s" % e)
    return context
</code></pre>

<p>我们分析django默认自带的   TEMPLATE_CONTEXT_PROCESSORS 中的 django.core.context_processors.py, 它里面定义了<code>auth</code>,<code>debug</code>,<code>i18n</code>,<code>media</code>等方法,如下:</p>

<pre><code>from django.conf import settings
from django.middleware.csrf import get_token
from django.utils.functional import lazy

def auth(request):
    """
    DEPRECATED. This context processor is the old location, and has been moved
    to `django.contrib.auth.context_processors`.

    This function still exists for backwards-compatibility; it will be removed
    in Django 1.4.
    """
    import warnings
    warnings.warn(
        "The context processor at `django.core.context_processors.auth` is " \
        "deprecated; use the path `django.contrib.auth.context_processors.auth` " \
        "instead.",
        PendingDeprecationWarning
    )
    from django.contrib.auth.context_processors import auth as auth_context_processor
    return auth_context_processor(request)

def csrf(request):
    """
    Context processor that provides a CSRF token, or the string 'NOTPROVIDED' if
    it has not been provided by either a view decorator or the middleware
    """
    def _get_val():
        token = get_token(request)
        if token is None:
            # In order to be able to provide debugging info in the
            # case of misconfiguration, we use a sentinel value
            # instead of returning an empty dict.
            return 'NOTPROVIDED'
        else:
            return token
    _get_val = lazy(_get_val, str)

    return {'csrf_token': _get_val() }

def debug(request):
    "Returns context variables helpful for debugging."
    context_extras = {}
    if settings.DEBUG and request.META.get('REMOTE_ADDR') in settings.INTERNAL_IPS:
        context_extras['debug'] = True
        from django.db import connection
        context_extras['sql_queries'] = connection.queries
    return context_extras

def i18n(request):
    from django.utils import translation

    context_extras = {}
    context_extras['LANGUAGES'] = settings.LANGUAGES
    context_extras['LANGUAGE_CODE'] = translation.get_language()
    context_extras['LANGUAGE_BIDI'] = translation.get_language_bidi()

    return context_extras

def media(request):
    """
    Adds media-related context variables to the context.

    """
    return {'MEDIA_URL': settings.MEDIA_URL}

def request(request):
    return {'request': request}
</code></pre>

<h1>四.中间件的使用</h1>

<p>中间件中是预处理的东西,也可设置全局变量,如<code>process_request</code>是对request请求预处理,<code>process_view</code>对view方法预处理,<code>process_response</code>是对response请求预处理等.</p>

<p>这里有篇翻译:<a href="https://myfavor.readthedocs.org/en/latest/topics/http/middleware.html">https://myfavor.readthedocs.org/en/latest/topics/http/middleware.html</a></p>

<p>中间件的具体使用将会在下节总结出来.如下是自己的处理;</p>

<pre><code>#coding=utf-8
#中间件扩展
__author__ = 'beginman'
from django.http import HttpResponseRedirect
from django.conf import settings

LOGIN_URLS = ['/manage/']
ANONYMOUS_URLS = ['/manage/userGreat/', '/manage/user/']

class Mymiddleware(object):
    def process_request(self, request):
        """Request预处理函数"""
        path = str(request.path)
        request.session['domain'] = settings.DOMAIN
        if path.startswith('/site_media/'):
            return None
        #验证登陆
        if request.user.is_anonymous():
            for obj in ANONYMOUS_URLS:
                if path.startswith(obj):
                    return None

            for obj in LOGIN_URLS:
                if path.startswith(obj):
                    return HttpResponseRedirect('/login/?url=%s' % path)
</code></pre>

<h1>五.缓存</h1>

<p>利用缓存也是个好办法,具体见<a href="http://blog.beginman.cn/blog/83/"><strong>django缓存系统之django缓存</strong></a></p>

<h1>六.session使用</h1>

<p>同理么.见<a href="http://blog.beginman.cn/blog/76/"><strong>Redis+Django(Session,Cookie)的用户系统</strong></a></p>

<p>好了,大概就是这么多了.</p>

<h1>七.参考</h1>

<p><a href="http://djangobook.py3k.cn/">1.djangobook</a></p>

<p><a href="http://blog.mycolorway.com/2012/01/14/inject-global-vars-in-django/">2.如何在Django模板中注入全局变量| 彩程团队BLOG</a></p>

<blockquote>
  <p>项目开发的六个阶段：1. 充满热情 2. 醒悟 3. 痛苦 4. 找出罪魁祸首 5. 惩罚无辜 6. 褒奖闲人</p>
  
  <p>程序员和上帝打赌要开发出更大更好——傻瓜都会用的软件。而上帝却总能创造出更大更傻的傻瓜。所以，上帝总能赢。——Anon</p>
</blockquote>

<p><img src="http://img1.mydrivers.com/img/20131009/s_07e35ba5865f4a1387ef0d85ec0f8533.jpg" alt="" /></p>
