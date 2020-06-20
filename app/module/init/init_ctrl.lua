
local InitCtrl = Class()

function InitCtrl:_init()
	if InitCtrl.instance ~= nil then
		error("InitCtrl Init Twice!")
	end
	InitCtrl.instance = self

	self.view = require("module/init/init_view").New()
	self.res_loaded = false
end

function InitCtrl:_delete()
	self.view:DeleteMe()
	self.view = nil

	InitCtrl.instance = nil
end

function InitCtrl:LoadInitRes()
	if not self.req_id then
		local max_num = 2
		local cur_num = 0
		global.AssetLoader:SetNeedDownload(false)
		global.AssetLoader:LoadAllAsset("default.ab", false, function()
			FairyGUI.FontManager.RegisterDynamicFont("", "华康圆体W7(P)", "default.ab", "font1")
			FairyGUI.FontManager.RegisterDynamicFont("HYZhongKaiJ", "汉仪中楷简", "default.ab", "font2")
			cur_num = cur_num + 1
			self.res_loaded = cur_num == max_num
		end)
		global.AssetLoader:SetPersistentRes("default.ab")
		self.req_id = global.AssetLoader:LoadAllAsset("ui/ui_init.ab", true, function()
			cur_num = cur_num + 1
			self.res_loaded = cur_num == max_num
		end)
		global.AssetLoader:SetNeedDownload(true)
	end
end

function InitCtrl:UnloadInitRes()
	if self.req_id then
		global.AssetLoader:UnLoad(self.req_id)
		self.req_id = nil
	end
	self.res_loaded = false
end

function InitCtrl:IsInitResLoaded()
	return self.res_loaded
end

function InitCtrl:OpenView()
	self.view:Open()
end

function InitCtrl:CloseView()
	self.view:Close()
end

function InitCtrl:IsViewOpen()
	return self.view:IsOpen()
end

function InitCtrl:SetLoadingValue(val)
	if self.view:IsOpen() then
		self.view:SetLoadingValue(val)
	end
end

function InitCtrl:SetLoadingTxt(val)
	if self.view:IsOpen() then
		self.view:SetLoadingTxt(val)
	end
end

function InitCtrl:ShowNotice(enable, txt, ok_func, cancel_func)
	if self.view:IsOpen() then
		self.view:ShowNotice(enable, txt, ok_func, cancel_func)
	end
end

function InitCtrl:SetVersion(app, res)
	if self.view:IsOpen() then
		self.view:SetVersion(app, res)
	end
end

app.InitCtrl = InitCtrl.New()

return InitCtrl
