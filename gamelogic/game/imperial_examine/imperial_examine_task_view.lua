local ImperialExamineTaskView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/examine_template",
        item_class = "game/imperial_examine/examine_task_template",
    },
    {
        item_path = "list_page/rank_template",
        item_class = "game/imperial_examine/rank_template",
    },
}

function ImperialExamineTaskView:_init(ctrl)
    self._package_name = "ui_imperial_examine"
    self._com_name = "examine_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self:AddPackage("ui_daily_task")
end

function ImperialExamineTaskView:_delete()
    
end

function ImperialExamineTaskView:OpenViewCallBack(open_idx)
    self:Init(open_idx)
    self:InitBg()
    game.Scene.instance:GetMainRole():SetPauseOperate(true)
end

function ImperialExamineTaskView:CloseViewCallBack()
    local scene = game.Scene.instance
    if scene then
        local main_role = scene:GetMainRole()
        if main_role then
            main_role:SetPauseOperate(false)
        end
    end
end

function ImperialExamineTaskView:Init(open_idx)
    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)
    self:InitView()
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
        self:OnClickPage(idx+1)
    end)

    open_idx = open_idx or 1
    self.ctrl_page:SetSelectedIndexEx(open_idx-1)
end

function ImperialExamineTaskView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5126])
end

function ImperialExamineTaskView:InitView()
    for _, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path)
    end
end

function ImperialExamineTaskView:OnClickPage(index)
    local page = self:GetTemplate(PageConfig[index].item_class, PageConfig[index].item_path)
    page:Active(true)
end

return ImperialExamineTaskView
