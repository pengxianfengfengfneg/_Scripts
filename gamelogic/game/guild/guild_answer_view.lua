local GuildAnswerView = Class(game.BaseView)

function GuildAnswerView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_answer_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function GuildAnswerView:_delete()

end

function GuildAnswerView:OpenViewCallBack()
    self:HideLayout()
    self:Init()
    self:InitBg()
    self:InitAnswerOptionList()
    self.ctrl:SendQuestionOpen()
    self.ctrl:SendQuestionInfo()
end

function GuildAnswerView:CloseViewCallBack()
    self.list_answer_option:DeleteMe()
    self.list_answer_option = nil
    self:DelAnswerTimer()
    self.ctrl:SendQuestionClose()
end

function GuildAnswerView:Init()
    self.max_quest_num = 20
    self.limit_time = 15
    self.prepare_time = 3

    self._layout_objs["label_answer_rank"]:SetText(config.words[2726])
    self.txt_my_rank = self._layout_objs["txt_my_rank"]
    self.txt_my_score = self._layout_objs["txt_my_score"]

    self.txt_quest_number = self._layout_objs["txt_quest_number"]
    self.txt_quest_content = self._layout_objs["txt_quest_content"]
    self.txt_answer_time = self._layout_objs["txt_answer_time"]
    self.list_answer_rank = self._layout_objs["list_answer_rank"]

    self._layout_objs["label_answer_end"]:SetText(config.words[2731])
    self.txt_summary = self._layout_objs["txt_summary"]
    self.txt_rank = self._layout_objs["txt_rank"]
    self.txt_score = self._layout_objs["txt_score"]
    self.txt_exp = self._layout_objs["txt_exp"]
    self.txt_money = self._layout_objs["txt_money"]

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    self.option_map = {}

    self:RegisterAllEvents()
end

function GuildAnswerView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2725])
end

function GuildAnswerView:UpdateAnswerRankList(rank_list_data)
    self.list_answer_rank:SetItemNum(#rank_list_data)
    for i=1, #rank_list_data do
        local item = self.list_answer_rank:GetChildAt(i-1)
        local member_info = self.ctrl:GetGuildMemberInfo(rank_list_data[i].role_id)
        local name = member_info and member_info.name or ""
        item:GetChild("txt_name"):SetText(string.format("%d.%s", rank_list_data[i].rank, name))
        item:GetChild("txt_score"):SetText(string.format(config.words[2751], rank_list_data[i].score))
    end
end

function GuildAnswerView:InitAnswerOptionList()
    self.list_answer_option = game.UIList.New(self._layout_objs.list_answer_option)
    self.list_answer_option:SetCreateItemFunc(function(obj)
        local item = require("game/guild/item/guild_answer_option_item").New()
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.list_answer_option:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.answer_option_list_data[idx])
        item:SetClickFunc(function()
            self:AnswerQuestion(self.answer_option_list_data[idx].index)
        end)
        self.option_map[idx] = item
    end)
    self.list_answer_option:SetVirtual(false)
end

