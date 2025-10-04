---@class components
---@field role_wilisha_ent_bind component_role_wilisha_ent_bind # 实体绑定1对多,双方都需添加该组件,主人需要调用`InitMaster`

---@class component_role_wilisha_ent_bind
---@field inst ent
---@field ismaster boolean|nil # 是 master 还是 child
---@field uid string|nil # uid 自动在必要的时间点生成
---@field master_pid string|nil # 一般设置为 master 的 prefab id 即可
---@field _field string|nil # 用于实体绑定的 TUNING 中的字段
local role_wilisha_ent_bind = Class(
---@param self component_role_wilisha_ent_bind
---@param inst ent
function(self, inst)
    self.inst = inst
    self.ismaster = nil
    self.uid = nil
    self.master_pid = nil

    self._field = nil
end,
nil,
{
})

function role_wilisha_ent_bind:OnSave()
    local sav = {
        ismaster = self.ismaster,
        uid = self.uid,
    }
    if not self.ismaster then -- 只有child才要存,因为master初始化时,有这些数据. 但其实孩子也可以避免存,不过不想这样做,所以还是存吧
        sav.master_pid = self.master_pid
        sav._field = self._field
    end
    return sav
end

function role_wilisha_ent_bind:OnLoad(data)
    self.ismaster = data.ismaster
    self.uid = data.uid
    if not self.ismaster then
        self.master_pid = data.master_pid
        self._field = data._field
    end

    -- 当加载时,把自己添加到全局临时表里
    self:_putMeOnTempTable()
end

---(仅主人调用)为主人添加一个孩子
---@param id string # 用于生成uid, 一般填主人的prefabID即可
---@param field_in_tuning string # 为实体绑定 提供一个TUNING中的表所在的字段
function role_wilisha_ent_bind:InitMaster(id,field_in_tuning)
    self.ismaster = true
    self.master_pid = id

    self._field = field_in_tuning
end

---(仅主人调用)为主人添加一个孩子
---@param child ent
function role_wilisha_ent_bind:AddOneChild(child)
    -- 确保uid
    self:_genUID()
    -- 将自己挂到全局
    self:_putMeOnTempTable()
    -- 将生成好的孩子进行绑定
    child.components.role_wilisha_ent_bind.ismaster = false
    child.components.role_wilisha_ent_bind.master_pid = self.master_pid
    child.components.role_wilisha_ent_bind.uid = self.uid
    child.components.role_wilisha_ent_bind._field = self._field
    child.components.role_wilisha_ent_bind:_putMeOnTempTable()
end

---生成uid, master_pid + timestamp, 仅第一次生成,后续不变
---@private
function role_wilisha_ent_bind:_genUID()
    -- 确保uid
    if self.uid == nil then
        self.uid = self.master_pid..tostring(os.clock())
    end
end

---确保临时全局表存在
---@private
function role_wilisha_ent_bind:_makesureTempTable()
    if TUNING[self._field] == nil then
        TUNING[self._field] = {}
    end
    if TUNING[self._field].bind == nil then
        TUNING[self._field].bind = {}
    end
    if TUNING[self._field].bind[self.master_pid] == nil then
        TUNING[self._field].bind[self.master_pid] = {}
    end
    if TUNING[self._field].bind[self.master_pid][self.uid] == nil then
        TUNING[self._field].bind[self.master_pid][self.uid] = {}
    end
    if TUNING[self._field].bind[self.master_pid][self.uid].childs == nil then
        TUNING[self._field].bind[self.master_pid][self.uid].childs = {}
    end
end

---把我自己挂到临时全局表上
---@private
function role_wilisha_ent_bind:_putMeOnTempTable()
    -- 仅当有uid, 即有child时, 才会把双方添加到临时表
    self:_makesureTempTable()
    if self.ismaster then
        TUNING[self._field].bind[self.master_pid][self.uid].parent = self.inst
    else
        table.insert(TUNING[self._field].bind[self.master_pid][self.uid].childs, self.inst)
    end
end

---获取主人(应当由孩子调用)
---@return ent|nil
---@nodiscard
function role_wilisha_ent_bind:GetMaster()
    if not self.ismaster and self.uid then
        return TUNING[self._field] and TUNING[self._field].bind and TUNING[self._field].bind[self.master_pid] and TUNING[self._field].bind[self.master_pid][self.uid] and TUNING[self._field].bind[self.master_pid][self.uid].parent or nil
    end
    return nil
end

---获取孩子(应当由主人调用)
---@return ent[]|nil
---@nodiscard
function role_wilisha_ent_bind:GetChilds()
    if self.ismaster and self.uid then
        return TUNING[self._field] and TUNING[self._field].bind and TUNING[self._field].bind[self.master_pid] and TUNING[self._field].bind[self.master_pid][self.uid] and TUNING[self._field].bind[self.master_pid][self.uid].childs or nil
    end
    return nil
end

---移除所有孩子
function role_wilisha_ent_bind:RemoveAllChilds()
    assert(self.ismaster, "RemoveAllChilds() should only be called by master")
    for _,v in pairs(self:GetChilds() or {}) do
        if v:IsValid() then
            v:Remove()
        end
    end
    if TUNING[self._field] and TUNING[self._field].bind and TUNING[self._field].bind[self.master_pid] and TUNING[self._field].bind[self.master_pid][self.uid] then
        TUNING[self._field].bind[self.master_pid][self.uid].childs = {}
    end
end

---是否至少有一个孩子
---@return boolean
function role_wilisha_ent_bind:HasValidChild()
    assert(self.ismaster, "HasValidChild() should only be called by master")
    for _,v in pairs(self:GetChilds() or {}) do
        if v:IsValid() then
            return true
        end
    end
    return false
end

return role_wilisha_ent_bind