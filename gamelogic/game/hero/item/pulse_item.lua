local PulseItem = Class(game.UITemplate)

--¾­Âö
function PulseItem:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(function()
        if self.view_others_mode == true then
            return
        end
        local role_lv = game.RoleCtrl.instance:GetRoleLevel()
        if role_lv < self.pulse_cfg.level then
            game.GameMsgCtrl.instance:PushMsg(config.words[1549])
        else
            self:FireEvent(game.HeroEvent.HeroPulseSelect, self.pulse_cfg)
            game.HeroCtrl.instance:OpenPulseView(self.pulse_cfg.id)
        end
    end)
end

function PulseItem:CloseViewCallBack()
    self.role_lv = nil
    self.pulse_info = nil
end

function PulseItem:SetPulseInfo(cfg)
    self.pulse_cfg = cfg
    self._layout_objs.image:SetSprite("ui_hero", string.format("jm_%02d", 5 + cfg.id))

    self:SetPulseState()
end

function PulseItem:SetPulseState()
    if self.pulse_info == nil then
        self.pulse_info = game.HeroCtrl.instance:GetPulseInfoByID(self.pulse_cfg.id)
    end

    if self.role_lv == nil then
        self.role_lv = game.RoleCtrl.instance:GetRoleLevel()
    end
    if self.pulse_info and self.pulse_info.hero ~= 0 then
        self._layout_objs.text:SetText(config.words[3109])
    else
        if self.role_lv >= self.pulse_cfg.level then
            self._layout_objs.text:SetText(config.words[3110])
        else
            self._layout_objs.text:SetText(self.pulse_cfg.level .. config.words[3108])
        end
    end
end

function PulseItem:SetOthersMode()
    self.view_others_mode = true
end

function PulseItem:SetOthersInfo(lv, pulse_info)
    self.role_lv = lv
    self.pulse_info = pulse_info
end

return PulseItem