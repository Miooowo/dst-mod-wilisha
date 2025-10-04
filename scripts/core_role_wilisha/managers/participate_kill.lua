-- hide
-- 功能(无需修改): 联合击杀(参与击杀), 判断生物死亡时, 某个玩家有没有贡献伤害(参与战斗)

-- 参与击杀的人会推 `killed_role_wilisha_participate` 事件, 亲手击杀的还是监听 `killed`

---@class ent
---@field _role_wilisha_participate_kill_tbl table<ent, boolean> # 联合击杀贡献表

---@class event_data_killed_role_wilisha_participate
---@field victim ent
---@field attacker ent

AddComponentPostInit('combat',
---comment
---@param self component_combat
function (self)
    local old_GetAttacked = self.GetAttacked
    function self:GetAttacked(attacker,damage,weapon,stimuli,spdamage,...)
        local victim = self.inst
        if attacker and attacker:IsValid() then
            if victim._role_wilisha_participate_kill_tbl == nil then
                victim._role_wilisha_participate_kill_tbl = {}
            end
            victim._role_wilisha_participate_kill_tbl[attacker] = true
        end
        return old_GetAttacked ~= nil and old_GetAttacked(self,attacker,damage,weapon,stimuli,spdamage,...) or nil
    end
end)

AddComponentPostInit("health",
---comment
---@param self component_health
function(self)
    local old_SetVal = self.SetVal
    function self:SetVal(val,cause,afflicter,...)
        local res = old_SetVal ~= nil and {old_SetVal(self,val,cause,afflicter,...)} or {}
        local victim = self.inst
        if self:IsDead() then
            if victim and victim._role_wilisha_participate_kill_tbl then
                for attacker,_ in pairs(victim._role_wilisha_participate_kill_tbl) do
                    if attacker and attacker:IsValid() then
                        if afflicter and afflicter ~= attacker then
                            attacker:PushEvent('killed_role_wilisha_participate', { victim = self.inst, attacker = attacker })
                        end
                    end
                end
            end
        end
        return unpack(res)
    end
end)