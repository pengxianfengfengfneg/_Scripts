local WulinRewardCtrl = Class(game.BaseCtrl)

function WulinRewardCtrl:_init()
	if WulinRewardCtrl.instance ~= nil then
		error("WulinRewardCtrl Init Twice!")
	end
	WulinRewardCtrl.instance = self
	
	self.data = require("game/wulin_reward/wulin_reward_data").New(self)
    self.view = require("game/wulin_reward/wulin_reward_view").New(self)

	self:RegisterAllProtocal()
end

function WulinRewardCtrl:_delete()
    self.data:DeleteMe()
    self.data = nil

    self.view:DeleteMe()
    self.view = nil

	WulinRewardCtrl.instance = nil
end

function WulinRewardCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(42602, "OnPrizeInfo")
    self:RegisterProtocalCallback(42604, "OnPrizeAccept")
end

function WulinRewardCtrl:OpenView()
    self.view:Open()
end

function WulinRewardCtrl:CloseView()
    self.view:Close()
end

function WulinRewardCtrl:GetData()
    return self.data
end

function WulinRewardCtrl:OnPrizeInfo(data_list)
    self.data:SetTask(data_list.tasks)
    self.data:SetInfo(data_list.times, data_list.grade)
end

function WulinRewardCtrl:OnPrizeAccept(data_list)
    local old_grade = self.data:GetGrade()
    self.data:SetInfo(data_list.times, data_list.grade)

    if (not old_grade or old_grade == 0) and data_list.grade > 0 then
        local task_id = self:GetAcceptTask()
        if task_id then
            self.view:Close()
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoHangTask(task_id)
            end
        end
    end
end

function WulinRewardCtrl:SendPrizeAccept(grade)
    self:SendProtocal(42603, {grade = grade})
end

function WulinRewardCtrl:IsSystemOpen()
    local lv = game.Scene.instance:GetMainRoleLevel()
    local pioneer_lv = game.MainUICtrl.instance:GetPioneerLv()
    return config_help.ConfigHelpLevel.HasPioneerLvAdd(lv, pioneer_lv)
end

function WulinRewardCtrl:GetAcceptTask()
    return self.data:GetAcceptTask()
end

game.WulinRewardCtrl = WulinRewardCtrl

return WulinRewardCtrl