
local GameLoopLogin = Class()

function GameLoopLogin:_init()

end

function GameLoopLogin:_delete()

end

function GameLoopLogin:StateEnter()
	print("GameLoopLogin")
	game.LoginCtrl.instance:SendRoleLoginCheck()

	self.ev_list = {
		global.EventMgr:Bind(game.LoginEvent.LoginRoleRet, function(val)
			if val then
				local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1002], config.words[1003])
				msg_box._ui_order = game.UIZOrder.UIZOrder_Top
				msg_box:SetOkBtn(function()
					msg_box:Close()
					msg_box:DeleteMe()
					game.GameLoop:ChangeState(game.GameLoop.State.Start)
				end)
				msg_box:Open()
			else
				game.LoginCtrl.instance:SendGetRoleListReq()
			end
		end),
		global.EventMgr:Bind(game.LoginEvent.LoginRoleListRet, function(role_list)
			--是否有角色,没有角色进入创建角色界面,有角色进入选择角色界面
			if #role_list > 0 then
				game.GameLoop:ChangeState(game.GameLoop.State.SelectRole)
			else
				game.GameLoop:ChangeState(game.GameLoop.State.CreateRole)
			end
		end)
	}
end

function GameLoopLogin:StateUpdate(now_time, elapse_time)

end

function GameLoopLogin:StateQuit()
	for i,v in ipairs(self.ev_list) do
	 	global.EventMgr:UnBind(v)
	end 
	self.ev_list = nil
end

return GameLoopLogin