
local AppLoopCompareFileList = Class()

function AppLoopCompareFileList:_init()

end

function AppLoopCompareFileList:_delete()

end

function AppLoopCompareFileList:StateEnter()
	print("AppLoopCompareFileList")
	local filelist = app.ServiceCtrl.instance:GetFileList()
	local pos = string.find(filelist, '\n', 0)
	local seed = string.sub(filelist, 0, pos - 1)
	global.UserDefault:SetInt("Seed", tonumber(seed))
	
	app.ServiceCtrl.instance:StartCompareFileList(filelist)
end

function AppLoopCompareFileList:StateUpdate(now_time, elapse_time)
	if app.ServiceCtrl.instance:IsCompareFileListFinish() then
		app.AppLoop.instance:ChangeState(app.AppLoop.State.UpdateRes)
	end
end

function AppLoopCompareFileList:StateQuit()
	app.ServiceCtrl.instance:StopCompareFileList()
end

return AppLoopCompareFileList
