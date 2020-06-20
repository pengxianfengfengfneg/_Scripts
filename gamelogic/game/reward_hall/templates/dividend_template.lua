local DividendTemplate = Class(game.UITemplate)

local config_sprint_level = config.sprint_level
local config_stone_gold = config.stone_gold
local config_top_guild = config.top_guild
local config_lucky_lottery = config.lucky_lottery

local TabConfig = {
    [1] = {
        sprite = "hl_04",
        select = "hl_03",
    },
    [2] = {
        sprite = "hl_06",
        select = "hl_05",
    },
    [3] = {
        sprite = "hl_08",
        select = "hl_07",
    },
    [4] = {
        sprite = "hl_10",
        select = "hl_09",
    },
    [5] = {
        sprite = "hl_12",
        select = "hl_11",
    },
}

local RedConfig = {
    [1] = {
        check_func = function()
            return game.RewardHallCtrl.instance:CheckDividendLevelRedPoint()
        end,
        update_event = {
            game.RewardHallEvent.OnDividendLvGet,
        },
    },
    [4] = {
        check_func = function()
            return game.RewardHallCtrl.instance:CheckDividendStoneRedPoint()
        end,
        update_event = {
            game.RewardHallEvent.OnDividendStoneChange,
        },
    },
    [5] = {
        check_func = function()
            return game.RewardHallCtrl.instance:CheckLuckyLotteryRedPoint()
        end,
        update_event = {
            game.RewardHallEvent.OnDividendLuckyInfo,
        },
    },
}

local guild_rank_type = 4002

function DividendTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "dividend_template"
    self.ctrl = game.RewardHallCtrl.instance
end

function DividendTemplate:OpenViewCallBack()
    self:Init()
    self:BindRedEvent()
    self:RegisterAllEvents()
    game.RankCtrl.instance:GetRankDataReq(guild_rank_type, 1)
    game.RewardHallCtrl.instance:SendDividendInfo()
end

function DividendTemplate:CloseViewCallBack()
    self:StopBoxTreasureAnim()
    self:StopLuckyMoneyAnim()
    self:StopTimeCounter()
end

