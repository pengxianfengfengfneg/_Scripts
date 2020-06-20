
local GameLoopRestart = Class()

function GameLoopRestart:_init()

end

function GameLoopRestart:_delete()

end

function GameLoopRestart:StateEnter()
	game.SDKMgr:SendSDKData(5)
	game.GameNet.instance:Restart()
	game.ModuleMgr:StopAllModule()
	game.GamePool:ClearGamePool()
	game.CacheMgr:UnloadUnuseCache()
    global.AssetLoader:UnLoadUnuseBundle()
end

function GameLoopRestart:StateUpdate(now_time, elapse_time)
	game.GamePool:CreateGamePool()
	game.ModuleMgr:StartAllModule()
	game.GameLoop:ChangeState(game.GameLoop.State.Start)
end

function GameLoopRestart:StateQuit()
	collectgarbage("collect")
	N3DClient.GameTool.RunGC()
end

return GameLoopRestart