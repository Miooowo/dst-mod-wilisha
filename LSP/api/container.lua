---@meta

---@class single_containerUI # 容器UI表
---@field widget container.widget
---@field type string # 容器类型,同类型容器只能打开一个
---| 'pack' # 背包
---| 'chest' # 箱子
---@field acceptsstacks nil|boolean # 是否接受堆叠物品,不填默认为true
---@field issidewidget boolean|nil # 开启,则会在融合背包布局时融合
---@field usespecificslotsforitems boolean|nil # 是否使用特定的槽位,不填默认为false <br> 这个填true的时候,`container:GetSpecificSlotForItem` 会在 `shift+左键` 时触发, 返回的数值就是物品应该去的槽位 <br> 可以通过勾上述方法或者写itemtestfn, 来实现对槽位的控制, 比如写翻页容器时会用到这一点
---@field itemtestfn nil|(fun(container:replica_container, item:ent, slot:integer|nil): boolean)

---@class container.widget
---@field animbank string
---@field animbuild string 
---@field slotpos Vector3[] 
---@field slotbg atlasANDimage[]|table
---@field pos Vector3
---@field dragtype_drag string|nil # 设置拖拽,和widget名字保持一致
---@field unique string|nil # 唯一标识,用于花活
---@field buttoninfo container.widget.buttoninfo|nil

---@class container.widget.buttoninfo
---@field text string # 按钮文字
---@field position Vector3


---@class (exact) atlasANDimage
---@field atlas string
---@field image string


---@alias data_containerUI table<string, single_containerUI> # 自定义堆叠表