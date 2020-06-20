local LakeExpCtrl = Class(game.BaseCtrl)

function LakeExpCtrl:_init()
    if LakeExpCtrl.instance ~= nil then
        error("LakeExpCtrl Init Twice!")
    end
    LakeExpCtrl.instance = self

    self.data = require("game/lake_exp/lake_exp_data").New(self)
    self.view = require("game/lake_exp/lake_exp_view").New(self)
    self.keep_exp_tips_view = require("game/lake_exp/keep_exp_tips_view").New(self)

    self:RegisterAllEvents()
    self:RegisterAllProtocal()
end

function LakeExpCtrl:PrintTable(data)
    if self.log_enable then
        PrintTable(data)
    end
end

function LakeExpCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function LakeExpCtrl:_delete()
    self.data:DeleteMe()
    self.view:DeleteMe()
    self.keep_exp_tips_view:DeleteMe()

    LakeExpCtrl.instance = nil
end

function LakeExpCtrl:GetView()
    return self.view
end

function LakeExpCtrl:RegisterAllEvents()
    local events = {
        {game.SceneEvent.CommonlyValueRespon, handler(self, self.OnCommonlyKeyValue)},
        {game.LoginEvent.LoginRoleRet, handler(self, self.OnLoginRoleRet)},
        {game.SysSettingEvent.OnGetSettingInfo, handler(self, self.OnGetSettingInfo)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function LakeExpCtrl:RegisterAllProtocal()
    local proto = {
        [52302] = "OnLakeExperienceInfo",
        [52304] = "OnLakeExperienceUse",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function LakeExpCtrl:OpenView()
    self.view:Open()
end

function LakeExpCtrl:CloseView()
    self.view:Close()
end

function LakeExpCtrl:OpenKeepExpTipsView()
    self.keep_exp_tips_view:Open()
end

function LakeExpCtrl:OnCommonlyKeyValue(data)
    if data.key == game.CommonlyKey.DailyOutsideKillMon then
        self.data:SetKillMonNum(data)

        if self.kill_mon_req then
            self.kill_mon_req = false
        else
            local max_num = config.kill_mon_exp_info.kill_num[1][2]
            local exp = 100-config.kill_mon_exp_info.kill_num[2][3]

            if data.value == max_num then
                self:ShowKillMonTipsView(max_num, exp)
            end
        end
    end
end

function LakeExpCtrl:ShowKillMonTipsView(max_num, exp)
    local str = string.format(config.words[5416], max_num, exp)
    local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(str)
    msg_box:SetBtn1(nil, function()
    end)
    msg_box:Open()
end

function LakeExpCtrl:SendGetKillMonNum()
    game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.DailyOutsideKillMon)
    self.kill_mon_req = true
end

function LakeExpCtrl:OnLoginRoleRet(val)
    if val then
        self:SendLakeExperienceInfo()
    end
end

function LakeExpCtrl:SendLakeExperienceInfo()
    self:SendProtocal(52301)
end

function LakeExpCtrl:OnLakeExperienceInfo(data)
    --[[
        keep_exp__L  // 天灵丹储存经验
        have_times__C // 今日可使用次数
    ]]
    self:PrintTable(data)
    self.data:SetLakeExpInfo(data)
    self:OnKeepExpChange(data.keep_exp)
    self:OnPetExpChange(data.dl_keep_exp)
    self:CheckKeepExp()
end

-- 使用天灵丹
function LakeExpCtrl:SendLakeExperienceUse(num)
    self:SendProtocal(52303, {num = num})
end

function LakeExpCtrl:OnLakeExperienceUse(data)
    --[[
        keep_exp__L  // 天灵丹储存经验
        add_exp__L  // 增加存储经验
        have_times__C // 今日可使用次数  
    ]]
    self:PrintTable(data)
    self.data:UpdateLakeExpInfo(data)
    if data.type == 1 then
        self:OnKeepExpChange(data.keep_exp)
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5415], data.add_exp, data.have_times))
    else
        self:OnPetExpChange(data.keep_exp)
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1578], data.add_exp))
    end
    self:FireEvent(game.LakeExpEvent.OnLakeExperienceUse)
end

function LakeExpCtrl:GetKeepExpUseTimes()
    return self.data:GetKeepExpUseTimes()
end

function LakeExpCtrl:GetKillMonNum()
    return self.data:GetKillMonNum()
end

local _config_effect = config.effect
function LakeExpCtrl:OnKeepExpChange(keep_exp)
    local buff_id = config.kill_mon_exp_info.buff_id
    local buff_lv = 1
    _config_effect[buff_id][buff_lv].desc_param = {keep_exp}

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    if keep_exp > 0 then
        main_role:AddStaticBuff(buff_id)
    end
end

function LakeExpCtrl:OnPetExpChange(pet_exp)
    local buff_id = 20101
    local buff_lv = 1
    _config_effect[buff_id][buff_lv].desc_param = {pet_exp}

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    if pet_exp > 0 then
        main_role:AddStaticBuff(buff_id)
    end
end

function LakeExpCtrl:GetNextHangPos(scene_id, hang_pos)
    return self.data:GetNextHangPos(scene_id, hang_pos)
end

function LakeExpCtrl:ResetHangPos(scene_id)
    self.data:ResetHangPos(scene_id)
end

function LakeExpCtrl:GetKeepExp()
    return self.data:GetKeepExp()
end

function LakeExpCtrl:GetExtraExp(delta_exp)
    local keep_exp = self:GetKeepExp()
    local half_exp = math.floor(delta_exp * 0.5)
    if keep_exp >= half_exp then
        return half_exp
    else
        return keep_exp
    end
end

function LakeExpCtrl:GetPetExp()
    return self.data:GetPetExp()
end

function LakeExpCtrl:GetExtraPetExp(delta_exp)
    local keep_exp = self:GetPetExp()
    local half_exp = math.floor(delta_exp * 0.8)
    if keep_exp > half_exp then
        return half_exp
    else
        return keep_exp
    end
end

function LakeExpCtrl:CheckKeepExp()
    if self.check_keep_exp then
        return
    end
    local lake_exp_info = self.data:GetLakeExpInfo()
    if self.setting_ready and lake_exp_info then
        local is_active = game.SysSettingCtrl.instance:IsSettingActived(game.SysSettingKey.AutoUseKeepExp)
        if is_active and game.BagCtrl.instance:GetNumById(config.kill_mon_exp_info.item_id) == 0 and lake_exp_info.have_times > 0 then
            self:OpenKeepExpTipsView()
        end
        self.check_keep_exp = true
    end
end

function LakeExpCtrl:OnGetSettingInfo()
    self.setting_ready = true
    self:CheckKeepExp()
end

game.LakeExpCtrl = LakeExpCtrl

return LakeExpCtrl