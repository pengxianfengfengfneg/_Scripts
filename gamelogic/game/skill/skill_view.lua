local SkillView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/skill_template",
        item_class = "game/skill/skill_template",
        check_red_func = function()
            return game.SkillCtrl.instance:CheckSkillRedPoint()
        end,
    },
    {
        item_path = "list_page/practice_template",
        item_class = "game/skill/practice_template",
        check_red_func = function()
            return game.SkillCtrl.instance:CheckPracticeRedPoint()
        end,
    },
    {
        item_path = "list_page/gather_template",
        item_class = "game/skill/gather_template",
        check_red_func = function()
            return game.SkillCtrl.instance:CheckGatherRedPoint()
        end,
    },
    {
        item_path = "list_page/equip_forge_template",
        item_class = "game/skill/forge_template",
        check_red_func = function()
            return game.SkillCtrl.instance:CheckForeRedPoint()
        end,
    },
}

local practice_open_lv = config.sys_config.guild_practice_open_lv.value

function SkillView:_init(ctrl)
    self._package_name = "ui_skill"
    self._com_name = "skill_view"

    self._show_money = true

    self.ctrl = ctrl
end

function SkillView:OpenViewCallBack(open_idx)
    self:Init(open_idx)
    self:InitBg()

    self:InitPage()

    self:CheckRedPoint()

    self:RegisterAllEvents()
end

function SkillView:RegisterAllEvents()
    local events = {
        {game.SkillEvent.SkillUpgrade, handler(self, self.OnSkillUpgrade)},
        {game.SkillEvent.SkillOneKeyUp, handler(self, self.OnSkillOneKeyUp)},
        {game.HeroEvent.GuideChange, handler(self, self.OnGuideChange)},
        {game.HeroEvent.HeroUseGuide, handler(self, self.OnHeroUseGuide)},
        {game.GuildEvent.UpdatePracticeInfo, handler(self, self.OnUpdatePracticeInfo)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SkillView:Init(open_idx)
    self.list_tab = self._layout_objs["list_tab"]

    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)

    self.page_controller = self:GetRoot():AddControllerCallback("c1", function(idx, pre_idx)
        self:OnClickPage(idx, pre_idx)
    end)

    open_idx = open_idx or 1

    --修炼49级，打造50级开启
    local mainrole_lv = game.Scene.instance:GetMainRoleLevel()
    if mainrole_lv < practice_open_lv then
        self.list_page:SetLastPageCallBack(1, function()
        end)
        if open_idx == 3 then
            open_idx = 1
        end
    elseif mainrole_lv < 50 then
        self.list_page:SetLastPageCallBack(2, function()
        end)
        if open_idx == 4 then
            open_idx = 1
        end
    else
        self.list_page:SetLastPageCallBack(4, function()
        end)
    end

    self.page_controller:SetSelectedIndexEx(open_idx-1)
end

function SkillView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5456])
end

function SkillView:InitPage()
    for k,v in ipairs(PageConfig) do
        v.page_item = self:GetTemplate(v.item_class, v.item_path, v.check_red_func)
    end
end

function SkillView:OnClickPage(idx, pre_idx)
    local mainrole_lv = game.Scene.instance:GetMainRoleLevel()

    local is_enable = true
    --修炼49级，打造50级开启提示
    if idx == 1 then
        if mainrole_lv < practice_open_lv then
            is_enable = false
            game.GameMsgCtrl.instance:PushMsg(practice_open_lv .. config.words[2101])
        end
    end

    if idx >= 2 then
        if mainrole_lv < 50 then
            is_enable = false
            game.GameMsgCtrl.instance:PushMsg("50" .. config.words[2101])
        end
    end
end

function SkillView:CloseViewCallBack()
    if game.GuideCtrl.instance then
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_skill/skill_view/close_btn"})
    end
end

function SkillView:CheckRedPoint()
    for k,v in ipairs(PageConfig) do
        local is_red = v.check_red_func()
        local tab = self.list_tab:GetChildAt(k-1)
        game_help.SetRedPoint(tab, is_red, 15, 2)

        v.page_item:CheckRedPoint()
    end
end

function SkillView:OnSkillUpgrade(skill_id, skill_lv)
    for k,v in ipairs(PageConfig) do
        local page_item = v.page_item
        if page_item.OnSkillUpgrade then
            page_item:OnSkillUpgrade(skill_id, skill_lv)

            page_item:CheckRedPoint()

            local tab = self.list_tab:GetChildAt(k-1)
            game_help.SetRedPoint(tab, v.check_red_func(), 15, 2)
        end
    end
end

function SkillView:OnSkillOneKeyUp(skill_list)
    for k,v in ipairs(PageConfig) do
        local page_item = v.page_item
        if page_item.OnSkillOneKeyUp then
            page_item:OnSkillOneKeyUp(skill_list)

            page_item:CheckRedPoint()

            local tab = self.list_tab:GetChildAt(k-1)
            game_help.SetRedPoint(tab, v.check_red_func(), 15, 2)
        end
    end
end

function SkillView:OnGuideChange(data)
    for k,v in ipairs(PageConfig) do
        local page_item = v.page_item
        if page_item.OnGuideChange then
            page_item:OnGuideChange(data)

            page_item:CheckRedPoint()

            local tab = self.list_tab:GetChildAt(k-1)
            game_help.SetRedPoint(tab, v.check_red_func(), 15, 2)
        end
    end
end

function SkillView:OnHeroUseGuide(skill_list, guide_id)
    for k,v in ipairs(PageConfig) do
        local page_item = v.page_item
        if page_item.OnHeroUseGuide then
            page_item:OnHeroUseGuide(skill_list, guide_id)

            page_item:CheckRedPoint()

            local tab = self.list_tab:GetChildAt(k-1)
            game_help.SetRedPoint(tab, v.check_red_func(), 15, 2)
        end
    end
end

function SkillView:OnUpdatePracticeInfo()
    for k,v in ipairs(PageConfig) do
        local page_item = v.page_item
        if page_item.OnUpdatePracticeInfo then
            local tab = self.list_tab:GetChildAt(k-1)
            game_help.SetRedPoint(tab, v.check_red_func(), 15, 2)
        end
    end
end

return SkillView
