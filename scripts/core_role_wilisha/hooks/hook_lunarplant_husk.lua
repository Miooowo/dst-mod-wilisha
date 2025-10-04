-- 亮茄外壳种植功能钩子
-- 为亮茄外壳添加可种植成致命亮茄的功能

-- 假设亮茄外壳的prefab名称是 "lunarplant_husk"
-- 如果实际名称不同，请修改这里的prefab名称

local function AddMove(inst)
    local function OnDeploy (inst, pt)
        GLOBAL.SpawnPrefab("lunarthrall_plant").Transform:SetPosition(pt.x, pt.y, pt.z)
        inst.components.stackable:Get():Remove()
    end
    inst:AddTag("deployedplant")
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = OnDeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
	inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)
end
AddPrefabPostInit("lunarplant_husk", AddMove)

-- 如果亮茄外壳有其他名称，也可以添加其他名称的钩子
-- 常见的可能名称：
-- AddPrefabPostInit("lunarthrall_plant_husk", function(inst) ... end)
-- AddPrefabPostInit("lunarplant_husk", function(inst) ... end)
-- AddPrefabPostInit("lunarthrall_husk", function(inst) ... end)
