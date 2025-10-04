---@diagnostic disable: undefined-global, inject-field

local MakePlayerCharacter = require 'prefabs/player_common'

local avatar_name = 'wilisha'
local assets = {
	Asset('SCRIPT', 'scripts/prefabs/player_common.lua'),
	Asset('ANIM', 'anim/'..avatar_name..'.zip'),
	Asset('ANIM', 'anim/ghost_'..avatar_name..'_build.zip'),
    -- Asset('ANIM', 'anim/lunarthrall_plant_gestalt.zip'),
}

local prefabs = {}

local start_inv = {}
-- for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
-- 	start_inv[string.lower(k)] = v[string.upper(avatar_name)]
-- end
start_inv['default'] = {}
if TUNING.WILISHA_CUSTOM_START_INV~=nil then
    for k,v in pairs(TUNING.WILISHA_CUSTOM_START_INV) do
        for i = 1, v.num do 
            table.insert(start_inv['default'], k)
        end
    end
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function IsValidVictim(victim)
    return victim ~= nil
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
		and not (	(victim:HasTag("prey") and not victim:HasTag("hostile")) or
					victim:HasAnyTag(NON_LIFEFORM_TARGET_TAGS) or
					victim:HasTag("companion")
				)
end
local WATCH_WORLD_PLANTS_DIST_SQ = 20 * 20
local SANITY_DRAIN_TIME = 5
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---植物人相关函数
local function SanityRateFn(inst, dt)
    local amt = 0
    for bonus_index = #inst.plantbonuses, 1, -1 do
        local bonus_data = inst.plantbonuses[bonus_index]
        if bonus_data.t > dt then
            bonus_data.t = bonus_data.t - dt
        else
            table.remove(inst.plantbonuses, bonus_index)
        end
        amt = amt + bonus_data.amt
    end
    for bonus_index = #inst.plantpenalties, 1, -1 do
        local penalty_data = inst.plantpenalties[bonus_index]
        if penalty_data.t > dt then
            penalty_data.t = penalty_data.t - dt
        else
            table.remove(inst.plantpenalties, bonus_index)
        end
        amt = amt + penalty_data.amt
    end
    return amt
end

-- local function DoPlantBonus(inst, bonus, overtime)
--     if overtime then
--         table.insert(inst.plantbonuses, {
--             amt = bonus / SANITY_DRAIN_TIME,
--             t = SANITY_DRAIN_TIME
--         })
--     else
--         while #inst.plantpenalties > 0 do
--             table.remove(inst.plantpenalties)
--         end
--         inst.components.sanity:DoDelta(bonus)
--         inst.components.talker:Say(GetString(inst, "ANNOUNCE_GROWPLANT"))
--     end
-- end

-- local function DoKillPlantPenalty(inst, penalty, overtime)
--     if overtime then
--         table.insert(inst.plantpenalties, {
--             amt = -penalty / SANITY_DRAIN_TIME,
--             t = SANITY_DRAIN_TIME
--         })
--     else
--         while #inst.plantbonuses > 0 do
--             table.remove(inst.plantbonuses)
--         end
--         inst.components.sanity:DoDelta(-penalty)
--         inst.components.talker:Say(GetString(inst, "ANNOUNCE_KILLEDPLANT"))
--     end
-- end
local function CalcSanityMult(distsq)
    distsq = 1 - math.sqrt(distsq / WATCH_WORLD_PLANTS_DIST_SQ)
    return distsq * distsq
end

-- local function WatchWorldPlants(inst)
--     -- if not inst._onitemplanted then
--     --     inst._onitemplanted = function(src, data)
--     --         if not data then
--     --             --shouldn't happen
--     --         elseif data.doer == inst then
--     --             DoPlantBonus(inst, TUNING.SANITY_TINY * 2)
--     --         elseif data.pos then
--     --             local distsq = inst:GetDistanceSqToPoint(data.pos)
--     --             if distsq < WATCH_WORLD_PLANTS_DIST_SQ then
--     --                 DoPlantBonus(inst, CalcSanityMult(distsq) * TUNING.SANITY_SUPERTINY * 2, true)
--     --             end
--     --         end
--     --     end
--     --     inst:ListenForEvent("itemplanted", inst._onitemplanted, TheWorld)
--     -- end

