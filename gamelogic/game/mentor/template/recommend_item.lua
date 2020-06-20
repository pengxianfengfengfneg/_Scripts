local RecommendItem = Class(game.UITemplate)

function RecommendItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function RecommendItem:OpenViewCallBack()
    self.head_icon = self:GetIconTemplate("head_icon")

    self.txt_lv = self._layout_objs["txt_lv"]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_value = self._layout_objs["txt_value"]

    self.img_career = self._layout_objs["img_career"]

    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        if self.info then
            self.ctrl:OpenNoticeView(self.info)
        end
    end)
end

function RecommendItem:SetItemInfo(item_info, idx)
    self.info = item_info
    self.head_icon:UpdateData(item_info)
    self.img_career:SetSprite("ui_common", "career"..item_info.career)

    self.txt_lv:SetText(item_info.lv .. ".")
    self.txt_name:SetText(item_info.name)
    self.txt_value:SetText(item_info.morality)
end

return RecommendItem