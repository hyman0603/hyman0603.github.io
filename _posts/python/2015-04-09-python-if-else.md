---
layout: post
title: "python if else 多种写法"
description: "python if else 多种写法"
category: "python"
tags: [python]
---

For example:

	a, b, c = 1, 2, 3

# 1. Common
	
	if a > b:
	    c =  a
	else:
	    c = b

# 2.Expression

	c = a if a > b else b

# 3.二维列表

	c = [b, a][a > b]

# 4.and-or

	c = (a > b and [a] or [b])[0]

