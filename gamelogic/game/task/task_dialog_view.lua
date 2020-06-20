local TaskDialogView = Class(game.BaseView)

local handler = handler
local event_mgr = global.EventMgr
local config_task = config.task

local _ui_mgr = N3DClient.UIManager:GetInstance()

function TaskDialogView:_init(ctrl)
    self._package_name = "ui_task"
    self._com_name = "task_dialog_view"
    self._view_guide_name = "ui_task/task_dialog_view"
    self._ui_order = game.UIZOrder.UIZOrder_Tips + 1

    self._mask_type = game.UIMaskType.FullAlpha
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl
end

function TaskDialogView:OpenViewCallBack(task_id, dialog_id, npc_id)
	self:Init(task_id, dialog_id, npc_id)

	self:RegisterAllEvents()

	self:ShowBlur()
end

function TaskDialogView:CloseViewCallBack()
	self.is_left = nil
	self.show_npc_id = nil

	self:ClearModel()
	self:ClearRewards()

	self:HideBlur()
end

function TaskDialogView:RegisterAllEvents()
	local events = {
        { game.TaskEvent.OnAcceptTask, handler(self, self.OnAcceptTask)},
        { game.TaskEvent.OnGetTaskReward, handler(self, self.OnGetTaskReward)},
    }
    for _,v in ipairs(events) do
    	self:BindEvent(v[1], v[2])
    end
end

function TaskDialogView:Init(task_id, dialog_id, npc_id)
	self.task_id = task_id
	self.dialog_id = dialog_id
	self.is_skip_enable = false

	self.is_doing_finish = false

	self.task_cfg = self.ctrl:GetTaskCfg(self.task_id)
	if self.task_cfg == nil then
		return
	end

	self.dialog_cfg = config.task_dialog[self.dialog_id]
	if not self.dialog_cfg then
		local npc_id = npc_id or 1001
		self.dialog_cfg = {
			[1] = {
				seq = 1,
			    talk_npc = npc_id,			
				content = config.npc[npc_id].talk_content,
				npc_id = npc_id,	
			}
		}
	end

	local npc_cfg = config.npc[npc_id]
	if npc_cfg and #npc_cfg.sound > 0 then
		local cd_time = game.TaskCtrl.instance:GetNpcTimestamp(npc_id)
		if cd_time == nil or global.Time:GetServerTime() - cd_time > npc_cfg.cd then
			local index = math.random(#npc_cfg.sound)
			global.AudioMgr:PlayVoice(npc_cfg.sound[index])
			game.TaskCtrl.instance:SetNpcTimestamp(npc_id)
		end
	end

	self.cur_step = 1
	self.max_step = #self.dialog_cfg

	self.next_task_id = self.task_cfg.next

	self.model_left = self._layout_objs["model_left"]
	self.model_right = self._layout_objs["model_right"]

	self.group_reward = self._layout_objs["group_reward"]	

	self.model_left:SetVisible(false)
	self.model_right:SetVisible(false)

	self.txt_talk_name = self._layout_objs["txt_talk_name"]

	self.wrapper_left = self._layout_objs["model_left/wrapper"]
	self.wrapper_right = self._layout_objs["model_right/wrapper"]

	self.img_left = self._layout_objs["img_left"]
	self.img_right = self._layout_objs["img_right"]

	self:InitInfos()
	self:InitBtns()	
	self:InitListFunc()
	self:InitRewards()
	self:InitEffects()
	
	self:InitSelfModel()
	self:InitNpcModel()


	self:ExcuteStep()
end

function TaskDialogView:InitInfos()
	local task_name = self.task_cfg.name
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_name:SetText(task_name)

	self.txt_content = self._layout_objs["txt_content"]
end

function TaskDialogView:InitBtns()
	self.btn_skip = self._layout_objs["btn_skip"]
	self.btn_skip:AddClickCallBack(function()
		local cur_step = self.cur_step - 1
		if cur_step < self.max_step then
			self.cur_step = self.max_step
		end
		self:ExcuteStep()
	end)

	-- self.btn_accept = self._layout_objs["btn_accept"]
	-- self.btn_accept:AddClickCallBack(function()
	-- 	self:DoAcceptTask()
	-- end)

	-- self.btn_finish = self._layout_objs["btn_finish"]
	-- self.btn_finish:AddClickCallBack(function()
	-- 	self:DoFinishTask()
	-- 	game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_task/task_dialog_view/btn_finish"})
	-- end)

	self.touch_com = self._layout_objs["touch_com"]
	self.touch_com:AddClickCallBack(function()
		self:ExcuteStep()
	end)
end

function TaskDialogView:InitRewards()
	self.reward_item_list = {}
	self.list_reward = self._layout_objs["list_reward"]
	self.list_reward:RemoveChildrenToPool()

	if self.is_show_func then
		self.group_reward:SetVisible(false)
		return
	end

	self.list_reward:SetVisible(true)

	local reward_list = self.ctrl:GetTaskRewards(self.task_id)

	local package_name = "ui_task"
	local res_name = ""
	for _,v in ipairs(reward_list) do
		local item_id = v[1]
		local item_num = v[2]

		local currency_cfg = self:GetCurrencyCfg(item_id)

		res_name = "task_reward_item"
		if currency_cfg then
			res_name = "task_money"
		end

		local obj = self.list_reward:AddItemFromPool(package_name, res_name)
		--local obj = _ui_mgr:CreateObject(package_name, res_name)
		if currency_cfg then
			obj:SetText(item_num)
			obj:SetIcon("ui_common", currency_cfg.icon)
		else
			local item = game_help.GetGoodsItem(obj:GetChild("item"), true)
			item:SetItemInfo({id=item_id,num=item_num})

			table.insert(self.reward_item_list, item)
		end

		self.list_reward:AddChild(obj)
	end
end

function TaskDialogView:ClearRewards()
	for _,v in ipairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}
