
local GameLoopPlay = Class()

function GameLoopPlay:_init()

end

function GameLoopPlay:_delete()

end

function GameLoopPlay:StateEnter(is_reconnect)
	game.LoginCtrl.instance:ClearLoginRes()
	
	global.AssetLoader:SetMaxTaskNum(2)
	game.RenderUnit:SetUICameraClearColor(false)
	self.scene = game.ModuleMgr:GetModule("scene")

	-- 初始化语音
	game.VoiceMgr:InitEngine()

    game.GameNet:SetDiconnectCallback(function()
		if game.GameNet:CanReconnect() then
			game.GameLoop:ChangeState(game.GameLoop.State.Reconnect)
		else
			game.GameNet:OpenDisconnectView(function()
				game.GameLoop:ChangeState(game.GameLoop.State.Restart)
			end)
		end
	end)

    if not is_reconnect then
		self.scene:StartScene()
		global.EventMgr:Fire(game.GameEvent.StartPlay, self.scene:GetSceneID())
	end
end

function GameLoopPlay:StateUpdate(now_time, elapse_time)
	self.scene:Update(now_time, elapse_time)
end

function GameLoopPlay:StateQuit(next_state)
	game.GameNet:SetDiconnectCallback()
	global.AssetLoader:SetMaxTaskNum(5)
	game.RenderUnit:SetUICameraClearColor(true)
	
	if next_state ~= game.GameLoop.State.Reconnect then
		self.scene:StopScene()
		global.EventMgr:Fire(game.GameEvent.StopPlay)
	end
end

return GameLoopPlay
