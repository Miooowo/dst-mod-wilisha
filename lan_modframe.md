# 你设置的 `modid` 为 `role_wilisha`

***

# dst-lan MOD 框架介绍

## 1. 使用框架生成指令

0. 确保你在工作区中,并且**激活一个编辑器**(理解成打开一个txt文件就行)

1. `ctrl` + `shift` + `P` -> `dst-aln:Gen ModFrame`

2. 填写`modid`,注意这是`mod`唯一识别`id`,将用于各种文件的前缀,等等,命名建议: 纯`小写`英文,用`_`代替空格. 例如,我要创建一个mod叫`太刀武器mod`,那么我可以填写`wp_tachi_yyds`

3. 生成后的目录中,有一个`dst_mod-role_wilisha.code-workspace` vscode工作区文件,双击该文件,即可打开当前mod的工作区.(建议先创建一个git仓库来做版本控制)

## 2. 框架介绍

1. 简单看一下结构:

```lua
├── anim 动画包
├── exported 动画工程文件
├── fx 特效材质
├── images 图片
│   ├── inventoryimages 库存物品图片
│   │   ├── prefab_id.tex
│   │   └── prefab_id.xml
├── DETAILS 详细(给你自己看的)
├── LSP 为lls提供智能识别支持
│   ├── api 预设api
│   └── ...
├── scripts 脚本
│   ├── components 组件
│   ├── core_role_wilisha
│   │   ├── api 预设api
│   │   │   └── ...
│   │   ├── callers 调用器
│   │   │   └── ...
│   │   ├── data 数据库
│   │   │   ├── ...
│   │   │   └── tuning.lua MOD参数全局表
│   │   ├── hooks 钩子
│   │   ├── languages 本地化
│   │   │   ├── cn.lua 中文
│   │   │   └── en.lua 英文
│   │   ├── ui
│   │   ├── utils 堆放自己的一些工具库(有待添加)
│   │   ├── widgets 构造UI的各种类
│   ├── prefabs 预制物
│   │   ├── role_wilisha_module_dishes.lua 料理预制物模块
│   │   └── role_wilisha_module_particle.lua 粒子预制物模块
├── sound 音效
├── dst_mod-role_wilisha.code-workspace 工作区文件
├── modmain.lua
└── modinfo.lua mod介绍配置
```

2. 除了饥荒本身的mod结构,我们来看新加入的架构

- `core_role_wilisha` 这是模板的核心模块, `callers 调用器` 会读取 `data 数据表` 中的内容, 并用 `api` 中的预设方法进行调用, 我们再安装 lua下载量第一的vscode插件后, `LSP` 中的注释会为 `core_role_wilisha/api` 的预设api提供智能识别支持

- 至此,我们大致了解了 `core_role_wilisha/api`,`core_role_wilisha/callers`,`core_role_wilisha/data`,`LSP/api` 这四个文件的关系了, 那么我们只需要在`data`中去填写数据就可以了,最后在`modmain`中将对应的`callers`的注释的双横线去掉即可. 在填写`data`表时,我建议将光标放到,`data`顶部的`type`后面的类型上,然后按`Alt + F12`,可以 `局内速览定义`, 帮助你填写数据表.

- `languages` 文件夹中,有预设好的两个文件,去做你的本地化语言

- 至于 `hooks` 文件夹, 当你为自己的物品添加功能时,需要进行大量的hook,或者为自己的mod写了一些功能,但是分类时找不到归宿,那么可以以你的功能或者prefab为名,创建一个文件,然后把对应的功能写在里面,方便管理,最后别忘了再`modmain`中使用`modimport`导入

- `utils` 文件夹中,可以放一些自己的工具库

## 3. 预设API的详细介绍(没空写)

没啥好讲的,直接看文档吧,data里面也写了一些模板了,参考着写吧.