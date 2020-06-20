local HeroCtrl = Class(game.BaseCtrl)

function HeroCtrl:_init()
    if HeroCtrl.instance ~= nil then
        error("HeroCtrl Init Twice!")
    end
    HeroCtrl.instance = self

    self.hero_view = require("game/hero/hero_view").New(self)
    self.hero_data = require("game/hero/hero_data").New(self)
    self.hero_info_view = require("game/hero/hero_info_view").New(self)
    self.pulse_hero_view = require("game/hero/pulse_hero_view").New(self)
    self.potential_train_view = require("game/hero/potential_train_view").New(self)
    self.change_potential_view = require("game/hero/change_potential_view").New(self)
    self.pulse_equip_view = require("game/hero/pulse_equip_view").New(self)
    self.draw_reward_view = require("game/hero/draw_reward_view").New(self)
    self.equip_info_view = require("game/hero/equip_info_view").New(self)
    self.hero_total_attr_view = require("game/hero/hero_total_attr_view").New(self)
    self.treasure_view = require("game/hero/treasure_view").New(self)
    self.pulse_view = require("game/hero/pulse_view").New(self)
    self.hero_active_view = require("game/hero/hero_active_view").New(self)

    self:RegisterAllProtocal()

end

function HeroCtrl:_delete()
    self.hero_view:DeleteMe()
    self.hero_data:DeleteMe()
    self.hero_info_view:DeleteMe()
    self.pulse_hero_view:DeleteMe()
    self.potential_train_view:DeleteMe()
    self.change_potential_view:DeleteMe()
    self.pulse_equip_view:DeleteMe()
    self.draw_reward_view:DeleteMe()
    self.equip_info_view:DeleteMe()
    self.hero_total_attr_view:DeleteMe()
    self.treasure_view:DeleteMe()
    self.pulse_view:DeleteMe()
    self.hero_active_view:DeleteMe()

    HeroCtrl.instance = nil
end

function HeroCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(41802, "OnHeroInfo")
    self:RegisterProtocalCallback(41804, "OnHeroActive")
    self:RegisterProtocalCallback(41806, "OnHeroUpgrade")
    self:RegisterProtocalCallback(41808, "OnHeroOneKeyUpgrade")
    self:RegisterProtocalCallback(41810, "OnComposeItem")
    self:RegisterProtocalCallback(41812, "OnHeroSenior")
    self:RegisterProtocalCallback(41814, "OnHeroGuide")

    self:RegisterProtocalCallback(41816, "OnHeroModifyGuide")
    self:RegisterProtocalCallback(41818, "OnHeroUseGuide")

    self:RegisterProtocalCallback(41902, "OnPulseInfo")
    self:RegisterProtocalCallback(41904, "OnActivePulse")
    self:RegisterProtocalCallback(41906, "OnTrainPulse")
    self:RegisterProtocalCallback(41908, "OnChangePotential")
    self:RegisterProtocalCallback(41910, "OnWearEquip")
    self:RegisterProtocalCallback(41912, "OnTakeOffEquip")

    self:RegisterProtocalCallback(42102, "OnTreasureInfo")
    self:RegisterProtocalCallback(42104, "OnDrawTreasure")
    self:RegisterProtocalCallback(42106, "OnGetReward")
end

function HeroCtrl:OpenView(index)
    self.hero_view:Open(index)
end

function HeroCtrl:OpenHeroInfoView(id)
    self.hero_info_view:Open(id)
end

function HeroCtrl:OnHeroInfo(data)
    self.hero_data:SetHeroesInfo(data)
    self:FireEvent(game.RedPointEvent.UpdateRedPoint, game.OpenFuncId.Hero, self:GetTipState())
end

function HeroCtrl:GetHeroesInfo()
    return self.hero_data:GetHeroesInfo()
end

function HeroCtrl:GetHeroInfo(id)
    return self.hero_data:GetHeroInfo(id)
end

function HeroCtrl:GetHeroGuideInfo(guide_id)
    return self.hero_data:GetHeroGuideInfo(guide_id)
end

function HeroCtrl:SetHeroInfoList(list)
    self.hero_info_list = list
end

