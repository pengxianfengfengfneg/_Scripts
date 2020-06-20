local DailyTaskPuzzleGameView = Class(game.BaseView)

local table_insert = table.insert
local table_remove = table.remove
local vec2 = cc.vec2
local pGetDistance = cc.pGetDistance
local pDistanceSQ = cc.pDistanceSQ
local pSet = cc.pSet

local PageIndex = {
    Game = 0,
    End = 1,
}

function DailyTaskPuzzleGameView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "daily_task_puzzle_game_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function DailyTaskPuzzleGameView:OpenViewCallBack(task_id, game_id)
    self:Init(task_id, game_id)
    self:InitPuzzles()
    self:StartGameCounter()
    self:PlayGuide()
end

function DailyTaskPuzzleGameView:CloseViewCallBack()
    self:StopPuzzleSequence()
    self:StopCloseCounter()
    self:StopGameCounter()
    self:ResetGame()
end

function DailyTaskPuzzleGameView:Init(task_id, game_id)
    self.task_id = task_id
    self.game_id = game_id
    self.puzzle_cfg = config.puzzle_game[game_id]

    self.img_bg = self._layout_objs["img_bg"]
    self.txt_time = self._layout_objs["txt_time"]

    self.pz1 = self._layout_objs["pz1"]
    self.pz2 = self._layout_objs["pz2"]
    self.pz3 = self._layout_objs["pz3"]

    self.puzzle_list = {}
    self.seq_map = {}
    self.count = 0

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self.ctrl_page:SetSelectedIndexEx(PageIndex.Game)

    self.is_paly_end = false
end

function DailyTaskPuzzleGameView:InitPuzzles()
    local bundle_name = "ui_daily_task"
    local puzzles = self.puzzle_cfg.puzzles

    self.img_bg:SetSprite(bundle_name, self.puzzle_cfg.bg, true)

    for i=1, 3 do
        local puzzle_com = self["pz"..i]
        local x, y = puzzle_com:GetPosition()

        table.insert(self.puzzle_list, {
            obj = puzzle_com,
            img = puzzle_com:GetChild("icon"),
            x = x, 
            y = y,
        })
    end

    for i=1, 3 do
        local cfg = puzzles[i]
        local img_puzzle = self.puzzle_list[i].img
        local puzzle_com = self.puzzle_list[i].obj
        if cfg[1] then
            img_puzzle:SetSprite(bundle_name, cfg[1], true)
            img_puzzle:SetPivot(0.5, 0.5, true)
            img_puzzle:CenterX()
            img_puzzle:CenterY()
        end
        puzzle_com:SetVisible(cfg[1]~=nil)

        puzzle_com:SetTouchEnable(true)
        puzzle_com:SetTouchBeginCallBack(function(x, y)
            local x, y = self:GetRoot():ToLocalPos(x, y)
            self:SetPosition(puzzle_com, x, y)
            self:StopGuide()
        end)
        puzzle_com:SetTouchMoveCallBack(function(x, y)
            local x, y = self:GetRoot():ToLocalPos(x, y)
            self:SetPosition(puzzle_com, x, y)
        end)
        puzzle_com:SetTouchEndCallBack(function(x, y)
            if self:CheckPuzzle(i) then
                local pos = self:GetPuzzleCorrectPos(i)
                self:SetPosition(puzzle_com, pos.x, pos.y)
                puzzle_com:SetTouchEnable(false)
                self.count = self.count + 1

                if self:IsPlaySuccess() then
                    self:FinishTask()
                end
            else
                self:ResetPuzzle(i)
            end
        end)
    end
end

function DailyTaskPuzzleGameView:CheckPuzzle(i)
    local puzzles = self.puzzle_cfg.puzzles
    local cfg = puzzles[i]

    local puzzle_com = self.puzzle_list[i].obj
    local x, y = puzzle_com:GetPosition()

    local check_pos = vec2(x, y)
    local target_pos = vec2(cfg[2], cfg[3])
    local dist = 105

    return pDistanceSQ(check_pos, target_pos) <= dist * dist
end

function DailyTaskPuzzleGameView:GetPuzzleCorrectPos(i)
    local cfg = self.puzzle_cfg.puzzles[i]
    if cfg then
        return vec2(cfg[2], cfg[3])
    end
end

