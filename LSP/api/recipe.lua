---@meta

---@class data_recipe # 配方表
---@field recipe_name string # 配方ID <br>---------------<br> - 辉煌铁匠铺栏 <br>tech = TECH.LUNARFORGING_TWO,<br>config = {<br>    station_tag = "lunar_forge",<br>    nounlock = true,<br>},<br>---------------<br> - 远古栏<br>tech = TECH.ANCIENT_THREE,<br>config = {<br>    station_tag = "altar",<br>    nounlock = true,<br>},<br>filters = {'CRAFTING_STATION'},<br>---------------<br> - 月岛科技栏 <br>tech = TECH.CELESTIAL_THREE,<br>config = {<br>    station_tag = "moon_altar",<br>    nounlock = true,<br>},<br>---------------<br> - 暗影术基座栏<br>tech = TECH.SHADOWFORGING_TWO,<br>config = {<br>    station_tag = "shadow_forge",<br>    nounlock = true,<br>},<br>
---@field ingredients table # 材料表
---@field tech any # 所需科技
---@field isOriginalItem boolean|nil # 是官方物品(官方物品严禁写atlas和image路径,因为是自动获取的),不写则为自定义物品
---@field isAlwaysShown boolean|nil # 总是显示(即使游戏选项没有开启显示所有配方)
---@field isHidden boolean|nil # 隐藏配方(并不是不显示,而是直接不添加此配方,用于mod设置的)
---@field config recipe.config # 配置表
---@field filters recipe.filter[] # 过滤器

---@class recipe.config
---@field product string|nil # 产出prefab
---@field numtogive number|nil # 产出数量
---@field atlas string|nil
---@field image string|nil
---@field nounlock boolean|nil # 不需要解锁
---@field builder_tag string|nil # 只有有这个tag的建造者才能建造
---@field placer string|nil # 这里填的就是预制物的`MakePlacer`<br>如果填了, 在制作时就有绿色的预测, 不填则直接制作出来, 并且`deploy`时, 依旧有预测


---@class data_destruction_recipes # 分解配方表
---@field name PrefabID 
---@field ingredients table