function HeroCtrl:GetHeroInfoList()
    return self.hero_info_list
end

function HeroCtrl:SendHeroActive(id)
    self:SendProtocal(41803, {id = id})
end

function HeroCtrl:OnHeroActive(data)
    local hero = {id = data.id, level = 1, exp = 0, legend = 0}
    self.hero_data:AddHeroActive(hero)
    self:FireEvent(game.HeroEvent.HeroActive, data.id, hero)
    self.hero_active_view:Open(data.id)
end

function HeroCtrl:SendHeroUpgrade(id, item, num)
    self:SendProtocal(41805, {id = id, item = item, num = num})
end

function HeroCtrl:OnHeroUpgrade(data)
    self.hero_data:SetHeroUpgrade(data)
    self:FireEvent(game.HeroEvent.HeroUpgrade, data.id, data)
end

function HeroCtrl:SendHeroOneKeyUpgrade()
    self:SendProtocal(41807)
end

function HeroCtrl:OnHeroOneKeyUpgrade(data)
    self.hero_data:SetHeroOneKeyUpgrade(data)
    self:FireEvent(game.HeroEvent.HeroUpgradeAll, data)
end

function HeroCtrl:SendHeroActiveSenior(id)
    self:SendProtocal(41811, {id = id})
end

function HeroCtrl:OnHeroSenior(data)
    self.hero_data:SetHeroActiveSenior(data.id)
    self:FireEvent(game.HeroEvent.HeroActiveSenior, data.id, data)
end

function HeroCtrl:SendComposeItem(id, num)
    self:SendProtocal(41809, {item = id, num = num})
end

function HeroCtrl:OnComposeItem()
    self:FireEvent(game.HeroEvent.ComposeItem)
end

function HeroCtrl:SendHeroGuide(hero_id, skill_id, type)
    self:SendProtocal(41813, {id = hero_id, skill = skill_id, legend = type})
end

function HeroCtrl:OnHeroGuide(data)
    self:FireEvent(game.HeroEvent.GuideChange, data)
end

function HeroCtrl:GetHeroLengend(hero_id)
    return self.hero_data:GetHeroLengend(hero_id)
end

function HeroCtrl:SendHeroModifyGuide(info)
    local proto = {
        guide = info
    }
    self:SendProtocal(41815, proto)
end

function HeroCtrl:OnHeroModifyGuide(data)
    --[[
        "guide__U|CltHeroGuide|",
    ]]

    self.hero_data:OnHeroModifyGuide(data)
end

function HeroCtrl:SendHeroUseGuide(id)
    local proto = {
        id = id
    }
    self:SendProtocal(41817, proto)
end

function HeroCtrl:OnHeroUseGuide(data)
    --[[
        "id__C",
        "skills__T__id@I##lv@H##hero@C##legend@C",
    ]]
    self.hero_data:OnHeroUseGuide(data)

    self:FireEvent(game.HeroEvent.HeroUseGuide, data.skills, data.id)
end

function HeroCtrl:IsHeroActived(hero_id)
    return self.hero_data:IsHeroActived(hero_id)
end

function HeroCtrl:IsSkillHasHero(skill_id)
    return self.hero_data:IsSkillHasHero(skill_id)
end

function HeroCtrl:SendPulseInfo()
    self:SendProtocal(41901)
end

function HeroCtrl:OnPulseInfo(data)
    self.hero_data:SetPulseInfo(data.channels)
end

function HeroCtrl:GetPulseInfo()
    return self.hero_data:GetPulseInfo()
end

function HeroCtrl:GetPulseInfoByID(id)
    return self.hero_data:GetPulseInfoByID(id)
end

function HeroCtrl:SendActivePulse(pulse_id, hero_id)
    self:SendProtocal(41903, {id = pulse_id, hero = hero_id})
end

function HeroCtrl:OnActivePulse(data)
    self.hero_data:SetPulseInfo(data.channels)
    self.pulse_hero_view:Close()
    self:FireEvent(game.HeroEvent.HeroPulseActive, data.channel)
end

function HeroCtrl:SendTrainPulse(pulse_id, type)
    self:SendProtocal(41905, {id = pulse_id, type = type})
end

