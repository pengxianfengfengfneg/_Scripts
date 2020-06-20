local MainNewView = Class(game.BaseView)

local handler = handler
local config_skill = config.skill
local config_skill_career = config.skill_career
local config_scene = config.scene
local config_effect_desc = config.effect_desc
local UserDefault = global.UserDefault
local global_Time = global.Time

local MidTopEffect = {
    AutoFighting = 1,
    TaskComplete = 2,
}

function MainNewView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "new_main_view"
    self.add_to_view_mgr = false
    self._cache_time = 10

    self._ui_order = game.UIZOrder.UIZOrder_Main_UI

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl

    self:SetGuideIndex(0)
end

function MainNewView:OpenViewCallBack()
    self:Init()
    self:InitMidTop()
    self:InitMidBottom()
    self:InitLeftMid()
    self:InitRightMid()
    self:InitGesture()
    self:InitMoney()

    self:SetShowSkillCom(true)

    self:RegisterAllEvents()

    self:FireEvent(game.ViewEvent.MainViewReady, true)
end

function MainNewView:CloseViewCallBack()
    self:FireEvent(game.ViewEvent.MainViewReady, false)

    self:ClearPetCom()
    self:ClearFuncForeshowCom()
    self:ClearBuffList()
    self:ClearGesture()
end

function MainNewView:RegisterAllEvents()
    local event_list = {
        { game.RedPointEvent.UpdateRedPoint, handler(self, self.OnUpdateRedPoint), },
        { game.RoleEvent.UpdateMainRoleInfo, handler(self, self.OnUpdateMainRoleInfo), },
        { game.ChatEvent.UpdateNewChat, handler(self, self.OnUpdateNewChat), },
        { game.RoleEvent.LevelChange, handler(self, self.RefreshLevel), },
        { game.GameEvent.StartPlay, handler(self, self.OnStartPlay), },
        { game.GameEvent.StopPlay, handler(self, self.OnStopPlay), },
        { game.SceneEvent.MainRoleHpChange, handler(self, self.RefreshHp), },
        { game.SceneEvent.MainRoleMpChange, handler(self, self.RefreshMp), },
        { game.SceneEvent.TargetChange, handler(self, self.RefreshTarget), },
        { game.SceneEvent.TargetHpChange, handler(self, self.RefreshTargetHp), },
        { game.SceneEvent.TargetMpChange, handler(self, self.RefreshTargetMp), },
        { game.SceneEvent.TargetOwnerTypeChange, handler(self, self.RefreshTargetOwnerType), },
        { game.SceneEvent.HangChange, handler(self, self.OnHangChange), },
        { game.SceneEvent.GatherChange, handler(self, self.RefreshGather), },
        { game.SceneEvent.MainRolePetChange, handler(self, self.RefreshPetCom), },
        { game.SceneEvent.MainRoleSkillChange, handler(self, self.RefreshSkillList), }, 
        { game.SceneEvent.PkModeChange, handler(self, self.RefreshPkMode), }, 
        { game.SceneEvent.MainRoleAddBuff, handler(self, self.OnMainRoleAddBuff), }, 
        { game.SceneEvent.MainRoleDelBuff, handler(self, self.OnMainRoleDelBuff), }, 
        { game.SceneEvent.OperateChangeScene, handler(self, self.OperateChangeScene), },
        { game.MakeTeamEvent.UpdateTeamCreate, handler(self, self.OnUpdateTeamCreate), }, 
        { game.MakeTeamEvent.TeamLeave, handler(self, self.OnTeamLeave), }, 
        { game.MakeTeamEvent.TeamMemberLeave, handler(self, self.OnTeamMemberLeave), }, 
        { game.MakeTeamEvent.ChangeLeader, handler(self, self.OnChangeLeader), }, 
        { game.MakeTeamEvent.OnTeamGetInfo, handler(self, self.OnTeamGetInfo), },        
        { game.TaskEvent.OnUpdateTaskInfo, handler(self, self.OnUpdateTaskInfo)},
        { game.TaskEvent.OnAcceptTask, handler(self, self.OnAcceptTask)},
        { game.TaskEvent.OnGetTaskReward, handler(self, self.OnGetTaskReward)},
        { game.TaskEvent.HangTaskSeeking, handler(self, self.OnHangTaskSeeking)},

        { game.ObjStateEvent.MoveState, handler(self, self.OnMoveState)},

        { game.OpenFuncEvent.SetShowFunc, handler(self, self.OnSetShowFunc)},
        { game.SceneEvent.MainRoleTargetAddBuff, handler(self, self.OnMainRoleTargetAddBuff)},
        { game.SceneEvent.MainRoleTargetDelBuff, handler(self, self.OnMainRoleTargetDelBuff)},
        { game.SceneEvent.OnSkillSpeak, handler(self, self.OnSkillSpeak)},
        { game.OpenFuncEvent.OpenFuncNew, handler(self, self.OnOpenFuncNew)},
        { game.OpenFuncEvent.ShowFuncsEffect, handler(self, self.OnShowFuncsEffect)},
        { game.SceneEvent.MainRolePetDie, handler(self, self.OnPetStateChange)},
        { game.LoginEvent.LoginReconnectFinish, handler(self, self.OnReconnect)},
        { game.SceneEvent.MainRoleIconChange, handler(self, self.RefreshRoleHead)},
        { game.GuildEvent.UpdateGuildLuckyMoneyReceiveNum, handler(self, self.RefreshLuckyMoney)},

        { game.SkillEvent.UpdateSkillAnger, handler(self, self.OnUpdateSkillAnger)},
        { game.RoleEvent.UpdateCurFrame, handler(self, self.OnUpdateCurFrame)},

        { game.MsgNoticeEvent.UpdateMsgNotice, handler(self, self.OnUpdateMsgNotice)},
        { game.FireworkEvent.ShowFireworkUIEffect, handler(self, self.OnShowFireworkUIEffect)},
        { game.SceneEvent.OnPlayBigSkill, handler(self, self.OnPlayBigSkill)},

        { game.MarryEvent.MateDie, handler(self, self.OnMateDie)},
        { game.MarryEvent.UpdateSkillCD, handler(self, self.OnMateSkillUpdate)},
        { game.MarryEvent.MateNear, handler(self, self.OnMateNear)},
        { game.SceneEvent.ChangeScene, handler(self, self.OnChangeScene), },
    }
    for _,v in ipairs(event_list) do
        self:BindEvent(v[1], v[2])
    end
end

local next_check_skill_time = 0
function MainNewView:Update(now_time, elapse_time)
    if now_time > next_check_skill_time then
        next_check_skill_time = now_time + 0.05
        self:UpdateSkillCD(now_time, elapse_time)
    end

    self:UpdateMapPos()
    self:UpdateGesture(now_time, elapse_time)

    if self.showing_hp_counter then
        self.showing_hp_counter = self.showing_hp_counter + elapse_time

        if self.showing_hp_counter >= self.showing_hp_time then
            self.showing_hp_counter = nil
            self:HideHpMp()
        end
    end

    self.task_com:Update(now_time, elapse_time)
    self.task_members:Update(now_time, elapse_time)
    self.chat_com:Update(now_time, elapse_time)
    self.make_team_com:Update(now_time, elapse_time)

    if self.firework_effect_del_time then
        if now_time >= self.firework_effect_del_time then
            self:ClearFireworkEffect()
        end
    end
end

function MainNewView:Init()
    self.node_fixed = self._layout_objs["node_fixed"]
    self.node_main = self._layout_objs["node_main"]
    self.node_fight = self._layout_objs["node_fight"]
end

function MainNewView:InitMidTop()
    self.mid_top = self._layout_objs["mid_top"]
    
    self:InitRoleInfo()
    self:InitPetCom()
    self:InitTargetCom()
    self:InitPkMode()
    self:InitMapInfo()
    self:InitMakeTeamCom()
    self:InitSeek()
    self:InitFuncForeshowCom()
end

function MainNewView:InitMidBottom()
    self.mid_bottom = self._layout_objs["mid_bottom"]

    self:InitChatCom()
    self:InitFuncGroup()
    self:InitSkillCom()
    self:InitTaskCom()
    self:InitGatherCom()
    self:InitBottomInfo()
    self:InitMsgNocice()
    self:InitMateSkill()
end

