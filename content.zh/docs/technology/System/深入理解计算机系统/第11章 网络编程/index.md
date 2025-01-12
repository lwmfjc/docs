第 1 1 章

#### C H A P T E R 11

网络编程

### 网络应用随处可见。任何时候浏览 W eb 、发送 ema il 信息或是玩在线游戏， 你就正在使用网络应用程序。有趣的 是， 所有的网络应用都是基千相同的基本编程模型， 有着相似的整体逻辑结构，并且依赖相同的编程接口。

网络应用依 赖于很多在系统 研究中巳经学习过的概念。例如， 进程、信号、字节顺序、内存映射以及动态内存 分配， 都扮演着 重要的角色。还有一些新概念要掌握。我们需要理解基本的客户端－服务器编程模型 ， 以及如何编写使 用因特网提供的服务的客户端－服务器程序。最后 ， 我们将把所有这些概念结合起来， 开发一个虽小但功能齐全的 Web 服务器 ， 能够为真实的 Web 浏览器提供静态和动态的 文本和图形内容。

1.  1 客户端－服务器编程模型

    每个网络应用都是基千客户端－服务器模型的。采用这个模型，一个应用是由一个服 务器进 程和一个或者多个客户端 进程组 成。服务器管理某种资源， 并且通过操作这种资濒来为它的客户端提供某种服务。例如， 一个 Web 服务器管理着一组磁盘文件， 它会代表客户端进行检索和执行。一个 FT P 服务器管理着一组磁盘文件，它 会为客户端进行存储和检索。相似地 ， 一个电子邮件服务器管理着一些文件，它 为客户端进行读和更新。

    客户端－服务器模 型中的基本操作是 事务 ( t ra nsaction )( 见图 11-1) 。一个客户端－服务器事务由以下四步组成。

    1.  当一个客户端需要服务时 ， 它向服务器发送一个请求， 发起一个事务。例如，当

        Web 浏览器需要一个文件时，它 就发送一个请求给 Web 服务器。

    2.  服务器收到请求后，解 释它， 并以适当的方式操作它的资源。例如， 当 Web 服务器收到浏览器发出的请求后， 它就读一个磁盘文件。
    3.  ) 服务器给客户端发送 一个响应， 并等待下一个请求。例如， Web 服务器将文件发送回客户端 。
    4.  ![](img/1f3a937c2127ae6e334d6e9d5a1fb4ed.jpeg)) 客户端收到响应并处理它。例如， 当 Web 浏览器收到来自服务器的一页后， 就在屏幕上显示此页。

4\. 客户端

处理响应

图 11-1 一个客户端－服务器事务

### 认 识到客户端和服务器 是进程， 而不是常提到的机器或 者主机 ， 这是很重要的。一台主机可以同时运行许多不同的客户端 和服务 器，而 且一个客户端和服务器的事务可以在同一台或是不同的主机上。无论 客户端和服务 器是怎样映射到主机上的，客 户端－服务器模 j 型都是相同的。

#### m 客户端－服务器事务与数据库事务

客户端－服务器 事务 不是 数 据 库事务 ， 没有数据库事务的任何特性， 例如原子性。在我们的上下文中， 事务仅仅是客 户端 和服 务 器执 行 的一 系列 步骤。

1.  2 网络

#### 客户端和服务器通常运行在不同的主机上，并且通过计算机网络的硬件和软件资源来 通信。网络是很复杂的系统，在 这里我们只想了解一点皮毛。我们的目标是从程序员的角度给你一个切实可行的思维模型。

对主机而言，网 络只 是 又一种 I/ 0 设备 ，是 数 据 源和数据接收方，如 图 11-2 所 示 。

一个插到 I/ 0 总线扩展槽的适配器提供了到网络的物理接口。从网络上接收到的数据从适配器经过 I/ 0 和内 存总线复制到内存 ， 通常是通过 DMA 传送。相似地，数 据 也 能 从内存复制到网络。

CPU 芯片

#### Register file

![](img/f99043f0075df46f76d5de38a968b513.jpeg)言 丿 系统总线 内存总线

图 11-2 一个网络主机的硬件组成

#### 物理上而言，网 络 是 一 个 按 照 地理远近组成的层次系统。最低层是 LA N ( Local Area

Network, 局域网），在 一 个 建 筑 或 者 校园范围内。迄今为止， 最 流行的局域网技术是以太网 ( E t hern et ) , 它 是 由 施 乐 公 司 帕 洛阿尔托研究中心 ( Xero x P A RC ) 在 20 世纪 70 年代中期提出的。以太网技术被证明是适应力极强的，从 3 Mb/ s 演变到 l OG b/ s。

![](img/1b80d94c8dcc73a6aae55b93ffe4889d.jpeg)一个以太网段 ( E t hern et seg ment ) 包 括 一 些电缆（通常是双绞线）和一个叫做 集线器的小盒子，如 图 11- 3 所示 。以 太 网 段 通常跨越一些小的 区域， 例 如某建筑物的一个房间或者一个楼层。每根电缆都有相同的最大位带宽， 通常是 l OOMb/ s 或者 l Gb/ s。一端连接到主机的适配器，而另一端则连接到集线器的一个

端口上。集线器不加分辨地将从一个端口上收到的 每个位复制到其他所有 的端 口上。因此， 每台 主机都 能看到每个 位。

每个以太网适配器都有一个全球唯一的 48 位 地址，

它存储在这个适配器的非易失性存储器上。一台主机可 图 11-3 以太网段

以发送一段位（称为帧( fr am e) ) 到这个网段内的其他任何 主机。每个帧包括一些固定数量的 头部 ( h eade r ) 位，用 来标识此帧的源和目的地址以 及此帧的长度， 此后紧随的就是数据位的有效栽荷 ( pa yloa d ) 。每个 主机适配器都能看到这个帧， 但是只有目的主机实际读取它。

使 用一些电缆和叫做网桥( bridge ) 的小盒子，多 个以太网段可以连接成较大的局 域网，

### 称为桥接以太网 ( b ridged Ethernet), 如图 11-4 所示。桥接以 太网能够跨越整个建筑物或者校区。在一个桥接以太网里，一些电缆连接网桥与网桥，而另外一些连接网桥和集线 器。这些电缆的带宽可以是不同的。在我们的示 例中， 网桥与网桥之间的电缆有 l Gb/ s 的带宽 ， 而四根网桥 和集线器之间电缆的带宽却是 l OOM b/ s。

![](img/1687bc7486bdcb1f3e80a061dceb9f11.jpeg)![](img/8a6b908af6dc58a53790923c54640157.jpeg)A

![](img/e3fd88e2a89896e4fd91129c4cbaefb1.jpeg)! Gb/s

![](img/3ca4892e6e74bc668a037de8d8a382fe.jpeg)

图 11-4 桥接以太网

### 网桥比集线器更充分地利用了电缆带宽。利用一种聪明的分配算法， 它们随着时间自动学习哪个主机可以通过哪个端口可达，然后只在有必要时，有选择地将帧从一个端口复 制到另一个端口。例如， 如果主机 A 发送一个帧到同网段上的主机 B, 当该帧到达网桥 X 的 输入端口时， X 就将丢弃此帧， 因而节省了其他网段上的带宽。然而， 如果主机 A 发送一个帧到一个不同网段上的主机 C, 那么网桥 X 只会把此帧复制到和网桥 Y 相连的端口上， 网桥 Y 会只把此帧复制到与主机 C 的网段连接的端口 。

为了简化局域网的表示， 我们将把集线器和网桥以及连接它 们的电缆画成一根水平线， 如图 11-5 所示。

在层次的更 高级别中，多 个不兼容的局域网可以 通过叫做路由器( ro ute r ) 的特殊计算机连接起来， 组成一个 int ern et (互联网络）。每台路由器对于它所连接到的每个网 络都有一个适配器（端口）。路由器也能连接高速点 到点电话连接， 这是称为 W A N ( W啦 -Area

### ![](img/7cef2ac8c2993a29b3de90189d878320.jpeg)Network, 广域网）的网络示例，之所以这么叫是因为它们覆盖的地理范围比局域网的大。一般而言，路由器可以用来由各种局域网和广域网构建互 联网络。例如 ，图 11- 6 展示了一个互联网络的示例， 3 台路由器连接了一对局域

网和一对广域网。 图 11-5 局域网的概念视图

![](img/b5b3d809e38e42f136456aa6aec39adc.jpeg)

图 11 - 6 一个小型的互联网络。三台路由器连接起两个局域网和两个广域网

#### 田日Internet 和 internet

我们总是用小写字母的 in ter net 描述一般概念， 而 用 大写 字母 的 In ter net 来描 述一种具体的 实现，也 就 是 所谓 的全球 IP 因特 网。

互联网络至关重要的特性是，它能由采用完全不同和不兼容技术的各种局域网和广域 网组成。每台主机和其他每台主机都是物理相连的，但是如何能够让某台源主机跨过所有 这些不兼容的网络发送数据位到另一台目的 主机呢？

解决办法是一层运行在每台主机和路由器上的协议软件，它消除了不同网络之间的差 异。这个软件实现一种协议，这 种 协 议 控 制主机和路由器如何协同工作来实现数据传输。这种协议必须提供两种基本能力：

·命名机制。不同的局域网技术有不同和不兼容的方式来为主机分配地址。互联网络 协议通过定义一种一致的主机地址格式消除了这些差异。每台主机会被分配至少一 个这种互联 网络地址( in te rn et address), 这个地址唯一地标识了这台主机。

-   传送机制。在电缆上编码位和将这些位封装成帧方面，不同的联网技术有不同的和 不兼容的方式。互联网络协议通过定义一种把数据位捆扎成不连续的片（称为包）的 统一方式，从 而 消 除 了 这些差异。一个包是由 包头 和有效栽荷组成的，其 中 包 头 包括 包 的 大小 以 及 源主机和目的主机的地址， 有效载荷包括从源主机发出的数据位。

    ．图11-7 展示了主机和路由器如何使用互联网络协议在不兼容的局域网间传送数据的一个示例。这个互联网络示例由两个局域网通过一台路由器连接而成。一个客户端运行在 主机 A 上 ，主 机 A 与 LANl 相连，它 发 送 一 串 数 据 字 节 到 运行在主机 B 上的服务器端， 主机 B 则连接在 LAN2 上 。这个过程有 8 个基本步骤：

#### 1 ) 运行在主机 A 上的客户端进行一个系统调用，从 客户端的虚拟地址空间复制数据到内核缓冲区中。

1.  主机 A 上的协议软件通过在数据前附加互联网络包头和 LA Nl 帧 头 ，创 建 了 一 个

    LANl 的帧。互联网络包 头寻址到互联网 络 主机 B。LANl 帧头寻址到路由器。然后它传送此帧到适配器。注意， LANl 帧的 有效 载荷是一个互联网络包，而 互 联网络包的有效载荷是实际的用户数据。这种封装是基本的网络互联方法之一。

2.  LANl 适配器复制该帧到网络上。

#### 当此帧到达路由器时，路 由 器 的 L ANl 适 配器从电缆上读取它，并 把 它 传 送 到 协议软件。

5 ) 路由 器从互 联 网 络 包 头 中 提 取 出目的互联网络地址，并 用 它 作 为 路 由 表 的 索 引 ， 确定向哪里转发这个包，在 本 例 中是 L AN2。路由器剥落旧的 LANl 的帧头 ，加 上 寻 址 到主机 B 的新的 LA N2 帧 头 ，并 把得到的帧传送到适配器。

1.  路由 器的 L AN2 适 配 器复制该帧到网络上。

### 当此帧到 达主机 B 时， 它的适配器从电 缆上读到此帧 ， 并将它传送到协议软件。

2.  最后， 主机 B 上的协议 软件剥落包头和帧头。当服务器进行一个读取这些数据的系统调用时，协议软件最终将得到的数据复制到服务器的虚拟地址空间。

    主机A 主机B

客户端

( I) 口 歪J i

\< z) I三数据 I产PH Irn三il !

: ( 8 ) 巨 蕴］

i \< 7) I 数据 IPH lrn2I

二二] LAN2

I 3 l 三： 器丧呈 匐 ；三勹丿亘气更

\< 4) I 数据 IPH I阳 1I ! 1 I 数据 IPH IFH2I ( 5 )

