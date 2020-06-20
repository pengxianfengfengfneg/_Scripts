local HudTxtTemplate = Class(game.UITemplate)

local _ui_mgr = N3DClient.UIManager:GetInstance()
local _hud_color_list = game.HudColor

local item_func_map = {
	["name1"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end
			item.enable = val
			item.obj:SetVisible(val)
		end,
	},
	["name2"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end
			item.enable = val
			item.obj:SetVisible(val)

			local idx = val and 1 or 0
			if item.ctrl_index ~= idx then
				item.ctrl_index = idx
				item.ctrl:SetSelectedIndexEx(idx)
			end
		end,
	},
	["name3"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end
			item.enable = val
			item.obj:SetVisible(val)
		end,
	},
}

local layout_mt = {__index = function(t, k)
	if t._root_ then
		local obj = t._root_:GetChild(k)
		t[k] = obj
		return obj
	end
end}

function HudTxtTemplate:_init()
	self._package_name = "ui_scene"
    self._com_name = "hud_txt_item"
end

function HudTxtTemplate:_delete()
	
end

function HudTxtTemplate:Init()
	self._layout_root:SetVisible(true)
end

function HudTxtTemplate:Reset()
	for k,v in pairs(self.item_map) do
		self:SetItemVisible(k, false)
	end
	self._layout_root:SetVisible(false)
end

function HudTxtTemplate:OpenViewCallBack()
	self.item_map = {}
	self.item_map["name1"] = {obj = self._layout_objs["name1"], enable = true}
	self.item_map["name2"] = {obj = self._layout_objs["name2"], enable = true, ctrl = self:GetRoot():GetController("c1")}
	self.item_map["name3"] = {obj = self._layout_objs["name3"], enable = true}

	self.item_map["name1"].obj:SetShader("FairyGUI/Text-Hud")
	self.item_map["name2"].obj:SetShader("FairyGUI/Text-Hud")
	self.item_map["name3"].obj:SetShader("FairyGUI/Text-Hud")

	for k,v in pairs(self.item_map) do
		self:SetItemVisible(k, false)
	end
end

function HudTxtTemplate:CloseViewCallBack()

end

function HudTxtTemplate:_CreateLayout()
	if not self._ui_obj then
		self._ui_obj, self._layout_root, self._ui_panel = _ui_mgr:CreatePanel(self._package_name, self._com_name, game.LayerName.HeadWidget)
		if self._layout_root then
			self._ui_obj:SetHudComponent(0, 50, 0.001, 0.03)
			self._layout_objs = {}
			self._layout_objs._root_ = self._layout_root
			self._ui_panel:SetSortingOrder(9999, true)
			setmetatable(self._layout_objs, layout_mt)

			self._layout_root:SetTouchEnable(false)
		end
	end
end

function HudTxtTemplate:_DestroyLayout()
    if self._layout_root then
    	self._layout_root:Dispose()
    	self._layout_root = nil
    end

	if self._ui_obj then
		UnityEngine.GameObject.Destroy(self._ui_obj)
		self._ui_obj = nil
	end
end

function HudTxtTemplate:SetParent(parent)
	if self._is_open then
		if self.hud_item then
			parent:AddChild(self.hud_item)
		end
	end
end

function HudTxtTemplate:SetOwner(obj, offset)
	if self._ui_obj then
		self._layout_root:SetPosition(0, 0, 0)
		self._ui_obj:SetParent(obj)
		self._ui_obj:SetPosition(0, offset, 0)
	end
end

function HudTxtTemplate:SetText(name, val, color_idx)
	local item = self.item_map[name]
	if item then
		item_func_map[name].show_func(item, true)
		item.obj:SetText(val)
		if color_idx then
			local clr = _hud_color_list[color_idx]
			item.obj:SetColor(clr.x, clr.y, clr.z, 255.0)
		end
	end
end

function HudTxtTemplate:SetTextColor(name, color_idx)
	local item = self.item_map[name]
	if item then
		local clr = _hud_color_list[color_idx]
		item.obj:SetColor(clr.x, clr.y, clr.z, 255.0)
	end
end

function HudTxtTemplate:SetImg(name, sp_name)

end

function HudTxtTemplate:SetItemVisible(name, val)
	local item = self.item_map[name]
	if item then
		item_func_map[name].show_func(item, val)
	end
end

function HudTxtTemplate:GetObj()
	return self._ui_obj
end

return HudTxtTemplate
