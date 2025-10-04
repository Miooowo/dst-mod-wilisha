AddPrefabPostInit("lunarthrall_plant", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
    inst.components.lootdropper:AddRandomHauntedLoot("coolant", 0.01)
    -- 标记是否由作祟复活触发的死亡
    inst.haunt_death = false
    
    -- 自定义作祟函数：只有wilisha可以复活
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        -- 检查作祟者是否是wilisha
        if haunter and haunter:HasTag("wilisha") then
            -- wilisha作祟时正常复活
            -- 复活后杀死致命亮茄
            inst:DoTaskInTime(0.1, function()
                if inst and inst:IsValid() then
                    -- 标记为作祟死亡，会掉落特殊战利品
                    inst.haunt_death = true
                    -- 杀死致命亮茄，会掉落战利品
                    if inst.components.health then
                        inst.components.health:Kill()
                    else
                        inst:Remove()
                    end
                end
            end)
            return true
        else
            -- 其他角色作祟时无反应
            return false
        end
    end)
end)

AddPrefabPostInit("frog", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("hauntable")
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE
    
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        -- 检查作祟者是否是wilisha
        if haunter and haunter:HasTag("wilisha") then
            -- wilisha作祟时有25%几率转变为月蛙
            if math.random() < 0.25 then
                local lunarfrog = SpawnPrefab("lunarfrog")
                if lunarfrog then
                    lunarfrog.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst:Remove()
                    return true
                end
            end
        end
        -- 其他情况不进行转变
        return false
    end)
end)

AddPrefabPostInit("spider", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("hauntable")
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE
    
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        -- 检查作祟者是否是wilisha
        if haunter and haunter:HasTag("wilisha") then
            -- wilisha作祟时有25%几率转变为月蛙
            if math.random() < 0.25 then
                local spider_moon = SpawnPrefab("spider_moon")
                if spider_moon then
                    spider_moon.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst:Remove()
                    return true
                end
            end
        end
        -- 其他情况不进行转变
        return false
    end)
end)

AddPrefabPostInit("carrot", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("hauntable")
    
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        -- 检查作祟者是否是wilisha
        if haunter and haunter:HasTag("wilisha") then
            -- wilisha作祟时有10%几率转变为月鼠
            if math.random() <= TUNING.HAUNT_CHANCE_RARE then
                local carrot_moon = SpawnPrefab("carrat")
                if carrot_moon then
                    carrot_moon.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    
                    -- 处理堆叠问题：只减少一个胡萝卜
                    if inst.components.stackable and inst.components.stackable:StackSize() > 1 then
                        inst.components.stackable:Get():Remove()
                    else
                        inst:Remove()
                    end
                    return true
                end
            end
        end
        -- 其他情况不进行转变
        return false
    end)
end)

AddPrefabPostInit("tentacle", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("hauntable")
    
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        -- 检查作祟者是否是wilisha
        if haunter and haunter:HasTag("wilisha") then
            -- wilisha作祟时有0.1%几率转变为亮茄触手
            if math.random() < 1 then
                local tentacle_moon = SpawnPrefab("wilisha_lunarplanttentacle")
                if tentacle_moon then
                    tentacle_moon.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst.components.hauntable.hauntvalue = TUNING.HAUNT_HUGE
                    inst:Remove()
                    return true
                end
            end
        end
        -- 其他情况不进行转变
        return false
    end)
end)