end

function TaskDialogView:InitEffects()
	self.eff_finish = self._layout_objs["eff_finish"]
	self.eff_accept = self._layout_objs["eff_accept"]	

	local effect = self:CreateUIEffect(self.eff_finish, "effect/ui/rw_wancheng.ab", game.LayerName.UI2)
	effect:SetLoop(true)
	effect:SetLayer(game.LayerName.UI2, true)

	local effect1 = self:CreateUIEffect(self.eff_accept, "effect/ui/rw_jieshou.ab", game.LayerName.UI2)
	effect1:SetLoop(true)
	effect1:SetLayer(game.LayerName.UI2, true)
end

function TaskDialogView:GetCurrencyCfg(item_id)
	return game.MoneyItemMap[item_id]
end

function TaskDialogView:ExcuteStep()
	local step_cfg = self.dialog_cfg[self.cur_step]
	if not step_cfg then
		-- if self.is_skip_enable then
		-- 	self:Close()
		-- end

		self:DoFinish()
		return
	end

	local is_self = (step_cfg.talk_npc==0)
	self:ShowLeft(is_self)
	self:ShowRight(not is_self, step_cfg)

	local content = self:ParseContent(step_cfg.content)
	self.txt_content:SetText(content)

	self:UpdateTaskState()

	self.cur_step = self.cur_step + 1
end

function TaskDialogView:ShowLeft(val)
	if self.is_left == val then return end

	self.is_left = val
	self.model_left:SetVisible(val)
	
	local role_name = game.Scene.instance:GetMainRoleName()
    self.txt_talk_name:SetText(role_name)
end

function TaskDialogView:ShowRight(val, step_cfg)
	self.model_right:SetVisible(val)
	self.img_right:SetVisible(val)
	if val then
		self:UpdateNpcModel(step_cfg)
	end
end

