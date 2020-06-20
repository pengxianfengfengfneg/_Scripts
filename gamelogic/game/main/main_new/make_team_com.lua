local MakeTeamCom = Class(game.UITemplate)

local handler = handler
local et = {}

function MakeTeamCom:_init(view)
    
    MakeTeamCom.instance = self
    self.parent_view = view

    self.ctrl = game.MakeTeamCtrl.instance
end

function MakeTeamCom:_delete()
    MakeTeamCom.instance = nil
end

function MakeTeamCom:OpenViewCallBack()
    self:Init()
    self:InitMembers()
    self:InitOpers()

    self:RegisterAllEvents()
end

function MakeTeamCom:CloseViewCallBack()
    for _,v in ipairs(self.member_list or game.EmptyTable) do
        v:DeleteMe()
    end
    self.member_list = nil

    if self.make_team_operate then
        self.make_team_operate:DeleteMe()
        self.make_team_operate = nil
    end
end

function MakeTeamCom:RegisterAllEvents()
    local events = {    
        { game.MakeTeamEvent.OnTeamGetInfo, handler(self, self.OnTeamGetInfo), }, 
        { game.MakeTeamEvent.UpdateTeamCreate, handler(self, self.OnUpdateTeamCreate), }, 
        { game.MakeTeamEvent.TeamLeave, handler(self, self.OnTeamLeave), }, 
        { game.MakeTeamEvent.TeamMemberLeave, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.UpdateJoinTeam, handler(self, self.OnUpdateJoinTeam), }, 
        { game.MakeTeamEvent.UpdateKickOut, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.NotifyKickOut, handler(self, self.OnNotifyKickOut), }, 
        { game.MakeTeamEvent.UpdateTeamNewMember, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.ChangeLeader, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.CallTeamFollow, handler(self, self.OnCallTeamFollow), }, 
        { game.MakeTeamEvent.OnTeamMemberAttr, handler(self, self.OnTeamMemberAttr), },
        { game.MakeTeamEvent.UpdateApplyList, handler(self, self.OnUpdateApplyList), },
        { game.MakeTeamEvent.TeamNotifyApply, handler(self, self.OnTeamNotifyApply), },
        { game.MakeTeamEvent.UpdateAcceptApply, handler(self, self.OnUpdateAcceptApply), },
        { game.MakeTeamEvent.OnTeamNotifySyncState, handler(self, self.OnTeamNotifySyncState), },
        { game.MakeTeamEvent.OnTeamNotifyFollow, handler(self, self.OnTeamNotifyFollow), },
        { game.MakeTeamEvent.OnUpdateAssist, handler(self, self.OnUpdateAssist), },  
        { game.SceneEvent.ChangeScene, handler(self, self.OnChangeScene), },  
        { game.CarbonEvent.OnDungData, handler(self, self.OnDungData) },

        { game.GameEvent.StartPlay, handler(self, self.OnStartPlay) },
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamCom:Init()
    self.is_showing = true

    self.cur_scene = game.Scene.instance

    self.img_main_task = self._layout_objs["img_main_task"] 

    self.group_infos = self._layout_objs["group_infos"]

    --组队和任务
    self.btn_come_out = self._layout_objs["btn_come_out"]
    self.team = self._layout_objs["team"]
    self.task = self._layout_objs["task"]
    self.task_bg = self._layout_objs["task_bg"]
    self.list_members = self._layout_objs["list_members"]
    self.list_operate = self._layout_objs["list_operate"]
    self.team_des = self._layout_objs["team_des"]
    self.task_members = self._layout_objs["task_members"]
    self.btn_add_team = self._layout_objs["btn_add_team"]
    self.btn_invite = self._layout_objs["btn_invite"]
    self.btn_add_member = self._layout_objs["btn_add_member"]
    self.btn_out_team = self._layout_objs["btn_out_team"]
    self.btn_add_member:AddClickCallBack(function()
        self.ctrl:OpenView()
    end)

    --创建队伍
    self.btn_add_team:AddClickCallBack(function()
        game.MakeTeamCtrl.instance:SendTeamCreate(0)
    end)
    
    --邀请队员
    self.btn_invite:AddClickCallBack(function()
        game.MakeTeamCtrl.instance:OpenInviteView()
    end)

    --退出队伍
    self.btn_out_team:AddClickCallBack(function()
        game.MakeTeamCtrl.instance:SendTeamLeave()
    end)


    local list_btn = self._layout_objs["list_btn"]

    self.btn_zudui = list_btn:GetChild("btn_zudui")
    local btn_renwu = list_btn:GetChild("btn_renwu")

    local btn_zuduibg = self.btn_zudui:GetChild("n1")
    local btn_renwubg = btn_renwu:GetChild("n1")

    self.btn_zudui:AddClickCallBack(function()
        btn_renwubg:SetGray(true)
        btn_zuduibg:SetGray(false)
        self.team:SetVisible(true)
        self.task:SetVisible(false)
        if self.value == 1 then
            self.ctrl:OpenView()
        end
        self.value = 1
    end)

    btn_renwu:AddClickCallBack(function()
        btn_zuduibg:SetGray(true)
        btn_renwubg:SetGray(false)
        self.team:SetVisible(false)
        self.task:SetVisible(true)
        if self.value == 2 then
            game.TaskCtrl.instance:OpenView()
        end
        self.value = 2
    end)
    -- self.btn_create = self._layout_objs["btn_create"]
    -- self.btn_create:AddClickCallBack(function()
    --     self.ctrl:SendTeamCreate(0)
    -- end)

    -- self.btn_team = self._layout_objs["btn_team"]
    -- self.btn_team:AddClickCallBack(function()
    --     self.ctrl:OpenView()
    -- end)

    -- self.btn_exit_team = self._layout_objs["btn_exit_team"]
    -- self.btn_exit_team:AddClickCallBack(function()
    --     if self.ctrl:HasTeam() then
    --         self.ctrl:SendTeamLeave()
    --     else
    --         game.GameMsgCtrl.instance:PushMsg(config.words[5001])
    --     end
    -- end)

    self.list_operate.foldInvisibleItems = true

    self.img_assist_off = self._layout_objs["list_operate/btn_assist/img_off"]
    self.img_assist_on = self._layout_objs["list_operate/btn_assist/img_on"]

    self.assist_enable = true
    self.btn_assist = self._layout_objs["list_operate/btn_assist"]
    self.btn_assist:AddClickCallBack(function()
        if not self.assist_enable then
            game.GameMsgCtrl.instance:PushMsg(config.words[5026])
            return
        end

        local is_assist = (self.ctrl:GetSelfAssist()==1)
        if not is_assist then
            self:ShowAssistAsk()
        else
            local assist = (is_assist and 0 or 1)
            self.ctrl:SendTeamAssist(assist)
        end
    end)

    self.btn_account = self._layout_objs["list_operate/btn_account"]
    self.btn_account:AddClickCallBack(function()

    end)
    self.btn_account:SetVisible(false)

    self.img_follow_off = self._layout_objs["list_operate/btn_follow/img_off"]
    self.img_follow_on = self._layout_objs["list_operate/btn_follow/img_on"]

    self.btn_team_follow = self._layout_objs["list_operate/btn_follow"]
    self.btn_team_follow:AddClickCallBack(function()
        if self.ctrl:HasTeam() then
            if self.ctrl:IsSelfLeader() then
                -- 队长发起跟随
                local opt = self.ctrl:IsTeamFollow() and 0 or 1
                local res = self.ctrl:SendTeamFollow(opt)

                if opt == 1 and res then
                    local main_role = game.Scene.instance:GetMainRole()
                    if main_role then
                        main_role:GetOperateMgr():ClearOperate()
                    end
                end
            else
                local role_id = game.Scene.instance:GetMainRoleID()
                local is_following = self.ctrl:IsMemberFollow(role_id)
                if is_following then
                    -- 取消跟随                    
                    self:DoMemberFollow(false)
                else
                    -- 开始跟随                    
                    self:DoMemberFollow(true)
                end
            end
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[5001])
        end
    end)
    
    -- self.btn_team_switch = self._layout_objs["btn_team_switch"]
    -- self.btn_team_switch:AddClickCallBack(function()
    --     self:SwitchTeam()
    -- end)

    -- self.team_switch_x = self.btn_team_switch:GetPosition()

    self:UpdateFollowState()
    self:UpdateAssistState()
