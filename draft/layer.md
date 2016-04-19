title: caffe::Layer 
tags:
    - Caffe
    - BottomUp
--------------

Caffe中最基本的计算单元的统一抽象。

<!-- more -->

`caffe::Layer`的派生类的主要作用的是
+ 向`caffe::Net`提供抽象的计算方法
+ 在作为参数传入的`bottom`和`top`上执行具体计算

## 构造与初始化

`caffe::Layer`仅仅提供了一个不可重载的构造函数，
它接受一个`caffe::LayerParameter`实例的引用，来从proto文件构建一个新的实例。

`caffe::Layer`使用了典型的两段初始化策略：


`caffe::Layer`主要向`caffe::Net`暴露了三个方法用以统一所有Layers的对外接口：

+ `ToProto`: 序列化
+ `SetUp`: 初始化完整的逻辑
+ `Forward`&`Backword`: 计算的抽象方法 
+ `Reshape`: 调整top的维度

> Layers must implement a Forward function, in which they take their input
> (bottom) Blobs (if any) and compute their output Blobs (if any).
> They may also implement a Backward function, in which they compute the error
> gradients with respect to their input Blobs, given the error gradients with
> their output Blobs.

每个继承`caffe::Layer`以实现特定Layer的类最终必须实现以下函数：

+ `Forward_(cpu|gpu)`: 执行计算
+ `Backword_(cpu|gpu)`: 执行反向传播
+ `LayerSetUp`: 执行当前Layer的初始化操作
+ `Reshape`: 调整top的维度