--     -- if not inst._onplantkilled then
--     --     inst._onplantkilled = function(src, data)
--     --         if not data then
--     --             --shouldn't happen
--     --         elseif data.doer == inst then
--     --             DoKillPlantPenalty(inst, data.workaction and data.workaction ~= ACTIONS.DIG and TUNING.SANITY_MED or TUNING.SANITY_TINY)
--     --         elseif data.pos then
--     --             local distsq = inst:GetDistanceSqToPoint(data.pos)
--     --             if distsq < WATCH_WORLD_PLANTS_DIST_SQ then
--     --                 DoKillPlantPenalty(inst, CalcSanityMult(distsq) * TUNING.SANITY_SUPERTINY * 2, true)
--     --             end
--     --         end
--     --     end
--     --     inst:ListenForEvent("plantkilled", inst._onplantkilled, TheWorld)
--     -- end
-- end

local function StopWatchingWorldPlants(inst)
    if inst._onitemplanted then
        inst:RemoveEventCallback("itemplanted", inst._onitemplanted, TheWorld)
        inst._onitemplanted = nil
    end
    if inst._onplantkilled then
        inst:RemoveEventCallback("plantkilled", inst._onplantkilled, TheWorld)
        inst._onplantkilled = nil
    end
end

-- Also called from skilltree_wormwood.lua
local function UpdatePhotosynthesisState(inst, isday)
    local should_photosynthesize = false
    if isday and not inst:HasTag("playerghost") then
        should_photosynthesize = true
    end
    if should_photosynthesize ~= inst.photosynthesizing then
        inst.photosynthesizing = should_photosynthesize
        if inst.components.health then
            if should_photosynthesize then
                local regen = TUNING.WILISHA_PHOTOSYNTHESIS_HEALTH_REGEN
                inst.components.health:AddRegenSource(inst, regen.amount, regen.period, "photosynthesis_skill")
            else
                inst.components.health:RemoveRegenSource(inst, "photosynthesis_skill")
            end
        end
    end
end
local function OnIsDay(inst, isday)
    if isday then
        inst:UpdatePhotosynthesisState(true)
    else
        inst:UpdatePhotosynthesisState(false)
    end
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
local function onkilled(inst, data)
    if data.incinerated then
        return -- NOTES(JBK): Do not spawn spirits for this.
    end
    local victim = data.victim
    if inst.IsValidVictim(victim) then
        if victim:HasTag("lunarthrall_plant") then
            inst.components.sanity:DoDelta(-25)
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_KILLEDPLANT"))
        end
    end
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
local function ModifyFoodEffect(inst, health, hunger, sanity, food)
    --最爱食物精神值回复
    if food.prefab == "wormlight" then
        sanity = sanity + 15
    end

    return health, hunger, sanity
end

local function OnEatFavoriteFood(inst, data)
    if data and data.food and data.food.prefab == "wormlight" then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_EATFAVORITEFOOD"))
    end
end

-- 当wilisha采集植物时，给植物添加特殊标记
local function OnHarvestPlant(inst, data)
    if data and data.target and data.target:IsValid() then
        -- 检查是否是植物类实体
        if data.target:HasTag("plant") or data.target:HasTag("lunarplant_target") then
            -- 给植物添加被wilisha采集过的标记
            data.target:AddTag("wilisha_harvested")
            -- 设置一个组件来记录采集时间
            if not data.target.components.wilisha_harvest_tracker then
                data.target:AddComponent("wilisha_harvest_tracker")
            end
            data.target.components.wilisha_harvest_tracker:SetHarvestedByWilisha(GetTime())
        end
    end
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
local function OnIsFullmoon(inst, isfullmoon)
    if not inst.components.sanity.inducedlunacy and isfullmoon then
        inst.components.sanity:SetInducedLunacy(inst, true)
        inst.components.sanity:EnableLunacy(true, "wilisha_lunar_fullmoon")
    else
        inst.components.sanity:SetInducedLunacy(inst, false)
        inst.components.sanity:EnableLunacy(false, "wilisha_lunar_fullmoon")
    end