function MainNewView:InitBottomInfo()
    self.is_show_skill = false

    self.btn_toggle = self._layout_objs["mid_bottom/btn_toggle"]
    self.btn_toggle:AddClickCallBack(function()
        self:SetShowSkillCom(not self.is_show_skill)
    end)

    self.is_trust_on = false
    self.btn_trust = self._layout_objs["mid_bottom/btn_trust"]
    self.btn_trust:AddClickCallBack(function()
        if self.is_trust_long_click then
            self.is_trust_long_click = false
            return
        end
        self:OnClickBtnTrust()
    end)

    self.btn_trust:SetLongClickLinkCallBack(function()
        self.is_trust_long_click = true
        game.SkillCtrl.instance:OpenSkillSettingView()
    end)

    self.img_trust_on = self.btn_trust:GetChild("img_on")
    self.img_trust_follow_on = self.btn_trust:GetChild("img_folllow_on")

    self.btn_aim = self._layout_objs["mid_bottom/btn_aim"]
    self.btn_aim:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            local list = {}
            local func = function(obj)                
                if main_role:CanAttackObj(obj) then
                    local target = main_role:GetTarget()
                    if target and target:GetUniqueId() == obj:GetUniqueId() then
                        return
                    end

                    table.insert(list, obj)
                end
            end
            main_role:ForeachAoiObj(func)

            if #list > 0 then
                local target = list[math.random(#list)]
                main_role:SelectTarget(target)
            end
        end
    end)

    self.btn_mount = self._layout_objs["mid_bottom/btn_mount"]
    self.btn_mount:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            local state = main_role:GetMountState()
            if state == 1 then
                state = 0
            else
                state = 1
            end
            if main_role:CanRideMount(state, true) then
                main_role:SetMountState(state)
            end
        end
    end)

    self.btn_action = self._layout_objs["mid_bottom/btn_action"]
    self.btn_action:AddClickCallBack(function()
        game.MainUICtrl.instance:OpenPlayActionView()
        self:SetShowLeftMid(false)
    end)

    self.btn_setting = self._layout_objs["mid_bottom/btn_setting"]
    self.btn_setting:AddClickCallBack(function()
        game.SysSettingCtrl.instance:OpenView()
        self:SetShowLeftMid(false)
    end)

    self.btn_aim:SetLongClickLinkCallBack(function()
        self.ctrl:OpenOtherPlayerView()
    end)

    self.btn_exit = self._layout_objs["mid_bottom/btn_exit"]
    self.btn_exit:AddClickCallBack(function()
        local tips_word = config.words[141]
        local scene_id = game.Scene.instance:GetSceneID()
        local dun_id = config_help.ConfigHelpDungeon.GetDunForScene(scene_id)
        if dun_id then
            tips_word = config.words[140]
        elseif scene_id == config.sys_config["guild_seat_scene"].value then
            tips_word = config.words[6006]
        end

        local title = string.format(config.words[143], tips_word)
        local content = string.format(config.words[142], tips_word)
        local msg_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content)
        msg_view:SetOkBtn(function()
            local scene_logic = game.Scene.instance:GetSceneLogic()
        scene_logic:DoSceneLogicExit()
        end, config.words[5010], true)

        msg_view:SetCancelBtn(function()
            
        end, config.words[5011])
        msg_view:Open()
    end)

    self.btn_detail = self._layout_objs["mid_bottom/btn_detail"]
    self.btn_detail:AddClickCallBack(function()
        local scene_logic = game.Scene.instance:GetSceneLogic()
        scene_logic:DoSceneLogicDetail()
    end)
end

function MainNewView:InitMsgNocice()
    self.list_tips = self._layout_objs["mid_bottom/list_tips"]
    self.list_tips.foldInvisibleItems = true

    self.btn_tips_hb = self._layout_objs["mid_bottom/list_tips/btn_tips_hb"]
    self.btn_tips_hb:AddClickCallBack(function()
        self:RefreshLuckyMoney(0)
        game.LuckyMoneyCtrl.instance:OpenView()
    end)

    self.btn_tips_hb:SetVisible(false)
    self:RefreshLuckyMoney(0)

    self.btn_tips_hero = self._layout_objs["mid_bottom/list_tips/btn_tips_hero"]
    self.btn_tips_hero:AddClickCallBack(function()
        game.HeroCtrl.instance:OpenView(1)
    end)

    self.btn_tips_hero:SetVisible(false)

    self.btn_tips_sys = self._layout_objs["mid_bottom/list_tips/btn_tips_sys"]
    self.btn_tips_sys:AddClickCallBack(function()
        game.MsgNoticeCtrl.instance:OpenView(game.MsgNoticeType.System)
    end)

    self.btn_tips_act = self._layout_objs["mid_bottom/list_tips/btn_tips_act"]
    self.btn_tips_act:AddClickCallBack(function()
        game.MsgNoticeCtrl.instance:OpenView(game.MsgNoticeType.Activity)
    end)

    self.btn_tips_social = self._layout_objs["mid_bottom/list_tips/btn_tips_social"]
    self.btn_tips_social:AddClickCallBack(function()
        game.MsgNoticeCtrl.instance:OpenView(game.MsgNoticeType.Social)
    end)

    self:CheckMsgActivity()
    self:OnUpdateMsgNotice()
end

function MainNewView:CheckMsgActivity()
    game.ActivityMgrCtrl.instance:CheckMsgActivity()
end

function MainNewView:SetShowBtnExit(val)
    self.btn_exit:SetVisible(val)
end

function MainNewView:SetShowBtnDetail(val)
    self.btn_detail:SetVisible(val)
end

function MainNewView:SetShowTaskCom(val)
    self.task_com:SetVisible(val)
    self.task_members:SetVisible(val)
end

function MainNewView:SetDunAssistEnable(val)
    self.make_team_com:SetDunAssistEnable(val)
end

function MainNewView:InitLeftMid()
    self.left_mid = self._layout_objs["left_mid"]

    self:InitOtherCom()
end

function MainNewView:InitOtherCom()
    self.is_other_visible = false
    local btn_other = self._layout_objs["left_mid/btn_other"]
    btn_other:AddClickCallBack(function()
        self:SetShowLeftMid(not self.is_other_visible)
    end)

    local list_func = self._layout_objs["left_mid/list_func"]
    --local btn_mount = list_func:GetChild("btn_mount")
    --btn_mount:AddClickCallBack(function()
    --    local main_role = game.Scene.instance:GetMainRole()
    --    if main_role then
    --        local state = main_role:GetMountState()
    --        if state == 1 then
    --            state = 0
    --        else
    --            state = 1
    --        end
    --        if main_role:CanRideMount(state, true) then
    --            main_role:SetMountState(state)
    --        end
    --    end
    --end)

    -- local btn_action = list_func:GetChild("btn_action")
    --btn_action:AddClickCallBack(function()
    --    game.MainUICtrl.instance:OpenPlayActionView()
    --    self:SetShowLeftMid(false)
    -- end)

    --local btn_setting = list_func:GetChild("btn_setting")
    --btn_setting:AddClickCallBack(function()
    --    game.SysSettingCtrl.instance:OpenView()
--
    --    self:SetShowLeftMid(false)
    --end)

    --local btn_strengthen = list_func:GetChild("btn_strengthen")
    --btn_strengthen:AddClickCallBack(function()
    --    game.StrengthenCtrl.instance:OpenView()
--
    --    self:SetShowLeftMid(false)
    --end)
end

function MainNewView:InitRightMid()
    
end

function MainNewView:InitRoleInfo()
    self.txt_lv = self._layout_objs["mid_top/txt_lv"]
    self.txt_fight = self._layout_objs["mid_top/txt_fight"]

    self.bar_exp = self._layout_objs["mid_bottom/bar_exp"]
    self.bar_exp2 = self._layout_objs["mid_bottom/bar_exp2"]
    self.txt_exp_percent = self._layout_objs["mid_bottom/txt_exp_percent"]
       
    self.img_hp = self._layout_objs["mid_top/img_hp"]
    self.img_mp = self._layout_objs["mid_top/img_mp"]

    self.txt_hp_per = self._layout_objs["mid_top/txt_hp_per"]
    self.txt_mp_per = self._layout_objs["mid_top/txt_mp_per"]

    self.img_team_leader = self._layout_objs["mid_top/img_team_leader"]

    self.btn_strengthen = self._layout_objs["mid_top/btn_strengthen"]


--------------------------组队设置-----------------------------------------------
    self.make_team_com_bg = self._layout_objs["mid_top/make_team_com"]
    self.btn_come_out = self._layout_objs["mid_top/make_team_com/btn_come_out"]
    self.btn_add_member = self._layout_objs["mid_top/make_team_com/btn_add_member"]
    self.team = self._layout_objs["mid_top/make_team_com/team"]
    local list_btn = self._layout_objs["mid_top/make_team_com/list_btn"]
    self.btn_goin = list_btn:GetChild("btn_goin")

    local btn_zudui = list_btn:GetChild("btn_zudui")
    local btn_zuduibg = btn_zudui:GetChild("n1")
    btn_zuduibg:SetGray(true)

    self:UpdateTeamLeaderFlag()

    self.btn_come_out:AddClickCallBack(function()
        self:SetShowLeftTeam(true)
        local value = self.make_team_com:Getval()
        if value == nil then
            self.team:SetVisible(false)
            btn_zuduibg:SetGray(true)
            self.make_team_com:Setval(2)
        end
        local role_id = game.Scene.instance:GetMainRoleID()
        local member_info = game.MakeTeamCtrl.instance:GetTeamMemberById(role_id)
        self.btn_add_member:SetVisible(member_info == nil)
    end)

    self.btn_goin:AddClickCallBack(function()
        self:SetShowLeftTeam(false)
    end)

