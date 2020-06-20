
local GameLoopStart = Class()

function GameLoopStart:_init()

end

function GameLoopStart:_delete()

end

function GameLoopStart:StateEnter()
	print("GameLoopStart")
	game.ServiceMgr:Start()
	game.SDKMgr:Start()

	global.AssetLoader:SetMaxTaskNum(5)
	game.GameMsgCtrl.instance:OpenMsgView()
	game.LoginCtrl.instance:OpenLoginView()
	game.FightCtrl.instance:OpenSceneView()
	game.FightCtrl.instance:OpenFightView()
	game.GameLoop:Reset()

	game.RenderUnit:SetUICameraClearColor(true)
end

function GameLoopStart:StateUpdate(now_time, elapse_time)
	if game.LoginCtrl.instance:IsLoginViewOpen() then
		app.InitCtrl.instance:CloseView()
		app.InitCtrl.instance:UnloadInitRes()
		game.LoginCtrl.instance:InitLoginScene()
		if game.__DEBUG__ then
			local accname = global.UserDefault:GetString("Account")
			if accname ~= "" then
				game.GameLoop:ChangeState(game.GameLoop.State.SDKLogin)
			end
		else
			game.GameLoop:ChangeState(game.GameLoop.State.SDKLogin)
		end
	end
end

function GameLoopStart:StateQuit()

end

return GameLoopStart
