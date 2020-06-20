local UIEffect = Class()

function UIEffect:_init()
    self.effect_id = nil
    self.wrapper = nil
end

function UIEffect:_delete()
    self:Reset()
end

function UIEffect:Init(graph, layer)
    self.graph = graph
    self.layer = layer
end

function UIEffect:Reset()
    if self.effect_id then
        game.EffectMgr.instance:StopEffectByID(self.effect_id)
        self.effect_id = nil
    end

    if self.wrapper then
        self.wrapper:setWrapTarget(nil, false)
        self.wrapper:Dispose()
        self.wrapper = nil
    end

    self:ResetNativeObject()

    self.graph = nil
    self.layer = nil
end

function UIEffect:CreateEffect(path)
    if self.effect_id then
        game.EffectMgr.instance:StopEffectByID(self.effect_id)
        self.effect_id = nil
    end

    local effect = game.EffectMgr.instance:CreateEffect(path, 120)
    if not self.wrapper then
        self.wrapper = self.graph:SetGameObject(effect:GetGameObject())
    else
        self.wrapper:setWrapTarget(effect:GetGameObject(), false)
    end

    effect:SetLoadCallBack(function()
        self.wrapper:CacheRenderers()

        if self.layer then
            effect:SetLayer(self.layer)
        end
    end)

    self.effect_id = effect:GetID()
    return effect
end

function UIEffect:StopEffect()
    if self.effect_id then
        game.EffectMgr.instance:StopEffectByID(self.effect_id)
        self.effect_id = nil
    end
    if self.wrapper then
        self.wrapper:setWrapTarget(nil, false)
    end
end

function UIEffect:ResetNativeObject()
    if self.graph then
        self.graph:SetNativeObject()
    end
end

game.UIEffect = UIEffect

return UIEffect