end

function MakeTeamCom:Getval()
    return self.value
end

function MakeTeamCom:Setval(value)
    self.value = value
end

function MakeTeamCom:InitMembers()
    --self.list_members = self._layout_objs["list_members"]

    --self.member_list = {}
    -- local item_class = require("game/main/make_team_member_item")
    -- local item_num = self.list_members:GetItemNum()
    -- for i=1,item_num do
    --     local obj = self.list_members:GetChildAt(i-1)
    --     local item = item_class.New(self.ctrl)
    --     item:SetVirtual(obj)
    --     item:Open()
    --     item:SetClickCallback(handler(self,self.OnClickItem))

    --     table.insert(self.member_list, item)
    -- end

    self:UpdateMembers()
end

function MakeTeamCom:ShowOpers(is_leader, role_id, role_name, lv, career, idx, is_robot)
    if not is_leader and is_robot then
        return
    end

    self.is_showing_opt = true
    self.make_team_operate:ShowOpers(is_leader, role_id, role_name, lv, career, idx, is_robot)
end

function MakeTeamCom:HideOpers()
    self.is_showing_opt = false
    self.make_team_operate:HideOpers()
end

function MakeTeamCom:SwitchTeam()
    self.is_showing = not self.is_showing
    self.group_infos:SetVisible(self.is_showing)
    self.btn_team:SetVisible(self.is_showing)

    self.make_team_operate:SetVisible(false)

    local x = 0
    if self.is_showing then
        x = self.team_switch_x
    end
    self.btn_team_switch:SetPositionX(x)
