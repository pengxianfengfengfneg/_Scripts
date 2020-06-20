local ExamineTaskTemplate = Class(game.UITemplate)

local examine_cfg = config.examine_info
local examine_bank_cfg = config.examine_new_bank

function ExamineTaskTemplate:_init(parent)
    self.ctrl = game.DailyTaskCtrl.instance
    self.parent = parent
end

function ExamineTaskTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
    self:Refresh(true)
    self.init_flag = true
end

function ExamineTaskTemplate:CloseViewCallBack()
    self.cur_quest_id = nil
    self.click_option = nil

    self:StopNextCounter()
    self.init_flag = false
end

function ExamineTaskTemplate:RegisterAllEvents()
    local events = {
        [game.DailyTaskEvent.OnExamineGuide] = function(num)
            self:UpdateAnswerInfo()
            self:UpdateRewardInfo()
            self:NextQuestion(num+1)
            self:SetTipsText()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function ExamineTaskTemplate:Init()
    self.btn_start = self._layout_objs["btn_start"]
    self.btn_start:SetText(config.words[5127])
    self.btn_start:AddClickCallBack(function()
        self:Refresh(true)
    end)

    self.btn_help = self._layout_objs["btn_help"]
    self.btn_help:AddClickCallBack(handler(self, self.OnHelpClick))

    self.btn_get = self._layout_objs["btn_get"]
    self.btn_get:AddClickCallBack(function()
        game.GameMsgCtrl.instance:PushMsg(config.words[5172])
    end)

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
    self._layout_objs["txt_gift_info"]:SetText(config.words[5172])

    self._layout_objs["txt_accuracy_label"]:SetText(config.words[5134])
    self._layout_objs["txt_left_time_label"]:SetText(config.words[5135])

    for i=1, 4 do
        local option = "option"..i
        self[option] = self:GetTemplate("game/guild/item/guild_answer_option_item", option)
    end

    self.ctrl_reward = self:GetRoot():GetController("ctrl_reward")
    self.ctrl_index = self:GetRoot():GetController("ctrl_index")
    self.ctrl_task = self:GetRoot():GetController("ctrl_task")

    self.ctrl_task:SetSelectedIndexEx(1)
    self.ctrl_reward:SetSelectedIndexEx(0)
end

function ExamineTaskTemplate:OnHelpClick()
    game.GameMsgCtrl.instance:PushMsg(config.words[5171])
end

function ExamineTaskTemplate:UpdateAnswerInfo()
    local right_num = game.DailyTaskCtrl.instance:GetExamineNewTaskRight()
    local answer_num = game.DailyTaskCtrl.instance:GetExamineNewTaskNum()
    self.txt_accuracy:SetText(string.format("%d/%d", right_num, answer_num))
end

function ExamineTaskTemplate:Refresh(start)
    local answer_num = game.DailyTaskCtrl.instance:GetExamineNewTaskNum()
    local max_num = #examine_bank_cfg

    if answer_num > 0 or start then
        self:SetIndexCtrl(2)
    else
        self:SetIndexCtrl(0)
    end

    self.ctrl_reward:SetSelectedIndexEx(0)

    self:UpdateAnswerInfo()
    self:RefreshQuestion(answer_num + 1)
    self:UpdateRewardInfo()
    self:SetTipsText()

    self.click_option = nil
end

function ExamineTaskTemplate:RefreshQuestion(id)
    local answer_num = game.DailyTaskCtrl.instance:GetExamineNewTaskNum()
    local max_num = #examine_bank_cfg

    local is_answer_all = answer_num >= max_num
    self.btn_get:SetVisible(is_answer_all)
    self.img_reward:SetGray(not is_answer_all)

    if answer_num >= max_num or id > max_num then
        if self.init_flag then
            self.parent:Close()
            return
        else
            return
        end
    end
    if id and id ~= self.cur_quest_id then
        local quest_cfg = config.examine_new_bank[id]
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

        self.txt_quest_info:SetText(string.format(config.words[5129], math.min(answer_num + 1, max_num), max_num))
    end
end

function ExamineTaskTemplate:OnOptionClick(quest_cfg, option)
    if not self.click_option then
        local option_index = option:GetOptionIndex()
        local is_right = option_index == quest_cfg.answer
        option:SetOptionType(is_right and 1 or 2)
        option:SetSelected(true)

        if option_index ~= quest_cfg.answer then
            self["option"..quest_cfg.answer]:SetOptionType(1)
        end

        local index = option:GetOptionIndex()
        game.DailyTaskCtrl.instance:SendExamineGuide()

        if is_right then
            local right = game.DailyTaskCtrl.instance:GetExamineNewTaskRight()
            game.DailyTaskCtrl.instance:SetExamineNewTaskRight(right+1)
        end

        self:SetPlusText(is_right)
        
        self.click_option = option
    end
end

function ExamineTaskTemplate:NextQuestion(id)
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

function ExamineTaskTemplate:StopNextCounter()
    if self.next_tween then
        self.next_tween:Kill(false)
        self.next_tween = nil
    end
end

function ExamineTaskTemplate:UpdateRewardInfo()
    local drop_id = config.sys_config.examine_guide_reward.value
    local reward_list = config.drop[drop_id].client_goods_list
    local answer_num = game.DailyTaskCtrl.instance:GetExamineNewTaskNum()
    
    for i=1, 2 do
        local reward = reward_list[i]
        local money_type = game.Utils.GetMoneyTypeById(reward[1])
        self["img_money"..i]:SetSprite("ui_common", config.money_type[money_type].icon, true)
        self["txt_money"..i]:SetText(reward[2] * answer_num)
    end
end

function ExamineTaskTemplate:SetIndexCtrl(index)
    if not self.cur_index or self.cur_index ~= index then
        self.ctrl_index:SetSelectedIndex(index)
        self.cur_index = index
    end
end

function ExamineTaskTemplate:SetHelpText()
    self.btn_help:SetText(config.words[5173])
end

function ExamineTaskTemplate:SetTipsText()
    self.txt_tips:SetVisible(false)
end

function ExamineTaskTemplate:SetPlusText(is_right)
    local drop_id = config.sys_config.examine_guide_reward.value
    local reward_list = config.drop[drop_id].client_goods_list

    self.txt_plus1:SetText("+" .. reward_list[1][2])
    self.txt_plus2:SetText("+" .. reward_list[2][2])

    self:GetRoot():PlayTransition("trans_fade")
end

return ExamineTaskTemplate