local FoundryStoneSuitAttrView = Class(game.BaseView)

function FoundryStoneSuitAttrView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "stone_suit_view"
    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function FoundryStoneSuitAttrView:_delete()
end

function FoundryStoneSuitAttrView:OpenViewCallBack()

	self._layout_objs["bg"]:SetTouchEnable(true)
	self._layout_objs["bg"]:AddClickCallBack(function()
		self:Close()
    end)

    self:SetSuit()
end

function FoundryStoneSuitAttrView:CloseViewCallBack()

    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function FoundryStoneSuitAttrView:SetSuit()

	self.list = self._layout_objs["n2"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/foundry/foundry_stone_suit_attr_template").New(self)
        item:SetVirtual(obj)
        item:Open(self.stone_min_lv_list)
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_foundry:stone_suit_attr_template"
    end)

    self.ui_list:SetItemNum(#self.suit_cfg)
end

function FoundryStoneSuitAttrView:GetCfg()
	return self.suit_cfg
end

function FoundryStoneSuitAttrView:SetCfg(career, stone_min_lv_list)
    if career == nil then
        career = game.RoleCtrl.instance:GetCareer()
    end
    self.suit_cfg = config.equip_stone_suit[career]
    if stone_min_lv_list == nil then
        stone_min_lv_list = game.FoundryCtrl.instance:GetData():GetAllEquipStoneMinLv()
    end
    self.stone_min_lv_list = stone_min_lv_list
end

return FoundryStoneSuitAttrView