end

function MakeTeamCom:ClearMembers()
    for _,v in ipairs(self.member_list or et) do
        v:DeleteMe()
    end
    self.member_list = {}
end

function MakeTeamCom:UpdateMembers()
    
    local team_members = self.ctrl:GetTeamMembers()
    local team_member_num = #team_members
    local main_role_id = game.Scene.instance:GetMainRoleID()

    team_member_num = math.max(team_member_num-1, 0)

    local role_id = game.Scene.instance:GetMainRoleID()
    local member_info = self.ctrl:GetTeamMemberById(role_id)
    if team_member_num == 4 then
        self.btn_invite:SetVisible(false)
    elseif team_member_num ~= 4 and  member_info~=nil then
        self.btn_invite:SetVisible(true)
    end

    self:ClearMembers()
    self.list_members:SetItemNum(team_member_num)

    local idx = 0
    local item_class = require("game/main/main_new/make_team_item")
    for k,v in ipairs(team_members) do
        if v.member.id ~= main_role_id then
            idx = idx + 1

            if idx > team_member_num then
                break
            end

            local obj = self.list_members:GetChildAt(idx-1)
            local item = item_class.New(self.ctrl,idx)
            item:SetVirtual(obj)
            item:Open()
            item:UpdateData(v)
            item:SetClickCallback(handler(self,self.OnClickItem))

            table.insert(self.member_list, item)
        end
    end

    local width = 76 * team_member_num
    local height = 81
    self.list_members:SetSize(width, height)

    -- for i=idx+1,4 do
    --     local member = self.member_list[i]
    --     member:UpdateData(nil)
    -- end

    -- local role_id = game.Scene.instance:GetMainRoleID()
    -- self.btn_invite:SetVisible(team_member_num<5 and self.ctrl:IsLeader(role_id))

    -- self.btn_create:SetVisible(team_member_num<=0)

    -- local word = config.words[5000]
    -- if team_member_num > 0 then
    --     word = string.format(config.words[4992], team_member_num)
    -- end
    -- self.btn_team:SetText(word)

    -- self.btn_team_follow:SetVisible(team_member_num>0)
    -- self.btn_exit_team:SetVisible(team_member_num>0)
end

function MakeTeamCom:OnUpdateTeamCreate()
    self:UpdateMembers()
end

function MakeTeamCom:OnClickItem(item)
    if item:HasMember() then
        if item:IsSelf() then
            -- 提示点击自己
            game.GameMsgCtrl.instance:PushMsg(config.words[4991])
        else
            local role_id = item:GetRoleId()
            self:ShowOpers(self:IsSelfLeader(), role_id, item:GetName(), item:GetLevel(), item:GetCareer(), item:GetMemIdx(), item:IsRobot())

            local obj = game.Scene.instance:GetObjByUniqID(role_id)
            if obj then
                local main_role = game.Scene.instance:GetMainRole()
                main_role:SelectTarget(obj)
            end
        end
    end
