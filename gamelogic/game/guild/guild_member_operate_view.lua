local GuildMemberOperateView = Class(game.BaseView)

function GuildMemberOperateView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_member_operate_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function GuildMemberOperateView:_delete()
end

function GuildMemberOperateView:OpenViewCallBack(member_info)
    self.member_info = member_info
    self:Init()
    self:InitBg()
    self:Refresh()
end

function GuildMemberOperateView:CloseViewCallBack()
    self.member_item:DeleteMe()
    self.member_item = nil
end

function GuildMemberOperateView:Init()  
    self.btn_player_info = self._layout_objs["btn_player_info"]
    self.btn_chat = self._layout_objs["btn_chat"]
    self.btn_appoint_pos = self._layout_objs["btn_appoint_pos"]
    self.btn_kick = self._layout_objs["btn_kick"]
    self.btn_leave = self._layout_objs["btn_leave"]
    self.btn_retire = self._layout_objs["btn_retire"]

    self.ctrl_operate = self:GetRoot():GetController("ctrl_operate")

    self:InitMemberItem()
    self:RegisterAllEvents()
end

function GuildMemberOperateView:InitBg()
    self.min_appoint_pos = 4
    self.min_kick_pos = 3

    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2349]):HideBtnBack()

    self.btn_player_info:SetText(config.words[2350])
    self.btn_player_info:AddClickCallBack(function()
        game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.ViewOthers, self.member_info.id)
    end)

    self.btn_chat:SetText(config.words[2351])
    self.btn_chat:AddClickCallBack(function()
        local chat_info = {
            id = self.member_info.id,
            name = self.member_info.name,
            lv = self.member_info.level,
            career = self.member_info.career,
            svr_num = 1,
        }
        game.ChatCtrl.instance:OpenFriendChatView(chat_info)
    end)
    
    self.btn_appoint_pos:SetText(config.words[2352])
    self.btn_appoint_pos:AddClickCallBack(function()
        self.ctrl:OpenGuildAppointPosView(self.member_info)
    end)
    
    self.btn_kick:SetText(config.words[2353])
    self.btn_kick:AddClickCallBack(function()
        self.ctrl:SendGuildKickMember(self.member_info.id)
    end)

    self.btn_leave:SetText(config.words[2342])
    self.btn_leave:AddClickCallBack(function()
        self.ctrl:SendGuildLeave()
    end)

    self.btn_retire:SetText(config.words[2365])
    self.btn_retire:AddClickCallBack(function()
        self.ctrl:SendGuildAppointPos(self.member_info.id, 1)
    end)

    local operate_index = self.member_info.id == game.Scene.instance:GetMainRoleID() and 1 or 0
    self.ctrl_operate:SetSelectedIndexEx(operate_index)

    if game.IsZhuanJia then
        self.btn_chat:SetVisible(false)
    end
end

function GuildMemberOperateView:InitMemberItem()
    self.member_item = require("game/guild/item/guild_member_item").New()
    self.member_item:SetVirtual(self)
    self.member_item:Open()
end

function GuildMemberOperateView:Refresh()
    self.member_item:SetItemInfo(self.member_info)
    local pos = self.ctrl:GetGuildMemberPos()
    self.btn_appoint_pos:SetEnable(pos >= self.min_appoint_pos)
    self.btn_kick:SetEnable(pos >= self.min_kick_pos)
    self.btn_retire:SetEnable(pos >= 1 and pos <= 4)
end

function GuildMemberOperateView:OnEmptyClick()
    self:Close()
end

function GuildMemberOperateView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.KickMember] = function(id)
            self:Close()
        end,
        [game.GuildEvent.UpdateMemberPos] = function(id, pos)
            if self.member_info.id == id then
                self:Refresh()
            end
        end,
        [game.GuildEvent.UpdateMemberOffline] = function(id, time)
            if self.member_info.id == id then
                self:Refresh()
            end
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end


return GuildMemberOperateView
