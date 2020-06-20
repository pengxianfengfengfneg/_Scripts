local VipData = Class(game.BaseData)


function VipData:_init()
   
end

function VipData:_delete()

end

function VipData:OnGetVipInfoResp(data)
	self.vip_lv = data.vip_level
	self.vip_exp = data.vip_exp
	self.vip_got_list = data.got_gifts

	self:FireEvent(game.VipEvent.UpdateVipInfo)
end

function VipData:OnGetVipGiftResp(data)
	if data.ret == 0 then
		table.insert(self.vip_got_list, {level = data.level})

		self:FireEvent(game.VipEvent.UpdateVipReward)
	end
end

function VipData:GetVipLevel()
	return self.vip_lv or 0
end

function VipData:GetVipExp()
	return self.vip_exp or 0
end

-- 0-不可领取 1-可领取 2-已领取
function VipData:GetVipRewardState(vip_lv)
	if vip_lv > self.vip_lv then
		return 0
	end

	local has_got = false
	for _,v in ipairs(self.vip_got_list or {}) do
		if vip_lv == v.level then
			has_got = true
			break
		end
	end

	if has_got then
		return 2
	end

	return 1
end

function VipData:OnGetRechargeInfoResp(data)
	self.today_recharge = data.today_recharge
	self.today_recharge_money = data.today_recharge_money
	self.recharged_an = data.recharged_an
	self.recharged_ios = data.recharged_ios

	game.VipCtrl.instance:SendGetCaculateRecharge()
	game.VipCtrl.instance:SendGetCaculateRechargeMoney()
end

function VipData:OnCommonlyKeyValue(data)
	local key,value = data.key, data.value
	self:UpdateTodayRecharge(data)
	self:UpdateTodayRechargeMoney(data)
	self:UpdateCaculateRecharge(data)
	self:UpdateCaculateRechargeMoney(data)
end

function VipData:UpdateTodayRecharge(data)
	if data.key ~= 3 then
		return
	end

	self.today_recharge = data.value
	self:FireEvent(game.VipEvent.UpdateTodayRecharge, self.today_recharge)
end

function VipData:UpdateTodayRechargeMoney(data)
	if data.key ~= 4 then
		return
	end

	self.today_recharge_money = data.value
	self:FireEvent(game.VipEvent.UpdateTodayRechargeMoney, self.today_recharge_money)
end

function VipData:UpdateCaculateRecharge(data)
	if data.key ~= game.CommonlyKey.CaculateRecharge then
		return
	end

	self.caculate_recharge = data.value
	self:FireEvent(game.VipEvent.UpdateCaculateRecharge, self.caculate_recharge)
end

function VipData:UpdateCaculateRechargeMoney(data)
	if data.key ~= game.CommonlyKey.CaculateRechargeMoney then
		return
	end

	self.caculate_recharge_money = data.value
	self:FireEvent(game.VipEvent.UpdateCaculateRechargeMoney, self.caculate_recharge_money)
end

function VipData:HasDoneFirstRecharge(id)
	local recharged_list = self.recharged_an
	if game.PlatformCtrl.instance:IsIosPlatform() then
		recharged_list = self.recharged_ios
	end

	for _,v in ipairs(recharged_list or {}) do
		if v.product_id == id then
			return true
		end
	end
	return false
end

function VipData:GetTodayRechargeMoney()
	return self.today_recharge_money or 0
end

function VipData:GetCaculateRecharge()
	return self.caculate_recharge or 0
end

function VipData:GetCaculateRechargeMoney()
	return self.caculate_recharge_money or 0
end


return VipData
