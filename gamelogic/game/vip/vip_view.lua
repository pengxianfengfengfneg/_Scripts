local VipView = Class(game.BaseView)

local handler = handler

function VipView:_init(ctrl)
	self._package_name = "ui_vip"
    self._com_name = "vip_view"

    self._show_money = true

	self._view_level = game.UIViewLevel.First

	self.ctrl = ctrl
end

function VipView:OpenViewCallBack()
	self:Init()
	self:InitBtns()
	self:InitBg()
	self:InitMoney()

	self:UpdateVipShow(self.cur_show_vip_lv)

	self:RegisterAllEvents()
end

function VipView:CloseViewCallBack()
	self:ClearReards()
end

function VipView:RegisterAllEvents()
	local events = {
		{game.VipEvent.UpdateVipInfo, handler(self, self.OnUpdateVipInfo)},
		{game.VipEvent.UpdateVipReward, handler(self, self.OnUpdateVipReward)},
		{game.VipEvent.UpdateTodayRecharge, handler(self, self.OnUpdateTodayRecharge)},
		{game.VipEvent.UpdateCaculateRecharge, handler(self, self.OnUpdateCaculateRecharge)},

	}
	for _,v in ipairs(events) do
		self:BindEvent(v[1], v[2])
	end
end

function VipView:Init()
	self.cur_show_vip_lv = self.ctrl:GetVipLevel()

	self.img_vip_bg = self._layout_objs["img_vip_bg"]
	self.img_vip = self._layout_objs["img_vip"]
	self.bar_vip = self._layout_objs["bar_vip"]
	self.img_vip_left = self._layout_objs["img_vip_left"]
	self.img_vip_right = self._layout_objs["img_vip_right"]
	self.rtx_up_recharge = self._layout_objs["rtx_up_recharge"]
	self.txt_vip_privileges = self._layout_objs["txt_vip_privileges"]

	self.list_rewards = self._layout_objs["list_rewards"]

	self.img_get_flag = self._layout_objs["img_get_flag"]
	self.btn_get = self._layout_objs["btn_get"]
	self.btn_recharge = self._layout_objs["btn_recharge"]

	self.img_vip_left:SetSprite("ui_main", "VIP_" .. self.cur_show_vip_lv)
	self.img_vip_right:SetSprite("ui_main", "VIP_" .. (self.cur_show_vip_lv+1))

	self:OnUpdateVipInfo()
	self:UpdateVipReward(self.cur_show_vip_lv)
end

function VipView:InitBtns()
	self.btn_recharge:AddClickCallBack(function()
		self.ctrl:OpenRechargeView()
	end)
	
	self.btn_get:AddClickCallBack(function()
		self.ctrl:SendGetVipGiftReq(self.cur_show_vip_lv)
	end)

	self.btn_left = self._layout_objs["btn_left"]
	self.btn_left:AddClickCallBack(function()
		self.cur_show_vip_lv = math.max(self.cur_show_vip_lv - 1, 1)
		self:UpdateVipShow(self.cur_show_vip_lv)
	end)

	self.btn_right = self._layout_objs["btn_right"]
	self.btn_right:AddClickCallBack(function()
		self.cur_show_vip_lv = math.min(self.cur_show_vip_lv + 1, 15)
		self:UpdateVipShow(self.cur_show_vip_lv)
	end)
end

function VipView:UpdateVipBg(vip_lv)
	local boundle_name = "ui_vip.ab"
	local asset_name = "bg" .. vip_lv
	--self.img_vip_bg:SetSprite(boundle_name, asset_name)

	self.img_vip:SetSprite("ui_vip", "v" .. vip_lv)
end

function VipView:UpdatePrivileges(vip_lv)
	local vip_cfg = config.vip[vip_lv] or {}
	local vip_desc = vip_cfg.desc or ""
	local desc_tb = string.split(vip_desc, "|")
	for i=1,7 do
		local txt = self._layout_objs["txt_privileges_" .. i]
		if txt then
			local str = desc_tb[i]
			txt:SetVisible(str~=nil)

			if str then
				txt:SetText(str)
			end
		end
	end

	self.txt_vip_privileges:SetText(string.format(config.words[2800], vip_lv))
end

function VipView:InitBg()
    local template = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1661]):HideBtnWh()
end

function VipView:InitMoney()
	
end

function VipView:UpdateRewards(vip_lv)
	local vip_cfg = config.vip[vip_lv] or {}
	local drop_id = vip_cfg.gift
	local drop_cfg = config.drop[drop_id] or {}
	local drop_goods = drop_cfg.client_goods_list or {}

	local item_num = #drop_goods
	if item_num <= 0 then
		return
	end

	self.list_rewards:SetItemNum(item_num)

	self:ClearReards()
	for i=1,item_num do
		local info = drop_goods[i]
		local obj = self.list_rewards:GetChildAt(i-1)
		local item = game_help.GetGoodsItem(obj, true)
		info = {
			id = info[1],
			num = info[2]
		}
		item:SetItemInfo(info)
		table.insert(self.rewards_tb, item)
	end
end

function VipView:ClearReards()
	for _,v in ipairs(self.rewards_tb or {}) do
		v:DeleteMe()
	end
	self.rewards_tb = {}
end

function VipView:UpdateVipShow(vip_lv)
	self.btn_left:SetVisible(vip_lv>1)
	self.btn_right:SetVisible(vip_lv<15)

	self:UpdateVipBg(vip_lv)
	self:UpdatePrivileges(vip_lv)
	self:UpdateRewards(vip_lv)
	self:UpdateVipReward(vip_lv)

	print("vip_lv XXXX", vip_lv)
end

function VipView:OnUpdateVipInfo()
	local vip_lv = self.ctrl:GetVipLevel()
	local vip_exp = self.ctrl:GetVipExp()
	local next_vip_lv = vip_lv + 1

	self.img_vip:SetSprite("ui_vip", "v" .. vip_lv)
	self.img_vip_left:SetSprite("ui_main", "VIP_" .. vip_lv)
	self.img_vip_right:SetSprite("ui_main", "VIP_" .. next_vip_lv)

	local next_vip_cfg = config.vip[next_vip_lv] or {}
	local next_exp = next_vip_cfg.exp

	local str_desc = config.words[2802]
	if next_exp then
		str_desc = string.format(config.words[2801], next_exp-vip_exp, next_vip_lv)
	end

	self.rtx_up_recharge:SetText(str_desc)

	local percent = (vip_exp/next_exp)*100
	self.bar_vip:SetProgressValue(percent)
end

function VipView:OnUpdateVipReward()

	self:UpdateVipReward(self.cur_show_vip_lv)
end

function VipView:UpdateVipReward(vip_lv)
	local state = self.ctrl:GetVipRewardState(vip_lv)
	self.btn_get:SetGray(state~=1)
	self.btn_get:SetVisible(state~=2)

	self.img_get_flag:SetVisible(state==2)
end

function VipView:OnUpdateTodayRecharge(recharge)
	
end

function VipView:OnUpdateCaculateRecharge(recharge)
	
end

return VipView
