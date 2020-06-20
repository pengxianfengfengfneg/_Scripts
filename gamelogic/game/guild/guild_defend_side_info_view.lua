local GuildDefendSideInfoView = Class(game.BaseView)

local defend_cfg = {
    [1] = {
        sprite = "sw_04",
    },
    [2] = {
        sprite = "sw_05",
    },
    [3] = {
        sprite = "sw_06",
    },
}

function GuildDefendSideInfoView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_defend_side_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
    self._view_type = game.UIViewType.Fight
end

function GuildDefendSideInfoView:_delete()
    
end

function GuildDefendSideInfoView:OpenViewCallBack()
    self:Init()
    self:InitTripodList()
    self:SetEnemyText()
    self:RegisterAllEvents()
    self.ctrl:SendGuildDefendPanel()
end

function GuildDefendSideInfoView:CloseViewCallBack()
    self:StopRefreshCounter()
    self:StopPublishCounter()
    self:StopEnemyCounter()
    self:DelCloseTimer()
    self.defend_info = nil
end

function GuildDefendSideInfoView:Init()
    self.txt_monster_info = self._layout_objs["txt_monster_info"]
    self.txt_time = self._layout_objs["txt_time"]
    self.txt_enemy = self._layout_objs["txt_enemy"]

    self.txt_enemy:SetText("")
    self:SetCurWaveMonsterText()

    self.enter_flag = true
end

function GuildDefendSideInfoView:InitTripodList()
    self.list_tripod = self:CreateList("list_tripod", "game/guild/item/guild_defend_tripod_item")
    self.list_tripod:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(defend_cfg[idx])
    end)
    self.list_tripod:SetItemNum(#defend_cfg)
end

function GuildDefendSideInfoView:UpdateTripodList()
    local tripod_info = game.Utils.SortByField(self.defend_info.tripod_info or {}, 'tripod_id')
    for k, v in ipairs(tripod_info) do
        defend_cfg[k].hp = v.hp_pert
        defend_cfg[k].id = v.tripod_id
    end
    self.list_tripod:SetItemNum(#defend_cfg)
end

function GuildDefendSideInfoView:DefendTripodHurt(data)
    self.list_tripod:Foreach(function(item)
        if item:GetTripodId() == data.tripod_id then
            item:SetHp(data.hp_pert)
            item:PlayEffect()
        end
    end)
end

function GuildDefendSideInfoView:CreateRefreshCounter()
    if self.defend_info.refresh_time then
        self:StopRefreshCounter()
        local end_time = self.defend_info.refresh_time
        self.tw_refresh = DOTween:Sequence()
        self.tw_refresh:AppendCallback(function()
            local time = end_time - global.Time:GetServerTime()
            time = math.max(time, 0)
            self.txt_time:SetText(string.format(config.words[4797], game.Utils.SecToTime2(time)))
            if time == 0 then
                self:StopRefreshCounter()
            end
        end)
        self.tw_refresh:AppendInterval(1)
        self.tw_refresh:SetLoops(-1)
        self.tw_refresh:Play()
    end
end

function GuildDefendSideInfoView:StopRefreshCounter()
    if self.tw_refresh then
        self.tw_refresh:Kill(false)
        self.tw_refresh = nil
    end
end

function GuildDefendSideInfoView:SetEnemyText()
    if self.defend_info then
        local wave = self.defend_info.wave
        local monster_cfg = self.ctrl:GetDefendMonsterConfig2()
        if monster_cfg[wave].boss_mid ~= 0 then
            local monster = config.monster[monster_cfg[wave].boss_mid]
            self.txt_enemy:SetColor(table.unpack(game.Color.Red))
            self.txt_enemy:SetText(string.format(config.words[4717], monster.name))
            self:StartEnemyCounter()
        else
            wave = wave + 1
            while true do
                if not monster_cfg[wave] then
                    break
                elseif monster_cfg[wave].boss_mid ~= 0 then
                    local monster = config.monster[monster_cfg[wave].boss_mid]
                    self:StopEnemyCounter()
                    self.txt_enemy:SetColor(table.unpack(game.Color.Red))
                    self.txt_enemy:SetText(string.format(config.words[6003], monster.name, wave))
                    break
                else
                    wave = wave + 1
                end
            end
        end
        return
    end
end

function GuildDefendSideInfoView:StartEnemyCounter()
    local delay = 15
    self:StopEnemyCounter()
    self.tw_enemy = DOTween:Sequence()
    self.tw_enemy:AppendInterval(delay)
    self.tw_enemy:AppendCallback(function()
        self.txt_enemy:SetText("")
    end)
    self.tw_enemy:Play()
end

function GuildDefendSideInfoView:StopEnemyCounter()
    if self.tw_enemy then
        self.tw_enemy:Kill(false)
        self.tw_enemy = nil
    end
end

function GuildDefendSideInfoView:CreatePublishCounter()
    if self.defend_info then
        local next_wave = self.defend_info.wave + 1
        local refresh_time = self.defend_info.refresh_time - global.Time:GetServerTime()

        self:StopPublishCounter()

        self.tw_publish = DOTween:Sequence()
        self.tw_publish:AppendCallback(function()
            local time = refresh_time - global.Time:GetServerTime()
            time = math.max(0, time)
            if time > 0 then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[4720], next_wave, time))
            elseif time == 0 then
                self:StopPublishCounter()
            end
        end)
        self.tw_publish:AppendInterval(1)
        self.tw_publish:SetLoops(-1)
        self.tw_publish:Play()
    end
