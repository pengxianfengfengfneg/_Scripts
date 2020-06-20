local SkillSettingItem = Class(game.UITemplate)

local config_skill = config.skill

function SkillSettingItem:_init(skill_id, idx)
    self.skill_id = skill_id
    self.index = idx 
end

function SkillSettingItem:OpenViewCallBack()
    self:Init()
    self:InitSkillItem()

    self:BindEvent(game.SkillEvent.SkillBloodSettingChange, function(id, val)
        if id == self.skill_id then
            self:UpdateText(val)
        end
    end)
end

function SkillSettingItem:CloseViewCallBack()
    if self.skill_item then
        self.skill_item:DeleteMe()
        self.skill_item = nil
    end
end

function SkillSettingItem:Init()
    self.btn_checkbox = self._layout_objs["btn_checkbox"]
    self.btn_checkbox:AddChangeCallback(function(event_type)
        local is_selected = (event_type==game.ButtonChangeType.Selected)
        self:OnClickBtnCheckbox(is_selected)
    end)

    self._layout_objs["btn_setting"]:AddClickCallBack(function()
        game.SkillCtrl.instance:OpenSkillBloodSettingView()
    end)
end

function SkillSettingItem:InitSkillItem()
    self.skill_item = require("game/skill/item/skill_item_circle").New()
    self.skill_item:SetVirtual(self._layout_objs["skill_item"])
    self.skill_item:Open()

    local info = {
        id = self.skill_id,
        lv = 1   
    }
    self.skill_item:SetItemInfo(info)

    local skill_name = self.skill_item:GetName()
    local txt_name = self._layout_objs["txt_name"]
    txt_name:SetText(skill_name)

    local ctrller = self:GetRoot():GetController("c1")
    local skill_cfg = config_skill[self.skill_id][1]
    if #skill_cfg.condition > 0 and skill_cfg.condition[1] == 2 then
        ctrller:SetSelectedIndexEx(1)

        local val = game.SysSettingCtrl.instance:GetLocal(self.skill_id)
        if val == -1 then
            val = math.floor(skill_cfg.condition[2] * 100)
        end
        self:UpdateText(val)
    else
        ctrller:SetSelectedIndexEx(0)
    end
end

function SkillSettingItem:OnClickBtnCheckbox(is_selected)
    self._is_selected = is_selected

    if self.select_event then
        self.select_event(self)
    end
end

function SkillSettingItem:SetSelected(val)
    self._is_selected = val

    self.btn_checkbox:SetSelected(val)
end

function SkillSettingItem:IsSelected()
    return self._is_selected
end

function SkillSettingItem:AddSelectEvent(func)
    self.select_event = func
end

function SkillSettingItem:GetSkillId()
    return self.skill_id
end

function SkillSettingItem:GetIndex()
    return self.index
end

function SkillSettingItem:UpdateText(val)
    self._layout_objs["txt_setting"]:SetText(string.format(config.words[2231], math.floor(val)))
end

return SkillSettingItem