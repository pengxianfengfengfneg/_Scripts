local CarbonMaterialTemplate = Class(game.UITemplate)

function CarbonMaterialTemplate:_init()
	self._package_name = "ui_carbon"
    self._com_name = "carbon_material_template"
end

function CarbonMaterialTemplate:OpenViewCallBack()
	self:InitList()

    self._layout_objs["n0"]:AddClickCallBack(function()
        game.ShopCtrl.instance:OpenView(1109)
    end)

    self:BindEvent(game.CarbonEvent.RefreshMaterial, function(data)
        self:RefreshView()
    end)
end

function CarbonMaterialTemplate:CloseViewCallBack()
    self.ui_list:DeleteMe()
end

function CarbonMaterialTemplate:_delete()

end

function CarbonMaterialTemplate:InitList()

	local dunge_data = game.CarbonCtrl.instance:GetData()
    self.mater_dunge_id_list = dunge_data:GetMaterialCarbons()

	self.list = self._layout_objs["list"]
	self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

    	local item = require("game/carbon/carbon_material_item_template").New()
    	item:SetVirtual(obj)
    	item:Open()

    	return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
    	local dunge_id = self.mater_dunge_id_list[idx]
    	item:RefreshItem(dunge_id)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_carbon:carbon_mate_item_template"
    end)

    local item_num = #self.mater_dunge_id_list
    self.ui_list:SetItemNum(item_num)
end

function CarbonMaterialTemplate:RefreshView()
    self.ui_list:RefreshVirtualList()
end

return CarbonMaterialTemplate