local GuildMemberTemplate = Class(game.UITemplate)

local MemberConfig = {
    {
        item_path = "list_page/member_st_template",
        item_class = "game/guild/template/member_st_template",
    },
    {
        item_path = "list_page/member_nd_template",
        item_class = "game/guild/template/member_nd_template",
    },
}

function GuildMemberTemplate:_init(view)
    self.parent = view
    self.ctrl = game.GuildCtrl.instance
end

function GuildMemberTemplate:OpenViewCallBack()
    self:Init()
    self:InitTemplate()
    self:RegisterAllEvents()
end

function GuildMemberTemplate:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UpdateAppList, handler(self, self.SetAppRedPoint)},
        {game.GuildEvent.UpdateMemberPos, handler(self, self.UpdateMemberPos)},
        {game.GuildEvent.UpdateGuildInfo, handler(self, self.UpdateGuildInfo)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildMemberTemplate:Init(open_idx)
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
    end)

    open_idx = open_idx or 1
    self.ctrl_page:SetSelectedIndexEx(open_idx-1)

    self.btn_event = self._layout_objs.btn_event
    self.btn_event:AddClickCallBack(function()
        self.ctrl:OpenGuildEventView()
    end)

    self.btn_recruit = self._layout_objs.btn_recruit
    self.btn_recruit:AddClickCallBack(function()
        self:OnRecruit()
    end)

    self.btn_leave = self._layout_objs.btn_leave
    self.btn_leave:AddClickCallBack(function()
        self:OnLeave()
    end)

    self.img_hd = self.btn_recruit:GetChild("img_red_point")
    self.img_hd:SetVisible(false)

    self.list_page = self._layout_objs.list_page

    self.update_flag = false
end

function GuildMemberTemplate:InitTemplate()
    for _, v in ipairs(MemberConfig) do
        self:GetTemplate(v.item_class, v.item_path)
    end
end

function GuildMemberTemplate:SetAppRedPoint()
    if self.ctrl:CanRecruit() then
        local apply_info = self.ctrl:GetGuildApplyInfo()
        self.img_hd:SetVisible(apply_info and #apply_info > 0 or false)
    else
        self.img_hd:SetVisible(false)
    end
end

function GuildMemberTemplate:OnRecruit()
    if self.ctrl:CanRecruit() then
        self.ctrl:OpenGuildAppView()
    else
        game.GameMsgCtrl.instance:PushMsgCode(3417)
    end
end

function GuildMemberTemplate:OnLeave()
    local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(config.words[6013])
    msg_box:SetBtn1(nil, function()
        game.GuildCtrl.instance:SendGuildLeave()
    end)
    msg_box:SetBtn2(config.words[101])
    msg_box:Open()
end

function GuildMemberTemplate:UpdateMemberPos(id, pos)
    if id == game.Scene.instance:GetMainRoleID() then
        self:SetAppRedPoint()
    end
end

function GuildMemberTemplate:UpdateGuildInfo()
    if not self.update_flag then
        if self.ctrl:CanRecruit() then
            self.ctrl:SendGuildGetJoinReq()
        end
        self.update_flag = true
    end
end

function GuildMemberTemplate:SetListSize(w, h)
    self.list_page:SetSize(w, h)
end

return GuildMemberTemplate