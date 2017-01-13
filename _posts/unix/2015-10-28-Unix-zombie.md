---
layout: post
title: "Unix 处理僵尸进程"
description: ""
category: "unp"
tags: [Unix网络编程]
---

要弄清楚以下知识点：

1. 什么是僵尸进程？什么是孤儿进程？
2. 僵尸进程所带来的坏处？
3. 如何去用C编写僵尸进程和孤儿进程？并用Linux命令去查看和分析
4. 如何避免僵尸进程？
5. `wait()`和`waitpid()`怎么用？两者之间的区别？

带着这些问题去google或翻阅资料。

# 一. 什么是僵尸进程？
进程在exit后，父进程会调用`wait`和`waitpid`得到进程ID，终止状态，使用的CPU时间等信息（**直到父进程通过`wait` / `waitpid`来取时才释放**）；而僵尸进程则没有父进程调用wait或waitpid来获得它的结束状态，那么子进程的进程描述符仍然保存在系统中。这种进程称之为僵死进程。孤儿进程则是没有对应的父进程，最后会被`init`进程(PID 1)回收。

# 二. 僵尸进程所带来的坏处？

存在大量僵尸进程，如果进程不调用wait / waitpid的话， 那么保留的信息就不会释放，其**进程号就会一直被占用**，但是系统所能使用的进程号是有限的，如果大量的产生僵死进程，将因为没有可用的进程号而导致系统不能产生新的进程。

# 三. 如何去用C编写僵尸进程和孤儿进程？并用Linux命令去查看和分析

代码放在github上了，如下：

