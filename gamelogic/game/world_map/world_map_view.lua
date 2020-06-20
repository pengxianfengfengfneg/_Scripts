local WorldMapView = Class(game.BaseView)

local config_world_map = config.world_map
local config_world_map_sort = config.world_map_sort

function WorldMapView:_init(ctrl)
    self._package_name = "ui_world_map"
    self._com_name = "world_map_view"

    self._ui_order = game.UIZOrder.UIZOrder_Common_Beyond

    self._view_level = game.UIViewLevel.Standalone
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function WorldMapView:OpenViewCallBack()
	self:InitInfos()
end

function WorldMapView:CloseViewCallBack()
    for _,v in ipairs(self.list_items or {}) do
        v:DeleteMe()
    end
    self.list_items = {}
end

function WorldMapView:InitInfos()
    self.list_items = {}
    local item_class = require("game/world_map/world_map_item")
    for _,v in ipairs(config_world_map_sort or {}) do
        local item = item_class.New(v)
        item:Open()
        item:SetParent(self:GetRoot())

        table.insert(self.list_items, item)
    end
    
    local btn_close = self._layout_objs["btn_close"]
    btn_close:AddClickCallBack(function()
    	self:Close()
	end)
end

return WorldMapView
