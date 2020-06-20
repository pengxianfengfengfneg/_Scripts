local MarketPetInfoView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "page_com/list_page/pet_info_template",
        item_class = "game/market/template/pet_info_template",
    },
    {
        item_path = "page_com/list_page/pet_attr_template",
        item_class = "game/market/template/pet_attr_template",
    },
}

function MarketPetInfoView:_init(ctrl)
    self._package_name = "ui_market"
    self._com_name = "market_pet_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function MarketPetInfoView:_delete()
    
end

function MarketPetInfoView:OpenViewCallBack(info)
    self:Init()
    self:InitBg()
    self:InitTemplate(info)
end

function MarketPetInfoView:CloseViewCallBack()

end

function MarketPetInfoView:Init()
    self.list_page = self._layout_objs["page_com/list_page"]
    self.list_page:SetHorizontalBarTop(true)

    self.ctrl_page = self:GetRoot():GetChild("page_com"):AddControllerCallback("ctrl_page", function(idx)
        self:OnClickPage(idx+1)
    end)

    local open_idx = 1
    self.ctrl_page:SetSelectedIndexEx(open_idx-1)
end

function MarketPetInfoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5662]):HideBtnBack()
end

function MarketPetInfoView:InitTemplate(info)
    for k, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path, info)
    end
end

function MarketPetInfoView:OnClickPage(idx)

end

return MarketPetInfoView
