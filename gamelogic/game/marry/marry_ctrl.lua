local MarryCtrl = Class(game.BaseCtrl)

function MarryCtrl:_init()
    if MarryCtrl.instance ~= nil then
        error("MarryCtrl Init Twice!")
    end
    MarryCtrl.instance = self

    self.marry_view = require("game/marry/marry_view").New(self)
    self.marry_data = require("game/marry/marry_data").New(self)
    self.marry_book_view = require("game/marry/marry_book_view").New(self)
    self.bless_view = require("game/marry/bless_view").New(self)
    self.skill_upgrade_view = require("game/marry/skill_upgrade_view").New(self)
    self.church_view = require("game/marry/church_view").New(self)
    self.marry_rank_view = require("game/marry/marry_rank_view").New(self)

    self:RegisterAllProtocal()

    self:BindEvent(game.LoginEvent.LoginRoleRet, function(value)
        if value then
            self:SendSkillCDList()
        end
    end)
end

function MarryCtrl:_delete()
    self.marry_view:DeleteMe()
    self.marry_data:DeleteMe()
    self.marry_book_view:DeleteMe()
    self.bless_view:DeleteMe()
    self.skill_upgrade_view:DeleteMe()
    self.church_view:DeleteMe()
    self.marry_rank_view:DeleteMe()

    MarryCtrl.instance = nil
end

function MarryCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(41602, "OnMarryInfo")
    self:RegisterProtocalCallback(41604, "OnMarryInvite")
    self:RegisterProtocalCallback(41607, "OnMarryNotifyInvite")
    self:RegisterProtocalCallback(41608, "OnMarryNotifyResponse")
    self:RegisterProtocalCallback(41609, "OnMarryNotifyCouple")
    self:RegisterProtocalCallback(41612, "OnMarryDivorce")
    self:RegisterProtocalCallback(41615, "OnMarryNotifyDivorce")
    self:RegisterProtocalCallback(41616, "OnMarryDivorceConfirm")
    self:RegisterProtocalCallback(41617, "OnMarryDivorceSuccess")
    self:RegisterProtocalCallback(41620, "OnMarryBless")
    self:RegisterProtocalCallback(41622, "OnMarryUpgradeSkill")

    -- 夫妻技能
    self:RegisterProtocalCallback(90331, "OnNotifyTransfer")
    self:RegisterProtocalCallback(90334, "OnSkillCDList")
    self:RegisterProtocalCallback(90335, "OnUpdateSkillCD")
    self:RegisterProtocalCallback(41624, "OnMateScene")
end

function MarryCtrl:OpenView()
    if self:IsMarry() then
        self.marry_view:Open()
    else
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:GetOperateMgr():DoGoToTalkNpc(config.marry_npc[1])
        end
    end
end

function MarryCtrl:OpenMarryBookView()
    self.marry_book_view:Open()
end

function MarryCtrl:SendGetMarryInfo()
    self:SendProtocal(41601)
end

function MarryCtrl:OnMarryInfo(data)
    self.marry_data:SetMarryInfo(data)
    self:FireEvent(game.MarryEvent.MarryInfo)
end

function MarryCtrl:IsMarry()
    local marry_info = self:GetMarryInfo()
    if marry_info and marry_info.mate_id ~= 0 then
        return true
    else
        return false
    end
end

function MarryCtrl:GetMarryInfo()
    return self.marry_data:GetMarryInfo()
end

function MarryCtrl:SendMarryInvite()
    if self:IsMarry() then
        game.GameMsgCtrl.instance:PushMsg(config.words[2614])
        return
    end
    local open_lv = config.func[game.OpenFuncId.Marry].open_cond[1][2]
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    if role_lv < open_lv then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[2602], open_lv))
        return
    end
    if not game.MakeTeamCtrl.instance:HasTeam() then
        game.GameMsgCtrl.instance:PushMsg(config.words[2603])
        return
    end
    if not game.MakeTeamCtrl.instance:IsSelfLeader() then
        game.GameMsgCtrl.instance:PushMsg(config.words[2605])
        return
    end
    local team_member = game.MakeTeamCtrl.instance:GetTeamMembers()
    if #team_member ~= 2 then
        game.GameMsgCtrl.instance:PushMsg(config.words[2604])
        return
    end
    local self_id = game.RoleCtrl.instance:GetRoleId()
    local role_id = 0
    local partner_name = ""
    local partner_sex
    for _, v in ipairs(team_member) do
        if v.member.id ~= self_id then
            role_id = v.member.id
            partner_name = v.member.name
            partner_sex = v.member.gender
            break
        end
    end
    if partner_sex == game.RoleCtrl.instance:GetSex() then
        game.GameMsgCtrl.instance:PushMsg(config.words[2617])
        return
    end
    self:SendProtocal(41603, { id = role_id, opt = 1 })
end

function MarryCtrl:OnMarryInvite()
    game.GameMsgCtrl.instance:PushMsg(config.words[2609])
end

function MarryCtrl:SendMarryResponse(id, opt)
    self:SendProtocal(41605, { id = id, opt = opt })
end

function MarryCtrl:OnMarryNotifyInvite(data)
    local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(string.format(config.words[2607], data.name))
    tips_view:SetBtn1(nil, function()
        self:SendMarryResponse(data.id, 1)
    end)
    tips_view:SetBtn2(config.words[101], function()
        self:SendMarryResponse(data.id, 0)
    end)
    tips_view:Open()
end

