local GuideView = Class(game.BaseView)
local y = FairyGUI.GRoot.inst.height
local his_pos = {x=90,y=1079}
local can_smoot_move = false
function GuideView:_init(ctrl)
	self._package_name = "ui_guide"
    self._com_name = "ui_guide_view"
    self._layer_name = game.LayerName.UIDefault
    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Guide
    self._ui_order = game.UIZOrder.UIZOrder_Top
    self.not_add_mgr = true
    self.visible = true

    self.ctrl = ctrl
end

function GuideView:OnPreOpen()
	local main_role = game.Scene.instance:GetMainRole()
	if main_role then
		main_role:SetPauseHangTask(true)
	end
end

function GuideView:OnPreClose()
	if game.Scene.instance then
		local main_role = game.Scene.instance:GetMainRole()
		if main_role then
			main_role:SetPauseHangTask(false)
		end
	end
end

function GuideView:OpenViewCallBack(guide_step_info)

	self._layout_objs["bg"]:SetTouchEnable(false)

	self:PlayAnim()
	self:ExecuteGuide(guide_step_info)

	-- self:CheckFirstEnterTips()
	self._layout_root:SetVisible(self.visible)
end

function GuideView:CloseViewCallBack()
	self:StopUIEffect(self._layout_objs.effect)

	self:DelTimer()

	if self.tween then
		self.tween:Kill(false)
		self.tween = nil
	end

	if self.tween2 then
		self.tween2:Kill(false)
		self.tween2 = nil
	end

	if self.tween3 then
        self.tween3:Kill(false)
        self.tween3 = nil
    end

	his_pos = {}
end

function GuideView:ExecuteGuide(guide_step_info)
	local step1 = guide_step_info
	self:ExecuteOneStep(step1)
end


function GuideView:ExecuteOneStep(guide_step_info)
	local click_rect = guide_step_info.click_rect
	if click_rect.x then
		self._layout_objs["finger_img"]:SetVisible(true)

		if y ~= 1280 then
			local click_rect_y = y - 1280
			if click_rect.y > 500 then
				click_rect.y = click_rect.y + click_rect_y
			else
				--click_rect.y = click_rect_y - click_rect.y
			end
		end
		print("click_rect.y ========>" , click_rect.y)

		if his_pos.x and can_smoot_move then
			self._layout_objs["finger_img"]:SetPosition(his_pos.x, his_pos.y)

			self:DoMove(click_rect.x, click_rect.y)
		else
			self._layout_objs["finger_img"]:SetPosition(click_rect.x, click_rect.y)
		end

		his_pos.x = click_rect.x
		his_pos.y = click_rect.y

		if click_rect.rotation then
			local angle = click_rect.rotation % 360
			self._layout_objs["finger_img"]:SetRotation(angle)
		else
			self._layout_objs["finger_img"]:SetRotation(0)
		end

		if click_rect.guangbao == 1 then
			if guide_step_info.active_cond.on_view[1] == "ui_task/task_dialog_view" then
	        	self:CreateGuangbaoEffect(click_rect,game.LayerName.UI2)
	        else
	        	self:CreateGuangbaoEffect(click_rect)
	        end
		else
			self._layout_objs.effect:SetVisible(false)
		end

		if guide_step_info.active_cond.on_view[1] == "ui_task/task_dialog_view" or guide_step_info.active_cond.on_view[1] == "ui_task/npc_dialog_view" then
        	self:CreateGuangbaoKeepEffect(click_rect,game.LayerName.UI2)
        else
        	self:CreateGuangbaoKeepEffect(click_rect)
        end

        self:CreateFrameEffect(guide_step_info.frame_cfg)

		self:CreateCircleEffect(guide_step_info.circle_effect)

	else
		self._layout_objs["finger_img"]:SetVisible(false)
		for i = 1, 4 do
        	self._layout_objs["frame_effect"..i]:SetVisible(false)
        end
        self._layout_objs["cirlce_effect"]:SetVisible(false)
		self:ClearUIEffect()
	end

	self:SetNpcArrow(guide_step_info.npc_jt)

	self:SpecialAction(guide_step_info)

	self:PlaySound(guide_step_info)
end

function GuideView:PlayAnim()

	if self.tween then
		self.tween:Kill(false)
		self.tween = nil
	end

	self.tween = DOTween.Sequence()
	self.tween:Append(self._layout_objs["finger_img"]:TweenScale({ 1.2, 1.2 }, 0.5))
    self.tween:Append(self._layout_objs["finger_img"]:TweenScale({ 1, 1 }, 0.5))

	self.tween:SetLoops(-1)
