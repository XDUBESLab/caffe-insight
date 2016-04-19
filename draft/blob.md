title: caffe::Blob
tags:
    - Caffe
    - BottomUp
--------------

{{ srcLink("caffe::Blob") }}是caffe中最基础的计算单元，可以用于存储最高4个维度数的数据。

<!--more-->

## 存储结构

{% raw %}
2134
{% endraw %}

`caffe::Blob` 是在 {{ srcLink("caffe::SyncedMemory") }} 的基础之上构建的结构。他本身不对所存储的数据格式做任何假设；
主要的数据操纵工作都是通过向BLAS暴露内存实现的。

## 空间复杂度

一个独立的Blob对象需要的空间开销是

{% raw %}
{% katex true %}
2(\prod_{dim{\in}shape}dim)sizeof(Dtype)
{% endkatex %}
{% endraw %}