-------------------------------组队设置-----------------------------------------------


    self.btn_strengthen:AddClickCallBack(function()
        game.StrengthenCtrl.instance:OpenView()

        self:SetShowLeftMid(false)
    end)

    local touch_hp = self._layout_objs["mid_top/touch_hp"]
    touch_hp:AddClickCallBack(function()
        -- 显示生命/气量
        --game.GmCtrl.instance:OpenView()
        self:ShowHpMp()
    end)

    self.head_icon = self:GetIconTemplate("mid_top/head_icon")

    local touch_head = self._layout_objs["mid_top/touch_head"]
    touch_head:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:SelectTarget(main_role)
        end
    end)

    local fight = game.Scene.instance:GetMainRolePower()
    self.txt_fight:SetText("z" .. fight)

    local touch_fight = self._layout_objs["mid_top/touch_fight"]
    touch_fight:AddClickCallBack(function()
        if game.PlatformCtrl.instance:IsDevMode() then
            game.GmCtrl.instance:OpenView()
        end
    end)

    self:RefreshLevel()

    self:RefreshRoleHead()
    self:InitBuffList()
end

function MainNewView:SetShowLeftTeam(val)
    local action
    if val == true then
        action = "t1"
    else
        action = "t0"
    end
    self.make_team_com_bg:PlayTransition(action)
end

function MainNewView:ShowHpMp()
    self.showing_hp_counter = 0
    self.showing_hp_time = 3

    self.txt_hp_per:SetVisible(true)
    self.txt_mp_per:SetVisible(true)
end

function MainNewView:HideHpMp()
    self.showing_hp_counter = nil

    self.txt_hp_per:SetVisible(false)
    self.txt_mp_per:SetVisible(false)
end

function MainNewView:RefreshRoleHead()
    local main_role_vo = game.Scene.instance:GetMainRoleVo()
    if main_role_vo then
        self.head_icon:UpdateData(main_role_vo)

        if self.target_info then
            self.target_info.role_icon:UpdateData(main_role_vo)
        end
    end
end

function MainNewView:InitMapInfo()
    self.txt_scene_name = self._layout_objs["mid_top/txt_scene_name"]
    self.txt_scene_pos = self._layout_objs["mid_top/txt_scene_pos"]
    self.txt_server_line = self._layout_objs["mid_top/txt_server_line"]

    local touch_map = self._layout_objs["mid_top/touch_map"]
    touch_map:AddClickCallBack(function()
        game.WorldMapCtrl.instance:OpenCurMapView()
    end)
end

local MapPos = {x=0, y=0}
function MainNewView:UpdateMapPos()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        local logic_pos = main_role:GetLogicPos()
        if logic_pos.x~=MapPos.x or logic_pos.y~=MapPos.y then
            MapPos.x = logic_pos.x
            MapPos.y = logic_pos.y

            self.txt_scene_pos:SetText(string.format(config.words[148], MapPos.x, MapPos.y))
        end
    end
end

function MainNewView:RefreshServerLine()
    local server_line = game.Scene.instance:GetServerLine()
    self.txt_server_line:SetText(string.format(config.words[149], math.max(server_line,1)))
end

function MainNewView:InitBuffList()
    self.my_buff_list = {}
    self.my_buff_list.version = 0
    self.my_buff_list.buff_list = {}
    for i=1,4 do
        local obj = require("game/main/buff_item").New(self.ctrl, self.my_buff_list)
        obj:SetVirtual(self._layout_objs["mid_top/my_buff" .. i])
        obj:Open()
        self.my_buff_list[i] = obj
    end

    self.target_buff_list = {}
    self.target_buff_list.version = 0
    self.target_buff_list.buff_list = {}
    for i=1,4 do
        local obj = require("game/main/buff_item").New(self.ctrl, self.target_buff_list)
        obj:SetVirtual(self._layout_objs["mid_top/target_buff" .. i])
        obj:Open()
        self.target_buff_list[i] = obj
    end

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        self:RefreshBuff(self.my_buff_list, main_role)
        self:RefreshBuff(self.target_buff_list, main_role:GetTarget())
    else
        self:RefreshBuff(self.my_buff_list)
        self:RefreshBuff(self.target_buff_list)
    end
end

function MainNewView:ClearBuffList()
    for i,v in ipairs(self.my_buff_list) do
        v:DeleteMe()
    end
    self.my_buff_list = nil

    for i,v in ipairs(self.target_buff_list) do
        v:DeleteMe()
    end
    self.target_buff_list = nil
end

function MainNewView:IsBuffShow(buff_id)
    return config_effect_desc[buff_id]
end

local function sort_buff_func(v1, v2)
    return v1.id < v2.id
end

function MainNewView:RefreshBuff(ls, obj)
    for i=1,#ls.buff_list do
        ls.buff_list[i] = nil
    end

    if obj then
        local buff_list = obj:GetBuffList()
        if buff_list then
            for _,v in pairs(buff_list) do
                if self:IsBuffShow(v.id) then
                    table.insert(ls.buff_list, v)
                end
            end
            table.sort(ls.buff_list, sort_buff_func)
        end
    end

    for i,v in ipairs(ls) do
        v:UpdateData(ls.buff_list[i])
    end
    ls.version = ls.version + 1
end

function MainNewView:_OnAddBuff(ls, buff_info)
    if not self:IsBuffShow(buff_info.id) then
        return
    end

    if buff_info.is_new then
        table.insert(ls.buff_list, buff_info)
        table.sort(ls.buff_list, sort_buff_func)
    end

    for i,v in ipairs(ls) do
        v:UpdateData(ls.buff_list[i])
    end
    ls.version = ls.version + 1
end

function MainNewView:_OnDelBuff(ls, uid)
    for k,v in ipairs(ls.buff_list) do
        if v.uid == uid then
            table.remove(ls.buff_list, k)
            break
        end
    end

    for i,v in ipairs(ls) do
        v:UpdateData(ls.buff_list[i])
    end
    ls.version = ls.version + 1
end

function MainNewView:OnMainRoleAddBuff(buff_info)
    self:_OnAddBuff(self.my_buff_list, buff_info)
end

function MainNewView:OnMainRoleDelBuff(uid)
    self:_OnDelBuff(self.my_buff_list, uid)
end

function MainNewView:OnMainRoleTargetAddBuff(buff_info)
    self:_OnAddBuff(self.target_buff_list, buff_info)
end

function MainNewView:OnMainRoleTargetDelBuff(uid)
    self:_OnDelBuff(self.target_buff_list, uid)
end

function MainNewView:RefreshHp()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        local percent = main_role:GetHpPercent()
        self.img_hp:SetFillAmount(percent)
        self.txt_hp_per:SetText(string.format("%.f%%", percent*100))
    end
end

function MainNewView:RefreshMp()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        local percent = main_role:GetMpPercent()
        self.img_mp:SetFillAmount(percent)
        self.txt_mp_per:SetText(string.format("%.f%%", percent*100))
    end
end

function MainNewView:InitTaskCom()
    self.task_com = self:GetTemplate("game/main/main_new/task_com", "mid_bottom/task_com")
    self.task_members = self:GetTemplate("game/main/main_new/task_com_menmbers", "mid_top/make_team_com/task_members")
end

function MainNewView:ShowTask(task_id)
    self.task_com:ShowTask(task_id)
end

function MainNewView:GetShowingTask()
    return self.task_com:GetShowingTask()
end

function MainNewView:OnUpdateTaskInfo(data)
    self:UpdateMainTask()
end

function MainNewView:OnAcceptTask()
    self:UpdateMainTask()
end

function MainNewView:OnGetTaskReward(task_id, is_main_task)
    if is_main_task then

    end

    -- 显示完成特效
    self:ShowTaskCompleteEffect(true)
end

function MainNewView:ShowTaskCompleteEffect(val)
    local effect_node = self:GetMidTopEffectNode(MidTopEffect.TaskComplete)
    if val then
        local effect = self:CreateUIEffect(effect_node, string.format("effect/ui/%s.ab", "rw_wc"))
        effect:SetLoop(false)
        global.AudioMgr:PlaySound("qt001")
    else
        self:StopUIEffect(effect_node)
    end
end

function MainNewView:UpdateMainTask()
    do return end

    local task_ctrl = game.TaskCtrl.instance
    local main_task_info = task_ctrl:GetMainTaskInfo()
    if main_task_info then
        local task_id = main_task_info.id
        local task_cfg = task_ctrl:GetTaskCfg(task_id)
        local task_name = string.format(config.words[2151], config.words[2161], task_cfg.name)

        local task_state = main_task_info.stat
        local cond = main_task_info.masks[1]
        -- if not cond and task_state <= 1 then
        --     task_state = 2
        -- end

        if task_state == game.TaskState.Acceptable then
            self.txt_task_name:SetText(config.words[2189])
            self.rtx_task_desc:SetText(task_name)
        else
            local task_desc = task_cfg.desc
            if cond then
                local str_process = game.TaskStateWord[task_state]
                if task_state == game.TaskState.Accepted then
                    str_process = string.format("%s/%s", cond.current, cond.total)
                end
                task_desc = string.format(config.words[2191], task_desc, str_process)
            end

            self.txt_task_name:SetText(task_name)
            self.rtx_task_desc:SetText(task_desc)
        end
    end
