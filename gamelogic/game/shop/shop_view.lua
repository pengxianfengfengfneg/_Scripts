local ShopView = Class(game.BaseView)

function ShopView:_init(ctrl)
    self._package_name = "ui_shop"
    self._com_name = "shop_view"
    self.ctrl = ctrl
    self.guide_index = 1
    self._show_money = true

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
end

function ShopView:_delete()
    
end

function ShopView:OpenViewCallBack(func_id, shop_idx, tag_idx, cate_idx, item_id)
    self.func_id = func_id
    self.shop_idx = shop_idx or 1
    self.tag_idx = tag_idx or 1
    self.cate_idx = cate_idx
    self.item_id = item_id
    self:Init()
    self:InitBg()
end

function ShopView:CloseViewCallBack()

end

function ShopView:Init()
    self.list_page = self._layout_objs["list_page"]
    self.list_page:AddScrollEndCallback(function(perX, perY)
        self:SetTabSelect()
    end)
    self.list_page:SetHorizontalBarTop(true)

    self.ctrl_tab = self:GetRoot():AddControllerCallback("ctrl_tab", function(idx)
        self:OnClickTab(idx+1)
    end)
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)

    end)

    self.page_info = {}
    self.shop_info = {}

    local shop_list = self.ctrl:GetShopList(self.func_id)

    local page_idx = 0
    for k, v in ipairs(shop_list) do
        local shop_id = v.id
        local page_num = self.ctrl:GetPageNum(shop_id)
        for i=1, page_num do
            table.insert(self.page_info, {shop_id, page_num})
            page_idx = page_idx + 1
            if i==1 then
                self.shop_info[k] = {shop_id, page_idx}
            end
        end
    end
    self.list_page:SetItemNum(#self.page_info)
    for i=1, #self.page_info do
        local shop = self:GetShopTemplate(i)
        shop:InitPage(self.page_info[i][1], self.page_info[i][2])
    end

    self.list_tab = self._layout_objs["list_tab"]
    self.list_tab:SetItemNum(#shop_list)
    for i=1, #shop_list do
        self.list_tab:GetChildAt(i-1):SetText(shop_list[i].name)
    end

    self.ctrl_tab:SetPageCount(#shop_list)
    self.ctrl_tab:SetSelectedIndexEx(self.shop_idx-1)

    self:SetTabSelect()
end

function ShopView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1609]):ShowBtnBack():AddBackFunc(handler(self, self.OnBackClick))
end

function ShopView:OnClickTab(idx)
    local page_idx = self.shop_info[idx][2]
    self.list_page:ScrollToView(page_idx-1)
    self.cur_shop = self:GetShopTemplate(idx)
    self.cur_shop:RefreshView(self.tag_idx, self.cate_idx, self.item_id)
    if self.tag_idx ~= 1 then
        self.tag_idx = 1
    end
    if self.cate_idx then
        self.cate_idx = nil
    end
    if self.item_id then
        self.item_id = nil
    end
end

function ShopView:GetShopTemplate(idx)
    return self:GetTemplateByObj("game/shop/template/shop_template", self.list_page:GetChildAt(idx-1))
end

function ShopView:GetShopIndex(page)
    for k, v in ipairs(self.shop_info) do
        if page <= v[2] then
            return k
        end
    end
end

function ShopView:SetTabSelect()
    local index = self._layout_objs["list_page"]:GetFirstChildInView() + 1
    self.ctrl_tab:SetSelectedIndex(self:GetShopIndex(index)-1)
end

function ShopView:OnBackClick()
    if self.cur_shop then
        if self.cur_shop:GetPageState() == 2 then
            if self.cur_shop:BackToCateList() then
                return
            end
        end
    end
    self:Close()
end

return ShopView
