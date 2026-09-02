---
title: HelloWorld
description: HelloWorld
categories:
  - 学习
tags:
  - 串口通信
  - 51单片机
date: 2026-09-02T16:47:42+08:00
lastmod: 2026-09-02T16:47:42+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
这篇文章不是寻常意义上的HelloWorld，但是是我第一次尝试51单片机，原因是我想学的ros视频课程中出现了OpenRB-150开发板和舵机XL330-M288-T，我手头没有实物，只有吃灰了很久的51单片机，想着能否用单片机相似的模拟一下  

# 工具
路径  ~~普中-7开发板资料\5--开发工具：卖家给的文件~~ 
- 3-程序下载软件-Keil（我这里是4，单片机卖家提供的资料里提供的版本）
- 4-常用辅助开发工具-串口调试助手（丁丁）（这里是SSCOM ~~单片机卖家提供的~~ ）
- 4-常用辅助开发工具-程序烧制工具PZ-ISO v3.7 ~~单片机卖家提供的~~ 
- 51单片机 ~~实物~~ ，我这里是普中科技的A7标配 
- 普中公司给的资料地址  `http://www.prechin.cn/gongsixinwen/208.html` 
# 测试单片机是否正常

- 用USB-A 接口数据线连接单片机，接口旁边还有个按钮，要按下去才能开机，开机后蓝灯会亮，还有一个红灯亮着 ~~我不知道干嘛的，知识水平不够~~ 
- 打开PZ-ISP
	- 芯片我这里选择STC89C5xxSeries
	- 串口号COM3 蓝牙链接上的标准串行 （自动的）
	- 波特率9600
	- 双倍速12T（默认）
	- 按文件擦除
- 接线 ~~P20->D1，其他的按方向插下去就行。别接错了，很重要~~ 
~~3--手把手教你学51单片机\实验现象演示这里有实验现象演示~~  

![](img/ly-20260902171456099.png)

- 选择文件路径
	- 打开文件：我这里选择了最简单的流水灯 ~~`4--实验程序\1--基础实验\2-点亮第一个LED(解压后选择里面的template.hex[.hex后缀的那个，应该是编译后生成的])`~~ 
	- 程序下载---成功后会提示：`恭喜！文件下载完毕`
	- 然后D1灯就亮了绿色
	- 点亮LED灯源文件main.c
```C
/**************************************************************************************
深圳市普中科技有限公司（PRECHIN 普中）
技术支持：www.prechin.net
PRECHIN
 普中
 
实验名称：点亮第一个LED
接线说明：	
实验现象：下载程序后“LED模块”的D1指示灯点亮
注意事项：																				  
***************************************************************************************/
#include "reg52.h"

sbit LED1=P2^0;	//将P2.0管脚定义为LED1

/*******************************************************************************
* 函 数 名       : main
* 函数功能		 : 主函数
* 输    入       : 无
* 输    出    	 : 无
*******************************************************************************/
void main()
{
	LED1=0;	//LED1端口设置为低电平
	while(1)
	{
		
	}
		
}
```

测试完可以关按钮把线拔了  

# 串口数据收发

- 重新打开按钮（开机）
## 新建项目并编译

- 打开开发工具Ceil（主要写程序和编译）
- 在桌面新建文件夹HelloWorld
- 新建项目 ~~project --> new，文件夹选择刚才那个HelloWorld。uvproj名字随便输，我写的`HelloWorld`~~ 
  ![](img/ly-20260902172500960.png)
- 在弹出的选择芯片的页面，如果是普通 51 单片机，展开 Atmel 找到 AT89C51
  ![](img/ly-20260902173804643.png)
- 选择'是'
  ![](img/ly-20260902173835332.png)
- File-新建文件
  ![](img/ly-20260902172553659.png)  
- 粘贴下面的文件代码 ~~借助ai生成串口通信的处理代码~~ 
  
