AddPrefabPostInit("pocketwatch_weapon", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    if not inst.components.planardamage then
        inst:AddComponent("planardamage")
        inst.components.planardamage:SetBaseDamage(0.000001)
    end
    local function TryStartFx(inst, owner)
        owner = owner
                or inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner
                or nil
    
        if owner == nil then
            return
        end
    
        if not inst.components.fueled:IsEmpty() then
            if inst._vfx_fx_inst ~= nil and inst._vfx_fx_inst.entity:GetParent() ~= owner then
                inst._vfx_fx_inst:Remove()
                inst._vfx_fx_inst = nil
            end
    
            if inst._vfx_fx_inst == nil then
                inst._vfx_fx_inst = SpawnPrefab("pocketwatch_weapon_fx")
                inst._vfx_fx_inst.entity:AddFollower()
                inst._vfx_fx_inst.entity:SetParent(owner.entity)
                inst._vfx_fx_inst.Follower:FollowSymbol(owner.GUID, "swap_object", 15, 70, 0)
            end
        end
    end
    
    local function StopFx(inst)
        if inst._vfx_fx_inst ~= nil then
            inst._vfx_fx_inst:Remove()
            inst._vfx_fx_inst = nil
        end
    end
    local function OnFuelChanged(inst, data)
        if data and data.percent then
            if data.percent > 0 then
                if not inst:HasTag("shadow_item") then
                    inst:AddTag("shadow_item")
                    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_SHADOW_DAMAGE)
                    TryStartFx(inst)
                end
            else
                inst:RemoveTag("shadow_item")
                inst.components.weapon:SetDamage(TUNING.POCKETWATCH_DEPLETED_DAMAGE)
                -- 移除位面伤害加成
                inst.components.planardamage:RemoveBonus(inst, "setbonus")
                StopFx(inst)
            end
        end
    end
    -- 设置套装加成效果（当装备虚空风帽时激活）
    local function SetBuffEnabled(inst, enabled)
        if enabled then
            -- 激活套装效果
            if not inst._bonusenabled then
                inst._bonusenabled = true
                if inst:HasTag("shadow_item") then
                    -- 增加武器伤害
                    if inst.components.weapon ~= nil then
                        inst.components.weapon:SetDamage(TUNING.POCKETWATCH_SHADOW_DAMAGE * TUNING.WEAPONS_VOIDCLOTH_SETBONUS_DAMAGE_MULT)
                    end
                    -- 增加位面伤害
                    inst.components.planardamage:AddBonus(inst, TUNING.WEAPONS_VOIDCLOTH_SETBONUS_PLANAR_DAMAGE, "setbonus")
                else
                    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_DEPLETED_DAMAGE)
                    -- 移除位面伤害加成
                    inst.components.planardamage:RemoveBonus(inst, "setbonus")
                end
            end
        elseif inst._bonusenabled then
            -- 取消套装效果
            inst._bonusenabled = nil
            -- 恢复原始武器伤害
            if inst.components.weapon ~= nil then
                if inst:HasTag("shadow_item") then
                    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_SHADOW_DAMAGE)
                else
                    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_DEPLETED_DAMAGE)
                end
                -- 移除位面伤害加成
                inst.components.planardamage:RemoveBonus(inst, "setbonus")
            end
        end
    end
    -- 设置套装效果的所有者（监听装备变化）
    local function SetBuffOwner(inst, owner)
        if inst._owner ~= owner then
            -- 清理旧所有者的监听器
            if inst._owner ~= nil then
                inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
                inst:RemoveEventCallback("unequip", inst._onownerunequip, inst._owner)
                inst._onownerequip = nil
                inst._onownerunequip = nil
                SetBuffEnabled(inst, false) -- 取消套装效果
            end
            
            -- 设置新所有者
            inst._owner = owner
            if owner ~= nil then
                -- 监听装备事件：检查是否装备了虚空布帽子
                inst._onownerequip = function(owner, data)
                    if data ~= nil then
                        if data.item ~= nil and data.item.prefab == "voidclothhat" then
                            SetBuffEnabled(inst, true) -- 装备虚空布帽子时激活套装效果
                        elseif data.eslot == EQUIPSLOTS.HEAD then
                            SetBuffEnabled(inst, false) -- 装备其他帽子时取消套装效果
                        end
                    end
                end
                
                -- 监听卸装事件：检查是否卸下了头部装备
                inst._onownerunequip  = function(owner, data)
                    if data ~= nil and data.eslot == EQUIPSLOTS.HEAD then
                        SetBuffEnabled(inst, false) -- 卸下头部装备时取消套装效果
                    end
                end
                
                -- 注册事件监听器
                inst:ListenForEvent("equip", inst._onownerequip, owner)
                inst:ListenForEvent("unequip", inst._onownerunequip, owner)

                -- 检查当前是否已装备虚空布帽子
                local hat = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                if hat ~= nil and hat.prefab == "voidclothhat" then
                    SetBuffEnabled(inst, true) -- 立即激活套装效果
                end
            end
        end
    end
    -- 初始化连击相关变量
    inst.combo_stacks = 0
    inst.combo_decay_task = nil
    inst.combo_weapon = nil
    inst.wilisha_damage_bonus = false
    
    -- -- 检查是否佩戴头盔
    -- local function has_helmet(owner)
    --     if not owner or not owner.components.inventory then
    --         return false
    --     end
    --     local hat = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    --     return hat ~= nil and hat.prefab == "voidclothhat"
    -- end
    
    -- -- 应用连击加伤到武器
    -- local function apply_combo_bonus(inst, weapon, stacks)
    --     if weapon and weapon.components.weapon then
    --         local base_damage = weapon.base_damage or weapon.components.weapon.damage
    --         local final_damage = base_damage
            
    --         -- -- 薇丽莎基础伤害加成
    --         -- if inst.wilisha_damage_bonus then
    --         --     final_damage = final_damage * TUNING.WILISHA_SWORD_LUNARPLANT_DAMAGE_BONUS
    --         -- end
            
    --         -- 设置物理伤害
    --         weapon.components.weapon:SetDamage(final_damage)
            
    --         -- 连击位面伤害加成
    --         if weapon.components.planardamage then
    --             if stacks > 0 then
    --                 local bonus = (stacks / TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_MAX_HITS) * TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_DAMAGE_MAX
    --                 weapon.components.planardamage:AddBonus(inst, bonus, "wilisha_sword_combo")
    --             else
    --                 weapon.components.planardamage:RemoveBonus(inst, "wilisha_sword_combo")
    --             end
    --         end
    --     end
    -- end
    
    -- -- 头盔变化时更新连击状态
    -- local function on_helmet_change(owner, data)
    --     if data and data.eslot == EQUIPSLOTS.HEAD then
    --         -- 如果当前有连击，需要重新计算伤害
    --         if inst.combo_weapon and inst.combo_stacks > 0 then
    --             apply_combo_bonus(inst, inst.combo_weapon, inst.combo_stacks)
    --         end
    --     end
    -- end
    
    -- -- 设置连击武器
    -- local function set_combo_weapon(inst, weapon)
    --     if inst.combo_weapon ~= weapon then
    --         if inst.combo_weapon then
    --             apply_combo_bonus(inst, inst.combo_weapon, 0)
    --         end
    --         inst.combo_weapon = weapon
    --         if weapon then
    --             weapon.base_damage = weapon.components.weapon.damage
    --             apply_combo_bonus(inst, weapon, inst.combo_stacks)
    --         end
    --     end
    -- end
    
    -- -- 重置连击
    -- local function reset_combo(inst)
    --     if inst.combo_decay_task then
    --         inst.combo_decay_task:Cancel()
    --         inst.combo_decay_task = nil
    --     end
        
    --     inst.combo_stacks = 0
    --     if inst.combo_weapon then
    --         apply_combo_bonus(inst, inst.combo_weapon, 0)
    --     end
    -- end
    
    -- -- 攻击时增加连击
    -- local function on_attack_other(owner, data)
    --     -- if not owner or not owner:HasTag("wilisha") then
    --     --     return
    --     -- end
        
    --     local weapon = owner.components.combat and owner.components.combat:GetWeapon()
    --     if not weapon or weapon ~= inst then
    --         return
    --     end
        
    --     if not inst.combo_weapon then
    --         return
    --     end
        
    --     -- 只有佩戴头盔时才启用连击效果
    --     if not has_helmet(owner) then
    --         return
    --     end
        
    --     -- 取消之前的衰减任务
    --     if inst.combo_decay_task then
    --         inst.combo_decay_task:Cancel()
    --     end
    --     inst.combo_decay_task = inst:DoTaskInTime(TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_DECAY_TIME, reset_combo)
        
    --     -- 增加连击数
    --     if inst.combo_stacks < TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_MAX_HITS then
    --         inst.combo_stacks = inst.combo_stacks + 1
    --         apply_combo_bonus(inst, inst.combo_weapon, inst.combo_stacks)
    --     end
    -- end

    inst:ListenForEvent("percentusedchange", OnFuelChanged)
    local function onequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_object", inst.GUID, "swap_object")
        else
            owner.AnimState:OverrideSymbol("swap_object", "pocketwatch_weapon", "swap_object")
        end
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    
        TryStartFx(inst, owner)
        if inst:HasTag("shadow_item") then
            SetBuffEnabled(inst, true)
        else
            SetBuffEnabled(inst, false)
        end
        SetBuffOwner(inst, owner)
        -- inst.wilisha_damage_bonus = true
        -- set_combo_weapon(inst, inst)
        -- inst:ListenForEvent("onattackother", on_attack_other, owner)
        -- inst:ListenForEvent("equip", on_helmet_change, owner)
        -- inst:ListenForEvent("unequip", on_helmet_change, owner)
    end
    
    local function onunequip(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end
        StopFx(inst)
        SetBuffOwner(inst, nil)
        -- reset_combo(inst)
        -- set_combo_weapon(inst, nil)
        -- inst.wilisha_damage_bonus = false
    end
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
end)