local RoleCtrl = Class(game.BaseCtrl)

local event_mgr = global.EventMgr

function RoleCtrl:_init()
    if RoleCtrl.instance ~= nil then
        error("RoleCtrl Init Twice!")
    end
    RoleCtrl.instance = self

    self.role_view = require("game/role/role_new_view").New(self)
    self.role_data = require("game/role/role_data").New(self)

    self.update_power_view = require("game/role/role_update_power_view").New(self)

    self.role_info_view = require("game/role/role_info_view").New(self)
    self.role_notice_view = require("game/role/role_notice_view").New(self)
    self.role_honor_view = require("game/role/role_honor_view").New(self)
    self.role_honor_preview = require("game/role/role_honor_preview").New(self)
    self.role_title_attr_view = require("game/role/role_title_attr_view").New(self)
    self.role_title_quality_view = require("game/role/role_title_quality_view").New(self)
    self.role_rename_view = require("game/role/role_rename_view").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()

    global.Runner:AddUpdateObj(self, 2)
end

function RoleCtrl:_delete()
    global.Runner:RemoveUpdateObj(self)

    self.role_view:DeleteMe()
    self.role_view = nil

    self.role_data:DeleteMe()
    --self.role_data = nil   --更换账号的时候外观等于nil后没有重新赋值到

    self.role_info_view:DeleteMe()
    self.role_info_view = nil
    
    self.role_notice_view:DeleteMe()
    self.role_notice_view = nil

    self.role_title_attr_view:DeleteMe()
    self.role_title_attr_view = nil

    self.role_title_quality_view:DeleteMe()
    self.role_title_quality_view = nil
    
    self:CloseRoleAttrView()
    self:DeleteUpdatePowerView()

    self.role_honor_view:DeleteMe()
    self.role_honor_preview:DeleteMe()
    self.role_rename_view:DeleteMe()

    RoleCtrl.instance = nil
end

