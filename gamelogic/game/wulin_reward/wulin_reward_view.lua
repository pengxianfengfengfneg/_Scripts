local WulinRewardView = Class(game.BaseView)

function WulinRewardView:_init(ctrl)
    self._package_name = "ui_wulin_reward"
    self._com_name = "wulin_reward_view"
    self._show_money = true

    self.ctrl = ctrl
    self.data = ctrl.data
end

function WulinRewardView:_delete()
    
end

function WulinRewardView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1684])

    self.task_list = {}

    self.ui_list = game.UIList.New(self._layout_objs["task_list"])
    self.ui_list:SetVirtual(true)
    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/wulin_reward/wulin_reward_item").New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:Refresh(self.task_list[idx].grade, self.task_list[idx].id)
    end)

    self:BindEvent(game.WulinRewardEvent.WulinRewardChange, function()
        self:RefreshInfo()
    end)

    self:RefreshInfo()
end

function WulinRewardView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function WulinRewardView:RefreshInfo()
    self.task_list = self.data:GetTaskList()
    self.ui_list:SetItemNum(#self.task_list)
    self._layout_objs["left_txt"]:SetText(string.format(config.words[5752], config.sys_config["prize_task_max_times"].value - self.data:GetTimes()))
end

return WulinRewardView
