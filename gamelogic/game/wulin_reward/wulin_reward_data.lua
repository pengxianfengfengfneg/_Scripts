local WulinRewardData = Class(game.BaseData)

function WulinRewardData:_init(ctrl)
    self.ctrl = ctrl
end

function WulinRewardData:_delete()

end

function WulinRewardData:SetInfo(t, grad)
    self.times = t
    self.grade = grad
    self:FireEvent(game.WulinRewardEvent.WulinRewardChange)
end

function WulinRewardData:SetTask(tasks)
    self.task_list = tasks
    table.sort(self.task_list, function(a, b)
        return a.grade < b.grade
    end)
    self:FireEvent(game.WulinRewardEvent.WulinRewardChange)
end

function WulinRewardData:GetGrade()
    return self.grade
end

function WulinRewardData:GetTimes()
    return self.times or 0
end

function WulinRewardData:GetTaskList()
    return self.task_list or {}
end

function WulinRewardData:GetAcceptTask()
    if self.task_list then
        if self.task_list[self.grade] then
            return self.task_list[self.grade].id
        end
    end
end

return WulinRewardData