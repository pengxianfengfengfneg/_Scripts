local CurMapView = Class(game.BaseView)

local config_scene = config.scene
local string_format = string.format
local _ui_mgr = N3DClient.UIManager:GetInstance()

function CurMapView:_init(ctrl)
    self._package_name = "ui_world_map"
    self._com_name = "cur_map_view"

    self._ui_order = game.UIZOrder.UIZOrder_Common_Beyond

    self._view_level = game.UIViewLevel.Standalone
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl

    
end

function CurMapView:OnPreOpen()
    local map = game.Scene.instance:GetMap()
    local map_id = map:GetMapId()
    local bundle_name = "map/map_" .. map_id    
    self:AddPackage(bundle_name)
end

function CurMapView:OpenViewCallBack()
	self:Init()
end

function CurMapView:RegisterAllEvents()
    local events = {
        {game.SceneEvent.FindWay, handler(self,self.OnFindWay)},
        {game.MapEvent.OnMapLineInfo, handler(self,self.OnMapLineInfo)},
        {game.MakeTeamEvent.OnTeamSyncPos, handler(self,self.OnTeamSyncPos)},
        {game.MakeTeamEvent.TeamMemberLeave, handler(self,self.OnTeamMemberLeave)},
        {game.MakeTeamEvent.NotifyKickOut, handler(self,self.OnNotifyKickOut)},
        {game.MakeTeamEvent.OnTeamSyncPos, handler(self,self.OnTeamSyncPos)},
        {game.MakeTeamEvent.OnTeamMemberAttr, handler(self,self.OnTeamMemberAttr)}
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

function CurMapView:CloseViewCallBack()
    self:ClearWayPoint()
    self:ClearNpcItems()
    self:ClearNpcName()
    self:ClearItems()
    self:ClearAllMemPos()

    self.is_load_map_finish = false
end

local DefaultMapInfo = {
    width = 200,
    height = 200,
    offset_x = 0,
    offset_y = 0,
}
function CurMapView:Init()  
    self.res_loader = self._layout_objs["res_loader"]
    --self.res_loader:SetUrl("ui_mini_map", tostring(map_id))

    self.main_role_id = game.Scene.instance:GetMainRoleID()
    
    self.is_load_map_finish = false
    local map = game.Scene.instance:GetMap()
    local map_id = map:GetMapId()
    local bundle_name = "map_" .. map_id
    local bundle_path = self:GetPackageBundle("map/" .. bundle_name)
    local asset_name = map_id
    self:SetSpriteAsync(self.res_loader, bundle_path, bundle_name, asset_name, true, function()
        self:InitMapInfo()

        self:InitTeamMemberPos()

        self:LoadMapInfo()
        self:CalcWayPointList()

        self:ScheduleUpdate()
        self:RegisterAllEvents()

        if self.cur_line_id > 0 then
            self.ctrl:SendGetSceneLineInfoReq()
        end

        self.is_load_map_finish = true
        self:FireEvent(game.MapEvent.LoadMapFinish, map_id)

        local main_role = game.Scene.instance:GetMainRole()
        if main_role == nil then
            return
        end
        local ux,uy = main_role:GetUnitPosXY()
        self:OnUpdateMapPos(ux,uy)
    end)
end

function CurMapView:InitMapInfo()
    local scene = game.Scene.instance
    local map_id = scene:GetMapId()
    local scene_id = scene:GetSceneID()

    self.cur_scene_id = scene_id

    self.scene_config = scene:GetSceneConfig()

    self:InitFuncNpcData()
    self:InitDramaNpcData()
    self:InitMonsterData()

    self:InitTab()
    self:InitMapLine()

    local cfg = config.map_info[map_id] or DefaultMapInfo
    local map_width = math.max(cfg.width, 1)
    local map_height = math.max(cfg.height, 1)

    self.txt_name = self._layout_objs["txt_name"]
    self.txt_name:SetText(config.scene[scene_id].name)

    self.mini_offset_x,self.mini_offset_y = self.res_loader:GetContentXY()

    self.mini_offset_y = -self.mini_offset_y

    self.unit_offset_x = cfg.offset_x or 0 
    self.unit_offset_y = cfg.offset_y or 0

    local loader_size = self.res_loader:GetSize()
    local image_width,image_height = self.res_loader:GetContentSize()

    local loader_w = loader_size[1]
    local loader_h = loader_size[2]
    self.loader_height = loader_h 

    self.mini_scale_x = image_width/map_width
    self.mini_scale_y = image_height/map_height

    local loader_x,loader_y = self.res_loader.x,self.res_loader.y

    self.orign_loader_x = loader_x
    self.orign_loader_y = loader_y

    self.loader_x = loader_x
    self.loader_y = loader_y

    self.loader_index = self:GetRoot():GetChildIndex(self.res_loader)
    self.res_loader:AddClickCallBack(function(x,y)    
        x,y = self:GetRoot():ToLocalPos(x,y)
        self:OnClickMiniMap(x, y)
    end)

    self.btn_world_map = self._layout_objs["btn_world_map"]
    self.btn_world_map:AddClickCallBack(function()
        self.ctrl:OpenView()
    end)

    self.btn_close = self._layout_objs["btn_close"]
    self.btn_close:AddClickCallBack(function()
        self:Close()
    end)
    
    self.img_pos = self._layout_objs["img_pos"]

    self.item_map = {}
    self.item_id = 0
end

function CurMapView:InitTab()
    self.list_npc = self._layout_objs["list_npc"]

    self.tab_list_data = {}
    if #self.func_npc_data > 0 then
        table.insert(self.tab_list_data, {name=config.words[2413],func=handler(self,self.LoadFuncNpc)})
    end

    if #self.drama_npc_data > 0 then
        table.insert(self.tab_list_data, {name=config.words[2414],func=handler(self,self.LoadDramaNpc)})
    end

    if #self.monster_data > 0 then
        table.insert(self.tab_list_data, {name=config.words[2415],func=handler(self,self.LoadMonster)})
    end

    local tab_num = #self.tab_list_data
    self.list_tabs = self._layout_objs["list_tabs"]
    self.list_tabs:SetItemNum(tab_num)

    self.list_npc:SetVisible(tab_num>0)

    for k,v in ipairs(self.tab_list_data) do
        local obj = self.list_tabs:GetChildAt(k-1)
        obj:SetText(v.name)
    end

    self.tab_ctrl = self:GetRoot():AddControllerCallback("tab_ctrl",function(idx)
        local tab_cfg = self.tab_list_data[idx+1]
        if tab_cfg then
            tab_cfg.func()
        end
    end)
    self.tab_ctrl:SetSelectedIndexEx(0)
end

function CurMapView:OnEmptyClick()
    self:Close()
end

function CurMapView:LoadMapInfo()
    self:ClearNpcName()
    for _,v in pairs(self.scene_config.npc_list or {}) do
        self:AddNpc(v)
    end

    for _,v in pairs(self.scene_config.jump_list or {}) do
        self:AddJumpPoint(v)
    end

    for _,v in pairs(self.scene_config.door_list or {}) do
        self:AddDoor(v)
    end
end

function CurMapView:AddNpc(cfg)
    local npc_cfg = config.npc[cfg.npc_id]
    if npc_cfg then
        local x,y = self:UnitPosToMiniPos(cfg.x, cfg.y)

        local npc_name = _ui_mgr:CreateObject("ui_world_map", "npc_name")
        npc_name:SetPosition(x,y)

        local txt_name = npc_name:GetChild("txt_name")
        txt_name:SetText(npc_cfg.map_name or npc_cfg.name)        
        self:GetRoot():AddChildAt(npc_name, self.loader_index+1)

        table.insert(self.list_npc_name, npc_name)
    end
end

function CurMapView:ClearNpcName()
    for _,v in ipairs(self.list_npc_name or {}) do
        v:Dispose()
    end
    self.list_npc_name = {}
end

function CurMapView:AddJumpPoint(cfg)
    
end

function CurMapView:AddDoor(cfg)
    local scene_cfg = config_scene[cfg.scene_id]
    if scene_cfg then
        local x,y = self:UnitPosToMiniPos(cfg.pos_x, cfg.pos_y)

        local map_name = _ui_mgr:CreateObject("ui_world_map", "map_name")
        map_name:SetPosition(x,y)

        local txt_name = map_name:GetChild("txt_name")
        txt_name:SetText(scene_cfg.name)        
        self:GetRoot():AddChildAt(map_name, self.loader_index+1)

        table.insert(self.list_npc_name, map_name)
    end
end

function CurMapView:CalcWayPointList()
    self:ClearWayPoint()

    local main_role = game.Scene.instance:GetMainRole()
    if main_role == nil then
        return
    end
    local cur_operate = main_role:GetOperateMgr():GetCurOperate()
    if cur_operate and cur_operate.oper_type == game.OperateType.FindWay then
        local src_x, src_y = main_role:GetUnitPosXY()
        local dst_x, dst_y = cur_operate:GetDstXY()
        local path_list = cur_operate:GetPathList()
        if not path_list[2] then
            return false
        end

        self:OnDoFindWay(path_list)

        return true
    end
    return false
end

function CurMapView:OnFindWay(val, oper)
    if val then
        self:ClearWayPoint()

        local path_list = oper:GetPathList()
        self:OnDoFindWay(path_list)
    end
end

function CurMapView:OnClickTab(idx)
    if idx == 1 then
        self:LoadFuncNpc()
    else
        self:LoadDramaNpc()
    end
end

function CurMapView:InitFuncNpcData()
    self.func_npc_data = {}
    local npc_list = self.scene_config.npc_list or {}
    for k,v in ipairs(npc_list) do
        local npc_cfg = config.npc[v.npc_id]
        if npc_cfg.func_name and npc_cfg.func_name ~= "" then
            npc_cfg.x = v.x
            npc_cfg.y = v.y
            table.insert(self.func_npc_data, npc_cfg)
        end
    end
end

function CurMapView:InitDramaNpcData()
    self.drama_npc_data = {}
    local npc_list = self.scene_config.npc_list or {}
    for k,v in ipairs(npc_list) do
        local npc_cfg = config.npc[v.npc_id]
        if npc_cfg.drama_name and npc_cfg.drama_name ~= "" then
            npc_cfg.x = v.x
            npc_cfg.y = v.y
            table.insert(self.drama_npc_data, npc_cfg)
        end
    end
end

function CurMapView:InitMonsterData()
    self.monster_data = {}
    local monster_list = self.scene_config.monster_list or {}
    for _,v in pairs(monster_list) do
        local x,y = 0,0
        local tmp = {}
        for _,cv in ipairs(v) do
            local pos = tmp[cv.monster_id]
            if not pos then
                local cfg = config.monster[cv.monster_id]
                pos = {x=0,y=0,num=0,id=cv.monster_id, name=cfg.name, func_name=config.words[2415]}
                tmp[cv.monster_id] = pos
            end
            pos.x = pos.x + cv.x
            pos.y = pos.y + cv.y
            pos.num = pos.num + 1
        end

        for k,cv in pairs(tmp) do
            cv.x = cv.x/cv.num
            cv.y = cv.y/cv.num
            table.insert(self.monster_data, cv)
        end
    end
end

function CurMapView:ClearListNpcItem()
    for _,v in ipairs(self.list_npc_item or game.EmptyTable) do
        v:DeleteMe()
    end
    self.list_npc_item = nil
end

function CurMapView:LoadFuncNpc()    
    self.list_npc:SetItemNum(#self.func_npc_data)

    self:ClearListNpcItem()
    self.list_npc_item = {}
    local item_class = require("game/world_map/map_npc_item")
    for k,v in ipairs(self.func_npc_data) do
        local npc_cfg = v
        local child = self.list_npc:GetChildAt(k-1)
        local item = item_class.New(npc_cfg,v.x,v.y, 1)
        item:SetVirtual(child)
        item:Open()
        item:SetClickCallback(function(npc_item)            
            self:OnClickNpcItem(npc_item)
        end)

        table.insert(self.list_npc_item, item)
    end
end

function CurMapView:OnClickNpcItem(item)
    local item_type = item:GetItemType()
    if item_type == 1 or item_type == 2 then
        self:DoGoToTalkNpc(item:GetId())
    else
        self:DoHangMonster(item:GetId(), item:GetXY())
        self:DoHangGather(item:GetId(), item:GetXY())
    end
    self:CalcWayPointList()

    for _,v in ipairs(self.list_npc_item or {}) do
        v:SetSelected(v==item)
    end
end

function CurMapView:DoGoToTalkNpc(npc_id)
    local main_role = game.Scene.instance:GetMainRole()
    if main_role == nil then
        return
    end
    main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
end

function CurMapView:DoHangMonster(monster_id, x, y)
    local scene_id = game.Scene.instance:GetSceneID()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role == nil then
        return
    end
    main_role:GetOperateMgr():DoHangMonster(scene_id, monster_id, 999999, x, y)
end

function CurMapView:DoHangGather(gather_id, x, y)
    
end

function CurMapView:ClearNpcItems()
    for _,v in ipairs(self.list_npc_item or game.EmptyTable) do
        v:DeleteMe()
    end
    self.list_npc_item = nil
end

function CurMapView:LoadDramaNpc()
    local item_num = #self.drama_npc_data
    self.list_npc:SetItemNum(item_num)

    self:ClearListNpcItem()
    self.list_npc_item = {}
    local item_class = require("game/world_map/map_npc_item")
    for k,v in ipairs(self.drama_npc_data) do
        local npc_cfg = v
        local child = self.list_npc:GetChildAt(k-1)
        local item = item_class.New(npc_cfg,v.x,v.y,2)
        item:SetVirtual(child)
        item:Open()
        item:SetClickCallback(function(npc_item)            
            self:OnClickNpcItem(npc_item)
        end)

        table.insert(self.list_npc_item, item)
    end
end

function CurMapView:LoadMonster()
    local item_num = #self.monster_data
    self.list_npc:SetItemNum(item_num)

    self:ClearListNpcItem()
    self.list_npc_item = {}
    local item_class = require("game/world_map/map_npc_item")
    for k,v in ipairs(self.monster_data) do
        local npc_cfg = v
        local child = self.list_npc:GetChildAt(k-1)
        local item = item_class.New(npc_cfg,v.x,v.y,3)
        item:SetVirtual(child)
        item:Open()
        item:SetClickCallback(function(npc_item)            
            self:OnClickNpcItem(npc_item)
        end)

        table.insert(self.list_npc_item, item)
    end
end

function CurMapView:OnClickMiniMap(x,y)
    local unit_x,unit_y = self:MiniPosToUnitPos(x,y)

    local lx,ly = game.UnitToLogicPos(unit_x, unit_y)
    local scene = game.Scene.instance
    if scene:IsWalkable(lx, ly) then
        self:DoFindWay(unit_x, unit_y)

        self:CalcWayPointList()
    end
end

function CurMapView:DoFindWay(unit_x,unit_y, callback)
    local main_role = game.Scene.instance:GetMainRole()
    if main_role == nil then
        return
    end
    main_role:GetOperateMgr():DoFindWay(unit_x,unit_y, 2, callback)
end

function CurMapView:UnitPosToMiniPos(x, y)
    x = x - self.unit_offset_x
    y = y - self.unit_offset_y

    local pix_width = x*self.mini_scale_x + self.loader_x + self.mini_offset_x
    local pix_height = self.loader_height - y*self.mini_scale_y + self.loader_y + self.mini_offset_y

    return pix_width,pix_height
end

function CurMapView:MiniPosToUnitPos(x, y)
    local unit_x = (x-self.mini_offset_x-self.loader_x)/self.mini_scale_x
    local unit_y = -(y-self.mini_offset_y-self.loader_y-self.loader_height)/self.mini_scale_y

    unit_x = unit_x + self.unit_offset_x
    unit_y = unit_y + self.unit_offset_y

    return unit_x,unit_y
end

function CurMapView:LogicPosToMiniPos(x, y)
    local ux, uy = game.LogicToUnitPos(x, y)
    return self:UnitPosToMiniPos(ux, uy)
end

function CurMapView:MiniPosToLogicPos(x, y)
    local unit_x,unit_y = self:MiniPosToUnitPos(x, y)

    return unit_x/game.logic_tile_size,unit_y/game.logic_tile_size
end

function CurMapView:OnUpdateMapPos(x, y)
    local mini_x,mini_y = self:UnitPosToMiniPos(x, y)
    self.img_pos:SetPosition(mini_x,mini_y)

    return mini_x,mini_y
end

function CurMapView:UpdatePosShow(unit_x, unit_y)
    -- local lx,ly = game.UnitToLogicPos(unit_x,unit_y)
    -- self.rtx_server_line:SetText( string_format(config.words[2409], self.scene_name, lx, ly))
end

local next_update_time = 0
local map_unit_pos = cc.vec2(0,0)
local role_dir = cc.vec2(0,0)
local angle_speed = 180
function CurMapView:Update(now_time, elapse_time)
    if now_time >= next_update_time then
        local main_role = game.Scene.instance:GetMainRole()
        if main_role == nil then
            return
        end
        if main_role then
            local posx,posy = main_role:GetUnitPosXY()
            if map_unit_pos.x ~= posx or map_unit_pos.y ~= posy then
                map_unit_pos.x = posx
                map_unit_pos.y = posy
                
                local mini_x,mini_y = self:OnUpdateMapPos(posx,posy)
                self:CheckWayPoint(mini_x,mini_y)

                next_update_time = now_time + 0.05
            end

            local dirx,diry = main_role:GetDirXY()
            if role_dir.x ~= dirx or role_dir.y~=diry then
                role_dir.x = dirx
                role_dir.y = diry

                local x,y,z = main_role:GetRotation()
                if not self.last_angle then
                    self.last_angle = y
                    self.img_pos:SetRotation(y)
                end

                local delta_angle = y - self.last_angle
                if math.abs(delta_angle) > 0 then
                    local dur = math.max(math.min(delta_angle/angle_speed,0.4),0.08)
                    self.img_pos:TweenRotate(y, dur)

                    self.last_angle = y
                end
            end
        end
    end
end

function CurMapView:OnDoFindWay(path_list)
    local min_len = 10
    local last_point = path_list[1]
    local sort_path = {}
    for k,v in ipairs(path_list) do
        local sub_point = cc.pSub3(v,last_point)
        local len = cc.pGetLength3(sub_point)
        if len >= min_len then
            if len >= min_len*1.5 and k>1 then
                local num = math.ceil(len/min_len)
                local delta_x = sub_point.x / num
                local delta_z = sub_point.z / num
                for i=1,num-1 do
                    local point = {x=last_point.x+delta_x*i, y=0, z=last_point.z+delta_z*i}
                    table.insert(sort_path, point)
                end
            end

            table.insert(sort_path, v)

            last_point = v
        end
    end

    for k,v in ipairs(sort_path or {}) do
        self:AddWayPoint(self:UnitPosToMiniPos(v.x,v.z))
    end
end

function CurMapView:AddWayPoint(x,y)
    local way_point = _ui_mgr:CreateObject("ui_world_map", "way_point")
    way_point:SetPosition(x,y)    
    self:GetRoot():AddChildAt(way_point,self.loader_index+1)

    table.insert(self.way_point_list, {x=x,y=y, point=way_point})
end

function CurMapView:ClearWayPoint()
    for _,v in ipairs(self.way_point_list or {}) do
        v.point:Dispose()
    end
    self.way_point_list = {}
end

function CurMapView:CheckWayPoint(mini_x, mini_y)
    local way_point = self.way_point_list[1]
    if way_point then
        local mini_pos = {x=mini_x, y=mini_y}

        local len = cc.pGetLength(cc.pSub(way_point,mini_pos))
        if len <= 28 then
            local seq = DOTween.Sequence()
            seq:Append(way_point.point:TweenFade(0,0.3))
            seq:OnComplete(function()
                way_point.point:Dispose()
            end)
            seq:SetAutoKill(true)
            
            table.remove(self.way_point_list,1)
        end
    end
end

function CurMapView:InitMapLine()
    local scene_id = game.Scene.instance:GetSceneID()
    local line_id = game.Scene.instance:GetServerLine()
    local scene_cfg = config.scene[scene_id]

    self.role_lmt = scene_cfg.role_lmt
    self.cur_line_id = line_id

    self.rtx_server_line = self._layout_objs["rtx_server_line"]

    if line_id > 0 then
        self.rtx_server_line:SetText(string.format(config.words[2418], scene_cfg.name, line_id))
    else
        self.rtx_server_line:SetText(scene_cfg.name)
    end

    self.is_show_line = false
    self.rtx_server_line:AddClickCallBack(function()
        self:ShowMapLine()
    end)

    self.group_line = self._layout_objs["group_line"]

    self.list_line = self._layout_objs["list_line"]
    self.img_line_bg = self._layout_objs["img_line_bg"]

    self.shape_line = self._layout_objs["shape_line"]
    self.shape_line:AddClickCallBack(function()
        self:ShowMapLine()
    end)

    self.is_first_click = true
    self.line_ctrl = self:GetRoot():AddControllerCallback("line_ctrl", function(idx)
        if self.is_first_click then
            self.is_first_click = false
            return
        end
        local info = self.line_info[idx+1]
        self:OnClickLineItem(info.line_id, info.role_num)
    end)

end

function CurMapView:OnMapLineInfo(data)
    --[[
        "scene_id__I",
        "line_info__T__line_id@C##role_num@C",
    ]]
    self.line_info = data.line_info
    self:UpdateMapLineList(data.line_info)    
end

function CurMapView:ShowMapLine()
    if self.cur_line_id <= 0 then
        game.GameMsgCtrl.instance:PushMsg(config.words[2426])
        return
    end

    self.is_show_line = not self.is_show_line
    self.group_line:SetVisible(self.is_show_line)
end

function CurMapView:UpdateMapLineList(info)
    table.sort(info, function(v1,v2)
        return v1.line_id<v2.line_id
    end)

    local line_num = #info
    self.list_line:SetItemNum(line_num)

    local idx = 1
    for i=1,line_num do
        local data = info[i]
        local line_id = data.line_id
        local role_num = data.role_num
        local obj = self.list_line:GetChildAt(i-1)

        local txt_line = obj:GetChild("txt_line")
        txt_line:SetText(string.format(config.words[2419], data.line_id))

        local role_num = data.role_num
        local per = (role_num/self.role_lmt)*100

        local word_color = game.Color.Green
        local word_id = 2420
        if per >= 100 then
            word_id = 2422
            word_color = game.Color.Red
        elseif per >= 75 then
            word_id = 2421
            word_color = game.Color.PaleYellow
        end
        local txt_cond = obj:GetChild("txt_cond")
        txt_cond:SetText(config.words[word_id])
        txt_cond:SetColor(table.unpack(word_color))

        if line_id == self.cur_line_id then
            idx = i
        end
    end

    self.list_line:SetSize(540, line_num * 50)
    self.img_line_bg:SetSize(540, 20 + line_num * 50)

    self.line_ctrl:SetSelectedIndexEx(idx-1)
end

function CurMapView:OnClickLineItem(line_id, role_num)
    if self.cur_line_id == line_id then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[2423], line_id))
        return
    end

    local per = (role_num/self.role_lmt)*100
    if per >= 100 then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[2424], line_id))
        return
    end

    -- 切换分线
    local main_role = game.Scene.instance:GetMainRole()
    if main_role == nil then
        return
    end
    main_role:GetOperateMgr():DoChangeScene(self.cur_scene_id, line_id)

    self.group_line:SetVisible(false)
    self.ctrl:CloseView()