end

-- 理智值特效管理
local function UpdateFloatTopEffect(inst)
    if not inst:HasTag("playerghost") and inst.components.sanity then
        local sanity_percent = inst.components.sanity:GetPercent()
        local should_show_effect = sanity_percent > 0.5
        
        if should_show_effect and not inst.fx_wilisha_float_top then
            -- 创建特效
            inst.fx_wilisha_float_top = SpawnPrefab("fx_wilisha_float_top")
            if inst.fx_wilisha_float_top then
                inst.fx_wilisha_float_top.entity:SetParent(inst.entity)
                inst.fx_wilisha_float_top.Follower:FollowSymbol(inst.GUID, "headbase", -40, -120, 0) -- 往左上方移动
                local frames = inst.fx_wilisha_float_top.AnimState:GetCurrentAnimationNumFrames()
                local rnd = math.random(frames) - 1
                inst.fx_wilisha_float_top.AnimState:SetFrame(rnd)
                -- 启动朝向检测定时器
                -- if not inst._float_top_task then
                --     inst._float_top_task = inst:DoPeriodicTask(0.1, function()
                --         if inst.fx_wilisha_float_top and inst.fx_wilisha_float_top:IsValid() then
                --             inst.fx_wilisha_float_top:UpdateFacing(inst)
                --         end
                --     end)
                -- end
            end
        elseif not should_show_effect and inst.fx_wilisha_float_top then
            -- 移除特效
            if inst.fx_wilisha_float_top:IsValid() then
                inst.fx_wilisha_float_top:Remove()
            end
            inst.fx_wilisha_float_top = nil
            
            -- 停止朝向检测定时器
            -- if inst._float_top_task then
            --     inst._float_top_task:Cancel()
            --     inst._float_top_task = nil
            -- end
        end
    elseif inst.fx_wilisha_float_top then
        -- 如果是幽灵状态，移除特效
        if inst.fx_wilisha_float_top:IsValid() then
            inst.fx_wilisha_float_top:Remove()
        end
        inst.fx_wilisha_float_top = nil
        
        -- 停止朝向检测定时器
        -- if inst._float_top_task then
        --     inst._float_top_task:Cancel()
        --     inst._float_top_task = nil
        -- end
    end
end

-- 更新启蒙状态伤害倍率
local function UpdateEnlightenedDamageBonus(inst)
    if not inst:HasTag("playerghost") and inst.components.sanity and inst.components.combat then
        local is_enlightened = inst.components.sanity.inducedlunacy -- 使用inducedlunacy属性判断启蒙状态
        
        if is_enlightened then
            -- 添加启蒙状态伤害倍率
            inst.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.WILISHA_ENLIGHTENED_DAMAGE_BONUS, "wilisha_enlightened_bonus")
            inst.components.planardamage:AddBonus(inst, TUNING.WILISHA_ENLIGHTENED_PLANAR_DAMAGE_BONUS, "wilisha_enlightened_bonus")
        else
            -- 移除启蒙状态伤害倍率
            inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "wilisha_enlightened_bonus")
            inst.components.planardamage:RemoveBonus(inst, "wilisha_enlightened_bonus")
        end
    end
end