function DailyTaskPuzzleGameView:IsPlaySuccess()
    return self.count == #self.puzzle_cfg.puzzles
end

function DailyTaskPuzzleGameView:FinishTask()
    game.TaskCtrl.instance:SendTaskGetReward(self.task_id)
    self.ctrl_page:SetSelectedIndexEx(PageIndex.End)
    self:GetRoot():PlayTransition("trans_end")
    self:StartCloseCounter()
    self.is_paly_end = true
end

function DailyTaskPuzzleGameView:ResetPuzzle(i)
    local move_speed = 1350
    local puzzle_cfg = self.puzzle_list[i]
    local puzzle_com = puzzle_cfg.obj

    self:StopPuzzleSequence(i)

    self.seq_map[i] = DOTween:Sequence()
    self.seq_map[i]:AppendCallback(function()
        puzzle_com:SetTouchEnable(false)
    end)

    local x, y = puzzle_com:GetPosition()
    local dist = pGetDistance(vec2(x, y), vec2(puzzle_cfg.x, puzzle_cfg.y))
    local duration = dist / move_speed

    self.seq_map[i]:Append(puzzle_com:TweenMove({puzzle_cfg.x, puzzle_cfg.y}, duration))
    self.seq_map[i]:AppendCallback(function()
        puzzle_com:SetTouchEnable(true)
    end)

    self.seq_map[i]:Play()
end

function DailyTaskPuzzleGameView:ResetGame()
    for k, v in ipairs(self.puzzle_list) do
        v.obj:SetPosition(v.x, v.y)
    end
    self.is_paly_end = false
end

function DailyTaskPuzzleGameView:StopPuzzleSequence(i)
    if i then
        if self.seq_map[i] then
            self.seq_map[i]:Kill(false)
            self.seq_map[i] = nil
        end
    else
        for k, v in pairs(self.seq_map) do
            self.seq_map[k]:Kill(false)
            self.seq_map[k] = nil
        end
    end
end

function DailyTaskPuzzleGameView:StartCloseCounter()
    self:StopCloseCounter()
    self.tw_close = DOTween:Sequence()
    self.tw_close:AppendInterval(5)
    self.tw_close:AppendCallback(function()
        self:Close()
    end)
    self.tw_close:Play()
end

function DailyTaskPuzzleGameView:StopCloseCounter()
    if self.tw_close then
        self.tw_close:Kill(false)
        self.tw_close = nil
    end
end

function DailyTaskPuzzleGameView:SetPosition(com, x, y)
    com:SetPosition(x, y)
    com:GetChild("icon"):InvalidateBatchingState()
end

function DailyTaskPuzzleGameView:IsPlayEnd()
    return self.is_paly_end
end

function DailyTaskPuzzleGameView:PlayGuide()
    self.is_play_guide = true
    local play_action = self:GetRoot():GetTransition("trans_guide")
    play_action:Play(-1, 0, nil)
    self._layout_objs["group_guide"]:SetVisible(true)
end

function DailyTaskPuzzleGameView:StopGuide()
    if self.is_play_guide then
        self.is_paly_guide = false
        self:StopTransition("trans_guide")
        self._layout_objs["group_guide"]:SetVisible(false)
    end
end

function DailyTaskPuzzleGameView:StartGameCounter()
    self:StopGameCounter()
    local end_time = global.Time:GetServerTime() + config.sys_config["puzzle_game_time"].value
    self.tw_game = DOTween:Sequence()
    self.tw_game:AppendCallback(function()
        local time = end_time - global.Time:GetServerTime()
        if time <= 0 then
            if not self:IsPlayEnd() then
                local main_role = game.Scene.instance:GetMainRole()
                if main_role then
                    main_role:GetOperateMgr():ClearOperate()
                end
                game.GameMsgCtrl.instance:PushMsg(config.words[6204])
            end
            self:StopGameCounter()
            self:Close()
        end
        self.txt_time:SetText(string.format(config.words[6203], time))
    end)
    self.tw_game:AppendInterval(1)
    self.tw_game:SetLoops(-1)
    self.tw_game:Play()
end

function DailyTaskPuzzleGameView:StopGameCounter()
    if self.tw_game then
        self.tw_game:Kill(false)
        self.tw_game = nil
    end
end

return DailyTaskPuzzleGameView
