local FieldBattleJoinTipsView = Class(game.BaseView)

function FieldBattleJoinTipsView:_init(ctrl)
    self._package_name = "ui_field_battle"
    self._com_name = "field_battle_join_tips_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
end

function FieldBattleJoinTipsView:_delete()

end

function FieldBattleJoinTipsView:OpenViewCallBack(act_id)
    self.act_id = act_id

    self:Init()
    self:InitInfos()
end

function FieldBattleJoinTipsView:CloseViewCallBack()
    self:ClearTimer()
end

function FieldBattleJoinTipsView:Init()
    self.txt_blue = self._layout_objs["txt_blue"]
    self.txt_red = self._layout_objs["txt_red"]

    self.btn_join = self._layout_objs["btn_join"]
    self.btn_join:AddClickCallBack(function()
        self.ctrl:SendTerritoryEnter()
    end)

    self.btn_info = self._layout_objs["btn_info"]
    self.btn_info:AddClickCallBack(function()
        self.ctrl:OpenPkInfoView()
    end)
end

local PrepareTime = 5*60
function FieldBattleJoinTipsView:InitInfos()
    local act_info = game.ActivityMgrCtrl.instance:GetActivity(self.act_id)
    if not act_info then
        return
    end

    local now_time = global.Time:GetServerTime()
    local act_st_time = act_info.start_time

    local pass_time = now_time-act_st_time
    local is_preparing = (pass_time<PrepareTime)

    self.btn_join:SetVisible(is_preparing)
    self.btn_info:SetVisible(not is_preparing)

    local against_info = self.ctrl:GetGuildAgainstInfo()
    self.txt_blue:SetText(against_info.blue_name)
    self.txt_red:SetText(against_info.red_name)

    self:StartTimer(PrepareTime-pass_time)
end

function FieldBattleJoinTipsView:StartTimer(delta_time)
    self:ClearTimer()

    if delta_time <= 0 then
        return
    end

    self.timer_id = global.TimerMgr:CreateTimer(delta_time, function()
        self.btn_join:SetVisible(false)
        self.btn_info:SetVisible(true)

        self:ClearTimer()
        return true
    end)
end

function FieldBattleJoinTipsView:ClearTimer()
    if self.timer_id then
        global.TimerMgr:DelTimer(self.timer_id)
        self.timer_id = nil
    end
end

return FieldBattleJoinTipsView
