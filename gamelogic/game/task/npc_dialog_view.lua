local NpcDialogView = Class(game.BaseView)

local NpcDialogConfig = require("game/task/npc_dialog_config")

local handler = handler
local event_mgr = global.EventMgr

function NpcDialogView:_init(ctrl)
    self._package_name = "ui_task"
    self._com_name = "task_dialog_view"
    self._view_guide_name = "ui_task/npc_dialog_view"
    self._ui_order = game.UIZOrder.UIZOrder_Tips + 1

    self._mask_type = game.UIMaskType.FullAlpha
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl
end

function NpcDialogView:OpenViewCallBack(npc_id)
	self:Init(npc_id)

	self:ShowBlur()

	self:RegisterAllEvents()
end

function NpcDialogView:CloseViewCallBack()
	self.is_left = nil
	self.is_right = nil

	self:ClearModel()

	self:HideBlur()
	game.TaskCtrl.instance:SetDialogNpcId(nil)

	self:FireEvent(game.MarryEvent.UpdateHallBTClick)
end

function NpcDialogView:RegisterAllEvents()
	local events = {
		{game.NpcEvent.UpdateEventList, handler(self,self.OnUpdateEventList)},
	}
	for _,v in ipairs(events) do
		self:BindEvent(v[1],v[2])
	end
end

