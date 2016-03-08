# Caffe代码分析

这是使用在[Wiki][wiki]中的文稿.
`wiki/`中是利用`Swig`模板引擎编写的, 未渲染的Markdown手稿.

`Swig`是Hexo支持的众多模板引擎之一, 选择它以方便未来时机成熟时生成`gh-pages`.

`Swig`是语言无关的, 但`lib/`中的辅助函数主要针对Markdown设计;
若要使用其他受Github Wiki支持的标记语言, 请小心使用这些副主函数.


## 构建 
```shell
npm install
grunt render
```

## 自动同步Wiki
这个仓库被设计成为可以与Wiki双向同步. 要执行双向同步, 执行

```shell
grunt sync
```

然后处理冲突, 填写两个仓库中各自的commit message后提交即可.


## Contribute

### 通过直接编辑Wiki
直接在Wiki中更新的页面会被自动的反向更新回 

### 通过贡献向本仓库
直接更新`wiki/`中的文件也可以, 其中`_Footer.md`是页脚, `_Sidebar.md`是右侧边栏.

__无论使用何种方式更新, 务请注意写出精确的commit message以免混淆.__


[wiki]: https://github.com/XDUBESLab/caffe-insight/wiki
