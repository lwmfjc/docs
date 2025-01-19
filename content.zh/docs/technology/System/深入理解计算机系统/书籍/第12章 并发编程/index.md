第 12 章

C H A P T E R 12 . . . \_

并发编程

正如我们在第 8 章学到的 ， 如果逻辑控制流在时间上重叠， 那么它们就是并发的 ( concu rr e nt ) 。这种常见的现象称为并发 ( co nc urr e ncy ) , 出现在计算机系统的许多不同层面上。硬件 异常处理程序、进程和 L in ux 信号处理程序都是 大家很熟悉的例子。

到目前为止，我们主要将并发看做是一种操作系统内核用来运行多个应用程序的机 制。但是， 并发不仅仅局限 于内核。它也可以在应用程序中 扮演重要角色。例如，我 们已经看到 Linux 信号处理程序如何允许应用响应异步事件， 例如用户键入 C t rl + C , 或者程序访问虚拟内存的 一个未定义的区域。应用级并发在其他情况下 也是很有用的：

-   访问慢速 1/0 设备。当一个应用正在等待来自慢速 1/ 0 设备（例如磁盘）的数据到达时，内 核会运行其他进程，使 CP U 保持繁忙。每个应用都可以按照类似的方式， 通过交替 执行 I/ 0 请求和其他有用的工作来利用并发。
-   与人交互。和计算机交互的人要求计算机有同时执行多个任务的能力。例如，他们 在打印一个文档时， 可能想要调整一个窗口的大小。现代视窗系统利用并发来提供这种能力。每次用户请求某种操作（比如通过单击鼠标）时， 一个独立的并发逻辑流被创建来执行这个操作。
-   通过推迟工作以降低延迟。有时，应用程序能够通过推迟其他操作和并发地执行它 们， 利用并发来降低某些操作的延 迟。比如， 一个动态内存分配器可以通过推迟合并， 把它放到一个运行在较低优先级上的 并发“合并“ 流中， 在有空闲的 CP U 周期时充分利用这些空闲周期，从 而降低单个 fr e e 操作的延迟。
-   服务多个网 络客户端。 我们在第 11 章中学习的迭代网络服务器是不现实的， 因为它们一次只能为一个客户端提供服务。因此， 一个慢速的客户端可能会导致服务 器拒绝为所有其他客户端服务。对千一个真正的服务器来说，可能期望它每秒为成百上千的 客户端提供服务，由千一个慢速客户端导致拒绝为其他客户端服务，这是不能接受 的。一个更好的方法是创建一个并发服务器，它为每个客户端创建一个单独的逻辑 流。这就允许服务器同时为多个客户端服务 ， 并且也避免了慢速客户端独占 服务器。
-   在多核机器上进行并行计算。许多现代系统都配备多核处理器，多核处理器中包含 有多个 CP U。被划分成并发流的应用程序通常在多 核机器上比 在单处理器机器上运行得快， 因为这些流会并行执行， 而不是交错执行。

    使用应用级并 发的应用程序称为并发程序 ( co nc ur re nt pro g ra m ) 。现代操作系统提供了三种基本的构造并发程序的方法：

-   进程。用这种方法 ，每 个逻辑控制流都是一个进程， 由内核来调度和维护。因为进程有独立的虚拟地址空间，想要和其他流通信，控制流必须使用某种显式的进程间通信( in te r proces s communication, IPC) 机制。
-   I/ 0 多路 复用。 在这种形式的并发编程中 ， 应用程序在一个进程的上下文中显式地调度它们自己的逻辑流。逻辑流被模型化为状态机，数据到达文件描述符后，主程 序显式地从一个状态转换到另一个状态。因为程序是一个单独的进程， 所以所有的流都共享同一个地址空间。
-   线程。线程是运行在一个单一进程上下文中的逻辑流，由内核进行调度。你可以把 线程看成是其他两种方式的混合体， 像进程流一样由内核进行调度，而 像 1/0 多路复用流一样共享同一个虚拟地址空间。

    本章研究这兰种不同的并发编程技术。为了使我们的讨论比较具体，我们始终以同一个应用为例一 11. 4. 9 节中的迭代 echo 服务器的并 发版本。

### 12. 1 基千进程的并发编程

构造并发程序 最简单的方法就是用进程，使 用 那些大家都很熟悉的函数， 像 f o r k、 e xe c 和 wa i t p 过 。 例如， 一个构造并发服务器的自然方法就是， 在父进程中接受 客户端连接请求，然后创建一个新的子进程来为每个新客户端提供服务。

![](img/9170308c487c408d13c9c46ae317f052.jpeg)为了了解这是如何工作的，假设我们有两个客户端和一个服务器，服务器正在监听一 个监听描述符（比如指述符 3) 上的连接请求 。现在假设服务器接受了客户端 1 的连接请求， 并返回一个已连接描述符（比如指述符 4 ) , 如图 12-1 所示。在接受 连接请求之后，服务器派生一个子进程，这个子进程获得服务器描述符表的完整副本。子进程关闭它的副本中的 监听描述符 3' 而父进程关闭 它的已连接描述符 4 的副本， 因为不再需要这些描述符了。这就得到了图 12- 2 中的状态， 其中子进程正 忙于为客户端提供服务。

三一＿一、一＿、归接请求

c l i e n t f d

三

clientfd

\--、-- listenfd(3) connfd(4)

clientfd

三cl i en 七 f d

listenfd(3)

图 1 2-1 第一步：服务器接受客户端的连接请求 图 12- 2 第二步：服务器派生一个子进程为这个客户端服务

因为父、子进程中的已连接描述符都指向同一个文件表表项，所以父进程关闭它的已连接描述符的副本是至关重要的。否则 ， 将永不会释放巳连接描述符 4 的文件表条目 ，而且由此引起的内存泄涌将最终消耗光可用的内存，使系统崩溃。

现在， 假设在父进程为客户端 1 创建了子进程之后，它 接受一个新的客 户端 2 的连接请求， 并返回一个新的已连接描述符（比如描述符 5) , 如图 12-3 所示。然后，父进程 又派生另一个子进程， 这个子进程用已连接描述符 5 为它的客户端提供服务， 如图 12-4 所示。此时， 父进程正在等待下一个连接请求，而两个子进程正在并发地为它们各自的客户端提供服务。

![](img/02bf1a7b6a129ba2a14f87d07c45db69.jpeg)![](img/8d9f6ad9c2fdeab53cf54bf088e69ec1.jpeg)clientfd listenfd(3)

clientfd

listenfd(3)

, ' connfd(5)

![](img/789e9bd6017ef030322d7092ad261d55.jpeg)巨

图12-3 第三步：服务器接受另一个连接请求 图 12-4 第四步：服务器派生另一个子进程为新的客户端服务

1.  1\. 1 基于进程的并发服务器

    图12-5 展示了一个基千进程 的并发 ech o 服务器的代码。第 29 行调用的 e c h o 函数来自于图 1 1- 21。关于这个服务器 ， 有几点重要内容需要说明：

    -   首先， 通常服务器会运行很长的时间， 所以我们必须 要包括一个 S IG C H L D 处理程序， 来回收僵死( zo m bie ) 子进程的 资 源（第4 9 行）。因为当 S IG C H L D 处理程序执行时， S IG C H LD 信号 是阻塞的， 而 L in u x 信号是不排队的， 所以 SIGC H LD 处理程序必须准备好回收多个僵死子进程的资源。
-   其次， 父子进程必须关闭 它们各自的 c o n n f d ( 分别为第 33 行和第 30 行）副本。就像我们已经提到过的，这对父进程而言尤为重要，它必须关闭它的已连接描述符， 以避免内存泄漏。
-   最后， 因为套接字的文件表表项中的引用计数， 直到父子进程的 c o n n f d 都关闭了， 到客户端的连接才会终止。

code/condechoserverp.c

1.  \#include "csapp.h"
2.  void echo(int connfd);

    3

    4 void sigchld_handler(int sig)

    5 {

    6 while (waitpid(-1, 0, WNOHANG) \> 0)

    7

    8 return;

    9 }

    10

    11 int main(int argc, char \*\*argv)

    12 {

    13 int listenfd, connfd;

    14 socklen_t clientlen;

3.  struct sockaddr_storage clientaddr;

    16

4.  7 if (argc != 2) {
5.  fprintf(stderr, "usage: %s \<port\>\\n", argv[O]);
6.  exit (0);

    20 }

    21

7.  Signal(SIGCHLD, sigchld_handler);
8.  listenfd = Open_listenfd (argv [1]) ;

    24 while (1) {

9.  clientlen = sizeof(struct sockaddr_storage);
10. connfd = Accept (listenfd, (SA \*) \&clientaddr, \&clientlen) ;

    27 if (Fork() == 0) {

28

29

30

31

32 }

Close(listenfd) ; echo(connfd); Close(connfd); exit(O);

I\* Child closes its listening socket \*I I\* Child services client \*I

I\* Child closes connection with client \*I I\* Child exits \*I

33 Close(connfd); I\* Parent closes connected socket (important!) \*I

34 }

35 }

code/condechoserverp.c

图 12-5 基于进程的并发 echo 服务器 。父进程 派生一个 子进程来 处理每个新的 连接请求

12 . 1. 2 进程的优劣

对于在父、子进程间共享状态信息，进程有一个非常清晰的模型：共享文件表，但是不共享用户地址空间。进程有独立的地址空间既是优点也是缺点。这样一来， 一个进程不可能不小心覆盖另一个进程的虚拟内存，这就消除了许多令人迷惑的错误—— 这是一个明显的优点。

另一方面，独立的地址空间使得进程共享状态信息变得更加困难。为了共享信息，它 们必须使用显式的 IPC C进程间通信）机制。（参见下面的 旁注。）基于进程的设计的另一个缺点是， 它们往往比较慢， 因为进程控制 和 IPC 的开销很高。

日日Unix IPC

在本 书中 ， 你已经遇到 好几个 IPC 的例子了。 笫 8 章中的 wa i t p i d 函数和信号是基本的 IPC 机制， 它们 允许进程发 送小消息 到 同一主机 上的 其他进程。笫 11 章的套接宇接口是 IPC 的一种重要 形式， 它允许 不同主机 上的进程交换任 意的 字 节流。 然而，术语 U n ix IPC 通常指的是所有 允许进程和 同一台主机上其他 进程进行 通信的 技术。其中包括管道、先进先出( FIF O) 、 系统 V 共享内存， 以及 系统 V 信号量( s e m a p h o r e ) 。这些机 制超 出了我 们的讨论范围。 K e r r is k 的著作[ 62] 是很 好的参考资料。

凶 练习题 12. 1 在图 1 2-5 中， 并发 服 务器的 第 33 行上， 父 进 程 关 闭 了 巳连 接 描述符后， 子进 程仍 然能够使 用该 描述 符和 客户端 通信。 为 什么？

练习题 12. 2 如果 我们 要 删除 图 1 2-5 中关 闭 巳连 接描述 符的 第 30 行，从 没有内存泄漏的角度来说，代码将仍然是正确的。为什么？

1.  2 基千 1/ 0 多路复用的并发编程

    假设要求你编写一个 e ch o 服务器，它 也 能对用户从标准输入键入的交互命令做出响应。在这种情况下 ， 服务器必须响应 两个互相独立的 I/ 0 事件： 1) 网络客户端发 起连接请求， 2 ) 用 户在键盘上 键人命令行。我们先 等待哪个事件呢？ 没有哪个选择是理想的。如果在 a c c e p t 中等待一个连接请求， 我们就不能响应输入的命令。类似地， 如果在r e a d 中等待一个输入命令，我们就不能响应任何连接请求。

    针对这种困 境的一个解决 办法就是 1/ 0 多路复用 CI/ 0 m u lt ip le x in g ) 技术。基本的思路就 是使用 s e l e c t 函数， 要求内核挂起进程，只 有在一个或多个 I/ 0 事件发生后，才将控制返回给应用程序，就像在下面的示例中一样：

    -   当集合{O, 4}中任意描述符准备好读时返回。
        -   当集合 { 1, 2 , 7}中任意描述符准备好写时返回。
        -   如果在等待一个 I/ 0 事件发生时过了 152. 13 秒， 就超时。

            s e l e c 七是一个复杂的 函数， 有许多不同的使用场景。我们将只讨论第一种场景： 等待一组描述符准备好读。全面的讨论请参考[ 62, 110] 。

\#include \<sys/select.h\>

int select(int n, fd_set \*fdset, NULL, NULL, NULL);

返回已准备 好的描述符的 非零的个数 ， 若出错 则 为一 1。

FD_ZERO(fd_set \*fdset); FD_CLR(int fd, fd_set \*fdset); FD_SET(int fd, fd_set \*fdset); FD_ISSET(int fd, fd_set \*fdset);

I\* Clear all bits in fdset \*I I\* Clear bit fd in fdset \*I I\* Turn on bit fd in fdset \*I

/\* Is bit fd in fdset on? \*I

处理 描述符 集合的 宏。

s e l e c t 函数处理类型为 f d \_s e t 的集合，也 叫做描述符集合 。逻辑上， 我们将描述符集合看成一个大小为 n 的位向量（在2. 1 节中介绍过）：

b,,_1 , ... , b1 , b。

每个位 从对应于描述符 k 。当且仅当从 = l , 描述符 k 才表明是 描述符集合的一个元素。只允许你对描述符集合做三件事： 1 ) 分配它们， 2 ) 将一个此种类型的变量赋值给另一个变量， 3 ) 用 F D\_ ZERO、F D_S ET 、FD_CLR 和 F D_ISS ET 宏来修改 和检查它们。

