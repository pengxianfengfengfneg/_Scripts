local WorldMapItem = Class(game.UITemplate)

local config_scene = config.scene

function WorldMapItem:_init(data)
    self._package_name = "ui_world_map"
    self._com_name = "world_map_item"

    self.item_data = data
end

function WorldMapItem:OpenViewCallBack()
	self:InitInfos()
end

function WorldMapItem:CloseViewCallBack()
    
end

function WorldMapItem:InitInfos()
	self:GetRoot():SetPosition(self.item_data.x, self.item_data.y)

	local boundle_name = "ui_world_map"

	local icon = self._layout_objs["icon"]
	icon:SetSprite(boundle_name, self.item_data.icon)

	self:GetRoot():AddClickCallBack(function(x, y)
		self:OnClickBtn(x, y)
	end)

	self.scene_id = self.item_data.id
	self.group_id = self.item_data.group_id

	local scene_cfg = config_scene[self.scene_id]
	local txt_name = self._layout_objs["title"]
	txt_name:SetText(string.format(config.words[2411], scene_cfg.name, self.item_data.lv))

	local is_open = self:CheckOpen(self.scene_id)
	icon:SetGray(not is_open)
end

function WorldMapItem:OnClickBtn(x, y)
	if not self.group_id or self.group_id == 0 then
		game.WorldMapCtrl.instance:EnterMap(self.scene_id)
	else
		local touch_info = {x = x, y = y}
		game.WorldMapCtrl.instance:OpenWorldMapGroupView(self.group_id, touch_info)
	end
end

function WorldMapItem:CheckOpen(scene_id)
	return game.WorldMapCtrl.instance:IsMapOpened(scene_id)
end

return WorldMapItem
