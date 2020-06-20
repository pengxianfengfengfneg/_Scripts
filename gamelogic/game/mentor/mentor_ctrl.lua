local MentorCtrl = Class(game.BaseCtrl)

local CommonViewType = {
    AdvancePrentice = 1,
}

function MentorCtrl:_init()
    if MentorCtrl.instance ~= nil then
        error("MentorCtrl Init Twice!")
    end
    MentorCtrl.instance = self

    self.data = require("game/mentor/mentor_data").New(self)
    self.view = require("game/mentor/mentor_view").New(self)
    self.register_view = require("game/mentor/mentor_register_view").New(self)
    self.notice_view = require("game/mentor/mentor_notice_view").New(self)
    self.graduate_view = require("game/mentor/mentor_graduate_view").New(self)
    self.post_view = require("game/mentor/mentor_post_view").New(self)
    self.dismiss_view = require("game/mentor/mentor_dismiss_view").New(self)
    self.option_view = require("game/mentor/mentor_option_view").New(self)
    self.confirm_view = require("game/mentor/mentor_confirm_view").New(self)
    self.feedback_view = require("game/mentor/mentor_feedback_view").New(self)
    self.feedback_tips_view = require("game/mentor/mentor_feedback_tips_view").New(self)
    self.recommend_view = require("game/mentor/mentor_recommend_view").New(self)

    self:RegisterAllEvents()
    self:RegisterAllProtocal()
end

function MentorCtrl:PrintTable(data)
    if self.log_enable then
        PrintTable(data)
    end
end

function MentorCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function MentorCtrl:_delete()
    self.data:DeleteMe()
    self.view:DeleteMe()
    self.register_view:DeleteMe()
    self.notice_view:DeleteMe()
    self.graduate_view:DeleteMe()
    self.post_view:DeleteMe()
    self.dismiss_view:DeleteMe()
    self.option_view:DeleteMe()
    self.confirm_view:DeleteMe()
    self.feedback_view:DeleteMe()
    self.feedback_tips_view:DeleteMe()
    self.recommend_view:DeleteMe()

    MentorCtrl.instance = nil
end

function MentorCtrl:RegisterAllProtocal()
    local proto = {
        [54202] = "OnMentorInfo",
        [54204] = "OnMentorBegin",
        [54208] = "OnMentorRegister",
        [54210] = "OnMentorFind",
        [54212] = "OnMentorBaseInfoListUpdate",
        [54213] = "OnMentorTudiListUpdate",
        [54215] = "OnMentorTaskListUpdate",
        [54216] = "OnMentorLearnTaskListUpdate",
        [54217] = "OnMentorTaixueTaskListUpdate",
        [54218] = "OnMentorCommentUI",
        [54220] = "OnMentorComment",
        [54222] = "OnMentorRefreshNew",
        [54223] = "OnMentorSeniorTudiUI",
        [54226] = "OnMentorBeginPractice",
        [54228] = "OnMentorDelBaseInfoUpdate",
        [54229] = "OnMentorDelTudiInfoUpdate",
        [54232] = "OnMentorTakeTaskAward",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function MentorCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, handler(self, self.OnLoginSuccess)},
        {game.SceneEvent.CommonlyValueRespon, handler(self, self.FireMentorMsg)},
    }
    for _, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MentorCtrl:OnLoginSuccess()
    self:SendMentorInfo()
end

function MentorCtrl:OpenView()
    self.view:Open()
end

function MentorCtrl:CloseView()
    self.view:Close()
end

function MentorCtrl:OpenRegisterView(type)
    self.register_view:Open(type)
end

function MentorCtrl:OpenNoticeView(info)
    self.notice_view:Open(info)
end

function MentorCtrl:OpenGraduateView(info)
    self.graduate_view:Open(info)
end

function MentorCtrl:OpenPostView(info)
    self.post_view:Open(info)
end

function MentorCtrl:OpenDismissView(role_id)
    self.dismiss_view:Open(role_id)
end

function MentorCtrl:OpenRecommendView()
    self.recommend_view:Open()
end

function MentorCtrl:OpenOptionView(info, global_pos)
    self.option_view:Open(info, global_pos)
end

function MentorCtrl:OpenFeedbackView()
    self.feedback_view:Open()
end

function MentorCtrl:OpenFeedbackTipsView()
    self.feedback_tips_view:Open()
