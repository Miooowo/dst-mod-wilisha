-- 亮茄外壳可部署组件
-- 让亮茄外壳可以部署成致命亮茄

local LunarplantHuskDeployable = Class(function(self, inst)
    self.inst = inst
    self.deploy_distance = 1.5 -- 部署距离
    self.deploy_radius = 1.0 -- 部署半径
    self.plant_prefab = "lunarthrall_plant" -- 部署后生成的植物prefab
end)

function LunarplantHuskDeployable:CanDeploy(pt, mouseover, deployer)
    if not pt then
        return false
    end
    
    local x, y, z = pt.x, pt.y, pt.z
    
    -- 检查是否在陆地上
    if TheWorld.Map:IsOceanAtPoint(x, y, z) then
        return false
    end
    
    -- 检查位置是否可通行
    if not TheWorld.Map:IsPassableAtPoint(x, y, z) then
        return false
    end
    
    -- 检查附近是否有其他植物
    local ents = TheSim:FindEntities(x, y, z, self.deploy_radius, {"plant", "lunarthrall_plant"})
    if #ents > 0 then
        return false
    end
    
    return true
end

function LunarplantHuskDeployable:Deploy(pt, deployer)
    if not pt then
        return false
    end
    
    local can_deploy = self:CanDeploy(pt, nil, deployer)
    if not can_deploy then
        if deployer and deployer.components.talker then
            deployer.components.talker:Say("无法在此位置种植")
        end
        return false
    end
    
    -- 创建致命亮茄
    local plant = SpawnPrefab(self.plant_prefab)
    if plant then
        plant.Transform:SetPosition(pt.x, pt.y, pt.z)
        
        -- 播放种植音效
        if deployer and deployer.SoundEmitter then
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
        
        -- 消耗亮茄外壳
        if self.inst.components.stackable and self.inst.components.stackable:StackSize() > 1 then
            self.inst.components.stackable:Get():Remove()
        else
            self.inst:Remove()
        end
        
        return true
    end
    
    return false
end

return LunarplantHuskDeployable
