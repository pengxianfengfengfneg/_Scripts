local FoundryStrenSuitAttrView = Class(game.BaseView)

function FoundryStrenSuitAttrView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "stren_suit_view"
    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function FoundryStrenSuitAttrView:_delete()
end

function FoundryStrenSuitAttrView:OpenViewCallBack()

	self._layout_objs["bg"]:SetTouchEnable(true)
	self._layout_objs["bg"]:AddClickCallBack(function()
		self:Close()
    end)

    self:SetSuit()
end

function FoundryStrenSuitAttrView:CloseViewCallBack()

    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function FoundryStrenSuitAttrView:SetSuit()

	self.list = self._layout_objs["n2"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/foundry/foundry_stren_suit_attr_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_foundry:stren_suit_attr_template"
    end)

    self.ui_list:SetItemNum(#self.suit_cfg)
end

function FoundryStrenSuitAttrView:GetStrenLvList()
	return self.stren_lv_list
end

function FoundryStrenSuitAttrView:GetCfg()
	return self.suit_cfg
end

function FoundryStrenSuitAttrView:SetCfg(career, stren_lv_list)
    if career == nil then
        career = game.RoleCtrl.instance:GetCareer()
    end
    self.suit_cfg = config.equip_stren_suit[career]
    if stren_lv_list == nil then
        local lv, list = game.FoundryCtrl.instance:GetData():GetStrenSuitLv()
        stren_lv_list = list
    end
    self.stren_lv_list = stren_lv_list
end

return FoundryStrenSuitAttrView
