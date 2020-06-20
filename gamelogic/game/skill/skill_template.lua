local SkillTemplate = Class(game.UITemplate)

local config_skill = config.skill
local config_hero_effect = config.hero_effect

local PageConfig = {
    {
        item_path = "skill_upgrade_item",
        item_class = "game/skill/skill_upgrade_item",
        check_red_func = function()
            return game.SkillCtrl.instance:CheckSkillUpgradeRedPoint()
        end,
        check_open_func = function()
        	return true
        end,
        check_open_tips = function()

        end,
    },    
    {
        item_path = "skill_guide_item",
        item_class = "game/skill/skill_guide_item",
        check_red_func = function()
            return game.SkillCtrl.instance:CheckSkillGuideRedPoint()
        end,
        check_open_func = function()
        	return game.SkillCtrl.instance:CheckSkillGuideOpen()
        end,
        check_open_tips = function()
        	local cfg = config.func[game.OpenFuncId.HeroGuide]
        	local open_lv = cfg.open_cond[1][2]
        	local tips = string.format(config.words[2229], cfg.name, open_lv)
        	game.GameMsgCtrl.instance:PushMsg(tips)
        end,
    },
}

function SkillTemplate:_init(view)
    self.ctrl = game.SkillCtrl.instance
    
    self.parent_view = view
end

function SkillTemplate:OpenViewCallBack()
	self:Init()
	self:InitTemplate()
	self:InitSkillItems()
	self:InitController()
	
	self:RegisterAllEvents()
end

function SkillTemplate:CloseViewCallBack()
	self:ClearHeroRedPoint()
	self:ClearGuideRedPoint()

   	for _,v in pairs(self.skill_item_list or {}) do
   		v:DeleteMe()
   	end
   	self.skill_item_list = {}
end

function SkillTemplate:RegisterAllEvents()
    
end

function SkillTemplate:Init()
	self.btn_skill_setting = self._layout_objs["btn_skill_setting"]	
	self.btn_skill_setting:AddClickCallBack(function()
		self.ctrl:OpenSkillSettingView()
	end)

	self.list_tab = self._layout_objs["list_tab"]	
	
	local career = game.Scene.instance:GetMainRoleCareer()
	local cfg = config.career_init[career]
	self.txt_main_attr_desc = self._layout_objs["txt_main_attr_desc"]	
	self.txt_main_attr = self._layout_objs["txt_main_attr"]	

	self.txt_main_attr_desc:SetText(string.format(config.words[2220],cfg.name))
	self.txt_main_attr:SetText(cfg.element)

	local effect = self:CreateUIEffect(self._layout_objs["effect_node"], "effect/ui/jn_sjcz.ab", 10)
	effect:SetLoop(true)
end

function SkillTemplate:InitTemplate()
	for k,v in ipairs(PageConfig) do
        v.page_item = self:GetTemplate(v.item_class, v.item_path, v.check_red_func)
    end
end

function SkillTemplate:InitController()
	self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
		self:OnClickTab(idx+1)
	end)

	self.tab_controller:SetSelectedIndexEx(0)
end

function SkillTemplate:InitSkillItems()
	self.skill_item_list = {}
	local item_class = require("game/skill/item/skill_item_circle")

	local default_item = nil
	local career = game.RoleCtrl.instance:GetCareer()
	local career_cfg = config.skill_career[career] or {}
	table.sort(career_cfg,function(v1,v2)
		return v1.index<v2.index
	end)

	for k,v in ipairs(career_cfg or {}) do
		local item_obj = self._layout_objs["skill_item_" .. k]
		if not item_obj then
			break
		end

		local info = {
			id = v.skill_id,
			lv = self.ctrl:GetSkillLv(v.skill_id),
			open_lv = v.open_lv,
			show_lv = true,
			hero = self.ctrl:GetSkillHeroId(v.skill_id),
			legend = self.ctrl:GetSkillLegend(v.skill_id)
		}
		local skill_item = item_class.New()
		skill_item:SetVirtual(item_obj)
		skill_item:Open()
		skill_item:SetItemInfo(info)
		skill_item:AddClickEvent(function(item)
			self:OnClickSkillItem(item)
		end)

		if k == 1 then
			default_item = skill_item
		end

		self.skill_item_list[info.id] = skill_item
	end

	self:OnClickSkillItem(default_item)
	self:CheckSkillUpgrade()
end

function SkillTemplate:OnClickSkillItem(skill_item)
	for _,v in pairs(self.skill_item_list or {}) do
		v:DoSelected(v==skill_item)
	end

	-- local skill_id = skill_item:GetSkillId()
	-- local skill_lv = math.max(skill_item:GetSkillLv(),1)
	-- local hero_id = skill_item:GetSkillHeroId()
	-- local legend = skill_item:GetSkillLegend()

	-- local name = config_help.ConfigHelpSkill.GetSkillCfg(skill_id, skill_lv, hero_id, legend, "name")
	-- self.txt_skill_name:SetText(name)

	self.cur_skill_item = skill_item

	-- self:UpdateOneCost()

	self:UpdateHeroGuide(skill_item, true)

	for _,v in ipairs(PageConfig) do
		v.page_item:OnClickSkillItem(skill_item)
	end
