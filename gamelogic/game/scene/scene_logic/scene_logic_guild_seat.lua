local SceneLogicGuildSeat = Class(require("game/scene/scene_logic/scene_logic_base"))

local handler = handler
local event_mgr = global.EventMgr

local carry_npc_id = config.carry_common.carry_npc
local max_carry_times = config.carry_common.carry_times

function SceneLogicGuildSeat:_init(scene)
	self.scene = scene
end

function SceneLogicGuildSeat:_delete()

end

function SceneLogicGuildSeat:OnStartScene()
	self.side_info_view = game.GuildCtrl.instance:OpenGuildSeatView()
	game.MainUICtrl.instance:SwitchToFighting()

	self:RegisterAllEvents()
end

function SceneLogicGuildSeat:StopScene()
	if game.GuildCtrl.instance then
		game.GuildCtrl.instance:CloseGuildSeatView()
	end
	self.side_info_view = nil

	self:UnRegisterAllEvents()
end

function SceneLogicGuildSeat:RegisterAllEvents()
	local events = {
		{game.GuildEvent.YunbiaoStateChange, handler(self,self.OnYunbiaoStateChange)},
	}
	self.ev_list = {}
	for _,v in ipairs(events) do
		local ev = event_mgr:Bind(v[1],v[2])
		table.insert(self.ev_list, ev)
	end
end

function SceneLogicGuildSeat:UnRegisterAllEvents()
	for _,v in ipairs(self.ev_list or {}) do
		event_mgr:UnBind(v)
	end
	self.ev_list = nil
end

function SceneLogicGuildSeat:CreateNpc(vo)
	local npc = SceneLogicGuildSeat.super.CreateNpc(self, vo)

	local carry_npc = carry_npc_id
	if npc:GetNpcId() == carry_npc then

		npc:SetAoiEnterListener(function()
			local is_act_open = game.ActivityMgrCtrl.instance:IsActOpened(game.ActivityId.GuildCarry)
			if is_act_open then
				local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData()
				if yunbiao_data and yunbiao_data.carry_times<max_carry_times then
					local state = yunbiao_data.stat
					npc:SetTaskStateFlag(state+1)
				end
			end
		end)

		npc:SetNpcClickCallback(function(npc_obj)
			
			local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData()
			if yunbiao_data then
				if yunbiao_data.stat > 0 then
					game.GuildCtrl.instance:OpenGuildYunbiaoRewardView()
					return
				end
			end

			local npc_id = npc_obj:GetNpcId()
			global.EventMgr:Fire(game.SceneEvent.ClickNpc, npc_id, npc_obj:GetUnitPosXY())
		end)

	end

	return npc
end

function SceneLogicGuildSeat:OnYunbiaoStateChange(from_state, to_state)
	local carry_npc = carry_npc_id
	local npc = self.scene:GetNpc(carry_npc)
	if npc then
		local is_act_open = game.ActivityMgrCtrl.instance:IsActOpened(game.ActivityId.GuildCarry)
		if is_act_open then
			local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData()
			local state = yunbiao_data.stat +1
			if yunbiao_data.carry_times >= max_carry_times then
				state = 0
			end
			npc:SetTaskStateFlag(state)

			if from_state==2 and to_state==0 then
				npc:DoClick()
			end

			if from_state==0 and to_state==1 then
		        local main_role = game.Scene.instance:GetMainRole()
		        main_role:GetOperateMgr():DoHangTask(game.DailyTaskId.YunbiaoTask)
		    end
		end
	end
end

function SceneLogicGuildSeat:IsShowLogicExit()
	return true
end

function SceneLogicGuildSeat:DoSceneLogicExit()
	if not game.RoleCtrl.instance:CanTransformChangeScene(self.main_role, true) then
		return false
	end
	if self.main_role:GetCurStateID() == game.ObjState.Practice then
		game.GameMsgCtrl.instance:PushMsg(config.words[4769])
		return false
	end
	game.GuildCtrl.instance:SendGuildLeaveSeat()
end

function SceneLogicGuildSeat:IsShowLogicTaskCom()
	return self.side_info_view:GetOpenActView() == nil
end

function SceneLogicGuildSeat:SetTaskComVisible(val)
	game.MainUICtrl.instance:SetShowTaskCom(val)
end

function SceneLogicGuildSeat:CanDoCrossOperate()
	
	return true
end

return SceneLogicGuildSeat
