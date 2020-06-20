local MainUIView = Class(game.BaseView)

local handler = handler
local config_skill = config.skill
local config_skill_career = config.skill_career
local config_scene = config.scene
local config_effect_desc = config.effect_desc

function MainUIView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "main_view"
    self.add_to_view_mgr = false
    self._cache_time = 10

    self._ui_order = game.UIZOrder.UIZOrder_Main_UI

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl

    self:SetGuideIndex(0)
end

function MainUIView:OpenViewCallBack()
    self:Init()
    self:InitFixedCom()
    self:InitMainCom()
    self:InitFightCom()
    self:InitSys()
    self:InitPetCom()
    self:InitMoney()

    self:SwitchToFighting()
    self:DoOpenFight(false)

    self:SetActTime()
    self:CheckActivityTips()

    self:RegisterAllEvents()
end

function MainUIView:CloseViewCallBack()
    self:ClearPetCom()

    self:ClearBuffList()

    if self.main_task_template then
        self.main_task_template:DeleteMe()
        self.main_task_template = nil
    end
end

function MainUIView:RegisterAllEvents()
    local event_list = {
        { game.RedPointEvent.UpdateRedPoint, handler(self, self.OnUpdateRedPoint), },
        { game.RoleEvent.UpdateMainRoleInfo, handler(self, self.OnUpdateMainRoleInfo), },
        { game.ChatEvent.OpenChatView, handler(self, self.OnOpenChatView), },
        { game.ChatEvent.CloseChatView, handler(self, self.OnCloseChatView), },
        { game.ChatEvent.UpdateNewChat, handler(self, self.OnUpdateNewChat), },
        { game.RoleEvent.LevelChange, handler(self, self.RefreshLevel), },
        { game.LakeExpEvent.OnLakeExperienceUse, handler(self, self.RefreshLevel), },
        { game.GameEvent.StartPlay, handler(self, self.OnStartPlay), },
        { game.GameEvent.StopPlay, handler(self, self.OnStopPlay), },
        { game.SceneEvent.MainRoleHpChange, handler(self, self.RefreshHp), },
        { game.SceneEvent.MainRoleMpChange, handler(self, self.RefreshMp), },
        { game.SceneEvent.TargetChange, handler(self, self.RefreshTarget), },
        { game.SceneEvent.TargetHpChange, handler(self, self.RefreshTargetHp), },
        { game.SceneEvent.TargetOwnerTypeChange, handler(self, self.RefreshTargetOwnerType), },
        { game.SceneEvent.HangChange, handler(self, self.OnHangChange), },
        { game.SceneEvent.GatherChange, handler(self, self.RefreshGather), },
        { game.SceneEvent.MainRolePetChange, handler(self, self.RefreshPetCom), },        
        { game.SceneEvent.MainRoleAutoPass, handler(self, self.OnMainRoleAutoPass), },
        { game.PassBossEvent.UpdateReward, handler(self, self.OnUpdateReward), },
        { game.SceneEvent.MainRoleSkillChange, handler(self, self.RefreshSkillList), }, 
        { game.PassBossEvent.BossComing, handler(self, self.OnBossComing), },
        { game.VipEvent.UpdateVipInfo, handler(self, self.OnUpdateVipInfo) },
        { game.SceneEvent.PkModeChange, handler(self, self.RefreshPkMode), }, 
        { game.SceneEvent.MainRoleAddBuff, handler(self, self.OnMainRoleAddBuff), }, 
        { game.SceneEvent.MainRoleDelBuff, handler(self, self.OnMainRoleDelBuff), }, 

        { game.SceneEvent.OperateChangeScene, handler(self, self.OperateChangeScene), },
        
        
        { game.MakeTeamEvent.UpdateTeamCreate, handler(self, self.OnUpdateTeamCreate), }, 
        { game.MakeTeamEvent.TeamLeave, handler(self, self.OnTeamLeave), }, 
        { game.MakeTeamEvent.TeamMemberLeave, handler(self, self.OnTeamMemberLeave), }, 
        { game.MakeTeamEvent.UpdateJoinTeam, handler(self, self.OnUpdateJoinTeam), }, 
        { game.MakeTeamEvent.UpdateKickOut, handler(self, self.OnUpdateKickOut), }, 

        
    }
    for _,v in ipairs(event_list) do
        self:BindEvent(v[1], v[2])
    end
end

local next_check_skill_time = 0
function MainUIView:Update(now_time, elapse_time)
    if now_time > next_check_skill_time then
        next_check_skill_time = now_time + 0.08
        self:UpdateSkillCD(now_time, elapse_time)
    end
