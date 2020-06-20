local RechargeCtrl = Class(game.BaseCtrl)

function RechargeCtrl:_init()
	if RechargeCtrl.instance ~= nil then
		error("RechargeCtrl Init Twice!")
	end
	RechargeCtrl.instance = self
	
	self.data = require("game/recharge/recharge_data").New(self)
    self.view = require("game/recharge/recharge_view").New(self)
    self.roraty_view = require("game/recharge/recharge_roraty_view").New(self)
    self.first_recharge_view = require("game/recharge/recharge_first_view").New(self)

	self:RegisterAllProtocal()
end

function RechargeCtrl:_delete()
    self.data:DeleteMe()
    self.view:DeleteMe()
    self.roraty_view:DeleteMe()
    self.first_recharge_view:DeleteMe()

	RechargeCtrl.instance = nil
end

function RechargeCtrl:RegisterAllProtocal()
	local proto = {
        [52902] = "OnChargeConsumeInfo",
        [52904] = "OnChargeConsumeGetCharge",
        [52906] = "OnChargeConsumeGetConsume",
        [52907] = "OnChargeConsumeChange",
        [52909] = "OnChargeConsumeRoraty",
        [52910] = "OnChargeConsumeFlagChange",
        [52913] = "OnChargeConsumeRoratyGet",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function RechargeCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, handler(self, self.OnLoginSuccess)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function RechargeCtrl:PrintTable(tbl)
    if self.log_enable then
        PrintTable(tbl)
    end
end

function RechargeCtrl:print(tbl)
    if self.log_enable then
        print(tbl)
    end
end

function RechargeCtrl:OnLoginSuccess()
    self.ctrl:SendChargeConsumeInfo()
end

function RechargeCtrl:OpenView(open_idx)
    self.view:Open(open_idx)
end

function RechargeCtrl:OpenRoratyView()
    self.roraty_view:Open()
end

function RechargeCtrl:OpenFirstRechargeView()
    self.first_recharge_view:Open()
end

-- 信息
function RechargeCtrl:SendChargeConsumeInfo()
    self:SendProtocal(52901)
end

function RechargeCtrl:OnChargeConsumeInfo(data)
    --[[
        "charge_got_list__T__id@C",    -- 充值礼包已领取列表
        "weekly_consume__I",           -- 周消费元宝
        "consume_got_list__T__id@C",   -- 每周回馈已领取列表
        "flag__C",                     -- 是否首冲标识 0:没有|1:有首冲|2:已领取奖励
        "leave_times__C"               -- 已抽奖次数",
        "leave_ids__T__id@C"           -- 转盘未抽取到列表"
        "index__C"                     -- 转盘已抽取ID"
    ]]
    self:PrintTable(data)
    self.data:SetChargeConsumeInfo(data)
end

-- 领取充值礼包
function RechargeCtrl:SendChargeConsumeGetCharge(id)
    --[[
        "id__C",                       
    ]]
    self:SendProtocal(52903, {id = id})
end

function RechargeCtrl:OnChargeConsumeGetCharge(data)
    --[[
        "id__C",                       
    ]]
    self:PrintTable(data)
    self.data:GetCharge(data.id)
end

-- 领取周消费奖励
function RechargeCtrl:SendChargeConsumeGetConsume(id)
    --[[
        "id__C",                       
    ]]
    self:SendProtocal(52905, {id = id})
end

function RechargeCtrl:OnChargeConsumeGetConsume(data)
    --[[
        "id__C",                       
    ]]
    self:PrintTable(data)
    self.data:GetConsume(data.id)
end

-- 转盘抽奖
function RechargeCtrl:SendChargeConsumeRoraty()
    self:SendProtocal(52908)
end

function RechargeCtrl:OnChargeConsumeRoraty(data)
    --[[
        "id__C",
        "leave_times__C",                    
    ]]
    self:PrintTable(data)
    self.data:OnChargeConsumeRoraty(data)
end

-- 转盘领奖
function RechargeCtrl:SendChargeConsumeRoratyGet()
    self:SendProtocal(52912)
end

function RechargeCtrl:OnChargeConsumeRoratyGet(data)
    --[[
        "id__C",                     
    ]]
    self:PrintTable(data)
    self.data:OnChargeConsumeRoratyGet(data)
end

-- 领取首冲奖励(返回52910)
function RechargeCtrl:SendChargeConsumeFirstReward()
    self:SendProtocal(52911)
end

-- 周消费变化
function RechargeCtrl:OnChargeConsumeChange(data)
    --[[
        "weekly_consume__I",           -- 周消费元宝
    ]]
    self:PrintTable(data)
    self.data:OnChargeConsumeChange(data)
end

-- 首冲标识变化
function RechargeCtrl:OnChargeConsumeFlagChange(data)
    --[[
        "flag__C",                     
    ]]
    self:PrintTable(data)
    self.data:OnChargeConsumeFlagChange(data)
end

function RechargeCtrl:GetChargeConsumeInfo()
    return self.data:GetChargeConsumeInfo()
end

function RechargeCtrl:GetFlag()
    return self.data:GetFlag()
end

function RechargeCtrl:GetChargeGiftState(id)
    return self.data:GetChargeGiftState(id)
end

function RechargeCtrl:GetWeekRewardState(id)
    return self.data:GetWeekRewardState(id)
end

function RechargeCtrl:GetWeeklyConsume()
    return self.data:GetWeeklyConsume()
end

function RechargeCtrl:CanRoraty(id)
    return self.data:CanRoraty(id)
end

function RechargeCtrl:CheckShowFirstRecharge()
    return self.data:CheckShowFirstRecharge()
end

function RechargeCtrl:GetRoratyTimes()
    return self.data:GetRoratyTimes()
end

function RechargeCtrl:CheckGiftRed()
    return self.data:CheckGiftRed()
end

function RechargeCtrl:CheckWeekRed()
    return self.data:CheckWeekRed()
end

function RechargeCtrl:GetRoratyIndex()
    return self.data:GetRoratyIndex()
end

function RechargeCtrl:Recharge(id)
    if game.SDKMgr:GetSDKTag() == "" then
        local gm_ctrl = game.GmCtrl.instance
        gm_ctrl:SendGmRequest(string.format("recharge_%s", id))
    else
        local cfg = config.recharge[id]
        if cfg then
            if game.Platform == "android" then
                --game.SDKMgr:RequestPay(cfg.product_id, cfg.product_name, cfg.rmb)
            elseif game.Platform == "ios" then

            end
        end
    end
end

game.RechargeCtrl = RechargeCtrl

return RechargeCtrl