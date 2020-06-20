
local SceneLogicLakeBandits = Class(require("game/scene/scene_logic/scene_logic_base"))

local _event_mgr = global.EventMgr
local _ui_mgr = N3DClient.UIManager:GetInstance()

function SceneLogicLakeBandits:_init(scene)
    self.scene = scene
    self.ctrl = game.LakeBanditsCtrl.instance
end

function SceneLogicLakeBandits:_delete()
    
end

function SceneLogicLakeBandits:OnStartScene()
	game.MainUICtrl.instance:SwitchToFighting()
    self.ctrl:OpenSideInfoView()
    
    self.cur_map_view = game.WorldMapCtrl.instance:GetCurMapView()

    self._ev_list = {
        _event_mgr:Bind(game.LakeBanditsEvent.UpdateDragonPosInfo, handler(self, self.UpdateDragonPosInfo)),
        _event_mgr:Bind(game.MapEvent.LoadMapFinish, handler(self, self.OnLoadMapFinish)),
    }
    self.item_list = {}
end

function SceneLogicLakeBandits:StopScene()
    self.ctrl:CloseSideInfoView()
    self.ctrl:CloseTipsView()

    for k, v in pairs(self._ev_list) do
        _event_mgr:UnBind(v)
    end
    self._ev_list = {}
end

function SceneLogicLakeBandits:CreateMonster(vo)
    local monster = self.scene:_CreateMonster(vo)
    local owner_id = self.ctrl:GetDragonOwnerId(monster:GetMonsterId())
    self.ctrl:SetMonsterOwnerType(monster, owner_id)
    return monster
end

function SceneLogicLakeBandits:IsShowLogicExit()
	return false
end

function SceneLogicLakeBandits:DoSceneLogicExit()
	self.ctrl:SendLakeBanditsLeave()
end

function SceneLogicLakeBandits:IsShowLogicDetail()
	return false
end

function SceneLogicLakeBandits:IsShowLogicTaskCom()
	return false
end

function SceneLogicLakeBandits:UpdateDragonPosInfo()
    if not self.cur_map_view:IsOpen() or not self.cur_map_view:IsLoadMapFinish() then
        return
    end

    local info = self.ctrl:GetDragonPosInfo()
    if not info then
        return
    end

    local big_dragon_list = {}
    local little_dragon_list = {}

    for k, v in pairs(info) do
        if v.type == 1 then
            table.insert(big_dragon_list, v)
        else
            table.insert(little_dragon_list, v)
        end
    end
    
    self:AdjustItemList(1, #big_dragon_list, "dragon_icon")
    self:AdjustItemList(2, #little_dragon_list, "little_icon")

    for k, v in ipairs(big_dragon_list) do
        local data = self.item_list[v.type][k]
        self.cur_map_view:UpdateItemPos(data.id, v.x, v.y)
        data.item:SetText(v.lv)
    end
    for k, v in ipairs(little_dragon_list) do
        local data = self.item_list[v.type][k]
        self.cur_map_view:UpdateItemPos(data.id, v.x, v.y)
        data.item:SetText(v.lv)
    end
end

function SceneLogicLakeBandits:AdjustItemList(type, num, com_name)
    local package_name = "ui_lake_bandits"
    local item_list = self.item_list[type]
    if not item_list then
        self.item_list[type] = {}
        item_list = self.item_list[type]
    end
    local item_num = #item_list
    local add_num = num - item_num
    if add_num > 0 then
        for i=1, add_num do
            local item = _ui_mgr:CreateObject(package_name, com_name)
            table.insert(item_list, {id = self.cur_map_view:AddItem(item), item = item})
        end
    elseif add_num < 0 then
        for i=item_num, item_num+add_num+1, -1 do
            local id = item_list[i].id
            table.remove(item_list, i)
            self.cur_map_view:RemoveItem(id)
        end 
    end
end

function SceneLogicLakeBandits:OnLoadMapFinish()
    self.item_list = {}
    self:UpdateDragonPosInfo()
end

function SceneLogicLakeBandits:SetFirstAtt(obj, first_att)

end

return SceneLogicLakeBandits