function HeroCtrl:OnTrainPulse(data)
    self.hero_data:SetTrainPulse(data)
    self:FireEvent(game.HeroEvent.HeroPulseTrain, data)
end

function HeroCtrl:SendChangePotential(pulse_id, type, attr)
    self:SendProtocal(41907, {id = pulse_id, type = type, attr = attr})
end

function HeroCtrl:OnChangePotential(data)
    self.hero_data:SetChangePotential(data)
    self:FireEvent(game.HeroEvent.HeroChangePotential, data)
end

function HeroCtrl:SendWearEquip(pulse_id, pos)
    self:SendProtocal(41909, {id = pulse_id, pos = pos})
end

function HeroCtrl:OnWearEquip(data)
    self.hero_data:SetWearEquip(data)
    self:FireEvent(game.HeroEvent.HeroPulseWearEquip, data)
    self.pulse_equip_view:Close()
end

function HeroCtrl:SendTakeOffEquip(pulse_id, pos)
    self:SendProtocal(41911, {id = pulse_id, pos = pos})
end

function HeroCtrl:OnTakeOffEquip(data)
    self.hero_data:SetWearEquip(data)
    self:FireEvent(game.HeroEvent.HeroPulseWearEquip, data)
end

function HeroCtrl:OpenPulseHeroView(id)
    self.pulse_hero_view:Open(id)
end

function HeroCtrl:OpenPotentialTrainView(id)
    self.potential_train_view:Open(id)
end

function HeroCtrl:OpenChangePotentialView(id, type)
    self.change_potential_view:Open(id, type)
end

function HeroCtrl:OpenPulseEquipView(id, pos)
    self.pulse_equip_view:Open(id, pos)
end

function HeroCtrl:SendTreasureInfo()
    self:SendProtocal(42101)
end

function HeroCtrl:OnTreasureInfo(data)
    self.hero_data:SetTreasureInfo(data)
end

function HeroCtrl:GetTreasureInfo()
    return self.hero_data:GetTreasureInfo()
end

function HeroCtrl:SendDrawTreasure(times)
    self:SendProtocal(42103, {times = times})
end

function HeroCtrl:OnDrawTreasure(data)
    self.hero_data:SetDrawTimes(data)
    self.draw_reward_view:Open(data.rewards)
    self:FireEvent(game.HeroEvent.PulseTreasureDraw, data)
end

function HeroCtrl:SendGetReward(id)
    self:SendProtocal(42105, {id = id})
end

function HeroCtrl:OnGetReward(data)
    self.hero_data:SetTreasreReward(data)
    self:FireEvent(game.HeroEvent.PulseTreasureDraw, data)
end

function HeroCtrl:GetPulseAttr()
    return self.hero_data:GetPulseAttr()
end

function HeroCtrl:GetPulseFight()
    return self.hero_data:GetPulseFight()
end

function HeroCtrl:OpenEquipInfoView(pulse, pos, id, state, btn_visible, in_bag)
    self.equip_info_view:Open(pulse, pos, id, state, btn_visible, in_bag)
end

function HeroCtrl:OpenHeroTotalAttrView()
    self.hero_total_attr_view:Open()
end

function HeroCtrl:OpenPulseView(id)
    self.pulse_view:Open(id)
end

function HeroCtrl:OpenTreasureView()
    self.treasure_view:Open()
end

function HeroCtrl:SetBookToBot()
    self.hero_view:SetBookToBot()
end

function HeroCtrl:GetHeroTipState(hero_id)
    return self.hero_data:GetHeroTipState(hero_id)
end

function HeroCtrl:GetTipState()
    return self.hero_data:GetTipState()
end

function HeroCtrl:GetAllChipTipState()
    return self.hero_data:GetAllChipTipState()
end

function HeroCtrl:SaveFilterState(val)
    self.filter_state = val
end

function HeroCtrl:GetFilterState()
    return self.filter_state or false
end

function HeroCtrl:GetBookFight()
    return self.hero_data:GetBookFight()
end

function HeroCtrl:GetPulseChannelFight(id)
    return self.data:GetPulseChannelFight(id)
end

game.HeroCtrl = HeroCtrl

return HeroCtrl