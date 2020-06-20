local HeroGuideItem = Class(game.UITemplate)

local guide_limit = config.sys_config.hero_active_lv.value
local legend_limit = config.sys_config.hero_active_legend_lv.value

function HeroGuideItem:OpenViewCallBack()
    self:BindEvent(game.HeroEvent.GuideChange, function(data)
        if data.skill == self.skill_id then
            self:SetBtnState()
        end
    end)

    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    self._layout_objs.btn_guide:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then     
            if main_role:IsFightState() then
                game.GameMsgCtrl.instance:PushMsg(config.words[528])
                return
            end
        end

        local guide_cfg = guide_limit
        if self.guide_type == 1 then
            guide_cfg = legend_limit
        end
        if role_lv >= guide_cfg[1] then
            local hero_info = game.HeroCtrl.instance:GetHeroInfo(self.info.id)
            if hero_info.level >= guide_cfg[2] then
                game.HeroCtrl.instance:SendHeroGuide(self.info.id, self.skill_id, self.guide_type)
            else
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[2211], guide_cfg[2]))
            end
        else
            game.GameMsgCtrl.instance:PushMsg(string.format(config.words[2210], guide_cfg[1]))
        end
    end)

    self._layout_objs.btn_disable:AddClickCallBack(function()
        game.HeroCtrl.instance:SendHeroGuide(0, self.skill_id, self.guide_type)
    end)
end

function HeroGuideItem:SetHeroInfo(info, skill_id)
    self.info = info
    self.skill_id = skill_id
    self._layout_objs.hero_name:SetText(info.name)
    self._layout_objs.head_bg:SetSprite("ui_common", "yx_t" .. info.color)
    self._layout_objs.head:SetSprite("ui_headicon", info.icon)
end

function HeroGuideItem:SetBtnState()
    local hero_info = game.HeroCtrl.instance:GetHeroInfo(self.info.id)
    local guide_hero, legend = game.SkillCtrl.instance:GetSkillHeroLegend(self.skill_id)
    if hero_info then
        self._layout_objs.level:SetText(string.format(config.words[2209], hero_info.level))
        self._layout_objs.btn_guide:SetVisible(guide_hero ~= self.info.id or (guide_hero == self.info.id and legend ~= self.guide_type))
        self._layout_objs.btn_guide:SetGray(false)
        self._layout_objs.btn_guide:SetTouchEnable(true)
        self._layout_objs.btn_disable:SetVisible(guide_hero == self.info.id and legend == self.guide_type)
    else
        self._layout_objs.level:SetText(config.words[2208])
        self._layout_objs.btn_disable:SetVisible(false)
        self._layout_objs.btn_guide:SetVisible(true)
        self._layout_objs.btn_guide:SetGray(true)
        self._layout_objs.btn_guide:SetTouchEnable(false)
    end
end

function HeroGuideItem:SetGuideType(type)
    self.guide_type = type
    local desc = config.hero_effect[self.info.id][self.skill_id][type][1].zd_desc
    self._layout_objs.desc:SetText(desc)

    self:SetBtnState()
end

return HeroGuideItem