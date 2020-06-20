local StrengthenFightView = Class(game.BaseView)

function StrengthenFightView:_init(ctrl)
    self._package_name = "ui_strengthen"
    self._com_name = "strengthen_fight_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
    self.ctrl = ctrl
end

function StrengthenFightView:OpenViewCallBack(type)
    self._layout_objs.txt_fight:SetText(string.format(config.words[6201], game.Scene.instance:GetMainRolePower()))

    local title_list = self.ctrl:GetTitleList(type)
    for k, v in ipairs(title_list) do
        self._layout_objs["txt_fight"..k]:SetText(string.format(config.words[6202], v.name, v.fight))
    end
end

function StrengthenFightView:OnEmptyClick()
    self:Close()
end

return StrengthenFightView
