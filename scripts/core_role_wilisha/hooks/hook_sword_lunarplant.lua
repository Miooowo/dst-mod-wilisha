AddPrefabPostInit("sword_lunarplant", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    -- 为亮茄剑添加连续攻击加伤效果 (仅限wilisha佩戴，需要头盔)
    -- 薇丽莎持有时增加15%物理伤害
    
    -- 初始化连击相关变量
    inst.combo_stacks = 0
    inst.combo_decay_task = nil
    inst.combo_weapon = nil
    inst.wilisha_damage_bonus = false
    
    -- 检查是否佩戴头盔
    local function has_helmet(owner)
        if not owner or not owner.components.inventory then
            return false
        end
        local hat = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        return hat ~= nil and hat.prefab == "lunarplanthat"
    end
    
    -- 应用连击加伤到武器
    local function apply_combo_bonus(inst, weapon, stacks)
        if weapon and weapon.components.weapon then
            
            -- -- 薇丽莎基础伤害加成
            -- if inst.wilisha_damage_bonus then
            --     final_damage = final_damage * TUNING.WILISHA_SWORD_LUNARPLANT_DAMAGE_BONUS
            -- end
            
            
            
            -- 连击位面伤害加成
            if weapon.components.planardamage then
                if stacks > 0 then
                    local bonus = (stacks / TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_MAX_HITS) * TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_DAMAGE_MAX
                    weapon.components.planardamage:AddBonus(inst, bonus, "wilisha_sword_combo")
                else
                    weapon.components.planardamage:RemoveBonus(inst, "wilisha_sword_combo")
                end
            end
        end
    end

    -- 设置连击武器
    local function set_combo_weapon(inst, weapon)
        if inst.combo_weapon ~= weapon then
            if inst.combo_weapon then
                apply_combo_bonus(inst, inst.combo_weapon, 0)
            end
            inst.combo_weapon = weapon
            if weapon then
                apply_combo_bonus(inst, weapon, inst.combo_stacks)
            end
        end
    end
    
    -- 重置连击
    local function reset_combo(inst)
        if inst.combo_decay_task then
            inst.combo_decay_task:Cancel()
            inst.combo_decay_task = nil
        end
        
        inst.combo_stacks = 0
        if inst.combo_weapon then
            apply_combo_bonus(inst, inst.combo_weapon, 0)
        end
    end
    
    -- 头盔变化时更新连击状态
    local function on_helmet_change(owner, data)
        if data and data.eslot == EQUIPSLOTS.HEAD then
            -- 检查是否还佩戴着亮茄头盔
            local still_has_helmet = has_helmet(owner)
            
            if not still_has_helmet then
                -- 如果没有佩戴亮茄头盔，立即清除连击效果
                reset_combo(inst)
            else
                -- 如果还佩戴着亮茄头盔，重新计算伤害
                if inst.combo_weapon and inst.combo_stacks > 0 then
                    apply_combo_bonus(inst, inst.combo_weapon, inst.combo_stacks)
                end
            end
        end
    end
    
    
    -- 攻击时增加连击
    local function on_attack_other(owner, data)
        if not owner or not owner:HasTag("wilisha") then
            return
        end
        
        local weapon = owner.components.combat and owner.components.combat:GetWeapon()
        if not weapon or weapon ~= inst then
            return
        end
        
        if not inst.combo_weapon then
            return
        end
        
        -- 只有佩戴头盔时才启用连击效果
        if not has_helmet(owner) then
            return
        end
        
        -- 取消之前的衰减任务
        if inst.combo_decay_task then
            inst.combo_decay_task:Cancel()
        end
        inst.combo_decay_task = inst:DoTaskInTime(TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_DECAY_TIME, reset_combo)
        
        -- 增加连击数
        if inst.combo_stacks < TUNING.WILISHA_SWORD_LUNARPLANT_COMBO_MAX_HITS then
            inst.combo_stacks = inst.combo_stacks + 1
            apply_combo_bonus(inst, inst.combo_weapon, inst.combo_stacks)
        end
    end
    
    -- 装备时设置连击武器
    local function on_equip(inst, data)
        local owner = data and data.owner
        if owner and owner:HasTag("wilisha") then
            -- 薇丽莎基础伤害加成始终生效
            inst.wilisha_damage_bonus = true
            set_combo_weapon(inst, inst)
            inst:ListenForEvent("onattackother", on_attack_other, owner)
            -- 监听头盔装备变化
            inst:ListenForEvent("equip", on_helmet_change, owner)
            inst:ListenForEvent("unequip", on_helmet_change, owner)
        end
    end
    
    -- 卸下时清理连击
    local function on_unequip(inst, data)
        local owner = data and data.owner
        if owner then
            inst:RemoveEventCallback("onattackother", on_attack_other, owner)
            inst:RemoveEventCallback("equip", on_helmet_change, owner)
            inst:RemoveEventCallback("unequip", on_helmet_change, owner)
        end
        reset_combo(inst)
        set_combo_weapon(inst, nil)
        inst.wilisha_damage_bonus = false
    end
    
    -- 监听装备和卸下事件
    inst:ListenForEvent("equipped", on_equip)
    inst:ListenForEvent("unequipped", on_unequip)
end)