end

function MentorCtrl:OpenConfirmView(data)
    self.confirm_view:SetTitle(data.title or config.words[6277])
    self.confirm_view:SetContent(data.content)

    self.confirm_view:SetOkBtn(data.ok_func, config.words[100])
    self.confirm_view:SetCancelBtn(data.cancel_func, config.words[101], data.cd_time)

    self.confirm_view:SetArg(data.arg)
    self.confirm_view:Open()
end

function MentorCtrl:ShowMentorBeginUI(mentor_name)
    local data = {}
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local type = role_lv >= config.mentor_base.senior_lv and config.words[6433] or config.words[6434]
    data.content = string.format(config.words[6432], mentor_name, type)
    data.ok_func = function()
        self:SendMentorBeginConfirm(1)
    end
    data.cancen_func = function()
        self:SendMentorBeginConfirm(0)
    end
    data.cd_time = config.mentor_base.confirm_cd1
    self:OpenConfirmView(data)
end

function MentorCtrl:ShowMentorSayGoodBuyUI()
    local base_info = self:GetBaseInfo(self:GetMentorID())
    if base_info then
        local data = {}
        data.content = string.format(config.words[6435], base_info.name)
        data.ok_func = function()
            self:SendMentorSayGoodbye()
        end
        data.cd_time = config.mentor_base.confirm_cd1
        self:OpenConfirmView(data)
    end
end

function MentorCtrl:ShowMentorGraduateUI(info)
    local data = {}
    data.content = string.format(config.words[6437], info.name, info.mark, info.max_mark)
    data.ok_func = function()
        self:SendMentorFinishLearning(info.role_id)
    end
    data.cd_time = config.mentor_base.confirm_cd1
    self:OpenConfirmView(data)
end

function MentorCtrl:ShowMentorKickUI(info)
    local data = {}
    data.content = string.format(config.words[6442], info.name)
    data.ok_func = function()
        self:SendMentorKickOffTudi(info.role_id, info.reason_idx)
    end
    data.cd_time = config.mentor_base.confirm_cd1
    self:OpenConfirmView(data)
end

function MentorCtrl:SendMentorInfo()
    self:SendProtocal(54201)
end

function MentorCtrl:OnMentorInfo(data)
    --[[
        "mentor_id__L",
        "mentor_quiz_list__T__index@C##choice@C",
        "tudi_quiz_list__T__index@C##choice@C",
        "open_ui__C",
        "info_list__T__info@U|MentorBaseInfo|",
        "tudi_list__T__tudi@U|MentorTudiInfo|",
    
        "morality__I",
        "mentor_lv__C",
        "registered__C",
    ]]
    self:PrintTable(data)
    self.data:SetMentorInfo(data)
    if data.open_ui == 1 then
        self:OpenView()
    end
    self:InitMentorCtrl()
end

function MentorCtrl:InitMentorCtrl()
    if self.is_init then
        return
    end
    game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.MentorNoticeTime)
    self.is_init = true
end

function MentorCtrl:FireMentorMsg(data)
    --屏蔽
    if true then
        return
    end
    if data.key ~= game.CommonlyKey.MentorNoticeTime then
        return
    end
    local last_date = data.value
    local time = global.Time:GetServerTime()
    local now_date = tonumber(os.date("%y%m%d", time))

    if data.value == 0 or last_date ~= now_date then
        if not self:HasMentorInfo() then
            local lv = game.RoleCtrl.instance:GetRoleLevel()
            if lv < config.mentor_base.senior_lv then
                self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, game.MsgNoticeId.FindMentor)
            else
                self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, game.MsgNoticeId.FindMentorSp)
            end
            game.MainUICtrl.instance:SendSetCommonlyKeyValue(game.CommonlyKey.MentorNoticeTime, now_date)
        end
    end
end

function MentorCtrl:OnMentorSeniorTudiUI(data)
    --[[
        "msg__s",
    ]]
    self:PrintTable(data)
    if self.confirm_view:IsOpen() and self.confirm_view:GetArg() == CommonViewType.AdvancePrentice then
        self.confirm_view:Close()
    else
        self:ShowMentorSeniorTudiUI(data.msg)
    end
end

