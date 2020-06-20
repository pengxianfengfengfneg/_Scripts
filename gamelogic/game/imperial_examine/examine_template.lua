local ExamineTemplate = Class(game.UITemplate)

local examine_cfg = config.examine_info

function ExamineTemplate:_init()
    self.ctrl = game.DailyTaskCtrl.instance   
end

function ExamineTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
    self:StartTimeCounter()
    self.ctrl:SendExamineInfo()
end

function ExamineTemplate:CloseViewCallBack()
    self.cur_quest_id = nil
    self.click_option = nil

    self:StopTimeCounter()
    self:StopNextCounter()
    self:StopRewardAnim()
end

function ExamineTemplate:RegisterAllEvents()
    local events = {
        [game.DailyTaskEvent.UpdateExamineInfo] = function(data)
            self.examine_info = data
            self:Refresh(data)
        end,
        [game.DailyTaskEvent.OnExamineAnswer] = function(data)
            self.examine_info = data
            self:UpdateAnswerInfo(data)
            self:UpdateRewardInfo(data.acc_get)
            self:NextQuestion(data.id)
            self:SetTipsText()
        end,
        [game.DailyTaskEvent.UpdateExamineHelpState] = function()
            self:SetHelpText()
        end,
        [game.DailyTaskEvent.UpdateExamineTipsText] = function()
            self:SetTipsText()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function ExamineTemplate:Init()
    self.btn_start = self._layout_objs["btn_start"]
    self.btn_start:SetText(config.words[5127])
    self.btn_start:AddClickCallBack(function()
        self:SetIndexCtrl(2)
    end)

    self.btn_help = self._layout_objs["btn_help"]
    self.btn_help:AddClickCallBack(handler(self, self.OnHelpClick))

    self.btn_get = self._layout_objs["btn_get"]
    self.btn_get:AddClickCallBack(function()
        self.ctrl:SendExamineReward()
    end)
    self.img_get = self.btn_get:GetChild("icon")

    self.txt_quest_info = self._layout_objs["txt_quest_info"]
    self.txt_question = self._layout_objs["txt_question"]

    self.txt_accuracy = self._layout_objs["txt_accuracy"]
    self.txt_left_time = self._layout_objs["txt_left_time"]

    self.txt_tips = self._layout_objs["txt_tips"]

    self.txt_money1 = self._layout_objs["txt_money1"]
    self.txt_money2 = self._layout_objs["txt_money2"]

    self.img_money1 = self._layout_objs["img_money1"]
    self.img_money2 = self._layout_objs["img_money2"]
    self.img_reward = self._layout_objs["n24"]

    self.txt_plus1 = self._layout_objs["txt_plus1"]
    self.txt_plus1:SetVisible(false)

    self.txt_plus2 = self._layout_objs["txt_plus2"]
    self.txt_plus2:SetVisible(false)

    self._layout_objs["txt_gift"]:SetText(config.words[5131])
    self._layout_objs["txt_gift_info"]:SetText(string.format(config.words[5132], examine_cfg.question_num))

    self._layout_objs["txt_accuracy_label"]:SetText(config.words[5134])
    self._layout_objs["txt_left_time_label"]:SetText(config.words[5135])

    for i=1, 4 do
        local option = "option"..i
        self[option] = self:GetTemplate("game/guild/item/guild_answer_option_item", option)
    end

    self.ctrl_reward = self:GetRoot():GetController("ctrl_reward")
    self.ctrl_index = self:GetRoot():GetController("ctrl_index")
    self.ctrl_task = self:GetRoot():GetController("ctrl_task")

    self.ctrl_task:SetSelectedIndexEx(0)
    self:SetIndexCtrl(3)

    self.ctrl:TryResetExamineHelpState()

    self.tween_list = {}
end


function ExamineTemplate:OnHelpClick()
    if not game.GuildCtrl.instance:IsGuildMember() then
        game.GameMsgCtrl.instance:PushMsgCode(1404)
        return
    elseif self.click_option then
        return
    end

    if self:GetExamineHelpState() == 1 then
        game.ChatCtrl.instance:OpenView(game.ChatChannel.Guild)
    else
        if self.examine_info.help_times < examine_cfg.help_times then
            local help_chat_id = config.examine_info.help_chat_id
            local href_params = {
                role_id = game.Scene.instance:GetMainRoleID(),
                name = game.Scene.instance:GetMainRoleName(),
                answer_num = self.examine_info.answer_num,
                quest_id = self.cur_quest_id,
                guild_id = game.GuildCtrl.instance:GetGuildId(),
                time = global.Time:GetServerTime(),
            }
            local params = {
                channel = game.ChatChannel.Guild,
                content = "",
                extra = help_chat_id .. "|" ..serialize(href_params),
            }
            game.ChatCtrl.instance:SendChatPublic(params)
        else
            game.GameMsgCtrl.instance:PushMsgCode(6303)
        end
    end
end

function ExamineTemplate:StartTimeCounter()
    local end_time = game.Utils.NowDaytimeStart(global.Time:GetServerTime()) + 86400
    self:StopTimeCounter()
    self.time_tween = DOTween:Sequence()
    self.time_tween:AppendCallback(function()
        local time = end_time - global.Time:GetServerTime()
        self.txt_left_time:SetText(game.Utils.SecToTime2(time))
        if time <= 0 then
            self.txt_left_time:SetText("00:00")
            self:StartTimeCounter()
        end
    end)
    self.time_tween:AppendInterval(1)
    self.time_tween:SetLoops(-1)
    self.time_tween:Play()
end

function ExamineTemplate:StopTimeCounter()
    if self.time_tween then
        self.time_tween:Kill(false)
        self.time_tween = nil
    end
end

function ExamineTemplate:UpdateAnswerInfo(examine_info)
    if examine_info.right_num and examine_info.answer_num then
        self.txt_accuracy:SetText(string.format("%d/%d", examine_info.right_num, examine_info.answer_num))
    end
end

function ExamineTemplate:Refresh(examine_info)
    local max_num = examine_cfg.question_num
    local answer_state = self.ctrl:GetExamineAnswerState()

    if examine_info.answer_num == max_num then
        self:SetIndexCtrl(1)
    else
        self:SetIndexCtrl(2)
    end
    
    self.ctrl_reward:SetSelectedIndex(examine_info.is_get)

    if examine_info.is_get == 1 then
        self:StopRewardAnim()
    end

    self:UpdateAnswerInfo(examine_info)
    self:RefreshQuestion(examine_info.id)
    self:UpdateRewardInfo(examine_info.acc_get)
    self:SetTipsText()

    self.click_option = nil
end

function ExamineTemplate:RefreshQuestion(id)
    local info = self.examine_info
    local is_answer_all = info.answer_num >= examine_cfg.question_num
    self.btn_get:SetVisible(is_answer_all)
    self.img_reward:SetGray(not is_answer_all or info.is_get == 1)

    if self.examine_info and self.examine_info.answer_num == examine_cfg.question_num then
        self:SetIndexCtrl(1)
    elseif id and id ~= self.cur_quest_id then
        local quest_cfg = config.examine_bank[id]
        self.txt_question:SetText(quest_cfg.question)
        for i=1, 4 do
            local item_info = {
                index = i,
                option = quest_cfg["options"..i],
                option_format = "%s %s",
                type = 0,
            }
            local option = self["option"..i]
            option:SetItemInfo(item_info)
            option:SetClickFunc(function()
                self:OnOptionClick(quest_cfg, option)
            end)
        end
        self.cur_quest_id = id
        self.click_option = nil
        self:SetHelpText()

        local max_num = examine_cfg.question_num
        self.txt_quest_info:SetText(string.format(config.words[5129], math.min( self.examine_info.answer_num + 1, max_num), max_num))
    end
end

function ExamineTemplate:OnOptionClick(quest_cfg, option)
    if not self.click_option then
        local option_index = option:GetOptionIndex()
        local is_right = option_index == quest_cfg.answer
        option:SetOptionType(is_right and 1 or 2)
        option:SetSelected(true)

        if option_index ~= quest_cfg.answer then
            self["option"..quest_cfg.answer]:SetOptionType(1)
        end

        local index = option:GetOptionIndex()
        self.ctrl:SendExamineAnswer(index)

        self:SetPlusText(is_right)
        
        self.click_option = option
    end
end

function ExamineTemplate:NextQuestion(id)
    self:StopNextCounter()
    local next_time = global.Time:GetServerTime() + 2
    self.next_tween = DOTween:Sequence()
    self.next_tween:AppendCallback(function()
        local time = next_time - global.Time:GetServerTime()
        if time <= 0 then
            self:RefreshQuestion(id)
            self:StopNextCounter()
        end
    end)
    self.next_tween:AppendInterval(1)
    self.next_tween:SetLoops(-1)
    self.next_tween:Play()
end

function ExamineTemplate:StopNextCounter()
    if self.next_tween then
        self.next_tween:Kill(false)
        self.next_tween = nil
    end
end

function ExamineTemplate:UpdateRewardInfo(acc_get)
    self.reward_list = self.reward_list or self:GetAnswerRewardType()
    for k, v in ipairs(acc_get or {}) do
        self.reward_list[v.type] = v.num
    end

    local count = 1
    for k, v in pairs(self.reward_list or {}) do
        self["img_money"..count]:SetSprite("ui_common", config.money_type[k].icon, true)
        self["txt_money"..count]:SetText(v)
        count = count + 1
        if count > 2 then
            break
        end
    end
end

function ExamineTemplate:GetAnswerRewardType()
    local sort_list = game.Utils.SortByKey(config.examine_reward)
    local reward = sort_list[1].right_answer
    local reward_list = {}

    for k, v in ipairs(reward or {}) do
        reward_list[v[1]] = 0
    end
    return reward_list
end

function ExamineTemplate:SetIndexCtrl(index)
    if not self.cur_index or self.cur_index ~= index then
        self.ctrl_index:SetSelectedIndex(index)
        self.cur_index = index

        if self:CanGetReward() then
            self:PlayRewardAnim()
        else
            self:StopRewardAnim()
        end

        if index == 2 then
            self.ctrl:SendExamineBegin()
        end
        self.ctrl:SetExamineAnswerState(index ~= 2 and 0 or 1)
    end
end

function ExamineTemplate:SetHelpText()
    local str
    local help_state = self:GetExamineHelpState()
    if help_state == 1 then
        str = config.words[5136]
    else
        local help_times = self.examine_info.help_times or 0
        str = string.format(config.words[5130], help_times, examine_cfg.help_times)
    end
    self.btn_help:SetText(str)
end

function ExamineTemplate:SetTipsText()
    local data = {
        role_id = game.Scene.instance:GetMainRoleID(),
        quest_id = self.examine_info.id,
        time = global.Time:GetServerTime(),
    }
    local help_data = self.ctrl:GetExamineHelpData(data)
    if help_data then
        local quest_cfg = config.examine_bank[help_data.quest_id]
        self.txt_tips:SetText(string.format(config.words[5161], help_data.answer_name, quest_cfg["options"..quest_cfg.answer]))
        self.txt_tips:SetVisible(true)
    else
        self.txt_tips:SetVisible(false)
    end
end

function ExamineTemplate:GetExamineHelpState()
    if self.examine_info then
        local data = {
            answer_num = self.examine_info.answer_num,
            quest_id = self.examine_info.id,
        }
        return self.ctrl:GetExamineHelpState(data)
    end
end

function ExamineTemplate:SetPlusText(is_right)
    local rw_cfg = self.ctrl:GetExamineRewardConfig()
    local data = is_right and rw_cfg.right_answer or rw_cfg.wrong_answer

    self.txt_plus1:SetText("+" .. data[1][2])
    self.txt_plus2:SetText("+" .. data[2][2])

    self:GetRoot():PlayTransition("trans_fade")
end

function ExamineTemplate:PlayRewardAnim()
    self:StopRewardAnim()

    local tween_scale_large = self.btn_get:TweenScale({ 1.25, 1.25 }, 1)
    local tween_scale_small = self.btn_get:TweenScale({ 1, 1 }, 1)

	local tween_seq = DOTween:Sequence()
	tween_seq:Append(tween_scale_large)
    tween_seq:Append(tween_scale_small)

    tween_seq:SetLoops(-1)
    tween_seq:Play()

    table.insert(self.tween_list, tween_seq)

    self:PlayEffect()
end

function ExamineTemplate:StopRewardAnim()
    for k, v in ipairs(self.tween_list or game.EmptyTable) do
        v:Kill(false)
        self.tween_list[k] = nil
    end

    self.btn_get.scaleX = 1
    self.btn_get.scaleY = 1

    self:ClearUIEffect()
end

function ExamineTemplate:PlayEffect()
    self:ClearUIEffect()

    local ui_effect = self:CreateUIEffect(self._layout_objs.effect,  "effect/ui/ui_keju.ab")
    ui_effect:SetLoop(true)
    ui_effect:Play()
end

function ExamineTemplate:CanGetReward()
    local info = self.examine_info
    return info and (info.answer_num==examine_cfg.question_num) and (info.is_get==0)
end

return ExamineTemplate