local ExteriorCtrl = Class(game.BaseCtrl)

function ExteriorCtrl:_init()
	if ExteriorCtrl.instance ~= nil then
		error("ExteriorCtrl Init Twice!")
	end
	ExteriorCtrl.instance = self
	
	self.data = require("game/exterior/exterior_data").New(self)
    self.view = require("game/exterior/exterior_view").New(self)
    self.mount_setting_view = require("game/exterior/mount_setting_view").New(self)
    self.fashion_setting_view = require("game/exterior/fashion_setting_view").New(self)
    self.fashion_dye_view = require("game/exterior/fashion_dye_view").New(self)

    self.action_setting_view = require("game/exterior/action_setting_view").New(self)
    self.frame_setting_view = require("game/exterior/frame_setting_view").New(self)
    self.bubble_setting_view = require("game/exterior/bubble_setting_view").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()
end

function ExteriorCtrl:_delete()
    self.data:DeleteMe()
    self.view:DeleteMe()
    self.mount_setting_view:DeleteMe()
    self.fashion_dye_view:DeleteMe()
    self.fashion_setting_view:DeleteMe()

    self.action_setting_view:DeleteMe()
    self.frame_setting_view:DeleteMe()
    self.bubble_setting_view:DeleteMe()

	ExteriorCtrl.instance = nil
end

function ExteriorCtrl:RegisterAllProtocal()
	local proto = {
        [52502] = "OnExteriorMountInfo",
        [52504] = "OnExteriorMountOpe",
        [52506] = "OnExteriorMountChoose",

        [52531] = "OnActionInfo",
        [52533] = "OnActionUse",
        [52534] = "OnActionInvite",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function ExteriorCtrl:RegisterAllEvents()
    local events = {
        {game.SceneEvent.CommonlyValueRespon, handler(self, self.OnCommonlyValue)},
        {game.LoginEvent.LoginRoleRet, handler(self, self.OnLoginRoleRet)},
    }
    for _, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ExteriorCtrl:PrintTable(tbl)
    if self.log_enable then
        PrintTable(tbl)
    end
end

function ExteriorCtrl:OpenView(index)
    self.view:Open(index)
end

function ExteriorCtrl:RefreshViewTips()
    if self.view:IsOpen() then
        self.view:SetTips()
    end
end

function ExteriorCtrl:OpenMountSettingView()
    self.mount_setting_view:Open()
end

function ExteriorCtrl:OnCommonlyValue(data)
    if data.key == game.CommonlyKey.MountSetting then
        self.data:SetMountSettingValue(data.value, true)
    end
end

function ExteriorCtrl:OnLoginRoleRet(val)
    if val then
        game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.MountSetting)
        self:SendExteriorMountInfo()
    end
end

function ExteriorCtrl:SendExteriorMountInfo()
    self:SendProtocal(52501)
end

function ExteriorCtrl:OnExteriorMountInfo(data)
    --[[
        "active_list__T__id@C##expire_time@I",
    ]]
    self:PrintTable(data)
    self.data:SetMountInfo(data.active_list)
end

-- 操作坐骑
function ExteriorCtrl:SendExteriorMountOpe()
    self:SendProtocal(52503)
end

-- 选择坐骑
function ExteriorCtrl:SendExteriorMountChoose(id)
    --[[
        "id__C",
    ]]
    self:SendProtocal(52505, {id = id})
end

function ExteriorCtrl:OnExteriorMountChoose(data)
    --[[
        "id__C",
    ]]
    self:PrintTable(data)
    self:FireEvent(game.ExteriorEvent.OnExteriorMountChoose, data.id)
end

function ExteriorCtrl:GetMountSortList()
    return self.data:GetMountSortList()
end

function ExteriorCtrl:GetMountSettingValue()
    return self.data:GetMountSettingValue()
end

function ExteriorCtrl:SetMountSettingValue(val, server)
    self.data:SetMountSettingValue(val, server)
end

function ExteriorCtrl:GetMountSettingKey()
    return self.data.MountSettingKey
end

