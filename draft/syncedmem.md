title: Caffe的内存同步
class: "caffe::SyncedMemory"
tags:
    - Caffe
    - BottomUp
--------------

caffe::SycnedMemnoy: RAM与GRAM之间的同步解决方案

<!--more-->

## 依赖关系

`caffe::SycnedMemnoy` 依赖标准库和CUDA Tool Kit，有Boost库的依赖，
但是所使用的`boost::shared_ptr`已随C++11标准纳入标准库，可取而代之。

`caffe::SycnedMemnoy` 仅仅被 `caffe::Blob` 和 `caffe::Filter` 依赖.

## 策略

`caffe::SycnedMemnoy` 是Caffe用来管理内存的基本组件。Caffe以这样的策略力图实现内存安全：

+ 多线程仅用于IO
+ 确保`caffe::SycnedMemnoy`实现可靠
+ 运行时使用的内存均直接或间接的由智能指针（`boost::shared_ptr`）管理

`caffe::SycnedMemnoy` 的整体策略是**尽可能推迟一切操作**，
真正的内存申请发生于第一次内存访问时而不是对象创建时；
内存同步发生于下一次内存访问前而不是每一次内存更改后。

但是这样的设计也使得在用于代码中直接使用`caffe::SycnedMemnoy`需要格外小心：
除非明确知晓你在做什么，否则永远不要缓存从`caffe::SycnedMemnoy`对象获得的内存地址。

# 实现

`caffe::SyncedMemory` 主要控制内存的申请和释放，不关心内存的具体用途。
在初始化时会同时在RAM和GRAM（如果启用GPU）中申请指定大小的内存。

`caffe::SyncedMemory` 有6个用于暴露/重置原始内存的方法:

+ `{set,mutable}_{cpu,gpu}_data()`
+ `{cpu,gpu}_data()`

`caffe::SyncedMemory` 有2个用于显式同步内存的方法：

+ `to_gpu()`
+ `to_cpu()`

此外，另有一个用于向GRAM异步推送数据的方法，
`caffe::SyncedMemory::async_gpu_push`，
存在于{{ fileLink("syncedmem.hpp") }}，
但是从未被引用。

`caffe::SyncedMemory` 会在上面罗列的6个暴露真实地址的方法返回之前调用适当的同步方法，
以保证每次访问时内存时，RAM和GRAM中的内容是同步的。

Caffe使用枚举类型`caffe::SyncedMemory::SyncedHead`状态每一个`caffe::SyncedMemory`
对象的内部状态

+ `UNINITIALIZED`: 对象构造完成之后的的初始状态
+ `HEAD_AT_CPU`: RAM持有最新副本
+ `HEAD_AT_GPU`: GRAM持有最新副本
+ `SYNCED`: 已同步, 该状态**只会出现在GPU模式下**

它们之间的状态迁移可以用这样一张图来描述：

{% raw %}
{% graph dot "状态转移图 - GPU Mode" %}
digraph {
    node   [shape = doublecircle, label = "U"] u;
    node   [shape = circle, label = "@CPU"] c;
    node   [shape = circle, label = "@GPU"] g;
    node   [shape = circle, label = "SYNC"] s;
    u -> c [ color = red ];
    g -> s [ color = red ];
    c -> c [ color = red ];
    s -> s [ color = red ];
    u -> g [ color = blue ];
    c -> s [ color = blue ];
    g -> g [ color = blue ];
    s -> s [ color = blue ];
}
{% endgraphviz %}
{% endraw %}

{% raw %}
{% graph dot "状态转移图 - CPU Mode" %}
digraph {
    node   [shape = doublecircle, label = "U"] u;
    node   [shape = circle, label = "@CPU"] c;
    u -> c [ color = red ];
    c -> c [ color = red ];
}
{% endgraphviz %}
{% endraw %}