local function OnSanityChanged(inst, data)
    UpdateFloatTopEffect(inst)
    UpdateEnlightenedDamageBonus(inst)
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
local function onbecamehuman(inst, data, isloading)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, avatar_name..'_speed_mod', 1)

	-- WatchWorldPlants(inst)

    inst:WatchWorldState("isday", OnIsDay)
    inst:UpdatePhotosynthesisState(TheWorld.state.isday)
    
    -- 添加理智值监听
    inst:ListenForEvent("sanitydelta", OnSanityChanged)
    inst:ListenForEvent("sanitychanged", OnSanityChanged)
    
    -- 初始化特效状态
    UpdateFloatTopEffect(inst)
    
    -- 初始化启蒙状态伤害倍率
    UpdateEnlightenedDamageBonus(inst)
end

local function onbecameghost(inst, data)
	inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, avatar_name..'_speed_mod')

	StopWatchingWorldPlants(inst)
	
    inst:UpdatePhotosynthesisState(TheWorld.state.isday)
    
    -- 移除理智值监听和特效
    inst:RemoveEventCallback("sanitydelta", OnSanityChanged)
    inst:RemoveEventCallback("sanitychanged", OnSanityChanged)
    UpdateFloatTopEffect(inst) -- 这会移除特效
    
    -- 移除启蒙状态伤害倍率
    if inst.components.combat then
        inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "wilisha_enlightened_bonus")
        inst.components.planardamage:RemoveBonus(inst, "wilisha_enlightened_bonus")
    end
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
local function ReflectDamageFn(inst, attacker, damage, weapon, stimuli, spdamage)
    -- 基础反射伤害
    local dmg = 15
    --inst.components.talker:Say(inst.components.combat:GetDebugString())
    -- 返回反射伤害，包括平面伤害
    return 0,
    {
        planar = attacker ~= nil and attacker:HasTag("shadow_aligned")
            and dmg * 2
            or dmg,
    }
end

local function OnEquip(inst, data)
    local item = data and data.item
    if item and item.components.weapon and item.prefab:find("lunarplant") then
        -- 额外伤害
        inst.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.WILISHA_SWORD_LUNARPLANT_DAMAGE_BONUS, "wilisha_attack_modifier")
        -- 设置磨损率为 0.85，即减少 15%
        item.components.weapon.attackwearmultipliers:SetModifier(inst, 0.85, "wilisha_modifier")
    end
    if item and item.components.armor and item.prefab:find("lunarplant") then
        -- 设置磨损率为 0.85，即减少 15%
        item.components.armor.conditionlossmultipliers:SetModifier(inst, 0.85, "wilisha_modifier")
    end
end

local function OnUnequip(inst, data)
    local item = data and data.item
    if item and item.components.weapon and item.prefab:find("lunarplant") then
        inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "wilisha_attack_modifier")
        -- 移除磨损率修正
        item.components.weapon.attackwearmultipliers:RemoveModifier(inst, "wilisha_modifier")
    end
    if item and item.components.armor and item.prefab:find("lunarplant") then
        -- 移除磨损率修正
        item.components.armor.conditionlossmultipliers:RemoveModifier(inst, "wilisha_modifier")
    end
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
local function onload(inst,data)
	inst:ListenForEvent('ms_respawnedfromghost', onbecamehuman)
	inst:ListenForEvent('ms_becameghost', onbecameghost)

	if inst:HasTag('playerghost') then
		onbecameghost(inst)
	else
		onbecamehuman(inst)
	end
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- 主/客机
local common_postinit = function(inst)
	inst:AddTag("plantkin") --植物人活木相关标签
	inst:AddTag(avatar_name)
	inst:AddTag("lunarthrall_plant") --亮茄标签
    inst:AddTag("stronggrip") --强力抓取 防脱手
	
	inst.MiniMapEntity:SetIcon(avatar_name..'.tex')

	if LOC.GetTextScale() == 1 then
        --Note(Peter): if statement is hack/guess to make the talker not resize for users that are likely to be speaking using the fallback font.
        --Doesn't work for users across multiple languages or if they speak in english despite having a UI set to something else, but it's more likely to be correct, and is safer than modifying the talker
        inst.components.talker.fontsize = 40
    end
    inst.components.talker.font = TALKINGFONT_WORMWOOD
    inst.components.talker.colour = Vector3(135/255, 169/255, 107/255)

