local SkillItemRect = Class(game.UITemplate)

function SkillItemRect:_init()
end

function SkillItemRect:_delete()
end

function SkillItemRect:SetItemInfo(info)
    self.item_info = info
    self:ResetItem()

    local skill_config = config.skill[info.id][info.lv or 1]
    self._layout_objs["icon"]:SetVisible(true)
    self._layout_objs["icon"]:SetSprite("ui_skill_icon", skill_config.icon)
    self:SetLevel(info.lv)

end

function SkillItemRect:ResetItem()
    self._layout_objs["icon"]:SetVisible(false)
    self._layout_objs["lock"]:SetVisible(false)
    self._layout_objs["btn_add"]:SetVisible(false)
    self._layout_objs["txt_open"]:SetVisible(false)
    self:SetLevel()
end

function SkillItemRect:SetLevel(lv)
    if lv then
        self._layout_objs.lv:SetText(lv .. config.words[1217])
    else
        self._layout_objs.lv:SetText("")
    end
end

function SkillItemRect:SetLevelText(txt)
    self._layout_objs.lv:SetText(txt)
end

function SkillItemRect:AddClickEvent(func)
    self.click_func = func
    self:GetRoot():AddClickCallBack(function()
        if self.click_func then
            self.click_func()
        end
    end)
end

function SkillItemRect:SetShowInfo()
    self:GetRoot():AddClickCallBack(function()
        if self.item_info then
            game.SkillCtrl.instance:OpenSkillInfoView(self.item_info)
        end
    end)
end

function SkillItemRect:SetSkillIcon(name)
    self._layout_objs["icon"]:SetVisible(true)
    self._layout_objs["icon"]:SetSprite("ui_skill_icon", name)
end

function SkillItemRect:SetGray(val)
    self._layout_objs["icon"]:SetGray(val)
end

function SkillItemRect:GetItemInfo()
    return self.item_info
end

function SkillItemRect:SetSelect(val)
    self._layout_objs.select:SetVisible(val)
end

function SkillItemRect:SetAddCallBack(func)
    self._layout_objs.btn_add:AddClickCallBack(func)
end

function SkillItemRect:SetBtnAddVisible(val)
    self._layout_objs.btn_add:SetVisible(val)
end

function SkillItemRect:SetLockVisible(val)
    self._layout_objs.lock:SetVisible(val)
end

function SkillItemRect:SetOpenText(txt)
    self._layout_objs.txt_open:SetVisible(true)
    self._layout_objs.txt_open:SetText(txt)
end

return SkillItemRect