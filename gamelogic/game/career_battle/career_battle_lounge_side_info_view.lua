local CareerBattleLoungeSideInfoView = Class(game.BaseView)

function CareerBattleLoungeSideInfoView:_init(ctrl)
    self._package_name = "ui_career_battle"
    self._com_name = "lounge_side_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
    self._view_type = game.UIViewType.Fight
end

function CareerBattleLoungeSideInfoView:_delete()
    
end

function CareerBattleLoungeSideInfoView:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
    self.ctrl:SendCareerBattleLoungeInfo()
end

function CareerBattleLoungeSideInfoView:CloseViewCallBack()
    self:StopMatchTimeCounter()
end

function CareerBattleLoungeSideInfoView:Init()
    self.txt_grade = self._layout_objs["txt_grade"]
    self.txt_match_time = self._layout_objs["txt_match_time"]
    self.txt_score = self._layout_objs["txt_score"]
    self.txt_battle_times = self._layout_objs["txt_battle_times"]
end

function CareerBattleLoungeSideInfoView:StartMathchTimeCounter()
    self:StopMatchTimeCounter()
    self.match_time_tween = DOTween:Sequence()
    self.match_time_tween:AppendCallback(function()
        local time = 0
        local type = 0
        local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.CareerBattle)
        if act and act.state == game.ActivityState.ACT_STATE_ONGOING then
            time = act.start_time + config.career_battle_info.wait_time - global.Time:GetServerTime()
            if time >= 0 then
                type = 1
            end
        end
        if type ~= 1 then
            if self.lounge_info.leave_times > 0 then
                time = self.lounge_info.match_time - global.Time:GetServerTime()
                type = 2
            end
        end      
        time = math.max(0, time)

        if type == 1 then
            self.txt_match_time:SetText(string.format(config.words[4835], game.Utils.SecToTime2(time)))
        else
            self.txt_match_time:SetText(string.format(config.words[4802], game.Utils.SecToTime2(time)))
            if time <= 10 and time > 0 then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[4831], time))
            end
        end
        if time == 0 then
            if type == 1 then
                self.ctrl:SendCareerBattleLoungeInfo()
            end
            self:StopMatchTimeCounter()
        end
    end)
    self.match_time_tween:AppendInterval(1)
    self.match_time_tween:SetLoops(-1)
    self.match_time_tween:Play()
end

function CareerBattleLoungeSideInfoView:StopMatchTimeCounter()
    if self.match_time_tween then
        self.match_time_tween:Kill(false)
        self.match_time_tween = nil
    end
end

function CareerBattleLoungeSideInfoView:SetGradeText()
    local career = game.RoleCtrl.instance:GetCareer()
    local grade = self.ctrl:GetGrade()
    self.txt_grade:SetText(string.format(config.words[4801], config.career_init[career].name, config.career_battle_grade[grade].name))
end

function CareerBattleLoungeSideInfoView:SetScoreText()
    local score = self.lounge_info.score
    self.txt_score:SetText(string.format(config.words[4803], score))
end

function CareerBattleLoungeSideInfoView:SetBattleTimesText()
    local battle_times = self.lounge_info.battle_times
    local left_times = self.lounge_info.leave_times
    self.txt_battle_times:SetText(string.format(config.words[4804], battle_times, left_times))
end

function CareerBattleLoungeSideInfoView:Refresh()
    self:StartMathchTimeCounter()
    self:SetScoreText()
    self:SetBattleTimesText()
    self:SetGradeText()
end

function CareerBattleLoungeSideInfoView:RegisterAllEvents()
    local events = {
        [game.CareerBattleEvent.UpdateLoungeInfo] = function(lounge_info)
            self.lounge_info = lounge_info
            self:Refresh()
        end,
        [game.ActivityEvent.UpdateActivity] = function(act_list)
            local act = act_list[game.ActivityId.CareerBattle]
            if act and act.state == game.ActivityState.ACT_STATE_ONGOING then
                self.ctrl:SendCareerBattleLoungeInfo()
            end
        end
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return CareerBattleLoungeSideInfoView
