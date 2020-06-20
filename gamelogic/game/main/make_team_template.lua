local MakeTeamTemplate = Class(game.UITemplate)

local handler = handler

function MakeTeamTemplate:_init(view)
    
    self.parent_view = view

    self.ctrl = game.MakeTeamCtrl.instance
end

function MakeTeamTemplate:OpenViewCallBack()
    self:Init()
    self:InitMembers()
    self:InitOpers()

    self:RegisterAllEvents()
end

function MakeTeamTemplate:CloseViewCallBack()
    for _,v in ipairs(self.member_list or game.EmptyTable) do
        v:DeleteMe()
    end
    self.member_list = nil

    if self.make_team_operate then
        self.make_team_operate:DeleteMe()
        self.make_team_operate = nil
    end
end

function MakeTeamTemplate:RegisterAllEvents()
    local events = {    
        { game.MakeTeamEvent.OnTeamGetInfo, handler(self, self.OnTeamGetInfo), }, 
        { game.MakeTeamEvent.UpdateTeamCreate, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.TeamLeave, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.TeamMemberLeave, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.UpdateJoinTeam, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.UpdateKickOut, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.NotifyKickOut, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.UpdateTeamNewMember, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.ChangeLeader, handler(self, self.UpdateMembers), }, 
        { game.MakeTeamEvent.CallTeamFollow, handler(self, self.OnCallTeamFollow), }, 
        { game.MakeTeamEvent.OnTeamMemberAttr, handler(self, self.OnTeamMemberAttr), },
        { game.MakeTeamEvent.UpdateApplyList, handler(self, self.OnUpdateApplyList), },
        { game.MakeTeamEvent.TeamNotifyApply, handler(self, self.OnTeamNotifyApply), },
        { game.MakeTeamEvent.UpdateAcceptApply, handler(self, self.OnUpdateAcceptApply), },
        { game.MakeTeamEvent.OnTeamNotifySyncState, handler(self, self.OnTeamNotifySyncState), },
        { game.SceneEvent.ChangeScene, handler(self, self.OnChangeScene), },        
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamTemplate:Init()
    self.is_showing = true

    self.img_main_task = self._layout_objs["img_main_task"] 

    self.group_infos = self._layout_objs["group_infos"]

    self.btn_invite = self._layout_objs["btn_invite"]
    self.btn_invite:AddClickCallBack(function()
        self.ctrl:OpenInviteView()
    end)

    self.btn_create = self._layout_objs["btn_create"]
    self.btn_create:AddClickCallBack(function()
        self.ctrl:SendTeamCreate(0)
    end)

    self.btn_team = self._layout_objs["btn_team"]
    self.btn_team:AddClickCallBack(function()
        self.ctrl:OpenView()
    end)

    self.btn_exit_team = self._layout_objs["btn_exit_team"]
    self.btn_exit_team:AddClickCallBack(function()
        if self.ctrl:HasTeam() then
            self.ctrl:SendTeamLeave()
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[5001])
        end
    end)

    self.img_follow_off = self._layout_objs["btn_team_follow/img_off"]
    self.img_follow_on = self._layout_objs["btn_team_follow/img_on"]

    self.btn_team_follow = self._layout_objs["btn_team_follow"]
    self.btn_team_follow:AddClickCallBack(function()
        if self.ctrl:HasTeam() then
            if self.ctrl:IsSelfLeader() then
                -- 队长发起跟随
                local opt = self.ctrl:IsTeamFollow() and 0 or 1
                self.ctrl:SendTeamFollow(opt)
            else
                local role_id = game.Scene.instance:GetMainRoleID()
                local is_following = self.ctrl:IsMemberFollow(role_id)
                if is_following then
                    -- 取消跟随                    
                    self.ctrl:SendTeamSyncState(0)
                else
                    -- 开始跟随
                    self:DoMemberFollow()
                end
            end
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[5001])
        end
    end)
    
    self.btn_team_switch = self._layout_objs["btn_team_switch"]
    self.btn_team_switch:AddClickCallBack(function()
        self:SwitchTeam()
    end)

    self.team_switch_x = self.btn_team_switch:GetPosition()
end

function MakeTeamTemplate:InitMembers()
    self.list_members = self._layout_objs["list_members"] 

    self.member_list = {}
    local item_class = require("game/main/make_team_member_item")
    local item_num = self.list_members:GetItemNum()
    for i=1,item_num do
        local obj = self.list_members:GetChildAt(i-1)
        local item = item_class.New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()
        item:SetClickCallback(handler(self,self.OnClickItem))

        table.insert(self.member_list, item)
    end

    self:UpdateMembers()
end

function MakeTeamTemplate:ShowOpers(is_leader, role_id, role_name)
    self.is_showing_opt = true
    self.make_team_operate:ShowOpers(is_leader, role_id, role_name)
end

function MakeTeamTemplate:HideOpers()
    self.is_showing_opt = false
    self.make_team_operate:HideOpers()
end

function MakeTeamTemplate:SwitchTeam()
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

