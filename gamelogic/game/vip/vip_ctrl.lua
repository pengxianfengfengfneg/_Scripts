local VipCtrl = Class(game.BaseCtrl)

local handler = handler
local global_time = global.Time
local event_mgr = global.EventMgr
local config_func = config.func

function VipCtrl:_init()
    if VipCtrl.instance ~= nil then
        error("VipCtrl Init Twice!")
    end
    VipCtrl.instance = self

    self.data = require("game/vip/vip_data").New()
    self.view = require("game/vip/vip_view").New(self)

    self:Init()

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()
end

function VipCtrl:_delete()
    self.data:DeleteMe()
    self.view:DeleteMe()

    VipCtrl.instance = nil
end

function VipCtrl:Init()
    
end

function VipCtrl:RegisterAllEvents()
    local events = {
        {game.SceneEvent.CommonlyValueRespon, handler(self, self.OnCommonlyKeyValue)},
        {game.LoginEvent.LoginRoleRet, handler(self, self.OnLoginRoleRet)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function VipCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(10901, "OnGetVipInfoResp")
    self:RegisterProtocalCallback(10903, "OnGetVipGiftResp")
    self:RegisterProtocalCallback(10941, "OnGetRechargeInfoResp")
end

function VipCtrl:OnLoginRoleRet(val)
    if val then
        self:SendGetCaculateRecharge()
        self:SendGetCaculateRechargeMoney()
    end
end

function VipCtrl:OpenView(open_idx)
    self.view:Open(open_idx)
end

function VipCtrl:SendGetVipInfoReq()
    local proto = {

    }
    self:SendProtocal(10900, proto)
end

function VipCtrl:OnGetVipInfoResp(data)
    --[[
        "vip_level__C",
        "vip_exp__I",
        "got_gifts__T__level@C",
    ]]
    --PrintTable(data)
    self.data:OnGetVipInfoResp(data)
end

function VipCtrl:SendGetVipGiftReq(level)
    local proto = {
        level = level
    }
    self:SendProtocal(10902, proto)
    --PrintTable(proto)
end

function VipCtrl:OnGetVipGiftResp(data)
    --[[
        "ret__C",
    ]]
    --PrintTable(data)
    self.data:OnGetVipGiftResp(data)
end

function VipCtrl:SendGetRechargeInfoReq()
    local proto = {

    }
    self:SendProtocal(10940, proto)
end

function VipCtrl:OnGetRechargeInfoResp(data)
    --[[
        "today_recharge__I",
        "recharged_an__T__product_id@C",
        "recharged_ios__T__product_id@C",
    ]]

    -- PrintTable(data)
    self.data:OnGetRechargeInfoResp(data)

    self:FireEvent(game.VipEvent.UpdateRechargeInfo, data)
end

function VipCtrl:GetVipLevel()
    return self.data:GetVipLevel()
end

function VipCtrl:GetVipExp()
    return self.data:GetVipExp()
end

function VipCtrl:GetVipRewardState(vip_lv)
    return self.data:GetVipRewardState(vip_lv)
end

function VipCtrl:SendGetTodayRecharge()
    local proto = {
        key = 3
    }
    self:SendProtocal(10505, proto)
end

function VipCtrl:SendGetTodayRechargeMoney()
    local proto = {
        key = 4
    }
    self:SendProtocal(10505, proto)
end

function VipCtrl:SendGetCaculateRecharge()
    local proto = {
        key = game.CommonlyKey.CaculateRecharge
    }
    self:SendProtocal(10505, proto)
end

function VipCtrl:SendGetCaculateRechargeMoney()
    local proto = {
        key = game.CommonlyKey.CaculateRechargeMoney
    }
    self:SendProtocal(10505, proto)
end

function VipCtrl:OnCommonlyKeyValue(data)
    --PrintTable(data)
    self.data:OnCommonlyKeyValue(data)
end

function VipCtrl:HasDoneFirstRecharge(id)
    return self.data:HasDoneFirstRecharge(id)
end

function VipCtrl:GetTodayRechargeMoney()
    return self.data:GetTodayRechargeMoney()
end

function VipCtrl:GetCaculateRecharge()
    return self.data:GetCaculateRecharge()
end

function VipCtrl:GetCaculateRechargeMoney()
    return self.data:GetCaculateRechargeMoney()
end

game.VipCtrl = VipCtrl

return VipCtrl
