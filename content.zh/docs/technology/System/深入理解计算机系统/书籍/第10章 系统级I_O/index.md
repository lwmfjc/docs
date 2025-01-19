第 10 章

C H A P T E R 10

系统级 1 /0

### 输入／扴出(1/0 )是在主存和外部设备（例如磁盘驱动器、终端和网络）之间复制数据的过程。输入操作是从 I/ 0 设备复制数据到主存， 而输出操作是从主存复制数据到1/0 设备。

所有语言的运行时系统都 提供执行 1/ 0 的较高级别的工具。例如， ANSI C 提供标准1/ 0 库， 包含像 pr i n t f 和 s c a n f 这样执行带 缓冲区的 I/ 0 函数。C++ 语言用它的重载操作符＜＜（输入）和＞＞（输出）提供了类似的功能 。在 Lin ux 系统中， 是通过使用由内核提供的系统级 U nix I/ 0 函数来实现这些较高级别的 I/ 0 函数的。大多数时候，高 级别 1/ 0 函数工作良好， 没有必要直接使用 U nix I/ 0 。那么为什么还要麻烦地学习 U nix 1/ 0 呢？

### 了解 Unix 1/ 0 将帮助你理解其他的 系统概念。1/ 0 是系统操作不可或缺的一部分，因此， 我们经常遇到 1/ 0 和其他系统概念之间 的循环依赖。例如， 1/ 0 在进程的创建和执行中扮演着关键的角色。反过来， 进程创建又在不同 进程间的文件共享中扮演着关键角色。因此，要真正理解1/0 , 你必须理解进程，反之亦然。在对存储器层次结构、链接和加载、进程以及虚拟内存的讨论中， 我们已经 接触了 I/ 0 的某些方面。既然你对这些概念有了比较好的理解， 我们就能闭 合这个循环， 更加深入地研究1/0 。

-   有时你除 了使用 U nix 1/ 0 以外别 无选择。在某些重要的情况中， 使用高级 1/ 0 函数不太可能 ，或 者不太合适。例如， 标准 I/ 0 库没有提供读取文件元数据的方式， 例如文件大小或文件创建时间。另外， I / 0 库还存在一些问题，使 得用它来进行网络编程非常冒险。

    这一章介绍 Unix 1/ 0 和标准 I/ 0 的一般概念， 并且向你展示在 C 程序中如何 可靠地使用 它们。除了作为一般 性的介绍之外，这 一章还为我们随后学习网络编程和并发性奠定坚实的基础。

    10 . 1 Unix 1/0

### 一个 Linu x 文件就是一个 m 个字节的 序列：

B。, B1, …， B k' … , Bm - 1

### 所有的 1/0 设备（例如网络、磁盘和终端）都被模型化为文件 ， 而所有的输入和输出都被当作对相应文件的读和写来执行。这种将设备优雅地映射为文件的方式，允 许 Lin ux 内核引出一个简单、低级的应用接口， 称为 U nix I/0, 这使得所有的输入和输出都能以一种统一且一致的方式来执行：

-   打开文件。一个应用程序通过要求内核打开相应的文件，来宣告它想要访问一个 I/ 0 设备。内核返回一个小的非负整数 ，叫 做 描述符 ，它 在后续对此文件的所有操作中标识这个文件。内核记录有关这个打开文件的所有信息。应用程序只需记住这个描述符。
-   Linux shell 创建的每个进程开始时都有三个打开的文件： 标准输入（描述符为 0)、标准输出（描述符为1) 和标准错误（描述符为 2) 。头文件\< un i s t d . h \> 定义了常量 STDIN\_ FIL ENO、STDOUT_FIL ENO和 STDERR\_ FIL ENO, 它们可用来代替显式的描述符值。

### 改变当 前的文件位 置。对 于每个打开的文件，内 核保持着一个文件位 置 k , 初始为

0。这个文件位置是从文件开头起 始的字节偏移量。应用程序能够通过执行 s ee k 操作， 显式地设置文件的当前位置为 K。

-   读写文 件。一个读操作就是 从文件复制 n \> O 个字节到内 存， 从当前文件位置 k 开始， 然后将 K 增加到k + n 。给定一个大小为 m 字节的文件 ，当 k;;;:=::m 时执行读操作会触发一个称为 e nd- of-f ile ( EO F ) 的条件， 应用程序能检测到这个条件。在文件结尾处并没有明确的 " EOF 符号”。

### 类似地， 写操作就是从内存复制 n \> O 个字节到一个文件， 从当前文件位置 K

开始， 然后更新 k 。

