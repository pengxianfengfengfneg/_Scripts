local GuildDefendRewardView = Class(game.BaseView)

function GuildDefendRewardView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_defend_reward_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildDefendRewardView:_delete()
    
end

function GuildDefendRewardView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitRankList()
    self:InitRewardList()
    self:RegisterAllEvents()
    self.ctrl:SendGuildDefendScore()
end

function GuildDefendRewardView:CloseViewCallBack()

end

function GuildDefendRewardView:Init()
    self._layout_objs["txt_title1"]:SetText(config.words[4727])
    self._layout_objs["txt_info2"]:SetText(config.words[4729])
    self._layout_objs["txt_title2"]:SetText(config.words[4730])
    self._layout_objs["txt_info4"]:SetText(config.words[4732])

    self._layout_objs["txt_rank"]:SetText(config.words[4721])
    self._layout_objs["txt_name"]:SetText(config.words[4722])
    self._layout_objs["txt_career"]:SetText(config.words[4723])
    self._layout_objs["txt_hurt"]:SetText(config.words[4724])
    self._layout_objs["txt_recover"]:SetText(config.words[4725])
    self._layout_objs["txt_score"]:SetText(config.words[4726])
    
    self.txt_info1 = self._layout_objs["txt_info1"]
    self.txt_info3 = self._layout_objs["txt_info3"]

    self.ctrl_rank = self:GetRoot():GetController("ctrl_rank")

    self.rank_top_item = self:GetTemplate("game/guild/item/guild_defend_rank_item", "rank_top_item")
    self.rank_top_item:SetClickFunc(handler(self, self.ScrollToBottom))

    self.rank_bottom_item = self:GetTemplate("game/guild/item/guild_defend_rank_item", "rank_bottom_item")
    self.rank_bottom_item:SetClickFunc(handler(self, self.ScrollToTop))
end

function GuildDefendRewardView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4715]):HideBtnBack()
end

function GuildDefendRewardView:InitRankList()
    self.list_rank = self:CreateList("list_rank", "game/guild/item/guild_defend_rank_item")
    self.list_rank:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.rank_list_data[idx])
    end)
    -- self.list_rank:AddScrollEndCallback(function()
    --     self:SetRankCtrl()
    -- end)
    self.ctrl_rank:SetSelectedIndexEx(0)
end

function GuildDefendRewardView:UpdateRankList()
    if not self.score_info then return end
    self.rank_list_data = self.score_info.score_list or {}
    self.list_rank:SetItemNum(#self.rank_list_data)
end

function GuildDefendRewardView:InitRewardList()
    self.list_auction = self:CreateList("list_auction", "game/bag/item/goods_item")
    self.list_auction:SetRefreshItemFunc(function(item, idx)
        local item_info = self.auction_list_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
        item:SetShowTipsEnable(true)
    end)

    self.list_person = self:CreateList("list_person", "game/bag/item/goods_item")
    self.list_person:SetRefreshItemFunc(function(item, idx)
        local item_info = self.person_list_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
        item:SetShowTipsEnable(true)
    end)
end

function GuildDefendRewardView:UpdateRewardList()
    if not self.score_info then return end

    local wave = self.score_info.repel_wave
    local max_fit_num = 4
    local auction_cfg = self.ctrl:GetDefendAuctionConfig(wave)
    local shop_drop = auction_cfg and auction_cfg.show_drop

    if auction_cfg and shop_drop ~= 0 then
        self.auction_list_data = config.drop[auction_cfg.show_drop].client_goods_list
        self.list_auction:SetItemNum(#self.auction_list_data)
        self.list_auction:ResizeToFit(math.min(max_fit_num, #self.auction_list_data))
    else
        self.list_auction:SetItemNum(0)
    end
    
    local person_cfg = self.ctrl:GetDefendMonsterConfig(wave)
    if person_cfg then
        self.person_list_data = config.drop[person_cfg.wave_reward].client_goods_list
        self.list_person:SetItemNum(#self.person_list_data)
        self.list_person:ResizeToFit(math.min(max_fit_num, #self.person_list_data))
    else
        self.list_person:SetItemNum(0)
    end
end

function GuildDefendRewardView:SetRankCtrl()
    local item_num = self.list_rank:GetItemNum()
    local page_num = 12
    -- local first_item_index = self.list_rank:GetFirstChildInView()
    local first_item_index = 0

    local index = 0
    if item_num <= page_num then
        index = 0
    elseif first_item_index <= item_num / 2 then
        index = 1
        self.rank_top_item:SetItemInfo(self.rank_list_data[1])
    else
        index = 2
        self.rank_bottom_item:SetItemInfo(self.rank_list_data[item_num])
    end

    self.ctrl_rank:SetSelectedIndexEx(index)
end

function GuildDefendRewardView:ScrollToBottom()
    local item_num = self.list_auction:GetItemNum()
    if item_num > 0 then
        self.list_auction:ScrollToView(item_num - 1)
    end
end

function GuildDefendRewardView:ScrollToTop()
    local item_num = self.list_auction:GetItemNum()
    if item_num > 0 then
        self.list_auction:ScrollToView(0)
    end
end

function GuildDefendRewardView:UpdateText()
    if not self.score_info then return end
    local wave = self.score_info.repel_wave
    local world_lv = game.MainUICtrl.instance:GetWorldLv()
    local auction_cfg = self.ctrl:GetDefendAuctionConfig(wave)
    local funds = auction_cfg and auction_cfg.add_funds or 0

    self.txt_info1:SetText(string.format(config.words[4728], wave, funds))
    self.txt_info3:SetText(string.format(config.words[4731], wave))
end

function GuildDefendRewardView:Refresh()
    self:UpdateRankList()
    self:UpdateRewardList()
    self:UpdateText()
end

function GuildDefendRewardView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateDefendScoreInfo] = function(score_info)
            self.score_info = score_info
            self:Refresh()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildDefendRewardView
