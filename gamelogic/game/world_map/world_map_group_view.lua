local WorldMapGroupView = Class(game.BaseView)

local config_world_map = config.world_map
local config_world_map_group = config.world_map_group

function WorldMapGroupView:_init(ctrl)
    self._package_name = "ui_world_map"
    self._com_name = "world_map_group_view"

    self._ui_order = game.UIZOrder.UIZOrder_Common_Beyond

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.None

    self.ctrl = ctrl
end

function WorldMapGroupView:OpenViewCallBack(group_id, touch_info)
	self:Init(group_id, touch_info)
end

function WorldMapGroupView:CloseViewCallBack()
    
end

function WorldMapGroupView:Init(group_id, touch_info)
    local group_info = config_world_map_group[group_id]
    local map_list = {}
    for k, v in pairs(group_info) do
        table.insert(map_list, v)
    end
    table.sort(map_list, function(m, n)
        return m.lv < n.lv
    end)

    local list_item = self:CreateList("list_item", "game/world_map/world_map_group_item")
    list_item:SetRefreshItemFunc(function(item, idx)
        local info = map_list[idx]
        item:SetGroupInfo(info)
    end)
    
    local item_num = #map_list
    list_item:SetItemNum(item_num)
    list_item:ResizeToFit(item_num)

    local root = self:GetRoot()
    root:AddClickCallBack(handler(self, self.OnEmptyClick))

    local group = self._layout_objs.group
    local img_bg = self._layout_objs.n0

    local x, y = self:GetRoot():ToLocalPos(touch_info.x, touch_info.y)
    local group_size = img_bg:GetSize()
    local full_size = root:GetSize()

    if x + group_size[1] >= full_size[1] then
        x = x - group_size[1]
    end
    if y + group_size[2] >= full_size[2] then
        y = y - group_size[2]
    end

    group:SetPosition(x, y)
end

function WorldMapGroupView:OnEmptyClick()
    self:Close()
end

return WorldMapGroupView
