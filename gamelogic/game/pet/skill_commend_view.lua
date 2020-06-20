local SkillCommendView = Class(game.BaseView)

function SkillCommendView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "commend_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function SkillCommendView:OnEmptyClick()
    self:Close()
end

function SkillCommendView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1502])

    local list = self:CreateList("list", "game/pet/item/skill_commend_item")
    list:SetRefreshItemFunc(function(item, idx)
        local info = config.pet_skill_commend[idx]
        item:SetItemInfo(info)
        item:SetBg(idx % 2 == 1)
    end)
    list:SetItemNum(#config.pet_skill_commend)
end


return SkillCommendView
