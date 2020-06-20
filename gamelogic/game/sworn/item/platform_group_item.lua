local PlatformGroupItem = Class(game.UITemplate)

function PlatformGroupItem:_init(ctrl)
    self.ctrl = game.SwornCtrl.instance
end

function PlatformGroupItem:OpenViewCallBack()
    self.txt_tend_career = self._layout_objs.txt_tend_career
    self.txt_tend_lv = self._layout_objs.txt_tend_lv
    self.txt_tend_time = self._layout_objs.txt_tend_time
    self.txt_exp = self._layout_objs.txt_exp

    self.btn_greet = self._layout_objs.btn_greet
    self.btn_greet:AddClickCallBack(function()
        if self.info then
            self.ctrl:SendSwornGreet(2, self.info.group_id)
        end
    end)

    self.list_member = self:CreateList("list_member", "game/sworn/item/group_member_item")
    self.list_member:SetRefreshItemFunc(function(item, idx)
        local item_info = self.member_list_data[idx].mem
        item:SetItemInfo(item_info, idx)
    end)
end

function PlatformGroupItem:SetItemInfo(item_info, idx)
    self.info = item_info

    self.txt_tend_career:SetText(string.format(config.words[6259], self.ctrl:GetTendCareer(item_info.tend_career)))
    self.txt_tend_lv:SetText(string.format(config.words[6260], self.ctrl:GetTendLevel(item_info.tend_lv)))
    self.txt_tend_time:SetText(string.format(config.words[6261], self.ctrl:GetTendTime(item_info.tend_time)))

    self.txt_exp:SetText(string.format(config.words[6249], self.ctrl:GetExpAddValue(item_info.sworn_value)))

    self.member_list_data = item_info.mem_list
    self.list_member:SetItemNum(#self.member_list_data)

    local txt = self.ctrl:IsGreet(self.info.type, self.info.group_id) and config.words[6244] or config.words[6243]
    self.btn_greet:SetText(txt)
end

return PlatformGroupItem