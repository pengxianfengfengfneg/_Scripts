local FoundryHideweaponSkillTemplate = Class(game.UITemplate)

function FoundryHideweaponSkillTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "foundry_hideweapon_skill_template"
    self.parent = parent
    self.foundry_data = game.FoundryCtrl.instance:GetData()
end

function FoundryHideweaponSkillTemplate:OpenViewCallBack()

	self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs["n26"])
    self.cost_item:Open()
    self.cost_item:ResetItem()
    self:ResetLeftSkillPlan()


	self:BindEvent(game.FoundryEvent.ChangeHWSkillPlan, function(data)
    	if self.select_index then
    		self:DoSelect(self.select_index)
    	end
    end)

    self:BindEvent(game.FoundryEvent.RefreshSkillPlan, function(data)
    	self:SetChongxiSkill()
    end)

    self:BindEvent(game.FoundryEvent.ReplaceSkillPlan, function(data)
    	self:DoSelect(self.select_index or 1)
    	self:SetChongxiSkill()
    end)

    self:BindEvent(game.FoundryEvent.UnlockSkillPlan, function(data)

    	local index = data.plan

    	self:InitPlanBtns()

		self:DoSelect(index)

		self:SetChongxiSkill()
    end)

    self:BindEvent(game.FoundryEvent.OpenFirstPlan, function(data)

    	local index = data.cur_plan

    	self:InitPlanBtns()

		self:DoSelect(index)

		self:SetChongxiSkill()
    end)

	for i = 1, 4 do
		self._layout_objs["planbtn"..i]:AddClickCallBack(function()
			self:DoSelect(i, true)
		end)
	end

	self._layout_objs["n1"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenHWSkillPreview()
    end)

	--启用
	self._layout_objs["use_btn"]:AddClickCallBack(function()
		local main_role = game.Scene.instance:GetMainRole()
        if main_role then     
            if main_role:IsFightState() then
                game.GameMsgCtrl.instance:PushMsg(config.words[529])
                return
            end
        end
        game.FoundryCtrl.instance:CsAnqiChangePlan(self.select_index)
    end)

	--重洗
    self._layout_objs["reuse_btn"]:AddClickCallBack(function()
    	local main_role = game.Scene.instance:GetMainRole()
        if main_role then     
            if main_role:IsFightState() then
                game.GameMsgCtrl.instance:PushMsg(config.words[534])
                return
            end
        end

        game.FoundryCtrl.instance:CsAnqiRefreshPlan()
    end)

    --替换
    self._layout_objs["replace_btn"]:AddClickCallBack(function()

    	local main_role = game.Scene.instance:GetMainRole()
        if main_role then     
            if main_role:IsFightState() then
                game.GameMsgCtrl.instance:PushMsg(config.words[534])
                return
            end
        end

    	if self.plan_info then
	    	if self.select_index then
		    	local str = string.format(config.words[1279], self.select_index)
		    	local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], str)
		        msg_box:SetOkBtn(function()
		            game.FoundryCtrl.instance:CsAnqiReplacePlan(self.select_index)
		            msg_box:Close()
		            msg_box:DeleteMe()
		        end)
		        msg_box:SetCancelBtn(function()
		            end)
		        msg_box:Open()
		    end
		else
			game.GameMsgCtrl.instance:PushMsg(config.words[1280])
		end
    end)

	self:InitPlanBtns()

	self:DoSelect(1)

	self:SetChongxiSkill()
end

function FoundryHideweaponSkillTemplate:CloseViewCallBack()

	if self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end

	self:DelTimer()
end

function FoundryHideweaponSkillTemplate:InitPlanBtns()

	local hideweapon_data = self.foundry_data:GetHideWeaponData()
	local skill_plans = hideweapon_data.skill_plans

	self.open_list = {}
	for k, v in pairs(skill_plans) do
		local index = v.plan.index
		self.open_list[index] = true
	end

	for i = 1, 4 do
		if self.open_list[i] then
			self._layout_objs["lock_img"..i]:SetVisible(false)
			self._layout_objs["planbtn"..i]:SetText(string.format(config.words[1260],i))
		else
			self._layout_objs["lock_img"..i]:SetVisible(true)
			self._layout_objs["planbtn"..i]:SetText("")
		end
	end
