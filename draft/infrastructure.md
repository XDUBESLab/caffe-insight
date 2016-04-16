title: Caffe的基础设施
tags:
    - Caffe
    - BottomUp
--------------

Caffe的基础设施：构建工具，依赖与编码风格

<!--more-->

## 构建工具

### 传统方案

官方维护了Make，社区维护着CMake，但都没有给出完整的依赖配置方案。
构建环境需另行参考[Caffe | Installation][caffe-installation]

### 使用Docker

在社区支持下，可以很方便的以Docker搭建Caffe环境。

+ CPU版本: `docker pull kaixhin/caffe`
+ GPU版本: `docker pull kaixhin/cuda-caffe`

更多镜像请往[Docker Hub][docker-hub-caffe]

## 线性代数

Caffe默认支持三种线性代数库，BLAS，OpenBlas 和 Intel MKL，
可以通过`Makefile。config`进行配置。

对于买不起Intel MKL的团队，Caffe会设法通过BLAS模拟Caffe需要的 MKL additions，
见于 {{ srcLink("mkl_alternate.hpp") }}。

## CUDA

或许是广泛商用之后的向前兼容问题使然，Caffe本身并及时跟进到CUDA 7.x，
因此Caffe对CUDA的使用就只停留在了cuDNN上，并没有使用性能更好的cuBLAS和cuSOLVER。
运行于GPU上的代码多是Caffe项目组手工编写的，如{{ srcLink("math_functions.cpp") }}。

## cuDNN

TODO

## 编码风格

Caffe大量的混用了模板和宏，但整体的原则是：

+ 所有类模板只有一个类型模板参数
+ 类模板之所以存在，只是为了同时支持

### 工具函数

Caffe在BLAS/OpenBlas/MKL Blas的基础上做了一个微型的兼容层，
其主要目的是

+ 以函数模板的形式统一不同精度的浮点数的函数，如`vdSub`和`vsSub`被统一成了`caffe::caffe_sub<Dtype>`
+ 模拟MKL的专有函数

### 类

类模板及其成员函数模板定义于`.hpp`，成员函数模板实现于`.cpp`。
`.cpp`尾部给出该类模板的所有可用的特化版本。没有显式方法阻止用户以不被支持的类型模板参数特化一个类模板，
但这样做通常会导致在递归地特化该模板类所引用的函数模板时因找不到对应的特化版本而失败。

[caffe-installation]: http://caffe.berkeleyvision.org/installation.html
[docker-hub-caffe]: https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=caffe&starCount=0
