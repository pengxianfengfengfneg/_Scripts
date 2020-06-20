local GetGiftItem = Class(game.UITemplate)

function GetGiftItem:OpenViewCallBack()
    self._layout_objs.btn:AddClickCallBack(function()
        game.RewardHallCtrl.instance:SendDailyGiftGet(self.grade, self.info[1])
    end)

    self.item = self:GetTemplate("game/bag/item/goods_item", "item")
    self.item:SetShowTipsEnable(true)
end

function GetGiftItem:SetItemInfo(info)
    self.info = info
    local drop_info = config.drop[info[3]]
    self._layout_objs.name:SetText(drop_info.name)
    self._layout_objs.desc:SetText(drop_info.desc)
    local show_goods = drop_info.client_goods_list[1]
    self.item:SetItemInfo({ id = show_goods[1], num = show_goods[2] })
end

function GetGiftItem:SetGrade(grade)
    self.grade = grade
end

return GetGiftItem