end

function MainUIView:Init()
    self.node_fixed = self._layout_objs["node_fixed"]
    self.node_main = self._layout_objs["node_main"]
    self.node_fight = self._layout_objs["node_fight"]

    self.list_func_tb = {}
    for i=1,100 do
        local key = "list_func_" .. i
        local list_func = self.node_fixed:GetChild(key)
        if not list_func then
            list_func = self.node_main:GetChild(key)
        end

        if not list_func then
            list_func = self.node_fight:GetChild(key)
        end

        if not list_func then
            break
        end

        list_func.foldInvisibleItems = true

        local func_tb = {}
        -- 默认个数太少，策划配置的idx很多，不够用
        local max_idx = 0
        for key, val in pairs(config.func) do
            if val.group == i and val.idx > max_idx then
                max_idx = val.idx
            end
        end
        list_func.numItems = max_idx
        --
        for j=0,max_idx-1 do
            local btn_func = list_func:GetChildAt(j)
            btn_func:SetVisible(false)
            table.insert(func_tb, btn_func)
        end

        table.insert(self.list_func_tb, func_tb)
    end
end

function MainUIView:InitFixedCom()
    self.txt_lv = self.node_fixed:GetChild("txt_lv")
    self.txt_fight = self.node_fixed:GetChild("txt_fight")
    self.bar_exp = self.node_fixed:GetChild("bar_exp")
    self.txt_exp_percent = self.node_fixed:GetChild("txt_exp_percent")

    self.bar_hp = self.node_fixed:GetChild("bar_hp")
    self.bar_mp = self.node_fixed:GetChild("bar_mp")

    self.bar_hp:AddClickCallBack(function()
        if not game.IsZhuanJia then
            game.GmCtrl.instance:OpenView()
        end
    end)

    self.img_role_icon = self.node_fixed:GetChild("img_role_icon")
    self.img_role_icon:AddClickCallBack(function()
        game.RoleCtrl.instance:OpenRoleInfoView()
    end)

    local role_ctrl = game.RoleCtrl.instance

    local fight = role_ctrl:GetCombatPower()
    self.txt_fight:SetText("z" .. fight)

    self:RefreshLevel()

    self:RefreshRoleHead()
    self:InitBuffList()
end

function MainUIView:InitBuffList()
    self.list_buff = self.node_fixed:GetChild("list_buff")
    self.buff_click = self.node_fixed:GetChild("buff_click")

    self.ui_list_buff = game.UIList.New(self.list_buff)
    self.ui_list_buff:SetVirtual(true)

    self.buff_click:AddClickCallBack(function()
        if #self.buff_list_data > 0 then
            self._buff_view = self.ctrl:OpenBuffView(self.buff_list_data)
        end
    end)

    self.ui_list_buff:SetCreateItemFunc(function(obj)
        local buff_item = require("game/main/buff_item").New(self.ctrl)
        buff_item:SetVirtual(obj)
        buff_item:Open()
        buff_item:AddCdCallback(function(item)
            self:OnBuffCdCallback(item)
        end)

        return buff_item
    end)

    self.ui_list_buff:SetRefreshItemFunc(function(item, idx)
        item:UpdateData(self.buff_list_data[idx])
    end)

    self.buff_list_data = {}
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        local buff_list = main_role:GetBuffList()
        for _,v in pairs(buff_list) do
            if self:IsBuffShow(v.id) then
                table.insert(self.buff_list_data, v)
            end
        end
    end

    self:DoSortBuffListData()
end

function MainUIView:IsBuffShow(buff_id)
    return config_effect_desc[buff_id]
end

function MainUIView:ClearBuffList()
    if self.ui_list_buff then
        self.ui_list_buff:DeleteMe()
        self.ui_list_buff = nil
    end
end

function MainUIView:RefreshRoleHead()
    local vo = game.Scene.instance:GetMainRoleVo()
    if vo then
        self.img_role_icon:SetSprite("ui_main", vo.career)
    end
end

function MainUIView:OnMainRoleAddBuff(buff_info)
    if not self:IsBuffShow(buff_info.id) then
        return
    end

    if buff_info.is_new then

        table.insert(self.buff_list_data, buff_info)
        self:DoSortBuffListData()

        local item_num = #self.buff_list_data
        item_num = (item_num>6 and 6 or item_num)
        self.ui_list_buff:SetItemNum(item_num)
    else
        self.ui_list_buff:RefreshVirtualList()
    end

    if self._buff_view then
        self._buff_view:UpdateData(self.buff_list_data)
    end