end

function GuideView:HideFinger()
	local main_role = game.Scene.instance:GetMainRole()
	if main_role then
		main_role:SetPauseHangTask(false)
	end
	self:ClearUIEffect()
	self._layout_objs["finger_img"]:SetVisible(false)
	self._layout_objs["yellow_arrow"]:SetVisible(false)
	self._layout_objs["pannel0"]:SetVisible(false)
	self._layout_objs["pannel1"]:SetVisible(false)
end

function GuideView:DoMove(target_pos_x, target_pos_y)

	if self.tween2 then
		self.tween2:Kill(false)
		self.tween2 = nil
	end

	self.tween2 = DOTween.Sequence()
	self.tween2:Append(self._layout_objs["finger_img"]:TweenMove({target_pos_x, target_pos_y}, 0.3))
end

function GuideView:CheckFirstEnterTips()

    local first_enter_flag = game.GuideCtrl.instance:GetFirstEnterFlag()

    if first_enter_flag then
        game.GuideCtrl.instance:OpenFirstEnterTips()
    end
	self.ctrl.is_first_login = false
end

function GuideView:CreateGuangbaoEffect(click_rect, layer)

	local ui_effect = self:CreateUIEffect(self._layout_objs.effect, "effect/ui/finger.ab",layer)
	self._layout_objs.effect:SetPosition(click_rect.x, click_rect.y)
	ui_effect:Play()
	self._layout_objs.effect:SetVisible(true)
end

function GuideView:CreateGuangbaoKeepEffect(click_rect, layer)

	local ui_effect = self:CreateUIEffect(self._layout_objs["effect_keep"], "effect/ui/shiyongyindao.ab",layer)
	self._layout_objs["effect_keep"]:SetPosition(click_rect.x, click_rect.y)
	ui_effect:SetLoop(true)
	ui_effect:Play()
	self._layout_objs["effect_keep"]:SetVisible(true)
end

function GuideView:CreateFrameEffect(frame_cfg)
	if next(frame_cfg) then
		local width = frame_cfg.width
		local height = frame_cfg.height
		local left_top_pos = frame_cfg.lt_pos

		if y ~= 1280 then
			local pos_y = y - 1280
			left_top_pos[2] = left_top_pos[2] + pos_y
		end

		local pos_cfg = {}
		pos_cfg[1] = left_top_pos									           	--left_top_pos
		pos_cfg[2] = {left_top_pos[1], left_top_pos[2]+height}					--left_bot_pos
		pos_cfg[3] = {left_top_pos[1]+width, left_top_pos[2]}	       			--right_top_pos
		pos_cfg[4] = {left_top_pos[1]+width, left_top_pos[2]+height}			--right_bot_pos

		for i = 1, 4 do

			local effect_path = "effect/ui/ui_xz_0"..tostring(i)..".ab"
			local effect = self:CreateUIEffect(self._layout_objs["frame_effect"..i], effect_path)
			effect:SetLoop(true)
			self._layout_objs["frame_effect"..i]:SetPosition(pos_cfg[i][1], pos_cfg[i][2])
		end

		if self.tween3 then
	        self.tween3:Kill(false)
	        self.tween3 = nil
	    end
		self.tween3 = DOTween.Sequence()
	    self.tween3:AppendInterval(1.5)
	    self.tween3:AppendCallback(function()
	    	for i = 1, 4 do
	        	self._layout_objs["frame_effect"..i]:SetVisible(true)
	        end
	    end)
	end
end

function GuideView:CreateCircleEffect(circle_effect)
	if next(circle_effect) then

		self._layout_objs["cirlce_effect"]:SetPosition(circle_effect.pos[1], circle_effect.pos[2])
		local scale = circle_effect.scale
		local effect_path = "effect/ui/ui_xz_y.ab"
		local effect = self:CreateUIEffect(self._layout_objs["cirlce_effect"], effect_path)
		effect:SetLoop(true)
		effect:SetScale(scale,scale,scale)
		self._layout_objs["cirlce_effect"]:SetVisible(true)
	end
end