end
-- 主机
local master_postinit = function(inst)	
	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	inst.soundsname = 'wormwood'
	inst.endtalksound = "dontstarve/characters/wormwood/end"
	
	inst.components.health:SetMaxHealth(TUNING[string.upper(avatar_name)..'_HEALTH'])
	inst.components.hunger:SetMax(TUNING[string.upper(avatar_name)..'_HUNGER'])
	inst.components.sanity:SetMax(TUNING[string.upper(avatar_name)..'_SANITY'])

	inst.components.health.fire_damage_scale = TUNING.WORMWOOD_FIRE_DAMAGE --额外的火伤
	inst.components.burnable:SetBurnTime(TUNING.WORMWOOD_BURN_TIME) --额外燃烧时间

	inst.plantbonuses = {}
    inst.plantpenalties = {}
    inst.components.sanity.custom_rate_fn = SanityRateFn
    inst.components.sanity.no_moisture_penalty = true

    if inst.components.eater then
        --No health from food
        inst.components.eater.custom_stats_mod_fn = ModifyFoodEffect
        inst.components.eater:SetAbsorptionModifiers(0, 1, 1)
		inst:ListenForEvent("oneat", OnEatFavoriteFood)
    end
	inst.components.foodaffinity:AddPrefabAffinity("wormlight", TUNING.AFFINITY_15_CALORIES_MED) --最喜爱食物

    inst.IsValidVictim = IsValidVictim
-- ----------------------------------- 战斗 --------------------------------------
	inst.components.combat:SetDefaultDamage(5)

	inst:AddComponent("planarentity") --位面实体抵抗 
    inst.components.planardamage:SetBaseDamage(5)

    inst:AddTag("player_lunar_aligned") --月亮亲和
    local damagetyperesist = inst.components.damagetyperesist
    if damagetyperesist then
        damagetyperesist:AddResist("lunar_aligned", inst, TUNING.WILISHA_ALLEGIANCE_LUNAR_RESIST, "lunarthrall_plant_girl")
    end
    local damagetypebonus = inst.components.damagetypebonus
    if damagetypebonus then
        damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WILISHA_ALLEGIANCE_VS_SHADOW_BONUS, "lunarthrall_plant_girl")
    end
    
    inst:AddComponent("battleborn") --为战而生
    inst.components.battleborn:SetBattlebornBonus(TUNING.WATHGRITHR_BATTLEBORN_BONUS)
    inst.components.battleborn:SetSanityEnabled(true)
    inst.components.battleborn:SetHealthEnabled(true)
    inst.components.battleborn:SetValidVictimFn(inst.IsValidVictim)
    inst.components.battleborn.allow_zero = false -- Don't regain stats if our attack is trying to deal literally 0 damage.

    -- 虚影减伤效果
    if inst.components.combat ~= nil then
        -- 保存旧的 GetAttacked
        local _OldGetAttacked = inst.components.combat.GetAttacked

        inst.components.combat.GetAttacked = function(self, attacker, damage, weapon, stimuli, ...)
            if attacker ~= nil and (
                attacker.prefab == "smallguard_alterguardian_projectile" or
                attacker.prefab == "largeguard_alterguardian_projectile" or
                attacker.prefab == "alterguardian_laser"
            ) then
                damage = damage * 0.75 -- 减伤 25%
                --print("wilisha受到虚影攻击："..attacker.prefab.."，减伤后伤害："..damage)
            end
            return _OldGetAttacked(self, attacker, damage, weapon, stimuli, ...)
        end

        -- 把旧函数存起来，方便移除时恢复
        inst._old_alterguardian_GetAttacked = _OldGetAttacked
    end

    inst:ListenForEvent("killed", onkilled)
    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("unequip", OnUnequip)
    inst:ListenForEvent("harvest", OnHarvestPlant)

    inst:AddComponent("damagereflect") --伤害反射
    inst.components.damagereflect:SetReflectDamageFn(ReflectDamageFn)
