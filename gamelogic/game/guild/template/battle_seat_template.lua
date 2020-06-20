local BattleSeatTemplate = Class(game.UITemplate)

local handler = handler

function BattleSeatTemplate:_init(view)
    self.parent = view
    self.ctrl = game.FieldBattleCtrl.instance
end

function BattleSeatTemplate:OpenViewCallBack()
    self:Init()
    self:UpdateField()
    self:UpdateNextTime()
    self:UpdateTarget()
    self:RegisterAllEvents()
end

function BattleSeatTemplate:CloseViewCallBack()
    self:ClearFieldItems()
end

function BattleSeatTemplate:RegisterAllEvents()
    local events = {
        {game.FieldBattleEvent.OnTerritoryInfo, handler(self, self.OnTerritoryInfo)}
    }   
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

--领地争夺战
function BattleSeatTemplate:Init()
    self.btn_info = self._layout_objs["btn_info"]
    self.btn_info:AddClickCallBack(function()
        game.GuildCtrl.instance:OpenGuildBattleinfoView()
    end)
    
    self.btn_battle_info = self._layout_objs["btn_battle_info"]
    self.btn_battle_info:AddClickCallBack(function()
        if not self:CheckMatches() then
            return game.GameMsgCtrl.instance:PushMsg(config.words[5276])
        end
        game.GuildCtrl.instance:OpenFieldBattleAgainstInfoView()
    end)

    self.btn_join = self._layout_objs["btn_join"]
    self.btn_join:AddClickCallBack(function()
        if not self:CheckActOpen() then
            return game.GameMsgCtrl.instance:PushMsg(config.words[5262])
        end
        self.ctrl:SendTerritoryEnter()
    end)

    self.txt_forcecast = self._layout_objs["txt_forcecast"]
    self.txt_guild_against = self._layout_objs["txt_guild_against"]

    self:InitFieldItems()
end

function BattleSeatTemplate:InitFieldItems()
    self.list_field_items = {}
    local item_class = require("game/guild/item/guild_battle_item")
    for i=1,7 do
        local field_item = self._layout_objs["field_item_" .. i]
        if field_item then
            local item = item_class.New(i,self)
            item:SetVirtual(field_item)
            item:Open()

            table.insert(self.list_field_items, item)
        end
    end
end

function BattleSeatTemplate:ClearFieldItems()
    for _,v in ipairs(self.list_field_items or {}) do
        v:DeleteMe()
    end
    self.list_field_items = nil
end

function BattleSeatTemplate:OnTerritoryInfo(data)
    self:UpdateField()
    self:UpdateNextTime()
    self:UpdateTarget()
end

function BattleSeatTemplate:UpdateField()
    local territory_data = self.ctrl:GetTerritoryData()
    local territories = territory_data.territories
    if not territories then
        return
    end

    table.sort(territories,function(v1,v2)
        return v1.id<v2.id
    end)

    for k,v in ipairs(territories) do
        local item = self.list_field_items[k]
        if item then
            item:UpdateData(v)
        end
    end
end

local RoundActs = {
    [1] = 1010,
    [2] = 1011,
    [3] = 1012,
}
local RoundWords = {
    [1] = config.words[5257],
    [2] = config.words[5258],
    [3] = config.words[5259],
}
function BattleSeatTemplate:UpdateNextTime()
    local server_time = global.Time:GetServerTime()
    local round = self.ctrl:GetTerritoryRound()
    if not round then
        self.txt_forcecast:SetVisible(false)
        return
    end

    self.txt_forcecast:SetVisible(true)

    local cur_act_id = RoundActs[round]
    local next_act_id = RoundActs[round+1]

    if not cur_act_id then
        cur_act_id = RoundActs[1]
    end

    if not next_act_id then
        next_act_id = RoundActs[1]
    end

    local act_info = game.ActivityMgrCtrl.instance:GetActivity(cur_act_id)
    if act_info then
        -- 活动进行中
        self.next_act_delta_time = 0

        local round_words = RoundWords[round] or RoundWords[1]
        self.txt_forcecast:SetText(string.format(config.words[5255], round_words, config.words[5271]))
    else
        -- 活动未开启，预告
        local coming_info = game.ActivityMgrCtrl.instance:GetActComingTime(next_act_id)
        local delta_time = coming_info.delta_time

        self.next_act_delta_time = delta_time

        local round_words = RoundWords[round] or RoundWords[1]
        local one_day_sec = 1*24*3600
        self:ClearTimer()
        self.timer_id = global.TimerMgr:CreateTimer(1, function()
            delta_time = delta_time - 1

            self.next_act_delta_time = delta_time

            if delta_time > one_day_sec then
                local day = math.ceil(delta_time/one_day_sec)
                local str = day .. config.words[5256]
                self.txt_forcecast:SetText(string.format(config.words[5255],round_words,str))
            else
                local str = game.Utils.SecToTimeCn(delta_time, 3)
                self.txt_forcecast:SetText(string.format(config.words[5255],round_words,str))
            end

            if delta_time <= 0 then
                self:ClearTimer()
                return true
            end
        end)
    end
end

function BattleSeatTemplate:UpdateTarget()
    local guild_id = game.GuildCtrl.instance:GetGuildId()
    local field_info = self.ctrl:GetTerritoryInfoForGuild(guild_id)

    local str = config.words[5262]
    if field_info then
        local target_field_id = nil
        local field_id = field_info.id
        for k,v in ipairs(game.FieldBattlePkConfig) do
            if v[1]==field_id or v[2]==field_id then
                target_field_id = k
                break
            end
        end
        local cfg = config.territory[target_field_id]
        if cfg then
            str = string.format(config.words[5261], cfg.name)
        else
            cfg = config.territory[1]
            str = string.format(config.words[5272], cfg.name)
        end
    end
    self.txt_guild_against:SetText(str)
end

function BattleSeatTemplate:ClearTimer()
    if self.timer_id then
        global.TimerMgr:DelTimer(self.timer_id)
        self.timer_id = nil
    end
end

function BattleSeatTemplate:GetNextDeltaTime()
    return self.next_act_delta_time
end

function BattleSeatTemplate:CheckActOpen()
    for _,v in ipairs(RoundActs) do
        local act_info = game.ActivityMgrCtrl.instance:GetActivity(v)
        if act_info then
            return true
        end
    end
    return false
end

function BattleSeatTemplate:CheckMatches()
    local matches = game.FieldBattleCtrl.instance:GetTerritoryMatches()
    return #matches>0
end

return BattleSeatTemplate