function MakeTeamTemplate:UpdateMembers()
    local idx = 0
    local team_members = self.ctrl:GetTeamMembers()
    local team_member_num = #team_members
    local mainr_role_id = game.Scene.instance:GetMainRoleID()
    for _,v in ipairs(team_members) do
        if v.member.id ~= mainr_role_id then
            idx = idx + 1
            local member = self.member_list[idx]
            member:UpdateData(v)
        end
    end

    for i=idx+1,4 do
        local member = self.member_list[i]
        member:UpdateData(nil)
    end

    local role_id = game.Scene.instance:GetMainRoleID()
    self.btn_invite:SetVisible(team_member_num<5 and self.ctrl:IsLeader(role_id))

    self.btn_create:SetVisible(team_member_num<=0)

    local word = config.words[5000]
    if team_member_num > 0 then
        word = string.format(config.words[4992], team_member_num)
    end
    self.btn_team:SetText(word)

    self.btn_team_follow:SetVisible(team_member_num>0)
    self.btn_exit_team:SetVisible(team_member_num>0)
end

function MakeTeamTemplate:OnUpdateTeamCreate()
    self:UpdateMembers()
end

function MakeTeamTemplate:OnClickItem(item)
    if item:HasMember() then
        if item:IsSelf() then
            -- 提示点击自己
            game.GameMsgCtrl.instance:PushMsg(config.words[4991])
        else
            self:ShowOpers(self:IsSelfLeader(), item:GetRoleId(), item:GetName())
        end
    end
end

function MakeTeamTemplate:InitOpers()
    local make_team_operate = self._layout_objs["make_team_operate"]
    
    self.make_team_operate = require("game/main/make_team_operate").New(self.ctrl)
    self.make_team_operate:SetVirtual(make_team_operate)
    self.make_team_operate:Open()
end

function MakeTeamTemplate:IsSelfLeader()
    local role_id = game.Scene.instance:GetMainRoleID()
    return self.ctrl:IsLeader(role_id)
end

function MakeTeamTemplate:UpdateFollowState()
    if self.ctrl:IsSelfLeader() then
        self:OnCallTeamFollow(self.ctrl:GetTeamFollowState())
    else
        local role_id = game.Scene.instance:GetMainRoleID()
        local state = self.ctrl:GetMemberFollowState(role_id)
        self.img_follow_off:SetVisible(state==0)
        self.img_follow_on:SetVisible(state==1 or state==2)
    end
end

function MakeTeamTemplate:OnCallTeamFollow(opt)
    self.img_follow_off:SetVisible(opt==0)
    self.img_follow_on:SetVisible(opt==1)
end

function MakeTeamTemplate:OnTeamGetInfo()
    self:UpdateMembers()
    self:UpdateFollowState()
end

function MakeTeamTemplate:DoMemberFollow()
    local main_role = game.Scene.instance:GetMainRole()
    main_role:AddAndCreateAi(game.AiType.TeamFollow)
    
    self.img_follow_off:SetVisible(false)
    self.img_follow_on:SetVisible(true)

    self.is_team_following = true
end

function MakeTeamTemplate:StopMemberFollow()
    local main_role = game.Scene.instance:GetMainRole()
    main_role:FreeObjAi()
    main_role:GetOperateMgr():DoStop()

    self.img_follow_off:SetVisible(true)
    self.img_follow_on:SetVisible(false)

    self.is_team_following = false
end

function MakeTeamTemplate:OnTeamMemberAttr(role_id, attr_list)
    for _,v in ipairs(self.member_list) do
        if v:GetRoleId() == role_id then
            v:UpdateAttrInfo(attr_list)
        end
    end
end

function MakeTeamTemplate:OnTeamNotifyApply()
    self:CheckApplyRedPoint()
end

function MakeTeamTemplate:OnUpdateAcceptApply()
    self:CheckApplyRedPoint()
end

function MakeTeamTemplate:OnTeamNotifySyncState(data)
    local role_id = game.Scene.instance:GetMainRoleID()
    if data.role_id == role_id then
        if data.state == 0 then
            self:StopMemberFollow()
        end
    end

    for _,v in ipairs(self.member_list) do
        if v:GetRoleId() == data.role_id then
            v:UpdateFollowState(data.state)
        end
    end
end

function MakeTeamTemplate:CheckApplyRedPoint()
    local is_red = self.ctrl:CheckApplyRedPoint()

    game_help.SetRedPoint(self.btn_team, is_red)
end

function MakeTeamTemplate:OnUpdateApplyList()
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

function MakeTeamTemplate:OnChangeScene(from_scene_id, to_scene_id)
    if not self.ctrl:HasTeam() then
        return
    end

    local attr_list = {}
    for _,v in ipairs(self.member_list) do
        local member = self.ctrl:GetTeamMemberById(v:GetRoleId())
        if member then
            for ck,cv in pairs(attr_keys) do
                table.insert(attr_list,{type=cv, value=member[ck]})
            end
            v:UpdateAttrInfo(attr_list)
        end
    end
end

return MakeTeamTemplate
