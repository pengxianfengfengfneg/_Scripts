local WorldMapCtrl = Class(game.BaseCtrl)

local global_time = global.Time
local event_mgr = global.EventMgr
local config_func = config.func

function WorldMapCtrl:_init()
    if WorldMapCtrl.instance ~= nil then
        error("WorldMapCtrl Init Twice!")
    end
    WorldMapCtrl.instance = self

    self.scene_line_data = {}

    self.world_map_view = require("game/world_map/world_map_view").New(self)
    self.world_map_tips_view = require("game/world_map/world_map_tips_view").New(self)
    self.cur_map_view = require("game/world_map/cur_map_view").New(self)
    self.world_map_group_view = require("game/world_map/world_map_group_view").New(self)

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()
    self:RegisterAllErrorCallbacks()
end

function WorldMapCtrl:_delete()
    self.world_map_view:DeleteMe()
    self.world_map_tips_view:DeleteMe()
    self.cur_map_view:DeleteMe()
    self.world_map_group_view:DeleteMe()
    
    WorldMapCtrl.instance = nil
end

function WorldMapCtrl:RegisterAllEvents()
   
end

function WorldMapCtrl:RegisterAllErrorCallbacks()
    game.GameMsgCtrl.instance:RegisterErrorCodeCallback(6103, function()
        local main_role = game.Scene.instance:GetMainRole()
        main_role:GetOperateMgr():ClearOperate()
    end)
end

function WorldMapCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(90211, "OnGetSceneLineInfoResp")
end

function WorldMapCtrl:OpenView()
    self.world_map_view:Open()
end

function WorldMapCtrl:CloseView()
    self.world_map_view:Close()
    self.cur_map_view:Close()
    self.world_map_group_view:Close()
end

function WorldMapCtrl:OpenTipsView(map_cfg)
    self.world_map_tips_view:Open(map_cfg)
end

function WorldMapCtrl:OpenCurMapView()
    return self.cur_map_view:Open()
end

function WorldMapCtrl:GetCurMapView()
    return self.cur_map_view
end

function WorldMapCtrl:OpenWorldMapGroupView(group_id, touch_info)
    return self.world_map_group_view:Open(group_id, touch_info)
end

function WorldMapCtrl:IsMapOpened(scene_id, group_id)
    local role_level = game.RoleCtrl.instance:GetRoleLevel()

    local map_cfg = nil
    if group_id and group_id ~= 0 then
        map_cfg = config.world_map_group[group_id][scene_id]
    else
        map_cfg = config.world_map[scene_id]
    end
    local open_lv = map_cfg.lv
    local map_seq = map_cfg.seq

    if role_level < open_lv then
        return false, config.words[2425]
    end

    return true
end

function WorldMapCtrl:EnterMap(scene_id)
    local cur_scene_id = game.Scene.instance:GetSceneID()
	if scene_id == cur_scene_id then
		game.GameMsgCtrl.instance:PushMsg(config.words[2408])
		return
	end

	game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_world_map/world_map_item/btn"..scene_id})

	local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoChangeScene(scene_id)
    end

    game.WorldMapCtrl.instance:CloseView()
end

function WorldMapCtrl:CheckTargetSceneLine(scene, line_id)
    
end

function WorldMapCtrl:SendGetSceneLineInfoReq()
    self:SendProtocal(90210)
end

function WorldMapCtrl:OnGetSceneLineInfoResp(data)
    self.scene_line_data[data.scene_id] = data.line_info

    global.EventMgr:Fire(game.MapEvent.OnMapLineInfo, data)
end

function WorldMapCtrl:GetSceneLineInfo(scene_id, line_id)
    local info = self.scene_line_data[scene_id]
    if info then
        return info[line_id]
    end
end

function WorldMapCtrl:GetLineInfo(line_id)
    local scene_id = game.Scene.instance:GetSceneID()
    return self:GetSceneLineInfo(scene_id, line_id)
end

function WorldMapCtrl:IsLineFull(line_id)
    local info = self:GetLineInfo(line_id)
    if info then
        local scene_cfg = game.Scene.instance:GetSceneConfig()
        if info.role_num >= scene_cfg.role_lmt then
            return true
        end
    end
    return false
end

function WorldMapCtrl:GetLineList()
    local scene_id = game.Scene.instance:GetSceneID()
    return self.scene_line_data[scene_id] or game.EmptyTable
end

game.WorldMapCtrl = WorldMapCtrl

return WorldMapCtrl
