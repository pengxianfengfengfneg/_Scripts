
local GameLoopSelectRole = Class()

function GameLoopSelectRole:_init()

end

function GameLoopSelectRole:_delete()

end

function GameLoopSelectRole:StateEnter()
	print("GameLoopSelectRole")
	game.RenderUnit:SetUICameraClearColor(false)
	if game.LoginCtrl.instance:IsLoginSceneLoaded() then
		game.LoginCtrl.instance:OpenSelectRoleView()
		game.LoginCtrl.instance:CloseLoginView()
	else
		game.GameMsgCtrl.instance:OpenWaitingView()
		self.is_loading_map = true
	end

	self.ev = global.EventMgr:Bind(game.LoginEvent.LoginRoleRet, function(val)
		if val then
			game.GameLoop:ChangeState(game.GameLoop.State.LoginSuccess)
		else
			game.LoginCtrl.instance:SetSelectRoleEnable(true)
		end
	end)
end

function GameLoopSelectRole:StateUpdate(now_time, elapse_time)
	if game.LoginCtrl.instance:IsSelectRoleViewOpen() then
		game.LoginCtrl.instance:UpdateSelectRoleView(now_time, elapse_time)
	end
	if game.LoginCtrl.instance:IsLoginSceneLoaded() and self.is_loading_map then
		self.is_loading_map = false
		game.LoginCtrl.instance:OpenSelectRoleView()
		game.GameMsgCtrl.instance:CloseWaitingView()
		game.LoginCtrl.instance:CloseLoginView()
	end
end

function GameLoopSelectRole:StateQuit()
	global.EventMgr:UnBind(self.ev)
	self.ev = nil
	game.LoginCtrl.instance:CloseSelectRoleView()
	game.RenderUnit:SetUICameraClearColor(true)
	self.is_loading_map = nil
end

return GameLoopSelectRole