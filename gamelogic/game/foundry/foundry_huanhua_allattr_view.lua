local FoundryHuanhuaAllattrView = Class(game.BaseView)

function FoundryHuanhuaAllattrView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_huanhua_allattr_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
    self.foundry_data = game.FoundryCtrl.instance:GetData()
end

function FoundryHuanhuaAllattrView:_delete()
end

function FoundryHuanhuaAllattrView:OpenViewCallBack()

	self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
    end)

    local career = game.RoleCtrl.instance:GetCareer()
	local cfg = config.artifact_avatar[career]
	local cfg2 = config.artifact_avatar[0]
	local attr_list = {}
	for k, v in pairs(cfg) do

		local id  = v.id
		local have_flag = self.foundry_data:CheckHaveAvatar(id)
		if have_flag then

			for j, r in pairs(v.attr) do
				if not attr_list[r[1]] then
					attr_list[r[1]] = r[2]
				else
					attr_list[r[1]] = attr_list[r[1]] + r[2]
				end
			end
		end
	end

	for k, v in pairs(cfg2) do

		local id  = v.id
		local have_flag = self.foundry_data:CheckHaveAvatar(id)
		if have_flag then

			for j, r in pairs(v.attr) do
				if not attr_list[r[1]] then
					attr_list[r[1]] = r[2]
				else
					attr_list[r[1]] = attr_list[r[1]] + r[2]
				end
			end
		end
	end

	local new_attr_list = {}

	for k, v in pairs(attr_list) do
		local t = {}
		t.attr_type = k
		t.attr_val = v

		table.insert(new_attr_list, t)
	end

	if next(new_attr_list) then

		self.list = self._layout_objs["attr_list"]
	    self.ui_list = game.UIList.New(self.list)
	    self.ui_list:SetVirtual(true)

	    self.ui_list:SetCreateItemFunc(function(obj)
	        return obj
	    end)

	    self.ui_list:SetRefreshItemFunc(function (obj, idx)
	    	if(idx%2) == 1 then
	    		obj:GetChild("bg"):SetVisible(true)
	    	else
	    		obj:GetChild("bg"):SetVisible(false)
	    	end
	    	local attr_info = new_attr_list[idx]
	    	local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_info.attr_type)

	        obj:GetChild("name"):SetText(attr_name..": "..tostring(attr_info.attr_val))
	    end)

	    self.ui_list:SetItemNum(#new_attr_list)

		self._layout_objs["tips_txt"]:SetVisible(false)
	else
		self._layout_objs["tips_txt"]:SetVisible(true)
	end
end

function FoundryHuanhuaAllattrView:CloseViewCallBack()
end

return FoundryHuanhuaAllattrView