针对我们的 目的， s e l e c t 函数有两个输入： 一个称为读 集合 的描述符集合( f d s e t ) 和该读集合的基数( n ) ( 实际上是任何描述符集合的最大基数）。s e l e c t 函数会一直阻塞， 直到读集合中至少有一个 描述符准备好可以读 。当且仅当一个从该描述符读取一个字节的请求不会阻塞时， 描述符 k 就表示准备 好可以 读了。s e l e c t 有一个副作用， 它修改参数f d s e t 指向的 f d \_ s e t , 指明读集合的一个子集，称 为准备 好集合 ( read y set) , 这个集合是由读集合中准备好可以 读了的描述符组成的。该函数返回的值指明了准备好集合的基 数。注意， 由于这个副作用， 我们必 须在每次调用 s e l e c t 时都更新读集合。

理解 s e l e c t 的最好办法是研究一个具体例子。图 12-6 展示了可以如何利用 s e l e c t 来实现一个迭代 echo 服务器， 它也可以接受标准输入上的用户命令。一开始， 我们用图 11-1 9 中的 op e n_止 s t e n f d 函数打开一个监听描述符（第1 6 行）， 然后使用 F D\_ ZE RO 创建一个空的读集合（第18 行）：

listenfd

3 2

read_set (0) : 曰

stdin

1 0

二

接下来， 在第 19 和 20 行中， 我们定义由描述符 0 ( 标准输入）和描述符 3 ( 监听描述符）组成的读集合：

listenfd stdin

3 2 1 0

read_set ({O, 3)) : I 1 I 1 I 1 I

在这里， 我们开始典 型的服务器循环 。但是我们不调用 a c c e p七函数来等待一个连接请求，而 是调用 s e l e 吐 函数， 这个函数会一直阻塞， 直到监听描述符或者标准输入准备好可以读（第24 行）。例如，下 面是 当用户按回车键， 因此使得标准输入描述符变为可读时， s e l e c t 会返回的r e a d y\_ s 包 的值：

listenfd stdin

3 2 1 0

ready_set ({O}): I 1 1 I 1 I

一旦 s e l e c t 返回， 我们就用 F D \_ ISSET 宏指令来确定哪个描述符 准备好可以读了。如果是标准输入准备好了（第25 行）， 我们就调用 c omma nd 函数，该 函数在返回到主程序前， 会读、解析和响应命令。如果是监听描述符准备好了（第27 行）， 我们就调用 a c c e p t 来得到一个已 连接描述符 ， 然后调用图 11-22 中的 e c ho 函数， 它会将来自客户端的每一行又回送回去， 直到客户端关闭 这个连接中它的那一端。

虽然这个程序是使用 s e l e c t 的一个很好示例，但 是它仍然留下了一些问题待解决。问题是一旦它连接到某个客户端，就会连续回送输入行，直到客户端关闭这个连接中它的那一 端。因此，如果键入一个命令到标准输人，你将不会得到响应，直到服务器和客户端之间结

束。一个更好的方法是更细粒度的多路复用，服务器每次循环（至多）回送一个文本行。

code/co nd se lect. c

\#include "csapp.h"

1.  void echo(int connfd);
2.  void command(void);

    4

    5 int main(int argc, char \*\*argv)

    6 {

3.  int listenfd, connfd;
4.  socklen_t clientlen;
5.  struct sockaddr_storage clientaddr;
6.  fd_set read_set, ready_set;

    11

7.  if (argc != 2) {
8.  fprintf(stderr, "usage: %s \<port\>\\n", argv[O));
9.  exit(O);

    15 }

    16 listenfd = Open_listenfd(argv[1]); 17

10. FD_ZERO(&read_set); I\* Clear read set \*I
11. FD_SET(STDIN_FILENO, \&read_set); I\* Add stdin to read set \*I
12. FD_SET(listenfd, \&read_set); I\* Add listenfd to read set \*I 21
13. while (1) {
14. ready_set = read_set;
15. Select(listenfd+1, \&ready_set, NULL, NULL, NULL);
16. if (FD_ISSET(STDIN_FILENO, \&ready_set))
17. command(); I\* Read command line from stdin \*I
18. if (FD_ISSET(listenfd, \&ready_set)) {

28

29

30

31

32

33 }

34 }

35

clientlen = sizeof(struct sockaddr_storage);

connfd = Accept(listenfd, (SA \*)&clientaddr, \&clientlen); echo(connfd); I\* Echo client input until EDF \*I Close(connfd);

1.  void command(void) {
2.  char buf[MAXLINE];
3.  if (! Fgets (buf , MAXLINE, st din))
4.  exit(O); I\* EOF \*I
5.  printf("%s", buf); I\* Process the input command \*I 41 }

codelcondselect.c

图 12-6 使用 1/ 0 多路复用的 迭代 echo 服务器。服务器使用 s e l e c t

等待监听描述符上的连接请求和标准输人上的命令

沁目 练习题 12. 3 在 L i n u x 系统 里，在标 准输入 上键入 C t rl + D 表 示 EOF 。 图 12-6 中的程序阻塞在 对 s e l e c t 的调 用上 时，如果 你键 入 C t rl + D 会发 生什 么？

12\. 2. 1 基千 1/ 0 多 路 复用的并发事件驱动服务器

I / 0 多路复用可以用做并发事件 驱动( e ve n t- d r ive n ) 程序的基础， 在事件驱动程序中， 某些事件会导致流向前推进。一般的思路是将逻辑流模型化为状态机。不严格地说，一个

![](img/3e5d2873e9e2555edbdaa046e638c91e.jpeg)状态机 ( s t a t e m a c h in e ) 就是一组状 态 ( s t a t e ) 、输 入事件 ( in p u t e ve n t ) 和转移 ( t ra n s it io n ) , 其中转移是将状态和输入事件映射到状态。每个转移是将一 个（输入状态， 输入事件）对映射到一个输出状态。自循环 ( s e lf - lo o p ) 是同一输入和输出状态之间的转移。通常把状态机画成有向图，其中节点表示状态，有向弧表示转移，而弧上的标号表示输入事件。一个状 态机从某种初始状态开始执行。每个输入事件都会引发一个从当前状态到下一状态的 转移。

对于每个新的 客户端 k , 基于 1/ 0 多路复用的 并发服务器会创建一个新的状态机

Sk' 并将它和巳连接描述符d k 联系起来。如图 12-7 所示， 每个状态机 Sk 都有一个状态( "等待描述符 d k 准备好可读")、一 个输入事件（＂描述符 d k 准备好 可以读了")和一个转移

（“从描述符 d k 读一个文本行")。 图 12- 7 并发事件驱动echo 服务器中逻辑流的状态机

服务器使用 1/ 0 多路复用 ， 借助 s e l e c t 函数检测输入事件的发生。当每个已连接描述符准备好可读时，服务器就为相应的状态机执行转移，在这里就是从描述符读和写回一 个文本行。

图 1 2-8 展示了一个基于 1/ 0 多路复用的并发事件驱动服务器的完整示 例代码。一个

p o o l 结构里维护着活动客户端的集合（第3 11 行）。在调用 i n i t \_ p o o l 初始化 池（第27 行）之后， 服务器进入一个无限循环。在 循环的 每次 迭代中， 服务器调用 s e l e c t 函数来检测两种不同类型的输入事件： a ) 来自一个新客户端的连接请 求到达， b ) 一个已存在的客户端的已连接描述符准 备好可以 读了。当一个连接请求到达时（第35 行）， 服务器打开连接（第37 行）， 并调用 a d d \_ c l i e n t 函数， 将该客户端添加到池里（第38 行）。最后， 服务器调用 c h e c k\_ c l i e n t s 函数， 把来自每个 准备好的已连接描述符 的一个文本行回送回去

（第 42 行）。

code/condechoservers.c

1 \#include "csapp.h"

1.  typedef struct { /• Represents a pool of connected descriptors•/
2.  int maxfd; I• Largest descriptor in read_set•I
3.  fd_set read_set; I• Set of all active descriptors•I
4.  fd_set ready_set; I• Subset of descriptors ready for reading•/
5.  int nready; /• Number of ready descriptors from select•I
6.  int maxi; /• High water index into client array•/
7.  int clientfd [FD_SETSIZE) ; /• Set of active descriptors•/
8.  rio_t clientrio[FD_SETSIZE); I\* Set of active read buffers•/
9.  } pool;

    12

    13 int byte_cnt = 0; I\* Counts total bytes received by server•/

    14

    15 int main(int argc, char \*\*argv)

    16 {

10. int listenfd, connfd;
11. socklen_t clientlen;
12. struct sockaddr_storage clientaddr;

图12-8 基 于 I/ 0 多路复用的并发 echo 服务器。每次服务器迭代都回送来自每个准备好的描述符的文本行

4.  static pool pool; 21
5.  if (argc != 2) {
6.  fprintf(stderr, "usage: %s \<port\>\\n", argv[O]);
7.  exit(O);

    25 ｝

8.  listenfd = Open_listenfd(argv[1]);
9.  init_pool(listenfd, \&pool); 28
10. while (1) {
11. I\* Wait for listening/connected descriptor(s) to become ready \*I
12. poolr. eady_s et = pool.read_set;

32

33

34

35

36

37

38

39

40

41

42

43

44 ｝

pool.nready = Select(pool.maxfd+l, \&pool.ready_set, NULL, NULL, NULL);

I\* If 让 s t eni ng descriptor ready, add new client to pool \*I if (FD_ISSET (listenfd, \&pool. ready_set)) {

clientlen = sizeof(struct sockaddr_storage);

connfd = Accept(listenfd, (SA \*)&clientaddr, \&clientlen); add_client(connfd, \&pool);

｝

I\* Echo a text line from each ready connected descriptor \*I check_clients(&pool);

codelcondechoservers.c

图 12-8 ( 续 ）

i n it \_p o o l 函数（图1 2- 9 ) 初始化客户端池。 c l i e n t f d 数组表示已连接描述符的集合， 其中整数—1 表示一个可用的 槽位。初始时，已 连接描述符集合是空的（第5 \~ 7 行），而且监听描 述符是 s e l e c t 读集合中唯 一的描述符（第1 0 \~ 1 2 行）。

cod e/cond echoservers .c

void init_pool(int listenfd, pool \*p)

3 I\* Initially, there are no connected descriptors \*I inti;

p-\>maxi = -1;

6 for (i=O; i\< FD_SETSIZE; i++)

p-\>clientfd[i] = -1;

8

1.  I\* Initially, listenfd is only member of select read set \*I
2.  p-\>maxfd = listenfd;
3.  FD_ZERO(&p-\>read_set);
4.  FD_SET(listenfd, \&p-\>read_set);

    13 }

code/co nd echoservers .c

图 12-9 init pool 初 始 化 活动客户端池

a d d \_ c li e n t 函数（图1 2- 1 0 ) 添加一个新的客户端到活动客户端池中。在 c li e n tf d 数组中找到一个空槽位后，服务器将这个巳连接描述符添加到数组中，并初始化相应的 R I O 读缓冲区 ， 这样一 来我们就能够对这个描述符调用r i o \_ r e a d l i n e b ( 第 8 \~ 9 行）。然

后， 我们将 这个已连接描述符添加到 s e l e c t 读集合（第12 行）， 并更新该池的一些全局属性。ma x f d 变量（第15 16 行）记录了 s e l e 立 的最大文件描述符。ma x i 变量（第17 18 行）记录的是 到 c l i e n t f d 数组的最大索引， 这样 c h e c k\_ c l i e n t s 函数就无需搜索整个数组了。

code/condechoservers.c

1 void add_client(int connfd, pool \*p)

2 {

3 inti;

4 p-\>nready--;

s for (i = O; i \< FD_SETSIZE; i++) I\* Find an available slot \*I

6 if (p-\>clientfd[i] \< 0) {

7 I\* Add connected descriptor to the pool \*I

8 p-\>clientfd[i] = connfd;

9 Rio_readinitb(&p-\>clientrio[i], connfd);

10

11 I\* Add the descriptor to descriptor set \*I

12 FD_SET(connfd, \&p-\>read_set);

13

1.  I\* Update max descriptor and pool high water mark \*I
2.  if (connfd \> p-\>maxfd)
3.  p-\>maxfd = connfd;
4.  if (i \> p-\>maxi)
5.  p-\>maxi = i;
6.  break;

    20 }

7.  if (i == FD_SETSIZE) / \* Couldn't find an empty slot \*I
8.  app_error("add_client error: Toomany clients");

    23 }

    code/condechoservers.c

图 1 2-10 add_c l i e nt 向池中添加一个新的客户端连接

图 12-11 中的 c he c k\_ c l i e n t s 函数回送来自每个 准备好的已连接描述符的一个文本行。如果成功地从描述符读取了一个文本行， 那么就将该文本行回送到客户端（第15 18 行）。注意，在 第 15 行我们维护着一个从所有客户端接收到的 全部字节的 累计值。如果因为客户端关闭这个连接中它的那一端， 检测到 EOF , 那么将关闭这边的连接端（第23 行）， 并 从池中清除掉这个描述符（第24 25 行）。

根据图 1 2- 7 中的有限状态模型， s e l e c t 函数检测到输入事件， 而 a d d \_ c l i e 吐 函数创建一个新 的逻辑流（状态机）。c h e c k \_ c l i e n t s 函数回送输入行，从 而执行状态转移， 而且当客户端完成文本行发送时，它还要删除这个状态机。

沁囡 练习题 12 . 4 图 1 2-8 所 示的 服 务器中， 我们 在每次调 用 s e l e 立 之前都 立 即小心地重新初 始化 p o o l .r e a d y\_ s e t 变量。 为什 么？

豆 日 事件驱 动的 We b 服务器

尽管有 12. 2. 2 节中说 明的缺点， 现代高性能服务器（ 例如 N od e. js 、ng in x 和 T or­ na do ) 使用的都是 基于 1/ 0 多路 复用的 事件 驱动的 编程 方式 ， 主要是因为相 比于进程和线程的 方式 ， 它有明 显的性能优势。

code/condechoservers. c

void check_clients(pool \*p)

2 {

3 inti, connfd, n;

4 char buf[MAXLINE];

5 rio_t rio;

6

7 for (i = O; (i \<= p-\>maxi) && (p-\>nready \> 0); i++) {

8 connfd = p-\>clientfd [i] ;

9 rio = p-\>clientrio[i];

10

11 /\* If the descriptor is ready, echo a text line from it \*I

12 if ((connfd \> 0) && (FD_ISSET(connfd, \&p-\>ready_set))) {

13 p-\>nready--;

1.  if ((n = Rio_readlineb (&rio, buf, MAXLINE)) ! = 0) {
2.  byte_cnt += n;
3.  printf("Server received %d (%d total) bytes on fd %d\\n",
4.  n, byte_cnt, connfd);

    18 Rio_writen(connfd, buf, n);

    19 ｝

    20

    21 I\* EDF detected, remove descriptor from pool \*I

    22 else {

5.  Close(connfd);
6.  FD_CLR(connfd, \&p-\>read_set);
7.  p-\>clientfd [i] = -1;

    26 }

    27 }

    28 }

    29 }

code/condechoservers.c

图 12-11 check cl i ent s 服务准备好的 客户 端连接

12\. 2. 2 1/ 0 多 路 复用技术的优劣

图 12-8 中的服务器提供了一个 很好的基于 I/ 0 多路复用的事件驱动编程的优缺点示例。事件驱动设计的一个优点是，它比基千进程的设计给了程序员更多的对程序行为的控制。例如，我们可以设想编写一个事件驱动的并发服务器，为某些客户端提供它们需要的服务，而这对于基于进程的并发服务器来说，是很困难的。

另一个优点是， 一个基千 I/ 0 多路复用的事件驱动服务器是运行在单一进程上下文中的，因此每个逻辑流都能访问该进程的全部地址空间。这使得在流之间共享数据变得很容 易。一个与作为单 个进程运行相关的优点是， 你可以利用熟悉的调试工具， 例如 GDB, 来调试你的并发服务器，就像对顺序程序那样。最后，事件驱动设计常常比基于进程的设 计要高效得多，因为它们不需要进程上下文切换来调度新的流。

事件驱动设计一个明显的 缺点就是编码复杂。我们的事件驱动的并 发 echo 服务器需要的代码比基于进程的服务器多三倍，并且很不幸，随着并发粒度的减小，复杂性还会上升。这 里的粒度是指每个逻辑流每个时间片执行的指令数量。例如，在示例并发服务器中，并发粒 度就是读一个完整的文本行所需要的指令数 量。只要某个逻辑流正忙于读一个文本行， 其他逻辑流就不可能有进展 。对我们的例子来说这没有问题， 但是它使得在“故意只发送部分文

本行然后就停止＂的恶意客户端的攻击面前，我们的事件驱动服务器显得很脆弱。修改事件 驱动服务器来处理部分文本行不是一个简单的任务，但是基千进程的设计却能处理得很好， 而且是自动处理的。基于事件的设计另一个重要的缺点是它们不能充分利用多核处理器。

12\. 3 基于线程的并发编程

到目前为止，我们已经看到了两种创建并发逻辑流的方法。在第一种方法中，我们为 每个流使用了单独的进程。内核会自动调度每个进程，而每个进程有它自己的私有地址空 间，这 使得流共享数据很困难。在第二种方法中， 我们 创建自己的逻辑流， 并利用 I/ 0 多路复用来显式地调度流。因为只有一个进程，所有的流共享整个地址空间。本节介绍第三 种方法 基千线程，它是这两种方法的混合。

线程 ( t hread ) 就是运行在进程上下 文中的逻辑流。在本书里迄今为止， 程序都是由每个进程中一个线程组成的。但是现代系统也允许我们编写一个进程里同时运行多个线程的程序。线 程由内核自动调度。每个线程都有它自己的 线程上 下文( t h read context), 包括一个唯一的整数线程 ID ( T hread ID, T ID) 、栈、栈指针、程序 计数器、通用目的寄存器和条件码。所有的运行在一个进程里的线程共享该进程的整个虚拟地址空间。

基千线程的逻辑流结合 了基于进程 和基于 I/ 0 多路复用的流的特性。同进程一样， 线程由内核 自动调度 ，并且内核通过一个 整数 ID 来识别线程。同 基于 I/ 0 多路复用的流一样，多个线程运行在单一进程的上下文中，因此共享这个进程虚拟地址空间的所有内容， 包括它的代码、数据、堆、共享库和打开的文件。

12\. 3. 1 线程执行模型

多线程的执行模型在某些方面和多进程的执行模型是相似的。思考图 12-12 中的示例。每个进程开始生命周期时都是单一线程， 这个线程称为主线程 ( main t hread ) 。在某一时刻，主线程创建一个对等线程(peer thread) , 从这个时间点开始，两个线程就并发地运行。最后，因为主线程执行一个 慢 速 系 统 调 用， 例 如 r e a d 或 者

sleep, 或者因为被系统的间隔计时器中断，控制就会通过上下文切换传递到对等

时间

线程1 线程2

（对等线程）

－－－－－－－－－－－－－－－－－－－－－－－－－－－

…- - ------- -- ----r-------- }线程上下文切换

:：：:：：：一二：二勹｝线程上下文切换二：：三二：：｝线程上下文切换

图12-12 并发线程执行

线程。对等线程会执行一段时间，然后控制传递回主线程，依次类推。

在一些重要的方面，线程执行是不同于进程的。因为一个线程的上下文要比一个进程的上下文小得多，线程的上下文切换要比进程的上下文切换快得多。另一个不同就是线程不像进程那样，不是按照严格的父子层次来组织的。和一个进程相关的线程组成一个对等

（线程）池，独立于其他线程创建的线程。主线程和其他线程的区别仅在于它总是进程中第 一个运行的线程。对等（线程）池概念的主要影响是，一个线程可以杀死它的任何对等线程，或者等待它的任意对等线程终止。另外，每个对等线程都能读写相同的共享数据。

1.  3 . 2 Pos ix 线程

    Posix 线程( P t hreads ) 是在 C 程序中处理线程的一个标准接口。它最早出现在 1995

年， 而且在所有的 L in u x 系统上都 可用。P t h r ea d s 定义了大约 60 个函数，允 许程序创建、杀死和回收线程，与对等线程安全地共享数据，还可以通知对等线程系统状态的变化。

图 12-13 展示了一个简单的 P t h rea ds 程序。主线程创建一个 对等线程， 然后等待它的终止。对等线程输出 " He l l o , world! \\ n" 并且终止。当主线 程检测到对等线 程终止后， 它就通过调用 e x i t 终止该进程。这是我们看到的第一个线程化的程序， 所以让我们仔细地解析它。线程的代码和本地数据被封装在一个线程例 程( t h r ead ro u t in e) 中。正如第二行里的原型所示，每个线程例程都以一个通用指针作为输入，并返回一个通用指针。如果想 传递多个参数给线程例程，那么你应该将参数放到一个结构中，并传递一个指向该结构的 指针。相似地，如果想要线程例程返回多个参数，你可以返回一个指向一个结构的指针。

code/cone/hello.c

\#include "csapp.h"

2 void \*thread(void \*vargp);

3

4 int main()

5 {

6 pthread_t tid;

7 Pthread_create(&tid, NULL, thread, NULL);

8 Pthread_join(tid, NULL);

9 exit(O);

10 }

11

12 void \*thread(void \*vargp) I\* Thread routine \*I

13 {

14 printf("Hello, world!\\n");

15 return NULL;

16 }

codelcondhello.c

图 1 2- 1 3 hello.c: 使用 Pthreads 的 " Hello , world!" 程序

第 4 行标出了主线程代码的 开始。主线程声明了一个本地变僵 t 过， 可以用来存放对等线程的 ID( 第 6 行）。主线程通过调用 p t hr e a d \_ cr e a 七e 函数创建一个新的对等线程（第

7 行）。当对 p t hr e a d \_ c r e a t e 的调用返回时， 主线程和新创建的对等线程同时运行， 并且 t i d 包含新线程的 ID。通过在第 8 行调用 p t hr e a d \_ j o i n , 主线程等待对等线程终止。最后， 主线程调用 e x 江（第9 行）， 终止当时运行在这个 进程中的所有线程（在这个示例中就只有主线程）。

第 12 \~ 1 6 行定义了对等线程的 例程。它只 打印一个字符串， 然后就通过执行第 15 行中的r e 七ur n 语句来终止对等线程 。

12\. 3. 3 创建线程

线程通过调用 p t hr e a d \_cr e a 七e 函数来创建其他线程。

\#include \<pthread.h\>

typedef void \*(func) (void \*);

int pthread_create(pthread_t \*tid, pthread_attr_t \*attr,

func \*f, void \*arg);

若成功则返回 o, 若出错 则 为 非零。

p t hr e a d\_ cr e a t e 函数创建一个新的线程， 并带着一个输入变量 ar g , 在新线程的上下文中运行线程例 程 f 。能用 a t 七r 参 数来改变新创建线程的 默认属性 。改变这些属性已超出我们 学习的范围， 在我们的示 例中，总 是用一个为 N U L L 的 a t tr 参数来调用p t h r e a d\_ cr e a 七e 函数。

当 p t h r e a d \_ cr e a t e 返回时 ， 参数 t i d 包含新创建线程的 ID 。新线程可以通过调用

p t hr e a d\_ s e l f 函数来获得它自己的线 程 ID。

\#include \<pthread.h\>

pthread_t pthread_self(void);

返回调用 者的 线 程 ID .

1.  3\. 4 终止线程

    一个线程是以下列方式之一来终止的：

    -   当顶层的线程例程返回时 ， 线程会隐式地终 止。
        -   通过调用 p 七hr e a d \_ e x i t 函数， 线程会显 式地终 止。如果主线程调用 p t hr e a d \_e x ­

            l 七，它 会等待所有其他对等线程终止，然 后再终止主线程和整个进程， 返回值为

            thread r et urn。

\#include \<pthread.h\>

void pthread_exit(void \*thread_return);

从不返回。

-   某个对等线程调用 Lin ux 的 e x i t 函数，该 函数终止进程以 及所有与该进程相关的线程。
    -   另一个对等线程 通过以 当前线程 ID 作为参数调用 p t h r e a d \_ c a n c e l 函数来终止当前线程。

\#include \<pthread.h\>

int pthread_cancel(pthread_t tid);

若成功则返回o , 若 出错 则 为 非零。

12\. 3. 5 回收己终止线程的资源

线程通过 调用 p 七hr e a d \_ j o i n 函数等待其他线程终止。

\#include \<pthread.h\>

int pthread_join(pthread_t tid, void \*\*thread_return);

若成功则返 回 o, 若出错则为非零。

p t hr e a d\_ j o i n 函数会阻塞， 直到线程 t i d 终止， 将线程例程返回的通用( v o i d \* ) 指针赋值为 t h r e a d \_r e t ur n 指向的位置， 然后回收己终 止线程占用的所有内存资源。

注意 ， 和 L in u x 的 wa i t 函数不同， p t hr e a d \_ j o i n 函数只能等待一个指定的线程终止。没有办法让 p t hr e a d \_ wa i t 等待任意一个线程终 止。这使得代码更加复杂， 因为它 迫

使我们去使用其他一些不那么直观的机制来检测进程的 终止。实际上， S t eve ns 在[ ll O] 中就很有说服力地论证了这是规范中的一个错误。

12\. 3. 6 分离线程

在任何一个时间点上， 线程是可结合的 ( joina ble ) 或者是 分离的( detached ) 。一个可结合的线程能够被其他线程收回和杀死。在被其他线程回收之前 ， 它的内存资源（例如栈）是不释放的。相反，一个分离的线程是不能被其他线程回收或杀死的。它的内存资源在它终 止时由系统自动释放。

默认情况下 ，线 程被创建成可结合的。为了避免内存泄漏， 每个可结合线程都应该要

么被其 他线程显式 地收回， 要么通过调用 p t h r e a d_d e t a c h 函数被分离。

\#include \<pthread.h\>

int pthread_detach(pthread_t tid);

若成功则返回 0 , 若 出错 则 为 非零。

p t hr e a d_d e t a c h 函数分离可结合线程 t 过。线程能够通过以 p t hr e a d\_ s e l f ()为参数的 p t hr e a d \_de t a c h 调用来分离它们自己。

尽管我们的一些例子会使用 可结合 线程，但 是在现实程序中，有 很好的理由要使用分

离的线程。例如， 一个高性能 W eb 服务器可能在每次收到 W e b 浏览器的连接请求 时都创建一个新的对等线程。因为每个连接都是由一个单独的线程独立处理的，所以对千服务器 而言，就很没有必要（实际上也不愿意）显式地等待每个对等线程终止。在这种情况下，每 个对等线程都应该在它开始处理请求之前分离它自身，这样就能在它终止后回收它的内存 资源了。

12\. 3. 7 初始化线程

p t hr e a d_onc e 函数允许你初始化与线程例程相关的 状态。

\#include \<pthread.h\>

pthread_once_t once_control = PTHREAD_ONCE_INIT; int pthread_once(pthread_once_t \*once_control,

void (\*init_routine)(void));

总是返回o.

o n c e \_c o n tr o l 变量是一 个全局或者静态变量 ，总 是被初始化为 PT H READ_ONCE\_ I NIT 。当你第一次用参数 on c e \_ c o n tr o l 调用 p t hr e a d \_ o nce 时， 它调用 m江 r ou­

tine, 这是一个没有输入参数 、也不返回什么的函数。接下来的以 o nc e \_c on t r o l 五参数的 p t hr e a d \_o nc e 调用不做任何事情。无论何时， 当你需要动态初始化多个线程共享的全局变量时， p t hr e a d \_ o n c e 函数是很有用的。我们将在 1 2. 5. 5 节里看到一个示例。

12\. 3. 8 基千线程的并发服务器

图 12-14 展示了基于线程的并发 echo 服务器的代码。整体结构类似于基于进程的设计。主线程不断地等待连接请求，然后创建一个对等线程处理该请求。虽然代码看似简

单， 但是有几个普遍而且有些 微妙的问题需要我们更 仔细地看一 看。第一个问题是当我们调用 p t hr e a d \_ cr e a t e 时， 如何将已连接描述符传递给对等线 程。最明 显的方法就是传递一个指向这个描述符的指针，就像下面这样

connfd = Accept(listenfd, (SA\*) \&clientaddr, \&clientlen); Pthread_create(&tid, NULL, thread, \&connfd);

然后，我们让对等线程间接引用这个指针，并将它赋值给一个局部变量，如下所示

void \*thread(void \*vargp) {

int connfd = \*((int \*)vargp);

code/co吹n chosevrert.c

7.  clientlen=sizeof (struct sockaddr_storage);
8.  connfdp = Malloc(sizeof(int));
9.  • connf dp = Accept(listenfd, (SA•) \&clientaddr, \&clientlen);
10. Pthread_create(&tid, NULL, thread, connfdp); 24 }

    25 }

    26

11. I• Thread routine•I
12. void•thread(void•vargp)

    29 {

13. int connf d = \* ((int \*)vargp) ;
14. Pthread_detach(pthread_self ());
15. Free(vargp);
16. echo(connfd) ;
17. Close(connfd);
18. return NULL;

    36 }

code/condechoservert.c

图 12-1 4 基于线程的 并发 echo 服务器

然而， 这样可能会出错， 因为它在对 等线程的赋值语句和主线程的 a c c e p t 语句间引入了竞争 ( race ) 。如果赋值语句在下一个 a c ce p t 之前完成， 那么对等线程中的局部变量c o nn f d就得到正确的描述符值。然而， 如果赋值语句是在 a c c e p t 之后才完成的， 那么对等线程中的 局部变量 c o n nf d 就得到下一次连接的描述符值。那么不幸的结果就是， 现在两个线程在同一个描述符上执行输入和输出。为了避免这种潜在的致命竞争，我们必须将 a c ce p七返回的每个已连接描述符分配到它自己的动态分配的内存块， 如第 20 21 行所示。我们 会在 12. 7. 4 节中回过来讨论竞争的问题。

另一个问题是在线程例程中避免内存泄漏。既然不显式地收回线程， 就必须分离每个线程，使 得在它终止时它的内存资源能够被收回（第31 行）。更进一步， 我们必须小心释放主线程分配的内存块（第32 行）。

沁氐 练习题 12. 5 在图 12- 5 中基 于进 程的服务器中， 我们 在两个位置小心 地关 闭 了 已连接描述 符： 父进 程和子进程。 然而，在 图 1 2-14 中基 于线程 的服务器中， 我们只在 一个位置关闭了巳连接描述符：对等线程。为什么？

12\. 4 多线程程序中的共享变量

从程序员的角度来看，线程很有吸引力的一个方面是多个线程很容易共享相同的程序 变量。然而， 这种共享也是很棘手的。为了编写正确的多线程程序， 我们 必须对所谓的 共享以及它是如何工作的有很清楚的了解。

为了理解 C 程序中的一个变量是否是共享的， 有一些基本的问题要解答： 1) 线程的基础内存模型是什么? 2 ) 根据这个 模型， 变量实例是如何映 射到内存的? 3 ) 最后， 有多少线程引用这些实例？一个变量是共享的，当且仅当多个线程引用这个变董的某个实例。

为了让 我们对共享的讨论具 体化， 我们将使用图 12-15 中的程序作为运行示例。尽管有些人为的痕迹， 但是它仍然值得研究， 因为它说明 了关于共享的许多细微之处。示例程序由一个创建了两个对等线程的主线程组成。主线程传递一个唯一的 ID 给每个 对等线程， 每个对等线程利用这个 ID 输出一条个性化的信息， 以及调用该线程例程的总次数。

12 . 4. 1 线程内存模型

一组并发线程运行在一个进程的上下文中。每个线程都有它自己独立的线程上下文， 包括线程 ID、栈、栈指针、程序计数器、条件码和通用目的寄存器值。每个线程和其他线程一起共享进程上下文的剩余部分。这包括整个用户虚拟地址空间，它是由只读文本

（代码）、读／写数据、堆以及所有的共享库代码和数据区域组成的。线程也共享相同的打开文件的集合。

从实际操作的角度来说 ，让 一个线程去读或写另一个线程的寄存器值是不可能的。另一方面， 任何线程都可以访问共享虚拟内存的任意位置。如果某个线程修改 了一个内存位置， 那么其他每个线程最终都能 在它读这个位 置时发现这个变化。因此，寄 存器是从不共享的， 而虚拟内存总是共享的 。

各自独立的线程栈的内存模型不是那么整齐清楚的。这些栈被保存在虚拟地址空间的 栈区域中， 并且通常是被相应的线程独立 地访问 的。我们说通常而不是总是， 是因为不同的线程栈是不对其他线程设防的 。所以， 如果一个线程以某种方式得到一个指向其他线程栈的指针， 那么它就可以 读写这个栈的任何部分。示例程序在第 26 行 展示了这一点， 其中对等线程直接通过全局变量 p tr 间接引用主线程的栈的内容。

code/condsharing.c

\#include "csapp.h"

1.  \#define N 2
    1.  void \*thread(void \*vargp);

5 char \*\*ptr; I\* Global variable \*I

6

7 int main()

8 {

1.  int i;
2.  pthread_t tid;
3.  char \*msgs [NJ = {
4.  "Hello from foo",
5.  "Hello from bar"

    14 };

    15

6.  ptr = msgs;
7.  for (i = O; i \< N; i++)
8.  Pthread_create(&tid, NULL, thread, (void \*)i);
9.  Pthread_exit (NULL) ; 20 }

    21

    22 void \*thread(void \*vargp)

    23 {

10. int myid = (int)vargp;
11. static int cnt = 0;
12. printf(" [%d]: %s (cnt=%d)\\n", myid, ptr[myid], ++cnt);
13. return NULL;

    28 }

code/condsharing.c

图 12-1:i 说明共享不同方面的示例程序

1.  4\. 2 将变星映射到内存

    多线程的 C 程序中变量根据它们的存储类 型被映射到虚拟内存：

    -   全局 变量。 全局变量是定义在函数之外的变量。在运行时， 虚拟内存的读／写区域只包含每个 全局变量的一 个实例， 任何线程都可以引用。例如， 第 5 行声明的全局变量 p tr 在虚拟内存的读／写区域中有一个运行时实例。当一个变量只有一个实例时， 我们只用 变量名（在这里就是 p tr ) 来表示这个实例。
    -   本地自动 变量。 本地自动变量就是定义在函数内部但是没有 s 七a t i c 属性的变量。在运行时，每个线程的栈都包含它自己的所有本地自动变量的实例。即使多个线程 执行同一个线程例程时也是如此。例如， 有一个本地变量 t i d 的实例，它 保存在主线程的栈中。我们用 巨 d . m 来表示这个实例。再来看一个例子， 本地变量 my 过 有两个实例 ， 一个在对等线程 0 的栈内， 另一个在对等线程 1 的栈内。我们将这两个实例分别表示为 my i d . p O 和 my i d . p l 。
    -   本地静 态变量。 本地静态变量是定义在函数内部并有 s t a t i c 属性的变量。和全局变量一样， 虚拟内存的读／写区域只包含在程序中声明的每个本地静态变量的一个实例。例如， 即使示例程序中的每个对等线程都 在第 25 行声明了 c n t , 在运行时， 虚拟内存的读／写区域中也只有一个 c n t 的实例。每个对等线程都读和写这个实例。

12\. 4. 3 ，.±f:. 吉示亘 立旦

我们说一个变量 v 是共享的 ，当 且 仅 当它的一个实例被一个以上的线程引用。例如， 示例程序中的变量 c n t 就是共享的，因 为它只有一个运行时实例，并 且这个实例被两个对等线程引用。在另一方面， my 过 不 是 共 享 的 ， 因 为它的两个实例中每一个都只被一个线程引用。然而，认 识 到像 ms g s 这样的本地自动变量也能被共享是很重要的。

饬 练习题 12. 6

1.  利用 12. 4 节 中的分析， 为 图 12-1 5 中的 示 例 程 序在下 表的每 个条目中填写 “ 是“ 或者“ 否＂。在第 一列 中， 符号 v. t 表 示 变 量 v 的 一个实例 ， 它 驻 留在线程 t 的本地栈中， 其中 t 要 么是 m( 主 线程），要么是 p O( 对等线程 0 ) 或者 p l ( 对等 线程 1 ) 。

| 变量实例 ptr cnt i.m msgs.m myid.po myi d . p l | 主线程引用的？ | 对等线程0引用的？ | 对等线程1引用的？ |
|-------------------------------------------------|----------------|-------------------|-------------------|

2.  根据 A 部分的分析， 变 量 p tr 、 c n t 、 1 、 ms g s 和 my 过 哪 些是 共享的？

### 5 用信号量同步线程

共享变量是十分方便，但 是 它 们也引 入了同 步错 误 ( s ynch ro nization er ro r ) 的可能性。考

虑图 12-16 中的程序 b a d c n t . c , 它创建了两个线程， 每个线程都对共享计数变量 c nt 加 1。

cod e/conclb ad cnt.c

1.  I\* WARNING : This code is buggy! \*I
    1.  \#include "csapp.h"

        3

        4 void \*thread(void \*vargp); I\* Thread routine prototype \*I

        5

2.  I\* Global shared variable \*I
3.  volatile long cnt = 0; I\* Counter \*I

    8

    9 int main(int argc, char \*\*argv)

    10 {

4.  long niters;
5.  pthread_t tid1, tid2;

    13

6.  I\* Check input argument \*I
7.  if (argc != 2) {
8.  printf("usage: %s \<niters\>\\n", argv[O]);
9.  exit(O);

    18 }

    19 niters = atoi(argv [1]);

    20

10. I\* Create threads and wait for them to finish \*I
11. Pthread_create(&tid1, 皿 L, thread, \&niters);

    图12- 16 ba dc nt . c, 一个同步不正确的计数器程序

| 23 | Pthread_create(&tid2, 皿 L, thread, | \&niters); |
|----|-------------------------------------|------------|
| 24 | Pthread_join(tid1, NULL);           |            |
| 25 | Pthread_join (tid2, NULL) ;         |            |
| 26 |                                     |            |
| 27 | I\* Check result \*I                |            |
| 28 | if Cent != (2 \* niters))           |            |
| 29 | printf("BODM! cnt=%ld\\n", cnt);    |            |
| 30 | else                                |            |
| 31 | printf ("DK cnt=%ld\\n", cnt);      |            |

32 exit(O); 33 }

34

1.  I\* Thread routine \*I
2.  void \*thread(void \*vargp) 37 {

    38 long i, niters = \*((long \*)vargp); 39

3.  for (i = O; i \< niters; i++)
4.  cnt++;

    42

    43 return NULL;

    44 }

codelcondbadcnt.c

图 12-16 (续）

因为每个线 程都对计数器增加了 n i t er s 次， 我们预计它的最终值是 2 X n i t er s 。这看上去简单 而直接 。然而， 当在 L in u x 系统上运行 b a d c n t . c 时，我 们不仅得到错误的答案，而且每次得到的答案都还不相同！

linux\> ./badcnt 1000000 BOOM! cnt=1445085

linux\> ./badcnt 1000000 BOOM! cnt=1915220

linux\> ./badcnt 1000000 BOOM! cnt=1404746

那么哪里出错 了呢？为了清晰地理解 这个问题， 我们需要研究计数器循环（第40 41 行）的汇编代码， 如图 1 2- 1 7 所示。我们发现， 将线程 1 的循环代码分解成 五个部分是很有帮助的：

-   H , : 在循环头部的指令块。
-   L,: 加载共享变量 c n t 到累加寄存器%r d x , 的 指令， 这里%r d x , 表示线程 1 中的寄存器%r d x 的 值。
-   U, : 更新（增加） %r d x, 的指令。
-   s,: 将%r d x ; 的 更新值存回到共享变量 c n t 的指令。
-   T;: 循环尾部的指令块。

    注意头和尾只操作本地栈变量 ， 而 L, 、U,和 S ,操作共享计数器变量的内容。

    当 b a d c n t . c 中的两个对等线程在一 个单处理器上并发运行时， 机器指 令以某种顺序一个接一个地完成。因此，每个并发执行定义了两个线程中的指令的某种全序（或者交 叉）。不幸的是，这些顺序中的一些将会产生正确结果，但是其他的则不会。

线程的汇编代码

线程 的C代码

f o r (i =O ; i \< ni 七 e r s ; i++) 1

圈畛

cnt++;

H,: 头

![](img/3dd856d1f38bb94e960525b3c025f62d.jpeg)L, : 加载c nt

u,: 更新c nt

S;: 存储c nt

T, : 尾

图 1 2-1 7 ba dc nt . c 中计数器循环（第40\~ 41 行）的汇编代码

这里有个关键点：一般而言，你没有办法预剧操作系统是否将为你的线程选择一个正 确的顺序。例如，图 1 2-1 8 a 展 示了一个正确的指令顺序的分步操作。在每个线程更新了共享变量 e n 七之 后 ，它 在 内 存 中 的 值 就 是 2 , 这正是期望的值。

另一方面，图 1 2-1 8 b 的 顺 序产生一个不正确的 c n t 的值。会发生这样的问题是因为， 线 程 2 在 第 5 步加载 c n t , 是在第 2 步线程 1 加载 c n t 之后， 而在第 6 步线程 1 存储它的更新值之前。因此， 每个线程最终都会存储一个值为 1 的更新后的计数器值。我们能够借 助千一种叫做进度图 ( p ro g r es s g ra p h ) 的 方法来阐明这些正确的和不正确的指令顺序的概念， 这个图我们将在下一节中介绍。

a ) 正确的顺序 b ) 不正确的顺序

