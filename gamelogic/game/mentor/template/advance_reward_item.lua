local AdvanceRewardItem = Class(game.UITemplate)

function AdvanceRewardItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function AdvanceRewardItem:OpenViewCallBack()
    self.txt_name = self._layout_objs["txt_name"]
    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
end

function AdvanceRewardItem:SetItemInfo(item_info, idx)
    self.txt_name:SetText(item_info.name)
    local goods_info = config.drop[item_info.drop].client_goods_list[1]
    self.goods_item:SetItemInfo({id = goods_info[1], num = goods_info[2]})
    self.goods_item:SetShowTipsEnable(true)
end

return AdvanceRewardItem