
local AppLoopGetFileList = Class()

function AppLoopGetFileList:_init()

end

function AppLoopGetFileList:_delete()

end

function AppLoopGetFileList:StateEnter()
	print("AppLoopGetFileList")

	app.InitCtrl.instance:SetLoadingTxt(app.words[6])
	app.InitCtrl.instance:SetLoadingValue(0)

	local db_new_version = global.UserDefault:GetInt("NewResVersion")
	local cur_new_version = app.ServiceCtrl.instance:GetNewVersion()
	if db_new_version == cur_new_version then
		local filelist = global.UserDefault:GetString("NewFileList")
		app.ServiceCtrl.instance:SetFileList(filelist)
		app.AppLoop.instance:ChangeState(app.AppLoop.State.CompareFileList)
	else
		app.ServiceCtrl.instance:StartGetFileList(3, function(result)
			if result then
				local new_version = app.ServiceCtrl.instance:GetNewVersion()
				local filelist = app.ServiceCtrl.instance:GetFileList()
				global.UserDefault:SetInt("NewResVersion", new_version)
				global.UserDefault:SetString("NewFileList", filelist)
				app.AppLoop.instance:ChangeState(app.AppLoop.State.CompareFileList)
			else
				print("AppLoopGetFileList Fail")
				app.AppLoop.instance:ChangeState(app.AppLoop.State.LoadingScript)
			end
		end)
	end
	
end

function AppLoopGetFileList:StateUpdate(now_time, elapse_time)
	
end

function AppLoopGetFileList:StateQuit()

end

return AppLoopGetFileList
