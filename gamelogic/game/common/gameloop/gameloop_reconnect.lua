
local GameLoopReconnect = Class()

function GameLoopReconnect:_init()

end

function GameLoopReconnect:_delete()

end

function GameLoopReconnect:StateEnter()
	self.state = 1
	self.delta_time = 0
	game.RenderUnit:SetUICameraClearColor(false)

	game.GameMsgCtrl.instance:OpenWaitingView()
    game.FightCtrl.instance:CloseReviveView()
end

function GameLoopReconnect:StateUpdate(now_time, elapse_time)
	if self.state == 1 then
		self.delta_time = self.delta_time + elapse_time
		if self.delta_time > 1.5 then
			self.state = self.state + 1
		end
	elseif self.state == 2 then
		if not game.GameNet:IsGameNetConnect() then
			local server_info = game.LoginCtrl.instance:GetLoginServerInfo()
			game.GameNet:ConnectGameNetAsyn(server_info.game_ip, server_info.game_port, 8000)
		end	
		self.state = self.state + 1
	elseif self.state == 3 then
		if game.GameNet:IsGameNetConnect() then
			self.state = self.state + 1
		end
	elseif self.state == 4 then
		game.LoginCtrl.instance:SendRoleLoginCheck()

		self:ClearEvent()
		self.ev = global.EventMgr:Bind(game.LoginEvent.LoginCheckResult, function(res, cur_login)
			if res == 0 then
				if cur_login == 0 then
					game.GameNet:DisconnectGameNet(true)
				else
					self.state = self.state + 1
					self.reconnect_role_id = cur_login
					game.LoginCtrl.instance:SendRoleReloginReq(1)
				end
			else
				game.GameNet:DisconnectGameNet(true)
			end
		end)
		self.state = self.state + 1
	elseif self.state == 6 then
		game.LoginCtrl.instance:SendGetRoleListReq()

		self:ClearEvent()
		self.ev = global.EventMgr:Bind(game.LoginEvent.LoginRoleListRet, function(role_list)
			if #role_list > 0 then
				self.state = self.state + 1
			else
				game.GameNet:DisconnectGameNet(true)
			end
		end)
		self.state = self.state + 1
	elseif self.state == 8 then
		game.LoginCtrl.instance:SendSelectRoleLogin(self.reconnect_role_id)

		self:ClearEvent()
		self.ev = global.EventMgr:Bind(game.LoginEvent.LoginRoleRet, function(val)
			if val then
				self.state = self.state + 1
			else
				game.GameNet:DisconnectGameNet(true)
			end
		end)
		self.state = self.state + 1
	elseif self.state == 10 then
		global.EventMgr:Fire(game.LoginEvent.LoginSuccess)
		game.Scene.instance:SendRoleEnterSceneInfoReq()

		self:ClearEvent()
		self.ev = global.EventMgr:Bind(game.LoginEvent.LoginReconnectRet, function(data_list)
			if game.Scene.instance:GetSceneID() == data_list.scene_id then
                local main_role = game.Scene.instance:GetMainRole()
                if main_role and main_role.uniq_id == self.reconnect_role_id then
					game.Scene.instance:ResetMainRole()
				    self.state = self.state + 1
				    return
				end
			end

			game.Scene.instance:StopScene()
			game.Scene.instance:ChangeToLoading(data_list)
			self.state = self.state + 1
		end)
		self.state = self.state + 1
	elseif self.state == 12 then
		self:ClearEvent()
		game.Scene.instance:OnReconnect()
		game.Scene.instance:SendSceneInfoReq()
		global.EventMgr:Fire(game.LoginEvent.LoginReconnectFinish)
		game.GameLoop:ChangeState(game.GameLoop.State.Play, true)
	end
end

function GameLoopReconnect:ClearEvent()
	if self.ev then
		global.EventMgr:UnBind(self.ev)
		self.ev = nil
	end
end

function GameLoopReconnect:StateQuit()
	game.RenderUnit:SetUICameraClearColor(true)
	game.GameMsgCtrl.instance:CloseWaitingView()
	self:ClearEvent()
end

return GameLoopReconnect