end

function MainUIView:OnMainRoleDelBuff(id)
    if not self:IsBuffShow(id) then
        return
    end

    local idx = nil
    for k,v in ipairs(self.buff_list_data or {}) do
        if v.id == id then
            idx = k
            break
        end
    end

    if idx then
        table.remove(self.buff_list_data, idx)

        local item_num = #self.buff_list_data
        self.ui_list_buff:SetItemNum(item_num)
    end

    if self._buff_view then
        self._buff_view:UpdateData(self.buff_list_data)
    end
end

function MainUIView:OnBuffCdCallback(buff_item)
    self:OnMainRoleDelBuff(buff_item:GetBuffId())
end

local function sort_buff_func(v1, v2)
    return v1.id<v2.id
end

function MainUIView:DoSortBuffListData()
    table.sort(self.buff_list_data, sort_buff_func)
end

function MainUIView:RefreshHp()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        self.bar_hp:SetProgressValue(main_role:GetHpPercent() * 100)
    end
end

function MainUIView:RefreshMp()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        self.bar_mp:SetProgressValue(main_role:GetMpPercent() * 100)
    end
end

function MainUIView:InitMainCom()
    --跨服演武
    self.img_main_1 = self.node_main:GetChild("img_main_1")
    self.img_main_1:AddClickCallBack(function()
        game.CarbonCtrl.instance:OpenView()
    end)

    --帮会
    self.img_main_2 = self.node_main:GetChild("img_main_2")
    self.img_main_2:AddClickCallBack(function()
        game.CarbonCtrl.instance:DungLeaveReq()
        game.GuildCtrl.instance:OpenView()
    end)

    --活动大厅
    self.img_main_3 = self.node_main:GetChild("img_main_3")
    self.img_main_3:AddClickCallBack(function()
        game.ActivityMgrCtrl.instance:OpenActivityHallView()
    end)

    --竞技场
    self.img_main_4 = self.node_main:GetChild("img_main_4")
    self.img_main_4:AddClickCallBack(function()
        game.ArenaCtrl.instance:OpenArenaView()
    end)
end

function MainUIView:InitFightCom()
    self:InitTaskCom()
    self:InitTrustCom()
    self:InitChatCom()
    self:InitMapCom()
    self:InitSkillCom()
    self:InitTargetCom()
    self:InitGatherCom()
    self:InitBossComing()
    self:InitMakeTeam()
    
    self.list_func_5 = self.node_fight:GetChild("list_func_5")

    self.btn_toggle = self.node_fight:GetChild("btn_toggle")
    self.btn_vip = self.node_fight:GetChild("btn_vip")
    self.btn_rank = self.node_fight:GetChild("btn_rank")

    self.btn_toggle:AddClickCallBack(function()
        
    end)

    self.btn_toggle:AddChangeCallback(function(event_type)
        local is_selected = (event_type==game.ButtonChangeType.Selected)
        self:OnClickFightToggle(is_selected)
        self:SetGuideIndex(is_selected and 1 or 0)
        game.ViewMgr:FireGuideEvent()
    end)

    
    
    self:UpdateVipLevel()
    self.btn_vip:AddClickCallBack(function()
        game.VipCtrl.instance:OpenView()
    end)

    self.btn_rank:AddClickCallBack(function()
        game.RankCtrl.instance:OpenRankView()
    end)

    self.btn_mount = self.node_fight:GetChild("btn_mount")
    self.btn_mount:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            if not main_role:HasMount() then
                game.GameMsgCtrl.instance:PushMsg(config.words[505])
                return
            end

            local state = main_role:GetMountState()
            if state == 1 then
                state = 0
            else
                state = 1
            end
            if main_role:CanRideMount(state) then
                main_role:SetMountState(state)
            end
        end
    end)

    local pk_mode_open = false
    self.touch_com = self.node_fight:GetChild("touch_com")
    self.touch_com:SetVisible(false)
    self.touch_com:AddClickCallBack(function()
        self.touch_com:SetVisible(false)
        self.pk_mode_panel:SetVisible(false)
        pk_mode_open = false
    end)

    self.pk_mode_img = self.node_fight:GetChild("pk_mode/mode")
    self.pk_mode_panel = self.node_fight:GetChild("pk_mode/panel")
    self.node_fight:GetChild("pk_mode/bg"):SetTouchDisabled(false)
    self.node_fight:GetChild("pk_mode/bg"):AddClickCallBack(function()
        pk_mode_open = not pk_mode_open
        if pk_mode_open then
            self.pk_mode_panel:SetVisible(true)
            self.touch_com:SetVisible(true)
        else
            self.pk_mode_panel:SetVisible(false)
            self.touch_com:SetVisible(false)
        end
    end)

    for i=1,6 do
        local img_word = self.node_fight:GetChild(string.format("pk_mode/m%d", i))
        img_word:SetSprite("ui_main", "ms_0" .. i)
        
        local mbg = self.node_fight:GetChild("pk_mode/mbg" .. i)
        mbg:SetTouchDisabled(false)
        mbg:AddClickCallBack(function()
            local id = game.Scene.instance:GetSceneID()
            local cfg = config.scene[id]
            local sel_mode = 0
            if cfg then
                for k,v in ipairs(cfg.mode) do
                    if v == i then
                        sel_mode = i
                        break
                    end
                end
            end

            self.pk_mode_panel:SetVisible(false)
            self.touch_com:SetVisible(false)
            pk_mode_open = false
            if not game.Scene.instance:CanChangePkMode() then
                game.GameMsgCtrl.instance:PushMsg(config.words[509])
                return
            end
            if sel_mode > 0 then
                game.Scene.instance:SendChangeSceneModeReq(sel_mode)
            else
                game.GameMsgCtrl.instance:PushMsg(config.words[508])
            end
        end)

        if game.IsZhuanJia then
            img_word:SetVisible(i<=3)
            mbg:SetVisible(i<=3)
        end
    end

    if game.IsZhuanJia then
        self.btn_mount:SetVisible(false)

        self.node_fight:GetChild("pk_mode/n3"):SetSize(279, 45)
    end
