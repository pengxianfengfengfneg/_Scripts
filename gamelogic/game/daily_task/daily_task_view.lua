local DailyTaskView = Class(game.BaseView)

function DailyTaskView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "daily_task_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function DailyTaskView:_delete()
    
end

function DailyTaskView:OpenViewCallBack(index, ...)
    self.index = index or 1
    self.open_params = ...
    self:InitBg()
    self:InitMoney()
    self:InitTemplate()
    self:InitTabList()
    self:RegisterAllEvents()
end

function DailyTaskView:CloseViewCallBack()
    self.common_bg = nil
end

function DailyTaskView:InitBg()
    self.common_bg = self:GetBgTemplate("common_bg")
    self.tab_list_bg = self._layout_objs["common_bg/n15"]
end

function DailyTaskView:InitTemplate()
    self.tpl_cfg = {
        {"game/daily_task/template/daily_task_cxdt_template", "template_cxdt", config.words[1901]},
        {"game/daily_task/template/daily_task_thief_template", "template_thief", config.words[1904]},
        {"game/daily_task/template/daily_task_guild_template", "template_guild", config.words[5100]},
        {"game/daily_task/template/daily_task_examine_template", "template_examine", config.words[5126]},
        {"game/daily_task/template/daily_task_treasure_template", "template_treasure", config.words[1950]},
    }

    self.tab_control = self:GetRoot():AddControllerCallback("ctrl_tab",function(idx)
        self:OnClickTab(idx+1)
    end)

    self:SetThiefTemplateShow()
    self:SetGuildTemplateShow()
    self:SetExamineTemplateShow()
end

function DailyTaskView:SetTemplateShowEnable(tpl_name, enable, msg)
    local tpl_idx
    for idx, v in pairs(self.tpl_cfg) do
        if v[2] == tpl_name then
            tpl_idx = idx
            break
        end
    end
    if tpl_idx then
        local btn = self._layout_objs.list_tabs:GetChildAt(tpl_idx - 1)
        if enable then
            btn:AddClickCallBack(function()
                self.tab_control:SetSelectedIndexEx(tpl_idx - 1)
            end)
        else
            btn:AddClickCallBack(function()
                game.GameMsgCtrl.instance:PushMsg(msg)
            end)
        end
    end
end

function DailyTaskView:SetThiefTemplateShow()
    local role_level = game.RoleCtrl.instance:GetRoleLevel()
    local open_lv = config.daily_thief.open_lv
    local error_msg = string.format(config.words[5115], open_lv)
    self:SetTemplateShowEnable("template_thief",  role_level >= open_lv, error_msg)
end

function DailyTaskView:SetGuildTemplateShow()
    local role_level = game.RoleCtrl.instance:GetRoleLevel()
    local open_lv = config.guild_task_info.open_lv
    local error_msg = string.format(config.words[5115], open_lv)
    self:SetTemplateShowEnable("template_guild",  role_level >= open_lv, error_msg)
end

function DailyTaskView:SetExamineTemplateShow()
    local role_level = game.RoleCtrl.instance:GetRoleLevel()
    local open_lv = config.examine_info.open_lv
    local error_msg = string.format(config.words[5115], open_lv)
    self:SetTemplateShowEnable("template_examine",  role_level >= open_lv, error_msg)
end

function DailyTaskView:InitMoney()
    
end

function DailyTaskView:InitTabList()
    self.tab_list = self._layout_objs["list_tabs"]

	for k, v in ipairs(self.tpl_cfg) do
        local tab = self.tab_list:GetChildAt(k-1)
        tab:SetText(v[3])
    end
    self:Refresh(self.index)
    self.tab_list:ScrollToView(self.index - 1, false, true)
    self.tab_list:GetChildAt(self.index - 1):SetSelected(true)

    if game.IsZhuanJia then
        -- self.tab_list.foldInvisibleItems = true
        -- self:Refresh(self.index)
        -- self.tab_list:GetChildAt(self.index - 1):SetSelected(true)
    end
end

function DailyTaskView:OnClickTab(index)
    local cfg = self.tpl_cfg[index]
    if cfg then
        local template = self:GetTemplate(cfg[1], cfg[2])
        if self.cur_act_tpl and self.cur_act_tpl.Inactive then
            self.cur_act_tpl:Inactive()
        end
        
        template:Active(self.open_params)
        if self.open_params then
            self.open_params = nil
        end

        self.cur_act_tpl = template
        self.common_bg:SetTitleName(cfg[3])
    end
end

function DailyTaskView:Refresh(index)
    self.tab_control:SetSelectedIndexEx(index - 1)
end

function DailyTaskView:RegisterAllEvents()
    local events = {
        [game.RoleEvent.LevelChange] = function()
            self:SetThiefTemplateShow()
            self:SetGuildTemplateShow()
            self:SetExamineTemplateShow()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return DailyTaskView
