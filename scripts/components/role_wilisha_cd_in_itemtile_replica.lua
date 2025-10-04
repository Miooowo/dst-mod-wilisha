---@class replica_components
---@field role_wilisha_cd_in_itemtile replica_role_wilisha_cd_in_itemtile

---@class replica_role_wilisha_cd_in_itemtile
---@field inst ent
---@field cur_cd netvar
---@field _show_itemtile netvar
local role_wilisha_cd_in_itemtile = Class(
---@param self replica_role_wilisha_cd_in_itemtile
---@param inst ent
function(self, inst)
    self.inst = inst
    self.cur_cd = net_byte(inst.GUID, "role_wilisha_cd_in_itemtile.cur_cd",'role_wilisha_cd_in_itemtile_cur_cd_change')

    self._show_itemtile = net_bool(inst.GUID, "role_wilisha_cd_in_itemtile._show_itemtile")
end)

function role_wilisha_cd_in_itemtile:SetCurCD(num)
    self.cur_cd:set(num)
end

function role_wilisha_cd_in_itemtile:GetCurCD()
    return self.cur_cd:value()
end

---是否显示在itemtile上
---@return boolean
---@nodiscard
function role_wilisha_cd_in_itemtile:ShouldShown()
    local res = self._show_itemtile:value() and true or false
    return res
end

---是否在cd中
---@return boolean
---@nodiscard
function role_wilisha_cd_in_itemtile:IsCD()
    return (self.cur_cd:value() or 0) > 0
end

return role_wilisha_cd_in_itemtile