local GuildSeatView = Class(game.BaseView)

local act_view_map = {
    [game.ActivityId.GuildWine] = {
        view_func = function() 
            return game.GuildCtrl.instance:OpenGuildWineSideInfoView() 
        end, 
        open_state = game.ActivityState.ACT_STATE_PREPARE,
        visible_func = function()
            local visible = game.RoleCtrl.instance:GetRoleLevel() >= config.guild_wine_act.open_lv
            return visible
        end,
    },
    [game.ActivityId.Territory_1] = { 
        view_func = function(act_id)
            return game.FieldBattleCtrl.instance:OpenJoinTipsView(act_id)
        end, 
        open_state = game.ActivityState.ACT_STATE_ONGOING,
        visible_func = function(act_id)
            local visible = game.FieldBattleCtrl.instance:IsGuildJoin()
            return visible
        end,
    },
}
act_view_map[game.ActivityId.Territory_2] = act_view_map[game.ActivityId.Territory_1]
act_view_map[game.ActivityId.Territory_3] = act_view_map[game.ActivityId.Territory_1]

function GuildSeatView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_seat_view"
    self.ctrl = ctrl
    self.not_add_mgr = true

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
    self._view_type = game.UIViewType.Fight
end

function GuildSeatView:_delete()
    
end

function GuildSeatView:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
    self:Refresh()
    self:UpdateTaskCom()
end

function GuildSeatView:CloseViewCallBack()
    self.act = nil
    self:CloseActView()
end

function GuildSeatView:RegisterAllEvents()
    local events = {
        {game.ActivityEvent.UpdateActivity, handler(self, self.OnUpdateActivity)},
        {game.ActivityEvent.StopActivity, handler(self, self.OnStopActivity)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildSeatView:Init()
    self.act_view_map = act_view_map
end

function GuildSeatView:Refresh(act)
    local act = act or self:GetActiveGuildAct()
    if act and self:CanOpenActView(act) then
        if self.act and self.act.act_id == act.act_id then
            if self.act_view and self.act_view:IsOpen() then
                self:FireEvent(game.GuildEvent.OnActStateChange, act.act_id, act.state)
                return
            end
        end

        local act_cfg = self.act_view_map[act.act_id]
        if not act_cfg.visible_func(act.act_id) then
            return
        end

        self:CloseActView()

        self.act = act
        self.act_view = act_cfg.view_func(act.act_id)
    end
end

function GuildSeatView:CanOpenActView(act)
    local cfg = act and self.act_view_map[act.act_id]
    if cfg and (not cfg.open_state or act.state >= cfg.open_state) then
        return true
    end
    return false
end

function GuildSeatView:GetActiveGuildAct()
    local act_list = game.ActivityMgrCtrl.instance:GetActivities()
    if not act_list then
        return nil
    end
    for k, v in pairs(self.act_view_map) do
        if act_list[k] then
            return act_list[k]
        end
    end
end

function GuildSeatView:GetOpenActView()
    return self.act_view
end

function GuildSeatView:OnUpdateActivity(act_list)
    for k, v in pairs(self.act_view_map) do
        local act = act_list[k]
        if act and self:CanOpenActView(act) then
            self:Refresh(act)
            self:UpdateTaskCom()
            break
        end
    end
end

function GuildSeatView:OnStopActivity(act_id)
    if self.act and self.act.act_id == act_id then
        self:CloseActView()
        self.act = nil
        self:UpdateTaskCom()
    end
end

function GuildSeatView:CloseActView()
    if self.act_view then
        self.act_view:Close()
        self.act_view = nil
    end
end

function GuildSeatView:UpdateTaskCom()
    local scene_logic = game.Scene.instance:GetSceneLogic()
    scene_logic:SetTaskComVisible(self.act_view == nil)
end

return GuildSeatView