function MentorCtrl:ShowMentorSeniorTudiUI(content)
    local data = {}
    data.content = content
    data.ok_func = function()
        self:SendMentorSeniorTudiConfirm(1)
    end
    data.cancen_func = function()
        self:SendMentorSeniorTudiConfirm(0)
    end
    data.cd_time = config.mentor_base.confirm_cd1
    data.arg = CommonViewType.AdvancePrentice
    self:OpenConfirmView(data)
end

function MentorCtrl:OnMentorRefreshNew(data)
    --[[
        "mentor_id__L",
        "morality__I",
        "mentor_lv__C",
    ]]
    self:PrintTable(data)
    self.data:UpdateMentorInfo(data)
end

function MentorCtrl:OnMentorCommentUI(data)
    self:PrintTable(data)
    self:OpenFeedbackView()
end

function MentorCtrl:OnMentorTaixueTaskListUpdate(data)
    --[[
        "role_id__L",
        "replace__C",
        "taixue_tasks__T__id@I##progress@I",
    ]]
    self:PrintTable(data)
    self.data:UpdateAdvanceTask(data.role_id, data.taixue_tasks, data.replace)
end

function MentorCtrl:OnMentorLearnTaskListUpdate(data)
    --[[
        "role_id__L",
        "replace__C",
        "learn_tasks__T__id@I##progress@I",
    ]]
    self:PrintTable(data)
    self.data:UpdateStudyTask(data.role_id, data.learn_tasks, data.replace)
end

function MentorCtrl:OnMentorTaskListUpdate(data)
    --[[
        "role_id__L",
        "replace__C",
        "mentor_tasks__T__id@I##progress@I",
    ]]
    self:PrintTable(data)
    self.data:UpdateMenterTask(data.role_id, data.mentor_tasks, data.replace)
end

function MentorCtrl:OnMentorTudiListUpdate(data)
    --[[
        "tudi_list__T__tudi@U|MentorTudi|",
    ]]
    self:PrintTable(data)
    self.data:UpdatePrenticeInfo(data.tudi_list)
end

function MentorCtrl:OnMentorBaseInfoListUpdate(data)
    --[[
        "info_list__T__info@U|MentorBaseInfo|",
    ]]
    self:PrintTable(data)
    self.data:UpdateBaseInfo(data.info_list)
end

function MentorCtrl:SendMentorTakeTaskAward(role_id)
    --[[
        "role_id__L",
    ]]
    self:SendProtocal(54231, {role_id = role_id})
end

function MentorCtrl:OnMentorTakeTaskAward(data)
    --[[
        "role_id__L",
        "award_taken__C",
    ]]
    self:PrintTable(data)
    self.data:TakeMentorTaskAward(data.role_id, data.award_taken)
end

function MentorCtrl:SendMentorSayGoodbye()
    self:SendProtocal(54230)
end

function MentorCtrl:OnMentorDelBaseInfoUpdate(data)
    --[[
        "del_id_list__T__id@L",
    ]]
    self:PrintTable(data)
    self.data:DelBaseInfo(data.del_id_list)
end

function MentorCtrl:SendMentorKickOffTudi(role_id, reason)
    --[[
        "role_id__L",
        "reason__C",
    ]]
    self:SendProtocal(54227, {role_id = role_id, reason = reason})
end

function MentorCtrl:SendMentorSeniorTudiConfirm(choice)
    --[[
        "choice__C",
    ]]
    self:SendProtocal(54224, {choice = choice})
end

function MentorCtrl:SendMentorFinishLearning(role_id)
    --[[
        "role_id__L",
    ]]
    self:SendProtocal(54221, {role_id = role_id})
end

function MentorCtrl:SendMentorComment(comment)
    --[[
        "comment__C",
    ]]
    self:SendProtocal(54219, {comment = comment})
end

function MentorCtrl:OnMentorComment(data)
    --[[
        "role_id__L",
        "comment__C",
    ]]
    self:PrintTable(data)
    self.data:UpdateMentorComment(data)
end

function MentorCtrl:SendMentorSetTasks(role_id, task_id_list)
    --[[
        "role_id__L",
        "task_id_list__T__id@I",
    ]]
    self:SendProtocal(54214, {role_id = role_id, task_id_list = task_id_list})
    self:PrintTable(task_id_list)
end

function MentorCtrl:SendMentorSendPost(role_id, enounce)
    --[[
        "role_id__L",
        "enounce__s",
    ]]
    self:SendProtocal(54211, {role_id = role_id, enounce = enounce})
