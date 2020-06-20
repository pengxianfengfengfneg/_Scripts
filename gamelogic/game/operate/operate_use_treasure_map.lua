--藏宝图任务
local OperateUseTreasureMap = Class(require("game/operate/operate_base"))

local UseState = {
    None = 1,
    WaitPos = 2,
    UseMap = 3,
    WaitItem = 4,
}

function OperateUseTreasureMap:_init()
    self.oper_type = game.OperateType.UseTreasureMap
end

function OperateUseTreasureMap:Reset()
    self:ClearCurOperate()
    OperateUseTreasureMap.super.Reset(self)
end

function OperateUseTreasureMap:Init(obj, item_id)
    OperateUseTreasureMap.super.Init(self, obj)
    self.state = UseState.None
    self.item_id = item_id
    return true
end

function OperateUseTreasureMap:Start()
    local ret, type = game.DailyTaskCtrl.instance:CanUseTreasureMap(self.item_id)
    if not ret then
        if type == 1 then
            self.state = UseState.WaitItem
        else
            return false
        end
    end
    game.DailyTaskCtrl.instance:ClearTreasureMapMonInfo()
    
    return true
end

function OperateUseTreasureMap:Update(now_time, elapse_time)
    local ctrl = game.DailyTaskCtrl.instance
    local treasure_info = ctrl:GetTreasureMapInfo()

    if not self:CheckItemState() then
        return
    end

    local ret, type = self:UpdateCurOperate(now_time, elapse_time)
    if ret == false and type == game.OperateType.GoToScenePos then
        return false
    end

    if self.state == UseState.Finish then
        if ctrl:GetTreasureMapEventTag() == 1 then
            return true
        end
    end

    if not self.cur_oper then
        if self.state == UseState.None then
            local pos_info = ctrl:GetTreasureMapPosInfo(self.item_id)
            if not pos_info then
                ctrl:RequestTreasureMapPos(self.item_id)
                self.state = UseState.WaitPos
            else
                self.state = UseState.UseMap
            end
        elseif self.state == UseState.WaitPos then
            if ctrl:GetTreasureMapPosInfo(self.item_id) then
                self.state = UseState.UseMap
            end
        elseif self.state == UseState.UseMap then
            ctrl:CloseDailyTaskView()
            game.DailyTaskCtrl.instance:SetTreasureMapEventTag(0)

            local pos_info = ctrl:GetTreasureMapPosInfo(self.item_id)
            local tar_x, tar_y = game.LogicToUnitPos(pos_info.x, pos_info.y)
            self.cur_oper = self:CreateOperate(game.OperateType.GoToScenePos, self.obj, pos_info.scene_id, tar_x, tar_y, function()
                ctrl:OpenTreasureMapView(self.item_id)
                self.state = UseState.Finish            
            end)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
                return false
            end
        elseif self.state == UseState.Finish then
            if treasure_info.mon_id then
                local scene = game.Scene.instance
                local scene_id = scene and scene:GetSceneID()
                local main_role = scene and scene:GetMainRole()
                local x, y = main_role and main_role:GetLogicPosXY()
                self.cur_oper = self:CreateOperate(game.OperateType.HangMonster, self.obj, scene_id, nil, 1, x, y, treasure_info.mon_id)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                    return false
                end
            end
        end
    end
end

function OperateUseTreasureMap:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local type = self.cur_oper:GetOperateType()
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
            return ret, type
        end
    end
end

function OperateUseTreasureMap:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateUseTreasureMap:OnSaveOper()
	self.obj.scene:SetCrossOperate(self.oper_type, self.item_id)
end

function OperateUseTreasureMap:CheckItemState()
    if self.state == UseState.WaitItem then
        local item_num = game.BagCtrl.instance:GetNumById(self.item_id)
        if item_num > 0 then
            self.state = UseState.None
            return true
        end
        return false
    end
    return true
end

return OperateUseTreasureMap
