---@diagnostic disable: lowercase-global, undefined-global, trailing-space

---@class api_componentaction # 组件动作 API
local dst_lan = {}

---comment
---@param data_tbl data_componentaction[]
---@return table # actions
---@return table # componentactions table
---@private
function dst_lan:_fix_tbl(data_tbl)
    local fixed_actions = {}
    local fixed_component_actions = {}

    for _,item in pairs(data_tbl) do
        local pal = item.type .. item.component
        if fixed_component_actions[pal] == nil then
            fixed_component_actions[pal] = {
                type = item.type,
		        component = item.component,
                tests = {
                    {
                        action = item.id,
                        testfn = item['testfn_type_'..item.type],
                    },
                },
            }
        else
            table.insert(fixed_component_actions[pal].tests,{
                action = item.id,
                testfn = item['testfn_type_'..item.type],
            })
        end
        table.insert(fixed_actions,{
            id = item.id,
            str = item.str,
            fn = item.fn,
            state = item.state,
            actiondata = item.actiondata,
        })
    end
    return fixed_actions,fixed_component_actions
end

---@param data_tbl data_componentaction[]
---@private
function dst_lan:registActions(data_tbl)
    local fixed_actions,fixed_component_actions = self:_fix_tbl(data_tbl)

    for _,act in pairs(fixed_actions) do
        local addaction = AddAction(act.id,type(act.str) == 'string' and act.str or 'Missing ComponnetAction Name',act.fn)
        if act.actiondata then
            for k,v in pairs(act.actiondata) do
                addaction[k] = v
            end
        end
        if type(act.str) == 'function' then
            ---@diagnostic disable-next-line: inject-field
            addaction.stroverridefn = act.str
        end

        AddStategraphActionHandler('wilson',ActionHandler(addaction, type(act.state) == 'string' and act.state or act.state))
        AddStategraphActionHandler('wilson_client',ActionHandler(addaction, type(act.state) == 'string' and act.state or act.state))
    end

    for _,v in pairs(fixed_component_actions) do
        local testfn = function(...)
            local actions = GLOBAL.select(v.type=='POINT' and -3 or -2,...)
            for _,data in pairs(v.tests) do
                if data and data.testfn and data.testfn(...) then
                    data.action = string.upper(data.action)
                    table.insert(actions,GLOBAL.ACTIONS[data.action])
                end
            end
        end
        AddComponentAction(v.type, v.component, testfn)
    end
end

---修改官方组件动作的testfn
---@param change_tbl data_componentaction_change[]
---@private
function dst_lan:changeComponentActionTestfn(change_tbl)
    for _,tbl in ipairs(change_tbl) do
        local data = SUGAR_role_wilisha:upvalueFind(EntityScript.CollectActions,'COMPONENT_ACTIONS')
        if data then
            local old_fn = data[tbl.type][tbl.component]
            data[tbl.type][tbl.component] = function(...)
                return tbl.testfn(old_fn,...)
            end
        end
    end
end

---主函数
---@param data_tbl data_componentaction[] # 组件动作表
---@param change_tbl data_componentaction_change[]|nil # 修改官方组件动作的testfn
function dst_lan:main(data_tbl,change_tbl)
    self:registActions(data_tbl)
    if change_tbl then
        self:changeComponentActionTestfn(change_tbl)
    end
end

return dst_lan