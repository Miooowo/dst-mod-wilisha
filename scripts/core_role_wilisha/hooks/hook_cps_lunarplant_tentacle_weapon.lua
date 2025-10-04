AddComponentPostInit("lunarplant_tentacle_weapon", function(self)
    if not TheWorld.ismastersim then
        return inst
    end
    -- 保存原始的条件判断函数
    local original_condition = self.should_do_tentacles_fn
    
    -- 创建新的条件判断函数
    self.should_do_tentacles_fn = function(inst, owner, attack_data)
        -- 原有的wormwood技能树判断
        if original_condition and original_condition(inst, owner, attack_data) then
            return true
        end
        
        -- 新增判断：如果角色是wilisha则也触发触手
        if owner and owner.prefab == "wilisha" then
            return true
        end
        
        return false
    end
end)