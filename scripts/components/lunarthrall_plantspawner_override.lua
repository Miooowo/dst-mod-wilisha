-- 虚影植物生成器覆盖版本
-- 优先选择被wilisha采集过的植物进行寄生

-- 重写FindWildPatch函数，优先选择被wilisha采集过的植物
local function FindWildPatchOverride(self)
    local tries = {}
    
    while #tries < 10 do
        local plants = {}
        local wilisha_plants = {} -- 被wilisha采集过的植物
        
        local pt = TheWorld.Map:FindRandomPointOnLand(40)
        if pt then
            -- 寻找植物
            local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 20, {"plant", "lunarplant_target"})
            for i, ent in ipairs(ents) do
                if not ent.lunarthrall_plant then
                    -- 检查是否被wilisha采集过
                    if ent:HasTag("wilisha_harvested") then
                        table.insert(wilisha_plants, ent)
                    else
                        table.insert(plants, ent)
                    end
                end
            end
        end
        
        -- 优先选择被wilisha采集过的植物
        local final_plants = {}
        for i, plant in ipairs(wilisha_plants) do
            table.insert(final_plants, plant)
        end
        for i, plant in ipairs(plants) do
            table.insert(final_plants, plant)
        end
        
        table.insert(tries, final_plants)
    end

    local top = 0
    local choice = nil
    for i,try in ipairs(tries)do
        if #try > top then
            choice = i
            top = #try
        end
    end
    if choice then
        return tries[choice]
    end
end

-- 重写FindHerd函数，优先选择被wilisha采集过的植物
local function FindHerdOverride(self)
    local choices = {}
    for i, herd in ipairs(self.plantherds)do
        table.insert(choices,herd)
    end

    local num = 0
    local choice = {}
    for i, herd in ipairs(choices)do
        local count = 0
        local wilisha_count = 0 -- 被wilisha采集过的植物数量
        
        for member, i in pairs(herd.components.herd.members) do
            local pt = Vector3(member.Transform:GetWorldPosition())
            local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 30, {"lunarthrall_plant"})
            if #ents <= 0 then
                if not member.lunarthrall_plant and
                    (not member.components.witherable or not member.components.witherable:IsWithered()) then
                    count = count + 1
                    -- 检查是否被wilisha采集过
                    if member:HasTag("wilisha_harvested") then
                        wilisha_count = wilisha_count + 1
                    end
                end
            end
        end

        if count > 0 then
            -- 优先选择有被wilisha采集过植物的群组
            local priority_score = count + (wilisha_count * 2) -- 被wilisha采集过的植物权重更高
            table.insert(choice,{herd=herd, count=count, wilisha_count=wilisha_count, priority_score=priority_score}) 
        end
    end

    -- 按优先级分数排序
    table.sort(choice, function(a,b) return a.priority_score > b.priority_score end)

    if #choice > 0 then
        return choice[math.random(1,math.min(5, #choice))].herd
    end
end

-- 在游戏启动后覆盖虚影植物生成器的函数
AddComponentPostInit("lunarthrall_plantspawner", function(self)
    -- 覆盖FindWildPatch函数
    self.FindWildPatch = FindWildPatchOverride
    -- 覆盖FindHerd函数
    self.FindHerd = FindHerdOverride
end)
