local ReviveView = Class(game.BaseView)

function ReviveView:_init(ctrl)
	self._package_name = "ui_scene"
    self._com_name = "revive_view"
	self._ui_order = game.UIZOrder.UIZOrder_Top

	self._layer_name = game.LayerName.UIDefault
	
	self._view_level = game.UIViewLevel.Standalone
	self._mask_type = game.UIMaskType.Full
	
	self.ctrl = ctrl
end

function ReviveView:_delete()
	
end

function ReviveView:OpenViewCallBack(scene_id, data_list)
	local killer_id = data_list.killer_id
	local killer_name = data_list.killer_name
	local killer_type = data_list.killer_type  -- 1.怪 2.角色 3.宠物
	local die_time = data_list.die_time
	local cfg = config.scene[scene_id]
	local can_operate = true
	local cd_time = 0
	local cost_id = 0
	local cost_num = 0
	local is_force_difu = false
	for _, v in pairs(cfg.revive_param) do
		if v[1] == 1 then
			can_operate = v[2] == 1
		end
		if v[1] == 2 then
			cd_time = v[2]
		end
		if v[1] == 3 then
			cost_id = v[2]
			cost_num = v[3]
		end
		if v[1] == 4 then
			-- 可配合0出窍使用
			is_force_difu = true
		end
	end

	self._layout_objs["txt_title"]:SetText(config.words[500])
	if can_operate then
		self._layout_objs["txt_content"]:SetText(string.format(config.words[501], cfg.name, killer_name))
	else
		self._layout_objs["txt_content"]:SetText(string.format(config.words[538], cfg.name, killer_name))
	end

	self._layout_objs["btn2"]:SetText(config.words[503])
	self._layout_objs["btn3"]:SetText(config.words[500])

	self._layout_objs["btn1"]:SetTouchEnable(cfg.type == game.SceneType.OutSideScene and killer_type == 2)
	self._layout_objs["btn1"]:SetGray(cfg.type ~= game.SceneType.OutSideScene or killer_type ~= 2)
	self._layout_objs["btn1"]:AddClickCallBack(function()
		if game.FriendCtrl.instance:IsMyEnemy(killer_id) then
			game.GameMsgCtrl.instance:PushMsg(config.words[524])
		else
			game.FriendCtrl.instance:CsFriendSysAddEnemy(killer_id)
		end
	end)
	self._layout_objs["btn2"]:AddClickCallBack(function()
		self:SendReviveReq(5)
		self:Close()
	end)
	self._layout_objs["btn3"]:AddClickCallBack(function()
		self:SendReviveReq(self.send_revive_type)
		self:Close()
	end)

	self:SetBtnState(cfg.revive_type, can_operate, is_force_difu)
	if self.send_revive_type >= 0 and cd_time > 0 then
		self.left_time = cd_time - (global.Time:GetServerTime() - die_time)

		self.tween = DOTween.Sequence()
		self.tween:AppendInterval(1)
		self.tween:AppendCallback(function()
			self:RefreshTime()
		end)
		self.tween:SetAutoKill(false)
		self.tween:SetLoops(self.left_time)
		self.tween:OnComplete(function()
			self:Close()
		end)

		self:RefreshTime()
	else
		self._layout_objs["txt_tips"]:SetText("")
	end

	if cost_id ~= 0 and cost_num ~= 0 then
		local own = game.BagCtrl.instance:GetNumById(cost_id)
		self._layout_objs["btn2"]:SetTouchEnable(own >= cost_num)
		self._layout_objs["btn2"]:SetGray(own < cost_num)
		self._layout_objs["txt_item"]:SetText(string.format(config.words[525], config.goods[cost_id].name, own, cost_num))
	else
		self._layout_objs["txt_item"]:SetText("")
	end

    self:BindEvent(game.SceneEvent.MainRoleRevive, function()
    	self:Close()
    end)

    self:CheckBtnState()
end

function ReviveView:CloseViewCallBack()
	if self.tween then
		self.tween:Kill(false)
		self.tween = nil
	end
end

function ReviveView:RefreshTime()
	self.left_time = self.left_time - 1
	if self.left_time < 0 then
		self.left_time = 0 
	end
	self._layout_objs["txt_tips"]:SetText(string.format(config.words[504], self.left_time))
end

function ReviveView:SetBtnState(revive_type, can_operate, is_force_difu)
	--[[
	0:出窍
	1:不能复活
	2:出生点复活
	3:退回原野外场景复活(记录的场景)
	4:退回活动准备场景复活
	5:原地复活，需要消耗道具
	6:夫妻技能复活
	]]

	self.send_revive_type = 0

	local difu_revive = revive_type == 0
	local ban_revive = (revive_type & 0x0001) > 0
	if ban_revive then
		self.send_revive_type = -1
	end
	local born_revive = (revive_type & 0x0002) > 0
	if born_revive then
		self.send_revive_type = 2
	end
	local normal_revive = (revive_type & 0x0004) > 0
	if normal_revive then
		self.send_revive_type = 3
	end
	local activity_revive = (revive_type & 0x0008) > 0
	if activity_revive then
		self.send_revive_type = 4
	end
	local original_revive = (revive_type & 0x0010) > 0

	-- TODO
	-- 等超越先完成
	--local marry_revive = (revive_type & 0x0020) > 0

	local state2 = can_operate and not difu_revive and not ban_revive and original_revive
	local state3 = can_operate and not ban_revive and (difu_revive or born_revive or normal_revive or activity_revive or is_force_difu)

	self._layout_objs.btn2:SetTouchEnable(state2)
	self._layout_objs.btn2:SetGray(not state2)
	self._layout_objs.btn3:SetTouchEnable(state3)
	self._layout_objs.btn3:SetGray(not state3)
end

function ReviveView:SendReviveReq(revive_type)
	self.ctrl:SendReviveReq(revive_type)

	if revive_type ~= 5 then
		local main_role = game.Scene.instance:GetMainRole()
		if main_role == nil then
			return
		end
		main_role:ClearOperate()
	end
end

function ReviveView:CheckBtnState()

	local visible = true
	local is_sl_scene = game.Scene.instance:IsSongliaoScene()
	if is_sl_scene then
		visible = false
	end

	self._layout_objs.btn1:SetVisible(visible)
	self._layout_objs.btn2:SetVisible(visible)
	self._layout_objs.btn3:SetVisible(visible)
end

return ReviveView
