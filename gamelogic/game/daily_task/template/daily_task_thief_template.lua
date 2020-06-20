local DailyTaskThiefTemplate = Class(game.UITemplate)

function DailyTaskThiefTemplate:_init(view)
    self.parent = view
    self.ctrl = game.DailyTaskCtrl.instance   
end

function DailyTaskThiefTemplate:OpenViewCallBack()
    -- self:Init()
    -- self:InitRewardList()
    -- self:RegisterAllEvents()
    -- self.ctrl:SendDailyThiefInfo()
end

function DailyTaskThiefTemplate:CloseViewCallBack()
    
end

function DailyTaskThiefTemplate:Init()
    self._layout_objs["txt_drop"]:SetText(config.words[1934])

    self.txt_info = self._layout_objs["txt_info"]
    self.txt_times = self._layout_objs["txt_times"]
    self.txt_target = self._layout_objs["txt_target"]

    self.btn_task = self._layout_objs["btn_task"]
    self.btn_task:AddClickCallBack(function()
        if not self.thief_info then
            return
        end
        local main_role = game.Scene.instance:GetMainRole()
        local task_npc = config.daily_thief.task_npc
        local scene_id = task_npc[1]
        local ux,uy = game.LogicToUnitPos(task_npc[2], task_npc[3])
        main_role:GetOperateMgr():DoGoToScenePos(scene_id, ux, uy, function()
            game.DailyTaskCtrl.instance:SendDailyThiefGet()
        end,2)
        self:Close()
    end)

    self.btn_kill = self._layout_objs["btn_kill"]
    self.btn_kill:AddClickCallBack(handler(self, self.OnKillThief))

    self.btn_abort = self._layout_objs["btn_abort"]
    self.btn_abort:AddClickCallBack(function()
        self.ctrl:OpenTipsView(3)
    end)
    
    self.btn_reward = self._layout_objs["btn_reward"]
    self.btn_reward:AddClickCallBack(function()

    end)

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
end

function DailyTaskThiefTemplate:InitRewardList()
    self.list_reward = self:CreateList("list_reward", "game/bag/item/goods_item")
    self.list_reward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.reward_list_data[idx]
        item:SetShowTipsEnable(true)
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
    end)
end

function DailyTaskThiefTemplate:UpdateRewardList()
    if not self.thief_info then
        return
    end

    local daily_times = self.thief_info.daily_times
    local thief_cfg = self.ctrl:GetThiefConfig()

    local reward_list_data
    if daily_times < config.daily_thief.mul_reward_times then
        reward_list_data = thief_cfg.thief_mul_reward
    else
        reward_list_data = thief_cfg.thief_normal_reward
    end

    if self.thief_info.times < config.daily_thief.one_round_times and self.thief_info.state ~= 0 and self.thief_info.state ~= 3 then
        local drop_id = reward_list_data[self.thief_info.times + 1][2]
        self.reward_list_data = config.drop[drop_id].client_goods_list    
    else
        local drop_id = thief_cfg.thief_box_reward
        self.reward_list_data = config.drop[drop_id].client_goods_list
    end
    self.list_reward:SetItemNum(#self.reward_list_data or {})
end

function DailyTaskThiefTemplate:Active()
    
end

function DailyTaskThiefTemplate:Refresh()
    -- local select_index = (self.thief_info.state == 0 or self.thief_info.state == 3) and 0 or 1
    -- self.ctrl_state:SetSelectedIndexEx(select_index)

    -- local mul_reward_times = config.daily_thief.mul_reward_times
    -- local left_mul_reward_times = math.max(0, mul_reward_times - self.thief_info.daily_times)

    -- if select_index == 0 then
    --     self.txt_info:SetText(string.format(config.words[1941], left_mul_reward_times, mul_reward_times))
    -- elseif select_index == 1 then
    --     local npc_id = self.ctrl:GetThiefNpcId()
    --     if npc_id then
    --         local target_format = left_mul_reward_times > 0 and config.words[1937] or config.words[1945]
    --         self.txt_target:SetText(string.format(target_format, config.npc[npc_id].name))
    --     end
    --     self.txt_times:SetText(string.format(config.words[1936], self.thief_info.daily_times + 1, self.thief_info.times, config.daily_thief.one_round_times))
    -- end

    -- self:UpdateRewardList()
end

function DailyTaskThiefTemplate:OnKillThief()
    self.ctrl:HangThiefTask()
    self.parent:Close()
end

function DailyTaskThiefTemplate:RegisterAllEvents()
    local events = {
        [game.RoleEvent.LevelChange] = function()
            self:UpdateRewardList()
        end,
        [game.DailyTaskEvent.UpdateThiefInfo] = function(thief_info)
            self.thief_info = thief_info
            self:Refresh()
        end
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return DailyTaskThiefTemplate