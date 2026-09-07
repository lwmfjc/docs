---
title: 4
description: 4
categories:
  - 学习
tags:
  - STM32
  - 单片机
  - 江科大
date: 2026-09-07T07:25:20+08:00
lastmod: 2026-09-07T07:25:20+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- STM32开发方式
	- 基于寄存器：用程序直接配置寄存器
		- 最底层，最直接，但是由于STM32结构复杂，寄存器太多 ~~不推荐~~ 
	- ==【本课程】基于标准库==，也就是库函数：使用ST官方提供的封装好的函数，通过调用函数来间接地配置寄存器。 
		- ST对寄存器封装的较好，所以这种方式既能满足对寄存器的配置，对开发人员也比较友好，有利于提高开发效率
	- 基于HAL库：图形化界面快速配置STM32
		- 适合快速上手STM32，但是隐藏了底层逻辑

------  

# 库

- 课程资料下载：  
	- 下载链接	https://pan.baidu.com/s/1h_UjuQKDX9IpP-U1Effbsw?pwd=dspb
	- 压缩包解压密码	32

- 标准外设库--> `TM32入门教程资料\固件库\STM32F10x_StdPeriph_Lib_V3.5.0.zip`

```shell
STM32入门教程资料\固件库\STM32F10x_StdPeriph_Lib
_V3.5.0
├── Libraries #库函数的文件，建工程会用到
├── Project #官方提供的工程示例和模版（用库函数时可参考）
├── Release_Notes.html #库函数发布文档
├── stm32f10x_stdperiph_lib_um.chm #库函数使用手册
├── Utilities #STM32官方评估版（小电路板）的相关例程
└── _htmresc
```

## 解释一下库

>
> 1. ARM(设计CPU内核的公司) → Cortex-M → Cortex-M3 →
> (ST公司)STM32F1 → STM32F103C8T6
> 2. ST 在设计自己的芯片时，把 ARM 授权给它的 Cortex-M3 设计集成进去，然后整个芯片一起制造出来 
> 

```shell
STM32F10x_StdPeriph_Lib_V3.5.0
│
└── Libraries
    │
    ├── CMSIS
    │   └── ARM Cortex-M3 内核 + STM32F10x 芯片底层定义
    │
    └── STM32F10x_StdPeriph_Driver
        ├── inc
        │   └── 各种外设的 .h 头文件
        │
        └── src
            └── 各种外设的 .c 实现文件
```

> 
> 关于最核心的两部分的解释：
> 1. CMSIS = “让程序认识 STM32 + Cortex-M3”
> 2. StdPeriph_Driver = “让你方便操作 STM32 的各种硬件==外设==”  ~~指的是片上外设（芯片上的，内核之外的），比如GPIO，USART，TIM，ADC，SPI，I2C，CAN，DMA~~  


> 外部器件/外接设备（芯片外的）：PA0->LED，PA1->按键，USART->USB转串口，I2C->OLED，TIM->电机驱动器->电机

### CMSIS

ARM 为 Cortex-M 系列制定的一套软件接口标准  

```shell
CMSIS
├── CM3 #Cortex-M3 内核
│   ├── CoreSupport #ARM Cortex-M3 内核本身的定义和支持代码
│   └── DeviceSupport #STM32F10x 芯片本身，即STM公司 针对 STM32F10x 做的支持，最重要的是"stm32f10x.h"，里面定义了 STM32F10x 的：外设寄存器，外设地址，GPIO，RCC，USART，TIM，ADC，DMA，NVIC，等等
├── CMSIS debug support.htm
├── CMSIS_changes.htm
├── Documentation
│   └── CMSIS_Core.htm
└── License.doc
```

####  CMSIS下CM3目录下的CoreSupport和DeviceSupport

