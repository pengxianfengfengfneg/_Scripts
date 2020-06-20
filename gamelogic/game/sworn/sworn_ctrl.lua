local SwornCtrl = Class(game.BaseCtrl)

local ViewMap = {
    HomeView = "game/sworn/home_view",
    SwornView = "game/sworn/sworn_view",
    SwornPlatformView = "game/sworn/sworn_platform_view",
    SwornDissmissView = "game/sworn/sworn_dismiss_view",
    SwornSeniorView = "game/sworn/sworn_senior_view",
    SwornConfirmView = "game/sworn/sworn_confirm_view",
    SwornRegisterView = "game/sworn/sworn_register_view",
    SwornValueView = "game/sworn/sworn_value_view",
    SwornTitleChangeView = "game/sworn/sworn_title_change_view",
    SwornTitleUpgradeView = "game/sworn/sworn_title_upgrade_view",
    SwornTitleGroupView = "game/sworn/sworn_title_group_view",
    SwornStyleNameView = "game/sworn/sworn_style_name_view",
    SwornNoticeView = "game/sworn/sworn_notice_view",
    SwornItemOptionView = "game/sworn/sworn_item_option_view",
}

function SwornCtrl:_init()
    if SwornCtrl.instance ~= nil then
        error("SwornCtrl Init Twice!")
    end
    SwornCtrl.instance = self

    self.data = require("game/sworn/sworn_data").New(self)
    for view_name, class_path in pairs(ViewMap) do
        self[view_name] = require(class_path).New(self)
        self:CreateViewFunc(view_name)
    end

    self:RegisterAllEvents()
    self:RegisterAllProtocal()
end

function SwornCtrl:CreateViewFunc(view_name)
    for view_name, class_path in pairs(ViewMap) do
        self["Open"..view_name] = function(self, ...)
            self[view_name]:Open(...)
            return self[view_name]
        end
        self["Close"..view_name] = function(self, ...)
            self[view_name]:Close(...)
        end
    end
end

function SwornCtrl:PrintTable(data)
    if self.log_enable then
        PrintTable(data)
    end
end

function SwornCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function SwornCtrl:_delete()
    self.data:DeleteMe()
    for view_name, class_path in pairs(ViewMap) do
        self[view_name]:DeleteMe()
    end
    SwornCtrl.instance = nil
end

