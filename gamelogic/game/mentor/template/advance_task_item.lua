local AdvanceTaskItem = Class(game.UITemplate)

local _advance_task_config = config.mentor_task[game.TaskType.MentorAdvance]

function AdvanceTaskItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function AdvanceTaskItem:OpenViewCallBack()
    self.img_bg = self._layout_objs["img_bg"]
    self.img_bg2 = self._layout_objs["img_bg2"]
    self.img_ywc = self._layout_objs["img_ywc"]

    self.txt_name = self._layout_objs["txt_name"]
    self.txt_status = self._layout_objs["txt_status"]
end

function AdvanceTaskItem:SetItemInfo(item_info, idx)
    self.info = item_info
    local task_cfg = _advance_task_config[item_info.id]
    self.txt_name:SetText(task_cfg.desc)

    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)

    local max_progress = task_cfg.cond[2]
    self.txt_status:SetText(string.format("%d/%d", item_info.progress, max_progress))
    
    local is_finish = item_info.progress >= max_progress
    self.img_ywc:SetVisible(is_finish)
    self.txt_status:SetVisible(not is_finish)
end

return AdvanceTaskItem