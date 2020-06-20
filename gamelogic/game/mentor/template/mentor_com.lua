local MentorCom = Class(game.UITemplate)

local TabIndex = {
    Study = 0,
    Task = 1,
    Gift = 2,
    Taixue = 3,
}
local mentor_task_num = config.mentor_base.mentor_task[2]

function MentorCom:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function MentorCom:OpenViewCallBack()
    self.ctrl_tab = self:GetRoot():AddControllerCallback("ctrl_tab", function(idx)
        self.tab_index = idx
    end)
    self.ctrl_member = self:GetRoot():AddControllerCallback("ctrl_member", function(idx)
        self:OnMemberClick(idx+1)
    end)

    self.list_member = self:CreateList("list_member", "game/mentor/template/member_item")
    self.list_member:SetRefreshItemFunc(function(item, idx)
        local item_info = self.member_list_data[idx]
        item:SetItemInfo(item_info and item_info.info, idx)
        item:SetSelVisible(true)
    end)

    self.txt_morality = self._layout_objs["txt_morality"]
    self.txt_title = self._layout_objs["txt_title"]
    self.txt_feeback = self._layout_objs["txt_feeback"]
    self.txt_time = self._layout_objs["txt_time"]
    self.txt_practice_times = self._layout_objs["txt_practice_times"]
    self.txt_begin_time = self._layout_objs["txt_begin_time"]

    self.btn_feedback = self._layout_objs["btn_feedback"]
    self.btn_feedback:AddClickCallBack(function()
        self.ctrl:OpenFeedbackTipsView()
    end)

    self:InitStudyGroup()
    self:InitTaskGroup()
    self:InitGiftGroup()
    self:InitTaixueGroup()

    self:UpdateMentorInfo()
    if self.member_list_data and #self.member_list_data > 0 then
        self.ctrl_member:SetSelectedIndexEx(0)
    end

    self:RegisterAllEvents()
end

function MentorCom:CloseViewCallBack()
    self.member_idx = nil
end

function MentorCom:RegisterAllEvents()
    local events = {
        {game.MentorEvent.UpdateMentorInfo, handler(self, self.UpdateMentorInfo)},
        {game.MentorEvent.UpdateMemberList, handler(self, self.UpdateMentorInfo)},
        {game.MentorEvent.UpdatePrentice, handler(self, self.UpdatePrentice)},
    }   
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MentorCom:OnMemberClick(idx)
    self.member_idx = idx
    local member_info = self.member_list_data[idx]
    if member_info then
        local role_id = member_info.info.role_id
        local prentice_info = self.ctrl:GetPrenticeInfo(role_id)
        self:UpdatePrenticeInfo(prentice_info)
    end
end

function MentorCom:InitStudyGroup()
    self.list_study = self:CreateList("list_study", "game/mentor/template/study_item")
    self.list_study:SetRefreshItemFunc(function(item, idx)
        local item_info = self.study_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)

    self.txt_score = self._layout_objs["txt_score"]
    self.txt_graduate_lv = self._layout_objs["txt_graduate_lv"]

    self.btn_check_reward = self._layout_objs["btn_check_reward"]
    self.btn_check_reward:AddClickCallBack(function()
        if self.prentice_info then
            self.ctrl:OpenGraduateView(self.prentice_info)
        end
    end)

    self.bar_course = self._layout_objs["bar_course"]
end