```shell
├── CM3 #ARM 的 Cortex-M3 内核相关代码(ARM公司提供的)
|  ├── CoreSupport #======【ARM】对应Cortex-M3(这里不关心 STM32F103) CPU 内核本身======
|  |  ├── core_cm3.c #一些实现
|  |  └── core_cm3.h# 1. Cortex-M3内核寄存器 2. 内核数据结构 3. 内核相关宏 ||||#比如NVIC，SysTick，SCB
|  └── DeviceSupport #======【ST】ST 的 STM32F103 领域======
|     └── ST
|        └── STM32F10x
|           ├── Release_Notes.html
|           ├── startup #Cortex-M3 的机器指令是一套统一的，但汇编源代码语法不是统一的。Keil、GCC、IAR 使用不同汇编器，所以同一个 STM32 启动流程需要提供不同版本的 startup.s。注意下面：.s后缀是汇编源代码文件；Keil5使用ARM汇编器
|           |  ├── arm #芯片上电后的第一段程序，即启动文件（汇编文件），里面不一样的文件，代表STM32F10x 的不同容量 ★★：所以江科大的课程里把这部分复制过去了
|           |  |  ├── startup_stm32f10x_cl.s
|           |  |  ├── startup_stm32f10x_hd.s
|           |  |  ├── startup_stm32f10x_hd_vl.s
|           |  |  ├── startup_stm32f10x_ld.s
|           |  |  ├── startup_stm32f10x_ld_vl.s
|           |  |  ├── startup_stm32f10x_md.s #STM32F103C8T6属于这个
|           |  |  ├── startup_stm32f10x_md_vl.s #Value Line 是 ST 的一个低成本系列：比如还有STM32F103xC8 value line 这种
|           |  |  └── startup_stm32f10x_xl.s
|           |  ├── gcc_ride7
|           |  |  ├── startup_stm32f10x_cl.s
|           |  |  ├── startup_stm32f10x_hd.s
|           |  |  ├── startup_stm32f10x_hd_vl.s
|           |  |  ├── startup_stm32f10x_ld.s
|           |  |  ├── startup_stm32f10x_ld_vl.s
|           |  |  ├── startup_stm32f10x_md.s
|           |  |  ├── startup_stm32f10x_md_vl.s
|           |  |  └── startup_stm32f10x_xl.s
|           |  ├── iar
|           |  |  ├── startup_stm32f10x_cl.s
|           |  |  ├── startup_stm32f10x_hd.s
|           |  |  ├── startup_stm32f10x_hd_vl.s
|           |  |  ├── startup_stm32f10x_ld.s
|           |  |  ├── startup_stm32f10x_ld_vl.s
|           |  |  ├── startup_stm32f10x_md.s
|           |  |  ├── startup_stm32f10x_md_vl.s
|           |  |  └── startup_stm32f10x_xl.s
|           |  └── TrueSTUDIO
|           |     ├── startup_stm32f10x_cl.s
|           |     ├── startup_stm32f10x_hd.s
|           |     ├── startup_stm32f10x_hd_vl.s
|           |     ├── startup_stm32f10x_ld.s
|           |     ├── startup_stm32f10x_ld_vl.s
|           |     ├── startup_stm32f10x_md.s
|           |     ├── startup_stm32f10x_md_vl.s
|           |     └── startup_stm32f10x_xl.s
|           ├── stm32f10x.h # 极其重要，定义STM32F103芯片里面所有外设的地址和结构，涉及GPIO，USART，TIM，ADC，RCC。比如 #define GPIOA ((GPIO_TypeDef *) GPIOA_BASE) ，typedef struct { uint32_t CRL; uint32_t CRH; uint32_t IDR; uint32_t ODR; }GPIO_TypeDef;
|           ├── system_stm32f10x.c # STM32系统初始化 ，包括1. 时钟初始化 2. SystemCoreClock变量 3. SystemInit()
|           └── system_stm32f10x.h 
├── CMSIS debug support.htm
├── CMSIS_changes.htm
├── Documentation
|  └── CMSIS_Core.htm #ARM CMSIS说明文档。
└── License.doc
```

STM上电以后：  

```shell
STM32上电
   |
   ↓
startup_stm32f10x_md.s
   |
   ├── 设置栈
   |
   ├── 设置中断表
   |
   ├── 初始化C语言运行环境：初始化 .data 段、清零 .bss 段，再加上一些必要的运行时准备
   |
   ├── 调用 SystemInit()
   |
   ↓
system_stm32f10x.c
   |
   └── 配置72MHz系统时钟
   |
   ↓
main.c
   |
   └── 你的程序开始运行
```

