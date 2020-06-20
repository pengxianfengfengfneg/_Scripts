local MentorTaskItem = Class(game.UITemplate)

function MentorTaskItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function MentorTaskItem:OpenViewCallBack()
    self.txt_cond = self._layout_objs["txt_cond"]
    self.txt_times = self._layout_objs["txt_times"]

    self.img_bg = self._layout_objs["img_bg"]
    self.img_bg2 = self._layout_objs["img_bg2"]
    self.img_ywc = self._layout_objs["img_ywc"]
end

function MentorTaskItem:SetItemInfo(item_info, idx)
    local task_cfg = config.mentor_task[game.TaskType.MentorTask][item_info.id]
    local max_progress = task_cfg.cond[2]
    self.txt_cond:SetText(task_cfg.desc)
    self.txt_times:SetText(string.format("%d/%d", item_info.progress, max_progress))

    local is_finish = item_info.progress >= max_progress
    self.img_ywc:SetVisible(is_finish)
    self.txt_times:SetVisible(not is_finish)
    if self._layout_objs["btn_go"] then
        self._layout_objs["btn_go"]:SetVisible(not is_finish)
    end

    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)
end

function MentorTaskItem:AddClickEvent(click_event)
    self._layout_objs["btn_go"]:AddClickCallBack(function()
        click_event()
    end)
end

return MentorTaskItem