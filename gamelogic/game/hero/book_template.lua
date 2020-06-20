local BookTemplate = Class(game.UITemplate)

function BookTemplate:OpenViewCallBack()
    self:BindEvent(game.HeroEvent.HeroActive, function()
        self:SetHeroAttr()
        self:SetHeroList(self.active)
    end)

    self:BindEvent(game.HeroEvent.HeroUpgrade, function()
        self:SetHeroAttr()
    end)

    self:BindEvent(game.HeroEvent.HeroUpgradeAll, function()
        self:SetHeroAttr()

        game.Utils.SetTip(self._layout_objs.btn_use, game.HeroCtrl.instance:GetAllChipTipState(), { x = 30, y = -9 })
    end)

    self.list = self:CreateList("list", "game/hero/item/hero_item", true)
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.hero_data[idx]
        item:SetHeroInfo(info)
        item:SetHeroIndex(idx)
    end)

    self._layout_objs.btn_checkbox:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_hero/hero_view/book_template/btn_checkbox"})
        game.ViewMgr:FireGuideEvent()
        local selected = self._layout_objs.btn_checkbox:GetSelected()
        game.HeroCtrl.instance:SaveFilterState(selected)
        self:SetHeroList(selected)
    end)

    --一键消耗英雄谱碎片
    self._layout_objs.btn_use:AddClickCallBack(function()
        game.HeroCtrl.instance:SendHeroOneKeyUpgrade()
    end)
    game.Utils.SetTip(self._layout_objs.btn_use, game.HeroCtrl.instance:GetAllChipTipState(), { x = 190, y = -9 })

    self._layout_objs.btn_attr:AddClickCallBack(function()
        game.HeroCtrl.instance:OpenHeroTotalAttrView()
    end)

    self._layout_objs["role_fight_com/btn_look"]:SetVisible(false)

    self._layout_objs.btn_checkbox:SetSelected(game.HeroCtrl.instance:GetFilterState())
    self:SetHeroList(game.HeroCtrl.instance:GetFilterState())
    self:SetHeroAttr()
end

function BookTemplate:CloseViewCallBack()
    self.list:DeleteMe()
end

function BookTemplate:SetHeroAttr()
    local combat_power = game.HeroCtrl.instance:GetBookFight()
    self._layout_objs["role_fight_com/txt_fight"]:SetText(combat_power)
end

function BookTemplate:SetHeroList(active)
    self.active = active
    self.hero_data = config.hero
    if active then
        local hero_info = game.HeroCtrl.instance:GetHeroesInfo()
        self.hero_data = {}
        for _, v in pairs(hero_info.heroes) do
            table.insert(self.hero_data, config.hero[v.hero.id])
        end
    end
    -- 英雄排序，按照品质从高到低-ID从小到大排列
    table.sort(self.hero_data, function(a, b)
        if a.color == b.color then
            return a.id < b.id
        else
            return a.color > b.color
        end
    end)
    self.list:SetItemNum(#self.hero_data)

    game.HeroCtrl.instance:SetHeroInfoList(self.hero_data)
end

function BookTemplate:SetListScrollToBot()
    self.list:ScrollToView(31)
end

return BookTemplate