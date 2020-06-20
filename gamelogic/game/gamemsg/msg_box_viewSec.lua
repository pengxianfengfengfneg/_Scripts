local MsgBoxViewSec = Class(game.BaseView)

function MsgBoxViewSec:_init()
	self._package_name = "ui_game_msg"
    self._com_name = "msg_box_view2"
    
	self._ui_order = game.UIZOrder.UIZOrder_Tips

    self._view_level = game.UIViewLevel.Standalone
end

function MsgBoxViewSec:OpenViewCallBack()
	self:InitBg()

	self._layout_objs["btn_ok"]:SetText(self.ok_txt or config.words[100])
	self._layout_objs["btn_ok"]:AddClickCallBack(function()
		if self.ok_callback then
			self.ok_callback()
		end
		self:Close()
	end)


	self._layout_objs["txt_content"]:SetText(self.content)
end

function MsgBoxViewSec:CloseViewCallBack()

end

function MsgBoxViewSec:InitBg()
	self:GetBgTemplate("common_bg"):SetTitleName(self.title or config.words[102]):SetBtnCloseVisible(false)
end

function MsgBoxViewSec:SetOkBtn(callback, txt)
	self.ok_txt = txt
	self.ok_callback = callback
end

function MsgBoxViewSec:SetTitle(title)
	self.title = title
end

function MsgBoxViewSec:SetContent(content)
	self.content = content
end

return MsgBoxViewSec