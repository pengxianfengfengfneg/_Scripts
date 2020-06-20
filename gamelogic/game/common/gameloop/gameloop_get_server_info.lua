
local GameLoopGetServerInfo = Class()

function GameLoopGetServerInfo:_init()

end

function GameLoopGetServerInfo:_delete()

end

function GameLoopGetServerInfo:StateEnter()
	print("GameLoopGetServerInfo")
	self.retry_count = 1
	self.wait_request = true

	game.LoginCtrl.instance:SetLoginEnable(false)
	game.GameMsgCtrl.instance:OpenWaitingView()

	local callback = function(success, data)
		if not self.wait_request then
			return
		end

		if success and data and data ~= "" then
			local json_data = N3DClient.JsonConverter.ParseJsonToLua(data)
			if json_data then
				if json_data.info == 1 then
					game.LoginCtrl.instance:SetServerTime(json_data.data.time)
					game.LoginCtrl.instance:SetIsWhiteList(json_data.data.is_white)
					game.LoginCtrl.instance:SetZoneList(json_data.data.zone_list)
					game.LoginCtrl.instance:SetServerList(json_data.data.server_list)
					game.LoginCtrl.instance:SetPersonList(json_data.data.person_list)
                    game.AccountInfo.disable_recharge = N3DClient.GameConfig.GetServerConfig("is_pay") == "0" 

                    if not game.LoginCtrl.instance:GetData():GetLastServerInfo() then
						local log_server_id = global.UserDefault:GetInt("LastLoginServer")
						if log_server_id ~= 0 then
							game.LoginCtrl.instance:GetData():SetLastServerID(log_server_id)
						end
					end

					game.GameLoop:ChangeState(game.GameLoop.State.SelectServer)
					return
				elseif json_data.info == -7 then
					local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1000], json_data.data)
					msg_box:SetOkBtn(function()
						msg_box:Close()
						msg_box:DeleteMe()
						game.GameLoop:ChangeState(game.GameLoop.State.GetServerInfo)
					end)
					msg_box:Open()
					return
				end
			end
		end

		self.retry_count = self.retry_count + 1
		if self.retry_count < 1 then
			self:SendGetServerListReq(callback)
		else
			game.GameNet:OpenDisconnectView(function()
				game.GameLoop:ChangeState(game.GameLoop.State.GetServerInfo)
			end)
		end
	end
	self:SendGetServerListReq(callback)
end

function GameLoopGetServerInfo:StateUpdate(now_time, elapse_time)
	
end

function GameLoopGetServerInfo:StateQuit()
	self.wait_request = false
	game.GameMsgCtrl.instance:CloseWaitingView()
end

function GameLoopGetServerInfo:SendGetServerListReq(callback)
	game.ServiceMgr:RequestServerList(game.AccountInfo.account, function(status, data)
		callback(status, data)
	end)
end

return GameLoopGetServerInfo