end

function SkillTemplate:OnSkillUpgrade(skill_id, skill_lv)
	local skill_item = self.skill_item_list[skill_id]
	local info = skill_item:GetItemInfo()
	info.lv = skill_lv

	skill_item:SetItemInfo(info)
	skill_item:PlayEffect("jn_shengji", 1 / 1.45)

	self:CheckSkillUpgrade()

	for _,v in ipairs(PageConfig) do
		v.page_item:OnSkillUpgrade(skill_item)
	end
end

function SkillTemplate:OnSkillOneKeyUp(skill_list)
	for _,v in ipairs(skill_list) do
		local skill_item = self.skill_item_list[v.id]
		if skill_item then
			if skill_item == self.cur_skill_item then
				for _,cv in ipairs(PageConfig) do
					cv.page_item:OnSkillUpgrade(skill_item)
				end
			end

			v.hero = skill_item:GetSkillHeroId()
			v.legend = skill_item:GetSkillLegend()

			skill_item:SetItemInfo(v)
			skill_item:PlayEffect("jn_shengji", 1 / 1.45)		
		end
	end

	self:CheckSkillUpgrade()
end

function SkillTemplate:CheckSkillUpgrade()
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

function SkillTemplate:CanSkillUpgrade(skill_id,skill_lv)
	local is_can,res = self.ctrl:CanSkillUpgrade(skill_id,skill_lv)
	if not is_can then
		local word_id = (res==1 and 2202 or 2203)
		game.GameMsgCtrl.instance:PushMsg(config.words[word_id])
	end
	return is_can
end

function SkillTemplate:CanSkillOneKeyUpgrade()
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

function SkillTemplate:OnActived(val)
	
end

function SkillTemplate:UpdateHeroGuide(skill_item, is_click)
	if not is_click then
		for _,v in ipairs(PageConfig) do
			v.page_item:UpdateHeroGuide(skill_item, is_click)
		end
	end

	if not is_click then	
		self:CheckHeroRedPoint(self.cur_tab_idx)
	end
end

function SkillTemplate:OnGuideChange(data)
	local item = self.skill_item_list[data.skill]
	if item then
		local info = item:GetItemInfo()
		info.hero = data.id
		info.legend = data.legend

		self:UpdateHeroGuide(item)
	end
end

function SkillTemplate:OnHeroUseGuide(skill_list, guide_id)
	for _,v in ipairs(skill_list or {}) do
		local item = self.skill_item_list[v.id]
		if item then
			local info = item:GetItemInfo()
			info.hero = v.hero
			info.legend = v.legend

			if v.id == self.cur_skill_item:GetSkillId() then
				self:UpdateHeroGuide(item)
			end
		end
	end
end

function SkillTemplate:CheckHeroRedPoint(idx)
	for _,v in pairs(self.skill_item_list) do

		if idx == 2 then
			local skill_id = v:GetSkillId()
			local is_use = self.ctrl:IsSkillUsedHero(skill_id)
			local has_hero = game.HeroCtrl.instance:IsSkillHasHero(skill_id)

			game_help.SetRedPoint(v:GetRoot(), (not is_use and has_hero))
		else
			game_help.SetRedPoint(v:GetRoot(), false)
		end
	end
end

function SkillTemplate:ClearHeroRedPoint()
	for _,v in pairs(self.skill_item_list) do
		game_help.SetRedPoint(v:GetRoot(), false)
	end
end

function SkillTemplate:IfHasGuideRedPoint()
	for _,v in pairs(self.skill_item_list) do
		local skill_id = v:GetSkillId()
		local is_use = self.ctrl:IsSkillUsedHero(skill_id)
		local has_hero = game.HeroCtrl.instance:IsSkillHasHero(skill_id)

		if not is_use and has_hero then
			return true
		end
	end
	return false
end

function SkillTemplate:CheckGuideRedPoint()
	-- local guide_tab = self.list_tab:GetChildAt(1)
	-- local is_red = self:IfHasGuideRedPoint()
	-- game_help.SetRedPoint(guide_tab, is_red, 216)
end

function SkillTemplate:ClearGuideRedPoint()
	-- local guide_tab = self.list_tab:GetChildAt(1)
	-- game_help.SetRedPoint(guide_tab, false)
end

function SkillTemplate:OnClickTab(idx)
	local page = PageConfig[idx]
	local is_open = page.check_open_func()
	if is_open then
		self.cur_tab_idx = idx
		self:CheckHeroRedPoint(idx)
	else
		local idx = self.cur_tab_idx-1
		self.list_tab:AddSelection(idx,false)
		self.tab_controller:SetSelectedIndex(idx)

		page.check_open_tips()
	end
end

function SkillTemplate:CheckRedPoint()
	for k,v in ipairs(PageConfig) do
		local tab = self.list_tab:GetChildAt(k-1)
		local is_red = v.check_red_func()
		game_help.SetRedPoint(tab, is_red, 210)
		v.page_item:CheckRedPoint(is_red)
	end
end

return SkillTemplate
