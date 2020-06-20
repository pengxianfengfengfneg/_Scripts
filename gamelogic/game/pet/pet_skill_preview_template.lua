local SkillPreview = Class(game.UITemplate)

function SkillPreview:_init(parent, param)
    self.parent_view = parent
    self.idx = param
end

function SkillPreview:OpenViewCallBack()
    self.list = self:CreateList("list", "game/skill/item/skill_item_rect")
    self.list:AddClickItemCallback(function(obj)
        self:SetSelectSkill(obj:GetItemInfo())
    end)

    local skill_list = {}
    for _, v in pairs(config.pet_skill) do
        if v.type == self.idx then
            table.insert(skill_list, v)
        end
    end

    self.list:SetRefreshItemFunc(function(item, index)
        local skill = skill_list[index]
        item:SetItemInfo(skill)
        item:SetSelect(false)
    end)
    self.list:SetItemNum(#skill_list)

    self.eff_template = require("game/character/effect_template").New()

    self:SetSelectSkill(skill_list[1])
end

function SkillPreview:CloseViewCallBack()
    if self.eff_template then
        self.eff_template:DeleteMe()
        self.eff_template = nil
    end
end

function SkillPreview:SetSelectSkill(skill)
    self.cur_skill = skill
    if skill then
        self._layout_objs.name:SetText(skill.name)
        self._layout_objs.type:SetText(config.words[1510 + skill.fit_type])
        self._layout_objs.normal_desc:SetText(skill.normal)
        self._layout_objs.senior_desc:SetText(skill.senior)
        self.list:Foreach(function(obj)
            local info = obj:GetItemInfo()
            obj:SetSelect(skill.id == info.id)
        end)

        local effect = config.skill[skill.id][1].effect[1]
        if effect then
            local eff = self.eff_template:CreateEffect(self._layout_objs.effect, string.format("effect/skill/%s.ab", effect[2]))
            eff:SetLoopPlay(true)
            eff:SetRotation(90, 0, 0)
            eff:SetPosition(0, 0, 5)
        else
            if self.eff_template then
                self.eff_template:ClearEffect()
            end
        end
    else
        if self.eff_template then
            self.eff_template:ClearEffect()
        end
        self._layout_objs.name:SetText("")
        self._layout_objs.type:SetText("")
        self._layout_objs.normal_desc:SetText("")
        self._layout_objs.senior_desc:SetText("")
    end
end

return SkillPreview
