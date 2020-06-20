local GuildBlessView = Class(game.BaseView)

function GuildBlessView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_bless_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildBlessView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendGuildBlessInfo()
end

function GuildBlessView:CloseViewCallBack()

end

function GuildBlessView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UpdateBlessInfo, handler(self, self.UpdateBlessInfo)},
        {game.GuildEvent.UpdateGuildInfo, handler(self, self.SetFundsText)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end 

function GuildBlessView:Init()
    self.list_bless = self:CreateList("list_bless", "game/guild/item/guild_bless_item")
    self.list_bless:SetRefreshItemFunc(function(item, idx)
        local item_info = self.bless_list_data[idx]
        item:SetItemInfo(item_info)
    end)

    self.txt_cost = self._layout_objs.txt_cost
    self.txt_cost:SetText(0)

    self.txt_funds = self._layout_objs.txt_funds

    self.btn_bless = self._layout_objs.btn_bless
    self.btn_bless:AddClickCallBack(function()
        local item_info = self.click_item_info
        if not item_info then
            game.GameMsgCtrl.instance:PushMsg(config.words[4795])
        elseif self.ctrl:GetGuildMemberPos() < game.GuildPos.ViceChief then
            game.GameMsgCtrl.instance:PushMsg(config.words[4794])
        elseif not game.GuildCtrl.instance:IsAllBuildMaxLevel() then
            game.GameMsgCtrl.instance:PushMsg(config.words[4796])
        else
            self.ctrl:OpenGuildTipsView(5, item_info.id, item_info.name, item_info.cost_funds)
        end
    end)

    self.ctrl_item = self:GetRoot():AddControllerCallback("ctrl_item", function(idx)
        self:OnItemClick(self.bless_list_data[idx+1])
    end)

    self.ctrl_item:SetSelectedIndexEx(-1)

    self:SetFundsText()
end

function GuildBlessView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4701])
end

function GuildBlessView:OnItemClick(item_info)
    self.click_item_info = item_info
    self.txt_cost:SetText(item_info and item_info.cost_funds or 0)
end

function GuildBlessView:UpdateBlessInfo()
    self.bless_list_data = config.guild_bless
    self.list_bless:SetItemNum(#self.bless_list_data)
    self.ctrl_item:SetPageCount(#self.bless_list_data)
end

function GuildBlessView:SetFundsText()
    local guild_info = self.ctrl:GetGuildInfo()
    self.txt_funds:SetText(guild_info.funds)
end

return GuildBlessView
