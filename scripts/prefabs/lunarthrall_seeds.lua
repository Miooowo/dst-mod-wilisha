require "prefabs/veggies"
require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/wilisha_lunarplant_seeds.zip"),
    Asset("ANIM", "anim/oceanfishing_lure_mis.zip"),

    Asset("ATLAS", "images/inventoryimages/lunarplant_seeds.xml"),
    Asset("IMAGE", "images/inventoryimages/lunarplant_seeds.tex"),
}

local prefabs =
{
    "seeds_cooked",
    "spoiled_food",
}

local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS
for k, v in pairs(WEED_DEFS) do
    if v.seed_weight ~= nil and v.seed_weight > 0 then
        table.insert(prefabs, k)
    end
end

local function common(anim, cookable, oceanfishing_lure)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wilisha_lunarplant_seeds")
    inst.AnimState:SetBuild("wilisha_lunarplant_seeds")
    inst.AnimState:PlayAnimation(anim, true)
    inst.AnimState:SetRayTestOnBB(true)

    inst.pickupsound = "vegetation_firm"

    if cookable then
        inst:AddTag("deployedplant")
        -- inst:AddTag("deployedfarmplant")

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    if oceanfishing_lure then
        inst:AddTag("oceanfishing_lure")
    end

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lunarplant_seeds"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/lunarplant_seeds.xml"
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.SEEDS

    if cookable then
        inst:AddComponent("cookable")
        inst.components.cookable.product = "seeds_cooked"
    end

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("snowmandecor")

    return inst
end
local function OnDeploy(inst, pt)
    SpawnPrefab("lunarthrall_plant").Transform:SetPosition(pt.x, pt.y, pt.z)
    inst.components.stackable:Get():Remove()
end

local function raw()
    local inst = common("idle", true, true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY / 2

    inst:AddComponent("bait")

    inst:AddComponent("oceanfishingtackle")
    inst.components.oceanfishingtackle:SetupLure({ build = "oceanfishing_lure_mis", symbol = "hook_seeds", single_use = true, lure_data =
    TUNING.OCEANFISHING_LURE.SEED })

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = OnDeploy
    inst.components.deployable.restrictedtag = "lunarthrall_plant"
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)

    return inst
end

local function cooked()
    local inst = common("cooked")

    inst.components.floater:SetScale(0.8)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY / 2
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

local function update_seed_placer_outline(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:CanTillSoilAtPoint(x, y, z) then
        local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(x, y, z)
        inst.outline.Transform:SetPosition(cx, cy, cz)
        inst.outline:Show()
    else
        inst.outline:Hide()
    end
end

local function seed_placer_postinit(inst)
    inst.outline = SpawnPrefab("tile_outline")

    inst.outline.Transform:SetPosition(2, 0, 0)
    inst.outline:ListenForEvent("onremove", function() inst.outline:Remove() end, inst)
    inst.outline.AnimState:SetAddColour(.25, .75, .25, 0)
    inst.outline:Hide()

    inst.components.placer.onupdatetransform = update_seed_placer_outline
end

return Prefab("lunarplant_seeds", raw, assets, prefabs),
    Prefab("seeds_cooked", cooked, assets),
    MakePlacer("lunarplant_seeds_placer", "lunarthrall_plant", "lunarthrall_plant_front", "scrapbook")
