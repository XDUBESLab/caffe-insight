title: Layer和Solver中的工厂模式
tag: 
    - Caffe
    - BottomUp
--------------------------------

Caffe中的诸多Solver和Layer是通过工厂方法的模式来控制实例化的。

<!-- more -->

> 由于两者的实现原理相同，这里以相对更典型的`caffe::LayerRegistry`为例进行分析。

这种方法的核心思想是为每种Layer的具体实现的类注册一个名字，
由它记录名字到构造函数的映射关系；
在描述网络的`.proto`文件中为每个Layer指定`type`属性，
用以检索对应的构造函数。
<!-- 或者赋予独有的属性值（如是一个全局的`std::map<std::string, Constructor>`对象， -->

## 代码实现

开发团队在{{ fileLink("layer_factory.hpp") }}中引入了三个概念

+ `Creator`: Layer的构造函数的类型别名
+ `LayerRegistry`: Layer的注册表, 维护一个`std::map`以记录名字和Creator的对应关系。
+ `LayerRegisterer`: Layer的注册器

实现这种注册机制的核心是一组类和一组宏：
+ {{ srcLink("caffe::LayerRegistry") }}
+ {{ srcLink("caffe::LayerRegisterer") }}
+ `REGISTER_LAYER_CREATOR`: 用于为每个类创建
+ `REGISTER_LAYER_CLASS`

```
typedef shared_ptr<Layer<Dtype>> (*Creator)(const LayerParameter &);
```

{{ srcLink("caffe::LayerRegistry") }}实现了这中注册机制。
这种机制的一个缺陷（由于C++缺乏简单易用的自省机制）是，它要求所有的由于`caffe::Layer`

## 运行时行为分析

Caffe开发团队选择的在`main()`函数之前执行注册命令的方案是利用`static`对象的构造函数，如

```C++
template<typename Dtype>
class LayerRegisterer {
 public:
  LayerRegisterer(const string &type,
                  shared_ptr<Layer<Dtype> > (*creator)(const LayerParameter &)) {
    LayerRegistry<Dtype>::AddCreator(type, creator);
  }
};
```

在

## 使用

以Model Zoo中的LeNet的`pool1`为例

```
layer {
  name: "pool1"
  type: "Pooling"
  bottom: "conv1"
  top: "pool1"
  pooling_param {
    pool: MAX
    kernel_size: 2
    stride: 2
  }
}
```

在每一层中显式指定Layer的类型即可。

## 特例

实现最简单的`std::PoolingLayer`是这种机制的一个特例。
这个特例在方便用户定义Pooling层的同时也说明了Caffe的易拓展性。

在{{ srcLink("caffe::UpgradeV0LayerParameter") }}函数
