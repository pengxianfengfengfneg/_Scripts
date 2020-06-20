
local GameLoopSDKLogin = Class()

function GameLoopSDKLogin:_init()

end

function GameLoopSDKLogin:_delete()

end

function GameLoopSDKLogin:StateEnter()
	print("GameLoopSDKLogin")
	game.GameMsgCtrl.instance:OpenWaitingView(8)
	
	self.is_sdk_ret = false
	self.is_sdk_login = false 
	if game.AccountInfo.is_login then
		-- 已登录
		game.GameLoop:ChangeState(game.GameLoop.State.GetServerInfo)
	else
		-- 未登录
		self.sdk_ev = global.EventMgr:Bind(game.SDKEvent.SDKStatusChange, function(ev, param)
			if ev == game.SDKEventName.LoginSuccess then
				self.is_sdk_ret = true
			end
		end)
	end
end

function GameLoopSDKLogin:StateUpdate(now_time, elapse_time)
	if not self.is_sdk_login then
		self.is_sdk_login = true
		game.SDKMgr:Login()
	end
	if self.is_sdk_ret then
		self.is_sdk_ret = false
		game.GameLoop:ChangeState(game.GameLoop.State.GetServerInfo)
	end
end

function GameLoopSDKLogin:StateQuit()
	if self.sdk_ev then
		global.EventMgr:UnBind(self.sdk_ev)
		self.sdk_ev = nil
	end
	game.GameMsgCtrl.instance:CloseWaitingView()
end

return GameLoopSDKLogin