function SwornCtrl:RegisterAllEvents()
    local events = {
       {game.LoginEvent.LoginSuccess, handler(self, self.OnLoginSuccess)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SwornCtrl:RegisterAllProtocal()
    local proto = {
        [54002] = "OnSwornInfo",
        [54004] = "OnSwornConfirmUI",
        [54007] = "OnSwornMemberUpdate",
        [54009] = "OnSwornDismissMemberReq",
        [54011] = "OnSwornDeleteMember",
        [54013] = "OnSwornSeniorSortInfo",
        [54015] = "OnSwornModifyNameReq",
        [54017] = "OnSwornModifyName",
        [54019] = "OnSwornModifyWord",
        [54021] = "OnSwornUpQuality",
        [54022] = "OnSwornValueUpdate",
        [54024] = "OnSwornModifyEnounce",
        [54027] = "OnSwornGetPlatformList",
        [54029] = "OnSwornRegisterUpdate",
        [54032] = "OnSwornGreet",
        [54034] = "OnSwornVoteSenior",
        [54036] = "OnSwornLeaveGroup",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function SwornCtrl:OnLoginSuccess()
    self:SendSwornInfo()
end

function SwornCtrl:OpenView()
    self.SwornView:Open()
end

function SwornCtrl:CloseView()
    self.SwornView:Close()
end

function SwornCtrl:OpenHomeView()
    self.HomeView:Open()
end

function SwornCtrl:CloseHomeView()
    self.HomeView:Close()
end

function SwornCtrl:CloseAllView()
    for view_name, v in pairs(ViewMap) do
        self[view_name]:Close()
    end
end

function SwornCtrl:SendSwornInfo()
    self:SendProtocal(54001)
end

function SwornCtrl:OnSwornInfo(data)
    --[[
        "group_id__L",
        "mem_list__T__mem@U|SwornMember|",
        "group_name__s",
        "quality__C",
        "sworn_value__I",
        "enounce__s",
        "open_ui__C",
    ]]
    self:PrintTable(data)
    self.data:SetSwornInfo(data)
    if data.open_ui == 1 then
        self:OpenSwornView()
    end
end

function SwornCtrl:OnSwornSeniorSortInfo(data)
    --[[
        "cur_senior__C",
        "close_time__I",
        "sorted_list__T__info@U|SwornSortInfo|",
        "raw_list__T__info@U|SwornSortInfo|",
    ]]
    self:PrintTable(data)
    self.data:UpdateSeniorSortInfo(data)
    if not self.SwornSeniorView:IsOpen() and self:HaveSwornGroup() then
        self.SwornSeniorView:Open()
    end
end

function SwornCtrl:OnSwornDeleteMember(data)
    --[[
        "role_id__L",
        "sworn_value__I",
    ]]
    self:PrintTable(data)
    self.data:DeleteMember(data)
end

function SwornCtrl:OnSwornMemberUpdate(data)
    --[[
        "mem_list__T__mem@U|SwornMember|",
    ]]
    self:PrintTable(data)
    self.data:UpdateMemberList(data.mem_list)
end

function SwornCtrl:OnSwornConfirmUI(data)
    --[[
        "type__C",
        "msg__s",
        "cd_time__C",
    ]]
    self:PrintTable(data)
    local confirm_view = self.SwornConfirmView
    if data.cd_time == 0 then
        if confirm_view:GetArg() == data.type then
            confirm_view:Close()
        end
    else
        self:ShowCommonConfirmView(data)
        if data.type == 3 then
            self:CloseSwornDissmissView()
        end
    end
end

function SwornCtrl:ShowCommonConfirmView(data)
    local confirm_view = self.SwornConfirmView
    confirm_view:SetTitle(data.title or config.words[6277])
    confirm_view:SetContent(data.msg)

    confirm_view:SetOkBtn(function()
        self:SendSwornMakeConfirm(data.type, 1)
        if data.type ~= 6 then
            game.GameMsgCtrl.instance:PushMsg(config.words[6291])
        end
    end, config.words[100])

    confirm_view:SetCancelBtn(function()
        if data.type ~= 6 then 
            self:SendSwornMakeConfirm(data.type, 0)
        end
    end, config.words[101], data.cd_time)

    confirm_view:SetArg(data.type)
    confirm_view:Open()
end

function SwornCtrl:ShowLeaveGroupView()
    local confirm_view = self.SwornConfirmView
    confirm_view:SetTitle(config.words[6277])

    local cost = config.sworn_base.sworn_value_cost[1]
    confirm_view:SetContent(string.format(config.words[6288], cost[1], cost[2]))

    confirm_view:SetOkBtn(function()
        self:SendSwornLeaveGroup()
    end, config.words[100])

    confirm_view:SetCancelBtn(nil, config.words[101], config.sworn_base.confirm_cd1)
    confirm_view:Open()
end

function SwornCtrl:SendSwornGreet(type, id)
    --[[
        "type__C",
        "id__L",
    ]]
    self:SendProtocal(54031, {type = type, id = id})
end

function SwornCtrl:OnSwornGreet(data)
    --[[
        "greet_num__C",
        "id__L",
        "type__C",
    ]]
    self:PrintTable(data)
    self.data:OnSwornGreet(data)
end

function SwornCtrl:SendSwornCancelRegister()
    self:SendProtocal(54030)
end

function SwornCtrl:SendSwornRegister(tend_career, tend_lv, tend_time)
    --[[
        "tend_career__C",
        "tend_lv__C",
        "tend_time__C",
    ]]
    self:SendProtocal(54028, {tend_career = tend_career, tend_lv = tend_lv, tend_time = tend_time})
end

function SwornCtrl:SendSwornGetPlatformList(type)
    --[[
        "type__C",
    ]]
    self:SendProtocal(54026, {type = type})
end

function SwornCtrl:OnSwornGetPlatformList(data)
    --[[
        "registered__C",
        "greet_num__C",
        "person_list__T__person@U|SwornPersonPlat|",
        "group_list__T__group@U|SwornPersonPlat|",
    ]]
    self:PrintTable(data)
    self.data:SetPlatformInfo(data)
end

function SwornCtrl:OnSwornValueUpdate(data)
    --[[
        "sworn_value__I",
    ]]
    self:PrintTable(data)
    self.data:UpdateSwornValue(data.sworn_value)
end

function SwornCtrl:SendSwornGatherMember()
    self:SendProtocal(54025)
end

function SwornCtrl:SendSwornUpQuality()
    self:SendProtocal(54020)
end

function SwornCtrl:OnSwornUpQuality(data)
    --[[
        "quality__C",
    ]]
    self:PrintTable(data)
    self.data:UpdateQuality(data.quality)
end

function SwornCtrl:SendSwornModifyWord(word)
    --[[
        "word__s",
    ]]
    self:SendProtocal(54018, {word = word})
end

function SwornCtrl:OnSwornModifyWord(data)
    --[[
        "word__s",
    ]]
    self:PrintTable(data)
    self.data:OnSwornModifyWord(data.word)
end

function SwornCtrl:SendSwornModifyName(name_head, name_tail)
    --[[
        "name_head__s",
        "name_tail__s",
    ]]
    self:SendProtocal(54016, {name_head = name_head, name_tail = name_tail})
end

function SwornCtrl:OnSwornModifyName(data)
    --[[
        "group_name__s",
    ]]
    self:PrintTable(data)
    self.data:ModifyGroupName(data.group_name)
    game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6297], data.group_name))
