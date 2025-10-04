---@class replica_components
---@field event_trigger_role_wilisha replica_event_trigger_role_wilisha

---@class replica_event_trigger_role_wilisha
---@field inst ent
---@field event_name netvar
---@field type netvar
---@field trigger netvar
local event_trigger_role_wilisha = Class(
---@param self replica_event_trigger_role_wilisha
---@param inst ent
function(self, inst)
    self.inst = inst
    self.event_name = net_string(inst.GUID, "event_trigger_role_wilisha.event_name")
    self.type = net_string(inst.GUID, "event_trigger_role_wilisha.type")
    self.trigger = net_bool(inst.GUID, "event_trigger_role_wilisha.trigger",'event_trigger_role_wilisha_triggered')
end)

function event_trigger_role_wilisha:SetEventName(event_name)
    self.event_name:set(event_name)
end

function event_trigger_role_wilisha:GetEventName()
    return self.event_name:value()
end

function event_trigger_role_wilisha:SetType(type)
    self.type:set(type)
end

function event_trigger_role_wilisha:GetType()
    return self.type:value()
end

function event_trigger_role_wilisha:Trigger(value)
    return self.trigger:set(value)
end

return event_trigger_role_wilisha