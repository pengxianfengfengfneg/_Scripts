local LakeBanditsSideInfoView = Class(game.BaseView)

function LakeBanditsSideInfoView:_init(ctrl)
    self._package_name = "ui_lake_bandits"
    self._com_name = "lake_bandits_side_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
    self._view_type = game.UIViewType.Fight

    self:AddPackage("ui_lake_exp")
end

function LakeBanditsSideInfoView:_delete()
    
end

function LakeBanditsSideInfoView:OpenViewCallBack()
    self:Init()
    self:UpdateComboLine()
    self:CreateTimeCounter()
    self:RegisterAllEvents()
end

function LakeBanditsSideInfoView:CloseViewCallBack()
    self:StopTimeCounter()
end

function LakeBanditsSideInfoView:Init()
    self.txt_left_num = self._layout_objs["txt_left_num"]
    self.txt_dragon_num = self._layout_objs["txt_dragon_num"]
    self.txt_little_dragon_num = self._layout_objs["txt_little_dragon_num"]
    self.txt_refresh = self._layout_objs["txt_refresh"]
    self.txt_time = self._layout_objs["txt_time"]

    self.txt_left_num:SetText(config.words[4901])
    self.txt_refresh:SetText(config.words[4904])

    self.combo_line = self._layout_objs["combo_line"]

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    self.ctrl_line = self:GetRoot():AddControllerCallback("ctrl_line", function(idx)
        local line_id = self.ctrl:GetLineId()
        if line_id and line_id - 1 ~= idx then
            self.ctrl:SendLakeBanditsSwitch(idx + 1)
        end
    end)

    local cur_line_id = self.ctrl:GetLineId()
    self:OnLineChange(cur_line_id)

    self.txt_dragon_num:SetText(string.format(config.words[4902], 0))
    self.txt_little_dragon_num:SetText(string.format(config.words[4903], 0))
end

function LakeBanditsSideInfoView:UpdateComboLine()
    local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.LakeBandits)
    local items = {}
    local line_info = game.WorldMapCtrl.instance:GetLineList()
    for i=1, #line_info do
        local option = string.format(config.words[4905], i)
        local state = self.ctrl:GetLineRoleState(line_info.role_num)
        if state then
            option = option .. " " .. state
        end
        table.insert(items, option)
    end

    self.ctrl_line:SetPageCount(#items)
    self.combo_line:SetItems(items)

    local cur_line_id = self.ctrl:GetLineId() or 1
    self.combo_line:SetText(items[cur_line_id])
end

function LakeBanditsSideInfoView:CreateTimeCounter()
    local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.LakeBandits)
    if not act then
        self:SetStateCtrl(2)
        return
    elseif act.state ~= game.ActivityState.ACT_STATE_PREPARE then
        self:SetStateCtrl(0)
        return
    end

    self:StopTimeCounter()
    self.time_tween = DOTween.Sequence()
    self.time_tween:AppendCallback(function()
        local time = act.end_time - global.Time:GetServerTime()
        time = math.max(0, time)
        self.txt_time:SetText(game.Utils.SecToTime2(time))
        if time == 0 then
            self:StopTimeCounter()
        end
    end)
    self.time_tween:AppendInterval(1)
    self.time_tween:SetLoops(-1)
    self.time_tween:Play()

    self:SetStateCtrl(1)
end

function LakeBanditsSideInfoView:StopTimeCounter()
    if self.time_tween then
        self.time_tween:Kill(false)
        self.time_tween = nil
    end
end

function LakeBanditsSideInfoView:SetStateCtrl(index)
    self.ctrl_state:SetSelectedIndexEx(index)
    if index == 0 then
        self:Refresh()
    end
end

function LakeBanditsSideInfoView:InitMonsterInfo()
    self.monster_config = self.ctrl:GetMonsterConfig()
end

function LakeBanditsSideInfoView:UpdateMonsterInfo()
    if not self.monster_config then
        self:InitMonsterInfo()
    end
    local dragon_id = self.monster_config.dragon_id
    local total_little_num = 0
    for _, v in pairs(self.monster_config.little_dragon_id) do
        total_little_num = total_little_num + self.ctrl:GetMonsterNum(v[1])
    end

    self.txt_dragon_num:SetText(string.format(config.words[4902], self.ctrl:GetMonsterNum(dragon_id)))
    self.txt_little_dragon_num:SetText(string.format(config.words[4903], total_little_num))
end

function LakeBanditsSideInfoView:GetMonster(mid)
    local scene_logic = game.Scene.instance:GetSceneLogic()
    return scene_logic:GetMonster(mid)
end

function LakeBanditsSideInfoView:OnLineChange(line_id)
    if line_id then
        self.ctrl_line:SetSelectedIndexEx(line_id - 1)
        self:ReqMonInfo()
        game.WorldMapCtrl.instance:SendGetSceneLineInfoReq()
    end
end

function LakeBanditsSideInfoView:ReqMonInfo()
    local line_id = self.ctrl:GetLineId()
    local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.LakeBandits)
    if act and act.state == game.ActivityState.ACT_STATE_ONGOING then
        self.ctrl:SendLakeBanditsDragonMon(line_id)
    end
end

function LakeBanditsSideInfoView:Refresh()
    self:InitMonsterInfo()
end

function LakeBanditsSideInfoView:RegisterAllEvents()
    local events = {
        [game.LakeBanditsEvent.OnLineChange] = function(line_id)
            self:OnLineChange(line_id)
        end,
        [game.LakeBanditsEvent.UpdateDragonMon] = function()
            self:UpdateMonsterInfo()
        end,
        [game.LakeBanditsEvent.UpdateLineRole] = function(line_role)
            self:UpdateComboLine()
        end,
        [game.ActivityEvent.UpdateActivity] = function(act_list)
            local act = act_list[game.ActivityId.LakeBandits]
            if act and act.state == game.ActivityState.ACT_STATE_ONGOING then
                self:StopTimeCounter()
                self:SetStateCtrl(0)
                self:ReqMonInfo()
            end
        end,
        [game.ActivityEvent.StopActivity] = function(act_id)
            if act_id == game.ActivityId.LakeBandits then
                self:StopTimeCounter()
                self:SetStateCtrl(2)
            end
        end,
        [game.MapEvent.OnMapLineInfo] = function(data)
            if data.scene_id == config.lake_bandits_info.scene then
                self:UpdateComboLine()
            end
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return LakeBanditsSideInfoView