function GuildAnswerView:UpdateAnswerOptionList(quest_bank)
    if not quest_bank then
        return
    end
    self.answer_option_list_data = {}
    for i = 1, 4 do
        local quest_index = self.quest_info.index
        local quest_conf_id = self.quest_info.conf_id
        local my_answer = self:GetMyAnswer(quest_index)
        local is_select = my_answer == i
        local option_type = 0
        if my_answer then
            option_type = i == quest_bank.answer and 1 or 2
        end
        table.insert(self.answer_option_list_data, { 
            index = i, 
            option = quest_bank["options"..i], 
            select = is_select,
            type = option_type,
            quest_index = self.quest_info.index,
        })
    end
    self.list_answer_option:SetItemNum(#self.answer_option_list_data)
end

function GuildAnswerView:UpdateQuestionInfo()
    self:ShowLayout()
       
    self.txt_my_rank:SetText(string.format(config.words[2727], self.quest_info.my_rank))
    self.txt_my_score:SetText(string.format(config.words[2728], self.quest_info.my_score))
    self.txt_quest_number:SetText(string.format(config.words[2729], self.quest_info.index, self.max_quest_num))
    self.txt_quest_content:SetText(config.question_bank[self.quest_info.conf_id].question)
  
    self:UpdateAnswerRankList(self.quest_info.ranks)
    self:UpdateAnswerOptionList(config.question_bank[self.quest_info.conf_id])
    self:DelAnswerTimer()

    if self.quest_info.state == 1 then
        self:CreateAnswerTimer()
        self.ctrl_state:SetSelectedIndexEx(0)
    elseif self.quest_info.state == 2 then
        self.ctrl_state:SetSelectedIndexEx(1)
        self.txt_summary:SetText(string.format(config.words[2732], self.max_quest_num, self.quest_info.bingo_num))
        self.txt_rank:SetText(string.format(config.words[2733], self.quest_info.my_rank))
        self.txt_score:SetText(string.format(config.words[2734], self.quest_info.my_score))
        self.txt_exp:SetText(string.format(config.words[2735], self:CaculateExp()))
        self.txt_money:SetText(string.format(config.words[2736], self:CaculateMoney()))
    end
end

function GuildAnswerView:UpdateOptionType()
    if not self.quest_info or table.nums(self.option_map) == 0 then
        return
    end 
    local right_answer = config.question_bank[self.quest_info.conf_id].answer
    for i = 1, 4 do
        self.option_map[i]:SetOptionType(i == right_answer and 1 or 2)
    end
    self.update_option_type = true
end

function GuildAnswerView:CreateAnswerTimer()
    local time = self.quest_info.begin_time + self.limit_time + self.prepare_time - global.Time:GetServerTime()
    time = math.max(0, time)
    self.txt_answer_time:SetText(string.format(config.words[2730], time >= self.prepare_time and time - self.prepare_time or time))
    if time > 0 then
        self.update_option_type = false
        self.answer_timer = global.TimerMgr:CreateTimer(1, function()        
            if time <= self.prepare_time and not self.update_option_type then
                self:UpdateOptionType()
            end

            time = time - 1
            self.txt_answer_time:SetText(string.format(config.words[2730], time >= self.prepare_time and time - self.prepare_time or time))
            if time <= 0 then
                self.answer_timer = nil
                return true
            end
        end)
    end
end

function GuildAnswerView:DelAnswerTimer()
    if self.answer_timer then
        global.TimerMgr:DelTimer(self.answer_timer)
        self.answer_timer = nil
    end
end

function GuildAnswerView:AnswerQuestion(answer)
    local quest_index = self.quest_info.index
    local my_answer = self:GetMyAnswer(quest_index)
    if not my_answer then
        local right_answer = config.question_bank[self.quest_info.conf_id].answer
        self.option_map[answer]:SetSelected(true)

        self:UpdateOptionType()

        self.quest_info.answer_list[quest_index] = {index = quest_index, answer = answer}
        self.ctrl:SendQuestionAnswer(answer)
    end
end

function GuildAnswerView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateQuestionInfo] = function(quest_info)
            quest_info.answer_list = game.Utils.SortByField(quest_info.answer_list, 'index')
            quest_info.ranks = game.Utils.SortByField(quest_info.ranks, 'rank')
            self.quest_info = quest_info
            self:UpdateQuestionInfo()
        end,
        [game.GuildEvent.AnswerQuestion] = function(answer)
            
        end
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function GuildAnswerView:CaculateExp()
    local exp = 0
    for k, v in pairs(self.quest_info.answer_list) do
        if v.answer ~= 0 then
            local index = config.question_bank[v.conf_id].answer == v.answer and 2 or 1
            local rw_cfg = config.level[v.lv].answer_reward
            exp = exp + rw_cfg[index][1][2]
        end
    end
    return exp
end

function GuildAnswerView:CaculateMoney()
    local money = 0
    for k, v in pairs(self.quest_info.answer_list) do
        if v.answer ~= 0 then
            local index = config.question_bank[v.conf_id].answer == v.answer and 2 or 1
            local rw_cfg = config.level[v.lv].answer_reward
            money = money + rw_cfg[index][2][2]
        end
    end
    return money
end

function GuildAnswerView:GetMyAnswer(index)
    local answer_list = self.quest_info.answer_list
    if answer_list[index] then
        return answer_list[index].answer
    end
end

function GuildAnswerView:GetAnswerNum()
    local num = 0
    for k, v in pairs(self.quest_info.answer_list or {}) do
        if v.answer ~= 0 then
            num = num + 1
        end
    end
    return num
end

return GuildAnswerView
