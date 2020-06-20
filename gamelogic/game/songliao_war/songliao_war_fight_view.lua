local SongliaoWarFightView = Class(game.BaseView)

function SongliaoWarFightView:_init(ctrl)
	self._package_name = "ui_songliao_war"
    self._com_name = "songliao_fight_view"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Main_UI+1
    self._view_level = game.UIViewLevel.Standalone
end

function SongliaoWarFightView:OpenViewCallBack()

	
	self._layout_objs["btn1"]:AddClickCallBack(function()

		local cfg = config.sys_config["dynasty_war_pos_yunzhong"].value
		local main_role = game.Scene.instance:GetMainRole()
		main_role:GetOperateMgr():DoFindWay(cfg[1],cfg[2])
    end)

    self._layout_objs["btn2"]:AddClickCallBack(function()
    	local cfg = config.sys_config["dynasty_war_pos_daijun"].value
		local main_role = game.Scene.instance:GetMainRole()
		main_role:GetOperateMgr():DoFindWay(cfg[1],cfg[2])
    end)

    self._layout_objs["btn3"]:AddClickCallBack(function()
		local cfg = config.sys_config["dynasty_war_pos_yanmen"].value
		local main_role = game.Scene.instance:GetMainRole()
		main_role:GetOperateMgr():DoFindWay(cfg[1],cfg[2])
    end)

	--排行榜
	-- self._layout_objs["n12"]:AddClickCallBack(function()
	-- 	self.ctrl:OpenRankView()
 --    end)

	-- self._layout_objs["n13"]:AddClickCallBack(function()

	-- 	local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[4208])

 --        msg_box:SetOkBtn(function()
 --            self.ctrl:CsDynastyWarLeave()
 --        end)

 --        msg_box:SetCancelBtn(function()
 --        end)

 --        msg_box:Open()
 --    end)

    self:BindEvent(game.SongliaoWarEvent.UpdateStage,
    	function(data)
    		self:UpdateFightInfo(data)
    	end)

    self:BindEvent(game.SongliaoWarEvent.UpdateScore,
    	function(data)
    		self:UpdateCampScore(data)
    	end)

    --手动倒计时
    local t = {
    	stage = 1,
    	span = config.songliao_war_stage[1].span
	}
    self:UpdateFightInfo(t)
end

function SongliaoWarFightView:CloseViewCallBack()
	self:DelTimer()
end

function SongliaoWarFightView:UpdateFightInfo(data)

	self:DelEffect()

	--重置
	for i = 1, 3 do
		for k = 1, 2 do
			self._layout_objs["btn"..i.."/state"..k]:SetVisible(false)
		end
	end

	local stage = data.stage
	local span = data.span

	local text_style

	if stage == 1 then
		self._layout_objs["btn1/state1"]:SetVisible(true)
		text_style = config.words[4104]
		self:ShowPrepareEffect(1)
	elseif stage == 2 then
		self._layout_objs["btn1/state2"]:SetVisible(true)
		text_style = config.words[4105]
		self:ShowBattleEffect(1)
	elseif stage == 3 then
		self._layout_objs["btn2/state1"]:SetVisible(true)
		text_style = config.words[4106]
		self:ShowPrepareEffect(2)
	elseif stage == 4 then
		self._layout_objs["btn2/state2"]:SetVisible(true)
		text_style = config.words[4107]
		self:ShowBattleEffect(2)
	elseif stage == 5 then
		self._layout_objs["btn3/state1"]:SetVisible(true)
		text_style = config.words[4108]
		self:ShowPrepareEffect(3)
	elseif stage == 6 then
		self._layout_objs["btn3/state2"]:SetVisible(true)
		text_style = config.words[4109]
		self:ShowBattleEffect(3)
	else
		self:DelTimer()
		return
	end

	self:SetTimerTips(text_style, span)
end

function SongliaoWarFightView:UpdateCampScore(data)

	local camp_score = data.camp_score

	local camp1_score = camp_score[1].score
	self._layout_objs["n4"]:SetText(string.format(config.words[4102], camp1_score))

	local camp1_score = camp_score[2].score
	self._layout_objs["n5"]:SetText(string.format(config.words[4103], camp1_score))
end

function SongliaoWarFightView:SetTimerTips(text_style, span)

	self:DelTimer()

	local left_time = span
	self.timer = global.TimerMgr:CreateTimer(1,
    	function()

    		left_time = left_time - 1
    		self._layout_objs["n3"]:SetText(string.format(text_style, left_time))

    		if left_time <= 0 then
    			self:DelTimer()
    		end
    	end)
end

function SongliaoWarFightView:DelTimer()

	if self.timer then
		global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
	end
end

function SongliaoWarFightView:DelEffect()
	local scene_logic = game.Scene.instance:GetSceneLogic()
	scene_logic:DeletePoisonEffect()
end

function SongliaoWarFightView:ShowPrepareEffect(pos_index)
	local scene_logic = game.Scene.instance:GetSceneLogic()
	scene_logic:CreatePrepareEffect(pos_index)
end

function SongliaoWarFightView:ShowBattleEffect(pos_index)
	local scene_logic = game.Scene.instance:GetSceneLogic()
	scene_logic:CreateBattleEffect(pos_index)
end

return SongliaoWarFightView