local GraduateItem = Class(game.UITemplate)

function GraduateItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function GraduateItem:OpenViewCallBack()
    self.img_icon = self._layout_objs["img_icon"]
    self.img_select = self._layout_objs["img_select"]

    self.txt_value = self._layout_objs["txt_value"]
    self.txt_score = self._layout_objs["txt_score"]

    self.bar_progress = self._layout_objs["bar_progress"]
end

function GraduateItem:SetItemInfo(item_info, idx)
    local goods_id = config.drop[item_info.award].client_goods_list[1][1]
    local goods_info = config.goods[goods_id]

    self.img_icon:SetSprite("ui_item", goods_info.icon)
    self.txt_value:SetText(item_info.mark)
    self.txt_score:SetText(string.format(config.words[6417], item_info.mark))
end

function GraduateItem:SetSelected(val)
    self.img_select:SetVisible(val) 
end

return GraduateItem