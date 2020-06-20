local GuildNewView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/guild_info_template",
        item_class = "game/guild/template/guild_info_template",
    },
    {
        item_path = "list_page/guild_member_template",
        item_class = "game/guild/template/guild_member_template",
    },
    {
        item_path = "list_page/guild_build_template",
        item_class = "game/guild/template/guild_build_template",
    },
    {
        item_path = "list_page/guild_welfare_template",
        item_class = "game/guild/template/guild_welfare_template",
    },
    {
        item_path = "list_page/guild_battle_template",
        item_class = "game/guild/template/guild_battle_template",
    },
}

function GuildNewView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_new_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function GuildNewView:OpenViewCallBack(open_idx, args)
    self:Init(open_idx, args)
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendGuildInfo()
end

function GuildNewView:CloseViewCallBack()

end

function GuildNewView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.LeaveGuild, function()
            self:Close()
        end},
    }
    for k,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildNewView:Init(open_idx, args)
    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)
    self:InitView(open_idx, args)
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
        self:SetGuideIndex(idx+1)
    end)

    open_idx = open_idx or 1
    self.ctrl_page:SetSelectedIndexEx(open_idx-1)

    self._layout_objs["list_tab"]:GetChildAt(3):AddClickCallBack(function()
        self.ctrl_page:SetSelectedIndex(3)
        self:SetGuideIndex(4)
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_guild/guild_new_view/btn_welfare"})
        game.ViewMgr:FireGuideEvent()
    end)

    self:BindRedEvent(self._layout_objs["list_tab"]:GetChildAt(1), {game.GuildEvent.UpdateAppList, game.GuildEvent.UpdateMemberPos}, function()
        if self.ctrl:CanRecruit() then
            local apply_info = self.ctrl:GetGuildApplyInfo()
            return apply_info and #apply_info > 0 or false
        end
        return false
    end)
end

function GuildNewView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4773])
    self._layout_objs["common_bg/btn_close"]:AddClickCallBack(function ()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_guild/guild_new_view/btn_close"})
        self:Close()
    end)
end

function GuildNewView:InitView(open_idx, args)
    for k, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path, k==open_idx and args)
    end
end

function GuildNewView:GetPageTemplate(idx)
    return self:GetTemplate(PageConfig[idx].item_class, PageConfig[idx].item_path)
end

function GuildNewView:RefreshView(open_idx, args)
    self.ctrl_page:SetSelectedIndexEx(open_idx-1)
    local page = self:GetPageTemplate(open_idx)
    if page.RefreshView then
        page:RefreshView(args)
    end
end

function GuildNewView:BindRedEvent(node, events, check_func)
    for k, v in pairs(events) do
        self:BindEvent(v, function()
            local is_red = check_func()
            game_help.SetRedPoint(node, is_red)
        end)
    end
    local is_red = check_func()
    game_help.SetRedPoint(node, is_red)
end

return GuildNewView
