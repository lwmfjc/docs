附录 A

#### A P P E N D I X A

错误处理

### 程序员应该总是检查系统级函数返回的错误代码。有许多细微的方式会导致出现错 误，只 有使用内核能够提供给我们的状态信息才能理解为什么有这样的错误。不幸的是， 程序员 往往不愿意进行错误检查， 因为这使他们的代码变得 很庞大，将 一行代码变成一个多行的条件语句。错误检查也是很令人迷惑的，因为不同的函数以不同的方式表示错误。

在编写本书时， 我们面临类似的问题。一方面， 我们希望代码示例阅读起来简洁简单；另一方面，我们又不希望给学生们一个错误的印象，以为可以省略错误检查。为了解 决这些问题， 我们采用了一种基于错误处理 包装函数 ( er ro r- ha ndling wra pper ) 的方法， 这是由 W. Richard Steve ns 在他的网络编程教材 [ 11 0] 中最先提出的。

### 其思想是 ，给 定某个基本的 系统级函数 f oo , 我们定义一个有相同参数、只不过开头字母大写了的包装函数 Foo。包装函数调用基本函数并检查错误。如果包装函数发现了错误，那么它就打印一条信息并终止进程。否则，它返回到调用者。注意，如果没有错误， 包装函数的行为与基本函数完全一样。换句话说，如果程序使用包装函数运行正确，那么 我们把每个 包装函数的第一个字母小 写并重新编译，也 能正确运行。

包装函数被封装在一个源文件( c s a p p . c ) 中， 这个文件被编译 和链接到每个程序中。一个独立的 头文件Cc s a p p . h ) 中包含这些包装函数的 函数原型。

本附录给出 了一个关于 U nix 系统中不同种类的错误处理的教程， 还给出 了不同风格的错误处 理包装函数的示例。c s a p p . h 和 c s a pp . c 文件可以从 CS : AP P 网站上获得。

.A. 1 Unix 系统中的错误处理

### 本书中我们遇到的系统 级函数调用使用三种不同风格的返回错误： U n ix 风格的、

Posix 风格的和 G Ai 风格的。

1.  Un ix 风格的错误处理

    像 f o r k 和 wa i t 这样 U nix 早期开发出来的函数（以及一些较老的 Pos ix 函数）的函数返回值既 包括错误代码，也 包括有用的结果。例如， 当 U nix 风格的 wa i t 函数遇到一个错误（例如没有子进程要 回收）， 它就返回一1, 并将全局变量 e rr n o 设置为指明错误原因的错误代码。如果 wa i t 成功完成， 那么它就返回有用的结果，也 就是回收的子进程的P ID。U nix 风格的错误处理代码通常具有以 下形式：