图 1 2-18 badc nt . c 中第一次循环迭代的指令顺 序

凶 练习题 12 . 7 根据 b a d c n t . c 的指令顺序 完成 下表：

。

这种顺 序会产 生 一个正确的 c n t 值吗？

12 . 5 . 1 进度图

进度图( pro g res s g ra ph ) 将 n 个并发线程的执行模型化为一条 n 维笛卡儿空间中的轨迹线。每条轴 k 对应于线程 k 的进度。每个点 ( Ii , lz , …, J" ) 代表线程 k ( k = l , … ， n )已经完成 了指令 Ik这一状态。图的原点对应于没有任何线程完成一 条指令 的初始状态。

图 1 2-19 展示了 b a d c n t . c 程序第一 次循环 迭代的二维进度图 。水平轴对应于线程 1,

垂直轴对应于线程 2。点 CL 1, S 2) 对应于线程 1 完成了 L1 而线程 2 完成了 S2的状态。

进度图将 指令执行模型化 为从一种状态到另一种状态的转换 ( t ra ns it io n ) 。转换 被表示为一条从一点到相邻点的有向边。合法的 转换是向右（线程 1 中的一条指令完成）或者向上

（线程 2 中的一条指令完成）的。两条指令不能在同一时刻完成一 对角线转换是不允许的。程序决不会反向运行，所以向下或者向左移动的转换也是不合法的。

