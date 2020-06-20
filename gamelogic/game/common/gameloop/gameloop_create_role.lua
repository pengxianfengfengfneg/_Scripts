
local GameLoopCreateRole = Class()

function GameLoopCreateRole:_init()

end

function GameLoopCreateRole:_delete()

end

function GameLoopCreateRole:StateEnter()
	print("GameLoopCreateRole")
	game.RenderUnit:SetUICameraClearColor(false)
	if game.LoginCtrl.instance:IsLoginSceneLoaded() then
		game.LoginCtrl.instance:OpenCreateRoleView()
		game.LoginCtrl.instance:CloseLoginView()
	else
		game.GameMsgCtrl.instance:OpenWaitingView()
		self.is_loading_map = true
	end

	self.ev = global.EventMgr:Bind(game.LoginEvent.LoginRoleRet, function(val)
		if val then
			game.GameLoop:ChangeState(game.GameLoop.State.LoginSuccess)
		else
			game.GameLoop:ChangeState(game.GameLoop.State.SelectServer)
		end
	end)
end

function GameLoopCreateRole:StateUpdate(now_time, elapse_time)
	if game.LoginCtrl.instance:IsCreateViewOpen() then
		game.LoginCtrl.instance:UpdateCreateView(now_time, elapse_time)
	end
	if game.LoginCtrl.instance:IsLoginSceneLoaded() and self.is_loading_map then
		self.is_loading_map = false
		game.GameMsgCtrl.instance:CloseWaitingView()
		game.LoginCtrl.instance:OpenCreateRoleView()
		game.LoginCtrl.instance:CloseLoginView()
	end
end

function GameLoopCreateRole:StateQuit()
	global.EventMgr:UnBind(self.ev)
	self.ev = nil
	game.LoginCtrl.instance:CloseCreateRoleView()
	game.RenderUnit:SetUICameraClearColor(true)
	self.is_loading_map = nil
end

return GameLoopCreateRole