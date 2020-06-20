local StudyItem = Class(game.UITemplate)

local _study_task_config = config.mentor_task[game.TaskType.MentorStudy]

function StudyItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function StudyItem:OpenViewCallBack()
    self.img_bg = self._layout_objs["img_bg"]
    self.img_bg2 = self._layout_objs["img_bg2"]
    self.img_ywc = self._layout_objs["img_ywc"]

    self.txt_name = self._layout_objs["txt_name"]
    self.txt_add_value = self._layout_objs["txt_add_value"]
    self.txt_status = self._layout_objs["txt_status"]
end

function StudyItem:SetItemInfo(item_info, idx)
    self.info = item_info
    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)

    local task_cfg = _study_task_config[item_info.id]
    self.txt_name:SetText(task_cfg.desc)
    self.txt_add_value:SetText(string.format("+%d", task_cfg.mark))

    local max_progress = task_cfg.cond[2]
    self.txt_status:SetText(string.format("%d/%d", item_info.progress, max_progress))

    local is_finish = item_info.progress >= max_progress
    self.img_ywc:SetVisible(is_finish)
    self.txt_status:SetVisible(not is_finish)
end

return StudyItem