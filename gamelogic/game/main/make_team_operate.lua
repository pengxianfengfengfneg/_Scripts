local MakeTeamOperate = Class(game.UITemplate)

local handler = handler

function MakeTeamOperate:_init(view)
    
    self.parent_view = view

    self.ctrl = game.MakeTeamCtrl.instance
end

function MakeTeamOperate:OpenViewCallBack()
    self:Init()

    self:RegisterAllEvents()
end

function MakeTeamOperate:CloseViewCallBack()
   
end

function MakeTeamOperate:RegisterAllEvents()
    local events = {    
        --{ game.MakeTeamEvent.OnTeamGetInfo, handler(self, self.UpdateMembers), },         
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamOperate:Init()
    self.img_bg = self._layout_objs["img_bg"]

    self.list_opers = self._layout_objs["list_opers"] 
    self.list_opers.foldInvisibleItems = true

    self.touch_com = self._layout_objs["touch_com"] 
    self.touch_com:AddClickCallBack(function()
        self:HideOpers()
    end)
end

local LeaderOptWords = {
    {config.words[4993], function(role_id)
        -- 提升队长
        game.MakeTeamCtrl.instance:SendTeamDemiseLeader(role_id)
    end,},
    {config.words[4999], function(role_id)
        -- 添加好友
        game.FriendCtrl.instance:CsFriendSysApplyAdd(role_id)
    end,},
    {config.words[4995], function(role_id, role_name, lv, career)
        -- 私聊
        local chat_info = {
            id = role_id,
            name = role_name,
            lv = lv,
            career = career,
            svr_num = 1,
        }
        game.ChatCtrl.instance:OpenFriendChatView(chat_info)
    end,},
    {config.words[4994], function(role_id)
        -- 查看资料
        game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.ViewOthers, role_id)
    end,},
    {config.words[4996], function(role_id, role_name, lv, career, is_robot)
        -- 请离队伍
        if is_robot then
            game.MakeTeamCtrl.instance:SendKickRobot(role_id)
        else
            game.MakeTeamCtrl.instance:SendTeamKickOut(role_id)
        end
    end,true},
}

local MemberOptWords = {
    {config.words[4998], function(role_id)
        -- 申请队长
        game.MakeTeamCtrl.instance:SendTeamPromoteRequest()
    end,},
    {config.words[4999], function(role_id)
        game.FriendCtrl.instance:CsFriendSysApplyAdd(role_id)
    end,},
    {config.words[4995], function(role_id, role_name, lv, career)
        local chat_info = {
            id = role_id,
            name = role_name,
            lv = lv,
            career = career,
            svr_num = 1,
        }
        game.ChatCtrl.instance:OpenFriendChatView(chat_info)
    end,},
    {config.words[4994], function(role_id)
        -- 查看资料
        game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.ViewOthers, role_id)
    end,},
    {config.words[4997], function(role_id)
        game.MakeTeamCtrl.instance:SendTeamLeave()
    end,},
}

function MakeTeamOperate:ShowOpers(is_leader, role_id, role_name, lv, career, idx, is_robot)
    self.opt_role_id = role_id
    self.opt_role_name = role_name
    self.opt_role_lv = lv
    self.opt_role_career = career

    self.is_robot = is_robot

    local idx = idx or 1
    local y = (idx-1)*80
    self.img_bg:SetPositionX(100)
    self.img_bg:SetPositionY(y)

    local OptWords = (is_leader and LeaderOptWords or MemberOptWords)
    local item_num = #OptWords
    self.list_opers:SetItemNum(item_num)

    if is_robot then
        item_num = 1
    end

    local width = 158
    local height = 14 + 56*item_num
    self:GetRoot():SetVisible(true)
    self.img_bg:SetSize(width, height)

    for k,v in ipairs(OptWords) do
        local child = self.list_opers:GetChildAt(k-1)
        child:SetText(v[1])

        if is_robot then
            child:SetVisible(v[3]==true)
        else
            child:SetVisible(true)
        end
        child:AddClickCallBack(function()
            v[2](self.opt_role_id, self.opt_role_name, self.opt_role_lv, self.opt_role_career, self.is_robot)

            self:HideOpers()
        end)     
    end
end

function MakeTeamOperate:HideOpers()
    self:GetRoot():SetVisible(false)
end

return MakeTeamOperate
