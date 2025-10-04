local modid = 'role_wilisha'
local trade_data = require('core_role_wilisha/data/trade')

---@type data_componentaction[]
local data = {
    -- 官方的三个组件的修理, finiteuses armor fueled, 给一堆物品时, 尽可能多的消耗物品来修理, 具体数据只需填进 `TUNING.MOD_ROLE_WILISHA.REPAIR_COMMON`, 此处逻辑不用动
    {
        id = 'ACTION_ROLE_WILISHA_COMMON_REPAIR',
        str = STRINGS.MOD_ROLE_WILISHA.ACTIONS.ACTION_ROLE_WILISHA_COMMON_REPAIR,
        fn = function (act)
            local doer,item,target = act.doer,act.invobject,act.target
            if doer and item and target and doer:IsValid() and item:IsValid() and target:IsValid() then
                local compo = TUNING.MOD_ROLE_WILISHA.REPAIR_COMMON[target.prefab].type
                local repair_percent = item.prefab and TUNING.MOD_ROLE_WILISHA.REPAIR_COMMON[target.prefab].repair_percent[item.prefab]
                local cur_percent = target.components[compo] and target.components[compo]:GetPercent()
                if repair_percent and cur_percent then
                    if doer and doer.SoundEmitter then
                        local prefab = item.prefab
                        local sound = (prefab == 'nightmarefuel' or prefab == 'horrorfuel') and 'dontstarve/common/nightmareAddFuel' or 'aqol/new_test/metal'
                        doer.SoundEmitter:PlaySound(sound)
                    end

                    local new_percent = math.min(1,cur_percent + repair_percent)
                    target.components[compo]:SetPercent(new_percent)
                    SUGAR_role_wilisha:consumeOneItem(item)

                    while item and item:IsValid() and (target.components[compo]:GetPercent() + repair_percent) <= 1 do
                        local _cur_percent = target.components[compo]:GetPercent()
                        local _new_percent = math.min(1,_cur_percent + repair_percent)
                        target.components[compo]:SetPercent(_new_percent)
                        SUGAR_role_wilisha:consumeOneItem(item)
                    end

                    if target:HasTag(target.prefab..'_nodurability') then
                        target:RemoveTag(target.prefab..'_nodurability')
                    end
                    return true
                end
            end
            return false
        end,
        state = 'give',
        actiondata = {
            mount_valid = true,
            priority = 5,
        },
        type = "USEITEM",
        component = 'inventoryitem',
        testfn_type_USEITEM = function (inst, doer, target, actions, right)
            if right and doer:HasTag("player") and target.prefab and TUNING.MOD_ROLE_WILISHA.REPAIR_COMMON[target.prefab] then
                local canrepair = inst and inst.prefab and TUNING.MOD_ROLE_WILISHA.REPAIR_COMMON[target.prefab].repair_percent[inst.prefab]
                if canrepair then
                    return true
                end
            end
            return false
        end
    },
    {
        id = 'ACTION_ROLE_WILISHA_TRADE',
        str = function (act)
            local _tar,_item = act.target,act.invobject
            local _tbl = _item and _tar and trade_data.map[_tar.prefab] and trade_data.map[_tar.prefab][_item.prefab]
            local _str = _tbl and _tbl.str or STRINGS.MOD_ROLE_WILISHA.ACTIONS.ACTION_ROLE_WILISHA_TRADE
            return _str
        end,
        fn = function (act)
            local target,item,doer = act.target,act.invobject,act.doer
            if target and item and doer and target:IsValid() and item:IsValid() and doer:IsValid() then
                local fixed = trade_data.map[target.prefab] and trade_data.map[target.prefab][item.prefab] or nil
                local testfn_server = fixed and fixed.testfn_server or nil
                if testfn_server and not testfn_server(item,target,doer) then
                    return false
                end
                if target.components.role_wilisha_trader then
                    return target.components.role_wilisha_trader:AddOne(item,doer)
                end
            end
            return false
        end,
        state = function (inst, act)
            local _tar,_item = act.target,act.invobject
            local _tbl = _item and _tar and trade_data.map[_tar.prefab] and trade_data.map[_tar.prefab][_item.prefab]
            local sg = _tbl and _tbl.state or 'give'
            return sg
        end,
        actiondata = {
            mount_valid = true,
            priority = 7,
        },
        type = "USEITEM",
        component = 'role_wilisha_tradeable',
        testfn_type_USEITEM = function (inst, doer, target, actions, right)
            local fixed = trade_data.map[target.prefab] and trade_data.map[target.prefab][inst.prefab] or nil
            if fixed and target.replica.role_wilisha_trader then
                local i,max = fixed.index,fixed.max
                local testfn = fixed.testfn
                local res_testfn = true
                if testfn and not testfn(inst,target,doer) then res_testfn = false end
                return not target.replica.role_wilisha_trader:IsMax(i,max) and res_testfn
            end
            return false
        end
    },
}

---@type data_componentaction_change[]
local change = {

}

return data,change