end

function FoundryHideweaponSkillTemplate:DoSelect(index, click_oper)

	if not self.open_list[index] then
		self._layout_objs["planbtn"..index]:SetSelected(false)

		if click_oper then
			game.GameMsgCtrl.instance:PushMsg(config.words[5219])

			local hideweapon_data = self.foundry_data:GetHideWeaponData()
			local cur_practice_lv = hideweapon_data.practice_lv
			local need_practice_lv = config.anqi_base[1].unlock_skill[1][2]

			if cur_practice_lv >= need_practice_lv then
				--开启新方案提示
				local cfg = config.anqi_base[1].skill_set_open[index]
				local money_type = cfg[2][1] 
				local money_num = cfg[2][2] 
				local item_id = game.MoneyGoodsId[money_type]

				local item_cfg = config.goods[item_id]
				local money_name = item_cfg.name
				local content = string.format(config.words[1259], money_num, money_name)
				local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], content)
		        msg_box:SetOkBtn(function()
		            game.FoundryCtrl.instance:CsAnqiUnlockPlan(index)
		            msg_box:Close()
		            msg_box:DeleteMe()
		        end)
		        msg_box:SetCancelBtn(function()
		        end)
		        msg_box:Open()
		    else
		    	local str = string.format(config.words[1281], config.anqi_base[1].unlock_skill[1][2])
		    	game.GameMsgCtrl.instance:PushMsg(str)
		    end
	    end

		return
	end

	self.select_index = index

	for i = 1, 4 do
		if i ~= index then
			self._layout_objs["planbtn"..i]:SetSelected(false)
		else
			self._layout_objs["planbtn"..i]:SetSelected(true)
		end
	end

	self:ResetLeftSkillPlan()

	local hideweapon_data = self.foundry_data:GetHideWeaponData()

	self:DelTimer()
	local cur_plan = hideweapon_data.cur_plan
	if cur_plan == index then
		self._layout_objs["use_btn"]:SetText(config.words[1261])
		self._layout_objs["use_btn"]:SetGray(true)
	else
		self:SetBtnCD(hideweapon_data.end_plan_cd_time)
	end

	local cur_practice_lv = hideweapon_data.practice_lv
	local skill_plans = hideweapon_data.skill_plans
	local plan_info = {}
	for k, v in pairs(skill_plans) do

		if v.plan.index == index then
			plan_info = v.plan
			break
		end
	end

	for i = 1, 3 do

		local need_practice_lv = config.anqi_base[1].unlock_skill[i][2]

		if cur_practice_lv >= need_practice_lv then

			local skill_id = plan_info["skill"..i]

			if skill_id > 0 then
				local skill_cfg = config.skill[skill_id][1]
				self._layout_objs["bg"..i]:SetSprite("ui_common", "item"..skill_cfg.color)
				self._layout_objs["bg"..i]:SetVisible(true)
				self._layout_objs["cur_item"..i]:SetSprite("ui_skill_icon", skill_cfg.icon)
				self._layout_objs["cur_item"..i]:SetVisible(true)
				self._layout_objs["cur_skill_name"..i]:SetText(skill_cfg.name)
				self._layout_objs["cur_skill_desc"..i]:SetText(skill_cfg.desc)

				local color = game.ItemColor2[skill_cfg.color]
				self._layout_objs["cur_skill_name"..i]:SetColor(color[1], color[2], color[3], color[4])
			else
				self._layout_objs["bg"..i]:SetSprite("ui_common", "item1")
			end
		else
			self._layout_objs["cur_skill_lock"..i]:SetVisible(true)
			local str = string.format(config.words[1282], config.anqi_base[1].unlock_skill[i][2])
			self._layout_objs["cur_skill_desc"..i]:SetText(str)
		end
	end
end