function NpcDialogView:Init(npc_id)
	self.npc_id = npc_id
	self.npc_cfg = config.npc[self.npc_id]

	if #self.npc_cfg.sound > 0 then
		local cd_time = game.TaskCtrl.instance:GetNpcTimestamp(npc_id)
		if cd_time == nil or global.Time:GetServerTime() - cd_time > self.npc_cfg.cd then
			local index = math.random(#self.npc_cfg.sound)
			global.AudioMgr:PlayVoice(self.npc_cfg.sound[index])
			game.TaskCtrl.instance:SetNpcTimestamp(npc_id)
		end
	end

	self.model_left = self._layout_objs["model_left"]
	self.model_right = self._layout_objs["model_right"]

	self.model_left:SetVisible(false)

	self.txt_talk_name = self._layout_objs["txt_talk_name"]

	self.wrapper_left = self._layout_objs["model_left/wrapper"]
	self.wrapper_right = self._layout_objs["model_right/wrapper"]

	self.img_left = self._layout_objs["img_left"]
	self.img_right = self._layout_objs["img_right"]

	self.txt_content = self._layout_objs["txt_content"]

	if NpcDialogConfig[npc_id] then
		self.txt_content:SetText(NpcDialogConfig[npc_id].content_func())
	else
		self.txt_content:SetText(self.npc_cfg.talk_content or "")
	end

	self.btn_skip = self._layout_objs["btn_skip"]
	self.btn_skip:SetVisible(true)
	self.btn_skip:AddClickCallBack(function()
		self:CompleteDialog()
	end)

	self.touch_com = self._layout_objs["touch_com"]
	self.touch_com:AddClickCallBack(function()
		self:CompleteDialog()
	end)

	self.main_role = game.Scene.instance:GetMainRole()

	self:InitInfos()
	self:InitNpcModel()
	self:InitListFunc()

	game.TaskCtrl.instance:SetDialogNpcId(self.npc_id)
end

function NpcDialogView:InitInfos()
	self.group_reward = self._layout_objs["group_reward"]
	self.group_reward:SetVisible(false)

	self.txt_name = self._layout_objs["txt_name"]
	self.txt_name:SetText(self.npc_cfg.func_name)

	self.img_name_flag = self._layout_objs["img_name_flag"]
	self.img_name_flag:SetVisible(self.npc_cfg.func_name~="")
end

function NpcDialogView:CompleteDialog()
	self:Close()

	if game.Scene.instance then
		local main_role = game.Scene.instance:GetMainRole()
		if main_role then
			main_role:GetOperateMgr():ClearOperate()
		end
	end
end

function NpcDialogView:ShowLeft(val, step_cfg)
	if self.is_left == val then return end

	self.is_left = val
	self.model_left:SetVisible(val)	
end

function NpcDialogView:ShowRight(val, step_cfg)
	if self.is_right == val then return end

	self.is_right = val
	self.model_right:SetVisible(val)
	
end

function NpcDialogView:InitSelfModel()
	if not self.role_model then
		local main_role = self.main_role

	    local model_list = {
	        [game.ModelType.Body]    = 110101,
	        --[game.ModelType.Wing]    = 101,
	        [game.ModelType.Hair]    = 11001,
	        [game.ModelType.Weapon]    = 1001,
	    }

	    for k,v in pairs(model_list) do
	        local id = main_role:GetModelID(k)
	        model_list[k] = (id>0 and id or v)
	    end

	    self.role_model = require("game/character/model_template").New()
	    self.role_model:CreateModel(self.wrapper_left, game.BodyType.Role, model_list)
	    self.role_model:PlayAnim(game.ObjAnimName.Idle)
	    self.role_model:SetPosition(0,-1.6,1.6)
	    self.role_model:SetRotation(0,160,0)
	    self.role_model:SetScale(1)

	    local role_name = game.Scene.instance:GetMainRoleName()
	    self.txt_talk_name:SetText(role_name)
	end
end

function NpcDialogView:InitNpcModel()
	if not self.npc_model then
		self.npc_model = require("game/character/model_template").New()
	    self.npc_model:CreateDrawObj(self.wrapper_right, game.BodyType.ModelSp)

	    local offset = self.npc_cfg.offset
	    local x = -3.65 + offset[1]
	    local y = -10 + offset[2]
		local z = 20 + offset[3]
	    self.npc_model:SetPosition(x, y, z)
	    self.npc_model:SetModelChangeCallBack(function()
	        self.npc_model:SetRotation(0, 180, 0)
	    end)

	    self.img_right:SetVisible(false)

	    if self.npc_cfg.spine_id > 0 then
		    self.npc_model:SetModel(game.ModelType.Body, self.npc_cfg.spine_id)
	    	self.npc_model:PlayAnim(game.ObjAnimName.Show1)
	    else
	    	if self.npc_cfg.image_id > 0 then
				self.img_right:SetVisible(true)

				local bundle_name = "npc_" .. self.npc_cfg.image_id
				local bundle_path = self:GetPackageBundle("npc/" .. bundle_name)
				local asset_name = self.npc_cfg.image_id
				self:SetSpriteAsync(self.img_right, bundle_path, bundle_name, asset_name, true)
			else
		    	self.npc_model:SetBodyType(game.BodyType.Monster)
		    	self.npc_model:SetModel(game.ModelType.Body, self.npc_cfg.model_id)
		    	self.npc_model:PlayAnim(game.ObjAnimName.Idle)
		    end
	    end

	    self.npc_talk_zoom = self.npc_cfg.talk_zoom

    	self.img_right:SetScale(self.npc_talk_zoom*1.0, self.npc_talk_zoom*1.0)

    	self.txt_talk_name:SetText(self.npc_cfg.name)
	end
end

function NpcDialogView:ClearModel()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.npc_model then
		self.npc_model:DeleteMe()
		self.npc_model = nil
	end
end

function NpcDialogView:ShowBlur()
	self:GetRootObj():SetLayer(game.LayerName.UI2, true)
	game.RenderUnit:HideUI(game.LayerMask.UI2)

	-- local scene_camera = game.RenderUnit:GetSceneCamera()
	-- scene_camera:StartImageEffect(game.MaterialEffect.EffectBlur,1,3,false)

	-- self.main_role:SetPauseOperate(true)
end

function NpcDialogView:HideBlur()
	game.RenderUnit:ShowUI()

	-- local scene_camera = game.RenderUnit:GetSceneCamera()
	-- scene_camera:StopImageEffect()

	-- self.main_role:SetPauseOperate(false)
end

function NpcDialogView:InitListFunc()
	self.list_funcs = self._layout_objs["list_funcs"]
	self.list_funcs.foldInvisibleItems = true

	local events = self.npc_cfg.event or game.EmptyTable
	local item_num = #events
	self.list_funcs:SetItemNum(item_num)
	self.list_funcs:SetVisible(item_num>0)

	if item_num > 0 then
		local config_npc_func = config.npc_func
		for k,v in ipairs(events) do
			local obj = self.list_funcs:GetChildAt(k-1)
			local cfg = config_npc_func[v]
			if cfg then
				if cfg.name_func then
					obj:SetText(cfg.name_func(self.npc_cfg))
				else
					obj:SetText(cfg.name)
				end
				obj:SetVisible(cfg.visible_func(self.npc_cfg))
				obj:AddClickCallBack(function()
					if cfg.click_func then
						if cfg.check_func(true) then
							game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_task/npc_dialog_view/func_btn"})
							self:Close()
							cfg.click_func(self.npc_cfg)
						end
					end
				end)
			end
		end
	end

	local row = math.max(math.ceil(item_num/2), 1)
	local offset = (row>1 and 10 or 30)
	local height = offset + (row*60)
	self.list_funcs:SetSize(527, height)
end

function NpcDialogView:OnUpdateEventList(npc_id)
	if self.npc_id == npc_id then
		self:InitListFunc()
	end
end

return NpcDialogView