end

function SwornCtrl:SendSwornChangeSenior()
    self:SendProtocal(54012)
end

function SwornCtrl:SendSwornDismissMemberReq()
    self:SendProtocal(54008)
end

function SwornCtrl:OnSwornDismissMemberReq(data)
    self:PrintTable(data)
    if self:HaveSwornGroup() then
        self:OpenSwornDissmissView()
    end
end

function SwornCtrl:SendSwornDismissMember(role_id, reason)
    --[[
        "role_id__L",
        "reason__C",
    ]]
    self:SendProtocal(54010, {role_id = role_id, reason = reason})
end

function SwornCtrl:SendSwornRecruitMember()
    self:SendProtocal(54006)
end

function SwornCtrl:SendSwornMakeConfirm(type, choice)
    --[[
        "type__C",
        "choice__C",
    ]]
    self:SendProtocal(54005, {type = type, choice = choice})
end

function SwornCtrl:SendSwornCreateNew()
    self:SendProtocal(54003)
end

function SwornCtrl:SendSwornModifyEnounce(enounce)
    --[[
        "enounce__s",
    ]]
    self:SendProtocal(54023, {enounce = enounce})
end

function SwornCtrl:OnSwornModifyEnounce(data)
    --[[
        "enounce__s",
    ]]
    self:PrintTable(data)
    self.data:OnSwornModifyEnounce(data.enounce)
end

function SwornCtrl:OnSwornRegisterUpdate(data)
    --[[
        "registered__C",
    ]]
    self:PrintTable(data)
    self.data:UpdatePlatformInfo(data)
end

function SwornCtrl:SendSwornVoteSenior(role_id)
    --[[
        "role_id__L",
    ]]
    self:SendProtocal(54033, {role_id = role_id})
end

function SwornCtrl:OnSwornVoteSenior(data)
    --[[
        "role_id__L",
    ]]
    self:PrintTable(data)
    self:FireEvent(game.SwornEvent.OnSwornVoteSenior, data.role_id)
end

function SwornCtrl:SendSwornLeaveGroup()
    self:SendProtocal(54035)
end

