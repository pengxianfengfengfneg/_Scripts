local DividendGetItem = Class(game.UITemplate)

function DividendGetItem:OpenViewCallBack()
    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    self.goods_item:SetShowTipsEnable(true)

    self.txt_desc = self._layout_objs.txt_desc
    self.txt_info = self._layout_objs.txt_info

    self.img_ylq = self._layout_objs.img_ylq
    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2

    self.btn_get = self._layout_objs.btn_get
    self.btn_get:AddClickCallBack(function()
        if self.click_event then
            self.click_event()
        end
    end)
end

function DividendGetItem:SetItemInfo(info, idx)
    self.info = info

    self.txt_desc:SetText(info.desc)
    self.txt_info:SetText(info.info)

    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)

    self.goods_item:SetItemInfo(info.goods_info)

    self:SetGetType(info.type)
    self:UpdateRedPoint(info.is_red)
end

function DividendGetItem:AddClickEvent(click_event)
    self.click_event = click_event
end

function DividendGetItem:SetGetType(type)
    self.btn_get:SetVisible(type ~= 2)
    self.btn_get:SetEnable(type == 1)
    self.img_ylq:SetVisible(type == 2)
end

function DividendGetItem:UpdateRedPoint(is_red)
    game_help.SetRedPoint(self.btn_get, is_red)
end

return DividendGetItem