end

function MentorCtrl:SendMentorFind()
    self:SendProtocal(54209)
end

function MentorCtrl:OnMentorFind(data)
    --[[
        "mentors__T__mentor@U|MentorBaseInfo|",
    ]]
    self:PrintTable(data)
    self:FireEvent(game.MentorEvent.OnMentorFind, data.mentors)
end

function MentorCtrl:SendMentorRegister(registered)
    --[[
        "registered__C",
    ]]
    self:SendProtocal(54207, {registered = registered})
end

function MentorCtrl:OnMentorRegister(data)
    --[[
        "registered__C",
    ]]
    self:PrintTable(data)
    self.data:OnMentorRegister(data.registered)
end

function MentorCtrl:SendMentorAnswerQuiz(type, quiz_list)
    --[[
        "type__C",
        "quiz_list__T__index@C##choice@C",
    ]]
    self:SendProtocal(54206, {type = type, quiz_list = quiz_list})
    self.data:UpdateMentorAnswerQuiz(type, quiz_list)
end

function MentorCtrl:SendMentorBeginConfirm(choice)
    --[[
        "choice__C",
    ]]
    self:SendProtocal(54205, {choice = choice})
end

function MentorCtrl:SendMentorBegin()
    self:SendProtocal(54203)
end

function MentorCtrl:OnMentorBegin(data)
    --[[
        "mentor_name__s",
    ]]
    self:PrintTable(data)
    self:ShowMentorBeginUI(data.mentor_name)
end

function MentorCtrl:SendMentorBeginPractice()
    self:SendProtocal(54225)
end

function MentorCtrl:OnMentorBeginPractice(data)
    --[[
        "role_id__L",
        "practice_num__C",
    ]]
    self:PrintTable(data)
    self.data:MentorBeginPractice(data.role_id, data.practice_num)
end

function MentorCtrl:OnMentorDelTudiInfoUpdate(data)
    --[[
        "del_id_list__T__id@L",
    ]]
    self:PrintTable(data)
    self.data:DelPrenticeInfo(data.del_id_list)
end

function MentorCtrl:HasMentorInfo()
    return self.data:HasMentorInfo()
end

function MentorCtrl:GetMentorInfo()
    return self.data:GetMentorInfo()
end

function MentorCtrl:IsMentor()
    return self.data:IsMentor()
end

function MentorCtrl:GetMentorID()
    return self.data:GetMentorID()
end

function MentorCtrl:GetMemberList(fliter)
    return self.data:GetMemberList(fliter)
end

function MentorCtrl:GetMemberType(role_id)
    return self.data:GetMemberType(role_id)
end

function MentorCtrl:GetBaseInfo(role_id)
    return self.data:GetBaseInfo(role_id)
end

function MentorCtrl:GetPrenticeInfo(role_id)
    return self.data:GetPrenticeInfo(role_id)
end

function MentorCtrl:IsMentorRegistered()
    return self.data:IsMentorRegistered()
end

function MentorCtrl:GetSeniorName(senior_id, gender)
    return self.data:GetSeniorName(senior_id, gender)
end

function MentorCtrl:GetRegisterBankInfo(id)
    return self.data:GetRegisterBankInfo(id)
end

function MentorCtrl:GetMentorLevelConfig()
    return self.data:GetMentorLevelConfig()
end

function MentorCtrl:GetMentorTaskReward(lv)
    return self.data:GetMentorTaskReward(lv)
end

function MentorCtrl:GetTaixueTaskReward()
    return self.data:GetTaixueTaskReward()
end

function MentorCtrl:GetPrenticeMark(role_id)
    return self.data:GetPrenticeMark(role_id)
end

function MentorCtrl:GetMentorName()
    return self.data:GetMentorName()
end

function MentorCtrl:GetAdvanceTaskFinishNum(advance_tasks)
    return self.data:GetAdvanceTaskFinishNum(advance_tasks)
end

function MentorCtrl:GetMaxStudyMark()
    return self.data:GetMaxStudyMark()
end

function MentorCtrl:IsFinishMentorTask(role_id)
    return self.data:IsFinishMentorTask(role_id)
end

function MentorCtrl:GetMentorLevel()
    return self.data:GetMentorLevel()
end

game.MentorCtrl = MentorCtrl

return MentorCtrl