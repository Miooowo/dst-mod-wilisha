TUNING.MOD_ROLE_WILISHA = {
    ---@type table<PrefabID,{type: 'finiteuses'|'armor'|'fueled', repair_percent: table<PrefabID,number>, cantequip_whennodurability: boolean|nil, autounequip_whennodurability: boolean|nil}>
    REPAIR_COMMON = { -- 官方的三个组件的修理, finiteuses armor fueled, 给一堆物品时, 尽可能多的消耗物品来修理
        -- spear = {
        --     type = 'finiteuses', -- 组件ID
        --     repair_percent = { -- 键为物品prefabID, 值为修理百分比
        --         flint = .2,
        --     },
        --     cantequip_whennodurability = false, -- 是否在耐久用尽时不允许装备,如果你得物品在耐久耗尽时,就直接被移除了,这个就不用填了,只有在耐久用尽,要保留物品时才填这个
        --     autounequip_whennodurability = false, -- 是否在耐久用尽时自动卸下到库存中
        -- },
    },
    SKIN_API = {
        rare = {
            elegent = {255/255,39/255,79/255,1},
            top = {91/255,193/255,255/255,1},
            reward = {255/255,255/255,16/255,1},
            cool = {225/255,31/255,248/255,1},
            loyal = {36/255,235/255,64/255,1},
        }
    },
}
TUNING.WILISHA_PHOTOSYNTHESIS_HEALTH_REGEN = {
        amount = 1,
        period = 5,
}
TUNING.WILISHA_ALLEGIANCE_LUNAR_RESIST = 0.9
TUNING.WILISHA_ALLEGIANCE_VS_SHADOW_BONUS = 1.1

-- 亮茄剑连续攻击加伤参数 (参考虚空风帽)
TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_DAMAGE_MAX = 7  -- 最大加伤
TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_MAX_HITS = 5      -- 最大连击数
TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_DECAY_TIME = 4    -- 连击衰减时间(秒)
TUNING.WILISHA_SWORD_LUNARPLANT_DAMAGE_BONUS = 1.15     -- 薇莉莎持有时的物理伤害加成(15%)
TUNING.WILISHA_ENLIGHTENED_DAMAGE_BONUS = 1.25          -- 启蒙状态时的伤害倍率加成(25%)
TUNING.WILISHA_ENLIGHTENED_PLANAR_DAMAGE_BONUS = 5      -- 启蒙状态时的位面伤害加成