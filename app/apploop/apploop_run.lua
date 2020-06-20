
local AppLoopRun = Class()

function AppLoopRun:_init()

end

function AppLoopRun:_delete()

end

function AppLoopRun:StateEnter()
	print("AppLoopRun")
	app.Game.Start()
end

function AppLoopRun:StateUpdate(now_time, elapse_time)
	app.Game.Update(now_time, elapse_time)
end

function AppLoopRun:StateQuit()
	app.Game.Stop()
	app.Game = nil
end

return AppLoopRun