function GuideView:SetNpcArrow(npc_jt)
	if next(npc_jt) then

		local npc_cfg = npc_jt[1]
		local flip = npc_cfg.flip and npc_cfg.flip or 0

		if y ~= 1280 then
			local npc_y = y - 1280
			if npc_cfg.y > 500 then
				npc_cfg.y = npc_cfg.y + npc_y
			else
				npc_cfg.y = npc_y - npc_cfg.y
			end
		end
		print("npc_cfg.y",npc_cfg.y)

		if flip == 0 then
			self._layout_objs["pannel0"]:SetVisible(true)
			self._layout_objs["pannel1"]:SetVisible(false)

			self._layout_objs["pannel0"]:SetPosition(npc_cfg.x, npc_cfg.y)
			self._layout_objs["txt0"]:SetText(npc_cfg.txt)

			if npc_cfg.npc_img == 0 then
				self._layout_objs["npc_img0"]:SetVisible(false)
			else
				self._layout_objs["npc_img0"]:SetVisible(true)
			end
		else

			self._layout_objs["pannel0"]:SetVisible(false)
			self._layout_objs["pannel1"]:SetVisible(true)

			self._layout_objs["pannel1"]:SetPosition(npc_cfg.x, npc_cfg.y)
			self._layout_objs["txt1"]:SetText(npc_cfg.txt)

			if npc_cfg.npc_img == 0 then
				self._layout_objs["npc_img1"]:SetVisible(false)
			else
				self._layout_objs["npc_img1"]:SetVisible(true)
			end
		end

		local jt_cfg = npc_jt[2]

		if jt_cfg then
			if y ~= 1280 then
				local jt_y = y - 1280
				if jt_cfg.y > 500 then
					jt_cfg.y = jt_cfg.y + jt_y
				else
					jt_cfg.y = jt_y - jt_cfg.y
				end
			end
			print("jt_cfg.y",jt_cfg.y)
			self._layout_objs["yellow_arrow"]:SetPosition(jt_cfg.x, jt_cfg.y)

			if jt_cfg.rotation then
				local angle = jt_cfg.rotation % 360
				self._layout_objs["yellow_arrow"]:SetRotation(angle)
			else
				self._layout_objs["yellow_arrow"]:SetRotation(0)
			end
			self._layout_objs["yellow_arrow"]:SetVisible(true)
		else
			self._layout_objs["yellow_arrow"]:SetVisible(false)
		end

	else
		self._layout_objs["yellow_arrow"]:SetVisible(false)
		self._layout_objs["pannel0"]:SetVisible(false)
		self._layout_objs["pannel1"]:SetVisible(false)
	end
end

function GuideView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function GuideView:SpecialAction(guide_step_info)

	local open_view = guide_step_info.open_view
	if next(open_view) then

        if open_view[1] == "MainUICtrl" and open_view[2] == 1 then
        	local view = game.MainUICtrl.instance:GetMainUIView()
        	view:SetShowSkillCom(false)
        	game.MainUICtrl.instance:SwitchFuncListPage(1)
        elseif open_view[1] == "hero_view" then
        	game.HeroCtrl.instance:SetBookToBot()
        elseif open_view[1] == "OpenGodWeaponView" then
        	game.FoundryCtrl.instance:OpenGodWeaponView(open_view[2])
        elseif open_view[1] == "OpenTaskView" then
        	game.TaskCtrl.instance:OpenView()
        elseif open_view[1] == "OpenActivityHallView" then
        	local tab_index = open_view[2]
        	local id = open_view[3]
        	local view = game.ActivityMgrCtrl.instance:GetActivityHallView()
        	if view then
        		view:SetGuideOper(tab_index,id)
        	end
        elseif open_view[1] == "PetBreedView" then
        	local petbreedview = game.PetCtrl.instance:GetBreedView()
        	if petbreedview and petbreedview:IsOpen() then
        		petbreedview:RefreshPetList()
        	end
        elseif open_view[1] == "LakeExpView" then
        	local lake_exp_view = game.LakeExpCtrl.instance:GetView()
        	if lake_exp_view and lake_exp_view:IsOpen() then
        		lake_exp_view:SetGuideOper()
        	end
        end
	end
end

function GuideView:SetVisible(val)
	
	self.visible = val

	if self:IsOpen() then
		if self._layout_root then
	        self._layout_root:SetVisible(val)
	    end
	end
end

function GuideView:PlaySound(guide_step_info)
	if guide_step_info.sound ~= "" then
		global.AudioMgr:PlayVoice(guide_step_info.sound)
	end
end

function GuideView:SetDynamicPos(posx, posy)

	if y ~= 1280 then
		local pos_y = y - 1280
		if posy > 500 then
			posy = posy + pos_y
		else
			posy = pos_y - posy
		end
	end
	print("posy",posy)
	self._layout_objs["finger_img"]:SetPosition(posx, posy)
	self._layout_objs["finger_img"]:SetVisible(true)
	self:CreateGuangbaoEffect({x=posx,y=posy})
end

return GuideView