end

function MainNewView:InitMakeTeamCom()
    self.make_team_com = self:GetTemplate("game/main/main_new/make_team_com", "mid_top/make_team_com")   
end

function MainNewView:InitSeek()
    self.group_seek = self._layout_objs["mid_top/group_seek"]
    self.txt_task_seek = self._layout_objs["mid_top/txt_task_seek"]

    self.txt_auto_fighting = self._layout_objs["mid_top/txt_auto_fighting"]    
end

function MainNewView:UpdateSeek(val, target_name)
    self.group_seek:SetVisible(val)
    self.txt_task_seek:SetText(target_name or "")

    --self.txt_auto_fighting:SetVisible(not val)
end

local __DefaultName = {name = ""}
function MainNewView:OnHangTaskSeeking(task_id, is_start)
    local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id) or __DefaultName
    
    self:UpdateSeek(is_start, task_cfg.name)
end

function MainNewView:InitChatCom()
    self.chat_com_obj = self._layout_objs["mid_bottom/chat_com"]

    self.chat_com = self:GetTemplate("game/main/main_new/chat_com", "mid_bottom/chat_com")
end

function MainNewView:InitFuncGroup()
    self.func_group_1_obj = self._layout_objs["mid_bottom/func_group_1"]

    self.list_func_groups = {
        self:GetTemplate("game/main/main_new/func_group_1", "mid_bottom/func_group_1"),
        self:GetTemplate("game/main/main_new/func_group_4", "mid_bottom/func_group_4"),

        self:GetTemplate("game/main/main_new/func_group_2", "mid_top/func_group_2"),
        self:GetTemplate("game/main/main_new/func_group_3", "mid_top/func_group_3"),
    }
end

function MainNewView:GetFuncBtn(func_id)
    for _,v in ipairs(self.list_func_groups or game.EmptyTable) do
        local btn = v:GetFuncBtn(func_id)
        if btn then
            return btn
        end
    end
    return nil
end

function MainNewView:GetBtnPos(func_id)
    local target = self:GetFuncBtn(func_id)
    if target then
        local global_pos_x, global_pos_y = target:GetRoot():ToGlobalPos(0, 0)
        local target_pos_x, target_pos_y = self:GetRoot():ToLocalPos(global_pos_x, global_pos_y)
        return target_pos_x, target_pos_y
    end
end

function MainNewView:OnUpdateRedPoint(func_id, is_red)    
    for _,v in ipairs(self.list_func_groups) do
        v:OnUpdateRedPoint(func_id, is_red) 
    end

    self:CheckToggleRedPoint()
end

function MainNewView:CheckToggleRedPoint()
    local is_group_red = (self.list_func_groups[1]:IsRedPoint() and self.is_show_skill)
    game_help.SetRedPoint(self.btn_toggle, is_group_red, -5, 5)
end

function MainNewView:SetFuncVisible(func_id, val)
    for _,v in ipairs(self.list_func_groups) do
        v:SetFuncVisible(func_id, val)
    end
end

function MainNewView:OnSetShowFunc(func_id, val)
    self:SetFuncVisible(func_id, val)
end

function MainNewView:InitSkillCom()
    self:InitRoleSkillCom()
    self:InitPetSkillCom()
    self:InitBigSkillCom()

    -- self:RefreshSkillList()
    -- self:RefreshPetSkill()
    -- self:RefreshBigSkill()

    --self:UpdateSkillLayout()
end

function MainNewView:InitRoleSkillCom()
    self.skill_com = self._layout_objs["mid_bottom/skill_com"]

    local img_bg = self._layout_objs["mid_bottom/skill_com/img_bg"]
    --img_bg:SetVisible(false)

    local list_skill = self._layout_objs["mid_bottom/skill_com/list_skill"]
    self.role_list_skill = list_skill

    self.skill_btn_list = {}
    local item_num = list_skill:GetItemNum()
    for i=1,item_num do
        local btn = list_skill:GetChildAt(i-1)
        local info = {
            btn = btn,
            icon = btn:GetChild("icon"),
            mask = btn:GetChild("mask"),
            cd_txt = btn:GetChild("title"),
            cd_val = 0,
            tween_val = 1,
        }

        info.eff = self:CreateUIEffect(btn:GetChild("eff"), "effect/ui/jn_chongzhi.ab")
        info.eff:SetLoop(true)
        -- info.eff:SetVisible(false)

        self.skill_btn_list[i] = info

        btn:AddClickCallBack(function()
            if info.enabled then
                self:OnSkillBtnTouch(i)
            else
                game.GameMsgCtrl.instance:PushMsg(config.words[2206])
            end
        end)
    end
end

function MainNewView:InitPetSkillCom()
    self.btn_pet_skill = self._layout_objs["mid_bottom/skill_com/btn_pet_skill"]
    self.btn_pet_skill:AddClickCallBack(function()
        self:OnPetSkillBtnTouch()
    end)
    self.pet_skill_info = {
        btn = self.btn_pet_skill,
        icon = self.btn_pet_skill:GetChild("icon"),
        mask = self.btn_pet_skill:GetChild("img_mask"),
        cd_txt = self.btn_pet_skill:GetChild("title"),
    }
end

function MainNewView:InitBigSkillCom()
    self.btn_skill_big = self._layout_objs["mid_bottom/skill_com/btn_skill_big"]
    self.btn_skill_big:AddClickCallBack(function()
        self:OnBigSkillBtnTouch()
    end)
    self.big_skill_info = {
        btn = self.btn_skill_big,
        icon = self.btn_skill_big:GetChild("icon"),
        mask = self.btn_skill_big:GetChild("mask"),
        effect = self.btn_skill_big:GetChild("eff"),
        cd_txt = self.btn_skill_big:GetChild("title"),
        img_anger = self.btn_skill_big:GetChild("img_anger"),
        has_skill = false,
    }
end

function MainNewView:OnUpdateMainRoleInfo(data)
    if self._combat_power ~= data.combat_power then
        self._combat_power = data.combat_power
        self.txt_fight:SetText("z" .. data.combat_power or "")
    end
    
    if self._hp_percent ~= data.hp_percent then
        self._hp_percent = data.hp_percent

        self.img_hp:SetFillAmount(self._hp_percent)
    end

    if self._mp_percent ~= data.mp_percent then
        self._mp_percent = data.mp_percent

        self.img_mp:SetFillAmount(self._mp_percent)
    end
end

function MainNewView:UpdateMapInfo(x, y)
    local scene_name = game.Scene.instance:GetSceneName()
    self.txt_scene_name:SetText(scene_name)
end

function MainNewView:OnUpdateNewChat(data)
    self.chat_com:OnUpdateNewChat(data)
end

function MainNewView:RefreshLevel()
    if not self.role_old_lv then
        self.role_old_lv = 0
    end
    if not self.role_old_exp then
        self.role_old_exp = -1
    end

    local vo = game.Scene.instance:GetMainRoleVo()
    local lv = vo.level
    local exp = vo.exp

    if lv ~= self.role_old_lv then
        if self.role_old_lv > 0 then
            self:ShowLvupEffect()
        end
        self.role_old_lv = lv
        self.txt_lv:SetText(lv)

        self:UpdateFuncForeshowCom()
    end

    local bar_list = {self.bar_exp, self.bar_exp2}

    if exp ~= self.role_old_exp then
        local max_exp = config.level[lv] and config.level[lv].exp or 100
        local percent = math.floor((exp*100)/max_exp)
        local delta_percent = math.max((exp-self.role_old_exp)*100/max_exp, 0)
        self.txt_exp_percent:SetText(string.format(config.words[147], exp, max_exp, percent))

        local keep_exp = game.LakeExpCtrl.instance:GetKeepExp()
        local bar_index = 1
        local duration = delta_percent/(100*0.5)

        if keep_exp == 0 then
            if self.role_old_exp <= 0 or percent<=5 then
                self.bar_exp:SetProgressValue(percent)
            else
                self.bar_exp:TweenValue(percent, duration)
            end
        else
            --天灵丹经验条
            local bar_exp = self.bar_exp2:GetChild("n1")
            local bar_keep_exp = self.bar_exp2:GetChild("n2")
            local keep_exp_percent = (exp+keep_exp)*100/max_exp
            if self.role_old_exp <= 0 or percent<=5 then
                bar_exp:SetProgressValue(percent)
                bar_keep_exp:SetProgressValue(keep_exp_percent)
            else
                bar_exp:TweenValue(percent, duration)
                bar_keep_exp:TweenValue(keep_exp_percent, duration)
            end
            bar_index = 2
        end

        for k, v in ipairs(bar_list) do
            v:SetVisible(k==bar_index)
        end

        self.role_old_exp = exp
    end

    local pet_open_lv = config.func[game.OpenFuncId.Pet].show_lv[1]
    if self.pet_template then
        self.pet_template:SetVisible(lv >= pet_open_lv)
    end
end

function MainNewView:OnReconnect()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        self:RefreshBuff(self.my_buff_list, main_role)
    end
end