function DividendTemplate:RegisterAllEvents()
    local events = {
        {game.RewardHallEvent.UpdateDividendInfo, handler(self, self.UpdateDividendInfo)},
        {game.RankEvent.UpdateRightList, handler(self, self.OnUpdateRankList)},
        {game.RewardHallEvent.OnDividendLvGet, handler(self, self.UpdateLevelList)},
        {game.RewardHallEvent.OnDividendStoneChange, handler(self, self.UpdateStoneList)},
        {game.RewardHallEvent.OnDividendLuckyInfo, handler(self, self.UpdateLuckyLotteryInfo)},
    }
    for _, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function DividendTemplate:Init()
    self.ctrl_tab = self:GetRoot():AddControllerCallback("ctrl_tab", function(idx)
        self:OnTabClick(idx+1)
    end)

    self.list_tab = self._layout_objs.list_tab
    for k, v in ipairs(TabConfig) do
        self:SetTabInfo(k)
    end

    self.list_level = self:CreateList("list_level", "game/reward_hall/item/dividend_get_item")
    self.list_level:SetRefreshItemFunc(function(item, idx)
        local cfg = config_sprint_level[idx]
        local state = self.ctrl:GetSprintLevelState(cfg.id)
        local goods_info = config.drop[cfg.reward].client_goods_list[1]
        local item_info = {
            desc = string.format(config.words[3063], cfg.times, cfg.lv),
            info = string.format(config.words[3064], self.ctrl:GetSprintLevelGotNum(cfg.id), cfg.times),
            type = state,
            is_red = state==1,
            goods_info = {id = goods_info[1], num = goods_info[2]},
        }
        item:SetItemInfo(item_info, idx)
        item:AddClickEvent(function()
            self.ctrl:SendDividendLvGet(cfg.id)
        end)
    end)

    local config_stone_gold_sort = {}
    for k, v in pairs(config_stone_gold) do
        table.insert(config_stone_gold_sort, v)
    end
    table.sort(config_stone_gold_sort, function(m, n)
        return m.id < n.id
    end)

    self.list_stone = self:CreateList("list_stone", "game/reward_hall/item/dividend_get_item")
    self.list_stone:SetRefreshItemFunc(function(item, idx)
        local cfg = config_stone_gold_sort[idx]
        local state = self.ctrl:GetStoneGoldState(cfg.id)
        local activity_hall_cfg = self:GetActivityHallConfig(cfg.id)
        local goods_info = config.drop[cfg.reward].client_goods_list[1]
        local item_info = {
            desc = cfg.desc,
            info = string.format(config.words[3065], self.ctrl:GetStoneGoldStage(cfg.id), activity_hall_cfg.times),
            type = state,
            is_red = state==1,
            goods_info = {id = goods_info[1], num = goods_info[2]},
        }
        item:SetItemInfo(item_info, idx)
        item:AddClickEvent(function()
            self.ctrl:SendDividendStoneGet(cfg.id)
        end)
    end)

    self.list_guild = self:CreateList("list_guild", "game/reward_hall/item/dividend_guild_item")
    self.list_guild:SetRefreshItemFunc(function(item, idx)
        local cfg = config_top_guild[idx]
        local columns = self.guild_list_data[idx].columns
        local item_info = {
            rank = cfg.rank,
            name = columns[1].column,
            live = columns[3].column,
            reward = cfg.reward,
        }
        item:SetItemInfo(item_info, idx)
    end)

    self.bar_live = self._layout_objs.bar_live
    self.bar_recharge = self._layout_objs.bar_recharge

    self.box_com = self._layout_objs.box_com
    self.box_com:AddClickCallBack(function()
        local id = self.ctrl:GetLotteryLivelyId()
        local times = self.ctrl:GetLotteryLivelyTimes()
        if not self.play_box_anim then
            if times == 0 then
                game.GameMsgCtrl.instance:PushMsg(config.words[3069])
            else
                self.ctrl:SendDividendLuckyGet(1, id)
            end
        end
    end)
    self.img_box_close = self.box_com:GetChild("img_box_close")
    self.img_box_open = self.box_com:GetChild("img_box_open")

    self.money_com = self._layout_objs.money_com
    self.money_com:AddClickCallBack(function()
        local id = self.ctrl:GetLotteryChargeId()
        local times = self.ctrl:GetLotteryChargeTimes()
        if not self.play_money_anim then
            if times == 0 then
                game.GameMsgCtrl.instance:PushMsg(config.words[3069])
            else
                self.ctrl:SendDividendLuckyGet(2, id)
            end
        end
    end)
    self.img_money_close = self.money_com:GetChild("img_money_close")
    self.img_money_open = self.money_com:GetChild("img_money_open")

    self.txt_box_get_times = self.box_com:GetChild("txt_box_get_times")
    self.txt_lucky_get_times = self.money_com:GetChild("txt_lucky_get_times")

    local live_value_cfg = config_lucky_lottery[1].value
    local max_live_value = live_value_cfg[#live_value_cfg][2]
    local live_bar_size = self._layout_objs["bar_live"]:GetSize()

    for k, v in ipairs(live_value_cfg) do
        local x = v[2] / max_live_value * live_bar_size[1]

        local title = self._layout_objs["bar_live/txt_"..k]
        title:SetText(self:NumberFormat(v[2]))
        title:SetPositionX(x)

        if k ~= #live_value_cfg then
            local line = self._layout_objs["bar_live/img_line_"..k]
            line:SetPositionX(x)
        end
    end

    local recharge_value_cfg = config_lucky_lottery[2].value
    local max_recharge_value = recharge_value_cfg[#recharge_value_cfg][2]
    local recharge_bar_size = self._layout_objs["bar_recharge"]:GetSize()

    for k, v in ipairs(recharge_value_cfg) do
        local x = v[2] / max_recharge_value * recharge_bar_size[1]

        local title = self._layout_objs["bar_recharge/txt_"..k]
        title:SetText(self:NumberFormat(v[2]))
        title:SetPositionX(x)

        if k ~= #live_value_cfg then
            local line = self._layout_objs["bar_recharge/img_line_"..k]
            line:SetPositionX(x)
        end
    end

    self.txt_time = self._layout_objs.txt_time
    self.group_guild = self._layout_objs.group_guild
    self.group_no_guild = self._layout_objs.group_no_guild

    self.ctrl_tab:SetSelectedIndexEx(0)
end

function DividendTemplate:SetTabInfo(idx)
    local tab = self.list_tab:GetChildAt(idx-1)
    tab:GetChild("img_icon"):SetSprite(self._package_name, TabConfig[idx].sprite, true)
    tab:GetChild("img_icon2"):SetSprite(self._package_name, TabConfig[idx].select, true)
end

function DividendTemplate:OnTabClick(idx)

end

function DividendTemplate:UpdateDividendInfo()
    self:UpdateLevelList()
    self:UpdateStoneList()
    self:UpdateLuckyLotteryInfo()
    self:StartTimeCounter()

    for k, v in pairs(RedConfig) do
        self:UpdateRedPoint(k)
    end
end

function DividendTemplate:UpdateLevelList()
    local item_num = table.nums(config_sprint_level)
    self.list_level:SetItemNum(item_num)
end

function DividendTemplate:UpdateStoneList()
    local item_num = table.nums(config_stone_gold)
    self.list_stone:SetItemNum(item_num)
end

function DividendTemplate:OnUpdateRankList(data)
    local rank_info = data.info
    if rank_info.type == guild_rank_type then
        self:UpdateGuildList(rank_info.items)
    end
end

function DividendTemplate:UpdateGuildList(data)
    self.guild_list_data = {}
    for k, v in pairs(data or game.EmptyTable) do
        local item = v.item
        if item.rank <= 10 then
            table.insert(self.guild_list_data, item)
        end
    end
    table.sort(self.guild_list_data, function(m, n)
        return m.rank < n.rank
    end)
    local item_num = #self.guild_list_data
    self.list_guild:SetItemNum(item_num)
    self.group_guild:SetVisible(item_num > 0)
    self.group_no_guild:SetVisible(item_num == 0)
end

function DividendTemplate:UpdateLuckyLotteryInfo(data)
    self.txt_box_get_times:SetText(string.format(config.words[3066], self.ctrl:GetLotteryLivelyTimes()))
    self.txt_lucky_get_times:SetText(string.format(config.words[3067], self.ctrl:GetLotteryChargeTimes()))

    local live_value_cfg = config_lucky_lottery[1].value
    local max_live = live_value_cfg[#live_value_cfg][2]
    local cur_live = math.min(self.ctrl:GetLotteryLively(), max_live)
    self._layout_objs["bar_live/bar"]:SetProgressValue(cur_live/max_live*100)
    self._layout_objs["bar_live/bar"]:GetChild("title"):SetText(string.format("%d/%d", cur_live, max_live))

    local recharge_value_cfg = config_lucky_lottery[2].value
    local max_recharge = recharge_value_cfg[#recharge_value_cfg][2]
    local cur_recharge = math.min(self.ctrl:GetLotteryCharge(), max_recharge)
    self._layout_objs["bar_recharge/bar"]:SetProgressValue(cur_recharge/max_recharge*100)
    self._layout_objs["bar_recharge/bar"]:GetChild("title"):SetText(string.format("%d/%d", cur_recharge, max_recharge))

    local update_type = data and data.type
    if update_type == 1 then
        self:PlayBoxTreasureAnim()
    elseif update_type == 2 then
        self:PlayLuckyMoneyAnim()
    end
end

function DividendTemplate:PlayBoxTreasureAnim()
    self:StopBoxTreasureAnim()
    self.tween_box = DOTween.Sequence()
    self.tween_box:AppendCallback(function()
        self.play_box_anim = true
        self.img_box_close:SetVisible(false)
        self.img_box_open:SetVisible(true)
    end)
    self.tween_box:AppendInterval(1.3)
    self.tween_box:AppendCallback(function()
        self.img_box_close:SetVisible(true)
        self.img_box_open:SetVisible(false)
    end)
    self.tween_box:OnComplete(function()
        self.play_box_anim = false
    end)
    self.tween_box:SetAutoKill(true)
end

function DividendTemplate:StopBoxTreasureAnim()
    if self.tween_box then
        self.tween_box:Kill(false)
        self.tween_box = nil
    end
    self.img_box_close:SetVisible(true)
    self.img_box_open:SetVisible(false)
    self.play_box_anim = false
end

function DividendTemplate:PlayLuckyMoneyAnim()
    self:StopLuckyMoneyAnim()
    self.tween_money = DOTween.Sequence()
    self.tween_money:AppendCallback(function()
        self.play_money_anim = true
        self.img_money_close:SetVisible(false)
        self.img_money_open:SetVisible(true)
    end)
    self.tween_money:AppendInterval(1.3)
    self.tween_money:AppendCallback(function()
        self.img_money_close:SetVisible(true)
        self.img_money_open:SetVisible(false)
    end)
    self.tween_money:OnComplete(function()
        self.play_money_anim = false
    end)
    self.tween_money:SetAutoKill(true)
end

function DividendTemplate:StopLuckyMoneyAnim()
    if self.tween_money then
        self.tween_money:Kill(false)
        self.tween_money = nil
    end
    self.img_money_close:SetVisible(true)
    self.img_money_open:SetVisible(false)
    self.play_money_anim = false
end

function DividendTemplate:StartTimeCounter()
    local activity = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.Dividend)
    if activity and activity.state == game.ActivityState.ACT_STATE_ONGOING then
        local end_time = activity.end_time
        self:StopTimeCounter()
        self.tween_time = DOTween:Sequence()
        self.tween_time:AppendCallback(function()
            local time = end_time - global.Time:GetServerTime()
            time = math.max(0, time)
            if time > 0 then
                self.txt_time:SetText(string.format(config.words[3068], self:GetTime(time)))
            else
                self.txt_time:SetText(config.words[4759])
                self:StopTimeCounter()
            end
        end)
    end
end

function DividendTemplate:StopTimeCounter()
    if self.tween_time then
        self.tween_time:Kill(false)
        self.tween_time = nil
    end
end

local DaySec = 1*24*60*60
local HourSec = 60*60
local MinSec = 60
function DividendTemplate:GetTime(sec)
    local day = math.floor(sec / DaySec)
    local hour = math.floor(sec % DaySec / HourSec)
    if day ~= 0 then
        return string.format("%d%s%d%s", day, config.words[107], hour, config.words[108])
    else
        return string.format("%d%s", hour, config.words[108])
    end
end

function DividendTemplate:GetActivityHallConfig(id)
    for k, v in pairs(config.activity_hall) do
        if v.id == id then
            return v
        end
    end
end

function DividendTemplate:BindRedEvent()
    for k, v in pairs(RedConfig) do
        for _, cv in pairs(v.update_event) do
            self:BindEvent(cv, function()
                self:UpdateRedPoint(k)
            end)
        end
    end
end

function DividendTemplate:UpdateRedPoint(id)
    local tab = self.list_tab:GetChildAt(id-1)
    local visible = RedConfig[id].check_func()
    if tab then
        game_help.SetRedPoint(tab, visible, -4, 12)
    end
end

function DividendTemplate:NumberFormat(val)
    if val < 10000 then
        return val
    else
        return math.floor(val / 10000) .. config.words[4734]
    end
end

return DividendTemplate