local HeroItem = Class(game.UITemplate)

function HeroItem:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(function()
        game.HeroCtrl.instance:OpenHeroInfoView(self.hero_info.id)

        if self.hero_info.id == 29 then
            game.GuideCtrl.instance:FinishCurGuideInfo({ click_btn_name = "ui_hero/hero_view/book_template/hero_item/group" })
        end
    end)

    self:BindEvent(game.HeroEvent.HeroUpgrade, function(id)
        if id == self.hero_info.id then
            self:SetHeroInfo(self.hero_info)
        end
    end)

    self:BindEvent(game.HeroEvent.HeroUpgradeAll, function()
        self:SetHeroInfo(self.hero_info)
    end)

    self:BindEvent(game.BagEvent.BagItemChange, function()
        local posY = 88
        if self.idx % 2 == 1 then
            posY = 156
        end
        game.Utils.SetTip(self:GetRoot(), game.HeroCtrl.instance:GetHeroTipState(self.hero_info.id), { x = 30, y = posY })
    end)
end

function HeroItem:CloseViewCallBack()
end

function HeroItem:SetHeroInfo(cfg)
    self.hero_info = cfg
    local info = game.HeroCtrl.instance:GetHeroInfo(cfg.id)
    self._layout_objs.image:SetSprite("ui_heroicon", cfg.big_icon, true)
    if info then
        self._layout_objs.level:SetText(info.level)
        self._layout_objs.image:SetGray(false)
    else
        self._layout_objs.level:SetText("")
        self._layout_objs.image:SetGray(true)
    end
    self._layout_objs.name:SetText(cfg.name)
    self._layout_objs.name_bg:SetSprite("ui_common", "yx_0" .. cfg.color)
end

function HeroItem:SetHeroIndex(idx)
    self.idx = idx
    local posY = 88
    if idx % 2 == 1 then
        self._layout_objs.group:SetPositionY(68)
        posY = 156
    else
        self._layout_objs.group:SetPositionY(0)
    end
    game.Utils.SetTip(self:GetRoot(), game.HeroCtrl.instance:GetHeroTipState(self.hero_info.id), { x = 30, y = posY })
end

return HeroItem