一个程序的执行历史被模型化为状态空间 中的一条轨迹线。图 12-20 展示了下面指令顺序对应的轨迹线：

###### H1, L1, U1, H2, L2, S1, T1 , U2 , S 2 , T 2

线程2 线程2

(L．,, S2)

###### S2 S2

U2 Ui

###### L2 L2

H2

H , L1 U1 S1 Tl

线程l

Hi

H, L, U,

S, T,

线程l

图 12- 1 9

badcnt . c 第一次循环迭代的进度图

图 12-20

一个轨迹线示例

对于线程 i' 操作共享变量 c n t 内容的指令( L; , U;, S; ) 构成了一个（关于共享变量

c让 的）临界区 ( crit ica l section), 这个临界区不应该和其他进程的临界区交替执行。换句话说，我们想要确保每个线程在执行它的临界区中的指令时，拥有对共享变量的互斥的访问 ( m ut uall y exclusive access ) 。通常这种现象称为互斥 ( m ut ua l e xcl us io n ) 。

在进度图 中， 两个临界区的交集形成的状态空间区域称为不安 全区 ( unsafe regio n ) 。图 12-21 展示了变量 c吐 的不安全区。注意 ， 不安全区和与它交界的状态相毗邻， 但并不包括这些状态。例如， 状态CH 1 , H z) 和CS 1 , Uz) 毗邻不安全区， 但是它们并不是不安全区的一部分。绕开不安全 区的轨迹线叫做安全轨迹线( sa fe t ra jector y) 。相反， 接触到任何 不安全区的轨迹线就叫做不 安全轨迹线 ( unsa fe t ra jecto r y ) 。图 12- 21 给出了示例程序ba d e n七 . c 的 状态空间中的安全和不安全轨迹线。上面的 轨迹线绕开了不安全区域的左边和上边，所 以是安全的。下面的轨 迹线穿 越不安全区， 因此是不安全的 。

任何安全轨迹线都将正确地更新共享计数器。为了保证线程化程序示例的正确执行（实 际上任何共享全局数据结构的并发程序的正确执行）我们必须以某种方式同步线程，使它们 总是有一条安全轨迹线。一个经典的方法是基于信号量的思想， 接下来我们就介绍它。

饬 练习题 12 . 8 使用 图 1 2-21 中的 进度 图， 将下列 轨迹 线划分为 安全的 或者 不 安全 的。

###### A. H1, L1, U1, S1, H2 , L 2 , U2 , S 2 , T 2 , T1

| B. H2  | , | L 2 | , | H 1 , L 1 , U1, S1,       | T1, | U2, 5 2 , T 2 |
|--------|---|-----|---|---------------------------|-----|---------------|
| C. H 1 | , | H2, |   | L 2 , U2 , S2 , L1, 线程2 | U1, | S1, T1, T2    |

![](img/950d49a36890602e7ea6a628769c77f9.jpeg)T,

s,

写 c nt 的 j u,

###### L2

HJ

H1 L1 亿 SI T, 线程1

写 cnt 的临界区

图 12-21 安全和不安全轨迹线。临界区的交集形成了不安全区。绕开不安全区的轨迹线能够正确更新计数器变量

1.  5\. 2 信号量

    Edsger Dijkstra, 并发编程领域的先锋人物，提出了一种经典的解决同步不同执行线程问题的方法， 这种方法是基千一种叫做信号 量( s em a p ho re ) 的特殊类型变量的。信号 量 s 是具有非负整数值的全局变量，只 能由两种特殊的操作来处理，这两 种操作称为 P 和 V :

    -   PCs): 如果 s 是非零的， 那么 P 将 s 减 1, 并且立即返回。如果 s 为零， 那么就挂起这个线程， 直到 s 变为非 零，而 一个 V 操作会重启 这个线程。在重启之后， P 操作将 s 减 1, 并将控制返回给调用者。
    -   V(s): V操作将 s 加 1 。如果有任何线程阻 塞在 P 操作等待 s 变成非零， 那么 V 操作会重启这些线程中的一个 ， 然后该线程将 s 减 1, 完成它的 P 操作。

        P 中的测试和减 1 操作是不可分割的，也 就是说， 一旦预测信号量 s 变为非 零， 就会将 s 减 1, 不能有中断。V 中的加 1 操作也是不可分割的，也 就是加载、加 1 和存储信号量的过程中没有中断。注意 ， V 的定义中没有定义等待线程被重启动的顺序。唯一的要求是 V 必须只能重启一个正在等待的线 程。 因此 ， 当有多个线程 在等待 同一个信号量时 ，你不能预 测 V 操作要重启哪 一个线程。

        P 和 V 的定义确保了一个正在运行的程序绝不 可能进入这样一种状态 ，也 就是一个正确初始化了 的信号量有一个负值。这个属性称为信号量不 变性( se m a pho re invariant), 为控制并发程序的轨迹线提供了强有力的工具，在下一节中我们将看到。

        P os ix 标准定义了许多操作信号量的函数。

\#include \<semaphore.h\>

int sem_init(sem_t•sem, 0, unsigned int value); int sem_wait(sem_t•s); /• P(s)•I

int sem_post(sem_t•s); I• V(s)•I

返回： 若 成 功 则为 0 , 若 出错 则为 一1.

s e m\_ i n i t 函数 将 信 号 量 s e m 初 始 化 为 v a l u e 。每个信号最在使用前必须初始化。针对我们的目的，中 间 的 参 数 总 是 零 。 程 序分别通过调用 s e m\_ wa 江 和 s e m\_ p o 江 函 数 来执行 P 和 V 操作。为了简明，我 们更喜欢使用下面这些等价的 P 和 V 的包装函数：

\#include "csapp. h"

void P(sem_t \*s); I\* Wrapper function for sem_wa i t \*I void V(sem_t \*s ) ; I\* Wr apper f un ct i o n for s e m_pos t \*I

返 回 ： 无 。

匮目P 和 V 名字的起源

E dsge r Dijk s t ra0 930 —20 0 2 ) 出生于荷 兰。名 字 P 和 V 来源 于荷 兰语 单词 P ro ber en

（测试）和V e r h og e n ( 增加）。

1.  5\. 3 使用信号量来实现互斥

    信号量提供了一种很方便的方法来确保对共享变量的互斥访问。基本思想是将每个共 享变量（或者一组相关的共享变量）与一个信号量 s ( 初始为 1 ) 联系起来， 然后用 P Cs ) 和 V Cs ) 操 作 将相应的临界区包围起来。

    以这种方式来保护共享变量的信号量叫做二元信号量 ( b in a r y s e m a p ho r e ) , 因为它的值总是 0 或者 1 。以提供互斥为目的的二元信号量常常也称为互 斥 锁 ( m ut ex ) 。在一个互斥锁上执行 P 操作称为对互斥锁加锁。类 似地， 执 行 V 操 作 称 为对互斥锁 解锁。对一个互斥锁加了锁但是还没有解锁的线程称为占 用这 个互斥锁。一个被用作一组可用资源的计数器的信号量被称为计数信号量。

    图 1 2- 22 中的进度图展示了我们如何利用二元信号量来正确地同步计数器程序示例。每个状态都标出了该状态中信号量 s 的值。关键思想是这种 P 和 V 操作的结合创建了一组

    线程2

.0 .0

T,

．0 ．0

.0 .0 ．I ．I

．0 ．0 ．I

V(s) 。

一1

S, ：

禁止区 。

·· ··-··I···········-··I····,·- ·I ·'•···

。 。 : - I

卜·：

.- I

\- I - I i

;.

u, 。 。

L 2 0 。

不安全区

1- 1 - I - I - I ．

；·一··I············-···I··············-·1······-··1··!·•'· 。

P (s )

0 .0 .0 0

## CTfil

,1-f

0 0 0

线 程1

H , P (s ) L1 U1 SI V(s) T1

图 12-22 使用信号量来互斥。s\< O 的不可行状态定义了一个禁 止区， 禁止区完全包括了不安全区， 阻止了实际可行的轨迹线接触到不安全区

状态， 叫做禁止 区( fo r b idde n region) , 其中 s\< O。 因为信号量的不变性 ， 没有实际可行的轨迹线能够包含禁止区中的状态。而且， 因为禁止区完全包括了不 安全区， 所以没有实际可行的轨迹线能够接触不安全区的任何部分。因此，每条实际可行的轨迹线都是安全的， 而且不管运行时指令顺序是怎样的，程序都会正确地增加计数器值。

从可操作的意义上来说， 由 P 和 V 操作创建的禁止区使得在任何时间点上， 在被包围的临 界区中， 不可能有多个线程在执行 指令。换句话说，信 号量操作确保了对临界区的互斥访问 。

总的来说， 为了用信号量正确同步图 1 2-1 6 中的计数器程序示例，我 们首先声 明一个信号量 mu 七e x :

volatile long cnt = O; I\* Counter \*I

sem_t mutex; I\* Semaphore that protects counter \*I

然后在主例程中将 mu t e x 初始化 为 1 :

Sem_init(&mutex, 0, 1); I\* mutex = 1 \*I

最后， 我们通 过把在线程例程中对共享变僵 c n t 的更新包围 P 和 V 操作， 从而保护它们：

for (i = O; i \< niters; i++) { P(&mutex);

cnt++;

V(&mutex);

｝

当我们运行这个正确同步的程序时，现在它每次都能产生正确的结果了。

linux\> ./goodcnt 1000000 OK cnt=2000000

linux\> ./goodcnt 1000000 OK cnt=2000000

m 进度图的 局限性

进度图给了我们一种较好的方法，将在单处理器上的并发程序执行可视化，也帮助 我们理解为什么需要同步。然而，它们确实也有局限性，特别是对于在多处理器上的并 发执行，在 多处 理器上一 组 CPU/ 高速缓 存对共享同一 个主 存。多 处理 器的 工作方式是进度图不能解释的 。特别是 ，一 个多处理 器内存 系统可以 处于一 种状态，不 对应 于进度图中任何轨迹线。不 管如何 ， 结论总是一样的 ： 无论是 在单处理 器还是 多处 理器上运行程序， 都要 同步你 对共享 变量的 访问。

1.  5\. 4 利用信号量来调度共享资源

    除了提供互斥之外，信 号量的另一个重要作用是调度对共享资源的访问。在这种场景中， 一个线程用信号量操作来通知另一个线程， 程序状 态中的某个条件已经为真了。两个经典而有用的例子是生产者－消费者和读者－写者问 题。

    1 生产者－消费者问题

    图 1 2- 23 给出了生产者－消费者问 题。生产者 和消费者线程共享一个有 n 个槽的有限缓 冲区。生产者线程反复地生成新的项目 ( item ) , 并把它们插入到缓冲区中。消费者线程不断地

从缓冲区中取出这些项目，然后消费（使用）它们。也可能有多个生产者和消费者的变种。

![](img/31d0ba10420bdde7d1c5772778c7aaef.jpeg)

图 12- 23 生产者－消费者问题。生产者产生项目并把它们插入到一个有限的缓冲区中。消费者从缓冲区中取出这些项目，然后消费它们

因为插入和取出项目都涉及更新共享变量，所以我们必须保证对缓冲区的访问是互斥的。但是只保证互斥访问是不够的，我们还需要调度对缓冲区的访问。如果缓冲区是满的

（没有空的槽位），那么生产者必须等待直到有一个槽位变为可用。与之相似，如果缓冲区 是空的（没有可取用的项目），那么消费者必须等待直到有一个项目变为可用。

生产者－消费者的相互作用在现实系统中是很普遍的。例如，在一个多媒体系统中， 生产者编码视频帧，而消费者解码并在屏幕上呈现出来。缓冲区的目的是为了减少视频流的抖动，而这种抖动是由各个帧的编码和解码时与数据相关的差异引起的。缓冲区为生产者提供了一个槽位池，而为 消费者提供一个已编码的帧池。另一个常见的示例是图形用户接口设计。生产者检测到鼠 标和键盘事件， 并将它们插入到缓 冲区中。消费者以某种基于优先级的方式从缓冲区取出这些事件，并显示在屏幕上。

在本节 中， 我们 将开发一个简单的包， 叫做 SBUF , 用来构造生产者－消费者程序。在下一节里 ， 我们会看到如何 用它来构造一个基千预 线程化( pr et h rea d in g ) 的有趣的并发服务器。SBUF 操作类型为 s b u f \_ t 的有限缓冲区（图1 2- 24 ) 。项目存放在一个动态分配的

