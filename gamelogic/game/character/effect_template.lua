local EffectTemplate = Class()

function EffectTemplate:_init()
end

function EffectTemplate:_delete()
    self:ClearEffect()
end

function EffectTemplate:ClearEffect()
    if self.eff then
        game.EffectMgr.instance:StopEffect(self.eff)
        self.eff = nil
    end
    if self.render_image then
        self.render_image:Dispose()
        self.render_image = nil
    end
end

function EffectTemplate:CreateEffect(parent, path)
    self:ClearEffect()
    self.eff = game.EffectMgr.instance:CreateEffect(path)
    self.render_image = parent:SetModel(self.eff:GetGameObject())
    self.render_image:SetCullingMask(game.LayerMask.Effect)
    self:SetRotateEnable(false)
    return self.eff
end

function EffectTemplate:SetRotateEnable(val)
    self.render_image:SetRotateEnable(val)
end

return EffectTemplate