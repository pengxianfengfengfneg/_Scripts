local FoundryGodweaponCollectView = Class(game.BaseView)

function FoundryGodweaponCollectView:_init(ctrl)
    self._package_name = "ui_equip_tips"
    self._com_name = "godweapon_collect_view"
    self.ctrl = ctrl
    self.foundry_data = self.ctrl:GetData()
end

function FoundryGodweaponCollectView:_delete()

end

function FoundryGodweaponCollectView:OpenViewCallBack()
    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[5220])

    self:InitModel()

    self:InitCollectView()

    self:InitAwards()

    self:UpdateAwardState()

    self:BindEvent(game.FoundryEvent.GodweaponCollect, function()
    	self:UpdateAwardState()
    end)

	--完成任务神器激活
    self._layout_objs["active_btn"]:AddClickCallBack(function()
    	self.ctrl:CsArtifactActivate()
    	self:Close()
		--刷新手中武器
		local role_info = game.SelectRoleView.instance:GetRoleInfo()
		if role_info.career == 1 then
			game.Role.instance:SetWeaponID(1100)
		elseif role_info.career == 2 then
			game.Role.instance:SetWeaponID(1200)
		elseif role_info.career == 3 then
			game.Role.instance:SetWeaponID(1300)
		elseif role_info.career == 4 then
			game.Role.instance:SetWeaponID(1400)
		end
    end)

    self._layout_objs["n10"]:AddClickCallBack(function()
    	self:Close()
    	self.ctrl:OpenGodWeaponPreView()
    	game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_equip_tips/godweapon_collect_view/n10"})
    end)

    game.ViewMgr:FireGuideEvent()
end

function FoundryGodweaponCollectView:CloseViewCallBack()
	for k, v in pairs(self.model_list or {}) do
		v:DeleteMe()
	end
	self.model_list = nil
end

function FoundryGodweaponCollectView:InitCollectView()

	for k, v in ipairs(config.godweapon_collect) do

		local get = true

		local finish_cond = v.finish_cond
		if finish_cond.task_id then

			local task_ctrl = game.TaskCtrl.instance
			local is_finished = task_ctrl:IsTaskCompleted(finish_cond.task_id)

			if not is_finished then
				get = false
			end
		end

		if finish_cond.role_lv then

			local role_lv = game.RoleCtrl.instance:GetRoleLevel()
			if role_lv < finish_cond.role_lv then
				get = false
			end
		end

		self._layout_objs["piece"..k]:SetGray(not get)

		self._layout_objs["txt"..k]:SetText(v.desc)
	end
end

function FoundryGodweaponCollectView:InitAwards()

	self.goods_list = {}
	for i = 1, 5 do

		local goods_item = game_help.GetGoodsItem(self._layout_objs["award_item"..i])
		self.goods_list[i] = goods_item

		local award_drop_id = config.godweapon_collect[i].award_drop
		local item_cfg = config.drop[award_drop_id].client_goods_list[1]

		goods_item:SetItemInfo({id = item_cfg[1], num = item_cfg[2]})

		goods_item:AddClickEvent(function()
			self:OnClick(i)
		end)
	end
end

function FoundryGodweaponCollectView:OnClick(level)
	self.ctrl:CsArtifactTakeAward(level)
	game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_equip_tips/godweapon_collect_view/award_item1"})
	game.ViewMgr:FireGuideEvent()
end

function FoundryGodweaponCollectView:UpdateAwardState()

	local get_num = 0

	for i = 1, 5 do

		local state = self.foundry_data:GetGodweaponChipState(i)

		--可领取
		if state == 1 then
			self._layout_objs["hd"..i]:SetVisible(true)
			self._layout_objs["get_img"..i]:SetVisible(false)
		--已领取
		elseif state == 2 then
			self._layout_objs["hd"..i]:SetVisible(false)
			self._layout_objs["get_img"..i]:SetVisible(true)
			self.goods_list[i]:SetGray(true)
		--不可领取
		else
			self._layout_objs["hd"..i]:SetVisible(false)
			self._layout_objs["get_img"..i]:SetVisible(false)
		end

		if state == 2 then
			get_num = get_num + 1
		end
	end

	if get_num == 5 then
		self._layout_objs["active_btn"]:SetVisible(true)
		self._layout_objs["bot_pannel"]:SetVisible(false)
	end
end

function FoundryGodweaponCollectView:InitModel()

	self.model_list = {}

	local model_cfg = {
		[1] = {
			pos = {0.14, 0.06,0.66},
			rot = {0, -96.065, 0},
		},
		[2] = {
			pos = {0.07, 0.19, 1.249},
			rot = {0, -122, 0},
		},
		[3] = {
			pos = {-0.131, -0.05, 0.977},
			rot = {-0.663, -103.157, -0.18},
		},
		[4] = {
			pos = {0.087, 0.02, 0.849},
			rot = {0, -90.427, 0},
		},
		[5] = {
			pos = {0.21, -0.2, 1.64},
			rot = {0, -92.1, 0},
		},
	}

	for i = 1, 5 do
		local cfg = model_cfg[i]
		self.model_list[i] = require("game/character/model_template").New()
	    self.model_list[i]:CreateDrawObj(self._layout_objs["model"..i], game.BodyType.Monster)
	    self.model_list[i]:SetPosition(cfg.pos[1], cfg.pos[2], cfg.pos[3])
	    self.model_list[i]:SetRotation(cfg.rot[1], cfg.rot[2], cfg.rot[3])
	    self.model_list[i]:SetModel(game.ModelType.Body, 5045+i)
	    self.model_list[i]:SetModelChangeCallBack(function()

	    	local get = true
	    	local v = config.godweapon_collect[i]
			local finish_cond = v.finish_cond
			if finish_cond.task_id then

				local task_ctrl = game.TaskCtrl.instance
				local is_finished = task_ctrl:IsTaskCompleted(finish_cond.task_id)

				if not is_finished then
					get = false
				end
			end

			if finish_cond.role_lv then

				local role_lv = game.RoleCtrl.instance:GetRoleLevel()
				if role_lv < finish_cond.role_lv then
					get = false
				end
			end

			if not get then
	    		self.model_list[i].draw_obj:SetMatEffect(game.MaterialEffect.ModelGray, true)
	    	end
	    	self._layout_objs["model"..i]:SetVisible(true)
	    end)
	   
	end
end

return FoundryGodweaponCollectView