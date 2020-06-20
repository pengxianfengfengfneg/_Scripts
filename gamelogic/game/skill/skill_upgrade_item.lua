local SkillUpgradeItem = Class(game.UITemplate)

local config_skill = config.skill
local config_hero_effect = config.hero_effect

local GetSkillCfg = config_help.ConfigHelpSkill.GetSkillCfg

function SkillUpgradeItem:_init(view)
    self.ctrl = game.SkillCtrl.instance
    
    self.parent_view = view
end

function SkillUpgradeItem:OpenViewCallBack()
	self:Init()
	self:InitBtns()
	--self:InitSkillItems()

	--self:RegisterAllEvents()
end

function SkillUpgradeItem:CloseViewCallBack()
   	if self.local_skill_item then
   		self.local_skill_item:DeleteMe()
   		self.local_skill_item = nil
   	end
end

function SkillUpgradeItem:RegisterAllEvents()
    local events = {
    	{game.SkillEvent.SkillUpgrade, handler(self, self.OnSkillUpgrade)},
    	{game.SkillEvent.SkillOneKeyUp, handler(self, self.OnSkillOneKeyUp)},
    	{game.HeroEvent.GuideChange, handler(self, self.OnGuideChange)},
    	{game.HeroEvent.HeroUseGuide, handler(self, self.OnHeroUseGuide)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SkillUpgradeItem:Init()
	self.txt_cost_one = self._layout_objs["txt_cost_one"]
	self.txt_cost_all = self._layout_objs["txt_cost_all"]

	self.txt_skill_name = self._layout_objs["txt_skill_name"]
	self.txt_skill_desc = self._layout_objs["txt_skill_desc"]

	self.txt_skill_type = self._layout_objs["txt_skill_type"]
	self.txt_skill_dist = self._layout_objs["txt_skill_dist"]
	self.txt_skill_cd = self._layout_objs["txt_skill_cd"]
	self.txt_skill_energy = self._layout_objs["txt_skill_energy"]

	self.local_skill_item = require("game/skill/item/skill_item_circle").New()
	self.local_skill_item:SetVirtual(self._layout_objs["skill_item"])
	self.local_skill_item:Open()
end

function SkillUpgradeItem:InitBtns()
	self.one_up_cost = 0
	self.one_key_cost = 0
	
	self.btn_upgrade = self._layout_objs["btn_upgrade"]
	self.btn_upgrade:AddClickCallBack(function()
		local skill_id = self.cur_skill_item:GetSkillId()
		local skill_lv = self.cur_skill_item:GetSkillLv()
		if self:CanSkillUpgrade(skill_id,skill_lv) then
			self.ctrl:SendSkillUpgrade(skill_id)
		else
			if self.one_up_cost > 0 then
				game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, self.one_up_cost, function()
					self.ctrl:SendSkillUpgrade(skill_id)
				end)
			end
		end
		game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_skill/skill_view/skill_template/skill_upgrade_item/btn_upgrade"})
		game.ViewMgr:FireGuideEvent()
	end)
	
	self.btn_onekey = self._layout_objs["btn_onekey"]
	self.btn_onekey:AddClickCallBack(function()
		if self:CanSkillOneKeyUpgrade() then
			self.ctrl:SendSkillOneKeyUp()
		else
			if self.one_key_cost > 0 then
				game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, self.one_key_cost, function()
					self.ctrl:SendSkillOneKeyUp()
				end)
			end
		end
	end)

	self:RegisterRedPoint(self.btn_onekey, game.OpenFuncId.RoleSkill)
end

function SkillUpgradeItem:OnSkillOneKeyUp(skill_list)
	for _,v in ipairs(skill_list) do
		local skill_item = self.skill_item_list[v.id]
		if skill_item then
			skill_item:SetItemInfo(v)
			skill_item:PlayEffect("jn_shengji", 1 / 1.45)
		else
			print("v.id XXXXXXXXXXXXXXXXXXXX", v.id)
		end
	end

	self:CheckSkillUpgrade()

	self:UpdateOneCost()
	self:UpdateAllCost()
end

function SkillUpgradeItem:CheckSkillUpgrade()
	local cur_copper = game.BagCtrl.instance:GetCopper()
	for _,v in pairs(self.skill_item_list or {}) do
		local skill_id = v:GetSkillId()
		local skill_lv = v:GetSkillLv()
		local open_lv = v:GetOpenLv()
		local upgrade_cost = v:GetCost()

		v:SetShowLockMask(skill_lv<=0, open_lv)
		v:SetShowLv(skill_lv>0, skill_lv)
		v:SetShowLvUp(self.ctrl:CanSkillUpgrade(skill_id, skill_lv))
	end