function ExteriorCtrl:OpenFashionDyeView()
    local fashion_cfg = {}
    for _, v in pairs(config.fashion or {}) do
        if #v.colors > 1 and game.FashionCtrl.instance:IsFashionActived(v.id) then
            table.insert(fashion_cfg, v)
        end
    end
    if #fashion_cfg > 0 then
        self.fashion_dye_view:Open()
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[2013])
    end
end

function ExteriorCtrl:CloseView()
    self.view:Close()
end

function ExteriorCtrl:GetFashionSettingValue()
    return self.data:GetFashionSettingValue()
end

function ExteriorCtrl:SetFashionSettingValue(val)
    self.data:SetFashionSettingValue(val)
end

function ExteriorCtrl:SetActionSettingValue(val)
    self.data:SetActionSettingValue(val)
end

function ExteriorCtrl:GetActionSettingValue()
    return self.data:GetActionSettingValue()
end

function ExteriorCtrl:SetFrameSettingValue(val)
    self.data:SetFrameSettingValue(val)
end

function ExteriorCtrl:GetFrameSettingValue()
    return self.data:GetFrameSettingValue()
end

function ExteriorCtrl:SetBubbleSettingValue(val)
    self.data:SetBubbleSettingValue(val)
end

function ExteriorCtrl:GetBubbleSettingValue()
    return self.data:GetBubbleSettingValue()
end

function ExteriorCtrl:GetFashionSettingKey()
    return self.data:GetExteriorSettingKey()
end

function ExteriorCtrl:GetExteriorSettingKey()
    return self.data:GetExteriorSettingKey()
end

function ExteriorCtrl:OpenFashionSettingView()
    self.fashion_setting_view:Open()
end

function ExteriorCtrl:OpenActionSettingView()
    self.action_setting_view:Open()
end

function ExteriorCtrl:OpenFrameSettingView()
    self.frame_setting_view:Open()
end

function ExteriorCtrl:OpenBubbleSettingView()
    self.bubble_setting_view:Open()
end

function ExteriorCtrl:SendActionInfo()
    self:SendProtocal(52530)
end

function ExteriorCtrl:OnActionInfo(data)
    self.data:SetActionInfo(data.active_list)
    self.data:SetActionSingleTime(data.single_time)
    self.data:SetActionCoupleTime(data.coupe_time)
end

function ExteriorCtrl:GetActionState(id)
    return self.data:GetActionState(id)
end

function ExteriorCtrl:SendActionUse(role_id, id)
    self:SendProtocal(52532, { be_invited_id = role_id, id = id })
end

function ExteriorCtrl:OnActionUse(data)
    self.data:SetActionSingleTime(data.single_time)
    self.data:SetActionCoupleTime(data.coupe_time)
end

function ExteriorCtrl:GetActionSingleTime()
    return self.data:GetActionSingleTime()
end

function ExteriorCtrl:GetActionCoupleTime()
    return self.data:GetActionCoupleTime()
end

function ExteriorCtrl:OnActionInvite(data)
    local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(string.format(config.words[2012], data.sender, config.exterior_action[data.id].name))
    tips_view:SetBtn1(nil, function()
        game.ViewMgr:CloseAllView()
        self:SendActionInviteResponse(data.invite_id, 1)
    end)
    tips_view:SetBtn2(config.words[101], function()
        self:SendActionInviteResponse(data.invite_id, 2)
    end)
    tips_view:Open()
end

function ExteriorCtrl:SendActionInviteResponse(id, type)
    self:SendProtocal(52535, {invited_id = id, res = type})
end

function ExteriorCtrl:IsExpireMount(id)
    return self.data:IsExpireMount(id)
end

function ExteriorCtrl:GetTipState()
    return self.data:GetActionTips() or game.FashionCtrl.instance:GetAllFashionNewActionState()
end

function ExteriorCtrl:GetActionTips()
    return self.data:GetActionTips()
end

function ExteriorCtrl:SetActionTips(val)
    self.data:SetActionTips(val)
end

game.ExteriorCtrl = ExteriorCtrl

return ExteriorCtrl