```c
#include "REG52.h"

typedef unsigned int u16;
typedef unsigned char u8;


/********************
 电机状态模拟
********************/

int target_position = 0;     //目标位置

int current_position = 0;    //当前位置

int target_velocity = 1;     //目标速度

int current_velocity = 0;    //当前速度



/********************
 串口缓存
********************/

char rx_buffer[30];

u8 rx_index = 0;

bit command_ready = 0;



/********************
 定时器
********************/

u16 timer_count = 0;



/********************
 串口初始化
********************/

void uart_init()
{

    TMOD |= 0X20;

    SCON = 0X50;

    PCON = 0X80;


    TH1 = 0XFA;

    TL1 = 0XFA;


    ES = 1;

    EA = 1;

    TR1 = 1;

}



/********************
 定时器0初始化
********************/

void timer0_init()
{

    TMOD &= 0XF0;

    TMOD |= 0X01;


    TH0 = 0XDC;

    TL0 = 0X00;


    ET0 = 1;

    EA = 1;

    TR0 = 1;

}



/********************
 串口发送
********************/

void uart_send(u8 dat)
{

    SBUF = dat;

    while(!TI);

    TI = 0;

}



void uart_send_string(char *str)
{

    while(*str)
    {

        uart_send(*str);

        str++;

    }

}



/********************
 数字发送
********************/

void send_number(int num)
{

    char buf[8];

    int i=0;



    if(num==0)
    {

        uart_send('0');

        return;

    }



    if(num<0)
    {

        uart_send('-');

        num=-num;

    }



    while(num>0)
    {

        buf[i++]=num%10+'0';

        num=num/10;

    }



    while(i>0)
    {

        uart_send(buf[--i]);

    }

}



/********************
 字符串转数字
********************/

int str_to_int(char *str)
{

    int value=0;


    while(*str>='0' && *str<='9')
    {

        value=value*10+(*str-'0');

        str++;

    }


    return value;

}



/********************
 命令解析
********************/

void parse_command()
{


    uart_send_string("CMD:");

    uart_send_string(rx_buffer);

    uart_send_string("\r\n");



    /*
        SET_POS 100
    */

    if(rx_buffer[0]=='S' &&
       rx_buffer[1]=='E' &&
       rx_buffer[2]=='T' &&
       rx_buffer[3]=='_' &&
       rx_buffer[4]=='P' &&
       rx_buffer[5]=='O' &&
       rx_buffer[6]=='S')
    {

        target_position = str_to_int(&rx_buffer[8]);


        uart_send_string("OK SET_POS\r\n");


        return;

    }



    /*
        SET_VEL 10
    */

    if(rx_buffer[0]=='S' &&
       rx_buffer[1]=='E' &&
       rx_buffer[2]=='T' &&
       rx_buffer[3]=='_' &&
       rx_buffer[4]=='V' &&
       rx_buffer[5]=='E' &&
       rx_buffer[6]=='L')
    {

        target_velocity = str_to_int(&rx_buffer[8]);


        uart_send_string("OK SET_VEL\r\n");


        return;

    }




    /*
        GET_POS
    */

    if(rx_buffer[0]=='G' &&
       rx_buffer[1]=='E' &&
       rx_buffer[2]=='T' &&
       rx_buffer[3]=='_' &&
       rx_buffer[4]=='P' &&
       rx_buffer[5]=='O' &&
       rx_buffer[6]=='S')
    {


        uart_send_string("POS:");

        send_number(current_position);

        uart_send_string("\r\n");


        return;

    }





    /*
        GET_VEL
    */

    if(rx_buffer[0]=='G' &&
       rx_buffer[1]=='E' &&
       rx_buffer[2]=='T' &&
       rx_buffer[3]=='_' &&
       rx_buffer[4]=='V' &&
       rx_buffer[5]=='E' &&
       rx_buffer[6]=='L')
    {


        uart_send_string("VEL:");

        send_number(current_velocity);

        uart_send_string("\r\n");


        return;

    }




    /*
        STATUS
    */

    if(rx_buffer[0]=='S' &&
       rx_buffer[1]=='T' &&
       rx_buffer[2]=='A' &&
       rx_buffer[3]=='T' &&
       rx_buffer[4]=='U' &&
       rx_buffer[5]=='S')
    {


        uart_send_string("TARGET:");

        send_number(target_position);


        uart_send_string(" POS:");

        send_number(current_position);


        uart_send_string(" VEL:");

        send_number(current_velocity);


        uart_send_string("\r\n");


        return;

    }




    uart_send_string("ERROR\r\n");

}





/********************
 主函数
********************/

void main()
{

    uart_init();

    timer0_init();



    while(1)
    {


        if(command_ready)
        {

            command_ready=0;


            parse_command();

        }

    }

}





/********************
 定时器中断

 模拟电机运动

********************/

void timer0_isr() interrupt 1
{


    TH0=0XDC;

    TL0=0X00;



    timer_count++;



    if(timer_count>=50)
    {


        timer_count=0;



        /*
            正方向运动
        */

        if(current_position < target_position)
        {

            current_position += target_velocity;


            current_velocity = target_velocity;



            if(current_position > target_position)
            {

                current_position=target_position;

            }

        }



        /*
            反方向运动
        */

        else if(current_position > target_position)
        {


            current_position -= target_velocity;


            current_velocity = -target_velocity;



            if(current_position < target_position)
            {

                current_position=target_position;

            }


        }



        /*
            到达目标

        */

        else
        {

            current_velocity=0;

        }


    }


}







/********************
 串口中断

 接收数据

********************/

void uart_isr() interrupt 4
{

    char rcv_data;



    if(RI)
    {

        RI=0;


        rcv_data=SBUF;



        if(rcv_data=='\r' || rcv_data=='\n')
        {


            if(rx_index>0)
            {

                rx_buffer[rx_index]='\0';


                command_ready=1;


                rx_index=0;

            }


        }


        else
        {


            if(rx_index<29)
            {

                rx_buffer[rx_index++]=rcv_data;

            }


        }


    }


}
```

