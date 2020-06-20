local HeroSetGuideItem = Class(game.UITemplate)

local guild_lv = config.sys_config.hero_active_lv.value

function HeroSetGuideItem:OpenViewCallBack()
    self._layout_objs.btn_guide:AddClickCallBack(function()
        self:FireEvent(game.HeroEvent.HeroSetGuide, self.skill_id, self.info.id)
        
        if self.click_callback then
            self.click_callback()
        end
    end)

    self._layout_objs.btn_disable:SetVisible(false)
end

function HeroSetGuideItem:SetHeroInfo(info, skill_id)
    self.info = info
    self.skill_id = skill_id
    self._layout_objs.hero_name:SetText(info.name)
    self._layout_objs.head_bg:SetSprite("ui_common", "yx_t" .. info.color)
    self._layout_objs.head:SetSprite("ui_headicon", info.icon)

    local desc = config.hero_effect[info.id][skill_id][0][1].zd_desc
    self._layout_objs.desc:SetText(desc)

    local hero_info = game.HeroCtrl.instance:GetHeroInfo(info.id)
    if hero_info then
        self._layout_objs.level:SetText(string.format(config.words[2209], hero_info.level))
    else
        self._layout_objs.level:SetText(config.words[2208])
    end
    local can_guide = hero_info and hero_info.level >= guild_lv[2] or false
    self._layout_objs.btn_guide:SetGray(not can_guide)
    self._layout_objs.btn_guide:SetTouchEnable(can_guide)
end

function HeroSetGuideItem:SetClickCallback(callback)
    self.click_callback = callback
end

return HeroSetGuideItem