end

function CurMapView:AddItem(item, delete_func, obj_func)
    local data = {
        item = item,
        delete_func = delete_func,
        obj_func = obj_func,
    }
    self.item_id = self.item_id + 1
    self.item_map[self.item_id] = data

    local obj = item
    if obj_func then
        obj = obj_func(item)
    end
    self:GetRoot():AddChild(obj)
    return self.item_id
end

function CurMapView:RemoveItem(item_id)
    local data = self.item_map[item_id]
    if data then
        if data.delete_func then
            data.delete_func(data.item)
        else
            data.item:Dispose()
        end
        self.item_map[item_id] = nil
    end
end

function CurMapView:UpdateItemPos(item_id, x, y)
    local data = self.item_map[item_id]
    if data then
        local obj = data.item
        if data.obj_func then
            obj = data.obj_func(data.item)
        end
        local mini_x, mini_y = self:LogicPosToMiniPos(x, y)
        obj:SetPosition(mini_x, mini_y)
    end
end

function CurMapView:ClearItems()
    for id, v in pairs(self.item_map) do
        self:RemoveItem(id)
    end
end

function CurMapView:IsLoadMapFinish()
    return self.is_load_map_finish
end

function CurMapView:InitTeamMemberPos()
    self.team_member_list = {}

    local members = game.MakeTeamCtrl.instance:GetTeamMembers()
    for _,v in ipairs(members) do
        local member = v.member
        local pos = game.MakeTeamCtrl.instance:GetTeamMemPos(member.id)
        if pos then
            local scene = pos.scene or self.cur_scene_id
            local line_id = pos.line or self.cur_line_id
            if scene == self.cur_scene_id and line_id==self.cur_line_id then
                self:AddMemPos(member.id, pos.x or 0, pos.y or 0)
            end
        end
    end
