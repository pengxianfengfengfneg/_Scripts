local TaskView = Class(game.BaseView)

local PageConfig = {
	{
        item_path = "list_page/task_template",
        item_class = "game/task/task_template",
    },
    {
        item_path = "list_page/daily_template",
        item_class = "game/task/daily_template",
    },
}

function TaskView:_init(ctrl)
    self._package_name = "ui_task"
    self._com_name = "task_view"

    self._show_money = true
    self.guide_index = 1
    self.ctrl = ctrl
end

function TaskView:OpenViewCallBack()
	self:Init()
	self:InitBg()
	
end

function TaskView:CloseViewCallBack()

end

function TaskView:Init()
	self:InitCommon()
	self:InitPage()
	self:InitTab()
end

function TaskView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2160])
end

function TaskView:InitCommon()
	
end

function TaskView:InitPage()
	self.list_page = self._layout_objs["list_page"]
	self.list_page:SetHorizontalBarTop(true)

	for k,v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path, self.ctrl)
    end
end

function TaskView:InitTab()
	self.list_tab = self._layout_objs["list_tab"]
end

return TaskView
