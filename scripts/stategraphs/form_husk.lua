--编写者：alt
--功能介绍：写新的sg
--使用方法：直接粘贴 修改sglist
--写新的sg
--Call this when exiting a "keep_pocket_rummage" state

local function OwnsPocketRummageContainer(inst, item)
	local owner = item.components.inventoryitem and item.components.inventoryitem:GetGrandOwner() or nil
	if owner == inst then
		return true
	end
	local mount = inst.components.rider and inst.components.rider:GetMount() or nil
	if owner == mount or item == mount then
		return true
	end
end
local function TryResumePocketRummage(inst)
	local item = inst.sg.mem.pocket_rummage_item
	if item then
		if item.components.container and
			item.components.container:IsOpenedBy(inst) and
			OwnsPocketRummageContainer(inst, item)
		then
			inst.sg.statemem.keep_pocket_rummage_mem_onexit = true
			inst.sg:GoToState("start_pocket_rummage", item)
			return true
		end
		inst.sg.mem.pocket_rummage_item = nil
	end
	return false
end
local function SetPocketRummageMem(inst, item)
	inst.sg.mem.pocket_rummage_item = item
end
local function IsHoldingPocketRummageActionItem(holder, item)
	local owner = item.components.inventoryitem and item.components.inventoryitem.owner or nil
	return owner == holder
		or (	--Allow linked containers like woby's rack	
				owner.components.inventoryitem == nil and
				owner.entity:GetParent() == holder
			)
end
local function ClosePocketRummageMem(inst, item)
	if item == nil then
		item = inst.sg.mem.pocket_rummage_item
	elseif item ~= inst.sg.mem.pocket_rummage_item then
		return
	end
	if item then
		inst.sg.mem.pocket_rummage_item = nil

		if OwnsPocketRummageContainer(inst, item) and item.components.container then
			item.components.container:Close(inst)
		end
	end
end
local function CheckPocketRummageMem(inst)
	local item = inst.sg.mem.pocket_rummage_item
	if item then
		if not (item.components.container and
				item.components.container:IsOpenedBy(inst) and
				OwnsPocketRummageContainer(inst, item))
		then
			SetPocketRummageMem(inst, nil)
		else
			local stayopen = inst.sg.statemem.keep_pocket_rummage_mem_onexit
			if not stayopen and inst.sg.statemem.is_going_to_action_state then
				local buffaction = inst:GetBufferedAction()
				if buffaction and
					(	buffaction.action == ACTIONS.BUILD or
						(buffaction.action == ACTIONS.DROP and buffaction.invobject ~= item) or
						(buffaction.invobject and IsHoldingPocketRummageActionItem(item, buffaction.invobject))
					)
				then
					stayopen = true
				end
			end
			if not stayopen then
				ClosePocketRummageMem(inst)
			end
		end
	end
end
local sglist = {
    --[[ name = {
        tags = { "nopredict" },
        onenter = function(inst, data)
            inst.sg:SetTimeout(1)
        end,
        ontimeout = function(inst)
        end,
         timeline =
        {
        },
        onupdate = function(inst)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    --inst.sg:GoToState("bugnet")
                end
            end),
        },
        onexit = function(inst)
        end,
    }, ]]
    form_husk = {
		tags = { "doing", "busy", "nocraftinginterrupt", "nomorph", "keep_pocket_rummage" },

		onenter = function(inst, product)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("form_log_pre")
			inst.AnimState:PushAnimation("form_log", false)
			if product == nil or product == "husk" then
				inst.sg.statemem.islog = true
				inst.AnimState:OverrideSymbol("wood_splinter", "wood_splinter_brightshade", "wood_splinter_brightshade")
            elseif product == "log" then
                inst.AnimState:OverrideSymbol("wood_splinter", "player_wormwood", "wood_splinter")
			else
				inst.AnimState:OverrideSymbol("wood_splinter", "wormwood_skills_fx", "wood_splinter_"..product)
			end
			inst.sg.statemem.action = inst.bufferedaction
		end,

		timeline =
		{
			FrameEvent(0, function(inst)
				if not inst.sg.statemem.islog then
					inst.SoundEmitter:PlaySound("meta2/wormwood/armchop_f0")
				end
			end),
			FrameEvent(2, function(inst)
				if inst.sg.statemem.islog then
					inst.SoundEmitter:PlaySound("dontstarve/characters/wormwood/living_log_craft")
				end
			end),
			FrameEvent(40, function(inst)
				if not inst.sg.statemem.islog then
					inst.SoundEmitter:PlaySound("meta2/wormwood/armchop_f40")
				end
			end),
			FrameEvent(50, function(inst)
				inst:PerformBufferedAction()
			end),
			FrameEvent(58, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			FrameEvent(62, TryResumePocketRummage),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if inst.bufferedaction == inst.sg.statemem.action and
					(not inst.components.playercontroller or
					inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
				inst:ClearBufferedAction()
			end
			inst.AnimState:ClearOverrideSymbol("wood_splinter")
			CheckPocketRummageMem(inst)
		end,
	},
}
for name, data in pairs(sglist) do
    AddStategraphState("wilson", State {
        name = name,
        tags = data.tags or {},
        onenter = data.onenter,
        ontimeout = data.ontimeout,
        onupdate = data.onupdate,
        events = data.events,
        onexit = data.onexit,
        timeline = data.timeline,
    })
end