end

function CurMapView:AddMemPos(role_id, x, y)
    if role_id == self.main_role_id then
        return
    end

    local info = self.team_member_list[role_id]
    if not info then
        info = {
            point = _ui_mgr:CreateObject("ui_world_map", "green_point"),
            x = 0,
            y = 0,
        }
        self.team_member_list[role_id] = info

        local child_count = self:GetRoot().numChildren
        self:GetRoot():AddChildAt(info.point, child_count)
    end

    if info.x~=x or info.y~=y then
        info.x = x
        info.y = y

        local ux,uy = game.LogicToUnitPos(x,y)
        local x,y = self:UnitPosToMiniPos(ux, uy)
        info.point:SetVisible(true)
        info.point:SetPosition(x,y)
    end
end

function CurMapView:RemoveMemPos(role_id)
    local info = self.team_member_list[role_id]
    if info then
        info.x = 0
        info.y = 0
        info.point:SetVisible(false)
    end
end

function CurMapView:RemoveAllMemPos()
    for _,v in pairs(self.team_member_list) do
        v.x = 0
        v.y = 0
        v.point:SetVisible(false)
    end
end

function CurMapView:ClearAllMemPos()
    for _,v in pairs(self.team_member_list or {}) do
        v.point:Dispose()
    end
    self.team_member_list = nil
end

function CurMapView:OnTeamSyncPos(data)
    self:AddMemPos(data.role_id, data.x, data.y)
end

function CurMapView:OnTeamMemberLeave(role_id)
    self:RemoveMemPos(role_id)
end

function CurMapView:OnNotifyKickOut()
    self:RemoveAllMemPos()
end

function CurMapView:OnTeamMemberAttr(role_id, list)
    local info = self.team_member_list[role_id]
    if info then
        for _,v in ipairs(list) do
            if v.type == game.TeamMemAttrTypes.Scene then
                if v.value ~= self.cur_scene_id then
                    self:RemoveMemPos(role_id)
                    break
                end
            end

            if v.type == game.TeamMemAttrTypes.Line then
                if v.value ~= self.cur_line_id then
                    self:RemoveMemPos(role_id)
                    break
                end
            end
        end
    end
end

return CurMapView