| 1 | if | ((pid = -wait (NULL)) \< 0) {                           |
|---|----|---------------------------------------------------------|
| 2 |    | fprintf(stderr, 节 ait error: %s\\n", strerror(errno)); |
|   |    | exit(O);                                                |

str err or 函数返回某个 err no 值的文本描述。

2.  Pos ix 风格的错误处理

    许多较新的 Posix 函数， 例如 P t h read 函数，只 用 返回值来表明成功( 0 ) 或者失败（非

### 。任何有用的结果都返回在通过引用传递进来的函数参数中。我们称这种方法为 P osix

730 附录 A 错 误 处 理

风格的错误处理。例如， P os ix 风格的 p t hr e a d \_ cr e a t e 函数用它的返回值来表明成功或者失败， 而通过引 用将新创建的线程的 ID ( 有用的结果）返回放在它的第一个参数中。P a s­

### ix 风格的错误处理代码通常具有以下形式：

if ((retcode = pthread_create(&tid, NULL, thread, NULL)) != 0) {

2 fprintf(stderr, "pthread_create error: %s\\n", strerror(retcode));

1.  exit(O);

    4 }

S七r er r or 函数返回r e t c o d e 某个值对应的 文本描述。

3.  GAi 风格的错误处理

    g e t a d d r i n fo ( G A D 和 g e t n a me i n f o 函数成功时返回零，失 败时返回非零值。G A I

### 错误处理代码通常具有以下形式：

if ((retcode = getaddrinfo(host, service, \&hints, \&result)) != 0) {

2 fprintf(stderr, "getaddrinfo error: %s\\n", gai_strerror(retcode));

3 exit(O);

4 }

gai \_s tr err or 函数返回r e t c o d e 某个值对应的文本描述。

### 错误报告函数小结

贯穿本书，我们使用下列错误报告函数来包容不同的错误处理风格：

\#include "csapp.h"

void unix_error(char•msg);

void posix_error(int code, char•msg); void gai_error(int code, char•msg); void app_error(char•msg);

返回： 无。

正如它们的名字表明的那样， u n i x \_ er r or 、 p o s i x \_ er r or 和 g a i \_ er r or 函数报告U n ix 风格的错误、P osix 风格的错误和 G A I 风格的错误，然后 终止。包括 a p p \_ e r r o r 函数是为了方便 报告应用错误。它只是简单地打印它的输入， 然后终止。图 A-1 展示了这些错误报告函数的代码。

codelsr 吹 sapp.c

void unix_error(char \*msg) I\* Unix-style error \*I

2 {

3 fprintf(stderr, "%s: %s\\n", msg, strerror(errno));

4 exit(O);

5 }

6

7 void posix_error(int code, char \*msg) I\* Posix-style error \*I

8 {

9 fprintf(stderr, "%s: %s\\n", msg, strerror(code));

10 exit(O);

11 }

12

13 void gai_error(int code, char \*msg) I\* Getaddrinfo-style error \*I

图A-1 错误报告函数

### 附录 A 错 误 处 理 731

| 14 | {                   |                                        |
|----|---------------------|----------------------------------------|
| 15 | fprintf(stderr,     | "%s: %s\\n", msg, gai_strerror(code)); |
| 16 | exit(O);            |                                        |
| 17 | }                   |                                        |
| 18 |                     |                                        |
| 19 | void app_error(char | \*msg) I\* App 辽 ca t i on error \*I  |
| 20 | {                   |                                        |
| 21 | fprintf(stderr,     | 欢 s\\n", msg);                        |
| 22 | exit(O);            |                                        |
| 23 | }                   |                                        |
|    |                     | code/srdcsapp.c                        |
|    |                     | 图 A-1 C 续 ）                         |

1.  2 错误处理包装函数

    下面是一些不同错误处理包装函数的示例：

    -   U nix 凤格的错误处理 包装函数。图 A-2 展示了 U nix 风格的 wa i t 函数的包装函数。如果 wa i t 返回一个错误， 包装函数打印一条消息， 然后退出。否则，它 向调用者 返回一个 P ID 。图 A-3 展示了 U nix 风格的 K过 1 函数的包装函数。注意， 这个函数和 wa i t 不同，成 功时返回 V O 过。

pid_t Wait(int \*status)

2 {

3 pid_t pid;

4

1.  if ((pid = wait(status)) \< 0)

    6 un1x_error("Wait error");

    7 return pid;

    8 }

    codelsrdcsapp.c

code/srdcsapp.c

图 A-2 Unix 风格的 wa i t 函数的包装函数

void Kill(pid_t pid, int signum)

2 {

3 int re;

4

5 if ((re = kill(pid, signum)) \< 0)

6 unix_error("Kill error");

7 }

code/srdcsapp.c

coder/s sapp.c

图A-3 Unix 风格的 ki ll 函数的包装 函数

-   P os ix 风格的错误处理 包装函数。图 A-4 展示了 P o si x 风格的 p t h r e a d \_ d e t a c h 函数的包装函数。同大多数 P os ix 风格的函数一样，它 的 错误返回码中不会包含有用的结果，所 以成功时 ， 包装函数返回 V O 过。

732 附录 A 错 误 处 理

void Pthread_detach(pthread_t tid) {

2 int re·

3

4 if ((re = pthread_detach(tid)) != 0)

5 posix_error(rc, "Pthread_detach error");

6 }

code/src/csapp.c

code/srdcsapp.c

图 A-4 Posix 风格的 pt hr ead_de t ach 函数的包装函数

-   GAI 风格的错 误 处理 包装 函 数 。 图 A-5 展示了 GAI 风 格 的 g e t a d dr i n f o 函数 的 包装函数。

code/srdcsapp.c

void Getaddrinfo(const char \*node, const char \*service,

2 const struct addrinfo \*hints, struct addrinfo \*\*res)

3 {

4 int rc;

5

6 if ((re = getaddrinfo (node, service, hints, res)) != 0)

7 gai_error(rc, "Getaddrinfo error");

8 }

code/sr吹 sapp.c

图 A-5 GAI 风格的 ge t addr i nf o 函数的包装函数

# 参考文献

[1] Advanced Micro Devices, Inc. Software Proceedings of the 4th Symposium on Operating Optimization Guide for AMD64 Processors, Systems Design and Implementation (OSDI) 2005. Publication Number 25112. pages 31--44. Usenix, October 2000.

[2] Advanced Micro Devices, Inc. AMD64 [13] R. E. Bryant. Term-level verification of a Architecture Programmer 's Manual, Volume pipelined CISC microprocessor. Technical 1: Application Programming, 2013. Publication Report CMU-CS-05-195, Carnegie Mellon

Number 24592. University, School of Computer Science, 2005.

[3] Advanced Micro Devices, Inc. AMD64 [14] R. E. Bryant and D.R. O'Hallaron. Introducing Architecture P rogrammer's Manual, Volume computer systems from a programmer's

3: General-Purpose and System Instructions, perspective. In Proceedings of the Technical 2013. Publication Number 24594. Symposium on Computer Science Education

[4] Advanced Micro Devices, Inc. AMD64 (S/GCSE), pages 90-94. ACM, February 2001. Architecture Programmer's Manual, Volume [15] D. Butenhof. Programming with Posix Threads 4:128-Bit and 256-Bit Media Instructions, 2013. Addison-Wesley, 1997.

Publication Number 26568. [16] S. Carson and P. Reynolds. The geometry of

[5] K. Arnold, J. G osling, and D. Holmes. The semaphore programs. ACM Transactions on Java Programming Language, Fourth Edition. Programming Languages and Systems9(l):25- Prentice Hall, 2005. 53, 1987.

[6] T. Berners-Lee, R. Fielding, and H. Frystyk. [17] J. B. Carter, W. C. Hsieh, L. B. Stoller, M. R. Hypertext transfer protocol - HTIP/1.0. RFC Swanson, L. Zhang, E. L. Brunvand, A. Davis, 1945, 1996. C.-C. Kuo, R. Kuramkote, M. A. Parker,

[7] A. Birrell. An introduction to programming L. Schaelicke, and T. Tateyama. Impulse: with threads. Technical Report 35, Digital Building a smarter memory controller. In Systems Research Center, 1989. Proceedings of the5th International Symposium

on High Performance Computer Architecture

[8] A. Birrell, M. Isard, C. Thacker, and T. Wobber. (HPCA), pages 70-79. ACM, January 1999.

A design for high-performance flash disks. [18] K. Chang, D. Lee, Z. Chishti, A. Alameldeen,

SIGOPS Operating Systems Review 41(2):88- 93, 2007.

C. Wilkerson, Y. Kim, and 0. Mutlu. Improving DRAM performance by parallelizing refreshes

[9] G. E. Blelloch, J. T. Fineman, P. B. Gibbons, with accesses. In Proceedings of the 20th

and H. V. Simhadri. Scheduling irregular International Symposium on High-Performance parallel computations on hierarchical caches. Computer Architecture (HP CA). ACM,

In Proceedings of the 23rd Symposium on February 2014.

Parallelism in Algorithms and Architectures [19] S. Chellappa, F. Franchetti, and M. Pilschel. (SPAA), pages 355-366. ACM, June 2011. How to write fast numerical code: A small in-

[10] S. Borkar. Thousand core chips: A technology troduction . In Generative and Transformational perspective. In Proceedings of the 44th Design Techniques in Software Engineering II, volume Automation Conference, pages 746---749. AC M, 5235 of Lecture Notes in Computer Science, 2007. pages 196-259. Springer-Verlag, 2008.

[11] D. Bovet and M. Cesati. Understanding the [20] P. Chen, E. Lee, G. Gibson, R. Katz, and Linux Kernel, Third Edition. O'Reilly Media, D. Patterson. RAID: High-performance, Inc., 2005. reliable secondary storage. ACM Computing

Surveys 26(2):145-185, June 1994.

[12) A. Demke Brown and T. Mowry. Taming the

memory hogs: Using compiler-inserted releases t21] S. Chen, P. Gibbons, and T. Mowry. Improving to manage physical memory intelligently. In index performance through prefetching. In

734 参考文献

Proceedings of the 2001 ACM SIGMOD ACM, May 1999.

International Conference on Management of [33] M. Dowson. The Ariane 5 software failure. Data, pages 235-246. ACM, May 2001. SIGSOFTSoftware Engineering Notes 22(2):84,

[22) T. Chilimbi, M. Hill, and J. Larus. Cache- 1997.

conscious structure layout. In P roceedings of [34] U. D re pper. User-level IPv6 programming the 1999 ACM Conference onP rogramming introduction. Available at http://www.akkadia Language Design and Imp lementation (P LD /), .or g/drepper/userap曰pv6.html, 2008.

pages 1- 12. ACM, May 1999

[23] E. Co ffman, M. Elphick, and A. Shoshani. System deadlocks. ACM Computing Surveys 3(2):67-78, June 1971.

[35) M. W. Eichen and J. A. Rochlis. With micro- scope and tweezers: An analysis of the In ternet viru s of November , 1988. In P roceedings of the IEEE Symposium on Research in Security and

(24] D. Cohen. On holy wars and a plea for peace. Priva cy, pages 326-343. IEEE, 1989.

IEEE Computer 14(10):48- 54, October 1981. [36] ELF-64 Object File Format, Version1.5 Draft 2, [25) P. J. Courtois, F. Heymans , and D. L. Parnas. 1998. Available at <http://www.uclibc.org/docs/>

Concurrent control with " readers " and elf-64-gen.pdf.

" wn ters." Communications of the ACM [37] R. Fielding , J. Ge ttys, J. Mogul, H. Frystyk, 14(10):667-668, 1971. L. Masinter, P. Leach , and T. Berners-Lee.

1.  C. Cowan , P. Wagle, C. Pu, S. Beattie, and Hypert ext transfer protocol - HIT P/1.1. RFC

    J. Walpole. Buffer overflows: A ttack s and 2616, 1999.

    defenses for the vulnerability of the decade. In [38] M. Frigo, C. E. Leiserson , H. Pro kop, and

    DARPA Information Survivability Conference S. Ramachandran. Cache-oblivious algorithms. and Expo (DISCEX), volum e 2, pages 119-129, In P roceedings of the 40th IEEE Symposium

    March 2000. on Foundations of Computer Science (FOCS),

2.  J. H. Crawford . The i486 CPU: Executing pages 285-297. IEEE, August 1999.

    instructions in one clock cycle. IEEE Micro [39] M. Frigo and V. Strumpen. The cache complex- 10(1):27- 36, February 1990. ity of multithreaded cache oblivious algorithms.

3.  V. Cuppu, B. Jacob, B. Davis, and T. Mudge. In Proceedings of the18th Symposium on Para[-

    A performance comparison of cont empo rary le/ism in Algorithms and Ar chitectures (SPAA), DRAM architectures. In Proceedings of the pages 271- 280. ACM, 2006.

    26th International Symposium on Computer [40] G. Gibson , D. Nagle, K. Amiri, J. Butler, Architecture (!SCA), pages 222- 233, ACM, F. Ch ang, H. Go bioff, C. Hardin , E. 凡edel,

    1999 . D. Rochb erg, and J. Zelenka. A cost-effective ,

    (29] B. Davis, B. Jaco b, and T. Mudge. The new high-bandwidth storage architecture. In DRAM interfaces: SDRA M, RDRAM, and Proceedings of the 8th International Conference variants. In Proceedings of the 3rd International on Architectural Support for Programming

    Symposium on High Performance Computing Lang uages and Operating Systems (ASPLOS), (ISHPC), volume 1940 of Lectur e Noces m pages 92- 103. ACM, October 1998.

    Computer Science, pages 26-31. Springer- [41] G. Gibson and R. Van Meter. Network attach ed Verlag, October 2000. storage architect ure. Communications of the

4.  E . Demaine. Cache-oblivious algorithms and ACM 43(11):37-45, November 2000.

    data structures. In Lecture Notes from the EEF [42] Google . 1Pv6 Adoption. Available at http://

    Summer School on Massive Data Sets. BRICS ,

University of Aarhus , Denmark , 2002.

W 吓 .google.com/intl/en/ipv6/statistics.html.

[43) J. Gustafson. Reevaluating Amdahl's law.

2.  E . W. Dijkstra. Cooperating sequential Communications of the ACM 31(5):532-533, processes. Technical Report EWD-123, August 1988.

    Technological University, Eindhoven, the

Netherlands, 1965.

(44] L. Gwennap. New algorithm improves branch

prediction. Microprocessor Report 9(4), March

3.  C. Ding and K. Kennedy. Improving cache 1995. performance of dynamic applications through

data and computation reorganizations at run time. In Proceedings of the 1999 ACM

Conference on Programming Language Design and Implementation (PLDI ), pages 229-241.

[45] S. P. Harbison and G. L. Steele, Jr. C, A

Reference Manual, Fifth Edition. Prentice Hall, 2002.

[46) J. L. Hennessy and D. A. Patterson. Computer

参考文献 735

Architecture: A Quantitative Approach, Fifth [58] R. Katz and G. Borriello. Contemporary Logic Edition. Morgan Kaufmann , 2011. Design, Second Edttion. Prentice Hall, 2005.

1.  M. Herlihy and N. Shavit. The Art of Multi- [59] B. W. Kernighan and R. Pike. The Practice of processor Programming. Morgan Kaufmann, Programming. Addison-Wesley, 1999.

    2008\. [60] B. Kernighan and D. Ritchie. The C Program-

2.  C. A. R. Hoare. Monitors: An operating system ming Language, First Edition. Prentice Hall, structuring concept. Communications of the 1978.

    ACM 17(10):549-557, October 1974. [61] B. Kernighan and D. Ritchie. The C Program-

3.  Intel Corporation. Intel 64 and IA-32 Ar- ming Language, Second Edi tion. Prentice Hall, chitectures Optimization Reference Manual . 1988.

    Available at http: //www.inte l.com/content / [62] Michael Kerrisk. The Linux Programming

    W 吓 /us/en/processors/architectures-so ftware- Interface. No Starch Press, 2010.

    developer-manuals.html.

    [63] T. Kilbu rn, B. Edwards, M. Lanigan, and

4.  Intel Corporation. Intel 64 and IA-32 Ar- F. Sumner. One-level storage system. IRE

    chitectures Software Developer's Manual, Transactions on Electronic Computers EC- Volume 1: Basic Architecture. Available at 11:223- 235, April 1962.

    http: //[www.intel.com/content/www/us/en/](http://www.intel.com/content/www/us/en/)

    processors/architectures-software-developer- [64] D. Knuth. The Art of Computer Programming, manuals.html. Volume 1: Fundamental Algorithms, Third

5.  Intel Corporation. Intel 64 and IA-32 Ar- Edition. Addison-Wesley, 1997.

    chitectures Software Developer 's Manual, [65] J. Kurose and K. Ross. Computer Networking: A Volume 2: Instruction Set Reference. Available Top-Down App roach, Sixth Edition. Addison- at <http://www.intel.com/content/www/us/en/> Wesley, 2012.

    processors/architectures-software-developer- [66] M. Lam, E. Rothberg, and M. Wolf. The manuals.html. cache performance and optimizations of

    [52) Intel Corporation. Intel 64 and IA-32 Architec- blocked algorithms. In Proceedings of the tures Software Develop er 's Manual, Volume 3a 4th International Conference on Architectural System Programming Guide, Part 1. Available Support for Programming Languages and

    at http :/[/www.intel.com/content](http://www.intel.com/content/www/us/en/)/[www/us/en/](http://www.intel.com/content/www/us/en/) Operating Systems (ASPLOS), pages 63-74. processors/architectures-software-developer- ACM, April 1991.

    manuals.html. [67] D. Lea. A memory allocator. Available at

    [53] Intel Corporation. Intel Solid-State Drive 730 [http://gee.cs.oswego.edu/dl/html/malloc.html,](http://gee.cs.oswego.edu/dl/html/malloc.html) Series: Product Specification. Available at 1996.

    htt p://www.inte l.com/content/www/us/en/solid- [68] C. E. Leiserson and J. B. Saxe. Retiming state-drives/ssd-730-series-spec.html. synchronous circuitry. Algorithmica 6(1-6),

    [54) Intel Corporation. Tool Interface Standards June 1991.

    Portable Formats Specification, Version 1.1, [69] J. R. Levine. Linkers and Loaders. Morgan 1993. Order number 241597. Kaufmann , 1999.

    (55] F. Jo nes, B. Prince , R. Norwood, J. Hartigan, [70] David Levinthal. Performance Analysis Guide

    W. Vogley, C. Hart, and D. Bondurant. for Intel Core i7 Processor and Intel Xeon Memory a new era of fast dynamic RAMs 5500 Processors. Available at https://softwa re (for video applications). IEEE Spectrum, pages .intel.com/sites/products/collatera l/hpc/vtune/ 43--45, October 1992. performance_analysis_guide.pdf.

6.  R. Jones and R. Lins. Garbage Collection: [71] C. Lin and L. Snyder. Principles of Parallel

Algorithms for Automatic Dynanuc Memory Management. Wiley, 1996.

Programming. Addison Wesley, 2008.

2.  M. Kaashoek , D. Engler, G. Ganger , H. Briceo, [72] Y. Lin and D. Padua. Compiler analysis of

R. Hunt, D. Maziers, T. Pinckney, R. Gr皿m,

J. Jannotti , and K. MacKenzie. Application performance and flexibility on E xokernel systems. In Proceedings of the 16th ACM

irregular memory accesses. In Proceedings of the 2000 ACM Conference on Programming Language Design and Implementation (PLDJ), pages 157- 168. ACM, June 2000.

Symposium on Operating System Principles (73] J. L. Lions. Ariane 5 Flight 501failure. Technical

(SOSP), pages 52-65. ACM, October 1997. Re port, European Space Agency, July 1996.

736 参考文献

1.  S. Macguire . Writing Solid Code. Microsoft (87) W. Pugh. The Omega test: A fast and practical Press, 1993. integer programming algorithm for depen-
    1.  S. A. Mahlke, W. Y. Chen, J. C. Gyllenhal, and dence analysis. Communications of the ACM

        W.W. Hwu. Compiler code transformations for 35(8):102-114, August 1992.

        superscalar-based high-performance systems. [88] W. Pugh. Fixing the Java memory model. In In Proceedings of the 1992 ACM/IEEE Proceedings of the ACM Conference on Java Conference on Supercomputing, pages 808-817 Grande, pages 89-98. ACM, June 1999.

        ACM, 1992.

        [89] J. Rabaey, A. Chandrakasan, and B. Nikolic.

    2.  E. Marshall. Fatal error: How Patriot over- Digital Integrated Circuits: A Design Perspec- looked a Scud. Science, page 1347, March 13, tive, Second Edition. Prentice Hall, 2003. 1992.
    3.  M. Matz, J. Hubicka, A. Jaeger, and M. Mitchell. [90] J. Reinders. Intel Threading Building Blocks.

| System V application binary interface AMD64 architecture processor supplement. Technical       |  [91] |  D. Ritchie . The evolution of the Unix time- |
|------------------------------------------------------------------------------------------------|-------|-----------------------------------------------|
| Report, x86-64.org, 2013. Available at http://                                                 |       | sharing system. AT&T Bell Laboratories        |
| [www.x86-64.org/documenta tion_folder/abi-0](http://www.x86-64.org/documentation_folder/abi-0) |       | Technical Journal 63(6 Part 2):1577-1593,     |
| .99.pdf.                                                                                       |       | October 1984.                                 |

1.  J. Morris, M. Satyanarayanan, M. Conner, [92] D. Ritchie . The development of the C language.

    J. Howard, D. Rosenthal, and F.Smith. Andrew: In Proceedings of the 2nd ACM SIGPLAN A distributed personal computing environment. Conference on History of Programming Communications of the ACM, pages 184-201, Languages, pages 201-208. ACM, April 1993. March 1986.

    1.  T. Mowry, M. Lam, and A. Gupta. Design [93] D. Ritchie and K. Thompson. The Unix time-

and evaluation of a compiler algorithm for prefetching. In Proceedings of the 5th

sharing system. Communications of the ACM 17(7):365-367, July 1974.

International Conference on Architectural [94] M. Satyana rayanan , J. Kistler, P. Kumar, Support for Programming Languages and M. Okasaki, E. Siegel, and D. Steere. Coda: Operating Systems (ASP L OS), pages 62-73 A highly available file system for a distributed ACM, October 1992. workstation environment. IEEE Transactions

1.  S. S. Muchnick. Advanced Compiler Design and on Computers 39(4):447-459, April 1990.

    Implementation. Morgan Kaufmann, 1997. (95) J. Schindler and G. Ganger. Automated disk

    1.  S. Nath and P. Gibbons. Online maintenance of drive characterization. Technical Report CMU- very large random samples on flash sto rage. In CS-99-176, School of Computer Science, Proceedings of VLDB, pages 970-983. VLDB Carnegie Mellon University, 1999.

        Endowment, August 2008. [96] F. B. Schneider and K. P Birman. The

    2.  M. Overton . Numerical Computing with IEEE monoculture risk put into context. IEEE Floating Point A rithmetic. SIAM, 2001. Security and Privacy 7(1):14-17, January 2009.
    3.  D. Patterson , G. Gibson, and R. Katz. A case for [97] R. C. Seacord. Secure Coding in C and C++, redundant arrays of inexpensive disks (RAID). Second Edition. Addison-Wesley, 2013.

        In Proceedings of the 1998 ACM SIG MOD

        International Conference on Management of [98] R. Sedgewick and K. Wayne. Algorithms, Fourth Data, pages 109-116. ACM, June 1988. Edition. Addison-Wesley, 2011.

    4.  L. Peterson and B. Davie . Computer Networks: (99] H. Shacham, M. Page, B. Pfaff, E.-J. Goh, A Systems Approach, Fifth Edition. Morgan N. Modadugu, and D. Boneh. On the effec -

        Kaufma nn, 2011. tiveness of address-space randomization. In

    5.  J. Pincus and B. Baker. Beyond stack smashing: Proceedings of the 11th ACM Conference on Recent advances in exploiting buffer overruns. Computer and CommunicationsSecurity (CCS), IEEE Security and Privacy 2(4):20-27, 2004. pages 298-307. ACM, 2004.
    6.  S. Przybylski. Cache and Memory Hierarchy [100) J.P. Shen and M. Lipasti. Modern Processor De- Design: A Performance-Directed Approach. sign: Fundamentals of Superscalar Processors. Morgan Kaufmann, 1990. McGraw Hill, 2005.

参考文献 737

[101] B. Shriver and B. Smith. The Anatomy of a High-Performance Microprocessor:A Systems Perspective. IEEE Computer Society, 1998.

Architecture (HPCA), pages 168-179. IEEE, February 1997.

1.  E. H. Spafford. The Internet worm program: An analysis. Technical Report CSD-TR-823, Department of Computer Science, Purdue University, 1988.
2.  W. Stallings. Operating Systems: Internals and Design Principles, Eighth Edition. Prentice Hall, 2014.
3.  W. R. Stevens . TCP/IP Illustrated, Volume 3: TCP for Transactions, H TTP, NNTP and the Unix Domain Protocols. Addison-Wesley, 1996.
4.  W. R. Stevens . Unix Network Programming: Interprocess Communications, Second Edition, volume 2. Prentice Hall, 1998.

    [109) W.R. Stevens and K. R. Fall. TCP/IP Illustrated, Volume 1: The P rotocols, Second Edition.

    Addison-Wesley, 2011.

5.  W. R. Stevens, B. Fenner, and A. M. Rudoff. Unix Network Programming: The Sockets Networking AP/ , Third Edition, volume 1. Prentice Hall, 2003.
6.  W. R. Stevens and S. A. Rago. Advanced Programming in the Unix Environment , Third Edition. Addison-Wesley, 2013.
7.  T. Stricker and T. Gross. Global address space, non-uniform bandwidth: A memory system performance characterization of parallel systems. In Proceedings of the 3rd International Symposium on High Performance Computer

2000.

1.  J. F. Wakerly. Digital Design Principles and P ractices,Fourth Edition. Prentice Hall, 2005.
2.  M. V. Wilkes. Slave memories and dynamic storage allocation. IEEE Transactions on Electronic Computers, EC-14(2), April 1965.
3.  P. Wilson, M. Johnstone, M. Neely, and D. Boles. Dynamic storage allocation: A survey and critical review. In International Workshop on Memory Management , volume 986 of Lecture Notes in Computer Science, pages 1- 116. Springer-Verlag, 1995.
4.  M. Wolf and M. Lam. A data locality algorithm. In P roceedings of the 1991 ACM Conference on Programming Language Design and Implementation (PLDI), pages 30-44, June 1991.
5.  G. R. Wright and W. R. Stevens . TCP/IP Illustrated, Volume 2: The Implementation . Addison-Wesley, 1995.
6.  J. Wylie, M. Bigrigg, J. Strunk, G. Ganger,

    H. Kiliccote, and P. Khosla. Survivable information storage systems. IEEE Computer 33:61-6 8, August 2000.

7.  T.-Y. Yeh and Y. N. Patt. Alternative implemen­ tation of two-level adaptive branch prediction. In Proceedings of the19th Annual International Symposium on Computer Architecture (!SCA), pages 451-461. ACM, 1998.

# 推 荐 阅 读 －

![](img/dffe0f9215f73077b5410899b43dd464.jpeg)![](img/3823304266a2099d3195cecc39e1ee71.jpeg)n-

严气 咱世rfflll

.

"-' cOMPUTER ' · ORGANIZATIO '

AND DESIG

. ,,, I '''

'I,, .·

-   ,, ..

    1,,'

-   ![](img/f5602ca82b6fc8129693c7f49f0c8d95.jpeg),, If/•;.

## 计算机组成与设计： 硬件／软件接（口原书第 5 版） 计算机组咸与设计： 硬件／软件接（口英文饭 ·第5版·亚洲饭）

作者 戴维A. 帕特森等

ISBN, 978- 7- 111- 50482- 5 定 价 99.00 元

作 者 David A. Patterson

ISBN: 978-7-111-45316-1 定 价 139.00 元

#### ![](img/575d1844b6e484463627c1e81c63abf8.jpeg) ![](img/a0295ff695f51fced4f09b898b2e3084.jpeg)

计算机体系结构： 量化研究方法（英文版，第5版） 计算机系统：系统架构与操作系统的高度纂成

\- . . . ..

作者JohnL.Henne等ssy

作者 阿麦肯尚尔·拉姆阿堪德兰 等

ISBN: 978- 7- 111- 36458- 0 定 价 138.00元 ISBN 978- 7- 111- 50636- 2 定 价 99.00 元

如何使用本书

从程序员的角度来学习计算机系统是如何工作的会非常有趣。最理想的学习方法是在真正的系统上解决具体的问题，或是编写和运行程序。这个主题观念贯穿本书始终。因此我们建议你用如下方式学习这本书：

．学习一个新概念时，你应 该立刻做一做紧随其后的一个或多个练习题来检验你的理解。这些练习题的解答在每章的末尾。要先尝试自己来解答每个问题， 然后再查阅答案。

-   每一章后都有一组难度不同的作业题，这些题目需要的时间从十几分钟到十几个小时，但建议你尝试完成这些作业题，完成之后你会发现对系统的理解更加深入。
    -   本书中有丰富的代码示例， 鼓励你在系统上运行这些示例的源代码。
    -   我们邀请国内名师录制了本书的导读，从中你可以了解各章的重点内容和知识关联，形成关千计算机系统的知识架构。
-   向老师或他人请教和交流是很好的学习方式 。我们将不定期组织线上线下的学习活动， 你可以登录本书网络社区及时了解活动的信息，井与学习本书的其他读者交流、讨论。

为帮助读者更好地学习本书，我们开设了本书的网络社区，请扫描如下二维码或登录[http://www.](http://www/) hzmedia.com .cn/e/jsj 加入社区，获 得本书相关学习资源，了 解活动信息。

![](img/545b6def55f33fb5ece0a7e467359086.jpeg)

![](img/c965dfc6e571b8a7daec8b46ef33d1e2.jpeg) 深入理解计算机系统 ![](img/59b61e8646bf8231b35c89bff3671036.jpeg)