end

function GuildDefendSideInfoView:StopPublishCounter()
    if self.tw_publish then
        self.tw_publish:Kill(false)
        self.tw_publish = nil
    end
end

function GuildDefendSideInfoView:UpdateMonsterInfo(monster_info)
    local num_map = {}
    for k, v in ipairs(monster_info) do
        num_map[v.tripod_id] = v.mon_num
    end

    self.list_tripod:Foreach(function(item)
        local tripod_id = item:GetTripodId()
        item:SetInfo(num_map[tripod_id] or 0)
    end)
end

function GuildDefendSideInfoView:SetCurWaveMonsterText(data)
    local leave_num = data and data.leave_num or 0
    local total_num = data and data.total_num or 0
    local wave = self.defend_info and self.defend_info.wave or 0
    self.txt_monster_info:SetText(string.format(config.words[4716], wave, leave_num, total_num))
end

function GuildDefendSideInfoView:Refresh()
    self:CreateRefreshCounter()
    self:UpdateTripodList()
    self:SetCurWaveMonsterText(self.defend_info)
    self:OpenDefendChoseView()
end

function GuildDefendSideInfoView:OpenDefendChoseView()
    if self.enter_flag then
        local tripod_info = {}
        self.list_tripod:Foreach(function(tripod)
            table.insert(tripod_info, tripod:GetTripodInfo())
        end)
        table.sort(tripod_info, function(m, n)
            return m.id < n.id
        end)
        self.ctrl:OpenGuildDefendChoseView(tripod_info)
        self.enter_flag = false
    end
end

function GuildDefendSideInfoView:CreateCloseTimer(end_time)
    self:DelCloseTimer()
    local time = end_time - global.Time:GetServerTime()
    if time > 0 then
        self.close_timer = global.TimerMgr:CreateTimer(1, function()
            game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6012], time))
            time = time - 1
            if time == 0 then
                self.close_timer = nil
                return true
            end
        end)
    end
end

function GuildDefendSideInfoView:DelCloseTimer()
    if self.close_timer then
        global.TimerMgr:DelTimer(self.close_timer)
        self.close_timer = nil
    end
end

function GuildDefendSideInfoView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateDefendPanelInfo] = function(defend_info)
            self.defend_info = defend_info
            self:Refresh()
        end,
        [game.GuildEvent.DefendTripodHurt] = function(tripod_info)
            self:DefendTripodHurt(tripod_info)
        end,
        [game.GuildEvent.DefendRefresh] = function(defend_info)
            self.defend_info = defend_info
            self:CreateRefreshCounter()
            self:SetEnemyText()
            self:SetCurWaveMonsterText(defend_info)
        end,
        [game.GuildEvent.DefendPublish] = function(defend_info)
            self.defend_info = defend_info
            self:CreateRefreshCounter()
            self:CreatePublishCounter()
        end,
        [game.GuildEvent.UpdateDefendMonInfo] = function(monster_info)
            self:UpdateMonsterInfo(monster_info)
        end,
        [game.GuildEvent.UpdateDefendCurNum] = function(data)
            self:SetCurWaveMonsterText(data)
        end,
        [game.ActivityEvent.UpdateActivity] = function(act_list)
            local act = act_list[game.ActivityId.GuildDefend]
            if act and act.state == game.ActivityState.ACT_STATE_ONGOING then
            end
        end,
        [game.GuildEvent.OnGuildDefendClose] = function(end_time)
            self:CreateCloseTimer(end_time)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildDefendSideInfoView
