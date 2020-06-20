local DailyTaskLineGameView = Class(game.BaseView)

local table_insert = table.insert
local table_remove = table.remove
local vec2 = cc.vec2

function DailyTaskLineGameView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "daily_task_line_game_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function DailyTaskLineGameView:OpenViewCallBack(task_id, game_id)
    self:Init(task_id, game_id)
    self:InitPointList()
    self:InitLineList()
    self:InitTouchArea()
    self:PlayEffect()
end

function DailyTaskLineGameView:CloseViewCallBack()
    self.is_play = false

    for _, v in ipairs(self.list_point) do
        v:DeleteMe()
    end
    self.list_point = nil

    for _, v in ipairs(self.list_line) do
        v:DeleteMe()
    end
    self.list_line = nil

    for _, v in ipairs(self.list_highline) do
        v:DeleteMe()
    end
    self.list_highline = nil

    for _, v in ipairs(self.list_use_highline) do
        v:DeleteMe()
    end
    self.list_use_highline = nil

    self:StopCloseCounter()
    self:StopStarAnim()
    self:StopBombAnim()
end

function DailyTaskLineGameView:Init(task_id, game_id)
    self.task_id = task_id
    self.game_id = game_id

    self.touch_area = self._layout_objs["line_game_com/touch_area"]
    self.layer1 = self._layout_objs["line_game_com/layer1"]
    self.layer2 = self._layout_objs["line_game_com/layer2"]
    self.layer3 = self._layout_objs["line_game_com/layer3"]
    self.wrapper = self._layout_objs["line_game_com/wrapper"]

    self.point_cfg = config.line_game[self.game_id].points

    self.btn_close = self._layout_objs["btn_close"]
    self.btn_close:AddClickCallBack(function()
        self:Close()
    end)

    self.is_play = true
end

function DailyTaskLineGameView:InitPointList()
    self.list_point = {}
    local point_class = require("game/daily_task/item/line_point_item")

    for k, v in ipairs(self.point_cfg) do
        local point = point_class.New(v, k)
        point:Open()
        point:SetParent(self.layer3)
        point:SetHighlight(true)
        table_insert(self.list_point, point)
    end
end

function DailyTaskLineGameView:InitLineList()
    self.list_line = {}
    self.list_highline = {}
    local line_class = require("game/daily_task/item/line_item")
    for k, v in ipairs(self.point_cfg) do
        if k ~= #self.point_cfg then
            local line = line_class.New(self.point_cfg[k], self.point_cfg[k+1], k)
            line:Open()
            line:SetParent(self.layer1)
            table_insert(self.list_line, line)

            local highline = line_class.New(self.point_cfg[k], self.point_cfg[k+1], k)
            highline:Open()
            highline:SetParent(self.layer2)
            highline:SetHighlight(true)
            highline:SetVisible(false)
            table_insert(self.list_highline, highline)
        end
    end

    self.list_data = {}
    self.list_use_highline = {}
end

function DailyTaskLineGameView:InitTouchArea()
    local touch_area_pos = self.touch_area:GetPosition()
    self.touch_area:SetTouchEnable(true)
    self.touch_area:SetTouchBeginCallBack(function(x, y)
        local x, y = self.touch_area:ToLocalPos(x, y)

        local item = self:GetCollideItem(vec2(x, y))
        if item then
            item:SetHighlight(true)
            table_insert(self.list_data, item)
        else
            return
        end

        self.highline = self:GetHighline()
        self.highline:SetVisible(true)
        self.highline:SetStartPos(item:GetPosition())
        self.highline:SetWidth(1)
    end)

    self.touch_area:SetTouchMoveCallBack(function(x, y)
        local x, y = self.touch_area:ToLocalPos(x, y)
        local last_line_point = self:GetLastLinePoint()

        if last_line_point and self.highline then
            self.highline:SetEndPos(vec2(x, y))
            local item = self:GetCollideItem(vec2(x, y))

            if self:CanLinkLinePoint(item) then
                self:LinkPoint(last_line_point, item)
            end
        end
    end)

    self.touch_area:SetTouchEndCallBack(function(x, y)
        local x, y = self.touch_area:ToLocalPos(x, y)
        if self.is_play and not self:IsPlaySuccess() then
            self:Reset()
        end
    end)
end

function DailyTaskLineGameView:IsContainPos(item, pos)
    local item_size = item:GetSize()
    local item_pos = item:GetPosition()
    local min_x, max_x = item_pos.x - item_size[1], item_pos.x + item_size[1]
    local min_y, max_y = item_pos.y - item_size[2], item_pos.y + item_size[2]
    return pos.x >= min_x and pos.x <= max_x and pos.y >= min_y and pos.y <= max_y
end

function DailyTaskLineGameView:GetCollideItem(pos)
    for k, v in ipairs(self.list_point) do
        if self:IsContainPos(v, pos) then
            return v
        end
    end
end

function DailyTaskLineGameView:GetLastLinePoint()
    local num = #self.list_data
    if num > 0 then
        return self.list_data[num]
    end
end

function DailyTaskLineGameView:CanLinkLinePoint(item)
    if not item then
        return false
    end
    for k, v in ipairs(self.list_data) do
        if v:GetIndex() == item:GetIndex() then
            return false
        end
    end
    return true
end

function DailyTaskLineGameView:LinkPoint(start_item, end_item)
    self.highline:SetEndPos(end_item:GetPosition())
    table_insert(self.list_data, end_item)

    self.highline = self:GetHighline()
    if self.highline then
        self.highline:SetStartPos(end_item:GetPosition())
    end

    if self:IsPlaySuccess() then
        self.touch_area:SetTouchEnable(false)
        self:FinishTask()
        self:PlayBombAnim()
    end
end

function DailyTaskLineGameView:GetHighline()
    local num = #self.list_highline
    if num > 0 then
        local highline = self.list_highline[num]
        highline:SetVisible(true)
        highline:SetWidth(0)
        table_remove(self.list_highline, num)
        table_insert(self.list_use_highline, highline)
        return highline
    end
end

function DailyTaskLineGameView:IsPlaySuccess()
    if #self.list_data == #self.list_point then
        for i=1, #self.list_data do
            if self.list_data[i]:GetIndex() ~= self.list_point[i]:GetIndex() then
                return false
            end
        end
        return true
    end
    return false
end

function DailyTaskLineGameView:Reset()
    for k, v in ipairs(self.list_use_highline) do
        v:SetVisible(false)
        table_insert(self.list_highline, v)
    end

    self.list_use_highline = {}
    self.list_data = {}
    self.highline = nil
end

function DailyTaskLineGameView:FinishTask()
    game.TaskCtrl.instance:SendTaskGetReward(self.task_id)
end

function DailyTaskLineGameView:StartCloseCounter()
    self:StopCloseCounter()
    self.tw_close = DOTween:Sequence()
    self.tw_close:AppendInterval(2)
    self.tw_close:AppendCallback(function()
        self:Close()
    end)
    self.tw_close:Play()
end

function DailyTaskLineGameView:StopCloseCounter()
    if self.tw_close then
        self.tw_close:Kill(false)
        self.tw_close = nil
    end
end

function DailyTaskLineGameView:PlayEffect()
    local ui_effect = self:CreateUIEffect(self.wrapper,  "effect/ui/ui_ligature.ab")
    ui_effect:SetLoop(true)
    ui_effect:Play()

    self:PlayStarAnim()
end

function DailyTaskLineGameView:PlayStarAnim()
    if #self.list_point <= 2 then
        return
    end

    local start_pos = self.list_point[1]:GetPosition()
    self.wrapper:SetPosition(start_pos.x, start_pos.y)

    local move_speed = 410
    self:StopStarAnim()

    self.tw_star = DOTween:Sequence()
    self.tw_star:AppendCallback(function()
        self.wrapper:SetVisible(true)
    end)
    for k, v in ipairs(self.list_line) do
        local length = v:GetWidth()
        local duration = length / move_speed
        local pos = v:GetEndPos()
        self.tw_star:Append(self.wrapper:TweenMove({pos.x, pos.y}, duration))
    end
    self.tw_star:AppendCallback(function()
        self.wrapper:SetVisible(false)
    end)
    self.tw_star:AppendInterval(1.2)
    self.tw_star:SetLoops(-1)
    self.tw_star:Play()
end

function DailyTaskLineGameView:StopStarAnim()
    if self.tw_star then
        self.tw_star:Kill(false)
        self.tw_star = nil
    end
end

function DailyTaskLineGameView:PlayBombAnim()
    self:StopBombAnim()
    self.tw_bomb = DOTween:Sequence()
    self.tw_bomb:AppendCallback(function()
        for k, v in ipairs(self.list_data) do
            v:PlayEffect()
        end
    end)
    self.tw_bomb:SetLoops(1)
    self.tw_bomb:OnComplete(function()
        self:StartCloseCounter()
    end)
    self.tw_bomb:Play()
end

function DailyTaskLineGameView:StopBombAnim()
    if self.tw_bomb then
        self.tw_bomb:Kill(false)
        self.tw_bomb = nil
    end
end

return DailyTaskLineGameView
