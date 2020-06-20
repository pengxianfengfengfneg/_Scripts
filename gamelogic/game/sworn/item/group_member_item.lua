local GroupMemberItem = Class(game.UITemplate)

function GroupMemberItem:_init(ctrl)
    self.ctrl = game.SwornCtrl.instance
end

function GroupMemberItem:OpenViewCallBack()
    self.txt_name = self._layout_objs.txt_name
    self.txt_level = self._layout_objs.txt_level
    self.txt_gender = self._layout_objs.txt_gender
    self.img_career = self._layout_objs.img_career
end

function GroupMemberItem:SetItemInfo(item_info, idx)
    self.txt_name:SetText(item_info.name)
    self.txt_level:SetText(string.format(config.words[6266], item_info.lv))
    self.txt_gender:SetText(game.Utils.GetGenderName(item_info.gender))
    self.img_career:SetSprite("ui_common", "career"..item_info.career)
end

return GroupMemberItem