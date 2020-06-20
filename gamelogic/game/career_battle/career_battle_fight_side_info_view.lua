local CareerBattleFightSideInfoView = Class(game.BaseView)

function CareerBattleFightSideInfoView:_init(ctrl)
    self._package_name = "ui_career_battle"
    self._com_name = "fight_side_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
    self._view_type = game.UIViewType.Fight
end

function CareerBattleFightSideInfoView:_delete()
    
end

function CareerBattleFightSideInfoView:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
    self:StartBattleTimeCounter(self.ctrl:GetBattleEndTime())
end

function CareerBattleFightSideInfoView:CloseViewCallBack()
    self:StopBattleTimeCounter()
end

function CareerBattleFightSideInfoView:Init()
    self.txt_grade = self._layout_objs["txt_grade"]
    self.txt_battle_time = self._layout_objs["txt_battle_time"]
    self.txt_hurt = self._layout_objs["txt_hurt"]
    self.txt_defer_hurt = self._layout_objs["txt_defer_hurt"]

    self.txt_hurt:SetText(string.format(config.words[4809], 0))
    self.txt_defer_hurt:SetText(string.format(config.words[4810], 0))

    self:SetGradeText()
end

function CareerBattleFightSideInfoView:StartBattleTimeCounter(battle_end_time)
    battle_end_time = battle_end_time or 0
    self:StopBattleTimeCounter()
    self.battle_time_tween = DOTween:Sequence()
    self.battle_time_tween:AppendCallback(function()
        local time = battle_end_time - global.Time:GetServerTime()
        time = math.max(0, time)
        self.txt_battle_time:SetText(string.format(config.words[4808], game.Utils.SecToTime2(time)))
        if time == 0 then
            self:StopBattleTimeCounter()
        end
    end)
    self.battle_time_tween:AppendInterval(1)
    self.battle_time_tween:SetLoops(-1)
    self.battle_time_tween:Play()
end

function CareerBattleFightSideInfoView:StopBattleTimeCounter()
    if self.battle_time_tween then
        self.battle_time_tween:Kill(false)
        self.battle_time_tween = nil
    end
end

function CareerBattleFightSideInfoView:SetGradeText()
    local career = game.RoleCtrl.instance:GetCareer()
    local grade = self.ctrl:GetGrade()
    self.txt_grade:SetText(string.format(config.words[4801], config.career_init[career].name, config.career_battle_grade[grade].name))
end

function CareerBattleFightSideInfoView:RegisterAllEvents()
    local events = {
        [game.CareerBattleEvent.EnterBattleScene] = function(battle_end_time)
            self:StartBattleTimeCounter(battle_end_time)
        end,
        [game.CareerBattleEvent.BattleUpdateHurt] = function(data)
            self.txt_hurt:SetText(string.format(config.words[4809], game.Utils.NumberFormat(tonumber(data.hurt))))
            self.txt_defer_hurt:SetText(string.format(config.words[4810], game.Utils.NumberFormat(tonumber(data.defer_hurt))))
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return CareerBattleFightSideInfoView
