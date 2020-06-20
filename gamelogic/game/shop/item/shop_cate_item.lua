local ShopCateItem = Class(game.UITemplate)

function ShopCateItem:_init(ctrl)
    self.ctrl = ctrl
end

function ShopCateItem:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(handler(self, self.OnItemClick))
end

function ShopCateItem:CloseViewCallBack()
    
end

function ShopCateItem:SetItemInfo(item_info)
    self._layout_objs["txt_name"]:SetText(item_info.name)
end

function ShopCateItem:OnItemClick()
    if self.click_func then
        self.click_func()
    end
end

function ShopCateItem:AddClickFunc(click_func)
    self.click_func = click_func
end

return ShopCateItem