end

function MainUIView:InitTaskCom()
    self.task_com = self.node_fight:GetChild("task_com")

    self.main_task_template = self:GetTemplate("game/main/main_task_template", "node_fight/task_com")    

    if game.IsZhuanJia then
        local group_open = self.task_com:GetChild("group_open")
        group_open:SetVisible(false)
    end
end

function MainUIView:InitMakeTeam()
    self.make_team_com = self.node_fight:GetChild("make_team_com")

    self.make_team_template = self:GetTemplate("game/main/make_team_template", "node_fight/make_team_com")   
end

function MainUIView:InitTrustCom( ... )
    self.trust_com = self.node_fight:GetChild("trust_com")

    self.btn_trust = self.trust_com:GetChild("btn_trust")
    self.btn_aim = self.trust_com:GetChild("btn_aim")

    self.btn_trust:AddClickCallBack(function()
        self:OnClickBtnTrust()        
    end)

    self.btn_aim:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            if main_role:GetTarget() then
                local list = {}
                local func = function(obj)
                    if main_role:CanAttackObj(obj) then
                        table.insert(list, obj)
                    end
                end
                main_role:ForeachAoiObj(func)
                if #list > 0 then
                    main_role:SelectTarget(list[math.random(#list)])
                end
            else
                main_role:SearchEnemy()
            end
        end
    end)

    self.btn_aim:SetLongClickLinkCallBack(function()
        self.ctrl:OpenOtherPlayerView()
    end)
end

function MainUIView:InitChatCom()
    self.chat_com = self.node_fight:GetChild("chat_com")
    self.chat_com:AddClickCallBack(function()
        game.ChatCtrl.instance:OpenView()
    end)

    local item_num = 2
    self.list_chat_item = self.chat_com:GetChild("list_item")
    self.list_chat_item:SetItemNum(item_num)

    self.list_chat_objs = {}
    for i=1,item_num do
        local obj = self.list_chat_item:GetChildAt(i-1)
        local title = obj:GetChild("title")
        title:SetupEmoji("ui_emoji", 24, 24)
        table.insert(self.list_chat_objs, obj)
    end

    self.cur_chat_index = 0
end

function MainUIView:InitMapCom()
    self.map_com = self.node_fight:GetChild("map_com")
    self.map_com:AddClickCallBack(function()
        --game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/main_view/node_fight/map_com"})

        game.WorldMapCtrl.instance:OpenCurMapView()
    end)

    self.img_mini_map = self.map_com:GetChild("img_mini_map")
    self.txt_map_name = self.map_com:GetChild("txt_map_name")
    
    self.txt_map_pos = self.map_com:GetChild("txt_pos")

    self.btn_camera = self.map_com:GetChild("btn_camera")
    self.btn_camera:AddClickCallBack(function()
        game.GmCtrl.instance:OpenView()
    end)
end

function MainUIView:InitSys()
    self.func_to_btn_list = {}

    for k,v in pairs(config.func or {}) do
        local group = self.list_func_tb[v.group]
        if group then
            local btn_func = group[v.idx]
            if btn_func then          
                self:SetBtnSprite(btn_func, v.icon)
                self:SetBtnRedPoint(btn_func, v.check_red_func())
                btn_func:SetVisible(v.check_visible_func())
                btn_func:AddClickCallBack(v.click_func)

                self.func_to_btn_list[v.id] = btn_func
            end
        end
    end
end

function MainUIView:GetFuncBtn(func_id)
    if self.func_to_btn_list then
        return self.func_to_btn_list[func_id]
    end
end

function MainUIView:SetBtnSprite(btn, res_name)
    local icon1 = btn:GetChild("n1")
    local icon2 = btn:GetChild("n2")

    if icon1 then
        icon1:SetSprite("ui_main", res_name)
    end

    if icon2 then
        icon2:SetSprite("ui_main", res_name)
    end
end

function MainUIView:SetBtnRedPoint(btn, is_red)
    local img_red = btn:GetChild("img_red")
    if img_red then
        img_red:SetVisible(is_red)
    end
end

function MainUIView:SwitchToFighting()
    self.node_fight:SetVisible(true)
    self.node_main:SetVisible(false)    
end

function MainUIView:SwitchToMainCity()
    self.node_fight:SetVisible(false)
    self.node_main:SetVisible(true)
end

function MainUIView:SwitchToArena()
    self.node_fight:SetVisible(false)
    self.node_main:SetVisible(false)    
end

function MainUIView:OnUpdateRedPoint(func_id, is_red)
    local btn_func = self.func_to_btn_list[func_id]
    if btn_func then
        self:SetBtnRedPoint(btn_func, is_red)
    end
end

function MainUIView:OnUpdateMainRoleInfo(data)
    if self._combat_power ~= data.combat_power then
        self._combat_power = data.combat_power
        self.txt_fight:SetText("z" .. data.combat_power or "")
    end
    
    if self._hp_percent ~= data.hp_percent then
        self._hp_percent = data.hp_percent

        self.bar_hp:SetProgressValue(self._hp_percent)
    end

    if self._mp_percent ~= data.mp_percent then
        self._mp_percent = data.mp_percent

        self.bar_mp:SetProgressValue(self._mp_percent)
    end
end

function MainUIView:OnClickFightToggle(is_selected)
    self:DoOpenFight(is_selected)
end

function MainUIView:DoOpenFight(is_open_fight)
    self.skill_com:SetVisible(is_open_fight)
    self.trust_com:SetVisible(is_open_fight)

    self.list_func_5:SetVisible(not is_open_fight)
    self.task_com:SetVisible(not is_open_fight)
end

function MainUIView:UpdateMapInfo(x, y)
    local cur_scene_id = game.Scene.instance:GetSceneID()
    local scene_cfg = config.scene[cur_scene_id]
    if not scene_cfg then return end

    self.txt_map_name:SetText(scene_cfg.name)
end

function MainUIView:OnOpenChatView()
    self.chat_com:SetVisible(false)
end

function MainUIView:OnCloseChatView()
    self.chat_com:SetVisible(true)
end

function MainUIView:OnUpdateNewChat(data)
    self.cur_chat_index = self.cur_chat_index + 1
    local idx = ((self.cur_chat_index-1)%2 + 1)
    local chat_obj = self.list_chat_objs[idx]
    if not chat_obj then
        return
    end

    local channel_name = game.ChatChannelWord[data.channel] or ""
    local color = game.ChatChannelColor[data.channel]
    local name_color = game.ChatGenderColor[data.sender.gender] or game.ColorString.Green
    local str_name = (data.sender.name~="" and (data.sender.name .. "：") or "")
    local str_content = ""
    if data.is_rumor then
        str_content = string.format("<font color='#%s'>%s</font>%s", name_color, str_name, data.content or "" )
    else
        str_content = string.format("<font color='#%s'>【%s】</font><font color='#%s'>%s</font>%s", color, channel_name, name_color, str_name, data.content or "" )

        str_content = string.gsub(str_content, "width=0 height=0", function()
            return "width=28 height=28"
        end)

    end
    
    chat_obj:SetText(str_content)
end

function MainUIView:RefreshLevel()
    if not self.role_old_lv then
        self.role_old_lv = 0
    end
    if not self.role_old_exp then
        self.role_old_exp = 0
    end

    local vo = game.Scene.instance:GetMainRoleVo()
    local lv = vo.level
    local exp = vo.exp

    if lv ~= self.role_old_lv then
        self.role_old_lv = lv
        self.txt_lv:SetText(lv)
    end

    if exp ~= self.role_old_exp then
        local max_exp = config.level[lv] and config.level[lv].exp or 100
        local percent = (exp*100)/max_exp
        local delta_percent = math.max((exp-self.role_old_exp)*100/max_exp, 0)
        self.txt_exp_percent:SetText( string.format("%.2f%%", percent))

        if self.role_old_exp <= 0 or percent<=5 then
            self.bar_exp:SetProgressValue(percent)
        else
            self.bar_exp:TweenValue(percent, delta_percent/(100*0.5))
        end
        self.role_old_exp = exp
    end
end

function MainUIView:OnStartPlay()
    self:RefreshRoleHead()
    self:RefreshHp()
    self:RefreshMp()
    self:RefreshSkillList()
    self:RefreshTarget()
    self:RefreshGather(false)
    self:UpdateMapInfo()
    self:RefreshPkMode()
end

function MainUIView:OnStopPlay()
end

function MainUIView:OnHangChange(val)
    self.btn_trust:SetSelected(val)
end

function MainUIView:RefreshPkMode()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        self.pk_mode_img:SetSprite("ui_main", "ms_0" .. main_role:GetPkMode())
    end
end

function MainUIView:InitGatherCom()
    self.gather_bar = self.node_fight:GetChild("gather_bar")
    self.gather_txt = self.gather_bar:GetChild("txt")
    self.gather_bar:SetVisible(false)

    self.group_engry = self.gather_bar:GetChild("group_engry")
    self.gather_energy_txt = self.gather_bar:GetChild("txt_enrgy")
end

function MainUIView:InitBossComing()
    self.boss_coming = self.node_fight:GetChild("boss_coming")
end

function MainUIView:PlayBossComing()
    self.boss_coming:SetVisible(true)
    self.boss_coming:PlayTransition("t0", function()
        self.boss_coming:SetVisible(false)
    end)
end

function MainUIView:RefreshGather(enable, txt, time, vitality_str)
    if enable then
        self.gather_bar:SetVisible(true)
        self.gather_txt:SetText(txt)
        self.gather_bar:SetProgressValue(0)
        self.gather_bar:SetProgressValueTween(100, time)

        self.group_engry:SetVisible(vitality_str~=nil)
        if vitality_str then
            self.gather_energy_txt:SetText(vitality_str)
        end
    else
        self.gather_bar:SetVisible(false)
    end
end

function MainUIView:OperateChangeScene(enable, scene_id, time)
    if enable then
        local cfg = config.scene[scene_id]
        local name = string.format(config.words[506], cfg.name)
        self:RefreshGather(enable, name, time or 1)
    else
        self:RefreshGather(enable)
    end
end



-- skill
function MainUIView:InitSkillCom()    
    self.skill_com = self.node_fight:GetChild("skill_com")

    self.btn_switch_skill = self.skill_com:GetChild("btn_switch_skill")
    self.btn_switch_skill:AddClickCallBack(function()
        self.cur_skill_switch_idx = self.cur_skill_switch_idx + 1

        local from_list = self.skill_switch_list_1
        local to_list = self.skill_switch_list_2
        if self.cur_skill_switch_idx%2 == 0 then
            from_list = self.skill_switch_list_2
            to_list = self.skill_switch_list_1
        end

        for _,v in ipairs(from_list) do
            v:SetVisible(false)
        end

        for _,v in ipairs(to_list) do
            v:SetVisible(true)
        end
    end)

    self.cur_skill_switch_idx = 1
    self.skill_switch_list_1 = {}
    self.skill_switch_list_2 = {}

    self.skill_btn_list = {}
    for i=1,8 do
        local info = {}
        self.skill_btn_list[i] = info

        info.btn = self.skill_com:GetChild("btn_skill_" .. i)
        info.icon = info.btn:GetChild("icon")
        info.mask = info.btn:GetChild("mask")
        info.cd_txt = info.btn:GetChild("cd")
        info.cd_val = 0
        info.tween_val = 1
        info.btn:AddClickCallBack(function()
            if info.enabled then
                self:OnSkillBtnTouch(i)
            else
                game.GameMsgCtrl.instance:PushMsg(config.words[2206])
            end
        end)

        local switch_list = self.skill_switch_list_1
        if i <= 4 then
            switch_list = self.skill_switch_list_2
        end
        table.insert(switch_list, info.btn)
    end

    self:RefreshSkillList()
end

function MainUIView:RefreshSkillList()
    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local tmp_list = {}
    local skill_list = main_role:GetSkillList()
    for k,v in pairs(skill_list) do
        if not v.is_normal then
            table.insert(tmp_list, k)
        end
    end
    table.sort(tmp_list, function(a,b)
        return a < b
    end)

    local info
    local career = main_role:GetCareer()
    local skill_career_cfg = config_skill_career[career]
    local ConfigHelpSkill = config_help.ConfigHelpSkill
    for i,v in ipairs(self.skill_btn_list) do
        info = main_role:GetSkillInfo(tmp_list[i])
        v.enabled = (info~=nil)
        --v.btn:SetTouchEnable(info ~= nil)
        v.btn:SetGray(info == nil)
        v.mask:SetFillAmount(0)
        v.cd_txt:SetText("")

        if info then
            v.skill_id = info.id
            v.skill_lv = info.lv

            local icon = ConfigHelpSkill.GetSkillCfg(v.skill_id, v.skill_lv, info.hero, info.legend, "icon")
            if icon then
                v.icon:SetSprite("ui_main", icon)
            end
        else
            v.skill_id = nil
            v.skill_lv = nil

            local cfg = skill_career_cfg[i]
            local skill_id = cfg.skill_id
            local skill_cfg = config_skill[skill_id][1]
            local icon = skill_cfg.icon
            if icon then
                v.icon:SetSprite("ui_main", icon)
            end
        end
    end
end

function MainUIView:OnSkillBtnTouch(idx)
    local btn_info = self.skill_btn_list[idx]
    if not btn_info.skill_id then
        return
    end

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local skill_info = main_role:GetSkillInfo(btn_info.skill_id)
    if not skill_info then
        return
    end

    if global.Time.now_time > skill_info.next_play_time then
        if main_role:CanDoAttack(btn_info.skill_id) then
            local to_obj_client = main_role:GetSkillToObjClient(btn_info.skill_id)
            if to_obj_client == 3 then
                main_role:DoAttack(skill_info.id, skill_info.lv)
            else
                local target = main_role:GetSkillTarget(btn_info.skill_id)
                if not target then
                    if to_obj_client == 2 then
                        main_role:DoAttack(skill_info.id, skill_info.lv)
                    else
                        game.GameMsgCtrl.instance:PushMsg(config.words[507])
                    end
                else
                    main_role:SetNextSkill(btn_info.skill_id)
                    main_role:GetOperateMgr():DoAttackTarget(target.obj_id, true)
                end
            end
        end
    end
end

function MainUIView:UpdateSkillCD(now_time, elapse_time)
    for i=1,8 do
        self:UpdateSkillCDTween(i, now_time)
    end
end

function MainUIView:UpdateSkillCDTween(idx, now_time)
    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local btn_info = self.skill_btn_list[idx]
    if not btn_info.skill_id then
        return
    end

    local skill_info = main_role:GetSkillInfo(btn_info.skill_id)
    if not skill_info then
        return
    end

    local left_time = skill_info.next_play_time - now_time
    if left_time < 0 then
        left_time = 0
    end

    local val = left_time / skill_info.cd
    if val ~= btn_info.tween_val then
        btn_info.tween_val = val
        btn_info.mask:SetFillAmount(val)
        if left_time == 0 then
            btn_info.cd_txt:SetText("")
            btn_info.cd_val = 0
        else
            local num = math.ceil(left_time)
            if btn_info.cd_val ~= num then
                if btn_info.cd_val == 0 then
                    btn_info.cd_txt:InvalidateBatchingState()
                end
                btn_info.cd_val = num
                btn_info.cd_txt:SetText(num)
            end
        end
    end
end

function MainUIView:InitTargetCom()
    self.target_info = {
        visible = true,
        com = self._layout_objs["node_fight/target_com"],
        hp_bar = self._layout_objs["node_fight/target_com/n1"],
        name_txt = self._layout_objs["node_fight/target_com/n2"],
        owner_type_img = self._layout_objs["node_fight/target_com/n3"],
        role_icon = self._layout_objs["node_fight/target_com/role_icon"],
        mon_icon = self._layout_objs["node_fight/target_com/mon_icon"],
    }
end

function MainUIView:RefreshTargetHp(val)
    self.target_info.hp_bar:SetFillAmount(val)
end

function MainUIView:RefreshTargetOwnerType(obj)
    if not obj or obj.obj_id ~= game.Scene.instance:GetMainRole():GetTargetID() then
        return
    end
    local sprite_name
    if obj:IsMonster() then
        local owner_type = obj:GetOwnerType()
        if owner_type == game.OwnerType.Self then
            sprite_name = "jf_02"
        elseif owner_type == game.OwnerType.Others then
            sprite_name = "jf_03"
        end
    end
    local owner_type_img = self.target_info.owner_type_img
    if sprite_name then
        owner_type_img:SetSprite("ui_common", sprite_name)
        owner_type_img:SetVisible(true)
    else
        owner_type_img:SetVisible(false)
    end
end

function MainUIView:RefreshTarget(obj)
    if obj then
        if not self.target_info.visible then
            self.target_info.visible = true
            self.target_info.com:SetVisible(true)
        end
        if obj:IsMonster() then
            self.target_info.mon_icon:SetVisible(true)
            self.target_info.role_icon:SetVisible(false)
            self.target_info.mon_icon:SetSprite("ui_headicon", obj:GetIconID())
        else
            self.target_info.mon_icon:SetVisible(false)
            self.target_info.role_icon:SetVisible(true)
            self.target_info.role_icon:SetSprite("ui_main", obj.vo.career)
        end
        self.target_info.name_txt:SetText(string.format("Lv.%d %s", obj:GetLevel(), obj:GetName()))
        self:RefreshTargetHp(obj:GetHpPercent())
        self:RefreshTargetOwnerType(obj)
    else
        if self.target_info.visible then
            self.target_info.visible = false
            self.target_info.com:SetVisible(false)
        end
    end
end

function MainUIView:GetTargetCom()
    return self.target_info.com
end

-- Pet
function MainUIView:InitPetCom()
    local pet_com = self.node_fight:GetChild("pet_com")
    self.pet_template = require("game/main/pet_template").New()
    self.pet_template:SetVirtual(pet_com)
    self.pet_template:Open()
    self.pet_template:BindObjID(nil)
end

function MainUIView:ClearPetCom()
    if self.pet_template then
        self.pet_template:DeleteMe()
        self.pet_template = nil
    end
end

function MainUIView:RefreshPetCom(obj_id)
    if self.pet_template then
        self.pet_template:BindObjID(obj_id)
    end
end

function MainUIView:UpdateVipLevel()
    local vip_lv = game.VipCtrl.instance:GetVipLevel()
    local boundle_name = "ui_main"
    local asset_name = string.format("VIP_%d", vip_lv)
    self.btn_vip:SetIcon(boundle_name, asset_name)
end

function MainUIView:UpdatePassBossRedPoint()
    local pass_ctrl = game.PassBossCtrl.instance
    local is_red = pass_ctrl:CheckRedPoint()
    self.img_map_red:SetVisible(is_red)
end

function MainUIView:OnUpdateReward(pass_id)
    self:UpdatePassBossRedPoint()
end

function MainUIView:DoMainRoleHang(val)
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        if val then
            main_role:GetOperateMgr():DoSceneHang()
        else
            main_role:GetOperateMgr():DoStop()
        end
    end
end

function MainUIView:OnClickBtnTrust()
    local is_selected = self.btn_trust:GetSelected()
    self:DoMainRoleHang(is_selected)
end

function MainUIView:OnMainRoleAutoPass(val)
    self.btn_trust:SetSelected(val)
    self:DoMainRoleHang(val)
end

function MainUIView:InitMoney()
    self.ctrl:OpenMoneyView()
end

function MainUIView:SetActTime(time)
    if time then
        self._layout_objs["node_fight/act_time"]:SetText(time)
        self._layout_objs["node_fight/act_time_bg"]:SetVisible(true)
    else
        self._layout_objs["node_fight/act_time"]:SetText("")
        self._layout_objs["node_fight/act_time_bg"]:SetVisible(false)
    end
end

function MainUIView:OnBossComing()
    self:OnHangChange(true)

    self:PlayBossComing()
end

function MainUIView:OnUpdateVipInfo()
    self:UpdateVipLevel()
end

function MainUIView:CheckActivityTips()
    game.ActivityMgrCtrl.instance:CheckActivityTips()
end

-- 组队
function MainUIView:OnUpdateTeamCreate()
    
end

function MainUIView:OnTeamLeave()
    
end

function MainUIView:OnTeamMemberLeave()
    
end

function MainUIView:OnUpdateJoinTeam()
    
end

function MainUIView:OnUpdateKickOut()
    
end

function MainUIView:DoTerritoryBattleHide(val)
    local visible = not val
    self.task_com:SetVisible(visible)
    self.btn_mount:SetVisible(visible)
    self.btn_toggle:SetVisible(visible)
    self.list_func_5:SetVisible(visible)
end

return MainUIView