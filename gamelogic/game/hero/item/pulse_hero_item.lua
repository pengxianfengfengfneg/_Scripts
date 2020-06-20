local PulseHeroItem = Class(game.UITemplate)

local limit_lv = config.sys_config.channel_active_hero_lv.value

function PulseHeroItem:OpenViewCallBack()
    self._layout_objs.btn_chose:AddClickCallBack(function()
        game.HeroCtrl.instance:SendActivePulse(self.cur_pulse_id, self.hero_cfg.id)
    end)
end

function PulseHeroItem:SetHeroInfo(cfg)
    self.hero_cfg = cfg
    local info = game.HeroCtrl.instance:GetHeroInfo(cfg.id)
    self._layout_objs.head:SetSprite("ui_headicon", cfg.icon)
    self._layout_objs.hero_bg:SetSprite("ui_common", "yx_t" .. cfg.color)
    self._layout_objs.name:SetText(cfg.name)
    self._layout_objs.level:SetText(string.format(config.words[2209], info.level))
    self._layout_objs.btn_chose:SetTouchEnable(info.level >= limit_lv)
    self._layout_objs.btn_chose:SetGray(info.level < limit_lv)
    if info.level >= limit_lv then
        local pulse_info = game.HeroCtrl.instance:GetPulseInfo()
        local pulse_id = 0
        for i, v in pairs(pulse_info) do
            if v.channel.hero == cfg.id then
                pulse_id = v.channel.id
                break
            end
        end
        if pulse_id == 0 then
            self._layout_objs.text:SetText("")
        else
            self._layout_objs.text:SetText(config.words[3109] .. " " .. config.pulse[pulse_id].name)
        end
    else
        self._layout_objs.text:SetText(config.words[3121])
    end
    local career = game.RoleCtrl.instance:GetCareer()
    local attr_pulse = config.hero_level[cfg.id][info.level].attr_pulse[career]
    local text
    if attr_pulse[1] < 100 then
        text = config.combat_power_battle[attr_pulse[1]].name .. "+" .. attr_pulse[2]
    else
        text = config.combat_power_base[attr_pulse[1] - 100].name .. "+" .. attr_pulse[2]
    end
    self._layout_objs.attr:SetText(text)
end

function PulseHeroItem:SetPulseID(id)
    self.cur_pulse_id = id
end

return PulseHeroItem