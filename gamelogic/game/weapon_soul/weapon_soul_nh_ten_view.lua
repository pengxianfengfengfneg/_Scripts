local WeaponSoulNHTenView = Class(game.BaseView)

function WeaponSoulNHTenView:_init(ctrl)
    self._package_name = "ui_weapon_soul"
    self._com_name = "weapon_soul_nh_ten_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function WeaponSoulNHTenView:_delete()
end

function WeaponSoulNHTenView:OpenViewCallBack(data)

    self.select_type = data.type

    self.batch_ret = data.batch_ret

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[6108])

    self._layout_objs["over_btn"]:AddClickCallBack(function()
        local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[6112])
        msg_box:SetOkBtn(function()
            msg_box:DeleteMe()
            self:Close()
        end)
        msg_box:SetCancelBtn(function()
            msg_box:DeleteMe()
            end)
        msg_box:Open()
    end)

    self._layout_objs["save_btn"]:AddClickCallBack(function()
        self:OnSave()
        self:Close()
    end)

    --标题
    self:SetListTitle(data)

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/weapon_soul/weapon_soul_nh_item").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:SetItemNum(#self.batch_ret)
end

function WeaponSoulNHTenView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function WeaponSoulNHTenView:GetListData()
    return self.batch_ret
end

function WeaponSoulNHTenView:OnSave()

    local select_index_list = {}

    self.ui_list:Foreach(function(item)
        if item:GetSelectFlag() then

            local t = {}
            t.index = item.ret_index
            table.insert(select_index_list, t)
        end
    end)

    game.WeaponSoulCtrl.instance:CsWarriorSoulSaveConden(self.select_type, select_index_list)
end

function WeaponSoulNHTenView:SetListTitle(data)
    local batch_ret = data.batch_ret
    local single_ret = batch_ret[1]
    local alters = single_ret.ret.alters

    for k, v in ipairs(alters) do
        local attr_type = v.id
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
        self._layout_objs["title_attr"..k]:SetText(attr_name)
    end
end

return WeaponSoulNHTenView