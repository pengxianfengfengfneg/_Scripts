local RoleOtherTemplate = Class(game.UITemplate)

function RoleOtherTemplate:_init(parent, info)
    self.parent_view = parent
    self.info = info
end

function RoleOtherTemplate:OpenViewCallBack()
    self:RefreshData()
    self:RefreshNotice()

    self:InitBtn()
end

function RoleOtherTemplate:InitBtn()
    self._layout_objs.btn_chat:AddClickCallBack(function()
        game.ChatCtrl.instance:OpenFriendChatView({
            id = self.info.id,
            name = self.info.name,
            lv = self.info.level,
            career = self.info.career,
            svr_num = self.info.server_num,
        })
    end)

    self._layout_objs.btn_friend:AddClickCallBack(function()
        game.FriendCtrl.instance:CsFriendSysApplyAdd(self.info.id)
    end)

    self._layout_objs.btn_guild:SetVisible(false)
    self._layout_objs.btn_follow:SetVisible(false)
end

function RoleOtherTemplate:RefreshData()
    local other_cfg = {
        {
            name = config.words[3302],
            value = self.info.name,
        },
        {
            name = config.words[5570],
            value = self.info.id,
        },
        {
            name = config.words[3303],
            value = config.title[self.info.title] and config.title[self.info.title].name or config.words[3307],
        },
        {
            name = config.words[3304],
            value = self.info.guild_name,
        },
        {
            name = config.words[5571],
            value = self.info.marriage.mate_name,
        },
        {
            name = config.words[3305],
            value = config.words[self.info.stat + 3310],
        },
        {
            name = config.words[3306],
            value = self.info.team_num .. "/5",
        },
    }

    local idx = 1
    for i,v in ipairs(other_cfg) do
        idx = i + 1
        self._layout_objs["n" .. i]:SetText(v.name)
        self._layout_objs["v" .. i]:SetText(v.value)
    end
end

function RoleOtherTemplate:RefreshNotice()
    local msg = self.info.introduction
    if msg == "" then
        msg = config.words[5592]
    end
    self._layout_objs["notice_txt"]:SetText(msg)
end

return RoleOtherTemplate
