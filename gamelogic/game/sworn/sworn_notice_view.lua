local SwornNoticeView = Class(game.BaseView)

function SwornNoticeView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "notice_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function SwornNoticeView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function SwornNoticeView:RegisterAllEvents()
    local events = {
        {game.SwornEvent.OnSwornModifyEnounce, handler(self, self.OnSwornModifyEnounce)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SwornNoticeView:Init()
    self.txt_content = self._layout_objs.txt_content
    self.txt_content:SetText(self.ctrl:GetNotice())

    self.btn_cancel = self._layout_objs.btn_cancel
    self.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self.btn_ok = self._layout_objs.btn_ok
    self.btn_ok:AddClickCallBack(function()
        local content = self.txt_content:GetText()
        if game.Utils.CheckMaskChatWords(self.txt_content:GetText()) then
            game.GameMsgCtrl.instance:PushMsgCode(1413)
        else
            self.ctrl:SendSwornModifyEnounce(content)
        end
    end)
end

function SwornNoticeView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6267])
end

function SwornNoticeView:OnSwornModifyEnounce()
    self:Close()
end

return SwornNoticeView
