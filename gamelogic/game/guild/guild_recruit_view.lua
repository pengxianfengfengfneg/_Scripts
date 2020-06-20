local GuildRecruitView = Class(game.BaseView)

function GuildRecruitView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_recruit_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildRecruitView:_delete()

end

function GuildRecruitView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitComboFight()
end

function GuildRecruitView:CloseViewCallBack()
    self.common_bg = nil
    self:StopTimeCounter()
end

function GuildRecruitView:Init()  
    self.label_fight = self._layout_objs["label_fight"]
    self.label_desc = self._layout_objs["label_desc"]

    self.txt_fight = self._layout_objs["txt_fight"]
    self.txt_time = self._layout_objs["txt_time"]

    self.btn_checkbox = self._layout_objs["btn_checkbox"]
    self.btn_recruit = self._layout_objs["btn_recruit"]

    self.combo_fight = self._layout_objs["combo_fight"]

    self:RegisterAllEvents()
end

function GuildRecruitView:InitBg()
    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[2334])

    self.common_bg.btn_close:AddClickCallBack(function()
        self:SetRecruitSetting()
        self:Close()
    end)
    self.common_bg.btn_back:AddClickCallBack(function()
        self:SetRecruitSetting()
        self:Close()
    end)

    self.label_fight:SetText(config.words[2335])
    self.label_desc:SetText(config.words[2337])

    self.btn_checkbox:SetSelected(self.ctrl:GetGuildInfo().auto_accept == 1)

    self.btn_recruit:SetText(config.words[2338])
    self.btn_recruit:AddClickCallBack(function()
        self.ctrl:SendGuildRecruit()
    end)

    self.txt_time:SetText("")
    self:StartTimeCounter(self.ctrl:GetRecruitTime())
end

function GuildRecruitView:SetFightText(fight)
    self.txt_fight:SetText(string.format(config.words[2336], fight))
end

function GuildRecruitView:InitComboFight()
    local combo_items = {}
    for k, v in pairs(config.guild_accept) do
        table.insert(combo_items, v)
    end
    table.sort(combo_items, function(m, n)
        return m.id < n.id
    end)
    for k, v in pairs(combo_items) do
        combo_items[k] = v.fight
        if combo_items[k] ~= 0 then
            combo_items[k] = string.format(config.words[2336], combo_items[k]/10000)
        end
    end
    self.combo_fight:SetItems(combo_items)
    local guild = self.ctrl:GetGuildInfo()
    self.combo_fight:SetSelectIndex(guild.accept_type or 0)
end

function GuildRecruitView:OnEmptyClick()

end

function GuildRecruitView:SetRecruitSetting()
    self.ctrl:SendGuildChangeAcceptType(self.combo_fight:GetSelectIndex(), self.btn_checkbox:GetSelected() and 1 or 0)
end

function GuildRecruitView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.GuildRecruit, handler(self, self.OnGuildRecruit)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildRecruitView:OnGuildRecruit(recruit_time)
    self:StartTimeCounter(recruit_time)
end

function GuildRecruitView:StartTimeCounter(recruit_time)
    self:StopTimeCounter()
    local end_time = recruit_time + config.sys_config["guild_recruit_cd"].value

    self.seq = DOTween:Sequence()
    self.seq:AppendCallback(function()
        local time = math.max(0, end_time - global.Time:GetServerTime())
        local minute = math.ceil(time / 60)
        self.txt_time:SetText(string.format(config.words[6014], minute))
        if time <= 0 then
            self.txt_time:SetText("")
            self:StopTimeCounter()
        end
    end)
    self.seq:AppendInterval(1)
    self.seq:SetLoops(-1)
    self.seq:Play()
end

function GuildRecruitView:StopTimeCounter()
    if self.seq then
        self.seq:Kill(false)
        self.seq = nil
    end
end

return GuildRecruitView
