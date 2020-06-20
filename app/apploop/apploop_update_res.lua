
local AppLoopUpdateRes = Class()

local _asset_loader = global.AssetLoader

function AppLoopUpdateRes:_init()

end

function AppLoopUpdateRes:_delete()

end

function AppLoopUpdateRes:StateEnter()
	print("AppLoopUpdateRes")

	app.InitCtrl.instance:SetLoadingTxt(app.words[7])
	app.InitCtrl.instance:SetLoadingValue(0)
	N3DClient.AssetManager:GetInstance():ResetAllDownloadState()

	self.req_list = {}
	self.download_list, self.download_sz = app.ServiceCtrl.instance:GetPriorityDownloadList()

	if #self.download_list > 0 then
		if UnityEngine.Application.internetReachability == 1 then
			app.InitCtrl.instance:ShowNotice(true, string.format(app.words[10], self.download_sz / 1024 / 1024), function()
				app.InitCtrl.instance:ShowNotice(false)
				self:StartDownload()
			end, function()
				UnityEngine.Application.Quit()
			end)
			return
		end
	end
	self:StartDownload()
end

function AppLoopUpdateRes:StateUpdate(now_time, elapse_time)
	if self.download_num == #self.download_list then
		if #self.download_list > 0 then
			app.AppLoop.instance:ChangeState(app.AppLoop.State.Restart)
		else
			app.AppLoop.instance:ChangeState(app.AppLoop.State.LoadingScript)
		end
	else
		local progress = 0
		for i,v in ipairs(self.req_list) do
			progress = progress + _asset_loader:GetProgress(v)
		end
		progress = progress / #self.download_list * 100
		app.InitCtrl.instance:SetLoadingValue(progress)
	end
end

function AppLoopUpdateRes:StateQuit()
	for i,v in ipairs(self.req_list) do
		_asset_loader:UnLoad(v)
	end
	self.req_list = nil
end

function AppLoopUpdateRes:StartDownload()
	self.download_num = 0
	local callback = function()
		self.download_num = self.download_num + 1
	end
	for i,v in ipairs(self.download_list) do
		table.insert(self.req_list, _asset_loader:DownloadAsset(v, callback))
	end
end

return AppLoopUpdateRes