- ctrl+s 保存到HelloWorld文件中 ~~文件名main.c~~ 
- 右键SourceGroup1-addFile  ~~不添加看不到，也没找到刷新的按钮，很奇怪~~ 
  
  ![](img/ly-20260902174010140.png)  
      
  添加刚才那个文件main.c
- 右键项目名-OptionForTarget
  ![](img/ly-20260902174518577.png)
	- output里面勾上createHex  
	  ![](img/ly-20260902174602796.png)  
	  
- 右键-build即可  
  ![](img/ly-20260902174137835.png)  
  
  ![](img/ly-20260902174728108.png)
  
   ~~那个STARTUP.A51我也不知道干嘛的~~ 
## 烧制程序

- 设置跟前面的测试一样，但是不需要接线了

![](img/ly-20260902174332297.png)  
- 打开文件，选择HelloWorld文件夹下的 .hex 文件  
- 程序下载
  然后就开始下载了，进度100%时结束  
  ![](img/ly-20260902174842672.png)

## 打开4-常用辅助开发工具-串口调试助手（丁丁）
- 端口我我选择和刚才烧制程序的串口号 ~~后续要烧制前得把这个串口号关了先~~ 
- 勾上时间戳、加回车换行
![](img/ly-20260902175209302.png)

## 测试流程

串口设置：

```shell
9600
8N1
发送新行 √
```

#### 1. 设置速度

发送：

```
SET_VEL 10
```

返回：

```
CMD:SET_VEL 10
OK SET_VEL
```
#### 2. 设置位置

发送：

```
SET_POS 100
```

返回：

```
CMD:SET_POS 100
OK SET_POS
```
#### 3. 查询状态

快速发送：

```
STATUS
```

可能：

```
TARGET:100 POS:20 VEL:10
```

继续：

```
TARGET:100 POS:60 VEL:10
```

最后：

```
TARGET:100 POS:100 VEL:0
```
#### 4. 查询位置

发送：

```
GET_POS
```

返回：

```
POS:100
```
#### 5. 查询速度

运动过程中：

```
GET_VEL
```

返回：

```
VEL:10
```

停止：

```
VEL:0
```

现在这个版本已经很接近课程里面的“电机驱动测试阶段”了。

## 随意测试

```

[18:04:50.095]发→◇STATUS
□
[18:04:50.138]收←◆CMD:STATUS
TARGET:0 POS:0 VEL:0

[18:04:51.406]发→◇STATUS
□
[18:04:51.450]收←◆CMD:STATUS
TARGET:0 POS:0 VEL:0

[18:05:01.567]发→◇GET_VEL
□
[18:05:01.600]收←◆CMD:GET_VEL
VEL:0

[18:05:13.375]发→◇SET_POS 100
□
[18:05:13.409]收←◆CMD:SET_POS 100
OK SET_POS

[18:05:17.327]发→◇STATUS
□
[18:05:17.371]收←◆CMD:STATUS
TARGET:100 POS:8 VEL:1

[18:05:18.143]发→◇STATUS
□
[18:05:18.174]收←◆CMD:STATUS
TARGET:100 POS:10 VEL:1

[18:05:23.144]发→◇GET_VEL
□
[18:05:23.176]收←◆CMD:GET_VEL
VEL:1

[18:05:24.175]发→◇GET_VEL
□
[18:05:24.208]收←◆CMD:GET_VEL
VEL:1

[18:05:33.895]发→◇STATUS
□
[18:05:33.928]收←◆CMD:STATUS
TARGET:100 POS:41 VEL:1

[18:05:46.969]发→◇GET_VEL
□
[18:05:47.002]收←◆CMD:GET_VEL
VEL:1

[18:05:54.904]发→◇STATUS
□
[18:05:54.935]收←◆CMD:STATUS
TARGET:100 POS:83 VEL:1

[18:11:08.515]发→◇fadf
□
[18:11:08.541]收←◆CMD:fadf
ERROR
```