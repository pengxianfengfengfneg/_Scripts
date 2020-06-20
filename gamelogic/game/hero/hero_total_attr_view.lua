local HeroTotalAttrView = Class(game.BaseView)

function HeroTotalAttrView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "pulse_attr_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function HeroTotalAttrView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3129])
    self.power = self._layout_objs["role_fight_com/txt_fight"]
    self._layout_objs["role_fight_com/btn_look"]:SetVisible(false)

    self:SetHeroAttr()
end

function HeroTotalAttrView:OnEmptyClick()
    self:Close()
end

function HeroTotalAttrView:SetHeroAttr()
    local hero_info = game.HeroCtrl.instance:GetHeroesInfo()
    local total_attr = {}
    for _, v in pairs(hero_info.heroes) do
        for _, val in ipairs(config.hero_level[v.hero.id][v.hero.level].attr) do
            table.insert(total_attr, val)
        end
    end
    local attr = {}
    for _, v in pairs(total_attr) do
        if attr[v[1]] then
            attr[v[1]] = attr[v[1]] + v[2]
        else
            attr[v[1]] = v[2]
        end
    end
    total_attr = {}
    for i, v in pairs(attr) do
        table.insert(total_attr, { i, v })
    end
    self.power:SetText(game.Utils.CalculateCombatPower2(total_attr))

    local list = self:CreateList("list", "game/hero/item/attr_list_item")
    list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo({ total_attr[idx * 2 - 1], total_attr[idx * 2] })
        item:SetBg(idx % 2 == 0)
    end)

    list:SetItemNum(math.ceil(#total_attr / 2))
end

return HeroTotalAttrView
