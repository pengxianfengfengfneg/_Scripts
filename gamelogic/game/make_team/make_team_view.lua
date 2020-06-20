local MakeTeamView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format

function MakeTeamView:_init(ctrl)
    self._package_name = "ui_make_team"
    self._com_name = "make_team_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function MakeTeamView:OpenViewCallBack(target)
    self.target = target
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function MakeTeamView:CloseViewCallBack()

end

function MakeTeamView:RegisterAllEvents()
    local events = {        
        {game.MakeTeamEvent.TeamLeave, handler(self, self.OnTeamLeave)},
        {game.MakeTeamEvent.TeamMemberLeave, handler(self, self.OnTeamMemberLeave)},
        {game.MakeTeamEvent.UpdateTeamNewMember, handler(self, self.OnUpdateTeamNewMember)},
        {game.MakeTeamEvent.UpdateKickOut, handler(self, self.OnUpdateKickOut)},
        {game.MakeTeamEvent.NotifyKickOut, handler(self, self.OnNotifyKickOut)},
        {game.MakeTeamEvent.TeamNotifyApply, handler(self, self.OnTeamNotifyApply)},
        {game.MakeTeamEvent.UpdateAcceptApply, handler(self, self.OnUpdateAcceptApply)},
        {game.MakeTeamEvent.OnTeamSetMatch, handler(self, self.OnTeamSetMatch)},
        {game.MakeTeamEvent.ChangeLeader, handler(self, self.OnChangeLeader)},
        {game.MakeTeamEvent.OnTeamSetTarget, handler(self, self.OnTeamSetTarget)},
        {game.MakeTeamEvent.OnTeamSetLevel, handler(self, self.OnTeamSetLevel)},
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamView:Init()
    self.is_team_matching = false

    self.txt_target = self._layout_objs["txt_target"]

    self:InitBtns()
    self:InitMembers()
    self:UpdateTeamTarget()
    self:UpdateMatchBtn()

    self:CheckApplyRedPoint()

    self:UpdateTeamBtn()

    if self.target then
        self:SetTeamTarget(self.target)
    end
end

function MakeTeamView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1671]):HideBtnBack()
end

function MakeTeamView:InitBtns()
    self.btn_modify = self._layout_objs["btn_modify"]
    self.btn_modify:AddClickCallBack(function()
        self.ctrl:OpenTargetView()
    end)

    self.btn_match = self._layout_objs["btn_match"]
    self.btn_match:AddClickCallBack(function()
        if self.ctrl:IsFullMember() then
            -- 已满员
            return game.GameMsgCtrl.instance:PushMsg(config.words[5005])
        end

        local cur_target = self.ctrl:GetTeamTarget()
        if cur_target <= 0 then
            return game.GameMsgCtrl.instance:PushMsg(config.words[4988])
        end

        local match = (self.is_team_matching and 0 or 1)
        self.ctrl:SendTeamSetMatch(match)
    end)
    self:UpdateTeamMatching()

    self.btn_apply_list = self._layout_objs["btn_apply_list"]
    self.btn_apply_list:AddClickCallBack(function()
        self.ctrl:OpenApplyView()
    end)

    self.btn_invite = self._layout_objs["btn_invite"]
    self.btn_invite:AddClickCallBack(function()
        local role_id = game.Scene.instance:GetMainRoleID()
        if self.ctrl:IsLeader(role_id) then
            self.ctrl:SendTeamRecruit()
        else
            -- 只有队长可以招募
            game.GameMsgCtrl.instance:PushMsg(config.words[4990])
        end
    end)

    self.btn_exit = self._layout_objs["btn_exit"]
    self.btn_exit:AddClickCallBack(function()
        self.ctrl:SendTeamLeave()
    end)
end

function MakeTeamView:InitMembers()
    self.list_members = self._layout_objs["list_members"]

    local item_num = 5
    self.list_members:SetItemNum(item_num)

    self.list_member_item = {}
    local item_class = require("game/make_team/make_team_member_item")
    for i=1,item_num do
        local child = self.list_members:GetChildAt(i-1)
        local item = item_class.New(self.ctrl)
        item:SetVirtual(child)
        item:Open()
        item:UpdateData(self:GetItemData(i))

        table.insert(self.list_member_item, item)
    end
end

function MakeTeamView:OnTeamLeave()
    self.ctrl:OpenView()
end

