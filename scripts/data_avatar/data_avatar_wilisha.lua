---@diagnostic disable: inject-field
-- 皮肤API
GLOBAL.WILISHA_API = env

local avatar_name = 'wilisha'

local modid = 'role_wilisha'

table.insert(PrefabFiles, 'avatar_'..avatar_name)

local assets_avatar = {
    Asset('ATLAS', 'images/saveslot_portraits/'..avatar_name..'.xml'),

	Asset('ATLAS', 'images/selectscreen_portraits/'..avatar_name..'.xml'),

	Asset('ATLAS', 'images/selectscreen_portraits/'..avatar_name..'_silho.xml'),

	Asset('ATLAS', 'bigportraits/'..avatar_name..'.xml'),

	Asset('ATLAS', 'images/map_icons/'..avatar_name..'.xml'),

	Asset('ATLAS', 'images/avatars/avatar_'..avatar_name..'.xml'),

	Asset('ATLAS', 'images/avatars/avatar_ghost_'..avatar_name..'.xml'),

	Asset('ATLAS', 'images/avatars/self_inspect_'..avatar_name..'.xml'),

	Asset('ATLAS', 'images/names_'..avatar_name..'.xml'),
	
    Asset( 'ATLAS', 'bigportraits/'..avatar_name..'_none.xml' ),
}

for _,v in pairs(assets_avatar) do
    table.insert(Assets, v)
end

--[[---注意事项
1. 目前官方自从熔炉之后人物的界面显示用的都是那个椭圆的图
2. 官方人物目前的图片跟名字是分开的 
3. 用打包工具生成好tex后
	bigportraits/xxx_none.xml 中 Element name 加上后缀 _oval
    images/names_xxx.xml 中 Element name 去掉前缀 names_
]]


modimport('scripts/api_skins/'..avatar_name..'_skins') -- 皮肤api

-- 初始物品
TUNING.WILISHA_CUSTOM_START_INV = {
	-- ['goldnugget'] = {
	-- 	num = 4, -- 数量
	-- 	moditem = false, -- 是否为mod物品
	-- 	-- img = {atlas = 'images/inventoryimages/goldnugget.xml', image = 'goldnugget.tex'},
	-- },
	-- ['flint'] = {
	-- 	num = 3,
	-- 	moditem = false,
	-- },
}

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT[string.upper(avatar_name)] = {}
for k,v in pairs(TUNING.WILISHA_CUSTOM_START_INV) do
	table.insert(TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT[string.upper(avatar_name)], k)
	if v.moditem then
		TUNING.STARTING_ITEM_IMAGE_OVERRIDE[k] = {
			atlas = v.img and v.img.atlas or "images/inventoryimages/"..k..".xml",
			image = v.img and v.img.image or k..".tex",
		}
	end
end


-- 角色注册
AddMinimapAtlas("images/map_icons/"..avatar_name..".xml")
AddModCharacter(avatar_name, "FEMALE") 

-- 三维
TUNING[string.upper(avatar_name)..'_HEALTH'] = 150
TUNING[string.upper(avatar_name)..'_HUNGER'] = 150
TUNING[string.upper(avatar_name)..'_SANITY'] = 250


local avatar_info = {
	['cn'] = {
		-- 选人界面的描述
		titles = "亮茄之子",
		names = "薇丽莎",
		descriptions = [[
*与植物息息相关
*同伴被杀死时会难过
*来自位面
*懂得如何“拒绝”别人
*食物能填肚子，但填不了心]],
		quotes = "\'我？还是我们……\'",
		survivability = "严峻",
		-- 描述
		myname = '薇丽莎', -- 角色名
		others_desc_me = '%s，我好像在哪见过你。', -- 其他人描述我
		me_desc_another_me = '%s，你和我……很像。', -- 自己描述自己
		--speech = require "speech_wathgrithr",--require "data_avatar/speech_wilisha",
	},
	['en'] = {
		-- select screen desc
		titles = "Children of the Brightshade",
		names = "wilisha",
		descriptions = [[
*Linked to plants
*Sad when a companion dies
*From the Dimension
*Knows how to "refuse" others
*Food fills the stomach, but not the heart
]],
		quotes = "\'me? or us?\'",
		survivability = "Grim",
		-- desc
		myname = 'Wilisha', -- avatar name
		others_desc_me = '%s, I think I have seen you before.', -- other people describe me
		me_desc_another_me = '%s, you and I... are very similar.', -- describe another me
		--speech = require"data_avatar/speech_wilisha_en",
	},
}

STRINGS.CHARACTER_TITLES[avatar_name] = avatar_info[TUNING[string.upper('CONFIG_'..modid..'_LANG')]].titles
STRINGS.CHARACTER_NAMES[avatar_name] = avatar_info[TUNING[string.upper('CONFIG_'..modid..'_LANG')]].names
STRINGS.CHARACTER_DESCRIPTIONS[avatar_name] = avatar_info[TUNING[string.upper('CONFIG_'..modid..'_LANG')]].descriptions
STRINGS.CHARACTER_QUOTES[avatar_name] = avatar_info[TUNING[string.upper('CONFIG_'..modid..'_LANG')]].quotes
STRINGS.CHARACTER_SURVIVABILITY[avatar_name] = avatar_info[TUNING[string.upper('CONFIG_'..modid..'_LANG')]].survivability

if STRINGS.CHARACTERS.WILISHA == nil then
    STRINGS.CHARACTERS.WILISHA = {}
end

if STRINGS.CHARACTERS.WILISHA.DESCRIBE == nil then
    STRINGS.CHARACTERS.WILISHA.DESCRIBE = {}
end

STRINGS.NAMES.WILISHA = avatar_info[TUNING[string.upper('CONFIG_'..modid..'_LANG')]].myname
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILISHA = avatar_info[TUNING[string.upper('CONFIG_'..modid..'_LANG')]].others_desc_me
STRINGS.CHARACTERS.WILISHA.DESCRIBE.WILISHA = avatar_info[TUNING[string.upper('CONFIG_'..modid..'_LANG')]].me_desc_another_me

-- STRINGS.CHARACTERS.WILISHA = avatar_info[TUNING[string.upper('CONFIG_'..modid..'_LANG')]].speech
-- 亮茄触手
STRINGS.CHARACTERS.WILISHA.DESCRIBE.WILISHA_LUNARPLANTTENTACLE = "我想我们惹祸了……"
STRINGS.CHARACTERS.WILISHA.ANNOUNCE_EATFAVORITEFOOD =
	{
		"这是我最喜欢的！",
		"我感觉自己在发光！",
		"闪闪发光！",
	}