function MainNewView:OnStartPlay()
    self:RefreshRoleHead()
    self:RefreshHp()
    self:RefreshMp()
    self:RefreshSkillList()
    self:RefreshBigSkill()
    self:RefreshPetSkill()
    self:RefreshTarget()
    self:RefreshGather(false)
    self:UpdateMapInfo()
    self:UpdateMapPos()
    self:RefreshPkMode()
    self:RefreshServerLine()

    self:UpdateSkillLayout()

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        self:RefreshBuff(self.my_buff_list, main_role)
    end
end

function MainNewView:OnStopPlay()
end

function MainNewView:OnHangChange(val)
    self.is_trust_on = val
    self.img_trust_on:SetVisible(val)

    --self.btn_trust:SetSelected(val)
    --self.txt_auto_fighting:SetVisible(val)

    self:ShowAutoFightingEffect(val)

    if val then
        self.group_seek:SetVisible(false)

        self:SwitchToFighting()
    end
end

function MainNewView:IsHanging()
    return self.is_trust_on
end

function MainNewView:RefreshPkMode()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        self.pk_mode_img:SetSprite("ui_main", "ms_0" .. main_role:GetPkMode(), true)
    end
end

function MainNewView:InitGatherCom()
    self.gather_state = nil
end

--刷新读取条
function MainNewView:RefreshGather(enable, txt, time, vitality_str)
    if self.gather_state == enable then
        return
    end

    self.gather_state = enable
    if enable then
        game.MainUICtrl.instance:OpenGatherBarView(txt, time, vitality_str)
    else
        game.MainUICtrl.instance:CloseGatherBarView()
    end
end

function MainNewView:OperateChangeScene(enable, scene_id, time)
    if enable then
        local cfg = config.scene[scene_id]
        local name = string.format(config.words[539], cfg.name)
        self:RefreshGather(enable, name, time or 1)
    else
        self:RefreshGather(enable)
    end
end

function MainNewView:RefreshPetSkill()
    local has_pet_skill = false
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        local pet = main_role:GetPet()
        if pet then
            local skill_list = pet:GetSkillList()
            if skill_list then
                if not pet:IsDead() then
                    local skill_id, skill_lv
                    for k,v in pairs(skill_list) do
                        if v.is_manual_skill then
                            skill_id = v.id
                            skill_lv = v.lv
                            break
                        end
                    end

                    if skill_id then
                        local cfg = config_skill[skill_id][skill_lv]
                        if cfg then
                            has_pet_skill = true
                            self.pet_skill_info.skill_id = skill_id
                            self.pet_skill_info.icon:SetSprite("ui_skill_icon", cfg.icon) 
                            self.pet_skill_info.mask:SetVisible(true)
                            self.pet_skill_info.cd_txt:SetVisible(true)           
                        end
                    end
                end
            end
        end
    end

    self.pet_skill_info.btn:SetVisible(has_pet_skill)
end

local AngerSkillDungeonID = 3002
local AngerSkillEventID = 20030105
function MainNewView:CheckBigSkill()
    local dun_info = game.CarbonCtrl.instance:GetDungeDataByID(AngerSkillDungeonID)
    if not dun_info then
        return false
    end

    local cur_scene = game.Scene.instance
    if cur_scene:IsAngerSkillScene() then
        local last_scene_id = cur_scene:GetLastSceneID()
        local main_role = cur_scene:GetMainRole()
        local key = string.format("%s_%s", main_role:GetUniqueId(), AngerSkillEventID)
        if (not last_scene_id) or UserDefault:GetBool(key, false) then
            local vo = main_role:GetVo()
            vo.anger = 10000
            return true
        end
    end

    return (dun_info.max_lv>=1)
end

function MainNewView:ForceShowBigSkill()
    self.big_skill_info.btn:SetVisible(true)
    self:OnUpdateSkillAnger()
    self:UpdateSkillLayout()
end

function MainNewView:RefreshBigSkill()
    local has_big_skill = false
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        local career = main_role:GetCareer()
        local skill_id = game.CareerBigSkill[career]
        if skill_id then
            local skill_info = main_role:GetSkillInfo(skill_id)
            if skill_info then
                local cfg = config_skill[skill_id][skill_info.lv]
                if cfg then
                    has_big_skill = true
                    self.big_skill_info.has_skill = true
                    self.big_skill_info.skill_id = skill_id
                    self.big_skill_info.skill_anger = cfg.anger
                    self.big_skill_info.icon:SetSprite("ui_skill_icon", cfg.icon) 
                    self.big_skill_info.mask:SetVisible(true)
                    self.big_skill_info.cd_txt:SetVisible(true)
                end
            end
        end
    end

    local is_visible = (has_big_skill and self:CheckBigSkill())
    self.big_skill_info.btn:SetVisible(is_visible)
    self:OnUpdateSkillAnger()
end

function MainNewView:RefreshSkillList()
    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local tmp_list = {}
    local skill_list = main_role:GetSkillList()
    for k,v in pairs(skill_list) do
        if not v.is_normal and v.anger<=0 then
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
                v.icon:SetSprite("ui_skill_icon", icon)
            end
        else
            v.skill_id = nil
            v.skill_lv = nil

            local cfg = skill_career_cfg[i]
            local skill_id = cfg.skill_id
            local skill_cfg = config_skill[skill_id][1]
            local icon = skill_cfg.icon
            if icon then
                v.icon:SetSprite("ui_skill_icon", icon)
            end
        end
    end
end

function MainNewView:UpdateSkillLayout()
    local has_pet_skill = self.pet_skill_info.btn:IsVisible()
    local has_big_skill = self.big_skill_info.btn:IsVisible()

    local is_skill_offset = (has_pet_skill or has_big_skill)
    local offset_x = (is_skill_offset and 102 or 51)
    self.role_list_skill:SetPositionX(offset_x)

    if has_pet_skill and has_big_skill then
        self.pet_skill_info.btn:SetPositionY(9)
        self.big_skill_info.btn:SetPositionY(96)
    elseif has_pet_skill then
        self.pet_skill_info.btn:SetPositionY(56)
    else
        self.big_skill_info.btn:SetPositionY(50)
    end
end

function MainNewView:CheckTeamFollowState()
    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return false
    end

    local is_in_follow = false
    local make_team_ctrl = game.MakeTeamCtrl.instance
    local is_leader = make_team_ctrl:IsLeader(main_role:GetUniqueId())
    if is_leader then
        is_in_follow = make_team_ctrl:IsTeamFollow()
    else
        local state = make_team_ctrl:GetMemberFollowState(main_role:GetUniqueId())
        is_in_follow = (state == game.TeamFollowState.Follow)
    end

    if is_in_follow then
        -- 正在跟随中
        game.GameMsgCtrl.instance:PushMsg(config.words[5015])
        return true
    end
    return false
end

function MainNewView:OnSkillBtnTouch(idx)
    local btn_info = self.skill_btn_list[idx]
    if not btn_info.skill_id then
        return
    end

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    if self:CheckTeamFollowState() then
        return
    end

    local skill_info = main_role:GetSkillInfo(btn_info.skill_id)
    if not skill_info then
        return
    end

    if global.Time.now_time > skill_info.next_play_time then
        if not main_role:IsHanging() and main_role:CanDoAttack(btn_info.skill_id, true) then
            main_role:GetOperateMgr():DoJoystickAttack(btn_info.skill_id)
        else
            local target = main_role:GetSkillTarget(btn_info.skill_id)
            if not target or skill_info.to_obj_client == 3 then
                if skill_info.to_obj_client ~= 2 and skill_info.to_obj_client ~= 3 then
                    game.GameMsgCtrl.instance:PushMsg(config.words[507])
                    return
                end
            end
            main_role:SetNextSkill(btn_info.skill_id)
        end
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[522])
    end
end

function MainNewView:OnPetSkillBtnTouch()
    local btn_info = self.pet_skill_info
    if not btn_info.skill_id then
        return
    end

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local pet = main_role:GetPet()
    if not pet then
        return
    end

    if self:CheckTeamFollowState() then
        return
    end

    local skill_info = pet:GetSkillInfo(btn_info.skill_id)
    if not skill_info then
        return
    end

    if global.Time.now_time > skill_info.next_play_time then
        if pet:CanDoAttack(btn_info.skill_id, true) then
            pet:GetOperateMgr():DoJoystickAttack(btn_info.skill_id)
        end
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[522])
    end
end

function MainNewView:OnBigSkillBtnTouch()
    local btn_info = self.big_skill_info
    if not btn_info.skill_id then
        return
    end

    local cur_anger = game.Scene.instance:GetMainRoleAnger()
    if cur_anger < btn_info.skill_anger then
        game.GameMsgCtrl.instance:PushMsg(config.words[2228])
        return
    end

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    if self:CheckTeamFollowState() then
        return
    end

    local skill_info = main_role:GetSkillInfo(btn_info.skill_id)
    if not skill_info then
        return
    end

    if global.Time.now_time > skill_info.next_play_time then
        if not main_role:IsHanging() and main_role:CanDoAttack(btn_info.skill_id, true) then
            main_role:GetOperateMgr():DoJoystickAttack(btn_info.skill_id)
        else
            main_role:SetNextSkill(btn_info.skill_id)
        end
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[522])
    end
