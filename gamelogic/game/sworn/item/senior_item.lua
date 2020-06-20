local SeniorItem = Class(game.UITemplate)

function SeniorItem:_init(ctrl)
    self.ctrl = game.SwornCtrl.instance
end

function SeniorItem:OpenViewCallBack()
    self.txt_senior = self._layout_objs.txt_senior
    self.txt_name = self._layout_objs.txt_name

    self.head_icon = self:GetIconTemplate("head_icon")
end

function SeniorItem:SetItemInfo(item_info, idx)
    local senior_id = item_info and item_info.senior or idx
    self.txt_senior:SetText(config.sworn_senior_name[senior_id].name2)

    self.txt_name:SetText(self:GetNameText(item_info, idx))
    
    if item_info then
        self.head_icon:UpdateData(item_info)
    end
    self.head_icon:SetVisible(item_info ~= nil)
end

function SeniorItem:GetNameText(item_info, idx)
    if item_info then
        return item_info.name
    else
        local info = self.ctrl:GetSeniorSortInfo()
        if idx == info.cur_senior then
            return config.words[6274]
        else
            return config.words[6272]
        end
    end
end

return SeniorItem