function MentorCom:InitTaskGroup()
    self.ctrl_task = self:GetRoot():GetController("ctrl_task")

    self.txt_task_num = self._layout_objs["txt_task_num"]

    self.btn_publish = self._layout_objs["btn_publish"]
    self.btn_publish:AddClickCallBack(function()
        if self.prentice_info then
            local role_id = self.prentice_info.role_id
            local task_id_list = {}
            self.list_publish_task:Foreach(function(item)
                if item:IsSelected() then
                    table.insert(task_id_list, {id = item:GetTaskId()})
                end
            end)
            self.ctrl:SendMentorSetTasks(role_id, task_id_list)
        end
    end)
    self.img_ylq = self._layout_objs["img_ylq"]

    self.publish_task_data = {}
    for k, v in pairs(config.mentor_task[game.TaskType.MentorTask]) do
        table.insert(self.publish_task_data, v)
    end
    table.sort(self.publish_task_data, function(m, n)
        return m.id < n.id
    end)
    self.list_publish_task = self:CreateList("list_publish_task", "game/mentor/template/publish_task_item")
    self.list_publish_task:SetRefreshItemFunc(function(item, idx)
        local item_info = self.publish_task_data[idx]
        item:SetItemInfo(item_info, idx)
        item:AddClickEvent(handler(self, self.OnTaskItemClick))
    end)
    self.list_publish_task:SetItemNum(#self.publish_task_data)

    self.list_mentor_task = self:CreateList("list_mentor_task", "game/mentor/template/mentor_task_item")
    self.list_mentor_task:SetRefreshItemFunc(function(item, idx)
        local item_info = self.mentor_task_data[idx]
        item_info.mark = self.prentice_info.mark
        item:SetItemInfo(item_info, idx)
    end)

    self.list_task_reward = self:CreateList("list_task_reward", "game/bag/item/goods_item")
    self.list_task_reward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.task_reward_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
        item:SetShowTipsEnable(true)
    end)

    self.btn_get_task = self._layout_objs["btn_get_task"]
    self.btn_get_task:AddClickCallBack(function()
        if self.prentice_info then
            local role_id = self.prentice_info.role_id
            self.ctrl:SendMentorTakeTaskAward(role_id)
        end
    end)
end

function MentorCom:GetPublishTaskNum()
    local publish_task_num = 0
    self.list_publish_task:Foreach(function(item)
        if item:IsSelected() then
            publish_task_num = publish_task_num + 1
        end
    end)
    return publish_task_num
end

function MentorCom:OnTaskItemClick(item)
    local is_selected = item:IsSelected()
    if is_selected then
        item:SetSelected(false)
    else
        if self:GetPublishTaskNum() < mentor_task_num then
            item:SetSelected(true)
        end
    end
    self:SetMentorTaskText()
end

function MentorCom:InitGiftGroup()
    self.list_gift = self:CreateList("list_gift", "game/mentor/template/gift_item")
    self.list_gift:SetRefreshItemFunc(function(item, idx)
        local item_info = self.gift_list_data[idx]
        item_info.mark = self.prentice_info.mark
        item:SetItemInfo(item_info, idx)
    end)
end

function MentorCom:InitTaixueGroup()
    self.txt_advance_name = self._layout_objs["txt_advance_name"]
    self.txt_advance_status = self._layout_objs["txt_advance_status"]
    
    self.list_advance_task = self:CreateList("list_advance_task", "game/mentor/template/advance_task_item")
    self.list_advance_task:SetRefreshItemFunc(function(item, idx)
        local item_info = self.advance_task_data[idx]
        item:SetItemInfo(item_info, idx)
    end)

    self.list_advance_reward = self:CreateList("list_advance_reward", "game/mentor/template/advance_reward_item")
    self.list_advance_reward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.advance_reward_data[idx]
        local data = {}
        data.name = string.format(config.words[6436], item_info.num)
        data.drop = item_info.mentor_award
        item:SetItemInfo(data)
    end)
end

function MentorCom:UpdateMemberList()
    self.member_list_data = self.ctrl:GetMemberList()
    local item_num = #self.member_list_data
    local max_num = config.mentor_base.tudi_num
    self.list_member:SetItemNum(max_num)
    self.ctrl_member:SetPageCount(max_num)

    self.txt_title:SetText(string.format(config.words[6401], item_num, max_num))
end

function MentorCom:SetMoralityValue()
    local mentor_info = self.ctrl:GetMentorInfo()
    local morality_cfg = self.ctrl:GetMentorLevelConfig()
    local next_cfg = config.mentor_lv[morality_cfg.mentor_lv+1]
    local max_morality = next_cfg and next_cfg.morality_value or morality_cfg.morality_value
    self.txt_morality:SetText(string.format(config.words[6427], morality_cfg.desc, mentor_info.morality, max_morality))
end

function MentorCom:UpdateMentorInfo()
    if not self.ctrl:IsMentor() then
        return
    end
    self:UpdateMemberList()
    self:SetMoralityValue()

    if self.member_idx then
        if not self.member_list_data[self.member_idx] then
            if self.member_idx ~= 1 then
                self.member_idx = 1
                self.ctrl_member:SetSelectedIndexEx(self.member_idx-1)
            else
                self:OnMemberClick(self.member_idx)
            end
        else
            self:OnMemberClick(self.member_idx)
        end
    end