end

function MakeTeamCom:InitOpers()
    local make_team_operate = self._layout_objs["make_team_operate"]
    
    self.make_team_operate = require("game/main/make_team_operate").New(self.ctrl)
    self.make_team_operate:SetVirtual(make_team_operate)
    self.make_team_operate:Open()
end

function MakeTeamCom:IsSelfLeader()
    local role_id = game.Scene.instance:GetMainRoleID()
    return self.ctrl:IsLeader(role_id)
end

function MakeTeamCom:UpdateFollowState()
    if self.ctrl:IsSelfLeader() then
        self:OnCallTeamFollow(self.ctrl:GetTeamFollowState())
    else
        local role_id = game.Scene.instance:GetMainRoleID()
        local state = self.ctrl:GetMemberFollowState(role_id)
        self.img_follow_off:SetVisible(state<=game.TeamFollowState.NoFollow)
        self.img_follow_on:SetVisible(state>game.TeamFollowState.NoFollow)
    end
end

function MakeTeamCom:OnCallTeamFollow(opt)
    self.img_follow_off:SetVisible(opt==0)
    self.img_follow_on:SetVisible(opt==1)
end

function MakeTeamCom:UpdateAssistState()
    local role_id = game.Scene.instance:GetMainRoleID()
    local member_info = self.ctrl:GetTeamMemberById(role_id)
    self.list_operate:SetVisible(member_info~=nil)
    self.btn_invite:SetVisible(member_info~=nil)
    self.btn_out_team:SetVisible(member_info~=nil)
    self.btn_add_team:SetVisible(member_info == nil)
    self.btn_add_member:SetVisible(member_info == nil)
    self.team_des:SetVisible(member_info == nil)

    if member_info then
        local is_assist = (member_info.assist==1)
        self.img_assist_off:SetVisible(not is_assist)
        self.img_assist_on:SetVisible(is_assist)
    end
end

function MakeTeamCom:SetTaskVil(val)
    if val == nil then
        val = true
    end
    self.task_bg:SetVisible(val)
end

function MakeTeamCom:OnTeamGetInfo()
    self:UpdateMembers()
    self:UpdateFollowState()
    self:UpdateAssistState()
end

function MakeTeamCom:OnUpdateTeamCreate()
    self:UpdateMembers()
    self:UpdateFollowState()
    self:UpdateAssistState()
end

function MakeTeamCom:DoMemberFollow(val)
    if val then
        local to_follow_state = game.TeamFollowState.CloseTo
        self.ctrl:SendTeamSyncState(to_follow_state)
        self.ctrl:DoFollowStart()
    else
        self.ctrl:SendTeamSyncState(game.TeamFollowState.NoFollow)
    end
end

function MakeTeamCom:OnTeamMemberAttr(role_id, aoi_attr_list)
    for _,v in ipairs(self.member_list) do
        if v:GetRoleId() == role_id then
            v:UpdateAttrInfo(aoi_attr_list)
        end
    end
end

function MakeTeamCom:OnTeamNotifyApply()
    self:CheckApplyRedPoint()
end

function MakeTeamCom:OnUpdateAcceptApply()
    self:CheckApplyRedPoint()
end

function MakeTeamCom:OnTeamNotifySyncState(data)
    -- 队员跟随状态改变
    local role_id = game.Scene.instance:GetMainRoleID()
    if data.role_id == role_id then
        self:UpdateFollowState()
    end

    for _,v in ipairs(self.member_list) do
        if v:GetRoleId() == data.role_id then
            v:UpdateFollowState(data.state)
        end
    end
end

function MakeTeamCom:OnTeamNotifyFollow(opt)
    -- 队伍跟随状态改变
    self:UpdateFollowState()
end

function MakeTeamCom:OnNotifyKickOut()
    self:UpdateMembers()
    self:UpdateFollowState()
    self:UpdateAssistState()
end

function MakeTeamCom:OnTeamLeave()
    self:UpdateMembers()

    self:UpdateFollowState()
    self:UpdateAssistState()

    self:CheckApplyRedPoint()
end

function MakeTeamCom:CheckApplyRedPoint()
    local is_red = self.ctrl:CheckApplyRedPoint()

    game_help.SetRedPoint(self.btn_come_out, is_red)
    game_help.SetRedPoint(self.btn_zudui, is_red)
