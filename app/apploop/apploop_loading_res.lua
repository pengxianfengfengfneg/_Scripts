
local AppLoopLoadingRes = Class()

function AppLoopLoadingRes:_init()

end

function AppLoopLoadingRes:_delete()

end

function AppLoopLoadingRes:StateEnter()
	print("AppLoopLoadingRes")
	app.InitCtrl.instance:SetLoadingTxt(app.words[5])
	app.InitCtrl.instance:SetLoadingValue(0)
	
	app.Game.Init()
	app.Game.Preload()

	self.cur_value = 0
end

function AppLoopLoadingRes:StateUpdate(now_time, elapse_time)
	local is_finish, percent = app.Game.UpdatePreload()
	if self.cur_value < percent then
		self.cur_value = math.min(self.cur_value + 3, percent)
	end
	if is_finish then
		app.InitCtrl.instance:SetLoadingValue(percent)
		app.AppLoop.instance:ChangeState(app.AppLoop.State.Run)
	else
		app.InitCtrl.instance:SetLoadingValue(self.cur_value)
	end
end

function AppLoopLoadingRes:StateQuit()

end

return AppLoopLoadingRes
