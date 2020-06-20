local GuildAppView = Class(game.BaseView)

function GuildAppView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_app_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildAppView:_delete()

end

function GuildAppView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitAppList()
    self.ctrl:SendGuildGetJoinReq()
end

function GuildAppView:CloseViewCallBack()

end

function GuildAppView:Init()  
    self.btn_approve_all = self._layout_objs["btn_approve_all"]
    self.btn_refuse_all = self._layout_objs["btn_refuse_all"]
    self:RegisterAllEvents()
end

function GuildAppView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2354]):HideBtnBack()

    self.btn_approve_all:SetText(config.words[2355])
    self.btn_approve_all:AddClickCallBack(handler(self, self.ApproveAllApp))

    self.btn_refuse_all:SetText(config.words[2356])
    self.btn_refuse_all:AddClickCallBack(handler(self, self.RefuseAllApp))
end

function GuildAppView:InitAppList()
    self.list_app = game.UIList.New(self._layout_objs.list_app)
    self.list_app:SetCreateItemFunc(function(obj)
        local item = require("game/guild/item/guild_app_item").New()
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.list_app:SetRefreshItemFunc(function(item, idx)
        local item_info = self.app_list_data[idx].request
        item:SetItemInfo(item_info)
    end)
    self.list_app:SetVirtual(true)
    self:UpdateAppList(self.ctrl:GetGuildApplyInfo())
end

function GuildAppView:UpdateAppList(app_list_data)
    self.app_list_data = app_list_data or {}
    self.list_app:SetItemNum(#self.app_list_data)
end

function GuildAppView:OnEmptyClick()
    self:Close()
end

function GuildAppView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateAppList] = function(app_list_data)
            self:UpdateAppList(app_list_data)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function GuildAppView:ApproveAllApp()
    for k, v in pairs(self.app_list_data or {}) do
        local app_info = v.request
        self.ctrl:SendGuildHandleReq(1, app_info.id)
    end
end

function GuildAppView:RefuseAllApp()
    for k, v in pairs(self.app_list_data or {}) do
        local app_info = v.request
        self.ctrl:SendGuildHandleReq(2, app_info.id)
    end
end


return GuildAppView
