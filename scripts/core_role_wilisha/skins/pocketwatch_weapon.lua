---@diagnostic disable: undefined-global
-- local prefab_id = 'cookpot'
-- local mid = '_skin_'

-- local _xml = GetInventoryItemAtlas('cookpot.tex') or "images/inventoryimages1.xml"
-- WEBBERT_API.MakeItemSkinDefaultImage(prefab_id, _xml, prefab_id)

-- local suffix = 'witch'
-- table.insert(Assets,Asset("ANIM","anim/"..prefab_id..mid..suffix..".zip"))
-- table.insert(Assets,Asset("ATLAS","images/inventoryimages/"..prefab_id..mid..suffix..".xml"))
-- WEBBERT_API.MakeItemSkin(prefab_id,prefab_id..mid..suffix,{
--     name = STRINGS.MOD_WEBBER_THE_TRAINER.SKIN_API.SKINS[prefab_id][suffix],
--     rarity = STRINGS.MOD_WEBBER_THE_TRAINER.SKIN_API.rare.cool,
--     raritycorlor = TUNING.MOD_WEBBER_THE_TRAINER.SKIN_API.rare.cool,
--     atlas = "images/inventoryimages/"..prefab_id..mid..suffix..".xml",
--     image = prefab_id..mid..suffix,
--     build = prefab_id..mid..suffix,
--     bank =  'cook_pot',
--     anim = "idle_empty",
--     animcircle = true,
--     basebuild = 'cook_pot',
--     basebank =  'cook_pot',
--     baseanim = "idle_empty",
--     baseanimcircle = true
-- })
local prefab_id = 'pocketwatch_weapon'
local mid = '_skin_'

local _xml = GetInventoryItemAtlas('pocketwatch_weapon.tex') or "images/inventoryimages1.xml"
WILISHA_API.MakeItemSkinDefaultImage(prefab_id, _xml, prefab_id)

local suffix = 'triumphant'
table.insert(Assets,Asset("ANIM","anim/"..prefab_id..mid..suffix..".zip"))
table.insert(Assets,Asset("ATLAS","images/inventoryimages/"..prefab_id..mid..suffix..".xml"))
WILISHA_API.MakeItemSkin(prefab_id,prefab_id..mid..suffix,{
    name = STRINGS.MOD_ROLE_WILISHA.SKIN_API.SKINS[prefab_id][suffix],
    rarity = STRINGS.UI.RARITY.Elegant,
    raritycorlor = TUNING.MOD_ROLE_WILISHA.SKIN_API.rare.cool,
    atlas = "images/inventoryimages/"..prefab_id..mid..suffix..".xml",
    image = prefab_id..mid..suffix,
    build = prefab_id..mid..suffix,
    bank =  'pocketwatch_weapon',
    anim = "idle",
    animcircle = true,
    basebuild = 'pocketwatch_weapon',
    basebank =  'pocketwatch_weapon',
    baseanim = "idle",
    baseanimcircle = true
})
