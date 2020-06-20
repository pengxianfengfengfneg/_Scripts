local HudImgTemplate = Class(game.UITemplate)

local _ui_mgr = N3DClient.UIManager:GetInstance()
local _hud_color_list = game.HudColor

local item_func_map = {
	["name1"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end
			item.enable = val
		end,
		set_func = function(item, val)
			item.obj:SetWidth(string.len(val) * 8)
		end,
	},
	["name2"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end
			item.enable = val

			local idx = val and 1 or 0
			if item.ctrl_index ~= idx then
				item.ctrl_index = idx
				item.ctrl:SetSelectedIndexEx(idx)
			end
		end,
		set_func = function(item, val)

		end,
	},
	["name4"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end
			item.enable = val
			item.obj:SetVisible(val)
		end,
		set_func = function(item, val, color_idx)
			item.obj:SetText(val)
			local clr = _hud_color_list[color_idx]
			item.obj:SetColor(clr.x, clr.y, clr.z, 255.0)
		end,
	},
	["img11"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
			if not val then
				item.obj:SetWidth(0)
			end
		end,
	},
	["img12"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
			if not val then
				item.obj:SetWidth(0)
			end
		end,
	},
	["img13"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
			if not val then
				item.obj:SetWidth(0)
			end
		end,
	},
	["img14"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
			if not val then
				item.obj:SetWidth(0)
			end
		end,
	},
	["img15"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
			if not val then
				item.obj:SetWidth(0)
			end
		end,
	},	
	["img16"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
			if not val then
				item.obj:SetWidth(0)
			end
		end,
	},	
	["img3"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
		end,
	},
	["img4"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
		end,
	},
	["img41"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
		end,
	},
	["img42"] = {
		show_func = function(item, val)
			if item.enable == val then
				return
			end

			item.enable = val
			item.obj:SetVisible(val)
			item.obj:SetFlipX(true)
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

function HudImgTemplate:_init()
	self._package_name = "ui_scene"
    self._com_name = "hud_img_item"
end

function HudImgTemplate:_delete()
	
end

function HudImgTemplate:Init()
	self._layout_root:SetVisible(true)
end

function HudImgTemplate:Reset()
	for k,v in pairs(self.item_map) do
		self:SetItemVisible(k, false)
	end
	self._layout_root:SetVisible(false)
end

function HudImgTemplate:OpenViewCallBack()
	self.item_map = {}
	self.item_map["name1"] = {obj = self._layout_objs["name1"], enable = true}
	self.item_map["name2"] = {enable = true, ctrl = self:GetRoot():GetController("c1")}
	self.item_map["name4"] = {obj = self._layout_objs["img4/name4"], enable = true}
	self.item_map["img3"] = {obj = self._layout_objs["img3"], enable = true}

	self.item_map["img11"] = {obj = self._layout_objs["img11"], enable = true}
	self.item_map["img12"] = {obj = self._layout_objs["img12"], enable = true}
	self.item_map["img13"] = {obj = self._layout_objs["img13"], enable = true}
	self.item_map["img14"] = {obj = self._layout_objs["img14"], enable = true}
	self.item_map["img15"] = {obj = self._layout_objs["img15"], enable = true}
	self.item_map["img16"] = {obj = self._layout_objs["img16"], enable = true}

	self.item_map["img4"] = {obj = self._layout_objs["img4"], enable = true}
	self.item_map["img41"] = {obj = self._layout_objs["img4/img41"], enable = true}
	self.item_map["img42"] = {obj = self._layout_objs["img4/img42"], enable = true}

	self.item_map["img3"].obj:SetShader("FairyGUI/Image-Hud")
	self.item_map["img11"].obj:SetShader("FairyGUI/Image-Hud")
	self.item_map["img12"].obj:SetShader("FairyGUI/Image-Hud")
	self.item_map["img13"].obj:SetShader("FairyGUI/Image-Hud")
	self.item_map["img14"].obj:SetShader("FairyGUI/Image-Hud")
	self.item_map["img15"].obj:SetShader("FairyGUI/Image-Hud")
	self.item_map["img16"].obj:SetShader("FairyGUI/Image-Hud")
	self.item_map["img41"].obj:SetShader("FairyGUI/Image-Hud")
	self.item_map["img42"].obj:SetShader("FairyGUI/Image-Hud")
	self.item_map["name4"].obj:SetShader("FairyGUI/Text-Hud")

	for k,v in pairs(self.item_map) do
		v.name = k
		self:SetItemVisible(k, false)
	end

	self.left_name_img_dict = {}
	self.right_name_img_dict = {}

	self.left_name_img = {}
	self.right_name_img = {}
	for i=1,4 do
		local left_key = "img" .. (10+i)
		local right_key = "img" .. (14+i)

		self.left_name_img_dict[left_key] = 1
		self.right_name_img_dict[right_key] = 1

		table.insert(self.left_name_img, self.item_map[left_key])
		table.insert(self.right_name_img, self.item_map[right_key])
	end
end

function HudImgTemplate:CloseViewCallBack()
	
end

function HudImgTemplate:_CreateLayout()
	if not self._ui_obj then
		self._ui_obj, self._layout_root, self._ui_panel = _ui_mgr:CreatePanel(self._package_name, self._com_name, game.LayerName.HeadWidget)
		if self._layout_root then
			self._ui_obj:SetHudComponent(0, 50, 0.001, 0.03)
			self._layout_objs = {}
			self._layout_objs._root_ = self._layout_root
			self._ui_panel:SetSortingOrder(9998, true)
			setmetatable(self._layout_objs, layout_mt)

			self._layout_root:SetTouchEnable(false)
		end
	end
end

function HudImgTemplate:_DestroyLayout()
    if self._layout_root then
    	self._layout_root:Dispose()
    	self._layout_root = nil
    end

	if self._ui_obj then
		UnityEngine.GameObject.Destroy(self._ui_obj)
		self._ui_obj = nil
	end
end

function HudImgTemplate:SetParent(parent)
	if self._is_open then
		if self.hud_item then
			parent:AddChild(self.hud_item)
		end
	end
end

function HudImgTemplate:SetOwner(obj, offset)
	if self._ui_obj then
		self._layout_root:SetPosition(0, 0, 0)
		self._ui_obj:SetParent(obj)
		self._ui_obj:SetPosition(0, offset, 0)
	end
end

function HudImgTemplate:SetText(name, val, color_idx)
	local item = self.item_map[name]
	if item then
		item_func_map[name].show_func(item, true)
		item_func_map[name].set_func(item, val, color_idx)
	end
end

function HudImgTemplate:SetTextColor(name, color_idx)

end

function HudImgTemplate:SetImg(name, sp_name, scale, is_flip_x)
	local item = self.item_map[name]
	if item then
		item_func_map[name].show_func(item, true)
		item.obj:SetSpriteScale("ui_title", sp_name, (scale or 1)*1.0)
		is_flip_x = is_flip_x or false
		item.obj:SetFlipX(is_flip_x)
	end
end

function HudImgTemplate:GetImgItem(name)
	if self.left_name_img_dict[name] then
		for _,v in ipairs(self.left_name_img) do
			if not v.enable then
				v.use_name = name
				return v,1
			end
		end
	end

	if self.left_name_img_dict[name] then
		for _,v in ipairs(self.right_name_img) do
			if not v.enable then
				v.use_name = name
				return v,2
			end
		end
	end

	return self.item_map[name],0
end

function HudImgTemplate:DoLeftNameImgSort()
	local sort_list = {}
	for _,v in ipairs(self.left_name_img) do
		if v.enable then
			if v.use_name ~= v.name then
				table.insert(sort_list, v)
			end
		end
	end

	if #sort_list > 1 then
		table.sort(sort_list, function(v1,v2)
			if v1.use_name and v2.use_name then
				return v1.use_name<v2.use_name
			end

			if v1.use_name then
				return true
			end

			if v2.use_name then
				return false
			end
		end)
	end
end

function HudImgTemplate:DoRightNameImgSort()
	
end

function HudImgTemplate:SetItemVisible(name, val)
	local item = self.item_map[name]
	if item then
		item_func_map[name].show_func(item, val)
	end
end

function HudImgTemplate:GetObj()
	return self._ui_obj
end

return HudImgTemplate
