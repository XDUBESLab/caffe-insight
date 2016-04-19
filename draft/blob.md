title: caffe::Blob
tags:
    - Caffe
    - BottomUp
--------------

{{ srcLink("caffe::Blob") }}是caffe中最基础的可计算数据单元，可以用于存储最高4个维度数的数据。

<!--more-->

## 存储结构

`caffe::Blob`是在{{ srcLink("caffe::SyncedMemory") }}的基础之上构建的结构。
它本身不对所存储的数据格式做任何假设，主要的数据操纵工作都是通过向BLAS暴露内存实现的。

## 主要方法

`caffe::Blob`向外暴露的主要方法包括：

+ `Blob`: 构造函数，核心依赖于`Reshape`
+ `Reshape`: 根据给定的维度数，**执行内容无关的空间调整**，且仅仅在空间不足时重新分配，不缩减已分配的空间
+ `(mutable_|set)?(cpu|gpu)_(data|diff)`: 底层数据访问，返回值的类型是`Dtype*`或者`const Dtype*`，
+ `(asum|sumsq|scale)_(data|diff)`: 稍高级的抽象，通过BLAS对`data`或者`diff`进行数值操作
+ Update: 执行 {% raw %}{% katex %} data \leftarrow data - diff {% endkatex %}{% endraw %}以更新Blob
+ ToProto: 序列化到Protocol Buffers
+ FromProto: 从Protocol Buffers反序列化到`caffe::Blob`对象

## 序列化与反序列化

序列化与反序列化操作均通过Google Protocol Buffers实现。
`caffe::Blob::ToProto`方法会逐个元素地将整个对象写入文件。 `caffe::Blob::FromProto`方法会逐个元素地将元素从Protocol Buffers拷贝到`caffe::Blob`。
 
## 空间复杂度

由于每个Blob对象需要存储`data`，`diff`两部分数据，所以一个独立的Blob对象需要的空间开销是

{% raw %}
{% katex true %}
2(\prod_{dim{\in}shape}dim)sizeof(Dtype)
{% endkatex %}
{% endraw %}