function RoleCtrl:RegisterAllEvents()
    local events = {
        {
            game.SceneEvent.UpdateEnterSceneInfo, 
            function(data_list)
                self:InitRoleInfo(data_list)
            end
        },
        {
            game.RoleEvent.UpdateRoleInfo, 
            function(data)
                self:OnUpdateRoleInfo(data)
            end
        },
        {
            game.LoginEvent.LoginSuccess, 
            function()
                self:SendPersonalInfo()
            end
        },
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function RoleCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(20504, "OnLevelUp")
    self:RegisterProtocalCallback(52702, "OnPersonalInfo")
    self:RegisterProtocalCallback(52704, "OnPersonalInfoChange")
    self:RegisterProtocalCallback(53002, "OnRoleHonorChange")

    self:RegisterProtocalCallback(40602, "OnTitleGetInfo")
    self:RegisterProtocalCallback(40607, "OnTitleNotifyNew")
    self:RegisterProtocalCallback(40608, "OnTitleNotifyExpire")
    self:RegisterProtocalCallback(40609, "OnTitleNotifyCurrent")

    -- 头像框、冒泡框
    self:RegisterProtocalCallback(52511, "OnExteriorBubbleInfo")
    self:RegisterProtocalCallback(52513, "OnExteriorBubbleChoose")
    self:RegisterProtocalCallback(52521, "OnExteriorFrameInfo")
    self:RegisterProtocalCallback(52523, "OnExteriorFrameChoose")
end

function RoleCtrl:OpenView(open_index)
    self.role_view:Open(open_index)
end

function RoleCtrl:OpenRoleInfoView(info)
    self.role_info_view:Open(info)
end

function RoleCtrl:CloseRoleInfoView()
    self.role_info_view:Close()
end

function RoleCtrl:OpenRoleAttrView()
    if not self.role_attr_view then
        self.role_attr_view = require("game/role/role_attr_view").New(self)
        self.role_attr_view:Open()
    end
end

function RoleCtrl:CloseRoleAttrView()
    if self.role_attr_view then
        self.role_attr_view:DeleteMe()
        self.role_attr_view = nil
    end
end

function RoleCtrl:OpenRoleNoticeView()
    self.role_notice_view:Open()
end

function RoleCtrl:OpenTitleAttrView(id)
    self.role_title_attr_view:Open(id)
end

function RoleCtrl:OpenTitleQualityView()
    self.role_title_quality_view:Open()
end

-- 主动升级
function RoleCtrl:SendLevelUp()
    self:SendProtocal(20503)
end

function RoleCtrl:OnLevelUp(data_list)
    game.GameMsgCtrl.instance:PushMsg(config.words[5597])
end

function RoleCtrl:GetRoleLevel()
    return self.role_data:GetRoleLevel()
end

function RoleCtrl:GetRoleExp()
    return self.role_data:GetRoleExp()
end

function RoleCtrl:GetRoleInfo()
    return self.role_data:GetRoleInfo()
end

function RoleCtrl:IsSelf(role_info)
    role_info = role_info or {}
    return self:GetRoleId() == role_info.role_id
end

function RoleCtrl:GetCombatPower()
    return self.role_data:GetCombatPower()
end

function RoleCtrl:InitRoleInfo(data)
    self.role_data:InitRoleInfo(data)
end

function RoleCtrl:OnUpdateRoleInfo(data)
    local pre_power = self:GetCombatPower()
    local delta_power = data.combat_power - pre_power
    self.role_data:SetCombatPower(data.combat_power)

    if pre_power ~= 0 and delta_power > 0 then

        self.update_from_power = pre_power
        self.next_update_power_time = global.Time.now_time + 0.1
    end

    event_mgr:Fire(game.RoleEvent.UpdateMainRoleInfo, data)
end

function RoleCtrl:Update(now_time, elapse_time)
    if self.next_update_power_time and (now_time>=self.next_update_power_time) then
        self.next_update_power_time = nil

        local from_power = self.update_from_power
        local to_power = self:GetCombatPower()

        self.update_from_power = nil
        self:OpenUpdatePowerView(from_power, to_power)
    end
end

function RoleCtrl:OpenUpdatePowerView(from_power, to_power)
    self.update_power_view:Close()
    
    self.update_power_view:Open(from_power, to_power)
end

function RoleCtrl:CloseUpdatePowerView()
    self.update_power_view:Close()
end

function RoleCtrl:DeleteUpdatePowerView()
    if self.update_power_view then
        self.update_power_view:DeleteMe()
        self.update_power_view = nil
    end
end

function RoleCtrl:GetRoleId()
    return self.role_data:GetRoleId()
end

function RoleCtrl:GetChatRoleInfo()
    return self.role_data:GetChatRoleInfo()
end

function RoleCtrl:GetCareer()
    return self.role_data:GetCareer()
end

function RoleCtrl:GetSex()
    return self.role_data:GetSex()
end

function RoleCtrl:CheckRedPoint()
    return false
end

function RoleCtrl:SendGetCommonlyKeyValue()
    self:SendProtocal(10505, {key=game.CommonlyKey.JhexpKillMonNum})
end

function RoleCtrl:SendPersonalInfo()
    self:SendProtocal(52701)
end

function RoleCtrl:OnPersonalInfo(data_list)
    self.role_data:SetPersonalInfo(data_list.msg)
end

function RoleCtrl:SendPersonalInfoChange(msg)
    self:SendProtocal(52703, {msg = msg})
end

function RoleCtrl:OnPersonalInfoChange(data_list)
    self.role_data:SetPersonalInfo(data_list.msg)
end

function RoleCtrl:GetPersonalInfo()
    return self.role_data:GetPersonalInfo()
end

function RoleCtrl:SendLevelExchangeBox(id)
    self:SendProtocal(20501, {id = id})
end

function RoleCtrl:SendHonorUpgrade()
    self:SendProtocal(53001)
end

function RoleCtrl:OnRoleHonorChange(data)
    self.role_data:SetRoleHonor(data.title_honor)
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:SetHonor(data.title_honor)
    end
    self:FireEvent(game.RoleEvent.HonorUpgrade)
end

function RoleCtrl:GetRoleHonor()
    return self.role_data:GetRoleHonor()
end

function RoleCtrl:OpenHonorView()
    self.role_honor_view:Open()
end

function RoleCtrl:OpenHonorPreview()
    self.role_honor_preview:Open()
end

function RoleCtrl:SendTitleGetInfo()
    self:SendProtocal(40601)
end

function RoleCtrl:SendTitleWear(title_id)
    local proto = {
        id = title_id
    }
    self:SendProtocal(40605, proto)
end

function RoleCtrl:OnTitleGetInfo(data)
    self.role_data:SetTitleInfo(data)
end

function RoleCtrl:OnTitleNotifyNew(data)
    self.role_data:AddTitle(data.title)
end

function RoleCtrl:OnTitleNotifyExpire(data)
    for i,v in ipairs(data.titles) do
        self.role_data:DelTitle(v.id)
    end
end

function RoleCtrl:OnTitleNotifyCurrent(data)
    self.role_data:SetCurTitleID(data.title)
end

function RoleCtrl:GetHonorTipState()
    return self.role_data:GetHonorTipState()
end

-- 冒泡框、头像框
function RoleCtrl:SendExteriorBubbleInfo()
    local proto = {

    }
    self:SendProtocal(52510, proto)
end

function RoleCtrl:OnExteriorBubbleInfo(data)
    --[[
        "active_list__T__id@C##expire_time@I",
        "id__H"
    ]]

    --PrintTable(data)

    self.role_data:OnExteriorBubbleInfo(data)

    self:FireEvent(game.RoleEvent.UpdateBubbleInfo)
end

function RoleCtrl:SendExteriorBubbleChoose(id)
    local proto = {
        id = id
    }
    self:SendProtocal(52512, proto)
end

function RoleCtrl:OnExteriorBubbleChoose(data)
    --[[
        "id__H",
    ]]

    --PrintTable(data)

    self.role_data:OnExteriorBubbleChoose(data)

    local main_role_vo = game.Scene.instance:GetMainRoleVo()
    main_role_vo.bubble = data.id

    self:FireEvent(game.RoleEvent.UpdateCurBubble, data.id)
end

function RoleCtrl:SendExteriorFrameInfo()
    local proto = {
        
    }
    self:SendProtocal(52520, proto)
end

function RoleCtrl:OnExteriorFrameInfo(data)
    --[[
        "active_list__T__id@C##expire_time@I",
        "id__H",
    ]]

    --PrintTable(data)

    self.role_data:OnExteriorFrameInfo(data)

    self:FireEvent(game.RoleEvent.UpdateFrameInfo)
end

function RoleCtrl:SendExteriorFrameChoose(id)
    local proto = {
        id = id
    }
    self:SendProtocal(52522, proto)
end

function RoleCtrl:OnExteriorFrameChoose(data)
    --[[
        "id__H",
    ]]

    --PrintTable(data)

    self.role_data:OnExteriorFrameChoose(data)

    local main_role_vo = game.Scene.instance:GetMainRoleVo()
    main_role_vo.frame = data.id

    self:FireEvent(game.RoleEvent.UpdateCurFrame, data.id)
end

function RoleCtrl:GetCurBubble()
    if self.role_data == nil then
        return
    end
    return self.role_data:GetCurBubble()
end

function RoleCtrl:GetCurFrame()
    return self.role_data:GetCurFrame()
end

function RoleCtrl:GetBubbleInfo(bubble)
    return self.role_data:GetBubbleInfo(bubble)
end

function RoleCtrl:GetFrameInfo(frame)
    return self.role_data:GetFrameInfo(frame)
end

function RoleCtrl:OpenRoleRenameView()
    self.role_rename_view:Open()
end

function RoleCtrl:SendRename(new_name)
    self:SendProtocal(10705, {name = new_name})
end

function RoleCtrl:CanTransformChangeScene(role, notice)
    local tran_stat = role and role:GetTranStat()
    if tran_stat then
        local tran_cfg = config.transform[tran_stat]
        if tran_cfg and tran_cfg.can_change_scene == 0 then
            if notice then
                game.GameMsgCtrl.instance:PushMsg(config.words[5526])
            end
            return false
        end
    end
    return true
end

game.RoleCtrl = RoleCtrl

return RoleCtrl