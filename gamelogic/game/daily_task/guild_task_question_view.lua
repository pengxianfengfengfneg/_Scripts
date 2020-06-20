local GuildTaskQuestionView = Class(game.BaseView)

local _quest_config = config.guild_task_question

function GuildTaskQuestionView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "guild_task_question_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildTaskQuestionView:_delete()
    
end

function GuildTaskQuestionView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RefreshQuestion()
    
    game.Scene.instance:GetMainRole():SetPauseOperate(true)
end

function GuildTaskQuestionView:CloseViewCallBack()
    self:StopNextCounter()
    self:StopCloseCounter()
    if self.answer == self.right_answer then
        self.ctrl:TryOpenGuildTaskView(true)
    end
    
    local scene = game.Scene.instance
    if scene then
        local main_role = scene:GetMainRole()
        if main_role then
            main_role:SetPauseOperate(false)
        end
    end
end

function GuildTaskQuestionView:Init()
    self.txt_quest = self._layout_objs["txt_quest"]

    for i=1, 4 do
        local option = "option"..i
        self[option] = self:GetTemplate("game/guild/item/guild_answer_option_item", option)
    end

    self.answer_count = self.answer_count or 0
    self:TryResetQuestionConfig()

    self.task_type = 3
end

function GuildTaskQuestionView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5103]):HideBtnBack()
end

function GuildTaskQuestionView:RefreshQuestion()
    local quest = self:GetQuestion()
    self.right_answer = quest.answer
    self.txt_quest:SetText(quest.question)

    for i=1, 4 do
        local item_info = {
            index = i,
            option = quest["options"..i],
            type = 0,
            select = false,
        }
        local option = self["option"..i]
        option:SetItemInfo(item_info)
        option:SetClickFunc(function()
            if not self.answer then
                self.answer = i

                option:SetOptionType(i == quest.answer and 1 or 2)
                option:SetSelected(true)

                if self.answer ~= quest.answer then
                    self["option"..quest.answer]:SetOptionType(1)
                    self:NextQuestion()
                else
                    self.ctrl:SendGuildTaskFinish(self.task_type)
                    self:StartCloseCounter()
                end
            end
        end)
    end
    self.answer = nil
end

function GuildTaskQuestionView:NextQuestion()
    local next_interval = 2
    self:StopNextCounter()

    self.tween = DOTween:Sequence()
    self.tween:AppendInterval(next_interval)
    self.tween:AppendCallback(function()
        self:RefreshQuestion()
    end)
    self.tween:Play()
end

function GuildTaskQuestionView:StopNextCounter()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function GuildTaskQuestionView:GetQuestion()
    local quest_num = #_quest_config - self.answer_count
    local index = math.random(1, quest_num)

    local tmp = _quest_config[quest_num]
    _quest_config[quest_num] = _quest_config[index]
    _quest_config[index] = tmp

    self.answer_count = self.answer_count + 1
    self:TryResetQuestionConfig()

    return _quest_config[quest_num]
end

function GuildTaskQuestionView:TryResetQuestionConfig()
    if self.answer_count == #_quest_config then
        table.sort(_quest_config, function(m, n)
            return m.id < n.id
        end)
        self.answer_count = 0
    end
end

function GuildTaskQuestionView:StartCloseCounter()
    local time = 2
    self:StopCloseCounter()
    self.close_tween = DOTween:Sequence()
    self.close_tween:AppendInterval(time)
    self.close_tween:AppendCallback(function()
        self:Close()
    end)
    self.close_tween:Play()
end

function GuildTaskQuestionView:StopCloseCounter()
    if self.close_tween then
        self.close_tween:Kill(false)
        self.close_tween = nil
    end
end

return GuildTaskQuestionView