end

function MentorCom:UpdatePrenticeInfo(info)
    if not info then
        return
    end
    self.prentice_info = info
    self.base_info = self.ctrl:GetBaseInfo(info.role_id)

    local comment = info.comment == 0 and config.words[6429] or config.mentor_comment_award[info.comment].desc
    self.txt_feeback:SetText(string.format(config.words[6428], comment))
    
    local time = os.date("%Y-%m-%d", info.begin_time)
    self.txt_begin_time:SetText(time)

    local daily_times = config.mentor_base.tudi_practice_num
    self.txt_practice_times:SetText(string.format("%d/%d", info.practice_num ,daily_times))

    if info.type == 0 then
        if self.tab_index == TabIndex.Taixue then
            self.ctrl_tab:SetSelectedIndexEx(TabIndex.Study)
        end
        self:UpdateStudyGroup()
        self:UpdateTaskGroup()
        self:UpdateGiftGroup()
    else
        if self.tab_index ~= TabIndex.Taixue then
            self.ctrl_tab:SetSelectedIndexEx(TabIndex.Taixue)
        end
        self:UpdateTaixueGroup()
    end
end

function MentorCom:UpdateStudyGroup()
    local info = self.prentice_info
    self.txt_score:SetText(info.mark)
    self.txt_graduate_lv:SetText(config.mentor_base.senior_lv)

    local max_mark = 0
    self.study_list_data = {}
    for k, v in pairs(info.learn_tasks) do
        max_mark = max_mark + config.mentor_task[game.TaskType.MentorStudy][v.id].mark
        table.insert(self.study_list_data, v)
    end
    table.sort(self.study_list_data, function(m, n)
        return m.id < n.id
    end)
    self.list_study:SetItemNum(#self.study_list_data)

    self.bar_course:SetProgressValue(info.mark / max_mark * 100)
    self.bar_course:GetChild("title"):SetText(string.format("%s/%s", info.mark, max_mark))
end

function MentorCom:UpdateTaskGroup()
    local info = self.prentice_info
    if #info.mentor_tasks == 0 then
        self:SetMentorTaskText()
        self.ctrl_task:SetSelectedIndexEx(0)
    else
        self.mentor_task_data = info.mentor_tasks
        self.list_mentor_task:SetItemNum(#self.mentor_task_data)

        local task_reward_cfg = self.ctrl:GetMentorTaskReward(game.RoleCtrl.instance:GetRoleLevel())
        local drop_id = task_reward_cfg.mentor_award
        self.task_reward_data = config.drop[drop_id].client_goods_list
        self.list_task_reward:SetItemNum(#self.task_reward_data)

        self.btn_get_task:SetEnable(self.ctrl:IsFinishMentorTask(info.role_id))
        self.ctrl_task:SetSelectedIndexEx(1)

        self.img_ylq:SetVisible(info.award_taken == 1)
        self.btn_get_task:SetVisible(info.award_taken == 0)
    end
end

function MentorCom:SetMentorTaskText()
    self.txt_task_num:SetText(string.format("(%d/%d)", self:GetPublishTaskNum(), mentor_task_num))
end

function MentorCom:UpdateGiftGroup()
    self.gift_list_data = game.ShopCtrl.instance:GetShopItems(game.ShopId.PrenticeGift)
    self.list_gift:SetItemNum(#self.gift_list_data)
end

function MentorCom:UpdateTaixueGroup()
    local info = self.prentice_info
    self.txt_advance_name:SetText(self.base_info.name)
    
    self.advance_reward_data = self.ctrl:GetTaixueTaskReward()
    self.list_advance_reward:SetItemNum(#self.advance_reward_data)

    self.advance_task_data = {}
    for k, v in pairs(info.taixue_tasks) do
        table.insert(self.advance_task_data, v)
    end
    table.sort(self.advance_task_data, function(m ,n)
        return m.id < n.id
    end)
    self.list_advance_task:SetItemNum(#self.advance_task_data)

    local finish_num = self.ctrl:GetAdvanceTaskFinishNum(info.taixue_tasks)
    self.txt_advance_status:SetText(string.format("（%d/%d）", finish_num, #self.advance_task_data))
end

function MentorCom:UpdatePrentice(role_id)
    local info = self.prentice_info
    if info and info.role_id == role_id then
        self:UpdatePrenticeInfo(info)
    end
end

return MentorCom