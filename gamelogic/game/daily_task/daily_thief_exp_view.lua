local DailyThiefExpView = Class(game.BaseView)

function DailyThiefExpView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "daily_thief_exp_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.list_map = {}
    self.tween_map = {}
    self.index_map = {}
end

function DailyThiefExpView:_delete()
    
end

function DailyThiefExpView:OpenViewCallBack(end_time)
    self.end_time = end_time
    self:Init()
    self:InitList()
    self:StartCountTime()
    self:RegisterAllEvents()
end

function DailyThiefExpView:CloseViewCallBack()
    self:Clear()
    self:StopCountTime()
end

function DailyThiefExpView:Init()
    self.btn_play = self._layout_objs["btn_play"]
    self.btn_play:SetEnable(true)
    self.btn_play:AddClickCallBack(function()
        self.ctrl:SendDailyThiefExpAdven()
    end)

    self.btn_get = self._layout_objs["btn_get"]
    self.btn_get:SetEnable(true)
    self.btn_get:AddClickCallBack(function()
        self.btn_get:SetEnable(false)
        self.ctrl:SendDailyThiefExpAdvenGet()
        self.end_time = global.Time:GetServerTime() + 2
    end)

    self.txt_time = self._layout_objs["txt_time"]

    self.ctrl_num = self:GetRoot():GetController("ctrl_num")
    self.ctrl_state = self:GetRoot():GetController("ctrl_state")

    self.ctrl_num:SetSelectedIndexEx(0)
    self.ctrl_state:SetSelectedIndexEx(0)
end

function DailyThiefExpView:Play(num)
    local n = num
    self.btn_play:SetEnable(false)

    if self.tween then
        self.tween:Kill(true)
        self.tween = nil
    end
    self.tween = DOTween:Sequence()
    local interval = 0.75

    for i=1, 5 do
        self.tween:AppendCallback(function()
            self:PlayAnim(i, n % 10)
            self.ctrl_num:SetSelectedIndexEx(i)
            n = math.floor(n / 10)
        end)
        self.tween:AppendInterval(interval)
    end
end

function DailyThiefExpView:PlayAnim(pos, target_num)
    local round = 1

    self.index_map[pos] = self.index_map[pos] and self.index_map[pos] % 10 or 1
    if self.index_map[pos] == 0 then
        self.index_map[pos] = 10
    end

    local turn_num = (11 - self.index_map[pos] % 10) + round * 10 + target_num

    if self.tween_map[pos] then
        self.tween_map[pos]:Kill(false)
        self.tween_map[pos] = nil
    end
    self.tween_map[pos] = DOTween:Sequence()

    for i=1, turn_num do
        self.tween_map[pos]:AppendCallback(function()
            self.list_map[pos].scrollPane:ScrollDown(1, false)
            self.index_map[pos] = self.index_map[pos] + 1
        end)
        self.tween_map[pos]:AppendInterval(0.1)
    end
    self.tween_map[pos]:Play()
    self.tween_map[pos]:OnComplete(function()
        self.tween_map[pos] = nil
        if table.nums(self.tween_map) == 0 then
            self.ctrl_state:SetSelectedIndexEx(1)
        end
    end)
end

function DailyThiefExpView:InitList()
    for i=1, 5 do
        self.list_map[i] = self._layout_objs["list_num_" .. i]
        self.list_map[i]:AddItemProviderCallback(function(idx)
            return "ui_daily_task:" .. string.format("%02d", idx)
        end)
        self.list_map[i]:AddRenderCallback(function(idx, obj) end)
        self.list_map[i]:SetVirtualAndLoop()
        self.list_map[i]:SetItemNum(10)
    end
end

function DailyThiefExpView:Clear()
    for key, tween in pairs(self.tween_map) do
        if tween then
            tween:Kill(false)
            self.tween_map[key] = nil
        end
    end

    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end

    for key, list in pairs(self.list_map) do
        list:SetItemNum(0)
        self.list_map[key] = nil
    end

    for key, index in pairs(self.index_map) do
        self.index_map[key] = nil
    end
end

function DailyThiefExpView:StartCountTime()
    self:StopCountTime()
    self.time_tween = DOTween:Sequence()
    self.time_tween:AppendCallback(function()
        local time = self.end_time - global.Time:GetServerTime()
        time = math.max(0, time)
        self.txt_time:SetText(string.format(config.words[1944], game.Utils.SecToTime2(time)))
        if time == 0 then
            self:StopCountTime()
            self:Close()
        end
    end)
    self.time_tween:AppendInterval(1)
    self.time_tween:SetLoops(-1)
end

function DailyThiefExpView:StopCountTime()
    if self.time_tween then
        self.time_tween:Kill(false)
        self.time_tween = nil
    end
end

function DailyThiefExpView:RegisterAllEvents()
    local events = {
        [game.DailyTaskEvent.ThiefExpAdven] = function(exp)
            self:Play(exp)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return DailyThiefExpView