end

function MainNewView:UpdateSkillCD(now_time, elapse_time)
    for i=1,8 do
        self:UpdateSkillCDTween(i, now_time)
    end
    self:UpdatePetSkillCDTween(now_time)

    self:UpdateBigSkillCDTween(now_time)
end

function MainNewView:UpdateSkillCDTween(idx, now_time)
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
            btn_info.eff:Replay()
            btn_info.eff:SetVisible(true)
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

function MainNewView:UpdatePetSkillCDTween(now_time)
    local btn_info = self.pet_skill_info
    if not btn_info.skill_id then
        return
    end

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local pet = main_role:GetPet()
    if not pet then
        return
    end

    local skill_info = pet:GetSkillInfo(btn_info.skill_id)
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

function MainNewView:UpdateBigSkillCDTween(now_time)
    local btn_info = self.big_skill_info
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

            self:OnUpdateSkillAnger()
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

function MainNewView:InitTargetCom()
    self.target_info = {
        visible = true,
        com = self._layout_objs["mid_top/target_com"],
        hp_bar = self._layout_objs["mid_top/target_com/img_hp"],
        mp_bar = self._layout_objs["mid_top/target_com/img_mp"],
        name_txt = self._layout_objs["mid_top/target_com/txt_name"],
        owner_type_img = self._layout_objs["mid_top/target_com/img_owner"],
        role_icon = self:GetIconTemplate("mid_top/target_com/head_icon"),
        mon_icon = self._layout_objs["mid_top/target_com/mon_icon"],
        txt_lv = self._layout_objs["mid_top/target_com/txt_lv"],        
        btn_switch = self._layout_objs["mid_top/target_com/btn_switch"],
    }
    self.target_info.btn_switch:SetTouchDisabled(false)
    self._layout_objs["mid_top/target_com/head_icon"]:AddClickCallBack(function()
        if self.target_information and self.target_information.role_id and not game.RoleCtrl.instance:IsSelf(self.target_information) then
            game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.ViewOthers, self.target_information.role_id)
        end
    end)
end

function MainNewView:RefreshTargetHp(val)
    self.target_info.hp_bar:SetFillAmount(val)
end

function MainNewView:RefreshTargetMp(val)
    self.target_info.mp_bar:SetFillAmount(val)
end

function MainNewView:RefreshTargetOwnerType(obj)
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

function MainNewView:RefreshTarget(obj)
    if obj then
        self.target_information = obj.vo
        if not self.target_info.visible then
            self.target_info.visible = true
            self.target_info.com:SetVisible(true)
        end

        if obj:IsMonster() or obj:IsPet() then
            self.target_info.mon_icon:SetVisible(true)
            self.target_info.role_icon:SetVisible(false)
            self.target_info.mon_icon:SetSprite("ui_headicon", obj:GetIconID())
        else
            self.target_info.mon_icon:SetVisible(false)
            self.target_info.role_icon:SetVisible(true)

            self.target_info.role_icon:UpdateData(self.target_information)
        end

        local lv = obj:GetLevel()
        self.target_info.name_txt:SetText(obj:GetName())
        self.target_info.txt_lv:SetText(lv)

        self:RefreshTargetHp(obj:GetHpPercent())
        self:RefreshTargetMp(obj:GetMpPercent())
        self:RefreshTargetOwnerType(obj)

        if obj:GetObjType() == game.ObjType.Role then
            self.target_info.btn_switch:SetSprite("ui_main", "zjm_14")
            self.target_info.btn_switch:SetVisible(true)
            self.target_info.btn_switch:AddClickCallBack(function()
                local pet_objs = game.Scene.instance:GetObjByType(game.ObjType.Pet, function(scene_pet_obj)
                    return obj.vo.cur_pet == scene_pet_obj.vo.id
                end)
                if #pet_objs > 0 then
                    local main_role = game.Scene.instance:GetMainRole()
                    if main_role then
                        main_role:SelectTarget(pet_objs[1])
                    end
                end
            end)
        elseif obj:GetObjType() == game.ObjType.Pet then
            self.target_info.btn_switch:SetSprite("ui_main", "zjm_13")
            self.target_info.btn_switch:SetVisible(true)
            self.target_info.btn_switch:AddClickCallBack(function()
                local role_objs = game.Scene.instance:GetObjByType(game.ObjType.Role, function(scene_pet_obj)
                    return obj.vo.owner_id == scene_pet_obj.vo.role_id
                end)
                if #role_objs > 0 then
                    local main_role = game.Scene.instance:GetMainRole()
                    if main_role then
                        main_role:SelectTarget(role_objs[1])
                    end
                end
            end)
        else
            self.target_info.btn_switch:SetVisible(false)
        end
    else
        self.target_information = nil
        if self.target_info.visible then
            self.target_info.visible = false
            self.target_info.com:SetVisible(false)
        end
    end
    self:RefreshBuff(self.target_buff_list, obj)
end

function MainNewView:GetTargetCom()
    return self.target_info.com
end

-- Pet
function MainNewView:InitPetCom()
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local pet_open_lv = config.func[game.OpenFuncId.Pet].show_lv[1]
    local pet_com = self._layout_objs["mid_top/pet_com"]
    self.pet_template = require("game/main/pet_template").New()
    self.pet_template:SetVirtual(pet_com)
    self.pet_template:Open()
    self.pet_template:BindObjID(nil)
    self.pet_template:SetVisible(role_lv >= pet_open_lv)
end

function MainNewView:ClearPetCom()
    if self.pet_template then
        self.pet_template:DeleteMe()
        self.pet_template = nil
    end
end

function MainNewView:RefreshPetCom(obj_id)
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local pet_open_lv = config.func[game.OpenFuncId.Pet].show_lv[1]
    self.pet_template:SetVisible(role_lv >= pet_open_lv)
    if self.pet_template then
        self.pet_template:BindObjID(obj_id)
    end
    self:RefreshPetSkill()

    self:UpdateSkillLayout()
end

function MainNewView:GetPetCom()
    return self._layout_objs["mid_top/pet_com"]
end

function MainNewView:OnPetStateChange()
    self:RefreshPetSkill()

    self:UpdateSkillLayout()
end

-- pk mode
function MainNewView:InitPkMode()
    self.touch_com = self._layout_objs["touch_com"]

    local pk_mode_open = false
    self.touch_com:AddClickCallBack(function()
        self.touch_com:SetVisible(false)
        self.pk_mode_panel:SetVisible(false)
        pk_mode_open = false
    end)

    self.pk_mode = self._layout_objs["mid_top/pk_mode"]
    self.pk_mode_img = self._layout_objs["mid_top/pk_mode/mode"]
    self.pk_mode_panel = self._layout_objs["mid_top/pk_mode/panel"]

    local pk_mode_bg = self._layout_objs["mid_top/pk_mode/bg"]
    pk_mode_bg:SetTouchDisabled(false)
    pk_mode_bg:AddClickCallBack(function()
        pk_mode_open = not pk_mode_open
        if pk_mode_open then
            self.pk_mode_panel:SetVisible(true)
            self.touch_com:SetVisible(true)
            self.btn_strengthen:SetVisible(false)
        else
            self.pk_mode_panel:SetVisible(false)
            self.touch_com:SetVisible(false)
            self.btn_strengthen:SetVisible(true)
        end
    end)

    local model_list = {1,3,4,2,12,13}
    for i=1,6 do
        local mode = model_list[i]
        local img_word = self._layout_objs[string.format("mid_top/pk_mode/m%d", i)]
        local mbg = self._layout_objs[string.format("mid_top/pk_mode/mbg%s", i)]
        if mode then
            img_word:SetSprite("ui_main", "ms_0" .. mode, true)
            
            mbg:SetTouchDisabled(false)
            mbg:AddClickCallBack(function()
                self.pk_mode_panel:SetVisible(false)
                self.touch_com:SetVisible(false)
                self.btn_strengthen:SetVisible(true)
                pk_mode_open = false

                if mode == 13 then
                    game.GameMsgCtrl.instance:OpenInfoDescView(8)
                elseif mode == 12 then
                    self.ctrl:OpenBattleInfoView()
                else
                    local id = game.Scene.instance:GetSceneID()
                    local cfg = config.scene[id]
                    local sel_mode = 0
                    if cfg then
                        for k,v in ipairs(cfg.mode) do
                            if v == mode then
                                sel_mode = mode
                                break
                            end
                        end
                    end

                    if not game.Scene.instance:CanChangePkMode() then
                        game.GameMsgCtrl.instance:PushMsg(config.words[509])
                        return
                    end
                    if sel_mode > 0 then
                        game.Scene.instance:SendChangeSceneModeReq(sel_mode)
                    else
                        game.GameMsgCtrl.instance:PushMsg(config.words[508])
                    end
                end
            end)
        else
            img_word:SetVisible(false)
            mbg:SetVisible(false)
        end
    end
end

function MainNewView:DoMainRoleHang(val)
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        if val then
            main_role:GetOperateMgr():DoSceneHang()
        else
            main_role:GetOperateMgr():DoStop()
        end
    end
