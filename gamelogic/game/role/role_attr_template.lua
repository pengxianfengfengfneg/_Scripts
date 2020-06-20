local RoleAttrTemplate = Class(game.UITemplate)

local attr_order_list = {
	5,7,6,8,9,10,11,12,43,44,45,46,
	21,23,22,24,29,25,30,26,31,27,32,28,
}

function RoleAttrTemplate:_init(view)
	self.parent_view = view
    self.ctrl = game.RoleCtrl.instance
end

function RoleAttrTemplate:OpenViewCallBack()
	local events = {
        {game.RoleEvent.UpdateRoleAttr, handler(self,self.RefreshAttr)},
        {game.RoleEvent.UpdateRoleBaseAttr, handler(self,self.RefreshBaseAttr)},
        {game.SceneEvent.MainRoleHpChange, handler(self,self.RefreshHp)},
        {game.SceneEvent.MainRoleMpChange, handler(self,self.RefreshMp)},
        {game.RoleEvent.LevelChange, handler(self,self.RefreshExp)},
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end

    local lv = self.ctrl:GetRoleLevel()
    local exp = self.ctrl:GetRoleExp()
    local lv_cfg = config.level[lv]
    if exp > lv_cfg.exp and lv < #config.level then
    	self._layout_objs["btn_notice"]:SetVisible(false)
    	self._layout_objs["btn_up"]:SetVisible(true)
    else
    	self._layout_objs["btn_notice"]:SetVisible(true)
    	self._layout_objs["btn_up"]:SetVisible(false)
    end

    self._layout_objs["btn_up"]:AddClickCallBack(function()
    	local view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[5594], config.words[1660])
    	view:SetBtn1(config.words[5595], function()
			if game.GuildCtrl.instance:GetGuildId() == 0 then
				game.GameMsgCtrl.instance:PushMsg(config.words[5599])
				return
			end
    		local main_role = game.Scene.instance:GetMainRole()
    		if main_role then
	    		main_role:GetOperateMgr():DoGoToNpc(2007, function()
		    		local obj = game.Scene.instance:GetMainRole()
		    		if obj then
		    			obj:GetOperateMgr():DoClickNpc(2007)
					end
	    		end)
    		end
    		self.parent_view:Close()
    	end)
    	view:SetBtn2(config.words[5596], function()
			if game.GuildCtrl.instance:GetGuildId() == 0 then
				game.GameMsgCtrl.instance:PushMsg(config.words[5599])
				return
			end
    		local main_role = game.Scene.instance:GetMainRole()
    		if main_role then
	    		main_role:GetOperateMgr():DoGoToNpc(2007, function()
		    		local obj = game.Scene.instance:GetMainRole()
		    		if obj then
		    			obj:GetOperateMgr():DoClickNpc(2007)
					end
	    		end)
    		end
    		self.parent_view:Close()
    	end)
    	view:Open()
    end)

    self._layout_objs["btn_notice"]:AddClickCallBack(function()
    	local pioneer_lv = game.MainUICtrl.instance:GetPioneerLv()
    	local world_lv = game.MainUICtrl.instance:GetWorldLv()
    	local open_day = game.MainUICtrl.instance:GetOpenDay()
    	local next_world_day, next_wolrd_lv = config_help.ConfigHelpLevel.GetNextWorldLvDay(open_day)

    	local lv = game.Scene.instance:GetMainRoleLevel()
    	local next_lv, practice_lv
    	for i=lv,#config.level do
    		if config.level[i].is_need_practice > 0 then
    			next_lv = i
    			practice_lv = config.level[i].is_need_practice
    			break
    		end
    	end

    	local str = ""
    	if next_lv == #config.level then
    		str = string.format(config.words[5585], next_lv, next_lv + 1, practice_lv)
    	else
    		str = string.format(config.words[5586], next_lv, next_lv + 1, practice_lv)
    	end

    	local param = {}
    	param[1] = {world_lv, next_world_day, next_wolrd_lv}
    	param[2] = {pioneer_lv}
    	param[3] = {str}
    	game.GameMsgCtrl.instance:OpenInfoDescView(6, param)
    end)

    self:RefreshAttr()
    self:RefreshBaseAttr()
    self:RefreshExp()
    self:RefreshHp()
    self:RefreshMp()
end

function RoleAttrTemplate:CloseViewCallBack()

end

function RoleAttrTemplate:RefreshHp()
	local vo = game.Scene.instance:GetMainRoleVo()
	if vo then
		self._layout_objs["hp_bar"]:SetMax(vo.attr.hp_lim)
		self._layout_objs["hp_bar"]:SetValue(vo.hp)
	end
end

function RoleAttrTemplate:RefreshMp()
	local vo = game.Scene.instance:GetMainRoleVo()
	if vo then
		self._layout_objs["mp_bar"]:SetMax(vo.attr.mp_lim)
		self._layout_objs["mp_bar"]:SetValue(vo.mp)
	end
end

function RoleAttrTemplate:RefreshExp()
    local lv = self.ctrl:GetRoleLevel()
    local exp = self.ctrl:GetRoleExp()

    local lv_cfg = config.level[lv]
	self._layout_objs["exp_bar"]:SetMax(lv_cfg.exp)
	self._layout_objs["exp_bar"]:SetValue(exp)
end

function RoleAttrTemplate:RefreshAttr()
	local vo = game.Scene.instance:GetMainRoleVo()
	local career_cfg = config.career_init[vo.career]
	if vo then
		local attr = vo.attr
	    local cfg = config.combat_power_battle
        local all_def = vo.base_attr.adef
        local all_adef = vo.base_attr.adef_red
		for i,v in ipairs(attr_order_list) do
            local idx = i + 6
            local val = attr[cfg[v].sign]
            if idx >= 23 and idx <= 30 then
                if idx % 2 == 1 then
                    val = val + all_adef
                else
                    val = val + all_def
                end
            end
			self._layout_objs["attr_n" .. idx]:SetText(cfg[v].attr_name)
			self._layout_objs["attr_v" .. idx]:SetText(val)
			if v > 20 and v < 40 then
				if v % 4 == career_cfg.element_id then
					self._layout_objs["attr_n" .. idx]:SetColor(table.unpack(game.Color.Orange))
					self._layout_objs["attr_v" .. idx]:SetColor(table.unpack(game.Color.Orange))
				else
					self._layout_objs["attr_n" .. idx]:SetColor(table.unpack(game.Color.GrayBrown))
					self._layout_objs["attr_v" .. idx]:SetColor(table.unpack(game.Color.GrayBrown))
				end 
			end
		end

		for i=6,6 do
			self._layout_objs["attr_n" .. i]:SetVisible(false)
			self._layout_objs["attr_v" .. i]:SetVisible(false)
		end
	end
end

function RoleAttrTemplate:RefreshBaseAttr()
	local vo = game.Scene.instance:GetMainRoleVo()
	if vo then
		local attr = vo.base_attr
	    local cfg = config.combat_power_base
	    for i=1,5 do
	    	self._layout_objs["attr_n" .. i]:SetText(cfg[i].attr_name)
			self._layout_objs["attr_v" .. i]:SetText(attr[cfg[i].sign])
	    end
	end
end


return RoleAttrTemplate