n 项整数数组 ( b u f ) 中。fr o n t 和r e ar 索引值记录该数组中的 第一项 和最后一项。三个信号量同步对缓冲区的 访问。mu t e x 信号量提供互斥的缓冲区访问 。s l o t s 和 i t e ms 信号 量分别记录空槽位和可用项目 的数量。

typedef struct { int \*buf;

I\* Buffer array \*I

code/condsbuf h

int n;

int front; int rear; sem_t mutex; sem_t slots; sem_t items;

} sbuf_t;

I\* Maximum number of slots \*I

I\* buf[(front+1)%n] is first item \*I I\* buf[rear%n] is last item \*I

I\* Protects accesses to buf \*I I\* Counts available slots \*I I\* Counts available items \*I

code/condsbuf.h

图 l 2-24 sbuf_t: SBUF 包使用的有限缓 冲区

图 1 2- 25 给出 了 SBU F 函数的实现。 s b u f \_ i n i t 函数为缓 冲区 分配堆内存，设 置f r o n 七和 r e ar 表示一个空的缓冲区 ， 并为三个 信号量赋初始值。这个函数在调用其他三个函数中的任何一个之前调用一次。s b u f \_ d e i n 江 函数是当应用程序使用完缓冲区时 ， 释放缓冲区存储的 。s b u f \_ i n s er t 函数等待一个可用的槽 位， 对互斥锁加锁， 添加项目， 对互斥锁解锁， 然后宣布有一个新项目可用。s b u f \_r e mo v e 函数是与 s b u f \_ i n s er t 函数对称的。在等待一个可用的缓冲区项目之后，对互斥锁加锁，从缓冲区的前面取出该项目， 对互斥锁解锁， 然后发信号通知一个新的槽位可供使用 。

code/condsbu肛

1.  \#include II csapp. h11
    1.  \#include 11sbuf .h11

        3

2.  I\* Create an empty, bounded, shared FIFO buffer with n slots \*I
3.  void sbuf_init(sbuf_t \*sp, int n)

    6 {

4.  sp-\>buf = Calloc(n, sizeof(int));
5.  sp-\>n = n; I\* Buffer holds max of n items \*I
6.  sp-\>front = sp-\>rear = 0; I\* Empty buffer iff front == rear \*I 1O Sem_init (&sp-\>mutex, 0, 1); I\* Binary semaphore for locking \*I
7.  Sem_init(&sp-\>slots, 0, n); I\* Initially, buf has n empty slots \*I
8.  Sem_init(&sp-\>items, O, 0); I\* Initially, bufhas zero data items \*I

    13 }

    14

9.  I\* Clean up buffer sp \*I
10. void sbuf_deinit(sbuf_t \*Sp)

    17 {

    18 Free(sp-\>buf);

    19 }

    20

