---               
layout: post   
title: "Multipart file upload with JSON serializer for tornado "
description: ""
category: "python"
tags: [python, tornado, json, upload]
---
在做APi开发时，遇到上传的情况也挺多的，如果文件较小则read后base64编码传输即可，如果大则需要`multipart/form_data`控制。下面分两类，小和大。

# 一.小文件传输

```python
data = {
        'group_name': 'adsa',
    }

with open('ini.xls', 'rb') as f:
        # 21 characters data:application/xls;
        encoded_string = ("data:application/xls;" + f.read()).encode('base64')

data['contact_file'] = encoded_string
api.request('group/create_with_import', data)
```

直接读取文件内容base64编码上传，这里客户端做文件类型校验，并添加`data:application/xls;`的标识来方便服务器校验请求是否合法。

下面是服务端的处理流程：

1. 限制文件大小
2. 文件类型校验
3. 文件内容解析

```python
...
size = self.size(contact_file) / 1024 / 1024
if size > 2:
  raise ServiceException(400, u'上传文件超出2MB大小限制')

try:
  contacts = base64.b64decode(contact_file)
except Exception as ex:
  logging.error(ex)
  raise ServiceException(400, u'上传文件失败')

if not self.check_mime_type(contacts):
  raise ServiceException(400, u'请上传Excel文件')
...
```

其实文件大小和类型很容易校验, 文件内容约等于base64编码过的4/3；而类型校验则与客户端约定的data:xxx， 如下代码：

```python
def size(self, b64string):
        return (len(b64string) * 3) / 4 - b64string.count('=', -2)

def check_mime_type(self, data):
   return len(data) > 21 and data[:21] == 'data:application/xls;'
```

# 二.大文件上传
没啥好说的，直接看代码， 首先目录结构如下：

```python
tornado-json-upload  » tree
.
├── __init__.py
├── client.py
├── server.py
└── uploads
```

这里使用requests库做客户端：

```python
import requests
import json

info = {
        'var1': [{'name':'fang', 'age': 26, 'items': [1, 2, 3]}],
        'var2': '2',
        'var3': [1,2,3,4]
    }
url = "http://127.0.0.1:8000/api/test"

def request_post_json_file():
    headers = {'Content-type': 'multipart/form_data'}
    files = {'document': open('server.py', 'rb')}

    r = requests.post(url, files=files, data=info, headers=headers)
    print r.json()


def request_normal():
    # r = requests.post(url, data=json.dumps(info))
    r = requests.post(url, data={'name': 'jack', 'age': 10})
    print r.json()


def request_json():
    r = requests.post(url, json=json.dumps(info))
    print r.json()

if __name__ == '__main__':
    request_normal()
    request_json()
    request_post_json_file()
```

服务端的处理：

```python
# coding=utf-8
"""
server
    :copyright: (c) 2016 by fangpeng(@beginman.cn).
    :license: MIT, see LICENSE for more details.
"""
import os
import StringIO
import uuid
import logging
from tornado.ioloop import IOLoop
from tornado.web import RequestHandler, Application
from tornado import httpserver
from tornado.httputil import parse_multipart_form_data
from tornado.escape import json_decode

UPLOAD_DIR = 'uploads/'


class UploadJsonFileHandler(RequestHandler):
    def prepare(self):
        self.parse_headers()

    def post(self, *args, **kwargs):
        self.write(self.req)

    def parse_headers(self):
        content_type = self.request.headers.get(
            'Content-Type', 'application/x-www-form-urlencoded')

        if content_type == 'multipart/form_data':
            self.deserialize(self.request.body)
        elif content_type in ('application/json',
                              'application/x-www-form-urlencoded'):
            self.parse_request()
        else:
            raise TypeError('unsupported headers:%s' % content_type)

    def parse_request(self):
        try:
            print self.request.body
            try:
                req = json_decode(self.request.body)
            except:
                req = {k: ''.join(v) for k, v in
                            self.request.arguments.iteritems()}
            self.req = req
        except Exception as ex:
            logging.error(ex)
            raise ValueError('request parsed error:%s' % ex)

    def deserialize(self, body):
        """
        deserialize the request body
        We need the boundary string 8d1e7a823982469d82c0358769ccba4c from body
        '''--8d1e7a823982469d82c0358769ccba4c
        Content-Disposition: form-data; name="document"; filename="test.txt"
        Test.txt content
        --8d1e7a823982469d82c0358769ccba4c--
        '''

        :param body:     request body
        :return:         deserialized json data
        """
        args = dict()
        post_data_multipart_files = dict()

        boundary_string = StringIO.StringIO(body).readline()[2:].strip()
        parse_multipart_form_data(
            boundary=boundary_string,
            data=body,
            arguments=args,
            files=post_data_multipart_files
        )

        # parse args
        for multipartfile in post_data_multipart_files.get('document') or []:
            if multipartfile:
                body, content_type, filename = multipartfile.values()
                unique_file_name = '%s' % uuid.uuid4()
                fullpath = os.path.abspath(UPLOAD_DIR + unique_file_name)

                if content_type in ['application/unknown']:
                    content_type = 'text/plain'

                # do something.
                with open(fullpath, 'wb') as f:
                    f.write(body)
        print args
        self.req = args
        # self.req.update(post_data_multipart_files)
        # print post_data_multipart_files

if __name__ == '__main__':
    app = Application([(r'/api/test', UploadJsonFileHandler)])
    server = httpserver.HTTPServer(app)
    server.listen(8000)
    IOLoop.current().start()
```

主要思想：

1. 熟悉HTTP协议，《HTTP权威指南》该放在案边好好研读的。
2. 深入理解Tornado源码， 有了HTTP协议思想后就看看这些框架是如何实现的，这里主要用到tornado的httputil模块`parse_multipart_form_data`


![](http://beginman.qiniudn.com/2016-09-22-14745375196758.jpg)

![](http://beginman.qiniudn.com/2016-09-22-14745375334126.jpg)

我们看下上传的body 

![](http://beginman.qiniudn.com/2016-09-22-14745376617803.jpg)
也就是上面的函数处理的方式。