end

function MainNewView:OnClickBtnTrust()
    local is_doing_follow = game.MakeTeamCtrl.instance:IsDoingFollow()
    local is_follow_hang = (is_doing_follow and (not self:IsFollowHanging()) or false)
    
    self:SetFollowHanging(is_follow_hang)
    if is_doing_follow then
        return
    end

    self.is_trust_on = not self.is_trust_on
    self:DoMainRoleHang(self.is_trust_on)
end

function MainNewView:SetFollowHanging(val)
    if self.is_follow_hanging == val then
        return
    end

    self.is_follow_hanging = val
    self.img_trust_follow_on:SetVisible(val)
end

function MainNewView:IsFollowHanging()
    return self.is_follow_hanging
end

function MainNewView:InitMoney()
    self.ctrl:OpenMoneyView()
end

function MainNewView:SetActTime(time)
    -- if time then
    --     self._layout_objs["node_fight/act_time"]:SetText(time)
    --     self._layout_objs["node_fight/act_time_bg"]:SetVisible(true)
    -- else
    --     self._layout_objs["node_fight/act_time"]:SetText("")
    --     self._layout_objs["node_fight/act_time_bg"]:SetVisible(false)
    -- end
end

function MainNewView:CheckActivityTips()
    game.ActivityMgrCtrl.instance:CheckActivityTips()
end

-- 组队
function MainNewView:OnUpdateTeamCreate()
    -- 创建队伍
    self:UpdateTeamLeaderFlag()
end

function MainNewView:OnTeamLeave()
    self:UpdateTeamLeaderFlag()
end

function MainNewView:OnTeamMemberLeave()
    self:UpdateTeamLeaderFlag()
end

function MainNewView:OnChangeLeader()
    self:UpdateTeamLeaderFlag()
end

function MainNewView:OnTeamGetInfo()
    self:UpdateTeamLeaderFlag()
end

function MainNewView:UpdateTeamLeaderFlag()
    local is_leader = game.MakeTeamCtrl.instance:IsSelfLeader()
    self.img_team_leader:SetVisible(is_leader)
end

function MainNewView:SetShowSkillCom(val)
    if self.is_show_skill == val then
        return
    end

    self.is_show_skill = val

    self.func_group_1_obj:SetVisible(not self.is_show_skill)
    self.skill_com:SetVisible(self.is_show_skill)

    self:CheckToggleRedPoint()

    if val then
        for k,v in pairs(self.skill_btn_list) do
            if v.skill_id and v.cd_val == 0 then
                v.eff:Replay()
            end
        end
    end

    self:FireEvent(game.ViewEvent.ShowSkillCom, self.is_show_skill)
end

function MainNewView:SetShowMainFuncGroup(val)
    self:SetShowSkillCom(false)
end

function MainNewView:SetShowLeftMid(val)
    if self.is_playing_other then
        return
    end

    if self.is_other_visible == val then
        return
    end

    self.is_other_visible = val
    if self.is_other_visible then
        self.func_foreshow_template:SetVisible(not self.is_other_visible)
    end

    self.is_playing_other = true
    local action = (self.is_other_visible and "t1" or "t0")
    self.left_mid:PlayTransition(action, function()
        self.is_playing_other = false
        self.func_foreshow_template:SetVisible(not self.is_other_visible)
    end)
end

function MainNewView:SwitchToFighting()
    self:SetShowSkillCom(true)
    self:SetShowLeftMid(false)

    for _,v in ipairs(self.list_func_groups or {}) do
        v:SwitchToFighting()
    end
end

function MainNewView:OnSkillSpeak(name, desc, icon)
    self._layout_objs["skill_speak_com/icon"]:SetSprite("ui_headicon", icon)
    self._layout_objs["skill_speak_com/name"]:SetText(name)
    self._layout_objs["skill_speak_com/desc"]:SetText(desc)
    self._layout_objs["skill_speak_com"]:PlayTransition("t0")
end

function MainNewView:OnOpenFuncNew(new_funcs)
    for k,v in pairs(new_funcs) do
        self:SetFuncVisible(k, true)
    end
end

function MainNewView:RefreshLuckyMoney(receive_num)
    local visible = receive_num > 0
    local is_open = game.LuckyMoneyCtrl.instance:IsOpenView()

    if not visible or not is_open then
        self.btn_tips_hb:SetVisible(visible)
    end
    self.btn_tips_hb:SetText(receive_num)
end

function MainNewView:ShowLvupEffect()
    self:CreateUIEffect(self._layout_objs["effect_wrapper1"], "effect/ui/ui_lvup.ab")
end

-- Pet
function MainNewView:InitFuncForeshowCom()

    local func_foreshow = self._layout_objs["mid_top/func_foreshow"]
    self.func_foreshow_template = require("game/main/func_foreshow_template").New()
    self.func_foreshow_template:SetVirtual(func_foreshow)
    self.func_foreshow_template:Open()

    self:UpdateFuncForeshowCom()
end

function MainNewView:UpdateFuncForeshowCom()
    local index = game.OpenFuncCtrl.instance:GetCurForeshowIndex()
    if index == 9999 then
        self._layout_objs["mid_top/func_foreshow"]:SetVisible(false)
    else
        local cfg = config.func_foreshow[index]
        if self.func_foreshow_template then
            self.func_foreshow_template:UpdateInfo(cfg)
            self._layout_objs["mid_top/func_foreshow"]:SetVisible(true)
        end
    end
end

function MainNewView:ClearFuncForeshowCom()
    if self.func_foreshow_template then
        self.func_foreshow_template:DeleteMe()
        self.func_foreshow_template = nil
    end
end

function MainNewView:OnMoveState(val)
    if val then
        local main_role = game.Scene.instance:GetMainRole()
        if main_role:IsFightState() then
            self:UpdateSeek(false, "")
            return
        end

        local cur_oper = main_role:GetOperateMgr():GetCurOperate()
        if cur_oper and cur_oper:GetOperateType()==game.OperateType.HangTask then
            local task_id = cur_oper:GetCurTaskId()
            local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id) or __DefaultName
            self:UpdateSeek(true, task_cfg.name)
        end
    else
        self:UpdateSeek(false, "")
    end
end

function MainNewView:InitGesture()
    self.gesture_item = require("game/main/gesture_item").New()
    self.gesture_item:SetVirtual(self._layout_objs["gesture_item"])
    self.gesture_item:Open()

    self._layout_objs["gesture_touch_com"]:SetTouchEnable(true)
    self._layout_objs["gesture_touch_com"]:AddClickCallBack(function(x, y)
        self.gesture_item:OnClick(x, y)
    end)

    self._layout_objs["joystick_com"]:SetTouchEnable(true)
    self._layout_objs["joystick_com"]:AddClickCallBack(function(x, y)
        self.gesture_item:OnClick(x, y)
    end)

    self._layout_root:SetTouchEnable(true)
    self._layout_root:AddClickCallBack(function(x, y, is_double)
        -- return false
    end)

    self.camera_com = require("game/main/camera_com").New()
    self.camera_com:SetVirtual(self._layout_objs["camera_com"])
    self.camera_com:Open()

    --角色摇杆
    self.gesture_item_data = require("game/main/gesture_item_data").New()
    self.gesture_item_data:SetVirtual(self._layout_objs["joystick_com"])
    self.gesture_item_data:Open()

    local task_com = self._layout_objs["mid_bottom/task_com"]
    local task_pos_x, task_pos_y = task_com:ToGlobalPos(0, 0)
    local task_pos_max_x, task_pos_max_y = task_pos_x + 425, task_pos_y + 130
    task_pos_x = task_pos_x - 10
    task_pos_y = task_pos_y - 10

    local cam_com = self._layout_objs["camera_com"]
    local cam_pos_x, cam_pos_y = cam_com:ToGlobalPos(0, 0)
    local cam_pos_max_x, cam_pos_max_y = cam_pos_x + 140, cam_pos_y + 140
    cam_pos_x = cam_pos_x - 10
    cam_pos_y = cam_pos_y - 10

    local joys_com = self._layout_objs["joystick_com"]
    local joys_pos_x, joys_pos_y = joys_com:ToGlobalPos(0, 0)
    local joys_pos_max_x, joys_pos_max_y = joys_pos_x + 600, joys_pos_y + 281
    joys_pos_x = joys_pos_x - 10
    joys_pos_y = joys_pos_y - 10

    local team_component = self._layout_objs["mid_top/make_team_com/task_members"]
    local team_pos_x, team_pos_y = team_component:ToGlobalPos(0, 0)
    local team_pos_max_x, team_pos_max_y = team_pos_x + 230, team_pos_y + 100
    team_pos_x = team_pos_x - 10
    team_pos_y = team_pos_y - 10

    self._layout_root:SetTouchBeginCaptureCallBack(function(x, y, is_double, touch_id)
        local nx, ny = x, y--self._layout_root:ToLocalPos(x, y)
        if nx > task_pos_x and ny > task_pos_y and nx < task_pos_max_x and ny < task_pos_max_y then
            return false
        elseif nx > cam_pos_x and ny > cam_pos_y and nx < cam_pos_max_x and ny < cam_pos_max_y then
            return false
        elseif nx > joys_pos_x and ny > joys_pos_y and nx < joys_pos_max_x and ny < joys_pos_max_y then
            return false
        elseif nx > team_pos_x and ny > team_pos_y and nx < team_pos_max_x and ny < team_pos_max_y then
            return false
        end

        self.camera_com:OnJoystickTouchBegin(x, y, is_double, touch_id)
        return false
    end)
    self._layout_root:SetTouchMoveCaptureCallBack(function(x, y, is_double, touch_id)
        self.camera_com:OnJoystickTouchMove(x, y, is_double, touch_id)
        return false
    end)
    self._layout_root:SetTouchEndCaptureCallBack(function(x, y, is_double, touch_id)
        self.camera_com:OnJoystickTouchEnd(x, y, is_double, touch_id)
        return false
    end)

    if self.camera_rot_enable ~= nil then
        self:SetCameraRotEnable(self.camera_rot_enable)
    end

    if self.click_terrain_enable ~= nil then
        self:SetClickTerrainEnable(self.click_terrain_enable)
    end

    if self.camera_rot_state ~= nil then
        self:SetCameraRotState(self.camera_rot_state)
    end
