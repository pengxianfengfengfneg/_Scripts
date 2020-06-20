local OpenFuncSkillTemplate = Class(game.UITemplate)

function OpenFuncSkillTemplate:_init(parent)
    self.parent = parent
    self.ctrl = game.OpenFuncCtrl.instance
    self._package_name = "ui_open_func"
    self._com_name = "open_func_skill_template"
end

function OpenFuncSkillTemplate:OpenViewCallBack()
    self:Init()
end

function OpenFuncSkillTemplate:CloseViewCallBack()
    
end

function OpenFuncSkillTemplate:OnEmptyClick()
    self:DelTimer()
    self.parent:CreateShowTimer()
end

function OpenFuncSkillTemplate:Init()
    self:GetRoot():AddClickCallBack(handler(self, self.OnEmptyClick))
end

function OpenFuncSkillTemplate:Active(data)
    local skill = config.skill[data.skill_id][data.skill_level]
    self:SetSkillName(skill.name)
    self:SetSkillSprite(skill.icon)
    self:PlayFade()
    self:PlayEffect()
    self:AutoClose()
    if not game.GuideCtrl.instance:IsOpenView() and game.MainUICtrl.instance:IsViewOpen() then
        game.MainUICtrl.instance:SwitchToFighting()
    end
end

function OpenFuncSkillTemplate:Inactive()
    self:ClearUIEffect()
    self:DelTimer()
end

function OpenFuncSkillTemplate:SetSkillName(name)
    self._layout_objs["txt_skill_name"]:SetText(name)
end

function OpenFuncSkillTemplate:SetSkillSprite(icon)
    self._layout_objs["img_skill"]:SetSprite("ui_skill_icon", icon)
end

function OpenFuncSkillTemplate:PlayFade()
    self:GetRoot():PlayTransition("trans_fade")   
end

function OpenFuncSkillTemplate:PlayEffect()
    local ui_effect = self:CreateUIEffect(self._layout_objs.wrapper,  "effect/ui/skill_open.ab")
    ui_effect:SetLoop(true)
    ui_effect:Play()
end

function OpenFuncSkillTemplate:AutoClose()
    self:DelTimer()
    self.timer = global.TimerMgr:CreateTimer(5, function()
        self.parent:CreateShowTimer()
        return true
    end) 
end

function OpenFuncSkillTemplate:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

return OpenFuncSkillTemplate