function SwornCtrl:OnSwornLeaveGroup(data)
    self:PrintTable(data)
    self.data:LeaveGroup()
    self:CloseAllView()
    game.GameMsgCtrl.instance:PushMsg(config.words[6290])
end

function SwornCtrl:SendSwornModifyNameReq()
    self:SendProtocal(54014)
end

function SwornCtrl:OnSwornModifyNameReq(data)
    self:PrintTable(data)
    if self:HaveSwornGroup() then
        self.SwornTitleGroupView:Open()
    end
end

function SwornCtrl:HaveSwornGroup()
    return self.data:HaveSwornGroup()
end

function SwornCtrl:GetSwornInfo()
    return self.data:GetSwornInfo()
end

function SwornCtrl:GetExpAddValue(sworn_value)
    return self.data:GetExpAddValue(sworn_value)
end

function SwornCtrl:GetSeniorName(senior_id)
    return self.data:GetSeniorName(senior_id)
end

function SwornCtrl:GetSeniorName2(senior_id, gender)
    return self.data:GetSeniorName2(senior_id, gender)
end

function SwornCtrl:GetMemberInfo(role_id)
    return self.data:GetMemberInfo(role_id)
end

function SwornCtrl:GetMemberList()
    return self.data:GetMemberList()
end

function SwornCtrl:GetNotice()
    return self.data:GetNotice()
end

function SwornCtrl:GetQuality()
    return self.data:GetQuality()
end

function SwornCtrl:HaveTitle()
    return self.data:HaveTitle()
end

--江湖称号
function SwornCtrl:GetTitle(role_id)
    return self.data:GetTitle(role_id)
end

function SwornCtrl:GetTitleColor()
    return self.data:GetTitleColor()
end

function SwornCtrl:GetColoredTitle(role_id, is_ubb)
    return self.data:GetColoredTitle(role_id, is_ubb)
end

--江湖名号
function SwornCtrl:GetTitleGroupName()
    return self.data:GetTitleGroupName()
end

--江湖字号
function SwornCtrl:GetTitleStyleName(role_id)
    return self.data:GetTitleStyleName(role_id)
end

function SwornCtrl:GetPlatformInfo()
    return self.data:GetPlatformInfo()
end

function SwornCtrl:GetTendCareer(id)
    local career_list = string.split(config.words[6262], ',')
    return career_list[id]
end

function SwornCtrl:GetTendLevel(id)
    local level_list = string.split(config.words[6263], ',')
    return level_list[id]
end

function SwornCtrl:GetTendTime(id)
    local time_list = string.split(config.words[6264], ',')
    return time_list[id]
end

function SwornCtrl:GetSeniorSortInfo()
    return self.data:GetSeniorSortInfo()
end

function SwornCtrl:ClearGreetInfo()
    self.data:ClearGreetInfo()
end

function SwornCtrl:IsGreet(type, id)
    return self.data:IsGreet(type, id)
end

function SwornCtrl:GetTeamNotFriendList()
    local list = {}
    local members = game.MakeTeamCtrl.instance:GetTeamMembers()
    local self_id = game.Scene.instance:GetMainRoleID()
    for k, v in pairs(members) do
        local role_id = v.member.id
        if not game.FriendCtrl.instance:IsMyFriend(role_id) and role_id ~= self_id then
            table.insert(list, v.member)
        end
    end
    return list
end

function SwornCtrl:StartSworn()
    local not_friend_list = self:GetTeamNotFriendList()
    if #not_friend_list > 0 then
        local name_list = {}
        for k, v in ipairs(not_friend_list) do
            table.insert(name_list, v.name)
        end
        local content = string.format(config.words[6241], table.concat(name_list, ","))
        local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(content)
        msg_box:SetBtn1(nil, function()
            for k, v in ipairs(not_friend_list) do
                game.FriendCtrl.instance:CsFriendSysApplyAdd(v.id)
            end
        end)
        msg_box:SetBtn2(config.words[101])
        msg_box:Open()
    else
        self:SendSwornCreateNew()
    end
end

game.SwornCtrl = SwornCtrl

return SwornCtrl