图 11 - 7 在互联网络上， 数据是如何从一台主机传送到另一台主机的 ( PH , 互联网络包头；

FHl, LANI 的帧头； FH2, LAN Z 的 帧头）

### 当然，在这里我们掩盖了许多很难的问题。如果不同的网络有不同帧大小的最大值，该怎 么办呢？路由器如何知道该往哪里转发帧呢？当网络拓扑变化时，如何通知路由器？如果一个 包丢失了又会如何呢？虽然如此，我们的示例抓住了互联网络思想的精髓，封装是关键。

11 . 3 全球 IP 因特网

全球 IP 因特网是最著名和最成功的互联网络 实现。从 1969 年起，它 就以这样或那样的形 式存在了。虽 然因特网的内部体系结构复杂而且不断变化， 但是自从 20 世纪 80 年代早期以来，客 户端－服务器应用的组织 就一直保持着相当的稳定。图 11-8 展示了一个因特网客户端－服务器应用程序的基本硬件和软件组织。

![](img/332b2e1e194b2d4e11ae3c7279b4b3cd.jpeg)互联网络客户端主机 互联网络服务器主机

图 1 1-8 一个因特网应用程序的硬件和软件组织

每台因特网主机都运行实现 T CP/ IP 协 议 ( T ransmission Control Protocol/ Internet

### Protocol, 传输控制协 议／互联网络协议）的软件，几 乎每个现代计算机系统都支持这个协议。因特网的客户端 和服务器混合使用 套接宇接 口函数和 U nix I/ 0 函数来进行通信（我们将在 11. 4 节中介绍套接字接口）。通常将套接字函数实现为系统调用， 这些系统调用会陷入内核，并调用各种内核模式的 T CP / IP 函数。

T CP/ IP 实际是一个协议族， 其中每一个都提供不同的功能。例如， IP 协议提供基本的命名方法和递送机制，这种递送机制能够从一台因特网主机往其他主机发送包，也叫做 数 据报 (datagram ) 。IP 机制从某种意义上而言是不可靠的， 因为， 如果数据报在网络中丢失或者重复，它 并不会试图恢复。U DP (Unreliable Datagram Protocol, 不可靠数据报协议）稍微扩展了IP 协议， 这样一来， 包可以在进程间而不是在主机间传送。T CP 是一个构建在 IP 之上的复杂协议， 提供了进程间可靠的全双工（双向的）连接。为了 简化讨论， 我们将 T CP / IP 看做是一个单独的整体协议。我们将不讨论它的内部工作，只 讨 论 T CP 和

IP 为应用 程序提供的某些基本功能。我们将不讨论 UDP。

从程序员的角度，我 们可以把因特网看做一个世界范围的主机集合， 满足以下特性：

-   主机集合被映射为一组 32 位的 IP 地址。
    -   这组 IP 地址被映射为一组称为因特 网域名 (I ntern et domain name) 的标识符 。
    -   因特网主机上的进程能够通过连接(connection) 和任何其他因特网主机上的 进程通信。接下来三节将更详 细地讨论 这些基本的因特网概念。

        日日1P v4 和 1P v6

### 最初的 因特 网 协议， 使 用 32 位地址， 称 为 因 特 网 协议版本 4 ( In t ern et Protocol Version 4, IP v4) 。1996 年， 因 特 网 工程任务组织 (I nte rn et Engin eering Task Force, IETF)提出了一 个新版 本的 IP , 称为 因特 网协议版本 6 CIP v6 ) , 它使 用的 是 128 位地址， 意在替代 IP v4。但是直到 2015 年， 大约 20 年后， 因特 网 流量的 绝大部 分还是由 IP v4 网络 承载的。例如， 只有 4% 的访问 Googl e 服务的用 户使 用 IP v6 [ 42] 。

． 因为 IP v6 的使用率较低， 本 书 不会 讨论 IP v6 的细 节， 而只是集中 注意 力 于 IP v4 背后的 概念。当我们谈论因特 网 时， 我们指的是基于 IP v4 的因特 网。 但是， 本章后 面介绍的 书写客 户端 和服务器的 技术是基于现代接口的，与 任何特殊的协议 无关。

11\. 3. 1 IP 地 址

一个 IP 地址就是一个 32 位无符号整数。网络程序将 IP 地址存放在如图 11-9 所示的

IP 地址结构中。

I\* IP address structure \*I

### struct in_addr {

code/netp/netprfagment.sc

uint32_t s_addr; I\* Address in network byte order (big-endian) \*I

};

### code/netp/nefrtpagments.c

图 11-9 IP 地址结构

### 把一个标量地址存放在结构中， 是套接字接口早期 实现的不幸产物。为 IP 地址定义一个标扯类型应该更有意义， 但是现在更改已经太迟了 ， 因为已经有大量应用是基于此的。

因为因特网主机可以有不同的主机字节顺序， T CP / IP 为任意整数数 据项定义了统一的网络宇节顺序 ( network byte order)(大端字节顺序）， 例如 IP 地址， 它放在包头中跨过网络被

携带。在 IP 地址结构中存放的地址总是以（大端法）网络字节顺序存放的， 即使主机字节顺序

(host byte order) 是小端法。U nix 提供了下面这样的函数在网络和主机字节顺序间实现转换。

\#include \<arpa/inet.h\>

uint32_t htonl(uint32_t hostlong); uint16_t htons(uint16_t hostshort);

uint32_t ntohl(uint32_t netlong); uint16_t ntohs(unit16_t netshort);

返回： 按 照 网 络 字节顺序的值。

返回： 按 照 主 机 字 节顺序的值。

ho t n l 函数将 32 位整数由主机字 节顺序转换 为网络字节顺序。n t o h l 函数将 32 位整数从网络字节顺序转换为主机字节。h t o n s 和 n t o h s 函数为 1 6 位无符号整数执行相应的转换。注意， 没有对应的处 理 64 位值的函数。

IP 地址通常是以一种称为点分十进制表示 法来 表示的，这 里， 每个 字节由它的十进制值表示， 并且用句点和其他字节间分开。例如， 1 28 . 2 . 1 9 4 . 2 42 就是地址 Ox 8 0 0 2 c 2 f 2 的点分十进制 表示。在 L in u x 系统上，你 能够使用 HOST NAME 命令来确定你自己主机的点分十进制地址：

linux\> hostname -i 128.2.210.175

应用程序使用 i ne 七主 t on 和 i ne t \_n t op 函数来实现IP 地址和点分十进制串之间的转换。

\#include \<arpa/inet.h\>

int inet_pton(AF_INET, const char \*src, void \*dst);

返回： 若 成 功则 为 1. 若 s r c 为非 法点 分 十进制地址则 为 o, 若 出错 则 为 一1。

const char \*inet_ntop(AF_INET, const void \*src, char \*dst,

socklen_t size);

返回： 若 成 功 则指向点 分 十进制 字符 串的 指 针 ， 若出错 则 为 NU LL .

在这些函数名中， " n" 代表网络 ， " p " 代表表示。它们可以 处理 3 2 位 1P v4 地址 ( AF_IN­

ET) ( 就像这里展示的那样）， 或者 1 28 位 1P v6 地址 ( AF\_ IN ET 6) ( 这部分我们 不讲）。

i ne t \_p t o n 函数将一个点分十进制串 ( sr c ) 转换为一个二进制的网络字节顺序的 IP 地址( d s t ) 。如果 sr c 没有指向 一个合法的点分十进制字符串， 那么该函数就返回 0。任何其他错误会返回—1, 并设置 err n o 。相似地， i n e t \_ n 七o p 函数将一个二进制的网络字节顺序的 IP 地址( sr c ) 转换为它所对应的点分十进制表示， 并把得到的以 n ull 结尾的字符串的最 多 s i z e 个字节复制到 d s 七。

l 'ia 勹 练 习 题 11. 1 完成下表：

笠 练习题 11. 2 编 写程序 h e x 2d d . c , 将它的十六进制参数转换为点分十进制串并打印

### 出结果。例如

linux\> ./hex2dd Ox8002c2f2 128.2.194.242

练习题 11. 3 编 写程序 d d 2h e x . c , 将它的点分十进制参数转换为十六进制数并打印

### 出结果。例如

linux\> ./dd2hex 128.2.194.242 Ox8002c2f2

### 11. 3. 2 因特网域名

因特网客户端 和服务器互相通信时使用的是 IP 地址。然而， 对于人们而言， 大整数是很难记住的， 所以因特网也定义了一组更加人性化的域名( do m ain name), 以及一种将域名映射到 IP 地址的机制。域名是一串用句点分隔的单词（字母、数字和破折号），例 如 wha l e s h ar k . i c s . c s . c mu . e d u 。

### 域名集合形成了一个层次结构，每个域名编码了它在这个层次中的位置。通过一个示 例你将很容易理解这点。图 11-10 展示了域名层次结构的一部分。层次结构可以 表示为一棵树。树的 节点表示域名，反 向到根的路径形成了域名。子树称为子域( s u bdo m ain ) 。层次结构中的第一层是一个未命名的根节点。下一层是一组 一级 域名（如s t- le ve l domain

name), 由非营利组织 IC A N N (Internet Corporation for Assigned Names and Numbers,

因特网分配名字数字协会）定义。常见的第一层域名包括 c o m、e d u 、g o v 、or g 和 ne t 。

未命名的根

mil edu gov

mit emu berkeley

,,('\\.,

whaIleshark wIww

128.2.210.175 128.2.131.66

com

＼amazon

WWW

176.32.98.166

第一层域名第二层域名第三层域名

图 11-10 因特网域名层次结构的一部分

下一层是二级( s eco nd- le ve l) 域名， 例如 c mu. e d u , 这些域名是由 ! C A N N 的各个授权代理按照先到先服务的基础分配的。一旦一个组织得到了一个二级域名，那么它就可以在 这个子域中创建任何新的域名了，例 如 c s . c mu . e d u 。

因特网定义了域名集合和 IP 地址集合之间的映 射。直到 1988 年， 这个映射都是通过一个叫做 HOSTS. TXT 的文本文件来手工维护的。从那以后， 这个映射是通过分布世界范围内的数据库（称为 D N S ( Do m ain Name System, 域名系统））来维护的。从概念上而言， D NS 数据库由上百 万的主机条目结构 ( h o s t entry structur e ) 组成， 其中每条定义了一组域名和一组 IP 地址之间的映射。从数学意义上讲，可 以认为每条主机条目就是一个域名和

IP 地址的等价类。我们可以用 Lin u x 的 NS LO O K U P 程序来探究 D NS 映射的一些属性， 这个程序能展示与某个 IP 地址对应的域名。e

每台因特网 主机都有本地定 义的域名 l o c a l h o s t , 这个域名总是映射为回送地址

(loop back address) 127.0. 0.1:

linux\> nslookup localhost Address: 127.0.0.1

l ocal host 名字为引用运行在同一台机器上的客户端和服务器提供了一种便利和可移植的方式 ， 这对调试相当有用。我们可以使用 H OST NAME 来确定本地主机的实际域名：

linux\> hostname

wha l e s har k . i c s . cs . cmu . edu

### 在最简单的情况 中， 一个域名和一个 I P 地址之间是一一映射：

linux\> nslookup whaleshark . i sc Address: 128.2. 210. 175

. cs. emu. edu

### 然而， 在某些情况下 ，多 个域名可以映射为同一个 IP 地址：

linux\> nslookup cs.mit.edu Address: 18.62.1.6

linux\> nslookup eecs.mit.edu Address: 18.62.1.6

### 在最通常的情 况下 ，多 个域名可以映 射到同一组的多个 IP 地址：

linux\> nslookup [www .](http://www/) t 忖 i t t er . com

| Address:     | 199.16.156.6     |
|--------------|------------------|
| Address:     | 199. 16. 156. 70 |
| Address:     | 199.16.156.102   |
| Addr e s s : | 199.16.156.230   |

linux\> nslookup twitter.com

| Address: | 199.16.156.102 |
|----------|----------------|
| Address: | 199.16.156.230 |
| Address: | 199.16. 156.6  |
| Address: | 199.16. 156.70 |

### 最后， 我们注意到某些 合法的域名没有映射到任何 IP 地址：

linux\> nslookup edu

\*\*\* Can't find edu: No answer

linux\> nslookup ics.cs.cmu.edu

\*\*\* Can't find i cs. cs . cmu . edu : No answer

### 豆日 有多少因特网主 机？

因特网软件协会 (I ntern et Software Consortium, [www.](http://www/) isc. org) 自从 198 7 年以后，每年进行 两次因特网 域名调查。这个调查通过计算已经分配给一个域名的 IP 地址的数量来估算因特网主机的数量，展 示了一种令人吃惊的趋势。自从 198 7 年以来，当 时一共大约有 20 000 台因特

网主机，主机的数量已经在指数性增长。到2015 年，已经有大约1 000 000 000台因特网主机了。

e 我们重新调整了 NSLOOKUP 的输出以 提高可读性。

11\. 3. 3 因特网连接

### 因特网客户端和服务器通过在连接上发送和接收字节流来通信。从连接一对进程的意义上而言，连接是点对点的。从数据可以同时双向流动的角度来说，它是全双工的。并且从（除了一些如粗心的耕锄机操作员切断了电缆引起灾难性的失败以外）由源进程发出的字 节流最终被目的进程以它发出的顺序收到它的角度来说，它也是可靠的。

一个套接宇是 连接的一个端点。每个套接字都有相应的套接字地 址， 是由一个因特网地址和一个 16 位的整数端口。 组成的，用 “ 地址： 端口” 来表示。

当客户端发起一个连接请求时，客户端套接字地址中的端口是由内核自动分配的，称 为临时 端口 ( e p hem e ra l por t ) 。然而， 服务器套接字地址中的端口通常是某个知名端口， 是和这个服务相 对应的。例如， W e b 服务器通常使用端口 80 , 而电子邮件服务器使用端 口 25 。每个具有知名端口的服务都有一个对应的 知名的服务名。例如， W e b 服务的知名名字是 h t t p , email 的知名名字是 s m七p 。 文件/ e t c / s er v i c e s 包含一张这台机器提供的知名名字和知名端口之间的映射。

### 一个连接是由它两端的套接字地址 唯一确定的。这对套接字地址叫做套接宇对 ( sock et

pair), 由下列元组来表示：

#### (cliaddr:cliport, servaddr:servport)

其中 c l i a d dr 是客户端的 IP 地址 ， c l i por t 是客户端的端口， s er v a d d r 是服务器的 IP 地址 ， 而 s er v p or t 是服务器的端口 。例如，图 11 - 11 展示了一 个 W eb 客户端和一个 Web 服务器之间的连接。

客户端套接字地址

128.2.194.242:51213

服务器套接字地址

208.216.181.15:80

![](img/ca3c51439a52e3df4af0520ae8cd0a07.jpeg)

客户端主机地址

128.2.194.242

图 11-11 因特网连接分析

服务器主机地址

208.216.181.15

在这个示例中， W e b 客户端的套 接字地址 是

128.2.194.242:51213

其中端口号 51 213 是内核分配的临时端口号。Web 服务器的套接字地址是

208 . 216 . 181 . 15 : 80

### 其中端口号 80 是和 W e b 服务相关联的知名端口号。给定这些客户端和服务器套接字地址，客户端和服务器之间的连接就由下列套接字对唯一确定了：

(128.2.194.242:51213, 208.216.181.15:80)

m 因特网的起源

### 因特 网是 政府、学校 和工业界合作的最成功的 示例之一。它成 功的 因素很 多 ， 但 是我们认 为有 两点尤其 重要： 美国政 府 30 年持 续不 变的 投资， 以及充满激 情的 研究人 员

e 这些软件端口与网络中交换机和路由器的硬件端口没有关系。

对麻省理工学院的 Dave Cla rke 提出的 “粗略一致和能用的 代码” 的投入。

因特 网的种 子是在 1957 年播下的 ， 其时正值冷战的高峰 ， 苏联发射 Sput nik , 笫一颗人造地球卫星，震 惊了世界 。作 为响 应， 美国政 府创建了 高级 研 究计划署( ARPA) , 其任务就是重建美国在科学与技 术上的领导地位。1967 年， ARPA 的 Lawrence Roberts 提出了一 个计 划，建 立一个叫做 A阳 决 NET 的新网络。 第一 个 ARPANET 节点是在 1969年建立并运行的 。到 1971 年， 已有 13 个 A团汛 NET 节点 ， 而且 email 作为第一 个重要的网络应 用涌现 出来。

1 972 年，Ro bert Ka hn 概括了网 络互联的一般原则： 一组互相连接的网络 ， 通过叫做“路由器”的黑盒子按照“以尽力传送作为基础”在互相独立处理的网络间实现通 信。1974 年， Ka hn 和 Vinton Cerf 发 表 了 T CP / IP 协议 的第一本详细资料 ， 到 1982 年它成为 了 AR P A NE T 的标准网络 互联协议 。19 83 年 1 月 1 日 ， AR PA NET 的每个节点都切换到 T CP / IP , 标志着全球 IP 因特 网的 诞生。

1985 年， P aul Mocka petris 发明 了 D NS , 有 1 000 多 台 因特 网 主机。1986 年， 国 家科 学基金 会( NS F ) 用 56KB / s 的电话线连接 了 13 个节点 ， 构建了 NSF NET 的骨 干网。其后在 1988 年升级到 1. 5MB/ s T l 的连接速率， 1 991 年为 45MB/ s T 3 的连接速率。到

1988 年， 有 超过 50 000 台 主机。1989 年， 原始的 ARP A NET 正式 退休 了。 199 年， 已经有 几乎 10 000 000 台因特 网主机了 ， NSF 取 消 了 NS F NE T , 并且用基于由公众网络接入点连接的私有商业骨干网的现代因特网架构取代了它。

# 11. 4 套接字接口

套接宇接 口( socket inte rface ) 是一组函数，它 们 和 U nix I / 0 函 数 结 合 起 来 ，用 以 创建网 络应用 。大多 数 现代系统上都实现套接字接口， 包 括 所 有 的 U nix 变种、Windows 和Macintos h 系统。图 11-12 给出了一个典型的客户端－服务器事务的上下文中的套接字接口概述。当讨论各个函数时，你可以使用这张图来作为向导图。

![](img/34f5a3f9a6cd67190cdcc91fb6c5ece4.jpeg)客户端 服务器

### getaddrinfo

s ocke 七

open_l i s t enf d

open_cl i ent f d bi nd

l i s t en

connec 七 连接请求 accept

### r i o_wr i t en r i or\_ ead l i neb

### rio_readlineb r i o_wr i t e n 等待来自下一个

客户端的连接请求

EOF

### close r i o_r eadl i neb

c l os e

图 11-12 基于套接 字接口的网络应用概述

#### m 套接字接口的起源

套接宇接 口是加 州 大学伯 克利分校的研究人员在 20 世 纪 80 年代早期提 出的 。因 为这个原因，它也经常被叫做伯克利套接宇。伯克利的研究者使得套接宇接口适用于任何 底层的协议。笫一 个实现的就是针对 T CP / IP 协议的，他 们把它 包括 在 U n ix 4. 2BS D 的内核里，并且分发给许多学校和实验室。这在因特网的历史上是一个重大事件。几乎一 夜之间，成 于上万的人们接触到 了 T C P / IP 和 它的 源代 码 。 它引起 了 巨 大的轰动， 并激发了新的 网络 和 网络互联研 究的浪潮。

11\. 4. 1 套接字地址结构

从 Lin u x 内核的角度来看， 一 个 套 接 字 就 是 通信的一个端点。从 Lin u x 程序的角度来看，套接字就是一个有相应描述符的打开文件。

因特网的套接字地址存放在如图 11 -1 3 所示的类型为 s o c ka d d r \_ i n 的 1 6 字节结构中。对于因特网应用， s i n \_ f a mi l y 成 员 是 AF_INET, sin \_por t 成员是一个16 位的端口号， 而 s i n a d dr 成员 就 是 一 个 32 位 的 I P 地址。IP 地址和端口号总是以网络字节顺序（大端法）存放的。

code/netp/netpfragments.c

I\* IP socket address structure \*I

struct sockaddr_in {

uint16_t sin_family; I\* Protocol family (always AF_INET) \*I uint16_t sin_port; I\* Port number in network byte order \*I struct in_addr sin_addr; I\* IP address in network byte order \*I unsigned char sin_zero[8]; I\* Pad to sizeof(struct sockaddr) \*I

｝；

I\* Generic socket address structure (for connect, bind, and accept) \*I

struct sockaddr {

uint16_t sa_family; I\* Protocol family \*I

char sa_data[14]; I\* Address data \*I

} ;

田日\_ in 后缀意味什么？

图 11-13 套接字地址结构

code/netp/netpfragments.c

in 后缀是互联 网络 ( in t ern e t ) 的缩写， 而不 是输入( in put ) 的缩写。

c o n n e c t 、 b i n d 和 a c c e p t 函数要求一个指向 与协 议 相关的 套 接字地址结 构的 指针。套接字接口的设计者面临的问题是，如何定义这些函数，使之能接受各种类型的套接字地 址结构。今天我们可以使用通用的 V O 过＊ 指针， 但 是 那时在 C 中并不存在这种类观的指针。解决办法是定义套接字函数要求一个指向通用 s o c ka d dr 结构（图 11 -1 3 ) 的指针， 然后要求应用程序将与协议特定的结构的指针强制转换成这个通用结构。为了简化代码示 例， 我们跟随 S te ven 的指导，定 义 下 面的类型：

typedef struct sockaddr SA;

然后无论何时需要将 s o c ka d dr \_ i n 结构强制转换成通用 s o c ka ddr 结构时， 我们都使用这个类型。

11\. 4. 2 s o c k e 七 函 数

客户端和服务器使用 s o c ke t 函数来创建一个套接字描 述符( s ock e t d es cri pto r ) 。

\#include \<sys/types.h\>

\#include \<sys/socket.h\>

int socket(int domain, int type, int protocol);

返回： 若 成 功则 为非 负描 述 符 ， 若出铢则 为 一1.

如果想要使套接字成为连接的一个端点， 就用如下硬编码的参数来调用s o c ke t 函数：

clientfd = Socket(AF_INET, SOCK_STREAM, O);

其中， AF_INET 表明我们 正在使用 32 位 IP 地址，而 SOCK_ST REAM 表示这个套接字是连接的一个端点。不过最好的方法是 用 g e 七a d dr i n f o 函数( 11. 4. 7 节）来自动生成 这些参数， 这样代码就与协议无关了。我们会在 1 1. 4. 8 节中向你展示如何配合 s o c ke t 函数来使用 g e t a d dr i n f o。

s o c ke t 返回的 c l i e n 七f d 描述符仅是部分打开的，还 不能用于读写。如何完成 打开套接字的工作，取决于我们是客户端还是服务器。下一节描述当我们是客户端时如何完成 打开套接字的工作。

11\. 4. 3 c o n n e c 七函 数

客户端通过调用 c o n ne c 七函数来建立和服务器的连接。

\#include \<sys/socket.h\>

int connect(int clientfd, const struct sockaddr \*addr, socklen_t addrlen);

返回： 若 成 功 则为 o, 若 出错 则 为一l 。

c o n ne c t 函数试图与套接字地址为 a ddr 的服务器建立 一个因特网连接，其中 a dd rl en 是 s i z e o f (s o c ka d dr \_ i n ) 。c o nne c t 函数会阻塞， 一直到连接成功建立或是发生错误。如果成功， c l i e n t f d 描述 符现在就准备好可以读写了，并 且得到的连接是由套接字对

(x:y, addr.sin_addr:addr.sin_port)

刻画的， 其中 x 表示客户端的 IP 地址 ， 而 y 表示临时端口，它唯 一地确定了客户端主机上的客户端进程。对于 s o c k e t , 最好的方法是用 g e t a d dr i n f o 来为 c o n n e c t 提供参数

（见 11. 4. 8 节）。

11 . 4. 4 b i nd 函数

剩下的套接字函数- b i nd 、 江 s t e n 和 a c c e p t , 服务器用它们来和客户端建立连接。

\#include \<sys/socket.h\>

int bind(int sockfd, const struct sockaddr \*addr, socklen_t addrlen);

返回： 若 成 功则 为 o, 若 出错 则 为— l。

#### 区 nd 函数告 诉内 核将 ad dr 中的服务器套接字地址和套接字描述符 s oc kf d 联系起来。参数 a d d r l e n 就是 s i z e o f ( s o c ka ddr \_ i n ) 。 对 千 s o c ke t 和 c on ne c t , 最好的方法是用 ge t a d d r i nf o 来为 b i nd 提供参数（见11. 4. 8 节）。

11\. 4. 5 l i s 七 e n 函 数

#### 客户端是发起连接请求的主动实体。服务器是等待来自客户端的连接请求的被动实 体。默认情况下，内 核会认为 s o c k吐 函数创建的描述符对应于主动套接 宇 ( act ive sock­

et), 它存在于一个连接的客户端。服务 器调用 1 工s t e n 函 数 告 诉 内 核 ， 描 述符是被服务器而不是客户端使用的。

\#include \<sys/socket.h\>

int listen(int sockfd, int backlog);

返回： 若 成 功 则 为 o , 若 出错 则为 一1。

#### 让 s t e n 函数将 s o c kf d 从一个主动套接字转化为一个监听套接宇 (l is te ning socket), 该套接字可以接受来自客户端的连接请求。ba c kl og 参数暗示了内核在开始拒绝连接请求之前，队列 中要 排队 的 未 完成的连接请求的数量。b a c kl og 参数的确切含义要求对 TCP/ IP 协议的理解， 这 超 出 了 我们讨论的范围。通常我们会把它设 置为一个较大的值， 比如 10 24。

1.  4\. 6 a c c e p 七 函 数

#### 服务器通过调用 a c c e p t 函数来等待来自客户端的连接请求。

\#include \<sys/socket.h\>

int accept(int listenfd, struct sockaddr \*addr, int \*addrlen);

返回： 若 成 功 则 为非 负连 接 描 述 符 ， 若 出错 则 为— l 。

#### a c c e p t 函数等待来自客户端的连接请求到达侦听描述符 l i s t e n f d , 然后在 a ddr 中填写客户端的套接字地址，并 返回一个已连接描述符( connect ed descriptor) , 这个描述符可被用来利用 U nix I/ 0 函数与客户端通信。

监听描述符和巳连接描述符之间的区别使很多人感到迷惑。监听描述符是作为客户端 连接请求的一个端点 。它通常被创建一次，并 存 在 千服务器的整个生命周期。已连接描述符是客户端和服务器之间已经建立起来了的连接的一个端点。服务器每次接受连接请求时 都会创建一次， 它只 存 在 于服务器为一个客户端服务的过程中。

图 11-14 描绘 了监 听描 述 符 和已 连接描述 符的 角色。在第一 步 中， 服 务 器 调 用

accept, 等待连接请求到达监听描述符，具 体 地我们设定为描述符 3。回忆一下， 描 述 符

0\~ 2 是预留给了标准文件的。

在第二步中，客 户端调用 c o nne c t 函数， 发 送 一个连接请求到 l i s t e n f d。第三步， a c c e p t 函 数 打 开了一个新的已连接描述符 c o nn f d ( 我们假设是描述符 4 )' 在 c l i e n 七f d 和 c o nn f d 之间建立连接，并 且 随 后 返 回 c o n n f d 给应用程序。客户端也从 c on ne c t 返回， 在这一点以后， 客户端和服务器就可以分别通过读和写 c l i e n t f d 和 c o nn f d 来回传送数据了。

曰clientfd

l i st enfd(3)

l 服务器阻塞在 a cce pt , 等待监听描述符l i s t e nf d 上的连接请求。

连接请求 li s t e n f d (3 )

三 －－－－－－－ **－**－－－－］ 三

c l i e n 七 f d

1.  客户端通过调用和阻塞在 conne c t ,

#### 创建连接请求。

![](img/52bec4632b46a669392f21b746e3cda7.jpeg)li s t e n f d (3 )

c l i e n t f d c onn f d ( 4 )

1.  服务器从 ac ce pt 返回 connf d。客户端从 co nne c t 返回。现在在 c巨 ent f d 和co nn f d 之间已经建立起了连接。

图 11-14 监听描述符和已 连接描述符的角色

#### 田 日 为何 要有监听描述符和已连接描述符之间的区别？

你可能很想知道为什 么套 接 宇接 口要区别监听描述符和已连接描述符。乍 一看，这像 是不必要的复杂化。然而， 区分这两者被 证明是 很有用的 ， 因 为 它使 得 我们可以建 立并发服务器， 它能够同时处理许多客 户端 连接。例如，每 次一个连接请求到达监听描述符时， 我们可以派生( fork) 一个新的进程， 它通 过 已连接描述符与客 户端通信。在第 12 章 中将介绍更多 关于并发服务器的 内容。

1.  4\. 7 主机和服务的转换

    Linu x 提供了一些强大的函数（称为 ge t a ddr i n f o 和 ge t name i n f o ) 实现二进制套接字地址 结 构 和主机名、主机地址、服务名和端口号的字符串表示之间的相互转化。当和套接字接口 一起 使用 时 ， 这些函数能使我们编写独立于任何特定版本的 IP 协议的网络程序。

    1.  ge ta d d rinfo 函数

        g e t a d dr i n f o 函数将主机名、主机地址、服务名和端口号的字符串表示转化成套接字 地 址 结 构 。 它 是巳弃用的 g e t h o s 七b y n a me 和 g e t s e r v b yn a me 函数 的 新的替代品。和以前 的那些 函数不同 ， 这 个 函 数 是 可重入的（见12. 7. 2 节），适用 于任 何 协议 。

        \# i nc l ude \<s y s / t yp e s . h\>

        \#include \<s ys / s ocke t . h \>

        \#include \<net db . h \>

        int getaddrinfo(const char \*host , const char \*ser vi ce, const struct addrinfo \*hints,

        str uct addrinfo \*\*result ) ;

        返回： 如 果 成 功 则 为 0 . 如 果 错 误 则 为非 零的错误代码。

        void fr eeaddri nfo(str uct addr i nfo \*resul t ) ;

const char \*gai \_s tr err or ( i nt errcode);

返回： 无．

返回： 错 误 消息。

给定 ho s t 和 s er v i c e ( 套接字地址的 两个组成部分），g e t a d d r i n f o 返回 r e s ult ,

r e s u l t 一个指向 a d dr i n f o 结构的链表，其 中 每个结构指向一个对应于 h o s t 和 s e r vi ce ,

的套接字地址结构（图11-15) 。

#### result

addr i nf o结构

![](img/cf335680aae5b61a17b09e716b258f69.jpeg)ai canonname 套接字地址结构

#### ai addr

ai nex 七

NULL

#### ![](img/b716bd39b239fd8774d7dc9b6013d00d.jpeg)ai addr

ai next

NULL

![](img/b14d4299c3c566f49173e06eefa34e3d.jpeg)

NUL L

图 11-15 get addr i nfo 返 回的数据结构

#### 在客户端调用了 ge t addr i nfo 之后，会 遍历这个列表，依 次尝试每个套 接字 地址 ，直 到调用 s oc ke t 和 conne c t 成功，建立起 连接。类似地，服 务器会尝试遍历列表中的每个套接字地址， 直到调用 s oc ke t 和 b i nd 成功，描 述符会 被绑定到一个合法的套接字地址。为了避免内存泄漏，应用程序必须 在最 后调用 fr ee a ddr i nf o , 释放 该链表。如果 ge t addr i nfo 返回非零的错误代码， 应用程序可以调用 ga i \_s tr eer or , 将该代码转换成消息字符串。

ge t addr i nfo 的 hos t 参数 可以是 域名，也 可以是数字地址（如点分 十进制 IP 地址）。se rv i ce 参数可以是服务名（如h七七p )' 也 可以是十进制端口号。如果不想把主机名转换成地址， 可以把 hos t 设置为 NULL。对 s e rv i ce 来说也是一样。但是必须指定两者中至少一个。

可选的参数 hi n t s 是一个 a ddr i nf o 结构（见图 11-16 ) , 它提供对 g e t a ddr i n f o 返回的套接字地址列表的更好的控制。如果要传递 h i nt s 参数，只 能 设 置 下 列 字 段 ： ai_fam­ il y、ai \_ sockt ype、ai \_ pr ot ocol 和 ai \_ f l ags 字段。其他字段必须设置为 0 (或NU LL) 。实际中， 我们用 me ms e 七将 整 个 结 构 清 零 ，然 后 有 选择地设置一些字段：

-   g e t a ddr i n f o 默 认 可以返回 IP v4 和 IPv6 套接字地址。a i \_ f a m过 y 设 置 为 AF \_IN­ ET 会将列表限制为 IPv4 地址；设 置 为 AF \_ INET 6 则 限 制 为 IP v6 地址。

#### 对于 h o s t 关联的每个地址， g e t a d dr i n f o 函 数 默 认 最 多 返 回 三个 a ddr i n f o 结构， 每个的 a i \_s oc kt yp e 字段不同：一 个 是 连接， 一 个 是数据报（本书未讲述），一 个是 原 始 套 接 字（本 书未 讲 述 ）。 a i \_ s o c k t yp e 设 置为 SOCK_STREAM 将列表限制为对每个地址最多一个 a d dr i n f o 结构，该 结 构 的 套 接 字 地址可以作为连接的一个端点。这是所有示例程序所期望的行为。

-   a i \_ fl a gs 字段是一个位掩码， 可 以 进一步修改默认行为。可以把各种值用 OR 组合起来得到该掩码。下面是一些我们认为有用的值：

    AI_ADDRCONFIG。如果在使用连接，就 推荐使用这个标志 [ 34] 。它要求 只有当

    本地主机被配置为 IPv4 时 ， ge 七a ddr i nfo 返 回 IPv4 地址。对 IPv6 也是类似。

#### AI_CANONNAME 。a i \_c a no n na me 字 段默认为 NU LL。如果设 置了该标志， 就是告诉 ge t a d dr i n f o 将列表中第一个 ad dr i n f o 结构的 a i \_ca no nna me 字 段 指 向h o s t 的 权 威（官 方 ）名字（见 图 11 - 1 5) 。

AI_NU MERICSERV 。参数 s er v i c e 默认可以是服务名或端口号。这个标志强制参数 s er v i c e 为端口号。

AI—P ASSIVE。ge t a ddr i n f o 默认返回套接字地址， 客户端可以 在调用 c o nne c t 时用作主动套接字。这个标志告诉该函数，返回的套接字地址可能被服务器用作监听套接字。在这种情况中，参 数 ho 江 应该 为 NU LL。得到的套接字地址结构中的地址字段会是通配符地址 ( w ild card address) , 告诉内核这个服务器会接受发送到该主机所有 IP 地址的请求。这是所有示 例服务器所期望的行为。

code/netp/netpfragments.c

struct addrinfo { int

int int int char

size_t

ai_flags; I\* Hints argument flags \*I ai_family; I\* First arg to socket function \*I ai_socktype; I\* Second arg to socket function \*I ai_protocol; I\* Third arg to socket function \*I

\*ai_canonname; I\* Canonical hostname \*I ai_addrlen; I\* Size of ai_addr struct \*I

struct sockaddr \*ai_addr; struct addrinfo \*ai_next;

};

I\* Ptr to socket address structure \*I I\* Ptr to next item in linked list \*I

codelnetp/netpfragments.c

图 11-16 ge t addr i nfo 使用的 addr i nf o 结构

当 g e t a d dr i n f o 创建输出列表中的 a d dr i n f o 结构时， 会填写每个字段，除 了 a i

f l a g s 。a i \_a d dr 字段指向一个套接字地址结构， a i \_ a d dr l e n 字段给出这个套接字地址结构 的大小， 而 a i \_ n e x t 字段指向列表中下一个 a d dr i n f o 结构。其他字段描述这个套接字地址的各种属性。

g e t a d dr i n f o 一个很好的方面是 a d dr i n f o 结构中的字段是不透明的， 即它们可以直接传递给套接字接口中的函数， 应用程序代码无需再做任何处理。例如， a i \_ f a mi l y、a i

s o c k t y p e 和 a i \_ p r o t o c o l 可以 直接传递给 s o c ke t 。类似地， a i \_ a d dr 和 a i \_ a d d r l e n 可以直接传递给 c o n n e c t 和 b i nd 。这个强大的属性使得我们编写的客户端和服务器能够独立于某个特殊版本的 IP 协议。

1.  ge tna me info 函数

    g e t n a me i n f o 函数和 g e t a d dr i n f o 是相反的， 将一个套接字地址结构转换 成相应的主机和服务名字符串 。它是已弃用的 g e t h o s t b y a d dr 和 g e t s er v b y p or t 函数的新的替代品 ，和 以前的那些函数不同， 它是可重入和与协议无关的。

\#include \<sys/socket.h\>

\#include \<netdb.h\>

int getnameinfo(const struct sockaddr \*sa, socklen_t salen, char \*host, size_t hostlen,

char \*service, size_t servlen, int flags);

返回： 如 果 成 功则 力 o. 如果错误则为非零的错误代码。

参数 s a 指向大小为 s a l e n 字节的套接字地址结构， h o s t 指向大小为 h o s t l e n 字节的缓冲区， s e rv i c e 指向大小为 s er v l e n 字节的缓冲区。g e t narne i n f o 函数将套接字地址结构 sa 转换成对应的主机和服务名字符串，并将它们复制到 ho s t 和 s e rv c i ce 缓冲区。如果 ge t narn-

e i nf o 返回非零的错误代码， 应用程序可以调用ga i \_s tr err or 把它转化成字符串。

如果不想要主机名 ，可 以把 h o s t 设置为 N U L L , h o s 七l e n 设置为 0 。对服务字段来说也是一样。不过， 两者必须设置其中 之一。

参数 f l a g s 是一个位掩码， 能够修改默认的行为。可以 把各种值用 O R 组合起来得到该掩码。下面是两个有用的值：

-   N I_N U M E R IC H OS T 。g e t na me i n f o 默认试图返回 h o s t 中的域名。设置该标志会使该函数返回一个数字地址字符串。
-   NI_N U MERICSER V。ge t name i n f o 默认会检查/ e 七c / s er v i c e s , 如果可能，会返回

    服务名而不是端口号。设置该标志会使该函数跳过查找，简单地返回端口号。

    图 11-17给出了一个简单的程序 ， 称为 H OST INF O . 它使用ge t a ddr i nfo 和 ge t name i nf o 展示出域名到和它相关联的 IP 地址之间的映射。该程序类 似于 11. 3. 2 节中的 NSLOO KU P 程序。

1 \#include "csapp.h"

2

3 int main(int argc, char \*\*argv)

4 {

s struct addrinfo \*P, \*listp, hints;

1.  char buf[MAXLINE];
2.  int re, flags;

    8

    9 if (argc != 2) {

3.  fprintf (stderr, "usage: i儿 s \<domain name\>\\n", argv[O]);
4.  exit(O);

    12 }

    13

5.  I\* Get a list of addrinfo records \*I
6.  memset(&hints, 0, sizeof(struct addrinfo));
7.  · hi nt s . a i\_ f am辽 y = AF_INET; I\* IPv4 only \*I
8.  hints.ai_socktype = SOCK_STREAM; I\* Connections only \*I

    code/netp/hostinfo.c

5.  if ((re = getaddrinfo(argv[1], NULL, \&hints, \&listp)) != 0) {
6.  fprintf(stderr, "getaddrinfo error: %s\\n", gai_strerror(rc));
7.  exit(!);

    21 }

    22

8.  I\* Walk the list anddisplay each IP address \*I
9.  flags= NI_NUMERICHOST; I\* Display address string instead of domain name \*I
10. for (p = listp; p; p = p-\>ai_next) {
11. Getnameinfo (p-\>ai_addr, p-\>ai_addrlen, buf, MAXLINE, NULL, 0, flags) ;
12. printf("%s\\n", buf); 28 }

    29

13. I\* Clean up \*I
14. Freeaddrinfo(listp); 32

    33 exit(O);

    34 }

code/netp/hostinfo.c

图 11-17 H OSTINFO 展示出域名到 和它相关联的 IP 地址之间的 映射

首先， 初始化 h i n t s 结构，使 g e t a ddr i n f o 返回我们想要的地址。在这里，我 们想查找 32 位的 IP 地址（第16 行），用 作连接的端点（第1 7 行）。因为只想 ge t a ddr i nf o 转换域名， 所以用 s er v i c e 参数为 N U L L 来调用它。

调用 g e t a ddr i n f o 之后， 会遍历 a ddr i n f o 结构，用 g e t na me i n f o 将每个套接字地址转换成点分十进制地址字符串 。遍历完列表之后 ， 我们调用 fr e e a d dr i n f o 小心地释放这个列表（虽然对于这个简单的程序来说 ，并 不是严格需要这样做的）。

运行 H OST INF O 时，我们 看到 t wi 七七e r . c om 映射到了四个 IP 地址， 和 11. 3. 2 节用

NS LO O K U P 的结果一样。

#### linux\> ./hostinfo t 甘i t t er .com 199.16.156.102

199.16.156.230

199.16.156.6

199.16.156.70

练习题 11. 4 函数 ge t a dd r i n fo 和 ge t narne i nf o 分别包含 了 i ne t \_p t o n 和 i ne t \_ n t op 的功能，提供 了 更高 级别的、 独 立于任 何特殊地 址格 式的 抽象。想看看这 到底 有多方便， 编写 H OST INFO ( 图 11-17 ) 的一个版本，用 i ne t 主 t on 而不是 ge t narne i nf o 将每个套接字地址转换成点 分十进制地址 字符 串。

1.  4\. 8 套接字接口的辅助函数

    初学时， g e t na me i n f o 函数和套接字接口看上去有些可怕。用高级的辅助函数包装一下会方便很多 ， 称为 o pe n\_ c l i e nt f d 和 o p e n 让 s t e n f d , 客户端和服务器互相通信时可以使用这些函数。

#### o pe n_c lie ntfd 函数

客户端调用 o p e n\_ c l i e n t f d 建立与服务器的连 接。

![](img/d930a8f540b79ad166bd12fe8412a907.jpeg)

o pe n_c l i e nt f d 函数建立与服务器的连接，该 服务器运行 在主机 h os t na me 上， 并在端口号 p or t 上监听连接请求。它返回一个打开的套接字描述符，该 描述符准备好 了，可以用 U nix 1/0 函数做输入和输出。图 11-18 给出了 ope n\_ c l i e n t f d 的代码。

我们调用 g e t a ddr i n f o , 它返回 a ddr i n f o 结构的列表，每 个结构指向一个套接字地址结构，可用 于建立与服务器的 连接，该 服务器运行 在 hos t na me 上并监听 po 江 端口。然后遍历该列表， 依次尝试列表中的每个条目， 直到调用 s o c ke t 和 c o n ne 吐 成功。如果c o n ne c t 失败 ， 在尝试下一个条目之前， 要小心地关闭套接字描述符。如果 c o n ne c t 成功，我们会释放列表内存，并把套接字描述符返回给客户端，客户端可以立即开始用

Unix 1/0 与服务器通信了 。

注意， 所有的代码都与任何 版本的 IP 无关。 s o c ke t 和 c o n ne c t 的参数都是用

g e 七a dd r i n f o 自动产生的， 这使得我们的代码干净可移植。

#### ope n\_ lis te nfd 函数

调用 ope n_l i s t e n f d 函数， 服务器创建一 个监听描述符， 准备好接收连接请求。

\#include "csapp.h"

int open_listenfd(char \*port);

返回： 若 成 功则 为描 述 符 ， 若出错 则为 一1。

1 int open_clientfd(char \*hostname, char \*port) { int clientfd;

3 struct addrinfo hints, \*listp, \*Pi

code/srdcsapp.c

1.  I\* Get a list of potential server addresses \*I
2.  memset(&hints, 0, sizeof(struct addrinfo));
3.  hints.ai_socktype = SOCK_STREAM; I\* Open a connection \*I
4.  hints.ai_flags = AI_NUMERICSERV; I\* ... using a numeric port arg. \*I
5.  hints.ai_flags I= AI_ADDRCONFIG; I\* Recommended for connections \*I
6.  Getaddrinfo(hostname, port, \&hints, \&listp);
1.  I \* 扣 al k the list for onethat we can successfully connect to \*I
2.  for (p = listp; p; p = p-\>ai_next) {
3.  / \* Create a socket descriptor \*I
4.  if ((clientfd = socket (p-\>ai_family, p-\>ai_socktype, p-\>ai_protocol))
5.  \< O) continue; I\* Socket failed, try the next \*I
1.  I\* Connect to the server \*I
2.  if (connect (clientfd, p-\>ai_addr, p-\>ai_addrlen) != -1)
3.  break; I\* Success \*I
4.  Close(clientfd); I\* Connect failed, try another \*I 22

    23

5.  I\* Clean up \*I
6.  · Fr e e addr i nfo (listp);
7.  if (! p) / \* All connects failed \*I
8.  return -1·
9.  else I\* Thelast connect succeeded \*I
10. return clientfd;

    30 }

code/srdcsapp.c

图 11-18 open_clientfd: 和服务器建立连 接的辅 助函数 。它是可重入 和与协议无关的

op e n_l i s t e n f d 函数打开和返回一个监听描述符， 这个描述符准备好在端口 p or t 上接收连接请求。图 11 -19 展示了 o pe n\_ l i s t e n f d 的代码。

op e n\_ l i s 七e n f d 的 风 格类似于 ope n \_ c l i e n七f d 。 调 用 g e t a ddr i n f o , 然后遍历结果列表，直 到调用 s o c ke t 和 b i nd 成功。注意，在 第 20 行， 我们使用 s e t s o c ko p t 函数（本书中没有讲述）来配置服务器，使得服务器能够被终止、重启和立即开始接收连接请求。一个重 启的服务器默认将在大约 30 秒内拒绝客户端的连接请求，这严 重 地阻碍了调试。

因为我们调用 ge t a d dr i n f o 时， 使 用 了 AI \_ PASSIVE 标志并将 h o s t 参数设 置为

#### NULL, 每个套接字地址结构中的地址字段会被设置为通配符地址， 这告诉内核这个服务器会接收发送到本主机所有 IP 地址的请求。

code/srdcsapp.c

1 int open_listenfd(char \*port)

2 {

3 struct addrinfo hints, \*listp, \*p;

4 int listenfd, optval=l;

5

6 I\* Get a list of potential server addresses \*I memset(&hints, 0, sizeof(struct addrinfo));

hints.ai_socktype = SOCK_STREAM; hints.ai_flags = AI_PASSIVE I AI_ADDRCONFIG; hints.ai_flags I= AI_NUMERICSERV; Getaddrinfo(NULL, port, \&hints, \&listp);

I\* Accept connections \*I

I\* . . . on any IP address \*I I\* ... using port number \*I

13 / \* Walk the list for onethat we can bind to•/

14 for(p= listp; p; p = p-\>ai_next) {

15 / \* Create a socket descriptor•I

1.  if ((listenfd = socket (p-\>ai_family, p-\>ai_socktype, p-\>ai_protocol))
2.  \< 0) continue; /• Socket failed, try the next•I

    18

3.  /• Eliminates "Address already in use" error from bind•/
4.  Setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR,
5.  (const void•)&optval , sizeof (int));

    22

    23 I• Bind the descriptor to the address•/

    24 if (bind(listenfd, p-\>ai_addr, p-\>ai_addrlen) == 0)

6.  break; I\* Success•I
7.  Close(listenfd); I• Bind failed, try the next•I

    27 }

    28

8.  I\* Clean up•I
9.  Freeaddrinfo (listp) ;
10. if (!p) I\* No address worked•/
11. return -1;

    33

12. I• Make it a listening socket ready to accept connection requests•I
13. if (listen(listenfd, LISTENQ) \< 0) {
14. Close (listenfd) ;

    37 return -1;

    38 }

    39 return listenfd;

    40 }

    code/srdcsapp.c

图 11- 1 9 open_listenfd: 打开并返回监听描述符的辅助函数。它是可重人和与协议无关的

最后， 我们调用 li s 七e n 函 数 ，将 l i s 七e n f d 转 换 为 一 个 监 听 描 述符，并 返 回 给调用者。如果 l i s t e n 失败 ，我 们 要小 心 地避免内存泄漏，在 返回前关闭描述符。

11\. 4. 9 e c ho 客户端和服务器的示例

学习套接字接口的最好方法是研究示 例代码。图 11-20 展示 了一个 ech o 客户端的代

#### 码。在和服务器建立连接之后，客户端进入一个循环，反复从标准输入读取文本行，发送 文本行给服务器，从 服务器读取回送的行，并 输 出 结 果 到 标准输出。当 f g e t s 在标准输人上遇到 EOF 时，或 者 因 为用户在键盘上键入 Ctrl + D, 或者因为在一个重定向的输入文件中用尽了所有的文本行时，循环就终止。

code/netplechoclient.c

\#include "csapp.h"

3 int main(int argc, char••argv) int clientfd;

6 char \*host, \*port, buf[MAXLINE] ;

rio_t rio;

9 if (argc != 3) {

1O fprintf (stderr, "usage: %s \<host\> \<port\>\\n", argv [0]) ; exit(O);

12

1.  host = argv[1];
2.  port = argv [2] ;

    15

3.  clientfd = Open_clientfd (host, port);
4.  Rio_readinitb(&rio, clientfd);

    18

5.  吐 hil e (Fgets(buf, MAXLINE, stdin) != NULL) {
6.  Rio_i.riten(clientfd, buf, strlen(buf));
7.  Rio_readlineb(&rio, buf, MAXLINE);
8.  Fputs (buf, stdout) ;

    23

9.  Close (clientfd) ;
10. exit(O);

    26 }

    code/netplechoclient.c

图 11-20 echo 客户端的 主程序

循环终止之后 ， 客户端关闭描述符。这会导致发送一个 EOF 通知到服务器， 当 服务器从它的 r e o \_r e a d l i n e b 函数收到一个为零的返回码时， 就会检测到这个结果。在关闭它的描述符后， 客户端就终止了。既然客户端内核在一个进程终止时会自动关闭所有打开的描述符 ，第 24 行的 c l o s e 就没有必要了。不过，显 式 地 关 闭 已经打开的任何描述符是一个良好的编程习惯。

#### 图 11-21 展示 了 e ch o 服务 器的 主程序。在打开监听描述符后， 它 进入一个无限循环。每次循环都等待一个来自客户端的连接请求，输 出 已 连接客户端的域名和 IP 地址，并 调 用 e c h o 函 数 为 这些客户端服务。在 e c h o 程序返回后， 主程序关闭巳连接描述符。一旦客户端和服务器关闭了它们各自的描述符，连接也就终止了。

第 9 行 的 c l i e n t a d dr 变量是一个套接字地址结构，被 传 递给 a c c e p t 。在 a c c e p t 返

回之前， 会在 c 让 e n t ad dr 中填 上连接另一端客户端的套接字地址。注意， 我们将 c l i ­

e n t a d dr 声明为 s 七r u c t sockaddr \_s七or a g e 类 型 ， 而 不 是 s 七r u c t sockaddr \_i n 类型。根据定义， s o c ka d dr \_ s t or a g e 结 构 足 够 大能 够装下任何类型的套接字地址，以 保 持 代 码 的协议无关性。

cod e/ netp/ ech oserveri.c

\#include "csapp.h"

2

3 void echo (int connfd);

4

5 int rnain(int argc, char \*\*argv)

6 {

1.  int listenfd, connfd;
2.  socklen_t cl i ent l en;
3.  struct sockaddr_storage clientaddr; I\* Enough space for any address \*I

    1O char client_hostname [MAXLINE] , client_port [MAXLINE] ;

    11

4.  if ( ar g c != 2 ) {
5.  fprintf (stderr, "usage: %s \<port\>\\n", argv [OJ ) ;
6.  e x i t ( O) ;

    15 }

    16

7.  listenfd = Open_listenfd(argv [1]);
8.  while (1) {
9.  clientlen = s i ze of ( s tr uc t sockaddr_storage);
10. connfd = Ac ce pt ( l i s t e nf d , (SA \* ) \&cl i e nt add r , \&c l i ent l en ) ;
11. Ge t n ame i nfo (( S A \* ) \&clientaddr, clientlen, cli ent_hotsname , MAXLI NE,
12. client_port, MAXLINE, 0 ) ;
13. pr i nt f ( "Conn e c t ed to ( %s , %s ) \\ n " , client_hostname, cl i ent \_por t ) ;
14. echo (connfd) ;
15. Close (connf d) ;

    26 }

    27 exit(O);

    28 }

code/netplechoserveri.c

图 11- 21 迭代 echo 服务楛的主程序

注意 ， 简单的 e c h o 服务器一次只能处理一个客户端。这种类型的服务器一次一个地在客户端间迭代， 称为迭代服务器 ( iterative server)。在第 12 章中， 我们将学习如何建立更加复杂的并发服 务器( co n c u r r e n t s e r v e r ) , 它能够同时处理多个客户端。

最后， 图 11- 22 展示了 ec ho 程序的代码，该 程序反复读写文本行， 直到r i o \_ r e a d li ne b

函数在第 10 行遇到 EOF。

co d e/netp / echo.c

\#include "csapp.h"

2

3 void echo(int connfd)

4 {

1.  s1ze_t n;
2.  char buf[MAXLINE] ;
3.  r1o_t rio;

    8

    9 Ri o r\_ e ad i n i t b (&r i o , connfd);

    1O while ((n = Rio_readlineb (&rio, buf, MAXLINE)) ! = 0) {

4.  printf("server received %d bytes\\n", (i nt )n) ;
5.  Rio_writen(connfd, buf, n);

    13 }

    14 }

code/netp/echo.c

图11-22 读和回送文本 行的 e c ho 函数

田 日 在连接中 EOF 意味什么？

### EOF 的概念常常使 人们感到迷惑， 尤其是在因特 网 连接的上下文中。 首先， 我们需要理解其 实并没有像 EOF 宇符 这样的一个 东西。 进一步来说 ， EOF 是由内核 检测到的一种条 件。应用程序在 它接 收到一个由r e a d 函数返回的零返回码时， 它就 会发现出

EOF 条件。对于磁 盘文件 ， 当前文件位置超 出 文件 长度时， 会发生 EOF 。 对于因特 网连接，当 一个进程 关闭 连接 它的 那一端 时， 会发生 EOF 。连接另一 端的 进程在试图读 取流中最后 一个字节之后的 字节时， 会检测到 EOF 。

11\. 5 Web 服务器

迄今为止， 我们已 经在一个简单的 echo 服务器的 上下 文中讨论了网络编程。在这一节里，我们将向你展示如何利用网络编程的基本概念，来创建你自己的虽小但功能齐全的

Web 服务器。

1.  5 . 1 We b 基础

    Web 客户端和服务器之间的交互用的是一个基于文本的应用级协议，叫 做 HT T P ( H'ljpertext Transfer Protocol, 超文本传输协议）。HTTP 是一个简单的协议。一个 Web 客户端（即浏览器）打开一个到服务器的因特网连接，并且请求某些内容。服务器响应所请 求的内容，然后关闭连接。浏览器读取这些内容，并把它显示在屏幕上。

    Web 服务和常规的文 件检索服务（例如FT P) 有什么区别呢？主要的区别是 Web 内容可以用一种叫做 HT ML ( Hypertext Markup Language, 超文本标记语言）的语言来编写。一个 HT ML 程序（页）包含指令（标记），它 们告诉浏览器如何显示这页中的各种文本和图形对象。例如，代码

## \<b\> Make me bold! \</b\>

告诉浏 览器用粗体字类型输出\< b \> 和\< / b \> 标记之间的文本。然而， HT ML 真正的强大之处在于一个页面可以包含指针（超链接），这些指针可以指向存放在任何因特网主机上的 内容。例如 ， 一个格式如下的 HT ML 行

## \<a [href="http://www.cmu.edu/index.html"\>Carnegie](http://www.cmu.edu/index.html) Mellon\</a\>

告诉浏览器高亮显示文本对象 " Car ne g i e Mellon", 并且创建一个超链接，它指向存放在 CMU Web 服务器上叫做 i nde x . h七ml 的 HT ML 文件。如 果用户单击了这个高亮文本对象，浏 览器就会从 CMU 服务器中请求相应的 HT ML 文件并显示 它。

### 田 日 万维网的起源

万维网是 Tim Bemers-Lee 发明的， 他是一位在瑞典物理 实验室 CERN( 欧洲粒子物理研究所）工作的软件工程师。1989 年， Berners-Lee 写了一个内部备忘录，提出了一个分布式超文

本系统，它 能连接“用链接组成的笔记的网(web of notes with links)" 。提出这个 系统的目的是帮助 CERN 的科学家共享和管理信息。在接下来的两年多里， Bemers-Lee 实现了笫一个 Web服务器和Web 浏览器之后， 在 CERN 内部以及其他一些网站中， Web 发展出了小 规模的拥护者。

1993年一个关键事件发生了， M釭 c Andreesen(他后来创建了 Netscape)和他在NCSA的同事发布了一种图形化的浏览器， 叫做 MOSAIC, 可以在三种主要的平台上所使用： Unix、Windows 和

:Macintosh。在MOSAIC发布后， 对 Web的兴趣爆发了， Web网站以 每年10 倍或更高的数量 增长。到 2015年，世界上已经有超过975000 000 个 Web 网站了（源自 Netcraft Web Survey)。

1.  5\. 2 W e b 内 容

    对于 W e b 客户端和服务器而言， 内容是与一个 MIME (Multipurpose Internet Mail

    Extensions, 多用途的网际邮件扩充协议）类型相关的字节序列。图 11- 23 展示了一些常用的 MIM E 类型。

    图 11-23 MIME 类型示例

### Web 服务器以 两种不同的方式向客户端 提供内容：

-   取一个磁盘文件 ， 并将它的内 容返回给客 户端。磁盘文件称为静态内 容( s ta tic con­

    tent), 而返回文件给客户端的过程称为服务静态内 容( se rving static content ) 。．

    -   运行一个可执行文件，并将它的输出返回给客户端。运行时可执行文件产生的输出称为动 态内 容( d ynam ic content) , 而运行程序并返回它的输出到客户端的过程称为服务动 态内 容( se r ving dynamic conte nt ) 。

        每条由 Web 服务器返回的内容都是和它管理的某个文件相关联的。这些文件中的每一个都有一个唯一的名字，叫做URL( Universal Resource Locator, 通用资源定位符）。例如， URL

#### ht t p : / / 吓 w. g oogl e . com: 80/ i ndex . ht ml

表示因特网主机 [www.](http://www/) g o o g l e . c om 上一个 称为/ i nd e x . h t ml 的 H T M L 文件， 它是由一个监听端口 80 的 Web 服务器管 理的。端口号是可选的，默认 为知名的 H T T P 端口 80。可执行文件的 U R L 可以在文件名后包括程序参 数。" ?" 字符分隔文件名和参数， 而且每个参数都用" &" 字符分隔开。例如 ， U R L

#### http://bluefish.ics.cs.cmu.edu:8000/cgi-bin/adder?15000&213

标识了一个叫做/ cg 丘 b i n / a dde r 的可执行文件， 会带两个参数字符串 15000 和 213 来调用它。在事务过程中，客户端和 服务器使用的是 URL 的不同部分。例如， 客户端使用前缀

#### http://www.google.com:80

来决定与哪类服务器联系，服务器在哪里，以及它监听的端口号是多少。服务器使用后缀

/index.html

来发现在它文件系统中的文件，并确定请求的是静态内容还是动态内容。关于服务器如何解释一个 U RL 的后缀，有 几点需要理解：

-   确定一个 U R L 指向的是静态内容还是 动态内容没有标准的规则。每个服务器对它所管理的文件都有自己的规则。一种经典的（老式的）方法是，确定一组目录，例如 c g i - 区 n , 所有的可执行性文件都必须存放这些目录中。
    -   后缀中的最开始的那个 "/" 不表示 Linux 的根目 录。相反， 它表示的是被请求内容类型的主目录。例如，可以将一个服务器配置成这样：所有的静态内容存放在目录／ usr / htt pd / ht ml 下 ，而所有的动态内 容都存放在目录/ usr / h tt pd / c g 丘 b i n 下。
-   最小的 UR L 后缀是 "I" 字符， 所有服务器将其扩展为某个默认的 主页， 例如/ i nde x . h t ml 。这解 释了为什么简单地在浏览器中键入一个域名就可以取出一个网站的主页。浏览器在 U R L 后添加缺失的 "/" , 并将之传递给服务器， 服务器又把 "I" 扩展到某个默认的文件名。

11\. 5. 3 HT T P 事务

因为 H T T P 是基于在因特网连接上传送的文本行的， 我们可以使用 L in u x 的 T E L ­ N E T 程序来和因特网上的任何 W e b 服务器执行 事务。对于调试在连 接上通过文本行来与客户端对话的 服务器来说， T E L N E T 程序是非常便利的。例如，图 11 - 24 使用 T E L N E T 向 A O L W e b 服务器请求主页。

l i nu x\> t el n e t w 叮 . a ol . c om 80 2 Trying 205. 188. 146. 23. . .

1.  Connected to aol . com .
    1.  Escape character i s '- J ' . s GET I HTTP/ 1 . 1

        6 Hos t : 日 叩 . a ol . co m

        7

Client: open connection to server Telnet prints 3 lines to the terminal

Client: request line

Client: required HTTP/1.1 header Client: empty line terminates headers

1.  HTTP/1. 0 200 OK Server: response line
2.  MI ME- Ver s i on : 1. 0 Server: followed by ti ve response headers 10 Da t e : Mon , 8 Jan 20 1 0 4 : 59 : 4 2 GMT
3.  Server: Apa c he - Co y ot e / 1 . 1
4.  Con t e nt - Type : t e xt / ht ml Server: expect HTML in the response body
5.  Con t e nt - Le ng t h : 42092 Server: expect 42, 092 bytes in the response body

14

15 \<html\>

16

Ser ver : empty line terminates response headers Server : first HTML line in response body

Ser ver : 766 lines of HTML not shown

17 \</html\> Server: last HTML line in response body 18 · Conn e c t i on c l o s e d by foreign host. Server : closes connection

19 l i nu x\>

Cl i ent : c1 oses connection and terminates

图 11-24 一个服务静 态内容的 HT T P 事务

在第 1 行， 我们从 L in u x s hell 运行 T EL NET , 要求它打开一个到 A O L W e b 服务器的连接。T E L N E T 向终端打印三行输出， 打开连接， 然后等待我们输入文本（第5 行）。每次输入一个文本行， 并键入回车键， T E L N E T 会读取该行， 在后面加上回车和换行符号（在C 的表示中为 " \\r \\ n" ) , 并且将这一行发送到服务器。这是和 H TT P 标准相符的， H TT P 标准要求每个文本行都由一对回车和换行符来 结束。为了发起 事务， 我们输入一个 H T T P 请求（第5 \~ 7 行）。服务器返回H TT P 响应（第8 \~ 1 7 行）， 然后关闭连接（第18 行）。

1.  HTT P 请求

    一个 H T T P 请求的组成 是这样的： 一个请求行 ( r eq ues t line ) ( 第 5 行）， 后 面跟随零个或更多个请求报 头 ( r e q u es t h ea d e r ) ( 第 6 行）， 再跟随 一个空的文本行来终止报头列表

### （第 7 行）。一个请求行的形式是

method URI version

HT T P 支持许多不同的方 法，包 括 G E T 、 P O S T 、 O P T I O N S 、 H E A D 、P U T 、 D E L E T E

和 T R A C E 。我们将只讨论广为应用的 G E T 方法， 大多数 H T T P 请求都是这种类型的。

G ET 方法指导服务器生成和返回 U RI ( U nifo rm Resource Identifier, 统一资源标识符）标识的内 容。U RI 是相应的 U R L 的后缀， 包括文件名和可选的参数 。e

请求行中的 version 字段表明了该请求遵循的 H T T P 版本。最新的 H T T P 版本是H T T P / 1. 1 [ 37] 。H T T P / 1. 0 是从 1996 年沿用 至今的老版本 [ 6] 。H T T P / 1. 1 定义了一些附加的报头， 为诸如缓冲和安 全等高级特性提供支持， 它还支持一种机制，允 许客户端和服务器在同一条持久连接 ( persis t e n t con nect io n ) 上执行多个事务。在实际中， 两个版本是互相兼容的， 因为 H T T P / 1. o 的客户端 和服务器会简单地忽略 H T T P / 1. 1 的报头。

总的来说， 第 5 行的请求行要求服务器取出并返回 H T M L 文件/ i nde x . h t ml 。 它也告知服务器请求剩下的部分是 H T T P / 1. 1 格式的。

### 请求报头为服务器提供了额外的信息，例如浏览器的商标名，或者浏览器理解的

MIME 类型。请求报头的格式为

#### hea d er - na me : head er-d a ta

针对我们的目的， 唯一需要关注的报头是 Ho 江 报头（第6 行）， 这个报头在 H T T P / 1. 1 请求中是需要的， 而在 H T T P / 1. 0 请求中是不需要的。代理缓存( pro xy cache ) 会使用 Ho s t 报头， 这个代理缓 存有时作为浏览器和管理被请求文件的原始服 务器 ( origin ser ver ) 的中介。客户端 和原始服务器之间， 可以 有多个代理， 即所谓的代理链( pro xy cha in ) 。 Ho s t 报头中的数据指示了原始服务器的域名，使得代理链中的代理能够判断它是否可以在本地 缓存中拥有一个被请求内容的副本。

继续图 11- 24 中的示例， 第 7 行的空文本行（通过在键盘上键入回车键生成的）终止了报头， 并指示服务器发送被请求的 H T ML 文件。

2.  HT T P 响应

    H T T P 响应和 H T T P 请求是相似的。一个 H T T P 响应的组成是这样的： 一个响应行(response line)(第 8 行）， 后面跟随 着零个或更多的响应报 头 ( res pons e header)(第 9 \~ 13行），再 跟随一个终止报头的空行（第14 行），再 跟随一个响应主体( res ponse body)(第 15 \~ 17行）。一个响应行的格式是

#### version sta tus -code sta tus-message

version 字段描述的是 响应所遵循的 H T T P 版本。状 态码( stat us飞 code) 是一个 3 位的正整数， 指明对请求的处理。状态消息 ( s tat us message) 给出与错误代码等价的英文描述。图 11- 25 列出了一些常见的状态码， 以及它们相应的消息。

| 状态代码 | 状态消息       | 描述                                 |
|----------|----------------|--------------------------------------|
| 200      | 成功           | 处理请求无误                         |
| 301      | 永久移动       | 内容巳移动到locat10n头中指明的主机上 |
| 400      | 错误请求       | 服务器不能理解请求                   |
| 403      | 禁止           | 服务器无权访问所请求的文件           |
| 404      | 未发现         | 服务器不能找到所请求的文件           |
| 501      | 未实现         | 服务器不支持请求的方法               |
| 505      | HTTP版本不支持 | 服务器不支持请求的版本               |

图 11-25 一些 HTT P 状态码

e 实际上，只 有当浏览器请求内容时 ， 这才是真的。如果代理服务器请求内容 ， 那么这个 URI 必须是完整的

U RL。

第 9\~ 13 行的响应报头提供了关于响应的附 加信息。针对我们的目的， 两个最重要的报头是 Co n t e n t - Typ e ( 第 1 2 行）， 它告诉客户端响应主体中内容的 M IM E 类型； 以及Co n 七e n t - Le ng 店（第13 行），用 来指示响应主体的字节大小。

### 第 14 行的终止响应报头的空文本行， 其后跟随着响应主体， 响应主体 中包含着被请求的内容。

1.  5\. 4 服务动态内容

### 如果我们停下来考虑一下，一个服务器是如何向客户端提供动态内容的，就会发现一些问题。例如，客户端如何将程序参数传递给服务器？服务器如何将这些参数传递给它所创建的子进程？服务器如何将子进程生成内容所需要的其他信息传递给子进程？子进程将它的输出发送到哪里？ 一个称为 CG ICCo mmon Gateway Interface, 通用网关接口）的实际标准的出现解决了这些问题。

1 客户端如何 将程序 参数传 递给服务器

GET 请求的参数在 UR I 中传递。正如我们看到的， 一个 "?" 字符分隔了文件名和参数，而每个参数都用一个 " &" 字符分隔开。参数中不允许有空格， 而必须 用字符串 " %2 o" 来表示。对其他特殊字符，也存在着相似的编码。

田 日 在 HTT P POS T 请求中传递参数

HTTP POST 请求的参数是 在请求主体 中而不 是 U RI 中传递的 。

### 服务器如何将参数传递给子进程在服务器接收一个如下的请求后

#### GET /cgi-bin/adder?15000&213 HTTP/1.1

它调用 f or k 来创建一个子进程， 并调用 e x e c v e 在子进 程的上下文中执行/ c g i - b i n / a d­

de 程序。像 a d der 这样的程序 ， 常常被称为 CG I 程序， 因为它们遵守 CG I 标准的规则。而且， 因为许多 CG I 程序是 用 Pe rl 脚本编写的， 所以 CG I 程序也常被称为 CG I 脚本。在调用 e xe c ve 之前， 子进程将 CG I 环境变量 Q U E R Y_ST RI NG 设置为 " 1 5000 &21 3" , ad­

der 程序在运行时 可以用 Lin ux g e t e nv 函数来引用它。

### 服务器如何将其他信息传递给子进程

CGI 定义了大量的其他环境变量， 一个 CG I 程序在它运行时可以设置这些环境变量。

### 图 11-26 给出了其中的一部分。

图 11-26 CGI 环境变量示例

### 子进程将它的输出发送到哪里

一个 CG I 程序将它的动态内容发送到标准输出 。在子进程加载并 运行 CGI 程序之前，

它使用 L in u x d u p 2 函数将标准输出重定向到和客户端相关联的已连接描述符。因此， 任何 CG I 程序写到标准输出的东西都会直接到达客户端。

### 注意，因为父进程不知道子进程生成的内容的类型或大小，所以子进程就要负责生成

Content- t ype 和 Co n t e n t - l e n g t h 响应报头， 以及终止报头的空行 。

图 11 - 27 展示了一个简单的 CGI 程序， 它对两个参数求和， 并返回带结果的 H T M L

文件给客户端 。图 11 - 28 展示了一个 H T T P 事务， 它根据 a d d er 程序提供动态内容。

code/netpltiny/cgi-bin/adder.c

\#include "csapp.h"

2

1.  int main(void) {
2.  char \*buf, \*Pi
3.  char argl[MAXLINE], arg2[MAXLINE], c ont e nt [MAX LI NE] ; 6 int n1=0, n2=0;

    7

4.  . I \* Extract the two arguments \*I
5.  if ((buf = getenv (11QUERY_STRING 11)) ! = NULL) { 1o p = strchr (buf ,'&') ;

    11 \*P ='\\0';

6.  strcpy(arg1, buf);
7.  strcpy(arg2, p+1);
8.  n1 = atoi(arg1);
9.  n2 = atoi(arg2); 16 }

    17

10. I\* Make the response body \*I
11. sprintf (content, 11QUERY_STRING=%s11 , buf) ;
12. sprintf(content, 11Welcome to a dd . com : 11);
13. sprintf(content, 11%sTHE Internet addition portal. \\r\\n\<p\>11, content);
14. sprintf (content, 11%sThe answer is: %d + %d = %d\\r\\n\<p\>11,
15. content, n1, n2, n1 + n2);
16. sprintf (content, 11%sThanks for visiting! \\r\\011, content); 25
17. I\* Generate the HTTP response \*I
18. printf(11Connection: close\\r\\n11);
19. printf(11Content-length: %d\\r\\n11, (int)strlen(content));
20. printf(11Content-type: t ext / html \\r \\ n \\r \\ n 11) ;
21. printf(11%s11, content);
22. f fl us h ( s t dout ) ; 32

    33 exit(O); 34 }

code/netpltiny/cgi-bin/adder.c

图 11-27 对两个整数求和的 CGI 程序

linux\> telnet kit tyha甘k.cmcl. cs. emu. edu 8000 Client: open connect i on

2 Trying 128. 2.194.242...

Connected to kittyhawk.cmcl.cs.cmu.edu. Escape character i s '- J ' .

GET /cgi-bin/adder?15000&213 HTTP/1.0

HTTP/1. 0 200 OK

Server: Tiny Web Server Content-length: 115 Content-type: text/html

Client: request line

Cl i en t : empty 1 ine terminates headers Server: response line

Server : identify server

Adder: expect 115 bytes in response body Adder: expect HTML in response body

1.  Ad der : empty line terminates headers
2.  Welcome to add.com: THE Internet addition portal. Adder: first HTML line
3.  \<p\>The answer is: 15000 + 213 = 15213 Ad der : second HTML line in response body
4.  \<p\>Thanks for visiting! Adder: third HTML line in response body
5.  Connection closed by foreign host.
6.  linux\>

    Server: closes connection

    Client: closes connection and terminates

图 11-28 - 个提供动态 H T ML 内容的 HT T P 事务

\_m 将HTTP POST 请求中的 参数传递给 CGI 程序

### 对于 POST 请求，子进程也 需要 重定向标 准输入 到已连接描 述符。然后 ， CGI 程序会从标准扴入 中读取 请求主体 中的 参数。

练习题 11. 5 在 1 0 . 11 节中， 我们警 告过你 关 于在 网络应用 中使用 C 标准 I/ 0 函数的危险。然而， 图 11 - 27 中的 CGI 程序却 能没有任何 问题地使用 标准 I/ 0 。为什 么呢？

1.  6 综合： TINY Web 服务器

### 我们通过开发一 个虽小但功能齐全的称为 T INY 的 W e b 服务器来结束对网络编程的讨论。TINY 是一个有趣的程序。在短短 2 5 0 行代码中， 它结合了许多我们已经学习到的 思想， 例如进程控制、Unix I/ 0 、套 接字接口和 HT TP。虽然它缺乏 一个实际服务器所具备的功能性 、健壮性和安全性， 但是它足够用来为实际的 W e b 浏览器提供静态和动态的内容。我们鼓励 你研究它， 并且自己 实现它。将一个实际的浏览器指向你自己的服务器， 看着它显 示一个复杂的带 有文本 和图片的 W e b 页面， 真是非常令人兴奋（甚至对我们这些作者来说，也 是如此！）。

1.  TINY 的 main 程序

    图 11 - 2 9 展示了 TINY 的主程序。TINY 是一个迭代服务器， 监听在命令行中传递来的端口上的连接请求 。在通过调用 o p e n \_ l i s t e n f d 函数打开一个监听套接字以后， T INY 执行典型的无限 服务器循环， 不断地接受连接请求（第3 2 行）， 执行事务（第3 6 行）， 并关闭连接的它那一 端（第3 7 行）。

    1.  doit 函数

        图 11 - 30 中的 d o i t 函数处理一个 HT TP 事务。首先， 我们 读和解析请求行（第11 1 4 行）。注意 ， 我们使 用图 11 - 8 中的r i o \_r e a d l i n e b 函数读取请求行。

        TINY 只支持 GET 方法。如果客户端请求其他方法（比如 POST) , 我们发送给它一个错误信息，并 返回到主程序（第1 5 1 9 行）， 主程序 随后关闭连接并等待下一个连接请求。否则，我们 读并且（像我们将要看到的那样）忽略任何请求报头（第 20 行）。

code/netpltinyltiny.c

1.  I\*
    1.  \* tiny.c - A simple, iterative HTTP/1.0 Web server that uses the GET method to serve static anddynamic content

        4 \*I

        5 \#include "csapp.h"

        6

2.  void doit(int fd);
3.  void read_requesthdrs(rio_t \*rp);
4.  int parse_uri(char \*uri, char \*filename, char \*cgiargs);
5.  void serve_static(int fd, cha工 \*fil ename , int filesize);

    11 void get_filetype(char \*filename, char \*filetype);

    12 void serve_dynamic(int fd, char \*filename, char \*cgiargs);

    13 void clienterror(int fd, char \*cause, char \*errnum,

    14 char \*shortmsg, char \*longmsg);

    15

    16 int main(int argc, char \*\*argv)

    17 {

6.  int listenfd, connfd;
7.  cha 工 hos t n ame [ MAX LI NE] , port[MAXLINE];
8.  socklen_t clientlen;
9.  struct sockadd_rs t or age clientaddr;

    22

10. I\* Check command-line args \*I
11. if (argc != 2) {
12. fprintf (stderr, "usage: %s \<port\>\\n", argv [OJ);
13. exit (1);

    27 }

    28

14. listenfd = Open_listenfd(argv[1]);
15. while (1) {
16. clientlen = sizeof (clientaddr)·
17. connfd = Accept (listenfd, (SA \*)&clientaddr, \&clientlen);
18. Getnameinfo((SA \*) \&clientaddr, clientlen, hostname, MAXLINE,
19. port , MAXLINE, 0) ;
20. printf("Accepted connection from (%s, %s)\\n", hostname, port);
21. doit(connfd);
22. Close(connfd);

    38 }

    39 }

code/netpltinyltiny.c

图 11-29 TINY Web 服务器

### 然后， 我们将 URI 解析为一个文件名和一个可能 为空的 CGI 参数字符串， 并且设置一个标志， 表明请求的是静态内容还是动态内容（第23 行）。如果文件在磁盘上不存在， 我们立即发送一个错误信息给客户端并返回。

最后， 如果请求的是静态内容，我 们就验证该文件是一个普通文件， 而我们 是有读权限的（第31 行）。如果是这样， 我们就向客户端提供静态内容（第36 行）。相似地， 如果请求的是动态内容， 我们就验证该文件是可执行 文件（第39 行）， 如果是这样，我 们就继续， 并且提供动态内容（第44 行）。

code/netpltinyltiny.c

void doit(int fd) 2 {

1.  int is_static;
    1.  struct stat sbuf;
        1.  char buf[MAXLINE], method[MAXLINE], uri[MAXLINE], version[MAXLINE];
        2.  char filename [MAXLINE], cgiargs [MAXLINE]; rio_t rio;

            8

2.  I\* Read request line andheaders \*I
3.  Rio_readinitb(&rio, fd);
4.  Rio_readlineb(&rio, buf, MAXLINE);
5.  printf("Request headers:\\n");
6.  printf("%s", buf);
7.  sscanf(buf, "%s %s %s", method, uri, version);
8.  if (strcasecmp(method, "GET")) {
9.  clienterror(fd, method, "501", "Not implemented",
10. "Tiny does not implement this method");
11. return;

    19 }

    20 read_requesthdrs (&rio);

    21

12. I\* Parse URI from GET request \*I
13. is_static = \_par s e \_ur i (uri, filename, cgiargs);
14. if (stat(filename, \&sbuf) \< 0) {
15. clienterror(fd, filename, "404", "Not found",
16. "Tiny couldn't find this file");
17. return;

    28 }

    29

18. if (is_static) { I\*Serve static content \*I
19. if (! (S_ISREG(sbuf.st_mode)) 11 ! (S_IRUSR & s buf . st_mode)) {
20. clienterror(fd, filename, "403", "Forbidden",
21. · "Ti ny couldn't read the file");
22. return;

    35 }

    36 serve_static (fd, filename, sbuf. st \_s i z e ) ;

    37 }

23. else { I\* Serve dynamic content \*I
24. if (! (S_ISREG (sbuf.st_mode)) I I ! (S_IXUSR & sbuf. st_mode)) {
25. clienterror(fd, filename, "403", "Forbidden",
26. "Tiny couldn't run the CGI program");
27. return;

    43 }

    44 serve_dynamic(fd, filename, cgiargs);

    45 }

    46 }

code/netp/tinyltiny.c

1.  c l ie nte rro r 函数

图 11-30 TINY d o i t 处理一个 H T T P 事务

T I NY 缺乏一个实际服务器的许多错误处理特性。然而， 它会检查一些明显的错误， 并把它们报告给客户端。图 11-31 中的 c l i e n t er r or 函数发送一个 HT TP 响应到客户端， 在响应行中包含 相应的状态码和状态消息， 响应主体中包含一个 HT ML 文件，向 浏览器

### 的用户解释这个错误。

1.  void clienterror(int fd, char•cause, char•errnum,
2.  char•shortmsg, char•longmsg)

    3 {

code/netpltinyltiny.c

| 4  |   | char buf[MAXLINE], body[MAXBUF];                                         |
|----|---|--------------------------------------------------------------------------|
| 5  |   |                                                                          |
| 6  |   | I• Build the HTTP response body•/                                        |
| 7  |   | sprintf(body, "\<html\>\<title\>Tiny Error\</title\>");                  |
| 8  |   | sprintf (body, 11%s\<body bgcolor=" "ffffff1111\>\\r\\n11, body);        |
| 9  |   | sprintf(body, 11%s%s: %s\\r\\n11, body, errnum, shortmsg);               |
| 10 |   | sprintf(body, 11%s\<p\>%s: %s\\r\\n11, body, longmsg, cause);            |
| 11 |   | sprintf (body, 11%s\<hr\>\<em\>The Tiny Web server\</em\>\\r\\n", body); |
| 12 |   |                                                                          |
| 13 |   | /• Print the HTTP response•I                                             |
| 14 |   | sprintf (buf, "HTTP/1.0 %s %s\\r\\n11, errnum, shortmsg);                |
| 15 |   | Rio_writen(fd, buf, strlen(buf));                                        |
| 16 |   | sprintf(buf, "Content-type: text/html\\r\\n");                           |
| 17 |   | Rio_writen(fd, buf, strlen(buf));                                        |
| 18 |   | sprintf(buf, "Content-length: %d\\r\\n\\r\\n11, (int)strlen(body));      |
| 19 |   | Rio_writen(fd, buf, strlen(buf));                                        |
| 20 |   | Rio_writen(fd, body, strlen(body));                                      |
| 21 | } |                                                                          |

code/netp/tinyltiny.c

图 11- 31 T I NY cl i e nt err or 向客户端发送一个出错消息

### 回想一下， H T M L 响应应该指明主体中内容的大小和类型。因此， 我们选择创建H T M L 内容为一个 字符串， 这样一来我们可以 简单地确定它的大小。还有， 请注意我们为所有的输出使用的都是图 10- 4 中健壮的r i o \_wr i t e n 函数。

1.  re a d \_ re q ue s t hd rs 函数

    T INY 不使用请求报头中的任何信息。它仅仅调用图 11-32 中的r e a d—r e q u e s t h d r s 函数来读取并忽略这些报头。注意，终止请求报头的空文本行是由回车和换行符对组成 的， 我们在第 6 行中检查它。

void read_requesthdrs(rio_t \*rp)

2 {

3.  cha 工 buf [ MAX LI NE] ;

    4

4.  Rio_readlineb(rp, buf, MAXLINE);
5.  while(strcmp(buf, "\\r\\n")) {
6.  Rio_readlineb(rp, buf, MAXLINE);
7.  printf("%s", buf);

    9 }

    10 return;

    11 }

    code/netp/tinyltiny.c

code/netpltinyltiny.c

图 11-32 TINYr ead\_ r eque s 七hdr s 读取并忽略请求报头

#### pa rs e \_uri 函数

T INY 假设静态内容的主目录就是 它的当前目录， 而可执行文件的主目录是 . / cg让 bi n。任何包含字符串 cg丘 bi n 的 URI 都会被认为表示的是 对动态内容的请求。默认的文件名是

#### . / home . html 。

图 11 - 33 中的 par s e \_u r i 函数实现了这些策略。它将 U RI 解析为一 个文件名和一个可选的 CG I 参数字符串。如果请求的是静态内容（第5 行）， 我们将清除 CG I 参数字符串

（第 6 行）， 然后将 U RI 转换为一个 Lin ux 相对路径名， 例如 . / i nd e x . h t ml ( 第 7 \~ 8 行）。如果 U RI 是用 "/" 结尾的（第9 行）， 我们将把默认的文件名加在后面（第10 行）。另一方 面， 如果请求的是 动态内容（第13 行）， 我们 就会抽取出所有的 CG I 参数（第14 \~ 20 行），并将 U R I 剩下的部分转换为一个 L inu x 相对文件名（第21 \~ 22 行）。

#### code/netpltinyltiny.c int pars e \_ur i( cha 工 \*ur i , cha 工 \*f i l ename , char \*cgia 工 gs )

2 {

#### 3 char \*ptr;

5 if (!strstr(uri, "cgi-bin")) { I\* Static content \*I strcpy(cgiargs, "");

strcpy(filename, ". ");

1.  strcat (filename, uri);
2.  if (uri[strlen(uri)-1] =='/')

#### strcat(filename, "home.html"); return 1;

12 }

#### else { I\* Dynamic content \*I

1.  ptr = index(uri,'?');
2.  if (ptr) {

#### strcpy(cgiargs, ptr+1);

3.  \*ptr = I \\0 I j

    18 }

    19 else

| 20 |   |   | strcpy (cgiargs, "") ;    |
|----|---|---|---------------------------|
| 21 |   |   | strcpy (filename, ". ") ; |
| 22 |   |   | strcat (filename, uri);   |
| 23 |   |   | r etu 工 n O;             |
| 24 |   | } |                           |
| 25 | } |   |                           |

#### code/netpltinyltiny.c

图 11- 33 TINY par s e_ur i 解析一个 HTT P URI

#### se rve \_s ta t ic 函数

T I N Y 提供五种常见类型的静态内容： H T M L 文件、无格式的文本文件，以 及编码为 G IF 、P NG 和 ] PG 格式的图片。

图 11-34 中的 s er ve \_s t a t i c 函数发送一个 H T T P 响应， 其主体包含一个本地文件的内容。首先， 我们通过检查文件名的后缀来判断文件类型（第 7 行）， 并且发送响应行和响应报头给客户端（第8,..._,1 3 行）。 注意用一个空行终 止报头。

code/netpltinyltiny.c

1 void serve_static(int fd, char \*filename, int filesize)

2 {

3 int srcfd;

4 char \*srcp, filetype [MAXLINE] , buf [MAXBUF] ;

5

6 I\* Send response headers to client \*I

1.  get_filetype(filename, filetype);
2.  sprintf(buf, "HTTP/1.0 200 OK\\r\\n");
3.  sprintf(buf, "%sServer: Tiny Web Server\\r\\n", buf);
4.  sprintf(buf, "%sConnection: close\\r\\n", buf);

    11 sprintf(buf, "%sContent-length: %d\\r\\n", buf, filesize);

    12 sprintf(buf, "%sContent-type: %s\\r\\n\\r\\n", buf, filetype);

    13 Rio_writen(fd, buf, strlen(buf));

    14 printf("Response headers:\\n");

    1 5 pr i nt f ( "知 " , buf);

    16

    17 I\* Send response body to client \*I

    18 srcfd = Open(filename, O_RDONLY, O);

5.  srcp = Mmap(O, filesize, PROT_READ, MAP_PRIVATE, srcfd, O);
6.  Close(srcfd) ;
7.  Rio_writen (fd, srcp, filesize) ;
8.  Munmap(srcp, filesize);

    23 }

    24

    2s I\*

    26 \* get_filetype - Derive file type from filename

    21 \*I

    28 void get_filetype (char \*filename, char \*filetype)

    29 {

9.  if (strstr(filename, ".html"))
10. strcpy(filetype, "text/html");
11. else if (strstr(filename, ".gif"))
12. strcpy(filetype, "image/gif");
13. else if (strstr(filename, 11.png"))
14. strcpy(filetype, "image/png");
15. else if (strstr(filename, ".jpg"))
16. strcpy(filetype, "image/jpeg");
17. else
18. strcpy(filetype, "text/plain");

    40 }

    code/netpltinyltiny.c

图 l 1-3-l T I NY s er ve s t a已 c 为客户端 提供静态内容

接着，我 们将被请求文 件的内容复制到已 连接描述符 f d 来发送响应主体。这里的 代码是比较微妙的，需 要仔细研究。第 18 行以读方式打开 f i l e n a me , 并获得它的描述符。在第 1 9 行， L in ux mma p 函数将被请求文件映射到一个虚拟内存空间。回想我们在第 9. 8 节中对 mma p 的 讨论 ， 调用 mma p 将文件 s r c f d 的前 f i l e s i ze 个字节映射到一个从地址 s r c p 开始的私有只读虚拟内存区域。

#### 一旦将文件映射到内存，就 不 再 需 要 它 的 描 述符了， 所 以 我们关闭 这个文件（第20 行）。执行这项任务失败将导致潜在的致命的内存泄漏。第 21 行 执 行 的 是 到客户端的实际文件传送。r i o_wr i t e n 函数 复 制 从 s r c p 位 置开始的 f i l e s i ze 个字节（它们当然已经被映射到了所请求的文件）到客户端的已连接描述符。最后，第 22 行 释放了映射的虚拟内存区域。这对于避免潜在的致命的内存泄漏是很重要的。

1.  s e rve \_dyna mic 函 数

    T INY 通过派生一个子进程并在子进程的上下文中运行一个 CGI 程序，来 提供各种类型的动态内容。

    图 11- 35 中的 s er v e \_ d yna mi c 函 数 一 开始就向客户端发送一个表明成功的响应行， 同时 还包括带有信息的 Ser ver 报头。CGI 程序负责发送响应的剩余部分。注意， 这并不像我们可能希望的那样健壮，因 为它没有考虑到 CGI 程序会遇到某些错误的可能性。

code/netp/tinyltiny.c

void serve_dynamic (int fd, char \*filename, char \*cgiargs)

2 {

#### 3 char buf [MAXLINE], \*emptylist [] = { NULL } ;

4

#### 5 I\* Return first part of HTTP response \*I

6 sprintf(buf, "HTTP/1.0 200 OK\\r\\n");

1.  Rio_writen(fd, buf, strlen(buf));
2.  sprintf(buf, "Server: Tiny Web Server\\r\\n");

    9 Rio_writen(fd, buf, strlen(buf));

    10

    11 if (Fork() == 0) { I\* Child \*I

#### I\* Real server would set all CGI vars here \*I

1.  setenv("QUERY_STRING", cgiargs, 1);
2.  Dup2(fd, STDOUT_FILENO); I\* Redirect stdout to client \*I
3.  Execve(filename, emptylist, environ); I\* Run CGI program \*I

    16 }

1.7

18 }

#### Wait(NULL); I\* Parent waits for and reaps child \*I

图 11 - 35 TINY ser ve_dynami c 为客户端提供 动态内容

#### code/ne/ttpinyltiny.c

在发送了响应的第一部分后， 我们会派生一个新的子进程（第11 行）。子进程用来自请求 URI 的 CGI 参数初始化 QUERY \_ ST RING 环境变量（第 13 行）。注意，一 个 真 正 的服务器还会在此处设置其他的 CGI 环境变量。为了简短， 我们省略了这一步。

#### 接下来，子 进程重定向它的标准输出到已连接文件描述符（第14 行），然后 加 载并运行

CGI程序（第15 行）。因为 CGI 程序运行在子进程的上下文中，它 能 够 访 问 所 有在调用 e x­ e c ve 函数之前就存在的打开文件和环境变量。因此， CGI程序写到标准输出上的任何东西都将直接送到客户端进程，不 会 受 到 任何来自父进程的干涉。其间，父 进 程阻塞在对 wa i t 的调 用中 ， 等待当子进程终止的时候，回 收 操 作 系统分配给子进程的资源（第17 行）。

m 处理过早关闭的连接

尽管一个 Web 服务 器的基本功能非常简单，但是 我们不想给你 一个假象，以 为编写 一个实际的 Web 服务器是非常简单的。构造一个长时间运行而不 崩溃的健壮的 Web 服务器是 一件困难的任 务，比起 在 这 里我们已经学习了的内容， 它要求对 Linux 系统 编程有更加深入的

理解。例如，如果一个服务器写一个已经被客户端关闭了的连接（比如，因为你在浏览器上 单击了 " Stop" 按钮），那 么第一 次 这 样 的 写会正 常返回， 但 是 第二 次 写就会引起发送 SIG­ PIP E 信号， 这个信号的默认行 为就 是 终 止 这 个进 程。如 果 捕 获或 者 忽略 SIG PIP E 信 号， 那么笫二 次写操作 会返 回值 - 1, 并将 err no 设 置 为 EP IP E。 s tr e rr 和 perr or 函数 将 EPIPE 错误报 告 为 " Broken pipe", 这是一个迷惑了很多人的不太直观的信息。总的来说，一个健壮的服务器必须捕获这些 SIGP IPE 信号， 并且检查 wr i t e 函 数 调 用是否有 EP IPE 错误。

11\. 7 小结

每个网络应用都是 基于客户端－服务器模型的。根据这个模型，一个应用是由一个服务器 和一个或多个客户端组成 的。服务器管理资 源，以某 种方式操作资源， 为它的 客户端提供服 务。客户端－服务器模型中的基 本操作是客户端－服务器事务 ， 它是由客户端请求和跟随其后的 服务器响应 组成的 。

客户端和服务器通过因特网这个全球网络来通信。从程序员的观点来看，我 们可以把因特网看成是一个全球范圉的主机集合，具有以下几个属性： 1) 每个因特网主机都有 一个唯一的 32 位名字， 称为它的 IP 地址。2)

IP 地址的集合被映射为一个因特网域名的集合。3)不同因特网主机上的进程能够通过连接互相通信。

客户端和服务器通过使用套接字接口建立连接。一个套接字是连接的一个端点，连接以文件描述符的形式提供给应用程序。套接字接口提供了打开 和关闭套接字描述符的函数。客户端和服务器通 过读写这些描述符来实 现彼此间的通信。

Web 服务器使用 HTT P 协议和它们的客户端（例如浏览器）彼此通信。浏览器向服务器请求 静态或者动态的内容。对静态内容的请求是通过从服务器磁 盘取得文件并把它返回 给客户 端来服务的 。对 动态内容的请求是通过在服务器上一个 子进程的上下文中运行一个程序并将它的输出返回给客户端来服务的。

CGI 标准提供了一组规则，来管理客户端 如何将 程序参 数传递给服 务器，服 务器如何将这些参数以及其他信息传递给子进程 ，以 及子进程如何 将它的输出发送回 客户端 。只用几百行 C 代码就能实现一个简单但是有功效的 Web 服务器，它既 可以提供静态内容， 也可以提供动态内 容。

参考文献说明

有关因特网的官 方信息源被保存 在一系列的 可免费获取的带编号的文档 中，称 为 RFC( Requests for Comments , 请求注解 ， Internet 标准（草案））。在以下网站可获得 可搜索的 RFC 的索引：

[http://rfc-](http://rfc-/) editor .org

RFC 通常是 为因特网基础设施的开发者编写 的， 因此，对 于普通读者来 说， 往往 过于详 细了。然而，要想获得权威信息 ，没有 比它更 好的信息来源了。HTT P/ I. 1 协议记录在 RFC 2616 中。 MIME 类型的权威列表保存在：

h七t p : / / [www.](http://www/) i a na . or g / a s s i gnme nt s / medi a- t ypes

Kerrisk 是全面 Linux 编程的圣经 ， 提供了现代网络编程的详 细讨论 [ 62] 。关 于计算机网络互联 有大量很好的通用文献[ 65, 84, 114]。伟大的科技作 家 W. Richard Stevens 编写了一系列相关的经典文献 ， 如高级

Unix 编程[ 111] 、因特网协议 [ 109, 120, 107] , 以及 Unix 网络编程[ 108, ll O] 。 认真学习 Unix 系统编程的学生会想要研究 所有这些内容。不幸的是， St evens 在 1999 年 9 月 1 日逝世。我们会永远纪住他的贡献。

# 家庭作业

u l l . 6 A. 修改 TINY 使得它会原样返回每个请求行 和请求报头 。

1.  使用你 喜欢的浏览器向TINY发送一个对静态内容的请求。把TINY 的输出记录到一个文件中。
2.  检查 TINY 的输出 ，确定 你的浏览器使用的 HTT P 的版本。
3.  参考 RFC 2616 中的 HTT P/ 1. 1 标准， 确定你的浏览器的 HTT P 请求中每个报头的含义。你可以从 www.r f c - edi t or . or g/r f c . ht ml 获得 RFC 2616 。

    \*\* 11. 7 扩展 T INY, 使得它可以提供 MPG 视频文件。用一个真正的浏览 器来检验你的工作 。

•• 11. 8 修改 TINY, 使 得 它在 SIGCHLD 处 理程序中回收操作系统分配给 CGI 子进程的资源，而 不 是 显式地等待它们终止。

•• 11. 9 修改 TINY, 使 得 当 它 服 务 静 态内容时，使 用 ma l l o c 、 r i o \_r e a dn 和r i o \_ wr i t e n , 而 不 是 mma p

和r i o wr i t e n 来 复 制 被请求文件到已连接描述符。

•• 11. 10 A. 写 出图 11- 27 中 CGI a dde r 函数的 HT ML 表单。你的表单应该包括两个文本框，用 户 将需 要相 加 的 两个数字填在这两个文本框中。你的表单应该使用 GET 方法请求内容。

B. 用这样的方法来检查你的程序：使 用 一 个 真 正 的 浏 览器向 TINY 请 求 表单，向 TINY 提 交 填写 好的 表单，然 后显示 a dder 生成的动态内容。

拿 11. 11 扩展 TINY, 以 支 持 HTT P HEAD 方法。使用 TELNET 作为 W eb 客户端来验证你的工作。

\\\* 11. 12 扩展 TINY, 使 得它服务以 HTT P POST 方式请求的动态内容。用你喜欢的 We b 浏览器来验证你的工作。

\*/ 11. 13 修改 TINY, 使 得 它 可 以 干净 地处理（而不是终止）在wr i t e 函 数 试 图 写 一 个 过 早 关 闭 的 连接时发

生的 SIGPIPE信号和 EPIPE 错误。

# 练习题答案

11\. 1

codelnetplhex2dd.c

codelnetpldd2hex.c

11 . 4 下 面是解决 方案。注意 ， 使用 i ne t \_ n t o p 要困难多少， 它要求很麻烦的强制类型转换和深层嵌套结构引用。g e t na me i n f o 函数要 简单许多 ，因 为它为我们 完成了这些工作。

codelnetplhostinfo-ntop.c

\#include "csapp.h"

| 3    | int | main(int argc, char oargv)                                          |
|------|-----|---------------------------------------------------------------------|
| 4    | {   |                                                                     |
| 5    |     | struct addrinfo \*P, •listp, hints;                                 |
| 6    |     | struct sockaddr_in•sockp;                                           |
| 7    |     | char buf[MAXLINE] ;                                                 |
|      |     | int re;                                                             |
|  1 0 |     | if (argc != 2) {                                                    |
| 11   |     | fprintf (stderr, "usage: %s \<domain name\>\\n", argv[OJ); exit(O); |

15 I• Get a list of addrinfo records•I

16 memset(&hints, 0, sizeof(struct addrinfo));

17 hints.ai_family = AF_INET; /• IPv4 only•/

18 hints.ai_socktype = SOCK_STREAM; I• Connections only•/

19 if ((re = getaddrinfo(argv[1], NULL, &:hints, &:listp)) != 0) {

20 fprintf (stderr, "getaddrinfo error: %s\\n", gai_strerror(rc)); exit(1);

22

23

1.  I• Walk the list anddisplay each associated IP address•I
2.  for (p = listp; p; p = p-\>ai_next) {
3.  sockp = (struct sockaddr_in•)p-\>ai_addr;
4.  Inet_ntop(AF_INET, &:(sockp-\>sin_addr), buf, MAXLINE);
5.  printf("%s\\n", buf);

    29

    30

6.  /• Clean up•/
7.  Freeaddrinfo (listp) ;

    33

    34 exit(O);

    35 }

    codelnetplhostinfo-ntop.c

    11\. 5 标准 I/ 0 能在 CGI 程序里工作的原 因是，在子进程中运行 的 CGI 程序不需 要显式地关闭它的输人输出流。当子进程终止时，内核会自动关闭所有描述符。
