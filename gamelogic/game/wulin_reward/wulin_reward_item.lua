local WulinRewardItem = Class(game.UITemplate)

function WulinRewardItem:_init(ctrl)
    self.ctrl = ctrl
    self.data = ctrl:GetData()
end

function WulinRewardItem:OpenViewCallBack()
    self._layout_objs["btn_jb"]:AddClickCallBack(function()
        if not game.TaskCtrl.instance:GetTaskInfoById(self.task_id) then
            game.MainUICtrl.instance:OpenAutoMoneyExchangeView(self.coin_type, self.coin_num, function()
                self.ctrl:SendPrizeAccept(self.grade)
            end)
        else
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoHangTask(self.task_id)
            end
            self.ctrl:CloseView()
        end
    end)

    self:BindEvent(game.TaskEvent.OnUpdateTaskInfo, function()
        self:RefreshTaskState()
    end)
end

function WulinRewardItem:CloseViewCallBack()

end

function WulinRewardItem:Refresh(grade, task_id)
    self.grade = grade
    self.task_id = task_id
    self:GetRoot():GetController("c1"):SetSelectedIndexEx(grade - 1)

    local sel_grade = self.data:GetGrade()
    self._layout_objs["mark_img"]:SetVisible(grade == sel_grade)
    self._layout_objs["star_list"]:SetItemNum(grade)

    local lv = game.Scene.instance:GetMainRoleLevel()
    local prize_cfg = config.prize_task_desc[task_id]
    if prize_cfg then
        self._layout_objs["txt"]:SetText(prize_cfg.name)
        self._layout_objs["icon"]:SetSprite("ui_wulin_reward", prize_cfg.icon, true)

        local pioneer_lv = game.MainUICtrl.instance:GetPioneerLv()
        local ratio = config_help.ConfigHelpLevel.GetPioneerLvRatio(lv, pioneer_lv)
        local exp = config.level[lv].prize_reward[grade][2]
        self._layout_objs["reward_txt"]:SetText(string.format(config.words[5753], exp, ratio + 1))
    end

    self:RefreshTaskState()
end

function WulinRewardItem:RefreshTaskState()

    if game.TaskCtrl.instance:GetTaskInfoById(self.task_id) ~= nil then
        self._layout_objs["cost_txt"]:SetText(config.words[5754])
    else
        local cfg
        local cfg_lv
        local lv = game.Scene.instance:GetMainRoleLevel()
        for k,v in pairs(config.prize_task) do
            if lv < k and (not cfg_lv or cfg_lv > k) then
                cfg = v
                cfg_lv = k
            end
        end

        local cost = cfg[self.grade].costs
        self.coin_num = 0
        if #cost == 0 then
            self._layout_objs["cost_txt"]:SetText(config.words[5750])
        else
            self.coin_num = cost[2]
            self.coin_type = cost[1]
            self._layout_objs["cost_txt"]:SetText(string.format(config.words[5751], game.Utils.NumberFormat(self.coin_num), config.money_type[self.coin_type].icon))
        end
    end
end

return WulinRewardItem
