local ZhenFaItem = Class(game.UITemplate)

function ZhenFaItem:OpenViewCallBack()
    self.view_others_mode = false
end

function ZhenFaItem:SetItemInfo(info)
    self.info = info

    self._layout_objs.name:SetText(info.name)
    self._layout_objs.text:SetText(info.level .. config.words[2101])
    self._layout_objs.icon:SetSprite("ui_common", info.icon)

    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    self._layout_objs.icon:SetVisible(self.view_others_mode or role_lv >= info.level)

    self:GetRoot():AddClickCallBack(function()
        if self.view_others_mode or role_lv >= info.level then
            self:FireEvent(game.PetEvent.SelectZhenFa, info.id)
        else
            game.GameMsgCtrl.instance:PushMsg(info.name .. info.level .. config.words[2101])
        end
    end)
end

function ZhenFaItem:SetSelect(val)
    self._layout_objs.select:SetVisible(val)
end

function ZhenFaItem:GetItemInfo()
    return self.info
end

function ZhenFaItem:SetOthersMode()
    self.view_others_mode = true
end

return ZhenFaItem