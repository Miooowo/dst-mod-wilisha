local trade_data = require('core_role_wilisha/data/trade')

---@class replica_components
---@field role_wilisha_trader replica_role_wilisha_trader # 不用管我(这个组件是为 通用交易 功能服务的 )

---@class replica_role_wilisha_trader
---@field inst ent
---@field val netvar
---@field item_nums table<integer,integer>
local role_wilisha_trader = Class(
---@param self replica_role_wilisha_trader
---@param inst ent
function(self, inst)
    self.inst = inst
    self.val = net_string(inst.GUID, "role_wilisha_trader.val",'role_wilisha_trader_val_change')
    self.item_nums = {}
    self.inst:ListenForEvent('role_wilisha_trader_val_change',function (this, data)
        for i,v in ipairs(self:decode(self.val:value() or '')) do
            self.item_nums[i] = v
        end
    end)
end)

---comment
---@param encoded_str string
---@param separator '|'|nil
---@return number[]
---@nodiscard
function role_wilisha_trader:decode(encoded_str, separator)
    local parts = {}
    for part in string.gmatch(encoded_str, "[^" .. (separator or '|') .. "]+") do
        table.insert(parts, tonumber(part))
    end
    return parts
end

---comment
---@param index integer
---@param max integer|nil # 允许没有最大值
function role_wilisha_trader:IsMax(index,max)
    if max then
        return (self.item_nums[index] or 0) >= max
    end
    return false
end

---获取某个物品的当前数量
---@param prefab PrefabID
---@return integer
---@nodiscard
function role_wilisha_trader:GetCurrentNum(prefab)
    local index = trade_data.map[self.inst.prefab][prefab].index
    return self.item_nums[index] or 0
end

return role_wilisha_trader