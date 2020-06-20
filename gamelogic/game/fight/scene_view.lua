local SceneView = Class(game.BaseView)

local _stage = FairyGUI.Stage

local string_format = string.format
local string_gsub = string.gsub


function SceneView:_init()
	self._package_name = "ui_scene"
    self._com_name = "scene_view"
	self._cache_time = 600
	self._swallow_touch = false
	self._ui_order = game.UIZOrder.UIZOrder_Scene

	self._mask_type = game.UIMaskType.None
	self._view_level = game.UIViewLevel.Keep

	self.next_refsh_time = 0
end

function SceneView:_delete()
	
end

function SceneView:OpenViewCallBack()
	self.hud_id = 0
	self.hud_txt_map = {}
	self.hud_img_map = {}
	self.hud_bubble_map = {}
	self.txt_pool = global.CollectPool.New(function()
			local item = require("game/fight/hud_txt_template").New()
			item:Open()
			return item
		end, function(item)
			item:DeleteMe()
		end, function(item)
			item:Reset()
			game.RenderUnit:AddToUnUsedLayer(item:GetObj())
		end, 15)
	self.img_pool = global.CollectPool.New(function()
			local item = require("game/fight/hud_img_template").New()
			item:Open()
			return item
		end, function(item)
			item:DeleteMe()
		end, function(item)
			item:Reset()
			game.RenderUnit:AddToUnUsedLayer(item:GetObj())
		end, 15)
	self.bubble_pool = global.CollectPool.New(function()
		local item = require("game/fight/speak_bubble_template").New()
		item:Open()
		return item
	end, function(item)
		item:DeleteMe()
	end, function(item)
		item:Reset()
		game.RenderUnit:AddToUnUsedLayer(item:GetObj())
	end, 15)
end

function SceneView:CloseViewCallBack()
	self.hud_txt_map = nil
	self.hud_img_map = nil
	self.hud_bubble_map = nil
	if self.txt_pool then
		self.txt_pool:DeleteMe()
		self.txt_pool = nil
	end
	if self.img_pool then
		self.img_pool:DeleteMe()
		self.img_pool = nil
	end
	if self.bubble_pool then
		self.bubble_pool:DeleteMe()
		self.bubble_pool = nil
	end
end

function SceneView:Update(now_time, elapse_time)
	if now_time > self.next_refsh_time then
		self.next_refsh_time = now_time + 1
		_stage.inst:SortWorldSpacePanelsByZOrder(9999)
		_stage.inst:SortWorldSpacePanelsByZOrder(9998)
		_stage.inst:SortWorldSpacePanelsByZOrder(9997)

		for _,v in pairs(self.hud_bubble_map) do
			v:Update(now_time, elapse_time)
		end
	end
end

function SceneView:RegisterHud(obj, offset)
	self.hud_id = self.hud_id + 1

	local txt = self.txt_pool:Create()
	txt:Init()
	txt:SetOwner(obj, offset)
	self.hud_txt_map[self.hud_id] = txt

	local img = self.img_pool:Create()
	img:Init()
	img:SetOwner(obj, offset)
	self.hud_img_map[self.hud_id] = img

	local bubble = self.bubble_pool:Create()
	bubble:Init()
	bubble:SetOwner(obj, offset)
	self.hud_bubble_map[self.hud_id] = bubble

	return self.hud_id
end

function SceneView:SetOwner(id, obj, offset)
	local item = self.hud_txt_map[id]
	if item then
		item:SetOwner(obj, offset)
	end
	item = self.hud_img_map[id]
	if item then
		item:SetOwner(obj, offset)
	end

	item = self.hud_bubble_map[id]
	if item then
		item:SetOwner(obj, offset)
	end
end

function SceneView:UnRegisterHud(id)
	local item = self.hud_txt_map[id]
	if item then
		self.txt_pool:Free(item)
		self.hud_txt_map[id] = nil
	end
	item = self.hud_img_map[id]
	if item then
		self.img_pool:Free(item)
		self.hud_img_map[id] = nil
	end

	item = self.hud_bubble_map[id]
	if item then
		self.bubble_pool:Free(item)
		self.hud_bubble_map[id] = nil
	end
end

function SceneView:SetHudVisible(id, enable)
	local item = self.hud_img_map[id]
	if item then
		item:SetVisible(enable)
	end
	item = self.hud_txt_map[id]
	if item then
		item:SetVisible(enable)
	end
end

function SceneView:SetHudText(id, name, val, color_idx)
	local item = self.hud_img_map[id]
	if item then
		item:SetText(name, val, color_idx)
	end
	item = self.hud_txt_map[id]
	if item then
		item:SetText(name, val, color_idx)
	end
end

function SceneView:SetHudTextColor(id, name, color_idx)
	local item = self.hud_img_map[id]
	if item then
		item:SetTextColor(name, color_idx)
	end
	item = self.hud_txt_map[id]
	if item then
		item:SetTextColor(name, color_idx)
	end
end

function SceneView:SetHudImg(id, name, sp_name, scale, is_flip_x)
	local item = self.hud_img_map[id]
	if item then
		item:SetImg(name, sp_name, scale, is_flip_x)
	end
	item = self.hud_txt_map[id]
	if item then
		item:SetImg(name, sp_name)
	end
end

function SceneView:SetHudItemVisible(id, name, val)
	local item = self.hud_img_map[id]
	if item then
		item:SetItemVisible(name, val)
	end
	item = self.hud_txt_map[id]
	if item then
		item:SetItemVisible(name, val)
	end
end

local txt_format = "<font color='#e0d6bd'>%s</font>"
function SceneView:SetSpeakBubble(id, txt, time, bubble_id)
	local item = self.hud_bubble_map[id]
	if item then
    	local content = string_gsub(txt, "3171f5", "5298e3")
		content = string_format(txt_format, content)

		item:SetText(content, time, bubble_id)
	end
end

return SceneView