function MakeTeamView:RefreshTeamMember()
    for k,v in ipairs(self.list_member_item) do
        v:UpdateData(self:GetItemData(k))
    end
end

function MakeTeamView:OnTeamMemberLeave(role_id)
    self:RefreshTeamMember()
end

function MakeTeamView:OnUpdateTeamNewMember()
    self:RefreshTeamMember()
end

function MakeTeamView:OnUpdateKickOut()
    self:RefreshTeamMember()
end

function MakeTeamView:OnNotifyKickOut()
    self.ctrl:OpenView()
end

function MakeTeamView:OnTeamNotifyApply()
    self:CheckApplyRedPoint()
end

function MakeTeamView:OnUpdateAcceptApply()
    self:CheckApplyRedPoint()
end

function MakeTeamView:OnTeamSetMatch(match)
    self:UpdateTeamMatching()

    self:RefreshTeamMember()
end

function MakeTeamView:UpdateTeamMatching()
    self.is_team_matching = self.ctrl:IsTeamMatching()

    local word_id = (self.is_team_matching and 4987 or 4986)
    self.btn_match:SetText(config.words[word_id])
end

function MakeTeamView:OnChangeLeader()
    self:UpdateMatchBtn()

    self:UpdateTeamBtn()
end

function MakeTeamView:GetItemData(idx)
    local members = self.ctrl:GetTeamMembers()
    return members[idx]
end

function MakeTeamView:UpdateTeamTarget()
    local team_target = self.ctrl:GetTeamTarget()
    local cfg = config.team_target[team_target]

    local min_lv,max_lv = self.ctrl:GetTeamTargetLv()

    local target_name = config.words[4980]
    if cfg then
        target_name = cfg.name
    end
    self.txt_target:SetText(string.format(config.words[5027], target_name, min_lv, max_lv))

    local is_match_enable = (cfg~=nil)
    self.btn_match:SetTouchEnable(is_match_enable)
    self.btn_match:SetGray(not is_match_enable)
end

function MakeTeamView:CheckApplyRedPoint()
    local is_red = self.ctrl:CheckApplyRedPoint()

    game_help.SetRedPoint(self.btn_apply_list, is_red)
end

function MakeTeamView:UpdateMatchBtn()
    local role_id = game.Scene.instance:GetMainRoleID()
    local is_self_leader = self.ctrl:IsLeader(role_id)

    self.btn_match:SetVisible(is_self_leader)
end

function MakeTeamView:OnTeamSetTarget(target, min_lv, max_lv)
    self:UpdateTeamTarget()
    self:RefreshTeamMember()
end

function MakeTeamView:OnTeamSetLevel(min_lv, max_lv)
    self:UpdateTeamTarget()
end

local PosCfg = {
    {37,967},
    {257,967},
    {477,967},
}

function MakeTeamView:UpdateTeamBtn()
    local is_self_leader = self.ctrl:IsSelfLeader()
    self.btn_apply_list:SetVisible(is_self_leader)
    self.btn_invite:SetVisible(is_self_leader)
    self.btn_modify:SetVisible(is_self_leader)

    if is_self_leader then
        self.btn_apply_list:SetPosition(table.unpack(PosCfg[1]))
        self.btn_invite:SetPosition(table.unpack(PosCfg[2]))
        self.btn_exit:SetPosition(table.unpack(PosCfg[3]))
    else
        self.btn_exit:SetPosition(table.unpack(PosCfg[2]))
    end
end

function MakeTeamView:SetTeamTarget(target, min_lv, max_lv)
    if not self.ctrl:IsSelfLeader() then
        return
    end

    local now_target = self.ctrl:GetTeamTarget()
    local now_min,now_max = self.ctrl:GetTeamTargetLv()
    local team_target_cfg = config.team_target[target]
    
    if not min_lv then
        min_lv = team_target_cfg.level
    end
    if not max_lv then
        local apply_cfg = team_target_cfg.apply_lv
        local max_apply = apply_cfg[#apply_cfg]
        max_lv = max_apply[2]
        if min_lv > max_lv then
            min_lv = max_apply[1]
        end
    end

    if now_target == target then
        if (now_min~=min_lv) or (now_max~=max_lv) then
            self.ctrl:SendTeamSetLevel(min_lv, max_lv)
        end
    else
        self.ctrl:SendTeamSetTarget(target, min_lv, max_lv)
    end

    if not self.is_team_matching then
        self.ctrl:SendTeamSetMatch(1)
    end
end

return MakeTeamView