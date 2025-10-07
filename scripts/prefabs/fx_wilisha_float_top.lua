---@diagnostic disable: undefined-global, inject-field
local assets =
{
    Asset("ANIM", "anim/float_top.zip"),
}

local function Update(inst)
	local parent = inst.entity:GetParent()
    if parent then
	    local facing = parent.AnimState:GetCurrentFacing()
        if facing == FACING_UP then --FACING_DOWN
            inst:Hide()
        else
            inst:Show()

        end
	end
end
local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.Transform:SetFourFaced()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()
    
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    
    inst.AnimState:SetBank("float_top")
    inst.AnimState:SetBuild("float_top")
    inst.AnimState:PlayAnimation("float_top", true)
    
    -- 设置初始透明度为0（不可见）
    inst.AnimState:SetMultColour(1, 1, 1, 0.6)
    inst.AnimState:SetLightOverride(0.2)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    
    if not TheNet:IsDedicated() then
        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddPostUpdateFn(Update)
    end

    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.persists = false
    
    -- 朝向检测和透明度更新函数
    -- local function UpdateFacing(inst, parent)
    --     if not parent or not parent.Transform then
    --         return
    --     end
        
    --     local parent_facing = parent.Transform:GetRotation()
    --     local camera_facing = TheCamera:GetHeading()
        
    --     -- 计算朝向差异
    --     local angle_diff = parent_facing - camera_facing
        
    --     -- 标准化角度到 -180 到 180 范围
    --     while angle_diff > 180 do
    --         angle_diff = angle_diff - 360
    --     end
    --     while angle_diff < -180 do
    --         angle_diff = angle_diff + 360
    --     end
        
    --     -- 在DST中，当人物面向摄像机时，angle_diff应该接近0
    --     -- 当人物背对摄像机时，angle_diff应该接近±180
    --     -- 当人物侧对摄像机时，angle_diff应该接近±90
        
    --     local abs_angle_diff = math.abs(angle_diff)
        
    --     -- 调试信息（可以删除）
    --     -- print("Parent facing:", parent_facing, "Camera facing:", camera_facing, "Angle diff:", angle_diff, "Abs diff:", abs_angle_diff)
        
    --     -- 只在正面（-45度到45度范围内）显示
    --     -- 修正：使用更严格的角度范围，确保只在真正正面时显示
    --     if abs_angle_diff <= 180 then
    --         inst.AnimState:SetMultColour(1, 1, 1, 1)  -- 正面，完全可见
    --     else
    --         inst.AnimState:SetMultColour(1, 1, 1, 0)  -- 其他方向，完全透明
    --     end
    -- end
    
    -- -- 设置朝向更新函数
    -- inst.UpdateFacing = UpdateFacing
    
    return inst
end

return Prefab("fx_wilisha_float_top", fn, assets)