end

function MainNewView:ClearGesture()
    self.camera_rot_enable = nil
    self.click_terrain_enable = nil
    self.camera_rot_state = nil
    self.gesture_item:DeleteMe()
    self.gesture_item = nil
    self.camera_com:DeleteMe()
    self.camera_com = nil
end

function MainNewView:UpdateGesture(now_time, elapse_time)
    if self.gesture_item then
        self.gesture_item:Update(now_time, elapse_time)
    end
    if self.camera_com then
        self.camera_com:Update(now_time, elapse_time)
    end
end

function MainNewView:SetCameraRotEnable(val)
    self.camera_rot_enable = val
    if self.gesture_item then
        self.gesture_item:SetCameraRotEnable(val)
    end
    if self.camera_com then
        self.camera_com:SetCameraRotEnable(val)
    end
end

function MainNewView:SetClickTerrainEnable(val)
    self.click_terrain_enable = val
    if self.gesture_item then
        self.gesture_item:SetClickTerrainEnable(val)
    end
end

function MainNewView:SetCameraRotState(val)
    self.camera_rot_state = val
    if self.gesture_item then
        self.gesture_item:SetCameraRotState(val)
    end
    if self.camera_com then
        self.camera_com:SetCameraRotState(val)
    end
end

function MainNewView:SetGestureCallBack(callback)
    if self.gesture_item then
        self.gesture_item:SetGestureCallBack(callback)
    end
end

function MainNewView:ShowAutoFightingEffect(val)
    local effect_node = self:GetMidTopEffectNode(MidTopEffect.AutoFighting)
    if val then
        local effect = self:CreateUIEffect(effect_node, "effect/ui/ui_zidongzhandou.ab")
        effect:SetLoop(true)
    else
        self:StopUIEffect(effect_node)
    end
end

function MainNewView:GetMidTopEffectNode(effect_idx)
    return self._layout_objs["mid_top/effect_node" .. effect_idx]
end

function MainNewView:OnUpdateSkillAnger(anger)
    if self.big_skill_info.has_skill then
        local anger = anger or game.Scene.instance:GetMainRoleAnger()
        self.big_skill_info.img_anger:SetFillAmount(anger/self.big_skill_info.skill_anger)

        local main_role = game.Scene.instance:GetMainRole()
        local skill_info = main_role:GetSkillInfo(self.big_skill_info.skill_id) or {next_play_time=0}
    
        local is_ready = (global.Time.now_time > skill_info.next_play_time)
        self:ShowAngerSkillEffect(anger>=self.big_skill_info.skill_anger and is_ready)
    end
end

function MainNewView:OnUpdateCurFrame(id)
    self.head_icon:UpdateFrame(id)
    self.target_info.role_icon:UpdateFrame(id)
end

function MainNewView:ShowFuncEffect(func_id)
    local item = self:GetFuncBtn(func_id)
    local cfg = config.func[func_id]
    if item then
        item:ShowOpenEffect()
    end
end

function MainNewView:OnShowFuncsEffect(func_list)
    for id, v in pairs(func_list or game.EmptyTable) do
        self:ShowFuncEffect(id)
    end
end

function MainNewView:OnUpdateMsgNotice()
    local msg_notice_ctrl = game.MsgNoticeCtrl.instance

    local msg_num = msg_notice_ctrl:GetMsgNoticeUnReadNumByType(game.MsgNoticeType.System)
    self.btn_tips_sys:SetVisible(msg_num>0)
    self.btn_tips_sys:SetText(msg_num)

    local msg_num = msg_notice_ctrl:GetMsgNoticeUnReadNumByType(game.MsgNoticeType.Activity)
    self.btn_tips_act:SetVisible(msg_num>0)
    self.btn_tips_act:SetText(msg_num)

    local msg_num = msg_notice_ctrl:GetMsgNoticeUnReadNumByType(game.MsgNoticeType.Social)
    self.btn_tips_social:SetVisible(msg_num>0)
    self.btn_tips_social:SetText(msg_num)
end

function MainNewView:OnShowFireworkUIEffect(effect_path, effect_time)
    local effect_node = self._layout_objs["effect_center"]
    self.firework_effect = self:CreateUIEffect(effect_node, string.format("%s.ab", effect_path))
    self.firework_effect:SetLoop(true)
    self.firework_effect_del_time = global_Time.now_time + effect_time
end

function MainNewView:ClearFireworkEffect()
    if self.firework_effect then
        self.firework_effect = nil
        self.firework_effect_del_time = nil

        local effect_node = self._layout_objs["effect_center"]
        self:StopUIEffect(effect_node)
    end
end

function MainNewView:IsBigSkillCDReady()
    if not self.big_skill_info.has_skill then
        return false
    end

    local main_role = game.Scene.instance:GetMainRole()
    local skill_info = main_role:GetSkillInfo(self.big_skill_info.skill_id)
    if not skill_info then
        return false
    end

    return (global.Time.now_time > skill_info.next_play_time)
end

function MainNewView:ShowAngerSkillEffect(val)
    if val then
        if not self.big_skill_effect then
            self.big_skill_effect = self:CreateUIEffect(self.big_skill_info.effect, "effect/ui/ts_bsj.ab")
            self.big_skill_effect:SetLoop(true)
        end
    else
        if self.big_skill_effect then
            self:StopUIEffect(self.big_skill_info.effect)
            self.big_skill_effect = nil
        end
    end
end

function MainNewView:OnPlayBigSkill(skill_id)
    if self.big_skill_info.skill_id == skill_id then
        self:ShowAngerSkillEffect(false)
    end
end

function MainNewView:InitMateSkill()
    self.mate_revive_skill = 40000002
    self.btn_mate_revive = self._layout_objs["mid_bottom/btn_mate_revive"]
    self.btn_mate_revive:AddClickCallBack(function()
        local marry_info = game.MarryCtrl.instance:GetMarryInfo()
        if game.MakeTeamCtrl.instance:IsTeamMember(marry_info.mate_id) then
            local flag = false
            local func = function(target, obj)
                if target.obj_type == game.ObjType.Role and obj:GetLogicDistSq(target:GetLogicPosXY()) <= 100 and target:GetUniqueId() == marry_info.mate_id then
                    flag = true
                end
            end
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:ForeachAoiObj(func)
            end
            if flag then
                game.MarryCtrl.instance:SendUseSkill(self.mate_revive_skill)
            else
                game.GameMsgCtrl.instance:PushMsg(config.words[2626])
            end
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[2625])
        end
    end)
end

function MainNewView:OnMateDie()
    local last_use = game.MarryCtrl.instance:GetSkillCD(self.mate_revive_skill)
    local skill_info = game.MarryCtrl.instance:GetMarrySkill(self.mate_revive_skill)
    local total_cd = config.marry_skill[self.mate_revive_skill][skill_info.level].cd
    if global.Time:GetServerTime() - last_use > total_cd then
        self.btn_mate_revive:SetVisible(true)
    else
        self.btn_mate_revive:SetVisible(false)
    end
end

function MainNewView:OnMateSkillUpdate(skill_id)
    if skill_id == self.mate_revive_skill then
        self:OnMateDie()
    end
end

function MainNewView:OnMateNear(state, obj)
    if state and obj and obj:IsDead() then
        self.btn_mate_revive:SetVisible(true)
    else
        self.btn_mate_revive:SetVisible(false)
    end
end

function MainNewView:ShowFuncBtn(func_id)
    local cfg = config.func[func_id]
    if cfg then
        if cfg.group == 1 and self.list_func_groups then
            self.list_func_groups[1]:ShowFuncBtn(func_id)
            self:SetShowMainFuncGroup(true)
        end
    end
end

function MainNewView:OnChangeScene()
    self:OnMateNear(false)
end

function MainNewView:SwitchFuncListPage(page)
    if self.list_func_groups then
        self.list_func_groups[1]:SwitchPage(page)
    end
end

return MainNewView