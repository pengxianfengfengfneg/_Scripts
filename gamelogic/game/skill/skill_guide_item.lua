local SkillGuideItem = Class(game.UITemplate)

local config_skill = config.skill
local config_hero_effect = config.hero_effect
local open_lv = config.sys_config.hero_active_lv.value[1]

local _configHelpSkill = config_help.ConfigHelpSkill

function SkillGuideItem:_init(view)
    self.ctrl = game.SkillCtrl.instance
    
    self.parent_view = view
end

function SkillGuideItem:OpenViewCallBack()
	self:Init()
	self:InitBtns()
end

function SkillGuideItem:CloseViewCallBack()
	game_help.SetRedPoint(self.btn_hero_add, false)
	
   	for _,v in pairs(self.skill_item_list or {}) do
   		v:DeleteMe()
   	end
   	self.skill_item_list = {}
end

function SkillGuideItem:Init()
	self.txt_now_lv = self._layout_objs["txt_now_skill"]
	self.txt_next_lv = self._layout_objs["txt_next_skill"]

	self.txt_now_damage = self._layout_objs["txt_now_damage"]
	self.txt_next_damage = self._layout_objs["txt_next_damage"]

	self.txt_now_name = self._layout_objs["txt_now_name"]
	self.txt_next_name = self._layout_objs["txt_next_name"]

	self.txt_guide_hero = self._layout_objs["txt_guide_hero"]
	self.txt_guide_effect = self._layout_objs["txt_guide_effect"]

	self.txt_skill_name = self._layout_objs["txt_skill_name"]
	
	self.txt_do_hero = self._layout_objs["txt_do_hero"]	

	self.group_guide = self._layout_objs["group_guide"]	
	self.txt_no_guide = self._layout_objs["txt_no_guide"]	
end

function SkillGuideItem:InitBtns()
	local role_lv = game.RoleCtrl.instance:GetRoleLevel()
	self.btn_change = self._layout_objs["btn_change"]
	self.btn_change:AddClickCallBack(function()
		if role_lv >= open_lv then
			local skill_id = self.cur_skill_item:GetSkillId()
			game.SkillCtrl.instance:OpenChangeGuideView(skill_id)
		else
			game.GameMsgCtrl.instance:PushMsg(open_lv .. config.words[2101])
		end
	end)

	self.btn_guide = self._layout_objs["btn_guide"]
	self.btn_guide:AddClickCallBack(function()
		if role_lv >= open_lv then
			game.SkillCtrl.instance:OpenHeroGuideView()
		else
			game.GameMsgCtrl.instance:PushMsg(open_lv .. config.words[2101])
		end
	end)

	self.btn_hero_add = self._layout_objs["btn_hero_add"]
	self.btn_hero_add:AddClickCallBack(function()
		if role_lv >= open_lv then
			local skill_id = self.cur_skill_item:GetSkillId()
			game.SkillCtrl.instance:OpenChangeGuideView(skill_id)
		else
			game.GameMsgCtrl.instance:PushMsg(open_lv .. config.words[2101])
		end
	end)

	self.img_add = self.btn_hero_add:GetChild("img_add")
	self.img_hero_icon = self.btn_hero_add:GetChild("img_icon")

	self.img_hero_bg = self.btn_hero_add:GetChild("img_bg")
	
end

function SkillGuideItem:OnClickSkillItem(skill_item)
	self:UpdateItem(skill_item)
end

function SkillGuideItem:UpdateItem(skill_item)
	local skill_id = skill_item:GetSkillId()

	if not self.ctrl:HasSkillHeroGuide(skill_id) then
		self.group_guide:SetVisible(false)
		self.txt_no_guide:SetVisible(true)

		self.btn_change:SetVisible(false)
		self.btn_guide:SetVisible(false)
		return
	end

	self.group_guide:SetVisible(true)
	self.txt_no_guide:SetVisible(false)

	self.btn_change:SetVisible(true)
	self.btn_guide:SetVisible(true)

	local skill_lv = math.max(skill_item:GetSkillLv(),1)
	local hero_id = skill_item:GetSkillHeroId()
	local legend = skill_item:GetSkillLegend()

	local name = config_help.ConfigHelpSkill.GetSkillCfg(skill_id, skill_lv, hero_id, legend, "name")
	self.txt_skill_name:SetText(name)

	self.txt_now_lv:SetText(string.format(config.words[2221], skill_lv))
	self.txt_next_lv:SetText(string.format(config.words[2221], skill_lv+1))

	self.cur_skill_item = skill_item	

	local is_guide = (hero_id>0)
	self.img_hero_icon:SetVisible(is_guide)
	self.img_add:SetVisible(not is_guide)

	local hero_name = config.words[2215]
	local hero_effect = ""

	local cfg = config.hero[hero_id]
	if is_guide then
		hero_name = cfg.name
		self.img_hero_icon:SetSprite("ui_headicon", cfg.icon or "")

		local effect_cfg = config_hero_effect[hero_id][skill_id][legend][1]
		hero_effect = effect_cfg.zd_desc
	end

	local color = 2
	if cfg then
		color = cfg.color
	end
	self.img_hero_bg:SetSprite("ui_common", "yx_t" .. math.max(color,2))

	self.txt_guide_hero:SetText(hero_name)
	self.txt_guide_effect:SetText(hero_effect)

	self.txt_guide_hero:SetVisible(is_guide)
	self.txt_do_hero:SetVisible(not is_guide)

	self:CheckHeroRedPoint()

	self:UpdateDamage()
end

function SkillGuideItem:OnSkillUpgrade(skill_item)
	self:UpdateItem(skill_item)
end

function SkillGuideItem:UpdateHeroGuide(skill_item)
	self:UpdateItem(skill_item)
end

function SkillGuideItem:CheckHeroRedPoint()
	local skill_id = self.cur_skill_item:GetSkillId()
	local is_use = self.ctrl:IsSkillUsedHero(skill_id)
	local has_hero = game.HeroCtrl.instance:IsSkillHasHero(skill_id)

	game_help.SetRedPoint(self.btn_hero_add, (not is_use and has_hero))
end

function SkillGuideItem:UpdateDamage()
	local skill_item = self.cur_skill_item

	local skill_id = skill_item:GetSkillId()
	local skill_lv = math.max(skill_item:GetSkillLv(),0)
	local hero_id = skill_item:GetSkillHeroId()
	local legend = skill_item:GetSkillLegend()

	local show_type,now_damage = self:CalcSkillDamage(skill_id, skill_lv, hero_id, legend)
	local show_type,next_damage = self:CalcSkillDamage(skill_id, skill_lv+1, hero_id, legend)
	self.txt_now_damage:SetText(now_damage)
	self.txt_next_damage:SetText(next_damage)

	self.txt_now_name:SetText(self:GetDamageName(show_type))
	self.txt_next_name:SetText(self:GetDamageName(show_type))
end

function SkillGuideItem:CalcSkillDamage(skill_id, skill_lv, hero_id, legend)
	return self.ctrl:CalcSkillDamage(skill_id, skill_lv, hero_id, legend)
	
end

function SkillGuideItem:GetDamageName(show_type)
	return config.words[2233 + show_type] or config.words[2233]
end

function SkillGuideItem:CheckRedPoint()
	
end

return SkillGuideItem