local CareerPosOffset = {
	[game.Career.GaiBang] = {2.2, -6.2, 11.738},
	[game.Career.XiaoYao] = {2.70, -10.73, 17.11},
	[game.Career.EMei] = {2.8, -7.2, 13.68},
	[game.Career.TianShan] = {1.8, -6.2, 10.264},
}
function TaskDialogView:InitSelfModel()
	if not self.role_model then
		local main_role = self.main_role

	    self.role_model = require("game/character/model_template").New()
	    self.role_model:CreateDrawObj(self.wrapper_left, game.BodyType.ModelSp)    
	    
	    self.role_model:SetModelChangeCallBack(function()
	        --self.role_model:SetRotation(0, 180, 0)
	    end)

	    local career = game.Scene.instance:GetMainRoleCareer()
	    self.role_model:SetModel(game.ModelType.Body, game.CareerSpineId[career] or "")
		self.role_model:PlayAnim(game.ObjAnimName.Show1)

		local x = 2.7 --0.5
	    local y = -7 -- -8.29
		local z = 13 -- 16.82
		local cfg = CareerPosOffset[career]
	    self.role_model:SetPosition(cfg[1], cfg[2], cfg[3])

	    local role_name = game.Scene.instance:GetMainRoleName()
	    self.txt_talk_name:SetText(role_name)
	end
end

function TaskDialogView:InitNpcModel()
	if not self.npc_model then
		self.npc_model = require("game/character/model_template").New()
	    self.npc_model:CreateDrawObj(self.wrapper_right, game.BodyType.ModelSp)
	    
	    self.npc_model:SetModelChangeCallBack(function()
	        self.npc_model:SetRotation(0, 180, 0)

	        self.npc_model:SetModelVisible(game.BodyType.ModelSp, true)
	    end)
	end
end

function TaskDialogView:UpdateNpcModel(step_cfg)
	if not step_cfg then
		return
	end

	local npc_id = step_cfg.talk_npc
	local npc_cfg = config.npc[npc_id]
	if not npc_cfg then
		return
	end

	self.npc_offset = npc_cfg.offset

	local x = -3.65 + (self.npc_offset[1] or 0) --0
	local y = -10 + (self.npc_offset[2] or 0)-- -12.5
	local z = 20 + (self.npc_offset[3] or 0) --25.26
    self.npc_model:SetPosition(x, y, z)

    self.npc_model:SetModelVisible(game.BodyType.ModelSp, false)

    local is_model_visible = false
    local is_image_visible = false
    if npc_cfg.spine_id > 0 then
    	is_model_visible = true
    	self.npc_model:SetModel(game.ModelType.Body, npc_cfg.spine_id)
		self.npc_model:PlayAnim(game.ObjAnimName.Show1)
	else
		if npc_cfg.image_id > 0 then
			is_image_visible = true
			
			local bundle_name = "npc_" .. npc_cfg.image_id
			local bundle_path = self:GetPackageBundle("npc/" .. bundle_name)
			local asset_name = npc_cfg.image_id
			self:SetSpriteAsync(self.img_right, bundle_path, bundle_name, asset_name, true)
		else
			is_model_visible = true
			self.npc_model:SetBodyType(game.BodyType.Monster)
	    	self.npc_model:SetModel(game.ModelType.Body, npc_cfg.model_id)
	    	self.npc_model:PlayAnim(game.ObjAnimName.Idle)
	    end
    end

    self.npc_model:SetModelVisible(game.ModelType.Body, is_model_visible)
    self.img_right:SetVisible(is_image_visible)

    self.npc_talk_zoom = npc_cfg.talk_zoom

    self.img_right:SetScale(self.npc_talk_zoom*1.0, self.npc_talk_zoom*1.0)
    --self.img_right:SetPosition(0+(self.npc_offset[1] or 0), 959 + (self.npc_offset[2] or 0))

	self.txt_talk_name:SetText(npc_cfg.name)
end

function TaskDialogView:ClearModel()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.npc_model then
		self.npc_model:DeleteMe()
		self.npc_model = nil
	end
end

function TaskDialogView:ShowBlur()
	self:GetRootObj():SetLayer(game.LayerName.UI2, true)
	game.RenderUnit:HideUI(game.LayerMask.UI2)

	-- local scene_camera = game.RenderUnit:GetSceneCamera()
	-- scene_camera:StartImageEffect(game.MaterialEffect.EffectBlur,1,3,false)
end

function TaskDialogView:HideBlur()
	game.RenderUnit:ShowUI()

	-- local scene_camera = game.RenderUnit:GetSceneCamera()
	-- scene_camera:StopImageEffect()
