local PotentialItem = Class(game.UITemplate)

function PotentialItem:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(function()
        self:FireEvent(game.HeroEvent.HeroPotentialSelect, self.info)
    end)

    self:BindEvent(game.HeroEvent.HeroPulseTrain, function(data)
        if self.info.type == data.type then
            self.info.val = data.val
            self:SetPotentialInfo(self.info, self.pulse_id)
            self:FireEvent(game.HeroEvent.HeroPotentialSelect, self.info)
        end
    end)

    self:BindEvent(game.HeroEvent.HeroChangePotential, function(data)
        if self.info.type == data.type then
            self.info.val = data.val
            self.info.id = data.attr
            self:SetPotentialInfo(self.info, self.pulse_id)
            self:FireEvent(game.HeroEvent.HeroPotentialSelect, self.info)
        end
    end)

    self._layout_objs.btn_change:AddClickCallBack(function()
        game.HeroCtrl.instance:OpenChangePotentialView(self.pulse_id, self.info)
    end)
end

function PotentialItem:SetPotentialInfo(info, pulse_id)
    self.info = info
    self.pulse_id = pulse_id
    self._layout_objs.potential:SetText(config.words[3110 + info.type])
    local cfg = config.pulse_potential[info.id]
    self._layout_objs.attr:SetText(cfg.name)
    self._layout_objs.bar:SetValue(math.floor(info.val / 10000 * cfg.limit))
    self._layout_objs.bar:SetMax(cfg.limit)
    self.limit = cfg.limit
    for j, val in ipairs(config.pulse_train) do
        if val.low <= info.val and info.val <= val.high then
            local clr = cc.GoodsColor[val.color]
            self._layout_objs.attr:SetColor(clr.x, clr.y, clr.z, clr.w)
            break
        end
    end
end

function PotentialItem:SetSelect(val)
    self._layout_objs.select:SetVisible(val)
end

function PotentialItem:SetBtnTouchEnable(val)
    self._layout_objs.btn_change:SetTouchEnable(val)
end

function PotentialItem:GetLimit()
    return self.limit or 0
end

return PotentialItem