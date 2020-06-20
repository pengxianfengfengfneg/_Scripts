local MarryRankItem = Class(game.UITemplate)

function MarryRankItem:SetItemInfo(info)
    self.info = info
    if info.rank == 1 then
        self._layout_objs.rank_img:SetSprite("ui_common", "pm_1")
        self._layout_objs.rank_img:SetVisible(true)
    elseif info.rank == 2 then
        self._layout_objs.rank_img:SetSprite("ui_common", "pm_2")
        self._layout_objs.rank_img:SetVisible(true)
    elseif info.rank == 3 then
        self._layout_objs.rank_img:SetSprite("ui_common", "pm_3")
        self._layout_objs.rank_img:SetVisible(true)
    else
        self._layout_objs.rank_img:SetVisible(false)
        self._layout_objs.rank_num:SetText(info.rank)
    end

    self._layout_objs.name_male:SetText(info.male_name)
    self._layout_objs.name_female:SetText(info.female_name)
    self._layout_objs.love:SetText(info.love_value)
    self._layout_objs.love:SetText(info.love_value)
    self._layout_objs.career_male:SetSprite("ui_common", "career" .. info.male_career)
    self._layout_objs.career_female:SetSprite("ui_common", "career" .. info.female_career)

end

function MarryRankItem:SetBg(val)
    if val then
        self._layout_objs.bg:SetSprite("ui_common", "009_1")
    else
        self._layout_objs.bg:SetSprite("ui_common", "009_2")
    end
end

return MarryRankItem