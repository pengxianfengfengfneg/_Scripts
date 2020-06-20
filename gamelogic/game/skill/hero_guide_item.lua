local HeroGuideItem = Class(game.UITemplate)

local config_skill = config.skill
local config_hero = config.hero

function HeroGuideItem:_init(idx)
    self.index = idx 
end

function HeroGuideItem:OpenViewCallBack()
    self:Init()
end

function HeroGuideItem:CloseViewCallBack()
    if self.skill_item then
        self.skill_item:DeleteMe()
        self.skill_item = nil
    end
end

function HeroGuideItem:Init()
    self.txt_skill_name = self._layout_objs["txt_skill_name"]
    self.txt_hero_name = self._layout_objs["txt_hero_name"]
    self.txt_guide = self._layout_objs["txt_guide"]

    self.img_frame = self._layout_objs["img_frame"]
    self.img_icon = self._layout_objs["img_icon"]

    self:GetRoot():AddClickCallBack(function()
        game.SkillCtrl.instance:OpenHeroSetGuideView(self:GetSkillId())
    end)
end

function HeroGuideItem:GetSkillId()
    return self.skill_id
end

function HeroGuideItem:GetHeroId()
    return self.hero_id
end

function HeroGuideItem:GetIndex()
    return self.index
end

function HeroGuideItem:SetSkillInfo(skill_id, skill_name)
    self.skill_id = skill_id
    self.skill_name = skill_name

    self.txt_skill_name:SetText(self.skill_name)
end

local ColorFrame = {
    [1] = "hy_02",
    [2] = "yx_t2",
    [3] = "yx_t3",
    [4] = "yx_t4",
    [5] = "yx_t5",
}

function HeroGuideItem:UpdateGuideInfo(info)
    if self.skill_id ~= info.skill then
        return
    end

    self.hero_id = info.id

    local hero_cfg = config_hero[self.hero_id]
    if not hero_cfg then return end

    self.txt_hero_name:SetText(hero_cfg.name)

    self.is_actived = game.HeroCtrl.instance:IsHeroActived(self.hero_id)
    if  self.is_actived then
        self.is_used = game.SkillCtrl.instance:IsHeroUsed(self.hero_id)
        if self.is_used then
            local frame_res = ColorFrame[hero_cfg.color]

            self.img_frame:SetSprite("ui_common", frame_res)

            self.txt_guide:SetColor(table.unpack(game.Color.Brown))
            self.txt_guide:SetText(config.words[2213])
        else
            self.img_frame:SetSprite("ui_common", ColorFrame[1])

            self.txt_guide:SetColor(table.unpack(game.Color.Orange))
            self.txt_guide:SetText(config.words[2214])
        end
    else
        self.img_frame:SetSprite("ui_common", ColorFrame[1])

        self.txt_guide:SetColor(table.unpack(game.Color.Red))
        self.txt_guide:SetText(config.words[2208])
    end

    self.img_icon:SetSprite("ui_headicon", hero_cfg.icon)
end

function HeroGuideItem:IsHeroActived()
    return self.is_actived
end

function HeroGuideItem:IsHeroUsed()
    return self.is_used
end

return HeroGuideItem