-- -----------------------------------------------------------------------------
	-- WatchWorldPlants(inst)

	inst.UpdatePhotosynthesisState = UpdatePhotosynthesisState
-- ----------------------------------------------------------------------------
    --月圆变异
    inst:WatchWorldState("isfullmoon", OnIsFullmoon)

	inst.OnLoad = onload
	inst.OnNewSpawn = onload
end

-- ---------------------------------- 人物皮肤 -------------------------------------
local function MakeWILISHASkin(name, data, notemp, free)
	local d = {}
	d.rarity = '典藏'
	d.rarityorder = 2
	d.raritycorlor = { 0 / 255, 255 / 255, 249 / 255, 1 }
	d.release_group = -1001
	d.skin_tags = { 'BASE', avatar_name, 'CHARACTER' }
	d.skins = {
		normal_skin = name,
		ghost_skin = 'ghost_'..avatar_name..'_build'
	}
	if not free then
		d.checkfn = WILISHA_API.WILISHASkinCheckFn
		d.checkclientfn = WILISHA_API.WILISHASkinCheckFn
	end
	d.share_bigportrait_name = avatar_name
	d.FrameSymbol = 'Reward'
	for k, v in pairs(data) do
		d[k] = v
	end
	WILISHA_API.MakeCharacterSkin(avatar_name, name, d)
	if not notemp then
		local d2 = shallowcopy(d)
		d2.rarity = '限时体验'
		d2.rarityorder = 80
		d2.raritycorlor = { 0.957, 0.769, 0.188, 1 }
		d2.FrameSymbol = 'heirloom'
		d2.name = data.name .. '(限时)'
		WILISHA_API.MakeCharacterSkin(avatar_name, name .. '_tmp', d2)
	end
end
function MakeWILISHAFreeSkin(name, data)
	MakeWILISHASkin(name, data, true, true)
end

MakeWILISHAFreeSkin(avatar_name..'_none', {
	-- name = '轻雨', -- 皮肤的名称
	-- des = '*轻樱\n*雨落', -- 皮肤界面的描述
	-- quotes = '\'轻樱雨落\'', -- 选人界面的描述
	-- rarity = '典藏', -- 珍惜度 官方不存在的珍惜度则直接覆盖字符串
	-- rarityorder = 2, -- 珍惜度的排序 用于按优先级排序 基本没啥用
	-- raritycorlor = { 189 / 255, 73 / 255, 73 / 255, 1 }, -- {R,G,B,A}
	-- skins = { normal_skin = "esctemplate", ghost_skin = 'ghost_'..avatar_name..'_build' },
	-- build_name_override = avatar_name,
	-- share_bigportrait_name = avatar_name..'_none',
	name = '薇丽莎', -- 皮肤的名称
	des = '苏醒之后，她只记得她叫这个名字。', -- 皮肤界面的描述
	quotes = '\'我？还是我们……\'', -- 选人界面的描述
	rarity = 'Character', -- 珍惜度 官方不存在的珍惜度则直接覆盖字符串
	rarityorder = 2, -- 珍惜度的排序 用于按优先级排序 基本没啥用
	--raritycorlor = { 189 / 255, 73 / 255, 73 / 255, 1 }, -- {R,G,B,A}
	skins = { normal_skin = avatar_name, ghost_skin = 'ghost_'..avatar_name..'_build' },
	build_name_override = avatar_name,
	share_bigportrait_name = avatar_name..'_none',
})


return MakePlayerCharacter(avatar_name, prefabs, assets, common_postinit, master_postinit, prefabs)