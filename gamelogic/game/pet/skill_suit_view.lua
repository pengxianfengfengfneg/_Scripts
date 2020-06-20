local SkillSuitView = Class(game.BaseView)

function SkillSuitView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "skill_suit_view"
    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.None

    self.ctrl = ctrl
end

function SkillSuitView:OpenViewCallBack(info)
    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)

    local suit_lv = self:CalcSuitLevel(info)
    local str_format = "[color=#5fc934]%s[/color]"

    local pet_cfg = config.pet[info.cid]
    local pet_add_cfg = config.pet_skill_suit[pet_cfg.carry_lv][pet_cfg.quality]
    local level_text, attr_text, value_text = "", "", ""
    for i, v in ipairs(pet_add_cfg) do
        local cond_cfg = config.pet_skill_suit_cond[i]
        if i <= suit_lv then
            level_text = level_text .. string.format(str_format, string.format(config.words[1542], cond_cfg.num, cond_cfg.level))
        else
            level_text = level_text .. string.format(config.words[1542], cond_cfg.num, cond_cfg.level)
        end
        local attrs = v.outer
        if pet_cfg.type == 2 then
            attrs = v.inner
        elseif pet_cfg.type == 3 then
            attrs = v.balance
        end
        for _, val in ipairs(attrs) do
            local text = config.words[1541]
            if val[1] < 100 then
                text = config.combat_power_battle[val[1]].name
            end
            if i <= suit_lv then
                value_text = value_text .. string.format(str_format, "+" .. val[2])
                text = string.format(str_format, text)
            else
                value_text = value_text .. "+" .. val[2]
            end
            attr_text = attr_text .. text .. "\n"
            value_text = value_text .. "\n"
            level_text = level_text .. "\n"
        end
    end

    self._layout_objs.attr_text:SetText(attr_text)
    self._layout_objs.value_text:SetText(value_text)
    self._layout_objs.level_text:SetText(level_text)
end

function SkillSuitView:CalcSuitLevel(info)
    local skill_suit = {}
    for _, v in pairs(info.skills) do
        for j = 1, v.lv do
            if skill_suit[j] then
                skill_suit[j] = skill_suit[j] + 1
            else
                skill_suit[j] = 1
            end
        end
    end
    local suit_lv = 0
    for _, v in ipairs(config.pet_skill_suit_cond) do
        if skill_suit[v.level] and skill_suit[v.level] >= v.num then
            suit_lv = v.suit_lv
        end
    end
    return suit_lv
end

return SkillSuitView