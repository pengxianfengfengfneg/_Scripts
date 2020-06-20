local PrenticeCom = Class(game.UITemplate)

local TabIndex = {
    Study = 0,
    Task = 1,
    Gift = 2,
    Taixue = 3,
}

function PrenticeCom:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function PrenticeCom:OpenViewCallBack()
    self.ctrl_tab = self:GetRoot():AddControllerCallback("ctrl_tab", function(idx)
        self.tab_index = idx
    end)

    self.list_member = self:CreateList("list_member", "game/mentor/template/member_item")
    self.list_member:SetRefreshItemFunc(function(item, idx)
        local item_info = self.member_list_data[idx].info
        item:SetItemInfo(item_info, idx)
        item:SetSelVisible(true)
    end)

    self.mentor_item = self:GetTemplate("game/mentor/template/member_item", "mentor_item")
    self.mentor_item:SetSelVisible(false)

    self.txt_morality = self._layout_objs["txt_morality"]
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
    self:RegisterAllEvents()
end

function PrenticeCom:RegisterAllEvents()
    local events = {
        {game.MentorEvent.UpdateMentorInfo, handler(self, self.UpdateMentorInfo)},
        {game.MentorEvent.UpdateMemberList, handler(self, self.UpdateMentorInfo)},
        {game.MentorEvent.UpdatePrentice, handler(self, self.UpdatePrentice)},
        {game.ShopEvent.BuySuccess, handler(self, self.OnBuySuccess)},
    }   
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function PrenticeCom:InitStudyGroup()
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

function PrenticeCom:InitTaskGroup()
    self.ctrl_task = self:GetRoot():GetController("ctrl_task")

    self.txt_task_num = self._layout_objs["txt_task_num"]
    self.txt_task_info = self._layout_objs["txt_task_info"]

    self.btn_report = self._layout_objs["btn_report"]
    self.btn_report:AddClickCallBack(function()
        if self.prentice_info then
            local role_id = self.prentice_info.role_id
            self.ctrl:SendMentorTakeTaskAward(role_id)
        end
    end)
    self.img_ylq = self._layout_objs["img_ylq"]

    self.list_mentor_task = self:CreateList("list_mentor_task", "game/mentor/template/mentor_task_item")
    self.list_mentor_task:SetRefreshItemFunc(function(item, idx)
        local item_info = self.mentor_task_data[idx]
        item:SetItemInfo(item_info, idx)
        item:AddClickEvent(function()
            local task_cfg = config.mentor_task[game.TaskType.MentorTask][item_info.id]
            local get_way_cfg = config.goods_get_way[task_cfg.require]
            if get_way_cfg then
                get_way_cfg.click_func()
            end
        end)
    end)

    self.btn_urge = self._layout_objs["btn_urge"]
    self.btn_urge:AddClickCallBack(function()
        local role_id = self.ctrl:GetMentorID()
        local params = {
            id = role_id,
            content = config.words[6440],
        }
        game.ChatCtrl.instance:SendChatPrivate(params)

        local info = self.ctrl:GetBaseInfo(self.ctrl:GetMentorID())
        local chat_info = {
            id = info.role_id,
            name = info.name,
            lv = info.lv,
            career = info.career,
            svr_num = 1,
        }
        game.ChatCtrl.instance:OpenFriendChatView(chat_info)
    end)

    self.list_task_reward = self:CreateList("list_task_reward", "game/bag/item/goods_item")
    self.list_task_reward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.task_reward_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
        item:SetShowTipsEnable(true)
    end)
end

function PrenticeCom:InitGiftGroup()
    self.list_gift = self:CreateList("list_gift", "game/mentor/template/gift_item")
    self.list_gift:SetRefreshItemFunc(function(item, idx)
        local item_info = self.gift_list_data[idx]
        item_info.mark = self.prentice_info.mark
        item:SetItemInfo(item_info, idx)
    end)
end

function PrenticeCom:InitTaixueGroup()
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
        data.drop = item_info.tudi_award
        item:SetItemInfo(data)
    end)
end

function PrenticeCom:UpdateMemberList()
    local mentor_id = self.ctrl:GetMentorID()
    local fliter = function(member)
        return member.info.role_id ~= mentor_id and member.info.role_id ~= game.RoleCtrl.instance:GetRoleId()
    end
    self.member_list_data = self.ctrl:GetMemberList(fliter)
    local item_num = #self.member_list_data
    self.list_member:SetItemNum(item_num)
end

function PrenticeCom:UpdateMentorInfo()
    if not self.ctrl:HasMentorInfo() or self.ctrl:IsMentor() then
        return
    end
    local mentor_base = self.ctrl:GetBaseInfo(self.ctrl:GetMentorInfo().mentor_id)
    self.mentor_item:SetItemInfo(mentor_base, 1)
    self.txt_task_info:SetText(string.format(config.words[6443], mentor_base.name))
    self:UpdateMemberList()
    self:UpdatePrenticeInfo(self.ctrl:GetPrenticeInfo(game.RoleCtrl.instance:GetRoleId()))
end

function PrenticeCom:UpdatePrenticeInfo(info)
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
    self.txt_practice_times:SetText(string.format("%d/%d", info.practice_num, daily_times))

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

function PrenticeCom:UpdateStudyGroup()
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

function PrenticeCom:UpdateTaskGroup()
    local info = self.prentice_info
    if #info.mentor_tasks == 0 then
        self.ctrl_task:SetSelectedIndexEx(1)
    else
        self.mentor_task_data = info.mentor_tasks
        self.list_mentor_task:SetItemNum(#self.mentor_task_data)

        local task_reward_cfg = self.ctrl:GetMentorTaskReward(game.RoleCtrl.instance:GetRoleLevel())
        local drop_id = task_reward_cfg.tudi_award
        self.task_reward_data = config.drop[drop_id].client_goods_list
        self.list_task_reward:SetItemNum(#self.task_reward_data)

        self.btn_report:SetEnable(self.ctrl:IsFinishMentorTask(info.role_id))
        self.ctrl_task:SetSelectedIndexEx(0)

        self.img_ylq:SetVisible(info.award_taken == 1)
        self.btn_report:SetVisible(info.award_taken == 0)
    end
end

function PrenticeCom:UpdateGiftGroup()
    self.gift_list_data = game.ShopCtrl.instance:GetShopItems(game.ShopId.PrenticeGift)
    self.list_gift:SetItemNum(#self.gift_list_data)
end

function PrenticeCom:UpdateTaixueGroup()
    local info = self.prentice_info
    
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

function PrenticeCom:OnBuySuccess(data)
    if data.shop_id == game.ShopId.PrenticeGift and self.gift_list_data then
        self.list_gift:SetItemNum(#self.gift_list_data)
    end
end

function PrenticeCom:UpdatePrentice(role_id)
    local info = self.prentice_info
    if info and info.role_id == role_id then
        self:UpdatePrenticeInfo(info)
    end
end

return PrenticeCom