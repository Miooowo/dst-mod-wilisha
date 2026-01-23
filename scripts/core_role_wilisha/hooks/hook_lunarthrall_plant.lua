-- 让致命亮茄能够攻击对 wilisha 具有敌意的生物

-- 查找附近的 wilisha 玩家
local function FindNearbyWilisha(inst, range)
    range = range or 30
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = TheSim:FindEntities(x, y, z, range, { "player" })
    for _, player in ipairs(players) do
        if player:HasTag("wilisha") and player:IsValid() then
            return player
        end
    end
    return nil
end

-- 检查生物是否对 wilisha 有敌意
local function IsHostileToWilisha(ent, wilisha)
    if ent == nil or wilisha == nil then
        return false
    end
    
    -- 检查该生物是否以 wilisha 为攻击目标（最直接的敌意判断）
    if ent.components.combat ~= nil and ent.components.combat.target == wilisha then
        return true
    end
    
    -- 检查生物是否具有攻击性标签
    -- 如果生物是怪物或敌对生物，且距离wilisha较近，认为有敌意
    if (ent:HasTag("monster") or ent:HasTag("hostile")) and ent.components.combat ~= nil then
        local x1, y1, z1 = ent.Transform:GetWorldPosition()
        local x2, y2, z2 = wilisha.Transform:GetWorldPosition()
        local dx, dy, dz = x1 - x2, y1 - y2, z1 - z2
        local distsq = dx * dx + dy * dy + dz * dz
        -- 如果距离在20单位内，认为有敌意
        if distsq <= 20 * 20 then
            return true
        end
    end
    
    return false
end

-- 修改致命亮茄的仇恨机制
AddPrefabPostInit("lunarthrall_plant", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    
    if inst.components.combat == nil then
        return
    end
    
    -- 保存原版的Retarget函数
    local old_retargetfn = inst.components.combat.targetfn
    
    -- 设置新的Retarget函数
    inst.components.combat:SetRetargetFunction(1, function(inst)
        -- 优先检查附近是否有对 wilisha 有敌意的生物
        local wilisha = FindNearbyWilisha(inst, 30)
        if wilisha ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            
            -- 使用原版的查找逻辑，但添加对wilisha敌意的检查
            local PLANT_MUST = {"lunarthrall_plant"}
            local TARGET_MUST_TAGS = { "_combat", "character" }
            local TARGET_CANT_TAGS = { "INLIMBO","lunarthrall_plant", "lunarthrall_plant_end" }
            
            local target = FindEntity(
                inst,
                TUNING.LUNARTHRALL_PLANT_RANGE,
                function(guy)
                    -- 首先检查是否对wilisha有敌意
                    if not IsHostileToWilisha(guy, wilisha) then
                        return false
                    end
                    
                    -- 然后使用原版的检查逻辑
                    local total = 0
                    local x, y, z = inst.Transform:GetWorldPosition()
                    
                    if inst.tired then
                        return false
                    end
                    
                    local plants = TheSim:FindEntities(x, y, z, 15, PLANT_MUST)
                    for i, plant in ipairs(plants) do
                        if plant ~= inst then
                            if plant.components.combat.target and plant.components.combat.target == guy then
                                total = total + 1
                            end
                        end
                    end
                    if total < 3 then
                        return inst.components.combat:CanTarget(guy)
                    end
                    return false
                end,
                TARGET_MUST_TAGS,
                TARGET_CANT_TAGS
            )
            
            -- 如果找到对wilisha有敌意的目标，使用原版的生成钻地藤蔓逻辑
            if target and inst.vinelimit and inst.vinelimit > 0 then
                if not inst.components.freezable or not inst.components.freezable:IsFrozen() then
                    local pos = inst:GetPosition()
                    local theta = math.random() * TWOPI
                    local radius = TUNING.LUNARTHRALL_PLANT_MOVEDIST
                    local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
                    pos = pos + offset
                    
                    if TheWorld.Map:IsVisualGroundAtPoint(pos.x, pos.y, pos.z) then
                        local vine = SpawnPrefab("lunarthrall_plant_vine_end")
                        if vine ~= nil then
                            vine.Transform:SetPosition(pos.x, pos.y, pos.z)
                            vine.Transform:SetRotation(inst:GetAngleToPoint(pos.x, pos.y, pos.z))
                            if vine.components.freezable ~= nil then
                                vine.components.freezable:SetRedirectFn(function(vine, ...)
                                    local inst = vine.parentplant
                                    if inst ~= nil and inst:IsValid() then
                                        inst.components.freezable:AddColdness(...)
                                        return true
                                    end
                                    return false
                                end)
                            end
                            if vine.sg ~= nil then
                                vine.sg:RemoveStateTag("nub")
                            end
                            if inst.tintcolor then
                                vine.AnimState:SetMultColour(inst.tintcolor, inst.tintcolor, inst.tintcolor, 1)
                                vine.tintcolor = inst.tintcolor
                            end
                            
                            if inst.components.colouradder ~= nil then
                                inst.components.colouradder:AttachChild(vine)
                            end
                            vine.parentplant = inst
                            if inst.vines ~= nil then
                                table.insert(inst.vines, vine)
                            end
                            if inst.vinelimit ~= nil then
                                inst.vinelimit = inst.vinelimit - 1
                            end
                            if vine.ChooseAction ~= nil then
                                inst:DoTaskInTime(0, function() vine:ChooseAction() end)
                            end
                            
                            return target
                        end
                    end
                end
            end
            
            -- 如果找到目标但没有生成钻地藤蔓，直接返回目标
            if target then
                return target
            end
        end
        
        -- 如果没找到对 wilisha 有敌意的生物，使用原版逻辑
        if old_retargetfn ~= nil then
            return old_retargetfn(inst)
        end
        return nil
    end)
end)

-- 添加对钻地藤蔓的支持
AddPrefabPostInit("lunarthrall_plant_vine_end", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    
    if inst.components.combat == nil then
        return
    end
    
    -- 钻地藤蔓也会优先攻击对wilisha有敌意的生物
    local old_retargetfn = inst.components.combat.targetfn
    
    inst.components.combat:SetRetargetFunction(1, function(inst)
        -- 优先检查附近是否有对 wilisha 有敌意的生物
        local wilisha = FindNearbyWilisha(inst, 30)
        if wilisha ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, TUNING.LUNARTHRALL_PLANT_RANGE or 15, { "_combat", "character" }, { "INLIMBO", "lunarthrall_plant", "lunarthrall_plant_end" })
            
            for _, ent in ipairs(ents) do
                if ent ~= inst 
                    and ent:IsValid()
                    and ent.entity:IsVisible()
                    and ent.components.health ~= nil
                    and not ent.components.health:IsDead()
                    and IsHostileToWilisha(ent, wilisha)
                    and inst.components.combat:CanTarget(ent) then
                    return ent
                end
            end
        end
        
        -- 如果没找到对 wilisha 有敌意的生物，使用原版逻辑
        if old_retargetfn ~= nil then
            return old_retargetfn(inst)
        end
        return nil
    end)
end)
