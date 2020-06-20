local WorldMapGroupItem = Class(game.UITemplate)

local config_world_map_func = require("game/world_map/world_map_func_config")

function WorldMapGroupItem:_init()
    self._package_name = "ui_world_map"
    self._com_name = "world_map_group_item"
end

function WorldMapGroupItem:OpenViewCallBack()
    self:Init()
end

function WorldMapGroupItem:CloseViewCallBack()
    
end

function WorldMapGroupItem:Init()
    self.txt_name = self._layout_objs["title"]
	self:GetRoot():AddClickCallBack(handler(self, self.OnItemClick))
end

function WorldMapGroupItem:SetGroupInfo(info)
    self.info = info
    self.scene_id = info.id
    self.group_id = info.group_id

    local scene = config.scene[self.scene_id]
    self.txt_name:SetText(string.format(config.words[2411], scene.name, info.lv))
end

function WorldMapGroupItem:OnItemClick()
    if config_world_map_func[self.scene_id] then
        config_world_map_func[self.scene_id].click_func(self.info)
    else
        local is_open, msg = game.WorldMapCtrl.instance:IsMapOpened(self.scene_id, self.group_id)
        if is_open then
            game.WorldMapCtrl.instance:EnterMap(self.scene_id)
        else
            game.GameMsgCtrl.instance:PushMsg(msg)
        end
    end
end

return WorldMapGroupItem