11. I\* Insert item onto the rear of shared buffer sp \*I
12. void sbuf_insert(sbuf_t \*Sp, int item) 23 {
13. P (&sp-\>slots); I\* Wait for available slot \*I
14. P (&sp-\>mutex); I\* Lock the buffer \*I
15. sp-\>buf [ (++s p- \>r ea 工）%(sp-\>n)] = item; I\* Insert the item \*I
16. V(&sp-\>mutex); I\* Unlock the buffer \*I
17. V(&sp-\>items); I\* Announce available item \*I

    29 }

    30

18. I\* Remove and return the first item from buffer sp \*I
19. int sbuf_remove(sbuf_t \*Sp)

    33 {

20. int item·
21. P(&sp-\>items); I\* Wait for available item \*I
22. P(&sp-\>mutex); I\* Lock the buffer \*I
23. item= sp-\>buf[(++sp-\>front)%(sp-\>n)]; I\* Remove the item \*I
24. V(&sp-\>mutex); I\* Unlock the buffer \*I
25. V(&sp-\>slots); I\* Announce available slot \*I
26. return item;

    41 }

code/condsbu肛

图 12- 25 SBUF: 同步对有限缓冲区并发访问的包

练习题 12. 9 设 p 表 示 生产 者数 量， c 表 示 消费者数量， 而 n 表 示 以项目单元 为单 位

的缓冲 区大小。对于下 面的每个场景 ， 指 出 s b u f \_ i n s er t 和 s b u f \_ r e mo v e 中的互斥锁信号量是否是必需的。

1.  p = I , c = 1 , n \> l
    1.  p = I , c = 1 , n = I

##### p\> I, c\>l, n=I

2 读者－者写问题

读者－者写问题是互斥问题的一个概括。一组并发的线程要访问一个共享对象， 例如

一个主存中的数据结构，或 者一个磁盘上的数据库。有些线程只读对象， 而其 他 的 线 程只修改对象。修改对象的线程叫做写者。只读对象的线程叫做读者。写者必须拥有对对象的 独占的访问，而读者可以和无限多个其他的读者共享对象。一般来说，有无限多个并发的 读者和写者。

读者－写者交互在现实系统中很常见。例如，一个在线航空预定系统中，允许有 无限多个客户同时查看座位分配，但是正在预订座位的客户必须拥有对数据库的独占 的访问。再来看另一个例子， 在 一个多线程缓 存 Web 代理中， 无 限 多 个 线 程可以从共享页面缓存中取出已有的页面，但是任何向缓存中写入一个新页面的线程必须拥有 独占的访问。

读者－写者问题有几个变种，分别基于读者和写者的优先级。第一类读者－写者问题，读者优先，要求不要让读者等待，除非已经

把使用对象的权限赋予了一个写者。换旬

话说，读者不会因为有一个写者在等待而等待。第二类读者－写者问题，写者优先， 要求一旦一个写者准备好可以写，它就会尽可能快地完成它的写操作。同第一类问题不同，在一个写者后到达的读者必须等待，即使这个写者也是在等待。

图 12-26 给出了一个对第一类读者－ 写者问题的解答。同许多同步问题的解 答一样，这个解答很微妙，极具欺骗性 地简单。信号量 w 控制对访问共享对象 的临界区的访问。信号量 mu t e x 保 护 对共享变量 r e a d c n t 的访问，r e a d c n t 统计当前在临界区中的读者数量。每当一 个写者进入临界区时， 它 对 互 斥锁 w 加锁 ， 每当它离 开 临 界 区 时， 对 w 解 锁 。这就保证了任意时刻临界区中最多只有 一个写者。另一方面，只有第一个进入 临界区的读者对 w 加 锁 ， 而 只 有 最 后 一个 离 开临界区的读 者对 w 解 锁 。 当 一个读者进入和离开临界区时，如果还有其 他读者在临界区中，那么这个读者会忽 略互斥锁 w。这 就意味着只要还有一个读者占用互斥锁 w, 无限多数量的读者可以没有障碍地进入临界区。

对这两种读者－写者问题的正确解答可能导致饥饿 ( s ta r va t io n ) , 饥饿就是一

I\* Global va工ia bl e s \*I

int readcnt; I\* Initially= 0 \*I

sem_t mutex, w; I\* Both initially= 1 \*I

void reader(void)

｛

while (1) {

P(&mutex); readcnt++;

if (readcnt == 1) I\* First in \*I

P(&w); V(&mutex);

I\* Critical section \*I I\* Reading happens \*I

P(&mutex); readcnt--;

if (readcnt == 0) I\* Last out \*I

V(&w); V(&mutex);

void writer(void)

｛

while (1) {

P(&w);

I\* Critical section \*I I\* Writing happens \*I

V(&w);

个线程无限期地阻塞，无法进展。例如，

图 12-26 所示的解答中，如 果 有 读 者 不 断地到达，写者就可能无限期地等待。

图 12-26 对第一类读者－写者问题的解答。读者优先级高于写者

练习题 12. 10 图 12- 26 所 示的 对 第 一 类 读者－写者问题的 解答给 予 读 者 较 高 的 优先级，但是从某种意义上说，这种优先级是很弱的，因为一个离开临界区的写者可能重 启一个在等待的写者，而不是一个在等待的读者。描述出一个场景，其中这种弱优先 级会导致一群写者使得一个读者饥饿。

应I \_其他同步机 制

我们已经向你展示了如何利用信号量来同步线程，主要是因为它们简单、经典，并且 有一个清晰的语义模型。但是你应该知道还是存在 着其他 同步技 术的。例如 ， Ja va 线程是用一种叫做 Java 监控器(J ava Monitor) [ 48] 的机制来同步的 ， 它提供了对 信号量 互斥 和调度能力的更高级 别的抽 象； 实际 上，监控 器 可以 用信号量来 实现。再 来看一 个例 子， Pthrea ds 接口定义了一组对互斥锁和条件 变量的 同步 操作。Pthreads 互斥锁 被用 来实现互斥。条件 变量用来调 度对共享资源的访问， 例如在一个生产者－消费者程序中的有限缓冲区。

12 . 5. 5 综合：基千预线程化的并发服务器

我们已 经知道了如何使用信号量来访问 共享变量和调度对共享资源的访问。为了帮 助你更清晰地理解这些思想，让 我们把它们应用到一个基千称为预线程化( pret hread ing )技术的并发服务器上。

![](img/3eb51c417054ab5f06bd1748d41e68b1.jpeg)在图 1 2-14 所示的并发服务器中， 我们为每一个新客户端创建了一个新线程。这种方法的缺点是我们为每一个新客户端创建一个新线程，导致不小的代价。一个基于预线程化 的服务器试图通过使用如图 1 2-27 所示的生产者－消费者模型来 降低这种开销。服务器是由一个主线程和一组工作者线程构 成的。主线程不断地接受来自客户端的连接请求， 并将得到的连接描述符放 在一个有限缓冲区中。每一个工作 者线程反复 地从共享缓冲区中 取出描述符， 为客户端 服务， 然后等待下一个描述符。

图 1 2- 27 预线程化的并发服务器的组织结构。一组现有的线程不断地取出

和处理来自有限缓冲区的已连接描述符

图 12-28 显示了我们怎样用 SBUF 包来实现一个预线程化的并发 echo 服务器。 在初始化了缓冲区 s b u f ( 第 24 行）后， 主线程创建 了一组工作者线程（第25 \~ 26 行）。然后它进 入了无限的服务器循 环，接 受连接 请求， 并将得到的巳 连接描述符插入到缓冲区 s b uf 中。每个工作者线程的行为都非常简单。它等待直到它能从缓冲区中取出一个已连接描述符

（第39 行），然后调用 e c ho_c nt 函数回送客户端的输入。

图 12-29 所示的函数 e c ho_c n t 是图 11-22 中的 e c ho 函数的一个版本， 它在全局变量b yt e \_c nt 中记录了从所有客户端接收到的累计字节数。这是一段值得研究的有趣代码， 因为它向你展示了一个从线程例程 调用的初始化 程序包的 一般技术。在这种情况中， 我们

需要初始化 b y t e \_ c n t 计数器和 rnu t e x 信号量。一个方法是 我们为 SBUF 和 R I O 程序包使用过的， 它要求主线程显式地调用一个初始化函数。另外一个方法， 在此显示的， 是当第一次有某个线程调用e c h o \_ c n t 函数时， 使 用 p t hr e a d \_ o n c e 函数（第 19 行）去调用初始化函数。这个方法的优点是它使程序包的使用更加容易。这种方法的缺点是每一次调用 e c h o \_ c n t 都会导致调用 p t hr e a d\_ o n c e 函数， 而在大多数时候它没有做什么有用的事。

co d e/co nd ech os ervert-p re.c

\#include "csapp.h"

1.  \#include "sbuf .h"
2.  \#define NTHREADS 4
3.  \#define SBUFSIZE 16
1.  void echo_cnt(int connf d) ;
2.  void \*thread(void \*vargp);

9 sbuf_t sbuf; I\* Shared buffer of connected descriptors \*I 10

11 int main(int ar gc, char \*\*argv)

12 {

1.  int i , listenfd, connfd;
2.  socklen_t cl i ent l en;
3.  struct sockaddr_storage clientaddr;
4.  pthread_t tid;
1.  if (argc != 2) {
2.  fprintf(stderr, "usage: %s \<port\>\\n", argv[O]);
3.  e x i t (O) ;

    21

    22 listenfd = Open_listenfd(argv[1]) ;

    23

4.  sbuf_init(&sbuf, SBUFSI ZE) ;
5.  for (i = O; i \< NTHREADS; i ++) I\* Create worker threads \*I 26' Pt hr e a d \_cr ea t e (&t i d , NULL, thread, NULL);

    27

6.  while (1) {
7.  clientlen = sizeof (struct sockaddr_s t or ag e ) ;
8.  connfd = Accept (listenfd, (SA \*) \&clientaddr, \&clientlen);
9.  sbuf_insert(&sbuf, connf d) ; I\* Insert connfd in buffer \*I 32

    33 }

    34

    35 void \*thread(void \*vargp) 36 {

10. Pt hr e ad \_de t a c h ( pt hr e ad \_s e lf O);
11. while (1) {
12. int connfd = sbuf_remove(&sbuf); I\* Remove c onn f d from buffer \*I

40

41

42

43 }

echo_cnt(connfd); Cl os e ( conn f d ) ;

I\* Service client \*I

code/con吹choservert-pre.c

图12- 28 一个预线程化的并发 echo 服务器。这个 服务器使用的是有一个生产者和多个消费者的生产者－消费者模型

code/cone/echo-cnt.c

\#include "csapp.h"

3 static int byte_cnt; I\* Byte counter \*I

4 static sem_t mutex; I\* and the mutex that protects it \*I

6 static void init_echo_cnt(void)

7 {

8 Sem_init(&mutex, 0, 1);

9 byte_cnt = O;

10 }

12 void echo_cnt(int connfd)

13 {

14 int n·

1.  char buf[MAXLINE];
2.  rio_t rio;
3.  static pthread_once_t once= PTHREAD_ONCE_INIT;

    18

4.  Pthread_once(&once, init_echo_cnt);
5.  Rio_readinitb(&rio, connfd);
6.  while ((n = Rio_readlineb (&rio, buf, MAXLINE)) ! = 0) {
7.  P (&mutex);
8.  byte_cnt += n;
9.  printf (11server received %d CJ 儿 d total) bytes on fd %d\\n",
10. n, byte_cnt, connfd);
11. V (&mutex) ;
12. Rio_writen(connfd, buf, n);

    28

    29 }

    code/conc/echo.-ccnt

    图 12- 29 echo_cnt, echo 的一个版本， 它对从客户端接收的所有字节计数

一旦 程序包 被初始化， e c h o \_ c n t 函 数 会 初始化 RIO 带 缓 冲区的 I/ 0 包（第 20 行），然 后 回 送 从 客 户端接收到的每一个文本行。注意，在 第 23 25 行 中 对共享变量 b yt e \_ c n t 的访问是被 P 和 V 操作保护的。

团 日 基千线程的事件驱动程序

I/ 0 多路 复 用不 是 编写事件 驱动程序的唯一方 法。 例如 ， 你可能已经注意到我们刚才开发的并发的预线程化的服务器实际上是一个事件驱动服务器，带有主线程和工作者 线程的简单状态机。主线程有两种状态("等待连接请求”和”等待可用的缓冲区槽 位")、两个 I/ 0 事件( "连接请求到 达” 和 ＂缓 冲区槽 位 变为 可用" )和 两个转换( "接受连接请求” 和 “ 插 入 缓 冲区项 目" )。 类似 地， 每个工作者线程有一个状 态( " 等待 可用的缓冲项目")、 一个 I/ 0 事件（＂缓冲区项 目 变为 可用" )和 一个转换( "取出缓 冲区项 目")。

12\. 6 使用线程提高并行性

到目前为止，在对并发的研究中，我们都假设并发线程是在单处理器系统上执行的。

然而，大多数现代机器具有多核处理器。并发程序通常在这样的机器上运行得更快，因为 操作系统内核在多个核上并行地调度这些并发线程，而不是在单个核上顺序地调度。在像 繁忙的 Web 服务 器、数据库服务器和大型科学计算代码这样的应用中利用这样的并行性是至关重要的， 而且在像 Web 浏览骈、电子表格处理程序和文档处理程序这样的主流应用中，并行性也变得越来越有用。 所有的程序

图 12- 30 给出了顺 序、并发和并行程序之间的 口五五示

集合关系。所有程序的集合能够被划分成不相交

的顺序程序集合和并发程序的集合。写顺序程序只有一条逻辑流。写并发程序有多条并发流。并行程序是一个运行在多个处理器上的并发程序。因此，并行程序的集合是并发程序集合的真子集。

并行程序的详细处理超出了本书讲述的范围，

三 顺序程序

图 12 -30 顺序、并发和并行程序

集合之间的关系

但是研究一个非常简单的示例程序能够帮助你理解并行编程的一些重要的方面。例如，考 虑我们如何并行地对一列整数 o, …, n - l 求和。当然， 对于这个特殊的问 题， 有闭合形式表达式的 解答（译者注： 即有现成的公 式来计算它， 即和等 千 n ( n - 1 ) / 2) , 但是尽管如

此，它是一个简洁和易于理解的示例，能让我们对并行程序做一些有趣的说明。

将任务分 配到不同线 程的最 直接方法是将序列划分成 t 个不相交的区域， 然后给 t 个不同的线程每个 分配一个区域。为了简单， 假设 n 是 t 的倍数， 这样每个 区域有 n / t 个元素。让我们来看看多个线程并行处理分配给它们的区域的不同方法。

最简单也最直接的选择是将线程的和放入一个共享全局变量中，用互斥锁保护这个变 量。图 12-31 给出了我们会如何实 现这种方法。在第 28 \~ 33 行， 主线程创建对等线程 ，然 后等待它们结束。注意 ， 主线程传递给每个对等线程一个小整数，作为唯一的线程ID。每个对等线程会用它的线 程 ID 来决定它应该计算序列的哪一部分。这个向对等线程传递一个小的唯一的线程1D 的思想是一项通用技术 ， 许多并行应用中都用到了它。在对等线程终止后， 全局变鼠 gs um 包含着最终的和。然后主线程用闭合形式解答来验证结果（第36\~ 37 行）。

code/condpsum-mutex.c

\#include "csapp.h"

2 \#define MAXTHREADS 32

4 void \*surn_rnutex(void \*vargp); I\* Thread routine \*I

6 I\* Global sha工ed va 工i abl e s \*I

1.  long gsurn = O; I\* Global sum \*I
2.  long nelerns_per_thread; I\* Number of elements to sum \*I

    9 sem_t rnutex; I\* Mutex to protect global sum \*I

    10

    11 int rnain(int argc, char \*\*argv)

    12 {

    1.  long i, nelems, log_nelems, nthreads, myid[MAXTHREADS];
    2.  pthread_t tid[MAXTHREADS];

        15

        16 I\* Get input arguments \*I

        图12-31 ps um- mut ex 的主程序， 使用多个线程将 一个序列元素的和放入一个用互斥锁保护的共享全局变扯中

| 17 |    | if (argc != 3) {                                             |
|----|----|--------------------------------------------------------------|
| 18 |    | printf("Usage: %s \<nthreads\> \<log_nelems\>\\n", argv[O]); |
| 19 |    | exit(O);                                                     |
| 20 |    | ｝                                                           |
| 21 |    | nthreads = atoi(argv[1]);                                    |
| 22 |    | log_nelems = atoi(argv[2]);                                  |
| 23 |    | nelems = (1L«log_nelems);                                    |
| 24 |    | nelems_per_thread = nelems / nthreads;                       |
| 25 |    | sem_init(&mutex, 0, 1);                                      |
| 26 |    |                                                              |
| 27 |    | I\* Create peer threads and wait for them to finish \*I      |
| 28 |    | for (i = O; i \< nthreads; i++) {                            |
| 29 |    | myid[i] = i;                                                 |
| 30 |    | Pthread_create(&tid[i], NULL, sum_mutex, \&myid[i]);         |
| 31 |    | ｝                                                           |
| 32 |    | for (i = O; i \< nthreads; i++)                              |
| 33 |    | Pthread_join(tid[i], NULL);                                  |
| 34 |    |                                                              |
| 35 |    | I\* Check final answer \*I                                   |
| 36 |    | if (gsum != (nelems \* (nelems-1))/2)                        |
| 37 |    | printf("Error: result=%ld\\n", gsum);                        |
| 38 |    |                                                              |
| 39 |    | exit(O);                                                     |
| 40 | ｝ |                                                              |
|    |    | code/condpsum-mutex.c                                        |
|    |    | 图 12-31 (续）                                               |

图 12-32 给出了每个对等线程执行的函数。在第 4 行 中 ，线 程 从 线 程 参 数 中 提取出线程 ID , 然后用这个 ID 来决定它要计算的序列区域（第5\~ 6 行）。在第 9 \~ 13 行中，线 程在它的那部分序列上迭代操作， 每次迭代都更新共享全局变量 g s um。 注 意 ， 我们很小心地用 P 和 V 互斥操作来保护每次更新。

code/condpsum-mutex.c

I\* Thread routine for psum-mutex.c \*I void \*sum_mutex(void \*vargp)

｛

long myid = \*((long \*)vargp); I\* Extract the thread ID \*I long start= myid \* nelems_per_thread; I\* Start element index \*I long end= start+ nelems_per_thread; I\* End element index \*I long i;

for (i = start; i \< end; i++) { P(&mutex);

gsum += i;

V(&mutex);

｝

return NULL;

code/condpsum-mutex.c

图 12-32 ps um- mu七e x 的线程例程。每个对 等线程将各 自的 和累加进一个用互斥锁保护的共享全局变量中

我们在一个四核系统上， 对一个大小为 n = 沪 的序列运行 p s um- mutex, 测量它的运行时间（以秒为单位），作为线程数的函数，得到的结果难懂又令人奇怪：

线程数

版本 16

ps um- mut e x I 68 432 I 719 I 552 I 599

程序单线程顺序运行时非常慢，几乎比多线程并行运行时慢了一个数量级。不仅如 此， 使用的核数越多 ，性 能越差。造成性能差的原因是相对于内存更新操作的开销，同 步操作( P 和 V ) 代价太大。这突显了并行编程的一项重要教训 ： 同 步 开销 巨 大，要 尽 可能 避免。如果无可避免 ， 必须要 用尽可能 多的有用计算 弥补这 个开销。

在我们的例子中，一种避免同步的方法是让每个对等线程在一个私有变量中计算它自 己的 部分和， 这个私有 变量不与其他任何线程共享， 如图 12-33 所示。主线程（图中未显示）定义一个全局 数组 p s u m, 每个对等线程 1 把它的部分和累积在 p s u m [ i ] 中。因为小 心地给了每个对等线程一个不同的内存位置来更新， 所以不需要用互斥锁来保护这些更新。唯一需要同步的地方是主线程必须等待所有的子线程完成。在对等线程结束后， 主线程把p s um 向 量的元素加起来， 得到最终的结果。

code/condpsum-array.c

I\* Thread routine for psum-array.c \*I

2 void \*sum_array(void \*vargp)

3 {

long myid = \*((long \*)vargp); I\* Extract the thread ID \*I

5 long start= myid \* nelems_per_thread; I\* Start element index \*I

6 long end= start+ nelems_per_thread; I\* End element index \*I

7 long i;

8

9 for (i = start; i \< end; i++) {

10 psum[myid] += i;

11 }

12 return NULL;

13 }

cod e/ cond ps um-array.c

图 12- 33 psum- ar r a y 的线程例程。每个对 等线程把它的 部分和

累积在一个私有数组元 素中 ， 不与其他任何 对等线程共享该元素

在四核系统上运行 p s u m- arr a y 时 ，我 们看到它比 p s um- mu t e x 运行得快好几个数量级：

版本

psum-mutex I 68.00

psum-array 7.26

432.00

3.64

线程数

4

719.00

1.91

552.00

1.85

16

599.00

1.84

在第 5 章中， 我们学 习到了如何使用局部变量来 消除不必要的内存引用。图 12-34 展示了如何应用这项原则，让每个对等线程把它的部分和累积在一个局部变量而不是全局变 量中。当在四核机器上运行 p s u m- l o c a l 时， 得到一组新 的递减的运行时 间：

|                 | 线程数 |        |        |        |        |
|-----------------|--------|--------|--------|--------|--------|
| 版本            | l      | 2      | 4      | 8      | 16     |
| psum-mutex      | 68.00  | 432.00 | 719.00 | 552.00 | 599.00 |
| psum-array      | 7.26   | 3.64   | 1.91   | 1.85   | 1.84   |
| ps um- l oc a l | 1.06   | 0.54   | 0.28   | 0.29   | 0.30   |

code/condpsum-local.c

I\* Thread routine for psum-local. c \*/

void•sum_local(void•vargp)

｛

long myid =•((long•)vargp); /• Extract the thread ID•I

long start= myid \* nelems_per_thread; I\* Start element index•/ long end= start+ nelems_per_thread; /• End element index•/

long i, sum= O; 。

for (i = start; i \< end; i++) { sum+= i;

｝

psum[myid] = sum; return NULL;

code/condpsum-local.c

图 1 2-34 ps um- l oca l 的 线程例程 。每个对等线 程把它的部分 和累积在一 个局部变昼中

从这个练习可以学习到一个重要的 经验， 那就是写并行程序相当棘手。对代码看上去很小的改动可能会对性能有极大的影响 。

刻画并行程序的性能

图 1 2-35 给 出 了图 12-34 中 程 序psum- l oca l 的运行时间，它 是线程数的函数。在每个 情况下， 程序运行在一个有四个处理器核的系统上，对一个n = 23 1 个元素的 序列求 和。我 们 看 到，随着线程数的增加，运行时间下降，直到增加到四个线程，此时，运行时间趋于平稳 ，甚 至开始有点 增加。

1.2

1.0

0.2

0 . 3

4 16

线程

在理想的情况中，我们会期望运行时间随着核数的增加线性下降。也就是说，

图 12-35 ps um- l o ca l 的 性 能（图 1 2-34) 。用四个处理器核对一个 沪 个元素序列求 和

我们会期望线程数每增加一倍 ， 运行时间 就下降一半。确实是这样， 直到到达 t\> 4 的时候， 此时四个核中的每一个都忙于运行 至少一个线程。随着线程数量的增加， 运行时间实际上增加了一点儿， 这是由于在一个核上多个线程上下文切换的开销 。由于这个原 因， 并行程序常常被写为每个核上只运行一个线程。

虽然绝对运行时间是衡 量程序性能的终极标 准， 但是还是有一些有用的相 对衡量标准能够说明并行 程序有多好地利用了潜在的并行性 。并行程序的加速比( s peed u p) 通常定义为

Sp= -T1

###### Tp

这里 p 是处理器核的数量， 吓 是在 K 个核上的运行时间。这个公式有时被称为 强扩展(strong scaling)。当 九是程序顺序执行版本的执行时间时， Sp 称为绝对加 速比 ( a bsol ute speed up) 。当 九是程序并 行版本在一个核上的执行时间时， Sp 称为相对加速比 ( re lat ive speed up) 。绝对加速比比相 对加速比能更真实地衡量并行的好处。即使是当并行程序在 一个处理器上运行时，也常常会受到同步开销的影响，而这些开销会人为地增加相对加速比的数值， 因为它们增 加了分子的大小。另一方面， 绝对加速比比相对加速比更难以测量， 因为测量绝对加 速比需要程序的 两种不同的 版本。对于复杂的并行代码， 创建一个独立的顺序版本可能不太实际，或者因为代码太复杂，或者因为源代码不可得。

一种相关的 测量量称为效 率( eff icie nc y) , 定义为

Ep Sp T1

###### p p T p

通常表示为范围 在( 0 , 1 0 0 ] 之间的百分比。效率是对由于并行化造成的开销的衡量。具 有高效率的程序比效率低的程序在有用的工作上花费更多的时间，在同步和通信上花费更少 的时间。

效率是因为我们的问题非常容易并行化。在实际中，很少会这样。数十年

图 12-36 图 12-35 中执行时间的加速比和并行效 率

来， 并行编程一直是一个很活跃的 研究领域。随着商用多核机器的出现， 这些机器的核数每几年就翻一番，并行编程会继续是一个深入、困难而活跃的研究领域。

． 加速比还有另外一面， 称为 弱扩展 ( w ea k scaling) , 在增加处理器数掀的同时， 增加问题的规模， 这样随着处理器数量的增加， 每个处理器执行的工作量保持不变。在这种描述中，加 速比和效率被表达为单 位时间 完成的工作总量。 例如， 如果 将处理器数量翻倍， 同时 每个小时也做了两倍的工作量， 那么我们就有线性 的加速比和 1 00 % 的效率。

弱扩展常常是比强扩展更真实的衡量值， 因为它更准确地反映 了我们用更大的机器做更多的工作的愿望。对于科学计算程序来说尤其如此，科学计算问题的规模很容易增加， 更大的问题规模直接就意味着更好地预测。不过， 还是有一些应用的规模不那么容易增加， 对于这样的 应用，强 扩展是更合适的。例如， 实时信号处 理应用所执行的工作量常常是由产生信号的物理传感器的属性决 定的。改变工 作总量需要用不同的物理传感器， 这不太实际或者不太必要。对于这类应用， 我们通常想要用并行来尽可能快地完成定量的工作。

练习题 12. 11 对于下表中的并行程序，填写空白处。假设使用强扩展。

| 线程 (t)        | 1    | 2   | 4   |
|-----------------|------|-----|-----|
| 核 (p )         | 1    | 2   | 4   |
| 运行时间 ( TP ) | 12   | 8   | 6   |
| 加速比 ( Sp )   |      | 1.5 |     |
| 效率 ( EP )     | 100% |     | 50% |

12\. 7 其他并发问题

你可能已经注意到了，一旦我们要求同步对共享数据的访问，那么事情就变得复杂得 多了。迄今为止，我 们已经看到了用千互斥和生产者－消费者同步的技术， 但 这仅仅是冰山一角。同步从根本上说是很难的问题， 它引 出 了 在普通的顺序程序中不会出现的问题。这一小节是关于你在写并发程序时需 要注意的一些问题的（非常不完整的）综述。为了让事情具体化，我们将以线程为例描述讨论。不过要记住，这些典型问题是任何类型的并发流 操作共享资源时都会出现的。

12\. 7. 1 线程安全

当用线程编写程序时， 必须 小 心 地编写那些具有称为线程安全性 ( t h read s afe t y ) 属性的函数。一个函数被称为线程安 全的 ( t h read- s a fe ) , 当且仅当被多个并发线程反复地调用时，它 会 一 直 产 生正确的结果。如果一个函数不是线程安全的， 我们就说它是线程不安 全的 ( t h rea d- un s a fe ) 。

我们能够定义出四个（不相交的）线程不安全函数类：

笫 1 类： 不保护共享 变量的函数。我们在图 12-1 6 的 吐r e a d 函数中就已经遇到了这样的问 题，该 函数 对 一 个 未受保护的全局计数器变量加 1。将这类线程不安全函数变成线程安全的，相对而言比较容易： 利用像 P 和 V 操作这样的同步操作来保护共享的变量。这个方法的优点是在调 用程序中不需要做任何修改。缺点是同步操作将减慢程序的执行时间。

笫 2 类 ：保 持跨越多 个调 用的状态的 函数。一个伪随机数生成器是这类线程不安全函

数的简单例子。请参考图 1 2-37 中的伪随机数生成器程序包。r a n d 函数是线程不安全的， 因 为 当前调用的结果依赖于前次调用的中间结果。当调用 sr a nd 为r a nd 设置了一个种子后， 我们从一个单线程中反复地调用 r a nd , 能够预期得到一个可重复的随机数字序列。然而， 如果 多 线 程调用r a n d 函数 ， 这种假设就不再成立了。

code/cond rand.c

unsigned next_seed = 1;

3 I\* rand - return pseudorandom integer in the range 0.. 32767 \*I

4 unsigned rand(void)

6 next_seed = next_seed\*1103515245 + 12543;

7 return (unsigned)(next_seed»16) % 32768;

10 I\* srand - set the initial seed for rand() \*I

11 void srand(unsigned new_seed)

12 {

13 next_seed = new_seed;

14 }

code/condrand.c

图 12-37 一个线程不安全的伪随机数生成器（基于 [ 61] )

使得像r a n d 这样的函数线程安全的唯一方式是重写它，使 得 它 不再使用任何 s 七a t i c

数据，而是依靠调用者在参数中传递状态信息。这样做的缺点是，程序员现在还要被迫修

改调用程序中的代码。在一个大的程序中，可能有成百上千个不同的调用位置，做这样的修改将是非常麻烦的，而且容易出错。

笫 3 类： 返回指向静 态 变 量的 指针的 函数。某些函数， 例如 c t i me 和 g e t h o s 亡

byname, 将计算结果放在一个 s ta tic 变量中，然 后返回一个指向这个变量的指针。如果我们从并发线程中调用这些函数，那么将可能发生灾难，因为正在被一个线程使用的结果会被另一个线程悄悄地覆盖了。

有两种方法来处理这类线程不安全函数。一种选择是重写函数，使得调用者传递存放结 果的变量的地址。这就消除了所有共享数据， 但是它要求程序员能够修改函数的源代码。

如果线程不安全函数是难以修改或不可能修改的（例如，代码非常复杂或是没有源代 码可用）， 那么另外一种选择就是使用加锁－复制( lock-a n d- co p y ) 技术。基本思想是将线程不安全函数与互斥锁联系起来。在每一个涸用位置，对互斥锁加锁，调用线程不安全函 数，将函数返回的结果复制到一个私有的内存位置，然后对互斥锁解锁。为了尽可能地减 少对调用者的修改，你应该定义一个线程安全的包装函数，它执行加锁－复制，然后通过 调用这个包装函数来取代所有对线程不安全函数的调用。例如， 图 12-38 给出了 c 巨 me 的一个线程安全的版本，利用的就是加锁－复制技术。

code/condctime-ts.c

char \*ctime_ts(const time_t \*timep, char \*privatep)

2 {

3 char \*sharedp;

4

5 P(&mutex);

6 sharedp = ctime(timep);

7 strcpy(privatep, sharedp); I\* Copy string from sha 工 ed to private \*I

8 V(&mutex);

9 return privatep;

10 }

code/condctime-ts.c

图 12-38 C 标准库函数 c t i me 的线程安全的包装函数。使用加锁－复制技术调用一个第3 类线程不安全函数

笫 4 类： 调用线程 不安 全函数的 函数。如果 函数 f 调用线程不安全函数 g , 那么 f 就是线程不安全的吗？ 不一定。如果 g 是第 2 类函数， 即依赖于跨越多次 调用的 状态， 那么

J 也是线程不安全的， 而且除了重写 g 以外， 没有什么办法。然而， 如果 g 是第 1 类或者

第 3 类函数， 那么只要你用一 个互斥锁保护调用位置和任何 得到的共享数据， J 仍 然可能是线程安全的。在图 1 2-38 中我们看到了一个这种情况很好的示例， 其中我们使用加锁－ 复制编写了一 个线程安全函数，它 调用了一个线程不安全的函数。

所有的函数

1.  7\. 2 可重入性

    有一类重要的线程安全函数，叫做可重入函数( ree n t ra nt function) , 其特点在于它们具有这样一种属性：当它们被多个线程调用时，不会引用任何共享数据。尽管线程安全和可重入有时会

线程安全函数

三 线程不安全函数

（不正确地）被用做同义词，但是它们之间还是有 图 12-39 可重入函数、线程安全函数和线程

清晰的技术 差别， 值得留意。图 12-39 展示了可 不安全函数之间的集合关系

重入函数、线程安全函数和线程不安全函数之间的集合关系。所有函数的集合被划分成不 相交的线程安全和线程不安全函数集合。可重入函数集合是线程安全函数的一个真子集。 可重入函数通常要比不可重入的线程安全的函数高效一些，因为它们不需要同步操

作。更进一步来说，将 第 2 类线程不安全函数转化为线程安全函数的唯一方法就是重写它，使 之 变为可重入的。例如，图 1 2- 40 展 示了图 1 2-37 中 r a nd 函数的一个可重入的版本。关键思想是我们用一个调用者传递进来的指针取代了静态的 ne x t 变量。

code/condrand-r.c I\* rand_r - return a pseudorandom integer on 0 .. 32767 \*I

int rand_r(unsigned int \*nextp)

｛

\*nextp = \*nextp \* 1103515245 + 12345;

return (unsigned int)(\*nextp / 65536) % 32768;

｝

codelcondrand-r.c

图 12-40 rand_r: 图 12-37 中的 r a nd 函数的可重入版本

检查某个函数的代码并先验地断定它是可重入的，这可能吗？不幸的是，不一定能这 样。如果所有的函数参数都是传值传递的（即没有指针），并且所有的数据引用都是本地的 自动栈变量（即没有引用静态或全局变量），那么函数就是显式 可 重入的 ( ex plicitl y reen­

trant), 也就是说，无论它是被如何调用的，都可以断言它是可重入的。

然而， 如果把假设放宽松一点 ，允 许显式可重入函数中一些参数是引用传递的（即允许它们传递指针），那 么 我们就得到了一个隐式可重入的 ( im plicitl y ree nt ra n t ) 函数，也 就是说，如果调用线程小心地传递指向非共享数据的指针，那么它是可重入的。例如，图 1 2-40 中的r a nd_r 函数就是隐式可重入的。

我们总是使用术语 可重入的 ( ree nt ra nt ) 既包括显式可重入函数也包括隐式可重入函数。然而，认 识 到 可重入性有时既是调用者也是被调用者的属性，并 不 只 是 被询用者单独的属性是非常重要的。

练习题 12 . 12 图 12-38 中的 ct ime_t s 函数是线程安全的，但不是可重入的。请解释说明。

1 2 . 7. 3 在线程化的程序中使用已存在的库函数

大多数 Lin u x 函数，包 括定义在标准 C 库中的函数（例如 ma l l o c 、 fr e e 、r e a l l o c 、

pr i n t f 和 s c a n f ) 都 是 线 程 安 全的，只 有一小部分是例外。图 1 2-41 列出了常见的例外。

（参考[ 110] 可以得到一个完整的列表。）s tr t o k 函数是一个已弃用的（不推荐使用）函数。 a s c t i me 、 c t i me 和 l oc a l t i me 函数 是 在 不同时间和数据格式间相互来回转换时经常使用的函数。ge t ho s t b yna me 、 g e t h o s t b ya d dr 和 i ne t \_ n t oa 函数是已弃用的网络编程函数，已 经分别被可重入的 ge t a ddr i n f o 、ge t na me i n f o 和 i ne t \_ nt o p 函数取代（见第 11 章）。除了 r a nd 和 s tr t o k 以外 ，所 有这些线程不安全函数都是第 3 类的，它 们 返 回 一 个 指向静态变量的指针。如果我们需要在一个线程化的程序中调用这些函数中的某一个，对 调用者来说最不惹麻烦的方法是加锁－复制。然而，加锁－复制方法有许多缺点。首先，额 外的同步降低了程序的速度。第二，像 g e t h o s t b yn a me 这样的函数返回指向复杂结构的结构的指针，要 复 制 整个结构层次，需 要 深层复制 ( dee p copy) 结构。第三，加 锁－复 制方法对像r a nd 这样依赖跨越调用的静态状态的第 2 类函数并不有效。

线程不安全函数 线程不安全类 Linux 线程安全版本

rand strtok asctime ctime

gethostbyaddr gethostbyname inet_ntoa localtime

rand_r strtok_r asctime_r ctime_r

gethostbyaddr_r gethostbyname_r

（无）

localtime_r

图12-4 1 常见的线程不安全的库函数

因此， L in u x 系统提供大多数线程不安全函数的可重入版本。可重入版本的名字总是以" r " 后缀结尾。例如， a s c 巨 me 的可重 入版本就叫做 a s c 巨 me \_r 。我 们建议尽可能地使用这些函数。

##### 12. 7. 4 竞争

当一个程序的正确性依赖于一个线程要在另一个线程到y达点之前到达它的控制流中的x 点时， 就会发生竞争( ra ce) 。通常发生竞争是因为程序员假定线程将按照某种特殊的轨迹线穿过执行状态空间， 而忘记了另一条准则规定：多 线程的程序必须对任何可行的轨迹线都正确工。作

例子是理解竞争本质的最简单的方法。让我们来 看看图 12-42 中的简单程序。主线程创建了四个对等线程， 并传递一个指向一个唯一的整数 ID 的指针到每个 线程。每个 对等线程复制它的参数中传递的 ID 到一个局部变量中（第22 行）， 然后输出一个包含这个 ID 的信息。它看上去足够简单，但是当我们在系统上运行这个程序时，我们得到以下不正确的结果：

linux\> ./race

Hello from thread 1 Hello from thread 3 Hello from thread 2 Hello from thread 3

code/condrace.c

I\* WARNING: This code is buggy! ＊／

\#include "csapp.h"

\#define N 4

void \*thread(void \*vargp); int main()

｛

pthread_t tid[N]; int i;

for (i = O; i \< N; i++) Pthread_create(&tid[i],

for (i = O; i \< N; i++)

NULL, thread, \&i);

Pthread_join(tid[i], exit(O);

NULL);

图 1 2-42 一个具有竞争的程序

18

1.  I\* Thread routine \*I
    1.  void \*thread(void \*vargp)

        21 ｛

2.  int myid = \*((int \*)vargp);
3.  printf("Hello from thread %d\\n", myid);
4.  return NULL;

    25 ｝

code/condrace.c

图 12- 42 （续）

问 题 是由每个对等线程和主线程之间的竞争引起的。你能发现这个竞争吗？ 下面是发生的 情况 。当主线程在第 1 3 行创建了一个对等线程，它 传递了一个指向本地栈变量 t 的指针。在此时，竞 争 出现在下一次在第 1 2 行对 1 加 1 和第 22 行参数的间接引用和赋值之间。如果对等线程在主线程执 行第 1 2 行对 t 加 1 之前就执行了第 22 行， 那么 my i d 变量就得到正确的 ID。否则，它 包含的就会是其他线程的 ID。令人惊慌的是， 我们是否得到正确的答案依赖千内核是如何调度线程 的执行的。在我们的 系统中它失败了 ， 但是在其他系统中，它可 能就能正确工作 ， 让程序员“幸福地” 察觉 不到程序的严重错误。

为了消除竞争，我 们可以动态地为每个整数 ID 分配一个独立的块， 并且传递给线程例程一个指向这个块的指针， 如图 1 2- 43 所示（第1 2 1 4 行）。请注意 线程例程必须释放这些块以避免内存泄漏。

code/condnorace.c

\#include "csapp.h"

\#define N 4

void \*thread(void \*vargp); int main()

｛

pthread_t tid[N]; inti, \*ptr;

for (i = O; i \< N; i++) {

ptr = Malloc(sizeof(int));

\*ptr = i;

Pthread_create(&tid[i],

｝

NULL, thread, ptr);

for (i = O; i \< N; i++) Pthread_join(tid[i],

exit(O);

NULL);

I\* Thread routine \*I

void \*thread(void \*vargp)

｛

int myid = \* ((int \*)vargp) ; Free (vargp) ;

printf("Hello from thread %d\\n", myid); return NULL;

｝

code/condnorace.c

图 12 -43 图 12-42 中程序的一个没有竞争的正确版本

当我们在系统上运行这个程序时，现在得到了正确的结果：

linux\> ./norace Hello from thread 0 Hello from thread 1 Hello from thread 2 Hello from thread 3

练习题 12. 13 在图 12-43 中， 我们可能想 要在 主线程中的 第 1 4 行后立即 释放 巳分 配的内存块，而不是在对等线程中释放它。但是这会是个坏注意。为什么？

练习题 12. 14

1.  在图 12-43 中， 我们 通过 为每 个整数 ID 分配 一个 独 立的 块来消除竟争。 给出 一个不调用 ma l l o c 或者 f r e e 函数的不 同的 方 法。
2.  这种方法的利弊是什么？

12\. 7. 5 死锁

信号量引 入了一种 潜在的令人厌恶的运行时错误， 叫做死锁 ( d eadlock ) , 它指的是一组线程被阻塞了，等待一个永远也不会为真的条件。进度图对于理解死锁是一个无价的工 具。例如，图 1 2-44 展示了一对用两个信号晕来实现互斥的线程的进程图。从 这幅图中， 我们能够得到一些关于死锁的重要知识：

![](img/268364c4dd3b97f0c27857ff02797a3b.jpeg)线程2

V(s)

V(t)

P(s)

死锁区

# ![](img/01c11eb8a9ab4d7f84a33d5078a24e2b.jpeg)勹"

P(s)···P(t)··· V(s) · · ·V(t)

图12-44 一个会死锁的程序的进度图

线程1

-   程序员使用 P 和 V 操作顺序不当， 以至于两个 信号量的禁止区域 重叠。如果某个执行轨迹线碰巧到达了死锁状态 d , 那么就不可能有进一步的进展了，因为重叠的禁止区域阻塞了每个合法方向上的进展。换句话说，程序死锁是因为每个线程都在等 待其他线程执行一个根不可能发 生的 V 操作。
-   重叠的禁止区域引起了一组称为死锁区域 ( d ead lo ck r eg io n ) 的状态。如果一个轨迹线碰巧到达了一个死锁区域中的状态，那么死锁就是不可避免的了。轨迹线可以进 入死锁区域，但是它们不可能离开。
-   死锁是一个相当困难的问题，因为它不总是可预测的。一些幸运的执行轨迹线将绕开死 锁区域，而其他的 将会陷入 这个区域。图 12-44展示了每种情况的一个示例。对于程序员来说， 这其中隐含的着实令人惊慌。你可以运行一个程序 1000 次不出任何问题，但是下一次它就死锁了。或者程序在一台机器上可能运行得很好，但 是 在另外 的 机 器 上就会死锁。最糟糕的是，错误常常是不可重复的，因为不同的执行有不同的轨迹线。

    程序死锁有很多原因，要避免死锁一般而言是很困难的。然而，当使用二元信号量来 实现互斥时 ，如 图 1 2- 44 所示，你 可以应用下面的简单而有效的规则来避免死锁：

    互斥锁加锁顺序规则： 给 定所有互斥操作的一个全序 ，如 果 每 个线程都是以一种顺序荻得互斥锁并以相反的顺序释放，那么这个程序就是无死锁的。

    例如， 我们可以通过这样的方法来解决图 12-44 中的死锁问题： 在 每个线程中先对 s

    加锁 ，然 后 再 对 t 加锁。图 12-45 展示了得到的进度图。

    线程2

![](img/0945ce788e0c2f17402b2375ad5c76a4.png)V(s)

V(t)

P(t)

# 勹, ,

· · · P (s) · ··P(t)··· V(s) · · ·V(t)

图 12 -45 一个无死锁程 序的进度图

线程1

心 练习题 12 . 15 思考下面的程序，它试图使用一对信号量来实现互斥。

| 初始时：  线程1: P(s); | s | = | 1, | t = 0 .  线程2: P(s); |
|------------------------|---|---|----|-----------------------|
| V(s);                  |   |   |    | V(s);                 |
| P(t); V(t);            |   |   |    | P(t); V(t);           |

1.  画出这个程序的进度图。
    1.  它总是会死锁吗？
    2.  如果是，那么对初始信号量的值做哪些简单的改变就能消除这种潜在的死锁呢？
    3.  画 出 得到 的无死锁程 序的进度图。

12\. 8 小结

一个并发程序是由在时间上重叠的一组逻辑流组成的。在这 一章中， 我们学习了三种不同的构建并发程序的机制 ： 进程、1/ 0 多路复用和线程。我们以一个并发网络服务器作为贯穿全章的应用程序。

进程是由内核自动调度的，而且因为它们有各自独立的虚拟地址空间，所以要实现共享数据，必须 要有显式的 IPC 机制。事件驱动程 序创建它们自己的并发逻辑流， 这些逻辑流被模型化为状态机，用1/ 0 多路复用来显式 地调度这些 流。因 为程 序运行 在一个单一进程中 ， 所以在流之间 共享数据速度很快 而且很容易。线程是这些方法的混合 。同基千进程的 流一样， 线程也是由内 核自动调度的。同基千 I/ 0 多路复用的流一样 ， 线程是运行 在一个单一进程的上下 文中的 ，因 此可以快速而方便地共 享数据 。

无论哪种并发机制 ，同 步对共享数据的并 发访问 都是一个困难的问 题。提出对信号 量的 P 和 V 操作就是为了帮助解决这个问题。信号量操作可以用来提供对共享数据的互斥访问，也对诸如生产者－消费者 程序中有限缓 冲区和读者－写者系统中的共享对象这样的资源访 间进行调度。一个并发预线程化的 echo 服务器提供了信号 量使用场景的很好的例子。

并发也引入了其他一些困难的问题。被线程调用的 函数必须具有一种称为线 程安 全的属性。我们定义了四类线程不安全的函数，以及一些将它们变为线程安全的建议。可重入函数是线程安全函数的一个 真子集，它不访问任何共享数据。可重入函数通常比不可重入函数更为有效，因为它们不需要任何同步 原语。竞争和死锁是并发 程序中出 现的另一些 困难的间题。当程序员错误地假设逻辑流该 如何 调度时 ， 就会发生竞争。当一个流等待一个永远不会发生的事件时，就会产生死锁。

#### 参考文献说明

信号蜇操作是 D咄s t ra 提出的 [ 31] 。进度图的概念是 Coff ma n [ 23] 提出的， 后来由 Ca rso n 和 R e yn­ olds [ 16] 形式化的 。Co ur tois 等人[ 25] 提出了读者－写者问题。操作系统教科 书更详 细地 描述了经典的同步问题， 例如哲学家进餐问 题、打睦睡的理发师问 题和吸烟者问 题 [ 102 , 106, 113] 。Buten hof 的书[ 15] 对 P o six 线程接口有全 面的描述。Birrell [ 7] 的论文对线程编程以 及线程编程中容易遇到的问 题做了很好的介绍。 R einde rs 的书[ 90] 描述了 C I C + + 库，简化了线 程化程序的设 计和实现。有一些 课本讲述了多核系统上并行编程的 基础知识 [ 47 , 71] 。P ug h 描述了 Ja va 线程通过内存进行交互的方式的缺陷，并提出了替代的内存模型 [ 88 ] 。G us tafso n 提出了替代强扩展的 弱扩展加速模型 [ 43] 。

#### 家庭作业

-   12 16 编写 he ll o . c ( 图 12-13 ) 的一个版本， 它创建和回收 n 个可结 合的对等线程，其 中 n 是一个命令行参数。
-   12 17 A. 图 12-46 中的程序有一个 b ug 。要求线程睡眠一秒钟 ， 然后输出一 个字符串。然而 ， 当在 我们

    的系统上运行它时 ，却 没有任何输 出。为什么？

/• WA 邸 I NG: This code is bu 邸 ;y! •/

1.  \#include "csapp.h"
    1.  void•thread(void•vargp);

        4

        5 int main()

        6 {

        7 pthread_t tid;

        8

        9 Pthread_create(&tid, NULL, thread, NULL);

        10 exit(O);

        11 }

        12

2.  /• Thread routine•/
3.  void•thread(void•vargp)

    15 {

4.  Sleep(1);
5.  printf("Hello, world!\\n");
6.  return NULL;

    19 }

    code/condhellobug.c

codelconclhellobug.c

图 12-46 练习题 12. 17 的有 bug 的程序

B. 你可以通过用两个 不同的 P th reads 函数调 用中的一个替代第 10 行中的 e x 让 函数来 改正这个错误。选哪一个呢？

-   12\. 18 用图 1 2-21 中的进度图， 将下面的 轨迹线分类 为安全或者不安全的。

    A. H2 , L2 , U2 , H, , L1 , S2 , U 1 , S, , T1 , T2

    B. H 2 , H1, L1 , U, , S1 , L 2, T, , U2, S 2 , T2

    C. H1 , L1 , H 2 , L2, U2, S2, U, , S , , T1 , T2

    •• 12 . 19 图 1 2- 2 6 中第一类读 者－写者问题的解答 给予 读者的是有些弱的优先级， 因为读者在离开它的临界区时，可能会重启一个正在等待的写者，而不是一个正在等待的读者。推导出一个解答，它给 予读者更强的优先级，当写者离开它的临界区的时候，如果有读者正在等待的话，就总是重启一 个正在等待的读者。

    \\\* 12. 20 考虑读者－写者问题的一个更简单的变种 ，即 最多只有 N 个读者。推导 出一个解答 ，给 予读者和

    写者同等的优先级，即等待中的读者和写者被赋予对资源访问的同等的机会。提示：你可以用一个计数信号蜇和一个互斥锁来解决这个问 题。

    :: 12. 21 推导出第二类读者－写者问题的一个解答，在此写者的优先级高于读者。

    •• 12. 22 检查一下你对 s e l e吐 函数的理 解，请 修改图 12-6 中的服务器， 使得它在主服务 器的每次迭代中最多只回送一个文本行。

    •• 12. 23 图 1 2-8 中的事件驱动并 发 echo 服务器是 有缺陷的 ， 因为一个恶意的 客户端能够通过发送部分的文本行，使服务器拒绝为其他客户端服务。编写一个改进的服务器版本，使之能够非阻塞地处理 这些部分文本行。

    -   12\. 24 RIO I/ 0 包中的 函数(1 0. 5 节）都是线程安全的 。它们也都是可重入函数吗？
    -   12\. 25 在图 1 2-28 中的预线程化的并发 echo 服务器中， 每个线程都调用 e c ho \_ c nt 函数（图12-29 ) 。e c ho_c n t 是线程安全的吗？ 它是可重人的吗？为什么是或 为什么不是呢？

        \*/ 12. 26 用加锁－复制技术来实现 g e t ho s t b yna me 的 一个线程安全而又不 可重入 的版本， 称为 ge t hos t -

        b yna me \_ t s 。一个正确的解答是使用由互斥 锁保护的 ho s t e nt 结构的深层副本 。

        • • 12. 27 一些网络编程的教科书建议用以下的方法来读 和写套接字 ： 和客户端交互之前 ， 在同一个打开的已连接套 接字描述符上 ，打开两个标 准 I/ 0 流， 一个用来读， 一个用来写 ：

        FILE•fpin, •fpout;

fpin = fdopen(sockfd, "r");

fpout = fdopen(sockfd, "w");

当服务器完成和客户端的交互之后，像下面这样关闭两个流：

fclose(fpin); fclose(fpout);

然而，如果你试图在基千线程的并发服务器上尝试这种方式，将制造一个致命的竞争条件。请解释。

-   12 28 在图 12-45 中，将 两个 V 操作的顺序交换 ， 对程序死锁是否 有影响？ 通过画出四 种可能情况的 进度图来证明你的答案：

| 情况        | l         | 情况      | 2         | 情况       | 3          | 情况      | 4         |
|-------------|-----------|-----------|-----------|------------|------------|-----------|-----------|
| 线程 l      | 线程2     | 线程 1    | 线程2     | 线程 l     | 线程2      | 线程 l    | 线程2     |
| P (s ) P(t) | P(s) P(t) | P(s) P(t) | P(s) P(t) | P(s) P(t ) | P(s) P(t ) | P(s) P(t) | P(s) P(t) |
| V(s)        | V(s)      | V(s)      | V(t)      | V(t)       | V(s)       | V(t)      | V(t)      |
| V(t)        | V(t)      | V(t)      | V(s)      | V(s)       | V(t)       | V(s)      | V(s)      |

-   12\. 29 下面的程序会死锁吗？为什么会或者为什么不会？

初始时： a= 1, b = 1, c = 1

线程1 : 线程2 :

P(a); P(c);

P(b); P(b);

V(b); V(b);

P(c); V(c);

V(c);

V(a);

-   12\. 30 考虑下面这个会死锁的程序。

    初始时： a= 1, b = 1, c = 1

线程1 : 线程2: 线程3:

P(a); P(c); P(c);

P(b); P(b); V(c);

V(b); V(b); P(b);

P(c); V(c); P(a);

V(c); P(a); V(a);

V(a); V(a); V(b);

1.  列出每个线程同时占用的一对互斥锁。
2.  如果 a \< b\< c , 那么哪个线程违背了互斥锁加锁顺序规则？
3.  对于这些线程，指出一个新的保证不会发生死锁的加锁顺序。

    \*.\* 12. 31 实现标准 I/ 0 函数 f ge t s 的一个版本，叫 做 t f ge t s , 假如它在 5 秒之内 没有从标 准输入 上接收到一个输入行，那么就超时，并返回 一个 NU LL 指针。你的函数应该实现在一个叫做 t f ge t s - pr oc . c 的包中，使用 进程、信号和非本地跳转 。它不应该使用 Linux 的 a l a rm 函数。使用图 12-47 中的驱动程序测试你的结果。

1 \#include "csapp.h"

2

3 char \*tfgets (char \*s, int size, FILE \*stream);

4

5 int main()

6 {

7 char buf [MAXLINE] ;

8

9 if (tfgets(buf, MAXLINE, stdin) == NULL)

10 printf("BOOM!\\n");

11 else

12 printf("o/.s", buf);

13

14 exit(O);

15 }

codelcond tfgets-main.c

code/contfdgets-main.c

图 12-47 家庭作业题 12. 31\~12. 33 的驱动程序

\*.\* 12. 32 使用 s e l e c t 函数来实现练习题 12. 31 中 t f ge t s 函数的一个版本。你的 函数应该在一个叫做 t f ­ ge t s -s e l e c t . c 的包中实现。用练习题 12. 31 中的驱 动程序测试你的结果 。你可以假定标准输人被赋值为描述符 0。

·.· 12. 33 实现练习 题 12. 31 中 t f ge t s 函数的一个线程化的版本。你的函数应该在一个叫做 t f ge t s ­ t hr e a d . c 的包中实现。用练习题 12. 31 中的驱动程序测试你的结果。

·: 12. 34 编写一个 N X M 矩阵乘法核心函数的并行线程化版本。比较它的性能 与顺序的版本的性能。

·: 12. 35 实现一个基于进程的 T I NY Web 服务器的并发版本 。你的解答应该为每一个新的 连接请求创建一个新的子进程。使用一 个实际的 Web 浏览器来测试你的 解答。

-   : 12. 36 实现一个基于 l/ 0 多路复用的 T IN Y Web 服务器的并 发版本。使用一个实际的 Web 浏览器来测试你的解答。

\*\* 12. 37 实现一个基于线程的 T INY Web 服务器的并发版本 。你的解答 应该为 每一个新的连接请求创建 一个新的线 程。使用一 个实际的 Web 浏览器来 测试你的 解答 。

: : 12. 38 实现一个 T INY Web 服务器的并发预线 程化的 版本。你的解答应该 根据当前的 负载， 动态地增加或减少线 程的数目 。一个策略是当缓 冲区变满时 ， 将线程数晟 翻倍 ， 而当缓 冲区 变为空 时， 将线程数目 减半。使用一 个实际的 Web 浏览器来 测试你的 解答 。

:: 12. 39 Web 代理是 一个在 Web 服务器和浏览 器之间 扮演中间角色 的程序。浏 览器不是直接连接服务器以获取 网页， 而是与代理连接 ， 代理再将请求转发给服务器。当服 务器响 应代理 时， 代理将响应发送给浏览器。为了这个试验 ， 请你编写一个简单的可以过滤和记 录请求 的 Web 代理：

1.  试验的第一部分中 ， 你要建立以接收请求的代理， 分析 HT T P , 转发请求给服务 器， 并且返回结果给浏览 器。你的代理将所有请求 的 URL 记录在磁盘上 一个日志文件中 ，同时它还要阻塞所有对包含 在磁盘上一 个过滤文件 中的 URL 的请求。
    1.  试验的第二部分中， 你要升级代理 ， 它通过派生一个独立的线程来处理每一个请求， 使得 代理能够一次处理多个打开的连接。当你的代理在等待远程服务器响应一个请求使它能服务于 一个浏览器时，它应该可以处理来自另一个浏览器未完成的请求。

        使用一个 实际的 Web 浏览骈来 检验你的 解答。

练习题答案

12\. 1 当父进 程派生子 进程时 ，它 得到一个已连接描 述符的副本， 并将相关文件 表中的引用计数从 1 增加到 2。当父进程关闭 它的描述符 副本时 ，引 用 计数就从 2 减少到 1。因为内 核不会关闭一个文件， 直到文件表中它的引用计数值 变为零 ， 所以子进程这边的 连接端将保持 打开。

12\. 2 当一个 进程因为某种原因终止时 ，内 核 将关闭所有打开的 描述符。因此， 当子进 程退出时， 它的已连接文件描述符的副本也将被自动关闭。

12\. 3 回想一下， 如果一个从描述符中读 一个字节的请求不 会阻塞， 那么这个描述符 就准备好 可以读 了。

假如 EOF 在一个描述符上为 真， 那么描述符也 准备好可读了 ， 因为读操作将立 即返回一个零返回码，表示 EOF。因此，键入 Ctrl+ D 会导致 s e l e c t 函数返回， 准备好的 集合中有描述符 0。

12\. 4 因为变最 poo l . r e ad\_ s e t 既作为输入参数 也作为输出 参数， 所以 我们在每一次调用 s e l e c t 之前都重新初始化它。在输入时 ， 它包含读集合 。在输出 ， 它包含准备好的 集合。

12\. 5 因为线程运行在同一个进程中 ， 它们都共享相同 的描述符表。无论有多少线程使用这个已 连接描述符， 这个已 连接描述符的 文件表的引 用计数都等于 1。因此， 当我们用完它时， 一个 c l os e 操作就足以 释放与这个已 连接描述符 相关的内存资源了。

1.  6 这里的 主要的思 想是， 栈变址是私有的 ， 而全局和静态变扯是共享的。诸如 c nt 这样的 静态变量有点小麻烦， 因为共享是限制 在它们的函数范围内的一—召：这个例子中， 就是线程例程 。
    1.  下面就是 这张表 ：

| 变量实例    | 被主线程引用？ | 被对等线程0引用？ | 被对等线程1引用？ |
|-------------|----------------|-------------------|-------------------|
| ptr         |  定曰          |  定曰             |  定曰             |
| cnt         | 否             |  定曰             |  定曰             |
| i . m       |  定曰          | 否                | 否                |
| ms g s . m  | 是             | 是                | 定El              |
| myid.pO     | 否             | 是                | 否                |
| myi d . p l | 否             | 否                | 是                |

说明：

-   p tr : 一个被主线程写 和被对等线程读的 全局变谜。
    -   c nt : 一个静态变储， 在内存中只有一个实例 ，被 两个对等线程读和写。
        -   i.m: 一个存储在主线程栈中的本 地自动变 釐。虽然它的 值被传递给对等线程，但 是对等线程也绝 不会在栈中引用它 ， 因此它不是 共享的。
-   msgs . m: 一个存储在 主线程栈中的 本地自动变量 ， 被两个对等线 程通过 p tr 间接地引用 。
-   myid. 0 和 my 过 . 1 : 一个本地自 动变量的实 例， 分别驻留在对等线 程 0 和线程 1 的栈中。
    1.  变量 ptr 、c nt 和 ms g s 被多于一个线程引用， 因此它们是 共享的。

        12\. 7 这里的重要思想是，你不能假设当内核调度你的线程时会如何选择顺序。

变量 c nt 最终有一 个不正确的 值 1。

12\. 8 这道题简单地测试你 对进度图中安全和不安 全轨迹线的理解。像 A 和 C 这样的轨迹线绕开了临界区，是安全的，会产生正确的结果。

A. H1, L1, U1 , S1, H , , L,, U , , S,, T,, Ti : 安 全 的

B. H, , L, , H1 , L1 , U1 , S1 , Ti , U, , S, , T, : 不 安 全 的

C. H, , H,, L, , U,, S,, Li , Ui, S 1 , T1 , T,: 安全的

12\. 9 A.p=l, c=l, n\> l : 是，互斥锁是需要的，因为生产者和消费者会并发地访间缓冲区。

1.  p=l, c = l , n=l, 不是， 在这种情况中 不需要互斥锁 信号量 ， 因为一个非空的缓 冲区就等千满的缓冲区。当缓冲区包含一个项目时，生产者就被阻塞了。当缓冲区为空时，消费者就被阻 塞了。所以 在任意时刻 ，只 有一个线 程可以访间缓 冲区 ， 因此不用互斥锁也能保证互斥 。
2.  p\>l, c\>l, n=l: 不是， 在这种情况中 ， 也不需要互斥锁 ，原因 与前面一种情况相同。

    12 10 假设一个特殊的 信号量实现为每一 个信号 量使用了 一个 LI FO 的线 程栈。当一个线程在 P 操作中阻塞在一个信号蜇 上，它的 ID 就被压入栈中 。类似地， V 操作从栈中弹出栈顶的线程 ID, 并重启这个线程。根据这个栈的实现，一个在它的临界区中的竞争的写者会简单地等待，直到在它释 放这个信号量之前另一个写 者阻塞 在这个信号 量上。在这种场景中， 当两个写者来回地传递控制权时， 正在等待的读者可能会永远地等待下去。

    注意， 虽然用 FIF O 队列而不是用 LIFO 更符合直觉 ， 但是使用 LIFO 的栈也 是对的， 而且也没有违反 P 和 V 操作的语义。

    12\. 11 这道题简单地检查你对加速比和并行效率的理解：

| 线程( t )      | I    | 2   | 4   |
|----------------|------|-----|-----|
| 核 (p )        | I    | 2   | 4   |
| 运行时间( T,,) | 12   | 8   | 6   |
| 加速比CSP )    | I    | 1.5 | 2   |
| 效率\<EP )     | 100% | 75% | 50% |

12 . 12 ct i me—t s 函数不是可重入函数， 因为每次调用都共享相同的由 get hos tb yname 函数返回的 s t at i c 变量。然而， 它是线程安全的，因 为对共享变扯的访问是被 P 和 V 操作保护的， 因此是互斥的。

12\. 13 如果在第 14 行调用了 p 七hr e a d \_cr e a t e 之后， 我们立即释放块， 那么将引入一个新的竞争， 这次竞争发 生在主线程对 fr e e 的调用 和线程例程中第 24 行的赋值语句之间。

12\. 14 A. 另一种方法是直接传递整数 i , 而不是传递一 个指向 1 的指针：

for Ci = 0; i \< N; i++)

Pthread_create(&tid[i], NULL, thread, (void•)i);

在线程例程中 ，我们将参数强 制转换成一个 i nt 类型， 并将它赋值给 rnyi d : int myid = (int) vargp;

B. 优点是它通过消除对 ma l l o c 和 fr e e 的 调用降低了开销。一个明显的缺点是， 它假设指针至少和 i n t 一样大。即便 这种假设 对于所有的 现代系统来说都为真， 但是它对千那 些过去遗留下来的或今后的系统来说可能就不为真了。

12\. 15 A. 原始的程序的 进度图如图 12-48 所示。

线程2

V(t)

P(t)

V(s)

勹(,)

t 的 禁止区

三 t 的禁止区

· · · P(s) .. ·V(s) ..·P(t) ..·V(t)

图 12- 48 一个有死锁的程序的进度图

线程1

1.  因为任何可行的轨迹最终都陷入死锁状态中，所以这个程序总是会死锁。
2.  为了消除 潜在的死锁， 将二元信号蜇 t 初始化为 1 而不是 0。
3.  改成后的程序的进度图 如图 12-49 所示。线程2

V(t) 三

P(t)

V(s) 三

勹"'

· · ·P(s)··· V(s) · · · P(t) · · ·V(t)

图 12- 49 改正后的无死锁的程序的进度图

线程1
