local FriendNoticeView = Class(game.BaseView)

function FriendNoticeView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "friend_notice_view"
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function FriendNoticeView:OpenViewCallBack(announce)
    self.announce = announce

    self:Init()
    self:InitBg()
end

function FriendNoticeView:Init()
    local txt_notice = self._layout_objs["txt_notice"]
    txt_notice:SetText(self.announce or "")

    local btn_ok = self._layout_objs["btn_ok"]
    btn_ok:AddClickCallBack(function()
        self:Close()
    end)
end

function FriendNoticeView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1771])
end

function FriendNoticeView:OnEmptyClick()
    self:Close()
end

return FriendNoticeView