>
> StdPeriph_Driver 则是在 main() 之后，你开始控制 GPIO、USART、TIM 时才大量使用。
>

小总结：  

![](img/ly-20260907123913917.png)
#### 精简

```shell
CMSIS
│
├── CoreSupport
│       ↓
│   ARM Cortex-M3
│   （CPU内核）
│
│
└── DeviceSupport
        ↓
    ST STM32F10x
        │
        ├── stm32f10x.h
        │       ↓
        │   STM32外设寄存器定义
        │
        ├── system_stm32f10x.c
        │       ↓
        │   时钟初始化
        │
        └── startup
                ↓
            芯片启动代码
```

### STM32F10x_StdPeriph_Driver

==STM32F10x 标准外设驱动库==，以后写 STM32 程序最常接触的部分  

```shell
STM32F10x_StdPeriph_Driver
│
├── inc #头文件
└── src #真正的实现
```

例如：  

```shell
stm32f10x_gpio.h
        ↓
告诉你怎么操作 GPIO

stm32f10x_rcc.h
        ↓
告诉你怎么操作时钟

stm32f10x_usart.h
        ↓
告诉你怎么操作 USART

stm32f10x_tim.h
        ↓
告诉你怎么操作 TIM
```

### 总结

![](img/ly-20260907082522025.png)  

STM32F10x_StdPeriph_Driver，就是给这些硬件外设提供一套比较方便的 C 语言 API。  

再具体实际点：  

![](img/ly-20260907082650325.png)  


==STM32F10x_StdPeriph_Driver 是建立在 DeviceSupport 之上的更高一层驱动库。它不是把 DeviceSupport 的代码重新“包装进来”，而是利用 DeviceSupport 提供的寄存器/芯片定义，进一步提供更易用的外设 API。==  

![](img/ly-20260907083033110.png)  

![](img/ly-20260907083144648.png)  


# 新建一个工程

![](img/ly-20260907102149513.png)  

![](img/ly-20260907102122358.png)  
![](img/ly-20260907102414490.png)  

新建完成  

![](img/ly-20260907102519111.png)  

```shell
#查看一下生成的工程目录结构
D:\software\单片机代码\STM32江科大\2-
1 STM32工程模板
├── DebugConfig
 | └── Target_1_STM32F103C8_1.0.0.dbgconf
├── Listings
├── Objects
├── Project.uvguix.ly.bak
├── Project.uvoptx
```

然后复制STM32启动文件（ARM汇编器需要用的）

首先打开一个Windows文件管理器窗口，打开工程所在文件夹，然后(再开一个窗口)找到下面这个目录：

![](img/ly-20260907125850388.png)  

复制这些==.s后缀文件==到工程文件夹下的start文件夹（没有就新建）  

- ==stm32f10x.h==，用来描述STM32有哪些寄存器和地址
- ==system_stm32f10x.c==，==system_stm32f10x.h==：STM32系统初始化 ，包括1. 时钟初始化 2. SystemCoreClock变量 3. SystemInit()

把以上3个文件也复制到start文件夹  

STM32是由内核和内核外围的设备组成的，内核的寄存器描述和外围设备的描述文件不是在一起的，以下添加内核寄存器描述、以及一些内核配置函数  

- ==core_cm3.c== 
- ==core_cm3.h==   ~~1. Cortex-M3内核寄存器 2. 内核数据结构 3. 内核相关宏 ||||#比如NVIC，SysTick，SCB~~ 

把以上2个文件也复制到start文件夹  

## 回到keil软件

### 添加基本文件

添加刚才复制的文件

点击后F2修改组名，改成Start  

![](img/ly-20260907131102932.png)  

右键Start添加文件  

![](img/ly-20260907131142061.png)  

先添加 `start/startup_stm32f10x_md.s`，然后还要再添加所有的`.c`和`.h`，之后Close  

![](img/ly-20260907131659129.png)  

上面的钥匙表示这些文件是不需要修改的  

### 添加头文件路径

![](img/ly-20260907131927303.png)  
![](img/ly-20260907132002065.png)  


### main函数

1. 在Windows文件管理中新建User文件夹
2. Target右键：AddGroup
   ![](img/ly-20260907132316763.png)  
   
   修改名字为User
3. 