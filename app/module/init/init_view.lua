
local InitView = Class()

function InitView:_init()
	self._package_name = "ui_init"
	self._com_name = "init_view"
	self._ui_order = 1
	self._is_open = false
end

function InitView:_delete()
	self:Close()
end

function InitView:Open()
	if self._is_open then
		return
	end
	self._is_open = true

	local ui_mgr = N3DClient.UIManager:GetInstance()
	self._ui_obj, self._layout_root = ui_mgr:CreateUIPanel(self._package_name, self._com_name, self._ui_order)
	self:OpenViewCallBack()
end

function InitView:Close()
	if not self._is_open then
		return
	end

	self:CloseViewCallBack()

	UnityEngine.GameObject.Destroy(self._ui_obj)
	self._ui_obj = nil
	self._layout_root = nil
	self._is_open = false
end

function InitView:IsOpen()
	return self._is_open
end

function InitView:OpenViewCallBack()
	self.progress_bar = self._layout_root:GetChild("n3")
	self.progress_txt = self._layout_root:GetChild("n3/txt")
	self:ShowNotice(false)
end

function InitView:CloseViewCallBack()
	self.progress_bar = nil
	self.progress_txt = nil
end

function InitView:SetLoadingValue(val)
	self.progress_bar:SetProgressValue(val)
end

function InitView:SetLoadingTxt(txt)
	self.progress_txt:SetText(txt)
end

function InitView:ShowNotice(enable, txt, ok_func, cancel_func)
	self._layout_root:GetChild("notice"):SetVisible(enable)
	if enable then
		self._layout_root:GetChild("notice/txt_content"):SetText(txt)
		self._layout_root:GetChild("notice/btn1"):AddClickCallBack(cancel_func)
		self._layout_root:GetChild("notice/btn2"):AddClickCallBack(ok_func)
	end
end

function InitView:SetVersion(app, res)
	self._layout_root:GetChild("version"):SetText(string.format("app:%s\nres:%s", app, res))
end

return InitView
