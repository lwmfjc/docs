---
title: 31-43 maven基础_动力节点
description: 'maven基础_动力节点'
categories:
  - 学习
tags:
  - maven_基础动力节点
date: 2022-07-09 18:24:30
updated: 2022-07-13 22:24:30
---

## idea中设置maven

- 和idea集成maven
  ![ly-20241212142146614](img/ly-20241212142146614.png)
- 

## 创建普通的j2se项目

- 使用idea创建空白项目
  ![ly-20241212142146810](img/ly-20241212142146810.png)

- 新建一个module
  ![ly-20241212142146873](img/ly-20241212142146873.png)

- 使用模板创建普通java项目
  ![ly-20241212142146930](img/ly-20241212142146930.png)

- 输入gav
  ![ly-20241212142146987](img/ly-20241212142146987.png)

- 设置maven信息
  ![ly-20241212142147048](img/ly-20241212142147048.png)

- 标准的maven工程
  ![ly-20241212142147103](img/ly-20241212142147103.png)
  
  - 与创建网站有关，删掉即可
    
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    
    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
      <modelVersion>4.0.0</modelVersion>
    
      <groupId>com.bjpowernode</groupId>
      <artifactId>ch01-maven-j2se</artifactId>
      <version>1.0</version>
    
      <!--设置网站，注释掉即可-->
    <!--  <name>ch01-maven-j2se</name>
      <!– FIXME change it to the project's website –>
      <url>http://www.example.com</url>-->
    
      <properties> <!--maven常用设置-->
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
      </properties>
    
      <dependencies>
        <dependency><!--单元测试-->
          <groupId>junit</groupId>
          <artifactId>junit</artifactId>
          <version>4.11</version>
          <scope>test</scope>
        </dependency>
      </dependencies>
    
      <build>
        <!--插件版本的配置，无特殊指定则删除-->
        <pluginManagement><!-- lock down plugins versions to avoid using Maven defaults (may be moved to parent pom) -->
          <plugins>
            <!-- clean lifecycle, see https://maven.apache.org/ref/current/maven-core/lifecycles.html#clean_Lifecycle -->
            <plugin>
              <artifactId>maven-clean-plugin</artifactId>
              <version>3.1.0</version>
            </plugin>
            <!-- default lifecycle, jar packaging: see https://maven.apache.org/ref/current/maven-core/default-bindings.html#Plugin_bindings_for_jar_packaging -->
            <plugin>
              <artifactId>maven-resources-plugin</artifactId>
              <version>3.0.2</version>
            </plugin>
            <plugin>
              <artifactId>maven-compiler-plugin</artifactId>
              <version>3.8.0</version>
            </plugin>
            <plugin>
              <artifactId>maven-surefire-plugin</artifactId>
              <version>2.22.1</version>
            </plugin>
            <plugin>
              <artifactId>maven-jar-plugin</artifactId>
              <version>3.0.2</version>
            </plugin>
            <plugin>
              <artifactId>maven-install-plugin</artifactId>
              <version>2.5.2</version>
            </plugin>
            <plugin>
              <artifactId>maven-deploy-plugin</artifactId>
              <version>2.8.2</version>
            </plugin>
            <!-- site lifecycle, see https://maven.apache.org/ref/current/maven-core/lifecycles.html#site_Lifecycle -->
            <plugin>
              <artifactId>maven-site-plugin</artifactId>
              <version>3.7.1</version>
            </plugin>
            <plugin>
              <artifactId>maven-project-info-reports-plugin</artifactId>
              <version>3.0.0</version>
            </plugin>
          </plugins>
        </pluginManagement>
      </build>
    </project>
    ```

## 单元测试

- 关于idea颜色
  ![ly-20241212142147158](img/ly-20241212142147158.png)

- 编写java程序
  
  ```java
  package com.bjpowernode;
  
  public class HelloMaven {
      public int addNumber(int n1,int n2){
          return n1+n2;
      }
  
      public static void main(String[] args) {
          HelloMaven helloMaven=new HelloMaven();
          int res=helloMaven.addNumber(10,20);
          System.out.println("res = "+res);
      }
  }
  ```

- ![ly-20241212142147213](img/ly-20241212142147213.png)

- 测试使用
  ![ly-20241212142147268](img/ly-20241212142147268.png)

## idea中maven工具窗口

- Maven生成的目录
  ![ly-20241212142147325](img/ly-20241212142147325.png)

- 使用```mvn clean```进行清理
  
  ```shell
  λ mvn clean
  [INFO] Scanning for projects...
  [INFO]
  [INFO] ------------------< com.bjpowernode:ch01-maven-j2se >-------------------
  [INFO] Building ch01-maven-j2se 1.0
  [INFO] --------------------------------[ jar ]---------------------------------
  [INFO]
  [INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ ch01-maven-j2se ---
  [INFO] Deleting D:\Users\ly\Documents\git\mavenwork\04-project\ch01-maven-j2se\target [INFO] ------------------------------------------------------------------------
  [INFO] BUILD SUCCESS
  [INFO] ------------------------------------------------------------------------
  [INFO] Total time:  0.438 s
  [INFO] Finished at: 2022-07-13T23:39:03+08:00
  [INFO] ------------------------------------------------------------------------
  ```

- 窗口
  ![ly-20241212142147383](img/ly-20241212142147383.png)

- ![ly-20241212142147440](img/ly-20241212142147440.png)

- 单元测试
  ![ly-20241212142147495](img/ly-20241212142147495.png)

- 打包
  ![ly-20241212142147554](img/ly-20241212142147554.png)

- install安装
  ![ly-20241212142147610](img/ly-20241212142147610.png)
  ![ly-20241212142147664](img/ly-20241212142147664.png)

- 其他
  ![ly-20241212142147719](img/ly-20241212142147719.png)

- 重新更新依赖项
  ![ly-20241212142147774](img/ly-20241212142147774.png)

## 创建web项目加入servlet依赖

- ![ly-20241212142147840](img/ly-20241212142147840.png)

- 结构
  ![ly-20241212142147918](img/ly-20241212142147918.png)

- 创建java文件夹和资源文件夹
  ![ly-20241212142147984](img/ly-20241212142147984.png)

- pom文件

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  
  <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
  
    <groupId>com.bjpowernode</groupId>
    <artifactId>ch02-maven-web</artifactId>
    <version>1.0</version>
    <packaging>war</packaging>
  
    <name>ch02-maven-web Maven Webapp</name>
    <!-- FIXME change it to the project's website -->
    <url>http://www.example.com</url>
  
    <properties>
      <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
      <maven.compiler.source>1.8</maven.compiler.source>
      <maven.compiler.target>1.8</maven.compiler.target>
    </properties>
  
    <dependencies>
      <!--servlet依赖-->
      <!-- https://mvnrepository.com/artifact/javax.servlet/javax.servlet-api -->
      <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <version>4.0.1</version>
        <scope>provided</scope>
      </dependency>
  
      <!--jsp依赖-->
      <!-- https://mvnrepository.com/artifact/javax.servlet.jsp/javax.servlet.jsp-api -->
      <dependency>
        <groupId>javax.servlet.jsp</groupId>
        <artifactId>javax.servlet.jsp-api</artifactId>
        <version>2.3.3</version>
        <scope>provided</scope>
      </dependency>
  
  
      <!--junit-->
      <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.11</version>
        <scope>test</scope>
      </dependency>
    </dependencies>
  
  </project>
  
  ```

  - 和上面进行对比

## 创建servlet

![ly-20241212142148038](img/ly-20241212142148038.png)

- 创建完之后

  - 代码

    ```java
    package com.bjpowernode.controller;
    
    import javax.servlet.*;
    import javax.servlet.http.*;
    import java.io.IOException;
    
    public class HelloServlet extends HttpServlet {
        @Override
        protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    
        }
    
        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    
        }
    }
    
    ```

  - web.xml 

    ```
    <!DOCTYPE web-app PUBLIC
     "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
     "http://java.sun.com/dtd/web-app_2_3.dtd" >
    
    <web-app>
      <display-name>Archetype Created Web Application</display-name>
      <servlet>
        <servlet-name>HelloServlet</servlet-name>
        <servlet-class>com.bjpowernode.controller.HelloServlet</servlet-class>
      </servlet>
    </web-app>
    
    ```

    - 添加mapping

      ```
      <!DOCTYPE web-app PUBLIC
       "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
       "http://java.sun.com/dtd/web-app_2_3.dtd" >
      
      <web-app>
        <display-name>Archetype Created Web Application</display-name>
        <servlet>
          <servlet-name>HelloServlet</servlet-name>
          <servlet-class>com.bjpowernode.controller.HelloServlet</servlet-class>
        </servlet>
        <servlet-mapping>
          <servlet-name>HelloServlet</servlet-name>
          <url-pattern>/hello</url-pattern>
        </servlet-mapping>
      </web-app>
      
      ```

- 添加jsp

  ``` jsp
  <%--
    Created by IntelliJ IDEA.
    User: ly
    Date: 2022/7/16
    Time: 18:10
    To change this template use File | Settings | File Templates.
  --%>
  <%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <html>
  <head>
      <title>index</title>
  </head>
  <body>
  <a href="hello" >访问</a>
  </body>
  </html>
  
  ```

- 设置转发

  ```
  package com.bjpowernode.controller;
  
  import javax.servlet.*;
  import javax.servlet.http.*;
  import java.io.IOException;
  
  public class HelloServlet extends HttpServlet {
      @Override
      protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
          System.out.println("收到请求了");
          //转发到show
          request.getRequestDispatcher("/show.jsp")
                  .forward(request,response);
      }
  
      @Override
      protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
  
      }
  }
  
  ```

- 设置tomcat并发布

  idea出现not found for the web module.
  ![ly-20241212142148090](img/ly-20241212142148090.png)

  - ![ly-20241212142148145](img/ly-20241212142148145.png)

![ly-20241212142148201](img/ly-20241212142148201.png)

## 复习核心的概念

- 约定的目录结构
  ![ly-20241212142148255](img/ly-20241212142148255.png)
- pom 项目对象模型，groupId,artifactId,version gav
- 仓库
  - 本地仓库  ...../.m2/repository
  - 远程仓库
- 生命周期，clean，compile，test-compile，test，package，install
- maven和idea集成
  - 设置maven安装目录和配置文件
  - 设置Runner，创建maven时速度快
    ![ly-20241212142148309](img/ly-20241212142148309.png)
  - 使用模板创建 se和web
    ![ly-20241212142148365](img/ly-20241212142148365.png)

## 导入模块到idea

- 导入02这个项目
  ![ly-20241212142148422](img/ly-20241212142148422.png)
- ![ly-20241212142148476](img/ly-20241212142148476.png)
- ![ly-20241212142148531](img/ly-20241212142148531.png)
- 结果
  ![ly-20241212142148587](img/ly-20241212142148587.png)
- 当磁盘中文件夹名字和项目名不一样时
  ![ly-20241212142148640](img/ly-20241212142148640.png)
- 如果导入后颜色不对，则需要右键 mark as
  ![ly-20241212142148694](img/ly-20241212142148694.png)

## scope依赖范围

- scope标签

- 依赖范围：scope标签，这个依赖在项目构建的哪个阶段起作用

  - 值：compile，默认，参与构建项目的所有阶段；
    		test：测试，在测试阶段使用，比如执行mvn test 会使用junit
      		provided：提供者，项目在部署到服务器时，不需要提供这个依赖的jar，而是由服务器提供这个以来的jar包

- 打包时只有mysql
  ![ly-20241212142148747](img/ly-20241212142148747.png)

  ![ly-20241212142148804](img/ly-20241212142148804.png)

- war文件
  ![ly-20241212142148857](img/ly-20241212142148857.png)

  - 给服务器，即放到tomcat的webapps中
    ![ly-20241212142148907](img/ly-20241212142148907.png)
  - 启动tomcat之后，会自动解压
    ![ly-20241212142148963](img/ly-20241212142148963.png)

- 访问
  ![ly-20241212142149017](img/ly-20241212142149017.png)

## 自定义变量

- properties标签，常用设置
  ![ly-20241212142149071](img/ly-20241212142149071.png)
  - test报告
    ![ly-20241212142149124](img/ly-20241212142149124.png)
- ![ly-20241212142149177](img/ly-20241212142149177.png)
  这种需要将文件夹删除，然后reimport
- 全局变量，比如依赖版本号
  - 重复的问题
    ![ly-20241212142149268](img/ly-20241212142149268.png)
  - 在properties里面定义即可
    ![ly-20241212142149338](img/ly-20241212142149338.png)
  - 使用全局变量 ${变量名}
    ![ly-20241212142149390](img/ly-20241212142149390.png)

## 处理文件的默认规则

- 使用资源插件
- 例子
  - 放置三个文件
  - ![ly-20241212142149444](img/ly-20241212142149444.png)
  - 进行四个操作，会生成资源文件（src/resources）拷贝到target/classes目录下
    ![ly-20241212142149497](img/ly-20241212142149497.png)
- 如果在java下的包中放资源文件
  ![ly-20241212142149552](img/ly-20241212142149552.png)
  - 没有拷贝
    ![ly-20241212142149602](img/ly-20241212142149602.png)
  - 即maven只处理src/main/java目录下的.java文件，把这些编译成class，拷贝到target/classes目录中，不处理其他文件

## 资源插件

build下

```xml
    <build>
        <!--资源插件-->
        <resources>
            <resource>
                <!--所在的目录-->
                <directory>src/main/java</directory>
                <!--包括properties及xml后缀文件-->
                <includes>
                    <include>**/*.properties</include>
                    <include>**/*.xml</include>
                    <include>**/*.txt</include>
                    <include>**/*</include>
                </includes>
                <excludes>
                    <exclude>**/*.java</exclude>
                </excludes>
                <!--不使用过滤器，*.xml已经起到过滤作用了-->
                <filtering>false</filtering>
            </resource>
        </resources>
        </resources>
    </build>
```

结果
![ly-20241212142149654](img/ly-20241212142149654.png)