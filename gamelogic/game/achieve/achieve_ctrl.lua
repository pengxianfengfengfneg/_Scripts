local AchieveCtrl = Class(game.BaseCtrl)

function AchieveCtrl:_init()
    if AchieveCtrl.instance ~= nil then
        error("AchieveCtrl Init Twice!")
    end
    AchieveCtrl.instance = self

    self.achieve_view = require("game/achieve/achieve_view").New()
    self.data = require("game/achieve/achieve_data").New()
    self.achieve_complete_view = require("game/achieve/achieve_complete_view").New()

    self:RegisterAllProtocal()
end

function AchieveCtrl:_delete()
    self.achieve_view:DeleteMe()
    self.data:DeleteMe()
    self.achieve_complete_view:DeleteMe()

    AchieveCtrl.instance = nil
end

function AchieveCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(42702, "OnAchieveInfo")
    self:RegisterProtocalCallback(42704, "OnGetReward")
    self:RegisterProtocalCallback(42705, "OnNotifyInfo")
end

function AchieveCtrl:SendAchieveInfo()
    self:SendProtocal(42701)
end

function AchieveCtrl:OnAchieveInfo(data)
    self.data:SetAchieveInfo(data)
    self:FireEvent(game.AchieveEvent.AchieveInfo)
end

function AchieveCtrl:GetAchieveInfo()
    return self.data:GetAchieveInfo()
end

function AchieveCtrl:SendGetReward(id)
    self:SendProtocal(42703, {id = id})
end

function AchieveCtrl:OnGetReward()
end

function AchieveCtrl:OnNotifyInfo(data)
    self.data:SetNotifyInfo(data)
    for _, v in pairs(data.tasks) do
        local task = self.data:GetAchieveTaskInfo(math.floor(v.id / 100))
        if v.state == 3 and task.id == v.id then
            self.achieve_complete_view:Open(v)
            break
        end
    end
    self:FireEvent(game.AchieveEvent.AchieveInfo, data)
end

function AchieveCtrl:OpenView()
    if self:GetAchieveInfo() then
        self.achieve_view:Open()
    end
end

function AchieveCtrl:GetAchieveTaskInfo(id)
    return self.data:GetAchieveTaskInfo(id)
end

function AchieveCtrl:GetAchieveTypeInfo(type)
    return self.data:GetAchieveTypeInfo(type)
end

function AchieveCtrl:GetAchieveTypeTips(type)
    return self.data:GetAchieveTypeTips(type)
end

function AchieveCtrl:GetAchieveCateTips(cate)
    return self.data:GetAchieveCateTips(cate)
end

function AchieveCtrl:GetAchieveTips()
    return self.data:GetAchieveTips()
end

game.AchieveCtrl = AchieveCtrl

return AchieveCtrl