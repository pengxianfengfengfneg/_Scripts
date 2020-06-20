local SkillCommendItem = Class(game.UITemplate)

function SkillCommendItem:SetItemInfo(info)
    self.info = info

    self._layout_objs.name:SetText(info.name)

    local list = self:CreateList("list", "game/skill/item/skill_item_rect")
    list:SetRefreshItemFunc(function(item, idx)
        local skill_id = info.skills[idx]
        item:SetItemInfo({id = skill_id})
        item:SetShowInfo()
    end)
    list:SetItemNum(#info.skills)
end

function SkillCommendItem:SetBg(val)
    self._layout_objs.bg:SetVisible(val)
end

return SkillCommendItem