end

function MakeTeamCom:OnUpdateApplyList()
    self:CheckApplyRedPoint()
end

local attr_keys = {
    hp = 1,
    hp_lim = 2,
    level = 3,
    career = 4,
    offline = 5,
    scene = 6,
}

function MakeTeamCom:OnChangeScene(from_scene_id, to_scene_id)
    if not self.ctrl:HasTeam() then
        return
    end

    local main_role_id = game.Scene.instance:GetMainRoleID()
    local aoi_attr_list = {}
    for _,v in ipairs(self.member_list) do
        local role_id = v:GetRoleId()
        local member = self.ctrl:GetTeamMemberById(role_id)
        if member then
            for ck,cv in pairs(attr_keys) do
                local info = {type=cv, value=member[ck]}
                if ck == attr_keys.scene then
                    if role_id == main_role_id then
                        info.value = to_scene_id
                    end
                end
                table.insert(aoi_attr_list,info)
            end
            v:UpdateAttrInfo(aoi_attr_list)
        end
    end
end

function MakeTeamCom:OnUpdateAssist(role_id, assist)
    local main_role_id = game.Scene.instance:GetMainRoleID()
    if main_role_id == role_id then
        self:UpdateAssistState()
    end

    for _,v in ipairs(self.member_list) do
        if role_id == v:GetRoleId() then
            v:SetAssistFlag(assist==1)
            break
        end
    end
end

function MakeTeamCom:OnUpdateJoinTeam()
    self:UpdateMembers()
    self:UpdateAssistState()
end

function MakeTeamCom:ShowAssistAsk()
    local title = config.words[5022]
    local content = config.words[5021]
    local msg_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content)
    msg_view:SetOkBtn(function()
        self.ctrl:SendTeamAssist(1)
    end)
    msg_view:SetCancelBtn(function()
        
    end)
    msg_view:Open()
end

function MakeTeamCom:SetDunAssistEnable(val)
    self.assist_enable = val

    -- self.img_assist_off:SetGray(not val)
    -- self.img_assist_on:SetGray(not val)
end

local NextUpdateTime = 0
local aoi_attr_list = {
    [1] = {type=1, value=100},
    [3] = {type=3, value=1},
    [5] = {type=5, value=0},
    [6] = {type=6, value=0},
    [7] = {type=7, value=1},
}
local attr_list = {
    [1] = {type=1, value=100},
}
function MakeTeamCom:Update(now_time, elapse_time)
    if now_time >= NextUpdateTime then
        NextUpdateTime = now_time + 0.2

        for _,v in ipairs(self.member_list) do
            local obj = self.cur_scene:GetObjByUniqID(v:GetRoleId())
            if obj then
                local percent = obj:GetHpPercent()
                aoi_attr_list[1].value = percent*100
                aoi_attr_list[3].value = obj:GetLevel()
                aoi_attr_list[5].value = 0
                aoi_attr_list[6].value = obj:GetScene():GetSceneID()

                v:UpdateAttrInfo(aoi_attr_list, true)
            else
                -- attr_list[1].value = 100

                -- v:UpdateAttrInfo(attr_list)
            end
        end
    end 
end

function MakeTeamCom:OnDungData(data)
    for _,v in ipairs(data.members or {}) do
        data.members[v.id] = v.assist
    end

    for _,v in ipairs(self.member_list) do
        local is_assist = (data.members[v:GetRoleId()]==1)
        v:SetAssistFlag(is_assist)
    end

    local main_role_id = game.Scene.instance:GetMainRoleID()
    local is_assist = (data.members[main_role_id]==1)
    self.img_assist_on:SetVisible(is_assist)
    self.img_assist_off:SetVisible(not is_assist)
end

function MakeTeamCom:OnStartPlay()
    local dun_data = game.CarbonCtrl.instance:GetDunFightData()
    if dun_data then
        self:OnDungData(dun_data)
    else
        for _,v in ipairs(self.member_list) do
            v:UpdateAssistFlag()
        end

        local is_assist = (self.ctrl:GetSelfAssist()==1)
        self.img_assist_on:SetVisible(is_assist)
        self.img_assist_off:SetVisible(not is_assist)
    end
end

game.MakeTeamCom = MakeTeamCom

return MakeTeamCom
