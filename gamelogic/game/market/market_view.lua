local MarketView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/buy_template",
        item_class = "game/market/template/market_buy_template",
    },
    {
        item_path = "list_page/sell_template",
        item_class = "game/market/template/market_sell_template",
    },
    {
        item_path = "list_page/presell_template",
        item_class = "game/market/template/market_presell_template",
    },
    {
        item_path = "list_page/follow_template",
        item_class = "game/market/template/market_follow_template",
    },
}

local PageIndex = {
    Buy = 1,
    Sell = 2,
    Presell = 3,
    Follow = 4,
}

local OpenFuncMap = {
    [PageIndex.Buy] = function (cate_id, tag_id, eq_tag, item_id)
        if cate_id then
            game.MarketCtrl.instance:JumpToBuyPage(cate_id, tag_id, eq_tag)
            return true
        end
        return false
    end,
}

function MarketView:_init(ctrl)
    self._package_name = "ui_market"
    self._com_name = "market_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self:AddPackage("ui_pet")
end

function MarketView:_delete()
    
end

function MarketView:OpenViewCallBack(open_idx, ...)
    self:Init(open_idx, ...)
    self:InitBg()
    self.ctrl:SendMarketInfo()
end

function MarketView:CloseViewCallBack()

end

function MarketView:Init(open_idx, ...)
    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)

    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
        self:OnClickPage(idx+1)
    end)
    self.ctrl_page:SetPageCount(#PageConfig)

    local open_idx = open_idx or 1
    local result = false
    if OpenFuncMap[open_idx] then
        result = OpenFuncMap[open_idx](...)
    end
    if not result then
        self.ctrl_page:SetSelectedIndexEx(open_idx-1)
    end
end

function MarketView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5634]):ShowBtnBack():AddBackFunc(handler(self, self.OnBackClick))
end

function MarketView:OnClickPage(idx)
    self.cur_tpl = self:GetTemplate(PageConfig[idx].item_class, PageConfig[idx].item_path)
end

function MarketView:OnBackClick()
    if not self.cur_tpl or not self.cur_tpl:BackPage() then
        self:Close()
    end
end

function MarketView:JumpToBuyPage(cate, tag, eq_tag)
    local page_idx = PageIndex.Buy
    self.ctrl_page:SetSelectedIndexEx(page_idx-1)
    local buy_tpl = self:GetTemplate(PageConfig[page_idx].item_class, PageConfig[page_idx].item_path)
    buy_tpl:RefreshView(cate, tag, eq_tag)
end

function MarketView:JumpToPresellPage(cate, tag, eq_tag)
    local page_idx = PageIndex.Presell
    self.ctrl_page:SetSelectedIndexEx(page_idx-1)
    local presell_tpl = self:GetTemplate(PageConfig[page_idx].item_class, PageConfig[page_idx].item_path)
    presell_tpl:RefreshView(cate, tag, eq_tag)
end

return MarketView