end

function TaskDialogView:InitListFunc()
	self.list_funcs = self._layout_objs["list_funcs"]

	self:UpdateListFunc()
end

function TaskDialogView:UpdateListFunc()
	local events = self.ctrl:GetTaskNpcFuncs(self.task_id)
	local item_num = #events
	self.list_funcs:SetItemNum(item_num)

	if self.task_id == nil then
		return
	end

	if item_num > 0 then
		local config_npc_func = config.npc_func
		for k,v in ipairs(events) do
			local obj = self.list_funcs:GetChildAt(k-1)
			local cfg = config_npc_func[v]
			obj:SetText(cfg.name)
			obj:AddClickCallBack(function()
				if cfg.click_func then
					if cfg.check_func(self.task_id) then
						self:Close()
						cfg.click_func(self.task_id)
					end
				end
			end)
		end
	end

	self.is_show_func = item_num>0
	self.list_funcs:SetVisible(self.is_show_func)
end

function TaskDialogView:DoAcceptTask()
	self.ctrl:SendTaskAccept(self.task_id)
end

function TaskDialogView:DoFinishTask()
	self.ctrl:SendTaskGetReward(self.task_id)
end

function TaskDialogView:UpdateTaskState()
	local is_max_step = (self.cur_step>=self.max_step)

	if is_max_step then
		local task_info = self.ctrl:GetTaskInfoById(self.task_id)
        if task_info == nil then 
            return
        end
		local task_state = task_info.stat

		local is_accept = task_state==game.TaskState.Acceptable
		--self.btn_accept:SetVisible(is_accept)

		self.eff_accept:SetVisible(is_accept)

		local is_task_finish = self.ctrl:CheckTaskFinish(self.task_id)

		--self.btn_finish:SetVisible(is_task_finish and (not self.is_show_func))
		self.eff_finish:SetVisible(is_task_finish and (not self.is_show_func))

		self.group_reward:SetVisible((is_accept or is_task_finish) and (not self.is_show_func))

		self.is_skip_enable = (not is_accept and (not is_task_finish))

		-- 记录对话
		if self.task_cfg.talk_id>0 and self.task_cfg.talk_id == self.dialog_id then
			self.is_skip_enable = true

			self.ctrl:RecordTaskTalk(self.task_id)
			self:FireEvent(game.TaskEvent.OnDoneTaskTalk, self.task_id)
		end

		self.btn_skip:SetVisible(self.is_skip_enable)
	else
		-- self.btn_accept:SetVisible(false)
		-- self.btn_finish:SetVisible(false)
		self.btn_skip:SetVisible(true)

		self.eff_accept:SetVisible(false)
		self.eff_finish:SetVisible(false)

		self.is_skip_enable = true

		self.group_reward:SetVisible(false)
	end
end

function TaskDialogView:ParseContent(content)
	local content = string.gsub(content,"#career#", function(arg)
			local career = game.Scene.instance:GetMainRoleCareer()
			local school_name = game.CareerSchool[career] or ""
			return string.format(config.words[2198], school_name)
		end)

	return string.gsub(content,"#name#", function(arg)
			local name = game.Scene.instance:GetMainRoleName()
			return string.format(config.words[2198], name)
		end)
end

function TaskDialogView:OnAcceptTask(task_id)
	if self.task_id ~= task_id then
		return
	end
	self:Close()

	game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_task/task_dialog_view/btn_finish"})
end

function TaskDialogView:OnGetTaskReward(task_id)
	if self.task_id ~= task_id then
		return
	end
	self:Close()

	game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_task/task_dialog_view/btn_finish"})
end

function TaskDialogView:DoFinish()
	if self.is_doing_finish then
		return
	end

	local is_visible = self.eff_accept:IsVisible()
	if is_visible then
		self.is_doing_finish = true
		self:DoAcceptTask()
		return
	end

	is_visible = self.eff_finish:IsVisible()
	if is_visible then
		self.is_doing_finish = true
		self:DoFinishTask()
		return
	end

	self:Close()

	game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_task/task_dialog_view/btn_finish"})
end

return TaskDialogView
