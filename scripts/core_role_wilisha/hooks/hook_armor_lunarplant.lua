AddPrefabPostInit("armor_lunarplant", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    local function OnHit_Vines(owner, data)
        if owner == nil or data == nil then
            return
        end

        local attacker = data.attacker
        if not attacker or not attacker.components.locomotor
                or (attacker.components.health and attacker.components.health:IsDead()) then
            return
        end

        local owner_skilltreeupdater = owner.components.skilltreeupdater
        if owner_skilltreeupdater and owner_skilltreeupdater:IsActivated("wormwood_allegiance_lunar_plant_gear_1") then
            attacker:AddDebuff("wormwood_vined_debuff", "wormwood_vined_debuff")
        end
        
        -- 新增判断：如果角色是wilisha则新增buff
        if owner.prefab == "wilisha" then
            attacker:AddDebuff("wormwood_vined_debuff", "wormwood_vined_debuff")
        end
    end
    
    inst._onblocked = OnHit_Vines
end)