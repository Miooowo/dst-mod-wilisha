---@diagnostic disable: lowercase-global, undefined-global, trailing-space, undefined-doc-name

GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

---@type string
local modid = 'role_wilisha' -- 定义唯一modid

---@type LAN_TOOL_COORDS
COORDS_role_wilisha = require('core_'..modid..'/utils/coords')
---@type LAN_TOOL_SUGARS
SUGAR_role_wilisha = require('core_'..modid..'/utils/sugar')

rawset(GLOBAL,'COORDS_role_wilisha',COORDS_role_wilisha)
rawset(GLOBAL,'SUGAR_role_wilisha',SUGAR_role_wilisha)

PrefabFiles = {
	-- 'role_wilisha_module_buffs',
	-- 'role_wilisha_module_dishes',
	-- 'role_wilisha_module_particle',
	'wilisha_lunarplanttentacle',
	'fx_wilisha_float_top',
	-- 'lunarplant_placer',
	'lunarthrall_seeds',
}

-- 添加wilisha_harvest_tracker组件
AddComponentPostInit("wilisha_harvest_tracker", function(self)
    -- 组件已经通过wilisha_harvest_tracker.lua定义
end)
local assets = {}
---@type asset[]
Assets = {
	Asset('ANIM', 'anim/wood_splinter_brightshade.zip'),
}
-- 导入mod配置
for _,v in ipairs({
	'_lang',

}) do TUNING[string.upper('CONFIG_'..modid..v)] = GetModConfigData(modid..v) end

-- 导入常量表
modimport('scripts/core_'..modid..'/data/tuning.lua')

-- 导入工具
modimport('scripts/core_'..modid..'/utils/_register.lua')

-- 导入功能API
modimport('scripts/core_'..modid..'/api/_register.lua')

-- 导入语言文件
modimport('scripts/core_'..modid..'/languages/'..TUNING[string.upper('CONFIG_'..modid..'_LANG')]..'.lua')

-- 导入人物
modimport('scripts/data_avatar/data_avatar_wilisha.lua')

-- 导入sg
modimport('scripts/stategraphs/form_husk.lua')

-- 导入调用器
-- modimport('scripts/core_'..modid..'/callers/caller_attackperiod.lua')
-- modimport('scripts/core_'..modid..'/callers/caller_badge.lua')
-- modimport('scripts/core_'..modid..'/callers/caller_ca.lua')
-- modimport('scripts/core_'..modid..'/callers/caller_changeactionsg.lua')
-- modimport('scripts/core_'..modid..'/callers/caller_container.lua')
-- modimport('scripts/core_'..modid..'/callers/caller_dish.lua')
-- modimport('scripts/core_'..modid..'/callers/caller_keyhandler.lua')
-- modimport('scripts/core_'..modid..'/callers/caller_onlyusedby.lua')
modimport('scripts/core_'..modid..'/callers/caller_recipes.lua')
-- modimport('scripts/core_'..modid..'/callers/caller_stack.lua')


-- 导入零散功能模块 (自用 可以无视) (如果你要启用某个模块, 先看该manager文件里面的置顶注释)
-- modimport('scripts/core_role_wilisha/managers/atk_speed_from_alt.lua') -- 功能(无需修改): alt写的修改攻速模块 修正版
-- modimport('scripts/core_role_wilisha/managers/bugfix_aoetargeting.lua') -- 当你使用官方组件来写技能时,貌似会因为没有正确移除 reticule 组件,导致玩家的轮盘施法放不出来,本文件就是用来修复这个bug的
-- modimport('scripts/core_role_wilisha/managers/bugfix_souljump.lua') -- 当你使用官方组件来写武器技能时, 会导致和 小恶魔的灵魂跳跃 冲突, 具体我忘了, 总之这个文件就是用来修复这个bug的
-- modimport('scripts/core_role_wilisha/managers/build_data_transfer.lua') -- 功能(需要填写): 制作物品过程涉及数据传输 (只能传输1件原材料的数据)
-- modimport('scripts/core_role_wilisha/managers/cantequip_whennodurability.lua') -- 功能(无需修改): 本文件用来管理,装备耐久用尽时的逻辑
-- modimport('scripts/core_role_wilisha/managers/cd_in_itemtile.lua') -- 功能(无需修改): 在物品栏以数字形式显示的cd
-- modimport('scripts/core_role_wilisha/managers/dmg_sys.lua') -- 管理: 用这个文件管理伤害处理吧
-- modimport('scripts/core_role_wilisha/managers/event_hook.lua') -- 功能(需要填写): 勾 event
-- modimport('scripts/core_role_wilisha/managers/hovertext.lua') -- 功能(无需修改): 添加悬浮提示
-- modimport('scripts/core_role_wilisha/managers/invincible.lua') -- 功能(无需修改): 设置无敌的
modimport('scripts/core_role_wilisha/managers/is_mod_enabled.lua') -- 功能(无需修改): 判断某个mod有没有开启 的前置
-- modimport('scripts/core_role_wilisha/managers/last_atk_weapon.lua') -- 功能(无需修改): 获取攻击者上次使用的武器
modimport('scripts/core_role_wilisha/managers/misc.lua') -- 杂项
-- modimport('scripts/core_role_wilisha/managers/participate_kill.lua') -- 功能(无需修改): 联合击杀(参与击杀), 判断生物死亡时, 某个玩家有没有贡献伤害(参与战斗)
-- modimport('scripts/core_role_wilisha/managers/quick_announce.lua') -- 功能(需要填写): alt + 左键点击库存物品宣告
-- modimport('scripts/core_role_wilisha/managers/sort_recipes.lua') -- 功能(需要填写): 给配方排序
-- modimport('scripts/core_role_wilisha/managers/trade.lua') -- 功能(无需修改,但需要填写其他地方): 添加通用的交易升级功能


-- 导入UI

-- 注册客机组件

-- 导入钩子 It's my勾
---@type string[]
local files_hook = {
	'hook_sword_lunarplant',
	'wilisha_haunt',
	'hook_armor_lunarplant',
	'hook_cps_lunarplant_tentacle_weapon',
	'hook_gestalt',
	-- 'hook_pocketwatch_weapon',
	-- 'hook_lunarthrall_plant',
	-- 'hook_lunarplant_husk',
}
for _,v in ipairs(files_hook) do
	modimport('scripts/core_'..modid..'/hooks/'..v..'.lua')
end

-- 引入虚影植物生成器覆盖版本，让虚影优先选择被wilisha采集过的植物
modimport('scripts/components/lunarthrall_plantspawner_override.lua')
