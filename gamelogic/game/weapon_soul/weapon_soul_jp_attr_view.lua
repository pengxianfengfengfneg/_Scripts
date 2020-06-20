local WeaponSoulJPAttrView = Class(game.BaseView)

function WeaponSoulJPAttrView:_init(ctrl)
    self._package_name = "ui_weapon_soul"
    self._com_name = "weapon_soul_jp_attr_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function WeaponSoulJPAttrView:OpenViewCallBack()

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[6120])

    local weapon_soul_data = self.ctrl:GetData()
    local attr_list = weapon_soul_data:GetActivedJPAttr()
    self.attr_list = attr_list

    if next(attr_list) then
        self:SetAttrList(attr_list)
        self._layout_objs["tips_txt"]:SetVisible(false)
    else
        self._layout_objs["tips_txt"]:SetVisible(true)
    end
end

function WeaponSoulJPAttrView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function WeaponSoulJPAttrView:SetAttrList(attr_list)

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/weapon_soul/weapon_soul_jp_attr_item").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:SetItemNum(#attr_list)
end

function WeaponSoulJPAttrView:GetListData()
    return self.attr_list
end

return WeaponSoulJPAttrView