end

function SkillUpgradeItem:UpdateOneCost()
	local cost = self.cur_skill_item:GetCost()

	self.one_up_cost = cost
	self.txt_cost_one:SetText(cost)
end

function SkillUpgradeItem:UpdateAllCost()
	local all_cost = self.ctrl:GetAllActiveSkillCost()
	self.one_key_cost = all_cost

	if all_cost <= 0 then
		all_cost = config.words[2201]
	end

	self.txt_cost_all:SetText(all_cost)
end

function SkillUpgradeItem:CanSkillUpgrade(skill_id,skill_lv)
	local is_can,res = self.ctrl:CanSkillUpgrade(skill_id,skill_lv)
	if not is_can then
		local word_id = (res==1 and 2202 or 2203)
		game.GameMsgCtrl.instance:PushMsg(config.words[word_id])
	end
	return is_can
end

function SkillUpgradeItem:CanSkillOneKeyUpgrade()
	local all_cost = self.ctrl:GetAllActiveSkillCost()
	if all_cost <= 0 then
		game.GameMsgCtrl.instance:PushMsg(config.words[2204])
		return false
	end

	local is_can,res = self.ctrl:CanSkillUpgradeAny()
	if not is_can then
		local word_id = (res==1 and 2205 or 2203)
		game.GameMsgCtrl.instance:PushMsg(config.words[word_id])
		return false
	end

	return true
end

function SkillUpgradeItem:OnActived(val)
	
end

function SkillUpgradeItem:OnClickSkillItem(skill_item)
	self:UpdateSkill(skill_item)
end

function SkillUpgradeItem:OnSkillUpgrade(skill_item)
	self:UpdateSkill(skill_item)
end

function SkillUpgradeItem:UpdateHeroGuide(skill_item)
	-- local skill_id = skill_item:GetSkillId()
	-- local skill_lv = math.max(skill_item:GetSkillLv(),1)
	-- local hero_id = skill_item:GetSkillHeroId()
	-- local legend = skill_item:GetSkillLegend()

	-- local desc = GetSkillCfg(skill_id, skill_lv, hero_id, legend, "desc")
	-- self.txt_skill_desc:SetText(desc)

	self:UpdateSkill(skill_item)
end

local skill_info = {
	id = 0,
	lv = 0,
	heor = 0,
	legend = 0,
}
function SkillUpgradeItem:UpdateSkill(skill_item)
	local skill_id = skill_item:GetSkillId()
	local skill_lv = math.max(skill_item:GetSkillLv(),1)
	local hero_id = skill_item:GetSkillHeroId()
	local legend = skill_item:GetSkillLegend()

	local name = GetSkillCfg(skill_id, skill_lv, hero_id, legend, "name")
	self.txt_skill_name:SetText(name)

	local desc = GetSkillCfg(skill_id, skill_lv, hero_id, legend, "desc")
	self.txt_skill_desc:SetText(desc)

	local dist = GetSkillCfg(skill_id, skill_lv, hero_id, legend, "dist")
	local mp = GetSkillCfg(skill_id, skill_lv, hero_id, legend, "mp")
	local cd = GetSkillCfg(skill_id, skill_lv, hero_id, legend, "cd")
	local pre_time = GetSkillCfg(skill_id, skill_lv, hero_id, legend, "pre_time")
	local progress_time = GetSkillCfg(skill_id, skill_lv, hero_id, legend, "progress_time")

	local word_id = (pre_time==0 and 2216 or 2217)
	if progress_time > 0 then
		word_id = 2227
	end
	self.txt_skill_type:SetText(config.words[word_id])

	local cd_time = cd * 0.001
	local cd_int,cd_float = math.modf(cd_time)
	local word_id = (cd_float>0 and 2218 or 2225)
	self.txt_skill_cd:SetText(string.format(config.words[word_id], cd_time))

	self.txt_skill_energy:SetText(mp)

	local skill_dist = dist*0.5
	local dist_int,dist_float = math.modf(skill_dist)	
	local word_id = (dist_float>0 and 2219 or 2226)
	self.txt_skill_dist:SetText(string.format(config.words[word_id], skill_dist))

	self.cur_skill_item = skill_item

	skill_info.id = skill_id
	skill_info.lv = skill_lv
	skill_info.hero = hero_id
	skill_info.legend = legend
	self.local_skill_item:SetItemInfo(skill_info)

	self:UpdateOneCost()
	self:UpdateAllCost()
end

function SkillUpgradeItem:CheckRedPoint(is_red)
	--game_help.SetRedPoint(self.btn_onekey, is_red, 0)
end

return SkillUpgradeItem
