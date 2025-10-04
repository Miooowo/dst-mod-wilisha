---@type SourceModifierList
local SourceModifierList = require("util/sourcemodifierlist")

---@class components
---@field role_wilisha_addequiptag component_role_wilisha_addequiptag # 这个组件是为一些可进库存的非装备物品添加装备的tag时,也能让owner有装备时的效果,例如夜视 护目镜等, 这个组件要在 `inventoryitem` 后添加

---@source ../core_role_wilisha/managers/misc.lua:6 
local _______see -- ctrl + 左键 点我快速跳转至 managers 中查看所需要做的其他事

-- 方法不止一种, 我写着玩的, 你也可以勾equiphastag,然后遍历物品栏,再模拟一次装备

---@class component_role_wilisha_addequiptag
---@field inst ent
---@field equipslot string|nil
---@field tags tagID[]|nil
local role_wilisha_addequiptag = Class(
---@param self component_role_wilisha_addequiptag
---@param inst ent
function(self, inst)
    self.inst = inst
    self.equipslot = nil
    self.tags = nil
end,
nil,
{
})

---comment
---@param assign_new_equipslot string # 分配一个新的equipslot,需要自己事先创建 <br> 虽然equipslots有上限,但 我们可以用相同的槽位, 例如在可以在 `modmain` 添加 `EQUIPSLOTS.EXTRA_VOIDEQUIP = 'extra_voidequip'`
---@param tags_autoactive_when_putininv tagID[]|nil # 这个参数填了是一个预设的功能, 当这件物品进入物品栏时, 就会给角色触发添加的tag, 当丢下时, 则自动移除tag <br> 如果不填,则需要自己手动写逻辑
function role_wilisha_addequiptag:Init(assign_new_equipslot,tags_autoactive_when_putininv)
    self.equipslot = assign_new_equipslot

    if tags_autoactive_when_putininv then
        self.tags = tags_autoactive_when_putininv
        local _owner = nil
        local old_ondropfn = self.inst.components.inventoryitem.ondropfn
        function self.inst.components.inventoryitem.ondropfn(this,...)
            self:RemoveTags(_owner,self.tags)
            _owner = nil
            return old_ondropfn ~= nil and old_ondropfn(this,...) or nil
        end
        local old_onputininventoryfn = self.inst.components.inventoryitem.onputininventoryfn
        function self.inst.components.inventoryitem.onputininventoryfn(this,owner,...)
            _owner = owner
            self:AddTags(_owner,self.tags)
            return old_onputininventoryfn ~= nil and old_onputininventoryfn(this,owner,...) or nil
        end
    end
end

---comment
---@return ent_role_wilisha_addequiptag
---@nodiscard
---@private
function role_wilisha_addequiptag:_createVoidEquip()
    ---@class ent_role_wilisha_addequiptag : ent
    ---@field tags_map table<tagID,SourceModifierList>

    local wp = SpawnPrefab('spear')
    ---@cast wp ent_role_wilisha_addequiptag
    wp:AddTag('NOCLICK')
    wp:AddTag('NOBLOCK')
    wp:AddTag('nosteal')
    wp:AddTag('hide_percentage')
    wp.components.equippable.onequipfn = nil
    wp.components.equippable.onunequipfn = nil
    wp.AnimState:SetMultColour(1,1,1,0)
    wp.components.equippable.equipslot = self.equipslot
    wp.components.inventoryitem:ChangeImageName('xxxxx')
    wp.tags_map = {}
    wp.persists = false
    return wp
end

---comment
---@param player ent|nil
---@param newtags tagID[]
function role_wilisha_addequiptag:AddTags(player,newtags)
    assert(self.equipslot ~= nil, 'Component role_wilisha_addequiptag: Please call the Init method to assign a new equipslot first !')
    player = player or ( self.inst.components.inventoryitem and self.inst.components.inventoryitem:GetGrandOwner() ) or nil
    if player and player:HasTag('player') then
        -- 获取当前装备的所有有用的tag
        local old = player.components.inventory:GetEquippedItem(self.equipslot)
        ---@cast old ent_role_wilisha_addequiptag
        -- 移除旧装备 生成新装备 数据传输 添加tag 并刷新装备状态
        local new = self:_createVoidEquip()
        if old and old:IsValid() then
            for k,v in pairs(old.tags_map) do
                new.tags_map[k] = SourceModifierList(new, false, SourceModifierList.boolean)
                for src_ent,v2 in pairs(v._modifiers or {}) do                    
                    for key,modifier_val in pairs(v2.modifiers or {}) do
                        new.tags_map[k]:SetModifier(src_ent, modifier_val, key)
                    end
                end
            end
            old:Remove()
        end
        old = nil
        for _,tag in ipairs(newtags) do
            if new.tags_map[tag] == nil or not new.tags_map[tag]:Get() then
                new.tags_map[tag] = nil
                new.tags_map[tag] = SourceModifierList(new, false, SourceModifierList.boolean)
            end
            new.tags_map[tag]:SetModifier(self.inst,true,'dst_lan')
            new:AddTag(tag)
        end
        player.components.inventory:Equip(new,nil,true)
    end
end

---comment
---@param player ent|nil
---@param newtags tagID[]
function role_wilisha_addequiptag:RemoveTags(player,newtags)
    player = player or ( self.inst.components.inventoryitem and self.inst.components.inventoryitem:GetGrandOwner() ) or nil
    if player and player:HasTag('player') then
        -- 获取当前装备的所有有用的tag
        local old = player.components.inventory:GetEquippedItem(self.equipslot)
        ---@cast old ent_role_wilisha_addequiptag
        -- 移除旧装备 生成新装备 数据传输 添加tag 并刷新装备状态
        local new = self:_createVoidEquip()
        if old and old:IsValid() then
            for k,v in pairs(old.tags_map) do
                new.tags_map[k] = SourceModifierList(new, false, SourceModifierList.boolean)
                for src_ent,v2 in pairs(v._modifiers or {}) do
                    for key,modifier_val in pairs(v2.modifiers or {}) do
                        new.tags_map[k]:SetModifier(src_ent, modifier_val, key)
                    end
                end
            end
            -- new.tags_map = deepcopy(old.tags_map) or {}
            old:Remove()
        end
        old = nil
        for _,tag in ipairs(newtags) do
            if new.tags_map[tag] == nil then
                new:RemoveTag(tag)
            else
                if not new.tags_map[tag]:Get() then
                    new.tags_map[tag] = nil
                    new:RemoveTag(tag)
                else
                    new.tags_map[tag]:RemoveModifier(self.inst,'dst_lan')
                    if not new.tags_map[tag]:Get() then
                        new.tags_map[tag] = nil
                        new:RemoveTag(tag)
                    else
                        new:AddTag(tag)
                    end
                end
            end
        end
        player.components.inventory:Equip(new,nil,true)
    end
end

return role_wilisha_addequiptag