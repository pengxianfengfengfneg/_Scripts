local MsgBoxView = Class(game.BaseView)

function MsgBoxView:_init()
	self._package_name = "ui_game_msg"
    self._com_name = "msg_box_view"

	self._ui_order = game.UIZOrder.UIZOrder_Tips

    self._view_level = game.UIViewLevel.Standalone

    self.timeout = 0
end

function MsgBoxView:OpenViewCallBack()
	self:InitBg()

	self._layout_objs["btn_ok"]:SetText(self.ok_txt or config.words[100])
	self._layout_objs["btn_ok"]:AddClickCallBack(function()
		if self.ok_callback then
			self.ok_callback()
		end
		self:Close()
	end)

	if self.cancel_callback then
		self._layout_objs["btn_ok"]:SetPosition(352, 287)
		self._layout_objs["btn_cancle"]:SetVisible(true)
		self._layout_objs["btn_cancle"]:SetText(self.cancel_txt or config.words[101])
		self._layout_objs["btn_cancle"]:AddClickCallBack(function()
			if self.cancel_callback then
				self.cancel_callback()
			end
			self:Close()
		end)
	else
		self._layout_objs["btn_cancle"]:SetVisible(false)
		self._layout_objs["btn_ok"]:SetPosition(217, 287)
	end

	self._layout_objs["txt_content"]:SetText(self.content)

	local is_timeout = self.timeout > 0
	self._layout_objs["txt_auto_time"]:SetVisible(is_timeout)
	if is_timeout then
		self:StartTimeOut()
	end
end

function MsgBoxView:CloseViewCallBack()
	self:ClearTimeOut()
end

function MsgBoxView:InitBg()
	self:GetBgTemplate("common_bg"):SetTitleName(self.title or config.words[102]):SetBtnCloseVisible(false)
end

function MsgBoxView:SetOkBtn(callback, txt, is_default)
	self.ok_txt = txt or config.words[100]
	self.ok_callback = callback

	self.is_ok_default = is_default
end

function MsgBoxView:SetCancelBtn(callback, txt, is_default)
	self.cancel_txt = txt or config.words[101]
	self.cancel_callback = callback

	self.is_ok_default = (not is_default)
end

function MsgBoxView:SetTitle(title)
	self.title = title
end

function MsgBoxView:SetContent(content)
	self.content = content
end

function MsgBoxView:SetTimeOut(timeout)
	self.timeout = timeout or 0
end

function MsgBoxView:StartTimeOut()
	self:ClearTimeOut()

	local timeout = self.timeout + 1
	local function updateTime()
		timeout = timeout - 1

		local default_txt = (self.is_ok_default and self.ok_txt or self.cancel_txt)
		default_txt = string.gsub(default_txt, " ", "")
		local str_time = string.format(config.words[106], timeout, default_txt)
		self._layout_objs["txt_auto_time"]:SetText(str_time)
		
		if timeout <= 0 then
			local call_func = (self.is_ok_default and self.ok_callback or self.cancel_callback)
			if call_func then
				call_func()
			end
			self:ClearTimeOut()
		end
	end
	updateTime()
	self.timeout_id = global.TimerMgr:CreateTimer(1,updateTime)
end

function MsgBoxView:ClearTimeOut()
	if self.timeout_id then
		global.TimerMgr:DelTimer(self.timeout_id)
		self.timeout_id = nil
	end
end

return MsgBoxView