function MarryCtrl:OnMarryNotifyResponse(data)
    --    回应通知 (拒绝时)
    if data.opt == 0 then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[2606], data.name))
    elseif data.opt == 1 then
        local cost = config.sys_config.marry_cost.value
        local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(string.format(config.words[2608], cost, data.name))
        tips_view:SetBtn1(nil, function()
            game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, cost, function()
                self:SendProtocal(41603, { id = data.id, opt = 2 })
            end)
        end)
        tips_view:SetBtn2(config.words[101])
        tips_view:Open()
    end
end

function MarryCtrl:OnMarryNotifyCouple()
    --    结婚通知 (结婚双方)
    self:SendGetMarryInfo()
    self:OpenMarryBookView()
end

function MarryCtrl:SendDivorce(type)
    -- 1是协议2是强制
    if not self:IsMarry() then
        game.GameMsgCtrl.instance:PushMsg(config.words[2613])
        return
    end
    if type == 1 then
        if not game.MakeTeamCtrl.instance:HasTeam() then
            game.GameMsgCtrl.instance:PushMsg(config.words[2615])
            return
        end
        if not game.MakeTeamCtrl.instance:IsSelfLeader() then
            game.GameMsgCtrl.instance:PushMsg(config.words[2616])
            return
        end
        self:SendProtocal(41611, { type = type })
    else
        local cost = config.sys_config.marry_divorce_cost.value
        local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(string.format(config.words[2612], cost))
        tips_view:SetBtn1(nil, function()
            game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, cost, function()
                self:SendProtocal(41611, { type = type })
            end)
        end)
        tips_view:SetBtn2(config.words[101])
        tips_view:Open()
    end
end

function MarryCtrl:OnMarryDivorce()
    self:SendGetMarryInfo()
end

function MarryCtrl:SendDivorceConfirm(opt)
    self:SendProtocal(41613, { opt = opt })
end

function MarryCtrl:OnMarryNotifyDivorce()
    local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[2610])
    tips_view:SetBtn1(nil, function()
        self:SendDivorceConfirm(1)
    end)
    tips_view:SetBtn2(config.words[101], function()
        self:SendDivorceConfirm(0)
    end)
    tips_view:Open()
end

function MarryCtrl:OnMarryDivorceSuccess()
    self:SendGetMarryInfo()
end

function MarryCtrl:OnMarryDivorceConfirm(data)
    if data.opt == 0 then
        game.GameMsgCtrl.instance:PushMsg(config.words[2611])
    end
end

function MarryCtrl:SendMarryBless()
    self:SendProtocal(41619)
end

function MarryCtrl:OnMarryBless(data)
    self.marry_data:SetMarryBless(data.bless)
    self:FireEvent(game.MarryEvent.Bless, data)
end

function MarryCtrl:GetBless()
    return self.marry_data:GetBless()
end

function MarryCtrl:SendMarryUpgradeSkill(skill_id)
    self:SendProtocal(41621, { id = skill_id })
end

function MarryCtrl:OnMarryUpgradeSkill(data)
    self.marry_data:SetMarrySkill(data)
    self:FireEvent(game.MarryEvent.SkillUpgrade, data)
end

function MarryCtrl:GetMarrySkill(id)
    return self.marry_data:GetMarrySkill(id)
end

function MarryCtrl:OpenBlessView()
    if self:IsMarry() then
        self.bless_view:Open()
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[2613])
    end
end

function MarryCtrl:OpenSkillUpgradeView()
    if self:IsMarry() then
        self.skill_upgrade_view:Open()
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[2613])
    end
end

function MarryCtrl:GetHisLove()
    return self.marry_data:GetHisLove()
end

function MarryCtrl:GetMateName()
    return self.marry_data:GetMateName()
end

function MarryCtrl:OpenChurch()
    self.church_view:Open()
end

function MarryCtrl:OpenRankView()
    self.marry_rank_view:Open()
end

function MarryCtrl:GetData()
    return self.marry_data
end

function MarryCtrl:SendUseSkill(skill_id)
    if skill_id == 40000001 then
        -- 主动传送技能先查询
        self:SendMateScene()
        return
    end
    self:SendProtocal(90330, {skill_id = skill_id})
end

function MarryCtrl:OnNotifyTransfer(data)
    local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(string.format(config.words[2623], config.scene[data.scene_id].name))
    tips_view:SetBtn1(nil, function()
        self:SendAckTransfer(1, data.scene_id)
    end)
    tips_view:SetBtn2(config.words[101], function()
        self:SendAckTransfer(0, data.scene_id)
    end)
    tips_view:Open()
end

function MarryCtrl:SendAckTransfer(type, id)
    self:SendProtocal(90332, {reply = type, scene_id = id})
end

function MarryCtrl:SendSkillCDList()
    self:SendProtocal(90333)
end

function MarryCtrl:OnSkillCDList(data)
    self.marry_data:SetSkillCDList(data.cd_list)
end

function MarryCtrl:GetSkillCDList()
    return self.marry_data:GetSkillCDList()
end

function MarryCtrl:OnUpdateSkillCD(data)
    game.SwornCtrl.instance:CloseHomeView()
    self.marry_view:Close()
    self.marry_data:SetSkillCD(data.skill_id)
    self:FireEvent(game.MarryEvent.UpdateSkillCD, data.skill_id)
end

function MarryCtrl:GetSkillCD(skill_id)
    return self.marry_data:GetSkillCD(skill_id)
end

function MarryCtrl:SendMateScene()
    self:SendProtocal(41623)
end

function MarryCtrl:OnMateScene(data)
    if config.scene[data.scene_id] then
        game.SwornCtrl.instance:CloseHomeView()
        self.marry_view:Close()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:DoChagneScene(data.scene_id, function()
                self:SendProtocal(90330, {skill_id = 40000001})
            end)
        end
    end
end

game.MarryCtrl = MarryCtrl

return MarryCtrl