---@class components
---@field role_wilisha_tradeable component_role_wilisha_tradeable # 不用管我(这个组件是为 通用交易 功能服务的 )

---@class component_role_wilisha_tradeable
---@field inst ent
local role_wilisha_tradeable = Class(
---@param self component_role_wilisha_tradeable
---@param inst ent
function(self, inst)
    self.inst = inst
end,
nil,
{
})

return role_wilisha_tradeable