- [测试僵尸进程的代码 gen_Zombie_process.c](https://github.com/BeginMan/BookNotes/blob/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition/source/demo/gen_Zombie_process.c)
- [测试孤儿进程的代码 gen_orhans_process.c](https://github.com/BeginMan/BookNotes/blob/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition/source/demo/gen_orhans_process.c)

在Linux分析进程做好用`ps`命令，ps命令是Process Status的缩写。

linux上进程有5种状态: 

1. R(running)运行(正在运行或在运行队列中等待) 
2. S(sleep)中断(休眠中, 受阻, 在等待某个条件的形成或接受到信号) 
3. D(uninterruptible sleep)不可中断(收到信号不唤醒和不可运行, 进程必须等待直到有中断发生) 
4. Z(zombie)僵死(进程已终止, 但进程描述符存在, 直到父进程调用wait4()系统调用后释放) 
5. T(traced or stopped)停止(进程收到SIGSTOP, SIGSTP, SIGTIN, SIGTOU信号后停止运行运行) 

# 四. 如何避免僵尸进程？

首先要明确子进程退出的标志：**子进程退出的时候会向其父进程发送一个`SIGCHLD`信号。**

常用处理方式如下：

1. 忽略SIGCHLD信号
2. 父进程调用wait/waitpid等函数阻塞等待子进程结束
3. signal注册信号处理函数，该函数再调用wait/waitpid处理
4. fork两次

在并发服务器上应用广泛，因为对于apache等通过`fork`子进程来处理请求的服务器，海量子进程退出后服务器进程（父进程）去`wait`清理资源,容易阻塞和占用系统资源。如果忽略此信号则由**init进程来处理僵尸进程**。

- [通过SIGCHILD信号来处理僵尸进程 deal_with_Zombie_process_with_SIGCHLD.c](https://github.com/BeginMan/BookNotes/blob/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition/source/demo/deal_with_Zombie_process_with_SIGCHLD.c)
- [两次fork处理僵尸进程 deal_with_Zombie_process_with_fork.c](https://github.com/BeginMan/BookNotes/blob/master/Unix/Unix-Network-Programming-Volume-1-The-Sockets-Networking-API-3rd-Edition/source/demo/deal_with_Zombie_process_with_fork.c)


# 五. wait()`和`waitpid()`怎么用？两者之间的区别？
在看《Unix网络编程卷1》时，感觉分析的没有这篇文章[**linux下的僵尸进程处理SIGCHLD信号**](http://www.cnblogs.com/wuchanming/p/4020463.html)好，这里就把人家的东西搬上来了。

## 5.1 wait()函数

	#include <sys/types.h> 
	#include <sys/wait.h>

	pid_t wait(int *status);

>进程一旦调用了wait，就立即阻塞自己，由wait自动分析是否当前进程的某个子进程已经退出，如果让它找到了这样一个已经变成僵尸的子进程，wait就会收集这个子进程的信息，并把它彻底销毁后返回；如果没有找到这样一个子进程，wait就会一直阻塞在这里，直到有一个出现为止。 

参数status用来保存被收集进程退出时的一些状态，它是一个指向int类型的指针。但如果我们对这个子进程是如何死掉的毫不在意，只想把这个僵尸进程消灭掉，（事实上绝大多数情况下，我们都会这样想），我们就可以设定这个参数为NULL，就象下面这样：

	pid = wait(NULL);

如果成功，wait会返回被收集的子进程的进程ID，如果调用进程没有子进程，调用就会失败，此时wait返回-1，同时errno被置为ECHILD。

- wait系统调用会使父进程暂停执行，直到它的一个子进程结束为止。
- 返回的是子进程的PID，它通常是结束的子进程
- 状态信息允许父进程判定子进程的退出状态，即从子进程的main函数返回的值或子进程中exit语句的退出码。
- 如果status不是一个空指针，状态信息将被写入它指向的位置

可以上述的一些宏判断子进程的退出情况：

![](http://images.cnitblog.com/blog/529981/201307/13113019-6a9fe47185da4a35a138df11ac942ae7.png)

## 5.2 waitpid()函数

	#include <sys/types.h> 
	#include <sys/wait.h>

	pid_t waitpid(pid_t pid, int *status, int options);


status:如果不是空，会把状态信息写到它指向的位置，与wait一样

options：允许改变waitpid的行为，最有用的一个选项是WNOHANG,它的作用是防止waitpid把调用者的执行挂起

返回值：如果成功返回等待子进程的ID，失败返回-1

对于waitpid的p i d参数的解释与其值有关：

- pid == -1 等待任一子进程。于是在这一功能方面waitpid与wait等效。
- pid > 0 等待其进程I D与p i d相等的子进程。
- pid == 0 等待其组I D等于调用进程的组I D的任一子进程。换句话说是与调用者进程同在一个组的进程。
- pid < -1 等待其组I D等于p i d的绝对值的任一子进程

## 5.3 wait与waitpid区别

- 在一个子进程终止前， wait 使其调用者阻塞，而waitpid 有一选择项，可使调用者不阻塞。
- waitpid并不等待第一个终止的子进程—它有若干个选择项，可以控制它所等待的特定进程。
- 实际上wait函数是waitpid函数的一个特例。`waitpid(-1, &status, 0);`

如以下代码会创建100个子进程，但是父进程并未等待它们结束，所以在父进程退出前会有100个僵尸进程。

	#include <stdio.h>  
	#include <unistd.h>  
	   
	int main() {  
	   
	  int i;  
	  pid_t pid;  
	   
	  for(i=0; i<100; i++) {  
	    pid = fork();  
	    if(pid == 0)  
	      break;  
	  }  
	   
	  if(pid>0) {  
	    printf("press Enter to exit...");  
	    getchar();  
	  }  
	   
	  return 0;  
	}


通过`ps -o pid,ppid,state,tty,command `可以发现有大量僵尸进程

方法1》wait处理：

	#include <stdio.h>  
	#include <unistd.h>  
	#include <signal.h>  
	#include <sys/types.h>  
	#include <sys/wait.h>  
	   
	void wait4children(int signo) {  
	   
	  int status;  
	  wait(&status);  
	   
	}  
	   
	int main() {  
	   
	  int i;  
	  pid_t pid;  
	   
	  signal(SIGCHLD, wait4children);  
	   
	  for(i=0; i<100; i++) {  
	    pid = fork();  
	    if(pid == 0)  
	      break;  
	  }  
	   
	  if(pid>0) {  
	    printf("press Enter to exit...");  
	    getchar();  
	  }  
	   
	  return 0;  
	}

但是通过运行程序发现还是会有僵尸进程，而且每次僵尸进程的数量都不定。这是为什么呢？其实主要是因为Linux的信号机制是不排队的，假如在某一时间段多个子进程退出后都会发出SIGCHLD信号，但父进程来不及一个一个地响应，所以最后父进程实际上只执行了一次信号处理函数。但执行一次信号处理函数只等待一个子进程退出，所以最后会有一些子进程依然是僵尸进程。

虽然这样但是有一点是明了的，就是收到SIGCHLD必然有子进程退出，而我们可以在信号处理函数里循环调用waitpid函数来等待所有的退出的子进程。至于为什么不用wait，主要原因是在wait在清理完所有僵尸进程后再次等待会阻塞。

方法2：waitpid处理，最佳方案

	#include <stdio.h>  
	#include <unistd.h>  
	#include <signal.h>  
	#include <errno.h>  
	#include <sys/types.h>  
	#include <sys/wait.h>  
	   
	void wait4children(int signo) {  
	  int status;  
	  while(waitpid(-1, &status, WNOHANG) > 0);  
	}  
	   
	int main() {  
	   
	  int i;  
	  pid_t pid;  
	   
	  signal(SIGCHLD, wait4children);  
	   
	  for(i=0; i<100; i++) {  
	    pid = fork();  
	    if(pid == 0)  
	      break;  
	  }  
	   
	  if(pid>0) {  
	    printf("press Enter to exit...");  
	    getchar();  
	  }  
	   
	  return 0;  
	}


这里使用waitpid而不是使用wait的原因在于：我们在一个循环内调用waitpid，以获取所有已终止子进程的状态。我们必须指定WNOHANG选项，它告诉waitpid在有尚未终止的子进程在运行时不要阻塞。我们不能在循环内调用wait，因为没有办法防止wait在正运行的子进程尚有未终止时阻塞。

参考：

[**孤儿进程与僵尸进程[总结]**](http://www.cnblogs.com/anker/p/3271773.html)

[**linux下的僵尸进程处理SIGCHLD信号**](http://www.cnblogs.com/wuchanming/p/4020463.html)

