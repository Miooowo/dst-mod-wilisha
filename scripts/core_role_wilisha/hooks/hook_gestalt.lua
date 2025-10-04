AddPrefabPostInit("gestalt", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    if inst.components.combat ~= nil then
        local old_retargetfn = inst.components.combat.targetfn

        inst.components.combat:SetRetargetFunction(1, function(inst)
            -- 先跑一遍原版的逻辑
            local target = old_retargetfn ~= nil and old_retargetfn(inst) or nil

            -- 加我们的过滤：有 "gestaltimmune" tag 的就无效
            if target ~= nil and target:HasTag("wilisha") then
                return nil
            end

            return target
        end)
    end
end)
    
AddPrefabPostInit("gestalt_guard", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    if inst.components.combat ~= nil then
        local old_retargetfn = inst.components.combat.targetfn

        inst.components.combat:SetRetargetFunction(1, function(inst)
            local target, changetarget = nil, false
            if old_retargetfn ~= nil then
                target, changetarget = old_retargetfn(inst)
            end

            -- 过滤掉有免疫 tag 的玩家
            if target ~= nil and target:HasTag("wilisha") then
                return nil, false
            end

            return target, changetarget
        end)
    end
end)