function FoundryHideweaponSkillTemplate:SetBtnCD(cd_end_time)

	local cur_time = global.Time:GetServerTime()
	if cd_end_time and cur_time < cd_end_time then
		local off_time = cd_end_time - cur_time
		self.timer = global.TimerMgr:CreateTimer(1,
	    function()
	        off_time = off_time - 1
	        local str = string.format(config.words[1263], off_time)
	        self._layout_objs["use_btn"]:SetText(str)

	        if off_time <= 0 then
	        	self._layout_objs["use_btn"]:SetText(config.words[1262])
				self._layout_objs["use_btn"]:SetGray(false)
	            self:DelTimer()
	            self:Close()
	        end
	    end)
	else
		self._layout_objs["use_btn"]:SetText(config.words[1262])
		self._layout_objs["use_btn"]:SetGray(false)
	end
end

function FoundryHideweaponSkillTemplate:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function FoundryHideweaponSkillTemplate:ResetLeftSkillPlan()

	for i = 1, 3 do
		self._layout_objs["cur_item"..i]:SetVisible(false)
		self._layout_objs["cur_skill_lock"..i]:SetVisible(false)
		self._layout_objs["bg"..i]:SetVisible(false)
		self._layout_objs["cur_skill_name"..i]:SetText("")
		self._layout_objs["cur_skill_desc"..i]:SetText("")
	end
end

function FoundryHideweaponSkillTemplate:ResetRightSkillPlan()

	for i = 1, 3 do
		self._layout_objs["next_item"..i]:SetVisible(false)
		self._layout_objs["next_skill_name"..i]:SetText("")
		self._layout_objs["next_skill_desc"..i]:SetText("")
		self._layout_objs["skill_lock"..i]:SetVisible(false)
		self._layout_objs["bg"..(i+3)]:SetVisible(false)
	end
end

function FoundryHideweaponSkillTemplate:SetChongxiSkill()

	self:ResetRightSkillPlan()

	local hideweapon_data = self.foundry_data:GetHideWeaponData()
	local cur_practice_lv = hideweapon_data.practice_lv

	local skill_plans = hideweapon_data.skill_plans
	local plan_info
	for k, v in pairs(skill_plans) do

		if v.plan.index == 0 then
			plan_info = v.plan
			break
		end
	end
	self.plan_info = plan_info

	--有重洗技能
	-- if plan_info then
		for i = 1, 3 do
			local need_practice_lv = config.anqi_base[1].unlock_skill[i][2]

			if cur_practice_lv >= need_practice_lv then
				if plan_info then
					local skill_id = plan_info["skill"..i]
					if skill_id > 0 then
						local skill_cfg = config.skill[skill_id][1]
						self._layout_objs["bg"..(i+3)]:SetVisible(true)
						self._layout_objs["bg"..(i+3)]:SetSprite("ui_common", "item"..skill_cfg.color)
						self._layout_objs["next_item"..i]:SetSprite("ui_skill_icon", skill_cfg.icon)
						self._layout_objs["next_item"..i]:SetVisible(true)
						self._layout_objs["next_skill_name"..i]:SetText(skill_cfg.name)
						self._layout_objs["next_skill_desc"..i]:SetText(skill_cfg.desc)
						local color = game.ItemColor2[skill_cfg.color]
						self._layout_objs["next_skill_name"..i]:SetColor(color[1], color[2], color[3], color[4])
					end
				end
			else
				local str = string.format(config.words[1282], config.anqi_base[1].unlock_skill[i][2])
				self._layout_objs["next_skill_desc"..i]:SetText(str)
				self._layout_objs["skill_lock"..i]:SetVisible(true)
			end
		end
	-- end

	self:SetCostItem()
end

function FoundryHideweaponSkillTemplate:SetCostItem()

	local cost_item_id = config.anqi_base[1].refresh_skill_cost[1]
	local cost_item_num = config.anqi_base[1].refresh_skill_cost[2]
	local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

	self.cost_item:SetItemInfo({id = cost_item_id, num = cost_item_num })
	self.cost_item:SetNumText(cur_num.."/"..cost_item_num)

	if cur_num >= cost_item_num then
		self.cost_item:SetColor(224, 214, 189)
		self.cost_item:SetShowTipsEnable(true)
	else
		self.cost_item:SetColor(255, 0, 0)
		self.cost_item:SetShowTipsEnable(true)
	end
end

return FoundryHideweaponSkillTemplate