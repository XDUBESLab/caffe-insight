title: Layer和Solver中的工厂模式
tag: 
    - Caffe
    - BottomUp
--------------------------------

Caffe中的诸多Solver和Layer是通过工厂方法的模式来控制实例化的。

<!-- more -->

由于Layer和Solver的工厂方法的实现原理相同，这里以相对更典型也更复杂的`caffe::LayerRegistry`为例进行分析。

这种方法的核心思想是为每种Layer的具体实现的类注册一个名字，
由它记录名字到构造函数的映射关系；
在描述网络的`.proto`文件中为每个Layer指定`type`属性，
用以检索对应的构造函数。
<!-- 或者赋予独有的属性值（如是一个全局的`std::map<std::string, Constructor>`对象， -->

## 代码实现

开发团队在{{ fileLink("layer_factory.hpp") }}中引入了一些类和宏来实现这样的工厂方法。
这个方法的核心思想是在一个`std::map`中记录名字到能构造对应的类的函数的对应关系，
这里姑且称之为『注册表』。

实现这样的工厂方法机制主要依靠了语言和工具链的两项特性：
+ C++中static storage duration的对象在程序加载后、main执行前构建并初始化。
+ 预处理器（宏）的符号拼接(Concatenation)和字符串化(Stringification)

### `Creator`

Creator是这样一个类型别名：

```C++
typedef shared_ptr<Layer<Dtype>> (*Creator)(const LayerParameter &)
```

也就是指向**构造并返回一个Layer对象的共享指针的函数**的指针。

### `LayerRegistry`

Layer的注册表, 维护一个`std::map<std::string, caffe::Creator>`以记录名字和Creator的对应关系。

```C++
template<typename Dtype>
class LayerRegistry { // 所有成员都被static修饰，这个class等同于一个namespace
 public:
  typedef shared_ptr<Layer<Dtype>> (*Creator)(const LayerParameter &);
  typedef std::map<string, Creator> CreatorRegistry;

  // static storage duration 保证这个map在程序开始运行时、main执行前被构造，并且仅存在一个实例
  static CreatorRegistry &Registry() {
    static CreatorRegistry *g_registry_ = new CreatorRegistry();
    return *g_registry_;
  }

  static void AddCreator(const string &type, Creator creator) {
    CreatorRegistry &registry = Registry();
    CHECK_EQ(registry.count(type), 0) << "Layer type " << type << " already registered.";
    registry[type] = creator;
  }
}

```

### `LayerRegisterer`

利用自己的构造函数在`main()`运行前向注册表注册类。

```C++
template<typename Dtype>
class LayerRegisterer {
 public:
  LayerRegisterer(const string &type, shared_ptr<Layer<Dtype> > (*creator)(const LayerParameter &)) {
    // 这里的creator只是特化之后函数，如Creator_PoolingLayer<double>
    LayerRegistry<Dtype>::AddCreator(type, creator);
  }
};
```
### 宏`REGISTER_LAYER_CREATOR`

分别以`float`和`double`创建两个`static`实例，最终实现动态注册类。

```C++
#define REGISTER_LAYER_CREATOR(type, creator)                                  \
  static LayerRegisterer<float> g_creator_f_##type(#type, creator<float>);     \
  static LayerRegisterer<double> g_creator_d_##type(#type, creator<double>)    \
```

### 宏`REGISTER_LAYER_CLASS`

这个宏用来为每个类生成Creator函数。

```C++
#define REGISTER_LAYER_CLASS(type)                                             \
  template <typename Dtype>                                                    \
  shared_ptr<Layer<Dtype> > Creator_##type##Layer(const LayerParameter& param) \
  {                                                                            \
    return shared_ptr<Layer<Dtype> >(new type##Layer<Dtype>(param));           \
  }                                                                            \
  REGISTER_LAYER_CREATOR(type, Creator_##type##Layer)
```

在完全展开之后得到类似这样的函数模板（以PoolingLayer为例）：

```C++
template<typename Dtype>
std::shared_ptr<PoolingLayer<Dtype>> Creator_PoolingLayer(const LayerParameter &param) {
  return std::shared_ptr<PoolingLayer<Dtype>>(new PoolingLayer<Dtype>(param));
}
```

然后使用`REGISTER_LAYER_CREATOR`宏来特化并注册Creator函数，完成工厂方法的所有准备工作。

### 注册

以`caffe::FilterLayer`为例，这种工厂方法下的直接注册方法是

```C++
REGISTER_LAYER_CLASS(Filter)
```

另外一种间接使用这个工厂方法的例子集中在{{ fileLink("layer_factory.cpp") }}中。

这里200+行代码的目的只有一个：为有特殊需求的Layer提供不同于`REGISTER_LAYER_CLASS`所创建的Creator。
具体分两类：
+ 为支持选择`Engine`的，也就是可以选择使用cuDNN实现或者Caffe实现的层，提供支持
+ 为{{ srcLink("caffe::PythonLayer") }}准备Python运行时环境

Stringification会产生`"Filter"`以便用于`.proto`，Concatenation会连缀`Filter`和`Layer`构造出类名`FilterLayer`。

确实有些不那么直白。
这里如果综合利用`std::function`（或者，前C++11时代的`boost::function`）和编译器提供的`__attribute__((constructor))`功能，
几乎可以肯定最终能得到易懂的多的工厂方法实现。
然而，相比于Caffe的主要任务，这些细枝末节，又何必费心太多呢:P

## 使用

以Model Zoo中的LeNet的`pool1`层为例

```yaml
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

## Solver

为Solver设计的工厂方法和为Layer设计的工厂方法思路完全一致，
而且没有特例，所以读起来更为简单。


