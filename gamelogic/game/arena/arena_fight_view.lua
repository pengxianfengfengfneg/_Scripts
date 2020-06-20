local ArenaFightView = Class(game.BaseView)

function ArenaFightView:_init(ctrl)
	self._package_name = "ui_arena"
    self._com_name = "arena_fight_view"
    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Main_UI+1
    self._view_level = game.UIViewLevel.Standalone
    self.ctrl = ctrl
end

function ArenaFightView:OpenViewCallBack()
    game.MainUICtrl.instance:SetClickTerrainEnable(false)

	self:BindEvent(game.ArenaEvent.InitOppInfo, function()
        self:UpdateOpp()
    end)

    self:BindEvent(game.SceneEvent.TargetHpChange, function(hp_per)
        -- self:UpdateHp(hp_per)
    end)

    self:BindEvent(game.SceneEvent.TargetMpChange, function(hp_per)
        self:UpdateMp(hp_per)
    end)

    self:InitLeftHead()
    self:InitRightHead()

    self:SetTimer()

end

function ArenaFightView:CloseViewCallBack()
    self:DelTimer()

    game.MainUICtrl.instance:SetClickTerrainEnable(true)

    if self.ui_left_list then
        self.ui_left_list:DeleteMe()
        self.ui_left_list = nil
    end

    if self.ui_right_list then
        self.ui_right_list:DeleteMe()
        self.ui_right_list = nil
    end
end

function ArenaFightView:UpdateHp(hp_per)
    self._layout_objs["bar_hp2"]:SetProgressValue(hp_per * 100)
end

function ArenaFightView:UpdateMp(mp_per)
    self._layout_objs["bar_mp2"]:SetProgressValue(mp_per * 100)
end

function ArenaFightView:UpdateOpp( ... )
	local scene_logic = game.Scene.instance:GetSceneLogic()
    if not scene_logic.GetArenaOpp then return end
    local arena_opp = scene_logic:GetArenaOpp()

    if arena_opp then
	    local role_vo = arena_opp:GetVo()
	    self._layout_objs["txt_fight2"]:SetText(string.format(config.words[1710], role_vo.combat_power))
	    self._layout_objs["txt_lv2"]:SetText(role_vo.level)
	end
end

function ArenaFightView:SetTimer()

    local limit_time = config.sys_config["arena_round_time"].value
    if game.Scene.instance:GetSceneID() == config.sys_config.master_rob_scene.value then
        limit_time = config.sys_config.master_rob_time.value
    end

    --显示倒计时
    self._layout_objs["left_time"]:SetText(string.format(config.words[1412], limit_time))
    self.timer = global.TimerMgr:CreateTimer(1,
    function()
        limit_time = limit_time - 1

        self._layout_objs["left_time"]:SetText(string.format(config.words[1412], limit_time))

        if limit_time <= 0 then
            self:DelTimer()
        end
    end)

    self.timer2 = global.TimerMgr:CreateTimer(0.5,
    function()
        self:UpdatePetsHp()
        self:UpdateOppPetsHp()
        self:UpdateOpp()
    end)
end

function ArenaFightView:DelTimer()

    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end

    if self.timer2 then
        global.TimerMgr:DelTimer(self.timer2)
        self.timer2 = nil
    end
end

function ArenaFightView:InitLeftHead()

    self.left_list = self._layout_objs["left_list"]
    self.ui_left_list = game.UIList.New(self.left_list)
    self.ui_left_list:SetVirtual(true)

    self.ui_left_list:SetCreateItemFunc(function(obj)
        local item = require("game/arena/arena_head_template").New(self)
        item:SetType(1)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_left_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_left_list:AddItemProviderCallback(function(idx)
        return "ui_main:pet_head_component"
    end)
end

function ArenaFightView:UpdatePetsHp()

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then return end
    local team = main_role:GetOwnTeam()
    local member_list = team:GetMemberList()

    self.my_left_data = {}

    for key, var in pairs(member_list) do

        if var.obj_type ~= game.ObjType.Role and var.obj_type ~= game.ObjType.MainRole then
            local t = {}
            t.obj_type = var.obj_type
            t.hp_per = var:GetHpPercent()
            table.insert(self.my_left_data, t)
        end
    end

    self.ui_left_list:SetItemNum(#self.my_left_data)
end

function ArenaFightView:GetMyLeftData()
    return self.my_left_data
end

function ArenaFightView:InitRightHead()

    self.right_list = self._layout_objs["right_list"]
    self.ui_right_list = game.UIList.New(self.right_list)
    self.ui_right_list:SetVirtual(true)

    self.ui_right_list:SetCreateItemFunc(function(obj)
        local item = require("game/arena/arena_head_template").New(self)
        item:SetType(2)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_right_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_right_list:AddItemProviderCallback(function(idx)
        return "ui_main:pet_head_component"
    end)
end

function ArenaFightView:UpdateOppPetsHp()

    local scene_logic = game.Scene.instance:GetSceneLogic()
    if not scene_logic.GetArenaOpp then return end
    local arena_opp = scene_logic:GetArenaOpp()
    if arena_opp == nil then
        return
    end
    local team = arena_opp:GetOwnTeam()
    local member_list = team:GetMemberList()

    self.my_right_data = {}

    for key, var in pairs(member_list) do

        if var.obj_type ~= game.ObjType.Role and var.obj_type ~= game.ObjType.MainRole then
            local t = {}
            t.obj_type = var.obj_type
            t.hp_per = var:GetHpPercent()
            table.insert(self.my_right_data, t)
        end
    end

    self.ui_right_list:SetItemNum(#self.my_right_data)
    self.ui_right_list:Foreach(function(item)
        item:ForceRefresh()
    end)

    self._layout_objs["bar_hp2"]:SetProgressValue(arena_opp:GetHpPercent()*100)
end

function ArenaFightView:GetMyRightData()
    return self.my_right_data
end

return ArenaFightView