-   关闭 文件。当应用完成了对 文件的访问之后，它 就通知内核关闭这 个文件。作为响应，内核释放文件打开时创建的数据结构，并将这个描述符恢复到可用的描述符池 中。无论一个进程因为何种原因终止时，内 核都会关闭所有打开的 文件并释放它们的内存资源。
1.  2 文件

    每个 Linu x 文件都有一个类型 ( t y pe) 来表明它在系统中的角色：

    -   普通文件 ( reg ula r fi le) 包含任意数 据。应用程序常常要 区分文本文件 ( te xt fi le ) 和二进制文件 ( bina r y file) , 文本文件是只含有 A SCII 或 U nicode 字符的普通文件；二进制文件是所有其他的文件。对内核而言，文本文件和二进制文件没有区别。

        Linux 文本文件包含了一个文本行( text line) 序列， 其中每一行都是一个字符序列， 以一个新行符(" \\ n" ) 结束。新行符与ASCII 的换行符CLF ) 是一样的， 其数字值为Ox Oa 。

    -   目 录( direct or y ) 是包含一组链接 Clink ) 的 文件， 其中每个链接都将一个 文件 名( fi le nam e) 映射到一个文件， 这个文件可能 是另一个目录。 每个目录至 少含有两个条目：“．”是到该目录自身的链接，以及".."是到目录层次结构（见下文）中父目 录( pa ren t director y ) 的链 接。你可以用 mkd ir 命令创建一个目录，用 l s 查看其内容，用 r md i r 删除该目录。
    -   套接宇( so cket ) 是用来与另一个进程进行 跨网络通信的文件(11. 4 节）。

        其他文件类型包含命名通道( nam ed pipe ) 、符号链 接( s ym bolic link), 以及字符和块

        设备( charact er and block device), 这些不在本书的讨论 范畴。

        Lin ux 内核将所有文件都组织成一个目 录层 次结构 ( directo r y hierarchy) , 由名为／（斜杠）的根目 录确定 。系统中的每个文件都是根目录的 直接或间接的后代。图 10-1 显示了Lin u x 系统的目录层次结构的一部分。

![](img/548d6c7893acb794ed31a7acd8055b55.jpeg)

e 七c l

#### group passwd/

home /

dr oh / br yant /

I

#### us r /

i ncl ude / bi n /

I

#### he l l o. c

stdio. h s ys / vim

uniIstd.h

图10-1 Linux 目录层次的一部分。尾部有斜杠表示是目录

作为其上下文的一部分，每 个 进程都有一个当前工作目 录( c ur r e n t working directory) 来确定其在目录层次结构中的当前位置。你可以 用 c d 命令来修改 s hell 中的当前工作目录。

目 录层次结构中的位置用路径名( pa t h na m e ) 来指定。路径名是一个字符串，包 括一个

#### 可选斜杠，其 后 紧跟一系列的文件名，文 件 名 之 间 用 斜 杠 分 隔 。 路 径 名 有 两 种 形 式 ：

-   绝对路径名 ( a bs ol ut e pa t h na me ) 以一个斜杠开始， 表 示从根节点开始的路径。例如 ，在 图 1 0- 1 中 ， h e l l o . c 的 绝 对 路 径 名 为/ h ome / dr o h / h e ll o . c 。
-   相 对路径名( re la t ive pa t h na me ) 以文件名开始， 表示从当前工作目录开始的路径。例如 ，在 图 1 0-1 中 ，如 果 / h o me / dr o h 是 当前工作目录， 那 么 h e l l o . c 的 相对路径名就是./hello. c。反之， 如果 / h ome / br y a n t 是 当前工作目录， 那 么 相 对路径名就是../ home / dr o h / h e l l o . c 。
1.  3 打开和关闭文件

#### 进程是通过调用 o p e n 函数来打开一个已存在的文件或者创建一个新文件的：

\#include \<sys/types.h\>

\#include \<sys/stat.h\>

\#include \<fcntl.h\>

int open(char \*filename, int flags, mode_t mode);

#### 返回： 若成功则为新文件描述符，若出错 为一 1 。

op e n 函数将 f i l e name 转换为一个文件描述符，并 且 返 回 描 述 符 数 字 。 返回的描述符总是在进程中当前 没有打开的最小描述符。fl a gs 参数指明了进程打算如何访问这个文件：

-   O_RDONLY: 只读。
    -   O_WRONLY: 只写。
    -   O_RDWR: 可读可写。

#### 例如，下 面的代码说明如何以读的方式打开一个已存在的文件：

fd = Dpen("foo.txt", O_RDONLY, O);

#### f l a g s 参 数 也 可以 是 一 个 或 者 更 多 位 掩 码 的 或 ， 为写提供给一些额外的指示：

-   O_CREAT: 如果文件不存在，就 创 建 它 的 一 个 截断的( t ru nca t ed )(空）文件。
    -   O_TRUNC: 如果文件已经存在，就截断它。
    -   O_APPEND: 在每次写操作前，设 置文件位置到文件的结尾处。

#### 例如，下面的代码说明的是如何打开一个已存在文件，并在后面添加一些数据：

fd = Open("foo.txt", O_WRONLYID_APPEND, 0);

mo d e 参 数 指 定 了 新 文件的访问权限位。这些位的符号名字如图 10- 2 所示。

作为上下文的一部分， 每个进程都有一个 uma s k , 它 是 通 过 调 用 u ma s k 函 数来设置的 。 当 进 程 通过带某个 mo d e 参 数 的 o p e n 函 数 调 用 来 创 建 一 个新文件时， 文 件 的 访问权限 位 被设 置 为 mo d e & \~ u ma s k 。 例 如，假 设 我们给定下面的 mo d e 和 uma s k 默 认值 ：

\#define DEF_MODE S_IRUSRIS_IWUSRIS_IRGRPIS_IWGRPIS_IROTHIS_IWOTH

\#define DEF_UMASK S_IWGRPIS_IWOTH

#### 接下来，下面的代码片段创建一个新文件，文件的拥有者有读写权限，而所有其他的

用户都有读权限：

umask(DEF_UMASK);

fd = Open("foo.txt", O_CREATIO_TRUNCIO_WRONLY, DEF_MODE);

图 10-2 访问权限位。在 s ys / s t a t . h 中定义

最后， 进程通过调用 c l o s e 函数关闭一个打开的文件。

\#include \<unistd.h\>

int close(int fd);

返回： 若 成 功 则 为 o, 若 出 错 则 为 一1。

### 关闭一个已关闭的描述符会出错。

＿｀练习题 10. 1 下面程序的输出是什么？

| 1   | \#include "csapp.h"             |     |
|-----|---------------------------------|-----|
| 2   |                                 |     |
| . 3 | int main()                      |     |
| 4   | {                               |     |
| s   | int fd1, fd2;                   |     |
| 6   |                                 |     |
| 7   | fd1 = Open("foo.txt", O_RDONLY, | 0); |
| 8   | Close(fdl);                     |     |
| 9   | fd2 = Open("baz.txt", O_RDONLY, | O); |
| 10  | printf("fd2 = %d\\n", fd2);     |     |
| 11  | exit(O);                        |     |
| 12  | }                               |     |

1.  4 读和写文件

    应用程序是通过分别调用r e a d 和 wr i t e 函数来执行输入和输出的。

\#include \<un i s t d . h \>

ssize_t read(int fd, void \*buf, size_t n);

返回： 若 成 功 则为读的 字节数 ， 若 EOF 则为 o, 若 出错 为 一1。

ssize_t write(int fd, const void \*buf, size_t n);

返回： 若 成 功 则为 写的 字节数 ， 若出错 则为 一1。

r e ad 函数从描述符为 f d 的当前文件位置复制最多 n 个字节到内存位置 bu f 。返回值- 1

### 表示一个错误，而返 回值 0 表示 EO F。否则 ， 返回值表示的是实际传送的字节数量。

W豆 t e 函数从内存位置 b uf 复制至多 n 个字节到描述符 f d 的当前文件位置。图 10-3 展

示了一个程序使用r e a d 和 wr i t e 调用一次一个字节地从标准输 入复制到标准输出。

#### codeliolcpstdin.c

\#include "csapp. h"

2

#### 3 int main(void)

4 {

5 char c;

6

7 while(Read(STDIN_FILENO, \&c, 1) != 0)

#### 8 Write(STDOUT_FILENO, \&c, 1);

9 exit(O);

10 }

#### code/io/cpstdin.c

图 10-3 一次一个字节地从标准输入复制到标准输出

### 通过调用 l s e e k 函数， 应用程序能够显示地修改当前文件的位置， 这部分内容不在我们的讲述范围之内。

田日ss ize \_t 和 s ize \_t 有些什么区别？

你可能 已经 注意到 了， r e a d 函数有一个 s i z e \_ t 的输入参数和一个 s s i ze \_ t 的返回值。那么这两种类 型之 间 有什 么区 别呢？在 x8 6-64 系统 中，s i ze \_ 七被定义为 un ­ signed long, 而 s s i z e \_ t ( 有符号的 大小）被定义为 l o ng 。r e a d 函数返回一个有符号的大小， 而不是 一个无符号 大小，这是 因 为 出错时它必须返 回 一1 。 有趣的是， 返回一个— 1 的可能性使得 r e a d 的最大值 减小 了一半。

在某些情况下 ，r e a d 和 wr i t e 传送的字节比应用程序要求的要少。这些不足 值( short cou nt ) 不表示有错误 。出现这样情况的原 因有：

-   读时遇到 E O F 。假设 我们准备读一个文件，该 文件从当前文件位置开始只含有 20 多个字节， 而我们以 50 个字节的 片进行读取。这样一来，下 一个r e a d 返回的不足值为 20 , 此后的r e a d 将通过返回不足值 0 来发出 E O F 信号。

### 从终端读文本行。如果打开文件是与终端相关联的（如键盘和显示器），那么每个

r e a d 函数将一次传送一个 文本行，返 回的不足值等于文本行的大小。

-   读和写网络套接 字 ( sock et ) 。如果打开的 文件对应于网络套接字( 11. 4 节）， 那么内部缓冲约束 和较长的网络延迟会引起r e a d 和 wr i t e 返回不足值。对 Lin ux 管道 ( pipe) 调用r e a d 和 wr i t e 时，也 有可能 出现不足值， 这种进程间 通信机制不在我们讨论的范围之内。

### 实际上， 除了 EO F , 当你在读磁盘文件时，将不会遇到不足值，而且在写磁盘文件时， 也不会遇到不足值。然而，如果你想创建健壮的（可靠的）诸如 Web 服务器这样的网络应用， 就必须通过反复调用 r e ad 和 wr i t e 处理不足值， 直到所有需要的字节都传送完毕。

10\. 5 用 RIO 包健壮地读写

在这一小 节里， 我们会讲述一个 1/0 包， 称为 R IO ( Robus t 1/ 0 , 健壮的 1/0 ) 包， 它

#### 会自动为你处理上文中所述的不足值。在像网络程序这样容易出现不足值的应用中， RIO

包提供了方便、健壮和高效的 I/ 0 。RIO 提供了两类不同的函数：

#### 无缓冲的输入输出函数。这些函数直接在内存和文件之间传送数据，没有应用级缓冲。它们对将二进制数据读写到网络和从网络读写二进制数据尤其有用。

-   带缓冲的输入函数。这些函数允许你高效地从文件中读取文本行和二进制数据，这 些文件的内容缓存在应用级缓冲区内， 类似千为 pr i n t f 这样的标准 I/ 0 函数提供的缓冲区。与[ ll O] 中 讲 述 的 带 缓 冲的 I/ 0 例程不同，带 缓 冲的 RIO 输入函数是线程安全的(1 2. 7. 1 节），它在同一个描述符上可以被交错地调用。例如，你 可以从一个描述符中读一些文本行， 然后读取一些二进制数据，接 着 再 多 读取一些文本行。

#### 我们讲述 RIO 例程有两个原因。第一，在接 下 来的两章中， 我们开发的网络应用中使用了它们；第 二 ，通 过学 习 这 些 例 程 的 代码，你 将 从 总体 上 对 Unix I/ 0 有更深入的了解。

10\. 5. 1 R IO 的 无 缓 冲 的 输 入 输 出 函 数

通过调用r i o_r ea dn 和r i o_wr i t e n 函数 ， 应用程序可以在内存和文件之间直接传送数据。

\#include "csapp.h"

ssize_t rio_readn(int fd, void \*usrbuf, size_t n); ssize_t rio_writen(int fd, void \*usrbuf, size_t n);

返回： 若 成 功 则为 传 送的 字 节数 ， 若 EOF 则 为 0 ( 只对r i or\_ ea dn 石言）， 若 出错 则 为 一1 。

豆 0 —r e a d n 函数 从 描 述 符 f d 的 当 前 文 件 位置最多传送 n 个字节到内存位置 u sr b u f 。类似地，r i o\_ wr i t e n 函数 从 位置 u sr b u f 传送 n 个字节到描述符 f d 。r i o \_r e a d 函数在遇到 EOF 时只 能返回一个不足值。r i o \_ wr i t e n 函 数 决 不 会 返回不足值。对同一个描述符，

可以任意交错地调用 rio readn 和 'rio wr i t e n 。

图 1 0- 4 显 示了 r i o \_r e a d n 和r i o \_ wr i t e n 的 代码。注意， 如 果 r i o \_ r e a d n 和r i o \_ wr i e n 函数被一个从应用信号处理程序的返回中断，那 么 每个函数都会手动地重启r e a d 或 wr i t e 。 为了尽可能有较好的可移植性， 我们允许被中断的系统调用， 且在必要时重启它们。

1.  5\. 2 R IO 的 带 缓 冲的 输入 函数

#### 假设我们要编写一个程序来计算文本文件中文本行的数量，该如何来实现呢？一种方 法就是用r e a d 函数来一次一个字节地从文件传送到用户内存，检 查每个字节来查找换行符。这个方法的缺点是效率不是很高， 每读取文件中的一个字节都要求陷入内核。

一种更好的方法是调用一个包装函数(r i o_r ea dl i ne b) , 它从一个内部读缓冲区复 制一个文本行，当缓 冲区变空时，会 自动 地调用r e ad 重新填满缓冲区。对于既包含文本行也包含二进制数据的文件（例如11. 5. 3 节中描述的 HTTP 响应）， 我们也提供了一个r i o\_ r e adn 带缓冲区的版本 ，叫做 r i o \_r e a dnb , 它从 和r i o_r e a dl i ne b 一样的读缓冲区中传送原始字节。

\#include "csapp.h"

void rio_readinitb(rio_t \*rp, int fd);

ssize_t rio_readlineb(rio_t \*rp, void \*usrbuf, size_t maxlen); ssize_t rio_readnb(rio_t \*rp, void \*usrbuf, size_t n);

返回： 无 。

返回： 若 成 功 则 为 读的 宇节数 ， 若 EOF 则 为 o , 若 出 错 则 为 — l 。

#### ssize_t rio_readn(int fd, void \*usrbuf, size_t n)

2 {

#### 3 size_t nleft = n;

4 ssize_t nread;

s char \*bufp = usrbuf;

6

#### 7 while (nleft \> 0) {

8 if ((nread = read(fd, bufp, nleft)) \< 0) {

code/s吹r

#### sapp.c

9 if (errno == EINTR) I\* Interrupted by sig handler return \*I

1o nread = 0; / \* and call read() again \*/

11 else

12

13 ｝

#### return -1;

I\* errno set by read() \*I

1.  else if (nread == 0)
2.  break;

I\* EDF \*I

3.  nleft -= nread;
4.  bufp += nread;

    18 }

19

20 }

#### return (n - nleft);

I\* Return\>= 0 \*I

code/srdcsapp.c

ssize_t rio_writen(int fd, void \*usrbuf, size_t n)

2 {

#### 3 size_t nleft = n;

4 ssize_t nwritten;

5 char \*bufp = usrbuf;

6

#### 7 while (nleft \> 0) {

8 if ((nwritten = write(fd, bufp, nleft)) \<= 0) {

code/srd csapp.c

9 if (errno == EINTR) I\* Interrupted by sig handler return \*I

1.  n江 i t t en = 0; I\* and call write() again \*I
2.  else

12

13 }

#### return -1; I\* errno set by write() \*I

1.  nleft 一= nwritten;
2.  bufp += nwritten;

    16 }

    17 return n;

    18 }

#### code/srdcsapp.c

图 10-4 r i o—r ead n 和 r i o_wr 止 e n 函数

每打开一个 描述符， 都会调用一次r i o_r e a d i n i t b 函数。它将描述符 f d 和地址 r p

处的一个类型为r i o \_ t 的读缓冲区联系起来。

r i o_r e a d l i ne b 函数从文件r p 读出下一个文本行（包括结尾的换行符）， 将它复制到内 存位置 usr b u f , 并且用 NU L L( 零）字符来结束这个文本行。r i o_r e a d l i ne b 函数最多读 ma x l e n - 1 个字节，余 下的 一个字符留给结尾的 NU LL 字符。超过 ma x l e n - 1 字节的文

本行被截断， 并用一个 N U L L 字符结束。

r i o \_r e a d nb 函数从文件r p 最多读 n 个字节到内存位置 u sr b u f 。对同一描述符， 对r i o\_ r e a d l i n e b 和r i o\_ r e a d n b 的调用可以任意交叉 进行。然而，对 这些带 缓冲的函数的调用却不应 和无缓冲的 r i o \_ r e a d n 函数交叉使用。

### 在本书剩下的部分中将给出大鼠的 RIO 函数的示例。图 10-5 展示了如何使用 RIO 函数来一次一行 地从标准输入复制一个文本文件到标准输出。

code/io/cpfile.c

\#include "csapp. h"

2

3 int main(int argc, char \*\*argv)

4 {

5 int n;

6 r. 1o_t r10;

7 char buf[MAXLINE];

8

1.  Rio_readinitb(&rio, STDIN_FILENO);
2.  while((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0)
3.  Ri o_wr i t en (ST DOUT_FI LENO, buf, n);

    12 }

code/io/cpfile.c

图 10-5 从标准输入复制一个文本文件到标 准输出

图 10-6 展示了一个读缓冲区 的格式，以 及初始化它的r i o \_r e a d i n i t b 函数的代码。rio r e a d i n i t b 函数创建了一个空的读缓冲区， 并且将一个打开的 文件描述符和这个缓冲区联系起来 。

\#define RIO_BUFSIZE 8192

1.  · t ypede f struct {
    1.  int rio_fd;

        4 int rio_cnt;

2.  char \*rio_bufptr;
3.  charr i o_buf [RIO_BUFSI ZE] ;
4.  } rio_t;

    codelinclude/csapp.h

I\* Descriptor for this internal buf \*I I\* Unread bytes in internal buf \*I

I\* Next unread byte in internal buf \*I I\* Internal buffer \*I

codelinclude/csapp.h

void rio_readinitb(rio_t \*rp, int fd)

2 {

3 rp-\>rio_fd = fd;

4 rp-\>rio_cnt = O;

5 rp-\>rio_bufptr = rp-\>rio_buf;

6 }

code/srdcsapp.c

code/srdcsapp.c

图 10-6 一个类型为 r i o_t 的读缓 冲区和初始化它的r i o_r eadi ni t b 函数

RIO 读程序的核心是图 10-7 所示的r i o \_r e a d 函数。r i o_r e a d 函数是 L in uxr e a d 函数的带缓冲的版本。当调用r i o \_r e a d 要求读 n 个字节时， 读缓冲区内 有r p - \> 豆 o \_ c n t

个未读字节。如果缓冲区 为空， 那么会通过调用r e a d 再填满它。这个r e a d 调用收到一 个不足值并 不是错误，只 不过读缓 冲区是填充了一部分。一旦缓冲区非空，r i o \_r e a d 就从读缓冲区复制 n 和r p - \> rio \_c nt 中较小值个字节到用户缓冲区， 并返回复制的字节数。

#### code/srdcsapp.c

static ssize_t rio_read(rio_t \*rp, char \*usrbuf, size_t n)

2 {

#### int cnt;

5 while (rp-\>rio_cnt \<= 0) { I\* Refill if buf is empty \*I

6 rp-\>rio_cnt = read(rp-\>rio_fd, rp-\>rio_buf, sizeof(rp-\>rio_buf));

1.  if (rp-\>rio_cnt \< 0) {

#### if (errno != EINTR) I\* Interrupted by sig handler return \*I 1o return -1;

｝

#### 12 else if (rp-\>rio_cnt == 0) I\* EDF \*I return O;

1.  else
2.  rp-\>rio_bufptr = rp-\>rio_buf; I\* Reset buffer ptr \*I

    16

#### I\* Copy min(n, rp-\>rio_cnt) bytes from internal buf to user buf \*I

1.  cnt = n;
2.  if (rp-\>rio_cnt \< n)

#### cnt = rp-\>rio_cnt;

3.  memcpy(usrbuf, rp-\>rio_bufptr, cnt);
4.  rp-\>rio_bufptr += cnt;
5.  rp-\>rio_cnt -= cnt;
6.  return cnt;

    26 }

#### code/srdcsapp.c

图 10-7 内 部的r i o_r ead 函数

对千一个应用 程序，r i o_r e a d 函数和 Lin uxr e a d 函数有同样的语义。在出错时，它返回值- 1 , 并且适当地设置 e rr no 。在 E O F 时，它 返回值 0。如果要求的字节数超过了读缓冲区内 未读的字节的数量， 它会返回一个不足值。两个函数的相似性使得很容易通过用r i o \_r e a d 代替 r e a d 来创建不同类型的带缓冲的 读函数。例如，用 r i o \_ r e a d 代替

read, 图10-8中的r i o_r e a d nb 函数和r i o—r e a d n 有相同的结构。相似地，图 10-8 中的

立 o \_r e a d l i ne b 程序最多 调用 ma x l e n - 1 次r i o_r e a d。每次调用都从读缓冲区 返回一个字节，然后检查这个字节是否是结尾的换行符。

田日RIO 包的起源

R IO 函数的灵感来自 于 W. Richard Stevens 在他的经典 网络 编程作品[ ll O] 中描述的r e a d l i ne 、r e a d n 和 wr i t e n 函数。r i o \_r e a d n 和r i o \_ wr i t e n 函数与 S t e vens 的 r e a d n 和 wr i t e n 函数是一样的。然而， S te vens 的r e a d l i ne 函数有一些局 限性在 RIO 中得到 了纠 正。笫一 ， 因为r e a d l i ne 是带缓 冲的 ， 而r e a d n 不带， 所以这两个函数不能在同一描 述符上一起使用。 第二，因为它使 用一 个 s t a t i c 缓冲区， Ste vens 的 r e a dl i ne

函数不是线程安全的， 这 就要 求 S te ve n s 引入一个不同的 线程 安全的 版本 ， 称 为 r e a d ­ 且 n e \_ r 。我 们已经在r i o r e a d l i n e b 和 r i o \_r e a d n b 函数 中修 改 了 这 两 个缺 陷， 使 得这两个函数是相互兼容和线程安全的。

code/sr吹 sapp.c ssize_t rio_readlineb(rio_t \*rp, void \*usrbuf, size_t maxlen)

2 {

3 int n, re;

4 char c, \*bufp = usrbuf;

5

6 for (n = 1; n \< maxlen; n++) {

7 if ((re= rio_read(rp, \&c, 1)) == 1) {

8 \*bufp++ = c;

9 if (C == 1 \\n 1) {

10 n++;

11 break;

12 }

13 } else if (re == 0) {

14 if (n == 1)

1.  return O; I\* EDF, no data read \*I
2.  else

17

18 } else

break;

I\* EDF, some data was read \*I

19

20 }

return -1;

I\* Error \*I

1.  \*bufp = O;
2.  return n-1，·

    23 }

code/srdcsapp.c

code/srdcsapp.c

1 ssize_t rio_read.nb(rio_t \*rp, void \*usrbuf, size_t n)

2 {

3 size_t nleft = n;

4 ssize_t nread;

s char \*bufp = usrbuf;

6

1.  while (nleft \> 0) {
2.  if ((nread = rio_read(rp, bufp, nleft)) \< 0)

    9 return -1; I\* errno set by read() \*I

    1o else if (nread == 0)

11

12

13

14 }

break; nleft -= nread; bufp += nread;

I\* EDF \*I

15

16 }

return (n - nleft);

I\* Return\>= 0 \*I

code/s吹r sapp.c

图10-8 r i o_r eadl i ne b 和r i o_r ea dnb 函数

10\. 6 读取文件元数据

应用程序能够通过调用 s t a t 和 f s t a t 函数， 检索到关 千文件的信息（有时也称为文

件 的 元 数 据 ( m e t a d a t a ) ) 。

\#include \<unistd.h\>

\#include \<sys/stat.h\>

int stat(const char \*filename, struct stat \*buf); int fstat(int fd, struct stat \*buf);

返回： 若 成 功 则为 o, 若 出错 则为 一1。

s t a 七函数以一个文件名作为输入， 并填写如图 1 0- 9 所示的一个 s t 扛 数据结构中的各个成员。f s t a t 函数是相似的，只 不过是以文件描述符而不是 文件名作为输 入。当我们在 11. 5 节中讨论 W e b 服务器时 ， 会需要 s t a t 数据结构中的 s t \_ mo d e 和 s t \_ s i z e 成员， 其他成员则不在我们的讨论之列。

statbuf h (included by sys/stat.h)

I\* Metadata returned by the stat andfstat functions \*I struct stat {

dev_t st_dev;

ino_t st_ino;

mode_t st_mode;

nlink_t st_nlink;

uid_t st_uid;

gid_t st_gid;

dev_t st_rdev;

off_t st_size;

I\* Device \*I I\* inode \*I

I\* Protection and file type \*I

/\* Number of hard links\*/ I\* User ID of owner \*I

/\* Group ID of owner\*/

)\* Device type (if inode device \*/ I\* Total size, in bytes \*I

unsigned long st_blksize; /\* Block size for filesystem I/□ \*/

unsigned long st_blocks; I\* Number of blocks allocated \*I

time_t time_t time_t

};

st_atime; st_mtime; st_ctime;

/\* Time of last access\*/

/\* Time of last modification\*/ I\* Time of last change \*I

statbuf h (included by sys/stat.h)

图 10-9 s t a t 数据结构

s t \_ s i z e 成员包含了文件的字节数大小。s t \_ mo d e 成员则编码了文件访问许可位（图1 0- 2 ) 和文件类型(1 0. 2 节）。L in u x 在 s y s / s t a 七 . h 中定义了宏谓词来确定 s t \_ mo d e 成员的文件类型：

S_IS REG ( m) 。这是一 个普通文件吗？ S_ISDIR ( m) 。这是一 个目录文件吗？ S_ISSOCK ( m) 。这是 一个网络套接字吗？

图 10-1 0 展示了我们会如何使用这些宏和 s t a t 函数来读取和解释一个文件的 s t mo d e 位。

code/iolstatcheck.c

1 \#include "csapp.h"

2

3 int main (int argc, char \*\*argv)

4 {

1.  struct stat stat;
2.  char \*type, \*readok;

    7

3.  Stat(argv[1], \&stat);
4.  if (S_ISREG (stat.st_mode)) I\* Determine file type \*I
5.  type = "regular";
6.  else if (S_ISDIR(stat.st_mode))
7.  type = "directory";
8.  else
9.  type = "other";
10. if ((stat.st_mode & S_IRUSR)) I\* Check read access \*I
11. readok = "yes"; 17 else

    18 readok = "no";

    19

12. printf("type: %s, read: %s\\n", type, readok);
13. exit(O); 22 }

图 10 -1 0 查询和处理一个文件的 s t \_mode 位

1.  7 读取目录内容

    应用程序可以用 r e a d d ir 系列函数来读取目录的内容。

\#include \<sys/types.h\>

\#fnclude \<dirent.h\>

code/iols ta tcheck . c

DIR \*opendir(const char \*name);

返回： 若 成 功 ， 则为 处理的 指针 ； 若 出错 ， 则 为 NU LL 。

函数 o p e n d i r 以路径名为参数， 返回指向目 录流 ( di r ec t o r y s t r ea m ) 的指针。流是对条目有序列表的抽象，在这里是指目录项的列表。

\#include \<dirent.h\>

struct dirent \*readdir(DIR \*dirp);

返回： 若 成 功， 则 为 指 向 下 一 个 目 录项的指针 ； 若 没 有 更 多的 目 录 项或 出错 ， 则 为 NU LL 。

每次对r e a d d ir 的调用返回的都是指向流 d ir p 中下一个目录项的指针， 或者， 如果没有更多目 录项则 返回 NU L L 。每个目录项都是一个结构 ， 其形式如下：

struct dirent {

ino_t d_ino; I\* inode number \*I char d_name[256]; I\* Filename \*I

};

虽然有些 L i n u x 版本包含了其他的结构成员， 但是只有这两个对所有系统来说都是标

准的。成员 d \_n a me 是文件名 ， d \_ i n o 是文件位 置。

如果出错， 则r e a d d ir 返回 N U L L , 并设置 err n o 。可惜的是，唯 一能区分错误和流结束情况的方法是检查 自调用r e a dd i r 以来 err no 是否被修改过。

\#include \<dirent.h\>

int closedir(DIR \*dirp);

返回： 成 功为 O; 错 误 为 一1.

函数 c l o s e d ir 关闭流并释放其 所有的资 源。图 1 0-11 展示了怎样用r e a d d i r 来读取目录的内容。

1 \#include "csapp.h"

2

3 int main(int argc, char \*\*argv)

4 {

s DIR \*Streamp;

6 struct dirent \*dep;

7

8 streamp = Opendir (argv [1]) ;

9

1.  errno = O;
2.  while ((dep = readdir(streamp)) != NULL) {
3.  printf("Found file: %s\\n", dep-\>d_name);

    13 }

    14 if (errno != 0)

    15 unix_error("readdir error");

    16

    17 Closedir (st reamp) ;

    18 exit (0);

    19 }

    code/io/readdir.c

code/io/readdir.c

图 10-11 读取目录的内容

1.  8 共享文件

### 可以 用许多不同的方式来共享 L in ux 文件。除非你很清楚 内核是如何表示打开的文件， 否则文件共享的概念相当难懂。内核用三个相关的数据结构来表示打开的文件：

-   描述符表( des crip to r t a b le ) 。每个进程都有它独立的描述符表，它 的 表项是由进程打开的文件描述符来索引的。每个打开的描 述符表项指向文件表中 的一个表项。
    -   文件表 ( fi le t a ble ) 。打开文件的集合是由一张文件表来表示的， 所有的 进程共享这张表。每个文件表的表项组成（针对我们的目的）包括当前的文件位置、引用计数(ref erenee count)(即当前指向该表项的描述符表项数）， 以及一个指向 v- node 表中对应表项的指针。关闭一个描述符会减少相应的文件表表项中的引用计数。内核不会删除这个文件表表项， 直到它的引用 计数为零。
-   v-node 表( v- node ta ble ) 。同文件表一样， 所有的进程共享这张 v- node 表。每个表项包含 s 七a t 结 构中的大多数信息， 包括 s t \_mo d e 和 s t \_s i ze 成员。

    图 10-1 2 展示了一个示例， 其中描述符 1 和 4 通过不同的打开文件表表项来引用两个

### 不同的文件。这是一种典型的情况，没有共享文件，并且每个描述符对应一个不同的文件。

描述符表

（ 每个进程一张表）

#### ![](img/e1f99c49a22df6df9b11d1bc176e046d.jpeg)s t di n fd 0 s t dout fd 1 S 七de rr fd 2

fd 3

fd 4

打开文件表

（ 所有进程共享） 文件 A

v-node表

（所有进程共享）

图 10-12 典 型 的 打 开 文 件 的 内 核 数 据 结 构 。 在这个示例中， 两 个 描 述 符引 用 不 同 的 文 件 。 没 有 共 享

### 如图 10-13 所示，多 个描述符也可以通过不同的文件表表项来引用同一个文件。例如， 如果以同一个 巨 l e na me 调用 ope n 函数两次， 就会发生这种情况。关键思想是每个描述符都有它自己的文件位置，所以对不同描述符的读操作可以从文件的不同位置获取 数据。

描述符表

（每个进程一张表 ）

打开文件表

![](img/6b86e6886bf2949f33e92877bc627b57.jpeg)（所有进程共享） 文件A

v-node表

（所有进程共享）

图 10-13 文件共享。这个例子展示了两个描述符通过两个打开文件表表项共享同一个磁盘文件

### 我们也能理解父子进程是如何共享文件的 。假设在调用 f or k 之前， 父进程有如图 10-12 所示的打开文件。然后 ， 图 1 0-1 4 展示了调用 f or k 后的情况。子进程有一个父进程描述符表的副本。父子进程共享相同的打开文件表集合 ， 因此共享相同的文件位置。一个很重要的结果就是，在内核删除相应文件表表项之前，父子进程必须都关闭了它们的描 述符。

![](img/ea83884330d6fcd6467c6bdb2901ce84.jpeg)描述符表父进程的表

打开文件表

（所有进程共享） 文件 A

v-node 表

（所有进程共享）

图 10-14 子进程如何继承父进程的打开文件。初始状态如图 10-12 所示

沁目 练习题 10. 2 假设 磁 盘 文件 f o o b ar . t x t 由 6 个 ASCII 码 字符 " f o o b ar " 组成。那么，下列程序的输出是什么？

1 \#include "csapp.h"

2

3 int main()

4 {

s int fd1, fd2;

6 char c;

7

8 fd1 = Open("foobar.txt", O_RDONLY, O);

9 fd2 = Open("foobar.txt", O_RDONLY, 0); 10 Read(fd1, \&c, 1);

11 Read(fd2, \&c, 1);

12 printf("c = o/.c\\n", c);

13 exit(O); 14 }

已 练习题 10. 3 就像前面那 样，假 设 磁盘文件 f oob ar . t 江 由 6 个 ASCII 码 字符 " f ooba r"

组成。那么下列程序的输出是什么？

\#include "csapp.h"

2

3 int main()

4 {

1.  int fd;
2.  char c;

    7

    8 fd = Open("foobar.txt", O_RDONLY, O);

    9 if (Fork() == 0) {

3.  Read(fd, \&c, 1);
4.  exit(O);

    12 }

5.  Wait (NULL) ;
6.  Read(fd, \&c, 1);
7.  printf("c = %c\\n", c);
8.  exit(O);

    17 }

10\. 9 1/ 0 重定向

Linux shell 提供了 I/ 0 重定向操作符，允 许用户将磁盘文件和标准输入输出联系起来。例如，键入

#### linux\> ls\> foo.txt

使得 s hell 加载和执行 l s 程序， 将标准输出重定向到磁盘文件 f o o . t x 七。 就如我们将在

1.  5 节中看到的那样， 当一个 Web 服务器代表客户端运行 CGI 程序时 ，它 就执行一种相似类型的重定向 。那么1/0 重定向是如何工作的呢？一种方式是使用 d up 2 函数。

#### \#include \<unistd.h\>

int dup2(int oldfd, int newfd);

返回： 若 成 功 则为 非 负的 描 述 符 ， 若 出错 则 为 一1。

d up 2 函数复制描述符表表项 o l d f d 到描述符表表项 ne wf d , 覆盖描述符表表项 ne w­ f d 以前的内容。如果 ne wf d 已经打开了， d up 2 会在复制 o l d f d 之前关闭 ne wf d 。

假设在调用 d up 2 ( 4 , 1 ) 之前，我 们的状态如图 10-1 2 所示， 其中描述符 1 ( 标准输出） 对应于文件 A( 比如一个终端）， 描述符 4 对应于文件 B( 比如一个磁盘文件）。A 和 B 的引 用计数都等千 1 。图 1 0-1 5 显示了调用 dup 2 ( 4, 1 ) 之后的情况。两个描述符现在都指向文件 B ; 文件 A 已经被关闭 了，并 且它的文件表和 v- node 表表项也已经被删除了； 文件 B 的引用计数已经增加了。从此以后， 任何写到标准输出的数据都被重定向到文件 B。

描述符表

打开文件表

v-node 表

![](img/592304ca8083dd9161a2d74ec24cf37d.jpeg) ..

fdO

I ，L------

：文件访问！

fd 1

,I -----------一一＇ 卜 ,

：文件位置！ ：文件大小！

fd 2

#### 卜----------一, I

t-------------·

fd 3

:refcnt=o: : 文件类型！

卜 －－－－－－一一－一一－1 卜， ,

fd 4

，，I：＇

-   I• I

![](img/78a83c31e19ccac09c0af8018a7f8bc5.jpeg)

图 10-15 通过调用 dup2 (4, l ) 重 定 向 标 准 输 出 之 后 的 内 核 数 据结 构 。 初始状态如图 10-12 所 示

日 日 左边和右边的 ho ink ie s

为了 避免和其他括号 类型操作符比如 " J" 和 ＂［” 相混淆， 我们总是将 s hell 的 "\> " 操作符称为“右 hoin k y" , 而将 "\< " 操作符称 为“ 左 hoin k y" 。

; 练习题 10. 4 如何 用 d up2 将标 准输入 重定 向到描述 符 5?

芦 练习题 10. 5 假设磁 盘 文件 f o o b ar . t x t 由 6 个 ASC II 码 字符 " f o o b ar " 组 成， 那么下列程序的输出是什么？

#### \#include "csapp.h"

2

#### 3 int main()

| 4 ｛ 5 |  int fdl, fd2;                     |     |
|--------|------------------------------------|-----|
| 6      | char c;                            |     |
| 7      |                                    |     |
| 8      | fd1 = Open("foobar.txt", O_RDONLY, | 0); |
| 9      | fd2 = Open("foobar.txt", O_RDONLY, | O); |
| 10     | Read(fd2, \&c, 1);                 |     |
| 11     | Dup2(fd2, fdl);                    |     |
| 12     | Read(fd1, \&c, 1);                 |     |
| 13     | printf("c = %c\\n", c);            |     |
| 14     | exit(O);                           |     |

15 ｝

10\. 10 标准 1/ 0

C 语言定义了一组高级输入输出函数，称 为标准 I/ 0 库 ， 为程序员提供了 U nix I/0 的较高级别的替代。这个库( li b c ) 提供了打开和关闭文件的函数 ( f o p e n 和 f c l o s e ) 、读和写字节的函数 ( fr e a d 和 f wr i t e ) 、 读 和 写 字 符 串 的 函 数 ( f g e t s 和 f p u t s ) , 以及复杂的格式化的 I/ 0 函数 Cs c a n f 和 pr i n t f ) 。

#### 标 准 I/ 0 库将一个打开的文件模型化为一个流。对于程序员而言，一 个 流就是一个指

向 FI LE 类型的结 构的指针。每个 ANSI C 程序开始时都有三个打开的流 s 七d i n 、 S 七d ou t

和 s t d err , 分别对应于标准输入、标准输出和标准错误：

\#include \<s t d i o . h \>

extern FILE \*stdin; I\* Standard input (descriptor 0) \*I extern FILE \*stdout; I\* Standard output (descriptor 1) \*I extern FILE \*stderr; I\* Standard error (descriptor 2) \*I

类型为 FILE 的 流是对文件描述符和流缓 冲区的 抽象 。 流缓 冲区的目的和 RIO 读缓冲区 的 一样： 就 是 使 开销较高的 Lin ux 1/0 系统调用的数量尽可能得小。例如， 假设我们有一个 程序， 它反复调用标准 1/0 的 g e t c 函数 ， 每次调用返回文件的下一个字符。当第一

次调用 g e t c 时 ，库 通过调用一次r e a d 函数来填充 流缓 冲区， 然 后 将 缓 冲区中的第一个字节 返回给应用程序。只要缓冲区中还有未读的字节， 接 下 来对 g e t c 的调用就能直接从流缓冲区得到服务。

10\. 11 综合： 我该使用哪些 1/ 0 函数？

图 10-16 总结了我们在这一章里讨论过的各种 1/ 0 包。

![](img/aa40a97bcb5e0334b52a9756b63928f5.jpeg)fopen fread f s can f sscanf f ge 七s

f dop en fwrite f pr i nt f sprintf

fputs

-   r· 飞

C应用程序

fflush f c l os e

open wr i 七e stat

fseek \\... ....

read l seek close

标准VO 函数 RIO 函数

Unix 1/0 函数

（通过系统调用来访问）

![](img/d08d9826430795fbffeb5e8e847ccd81.jpeg)图 10- 1 6 U ni x I / 0 、标准 I / 0 和 RIO 之间的关系

Unix 1/0 模型是在操作系统内核中实现的。应用程序可以通过诸如 op e n、c l o s e 、l s e e k、r e a d、wr i t e 和 s t a t 这样的函数来访问 U nix 1/0 。较高级别的 RIO 和标准I/ 0 函数都是基于（使用） Unix I/ 0 函数来实现的。RIO 函数是专为本书开发的r e a d 和 wr i t e 的健壮的包装函数 。它们自动处理不足值， 并且为读 文本行提供一种高效的带缓冲的 方法。标准 1/0 函数提供了 U nix I/ 0 函数的一个更加完整的 带缓冲的替代品， 包括格式化的 1/ 0 例程， 如 pr i nt f 和 s c a n f 。

### 那么， 在你的程序中该使用这些函数中的哪一个呢？下面是一些 基本的指导原则：

-   Gl: 只 要有可能就使用标准 I/ 0 。对磁盘和终端设备 I/ 0 来说， 标准 1/ 0 函数是首选方法。大多数 C 程序员在其整个职业生涯中只使用标准 I/ 0 , 从不受较低级的Unix I/ 0 函数的困扰（可能 s t a t 除外， 因为在标准 1/0 库中没有与它对应的函数）。只要可能 ， 我们建议你也这样做。
    -   G2 : 不要使用 s c a n f 或 r i o \_ r e a d l i ne b 来读二进制文件 。像 s c a n f 或r i o_r e a d­巨 ne b 这样的函数是专门设计来读取文本文件的。学生通常会犯的一个错误就是用这些函数来读取二进制文件， 这就使得他们的程序出现了诡异莫测的失败。比如， 二进制文件 可能散 布着很多 Oxa 字节， 而这些字节又与终止文 本行无关。

### G3: 对网络套 接字的 1/0 使用 RIO 函数。不幸的 是， 当我们试着将标准I/ 0 用千网络的输入输出时， 出现了一些令人讨厌的问题。如同我们将在 11. 4 节所见， L inux 对网络的抽象是一种称为套接字的 文件类型。就像所有的 L in ux 文件一样， 套接字由文件描述符来引用， 在这种情况下称为套 接字描述符。应用程序进程通过读写套接字描述符来与运行在其他计算机的进程实现通信。

标准 I/ 0 流，从 某种意义上而言是 全双工的 ， 因为程序能够在同一个流上执行输入和

输出。然而， 对流的限制和对套 接字的限制， 有时候会互相冲突 ， 而又极少有文档描述这些现象：

-   限制一： 跟在输出 函数之后的 输入函数。如果中间没有插入对 f fl u s h、f s e e k、 f s e t po s 或者r e wi n d 的调用， 一个输 入函数不能跟随在一个 输 出 函数之后。 f fl u s h 函数清空与流相关的缓冲区。后三个函数使用 U nix I/ 0 l s e e k 函数来重置当前的文件位置。
-   限制二： 跟在输入函数之后的 轮出函 数。如果中间没有插入对 f s e e k、f s e 七p o s 或者 r e wi n d 的调用， 一个输出函数不能跟随在一个输入函数之后， 除非该输入函数遇到了 一个文件结束。

### 这些限制 给网络应用 带来了一个问题， 因为对套接字使用 l s e e k 函数是非法的。对流I/ 0 的第一个限制能够通过采 用在每个输入操作前刷新缓 冲区 这样的规则来满足。然而， 要满足第二个限制的唯一办法是，对同一个打开的套接字描述符打开两个流，一个用来 读，一个用来写：

FILE \*f pi n, \*f pout ;

#### fpin = f d open (s ockf d ,

r" " ) ;

fpout = fdopen (s ockf d , "w") ;

但是这种方 法也有问题， 因为它 要求应用程序在两个流上都要调用 f c l os e , 这样才能释放与每个流相关联的内存资源， 避免内存泄漏：

f c l o s e ( f p i n) ;

f c l os e (f pout ) ;

这些操 作中的每一个都试图关闭同一个底层的套接字描 述符， 所以第二个 c l o s e 操作就会失败。对顺序的程序来说，这并不是问题，但是在一个线程化的程序中关闭一个已经 关闭了的描述符是会导致灾难的（见12. 7. 4 节）。

因此， 我们建议你在网络套 接字上不 要使用标准 I/ 0 函数来进行输入和输出， 而要使

用健 壮的 RIO 函数。如果你需要格式 化的输出，使 用 s p r i n 七f 函数在内存中格式化一个字符串 ， 然后用r i o \_ wr i t e n 把它发送到套接口。如果你需要格式化输入，使 用 r i o

r e a d l i n e b 来读一个完整的文 本行， 然后用 ss c a n f 从文本行提取不同的字段。

10\. 12 小结

Linux 提供了少械的基千 U nix I/ 0 模型的系统级函数．它们允许应用程序打开、关闭、读和写文件， 提取文件的元数据 ， 以及执行 I/ 0 重定向。Linux 的 读和写操 作会出现不足值， 应用程序必须能正确地 预计和处理这种情 况。应用 程序不 应直接调用 Unix I/ 0 函数， 而应该使用 RIO 包， RIO 包通过反复执行读写操作，直到传送完所有的请求数据，自动处理不足值。

Linux 内核使用三个相关的数据结构来 表示 打开的 文件。描述符表中的表项指向打开文件 表中的表项，而打开文件表中的 表项又指向 v-node 表中的表项。每个进程都 有它自己单独的描述符表，而所有的进程共享同一 个打开文件表 和 v-node 表。理解这些结构的一般组成就能使我们 清楚 地理解文件共享和I / 0 重定向。

标准 I/ 0 库是基于 Unix I/ 0 实现的，并 提供 了一组强大的 高级 I/ 0 例程。对千大 多数应用程序而言 ． 标准 I/ 0 更简单， 是优千 U nix I/ 0 的选择。然而 ， 因为对标准 I/ 0 和网络文件的一些相互不兼容的限制， U nix I/ 0 比之标准 I/ 0 更该适用于网络应用程序 。

## 参考文献说明

Kerr is k 撰写了关于 Unix I/ 0 和 Linux 文件系统的综述 [ 62] 。S tevens 编写了 Unix I/ 0 的标准参考文献[ 111] 。Kern igh an 和 Ritc hie 对千标准 I/ 0 函数给出了清晰 而完整的讨论[ 61] 。

## 家庭作业

-   10\. 6 下面程序的输出是什么？

    \#include "csapp.h"

3 int main()

4 {

5 int fdl, fd2;

6

7 fdl = Open("f oo. t xt " , O_RDONLY, 0);

B fd2 = Open("bar.txt", O_RDONLY, O);

9 Cl os e (f d2) ;一

| 10 |   | fd2 = Ope n ( "baz . t xt ", O_RDONLY, O) ; |
|----|---|---------------------------------------------|
| 11 |   | printf("fd2 = 加 \\n", fd2);                |
| 12 |   | exit(O);                                    |
| 13 | } |                                             |

-   10.7

•• 10. 8

\*\* 10. 9

修改图 10-5 中所示的 cpf i l e 程序 ， 使得它用 RIO 函数从 标准输入复制到标 准输出 ，一 次 MAX­

BUF 个字节。

编写图 10-10 中的 s t a t che c k 程序的 一个版本，叫 做 f s 七a t c he c k , 它从命令行上取得一个描述符数字而不是 文件名。

考虑下面对作业题 10. 8 中的 f s t a t chec k 程序的调用：

linux\> fstatcbeck 3 \< foo. txt

你可能会预想这个 对 f s t a t c he c k 的调用将提取和显示文件 f oo . t xt 的元数据。然而，当我们在

系统上运行它时， 它 将失败，返 回 “ 坏 的 文 件 描 述 符＂。 根 据 这 种 情 况 ，填 写 出 s hell 在 f o r k 和

e xe c v e 调 用 之 间 必 须 执 行 的 伪 代 码 ：

if (Fork() == 0) { I\* child•/

/• What code is the shell executing right here?•/ Execve("fstatcheck", argv, envp);

•• 10. 10 修改 图 1 0- 5 中 的 c p f i l e 程 序 ，使 得 它 有 一 个 可选的命令行参数 i n fi l e 。如果给定了 i n f i l e , 那么复制 i n fi l e 到标准输出，否则 像 以 前 那 样 复制标准输入到标准输出。一个要求是对于两种情况，你 的解答都必须使用原来的复制循环（第9\~ 11 行）。只允许你插人代码， 而 不 允 许 更 改 任何已经存在的代码。

# 练习题答案

10\. 1 U nix 进程生命 周期开始时 ，打 开 的 描 述 符 赋 给了 s t d i 认描述符 0 ) 、s t d o u t ( 描述符 1) 和 s t d err

（描述符 2 ) 。o p e n 函数总是返回最低的未打开的描述符，所 以 第 一 次 调用 o p e n 会 返 回 描 述 符 3 。调用 c l os e 函数 会释放 描述符 3 。最 后对 ope n 的调用会返回描述 符 3 , 因此程序的输出是 " f d2 = 3" 。

10\. 2 描 述 符 f d l 和 f d 2 都 有 各 自 的 打 开文件表表项，所 以 每个描述符对于 f oo b a r . t x t 都有它自己的文件位置。因此，从 f d 2 的读操作会读 取 f o o b ar . t x t 的 第一 个字节，并 输 出

C = f

而不是像你开始可能想的

C = 0

10\. 3 回想一下，子进程会继承父进程的描述符表，以及所有进程共享的同一个打开文件表。因此，描述符 f d 在父子进程中都指向同一个打开文件表表项。当子进程读取文件的第一个字节时，文 件 位置加 1。因此， 父进程会读取第二个字节，而 输出就是

C 一 。

10\. 4 重定向标准输人（描述符 0 ) 到描述符 5' 我们将调用 d up 2 (5 , 0 ) 或 者 等 价 的 d up 2 (5 , STDIN \_ F IL E­

NO) 。

10 . 5 第一眼你可能会想输出应该是

C = f

但是因为我们将 f d l 重定向到了 f d 2 , 输出实际上是

C = 0
