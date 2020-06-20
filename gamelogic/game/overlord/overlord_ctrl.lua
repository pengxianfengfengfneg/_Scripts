local OverlordCtrl = Class(game.BaseCtrl)

function OverlordCtrl:_init()
    if OverlordCtrl.instance ~= nil then
        error("OverlordCtrl Init Twice!")
    end
    OverlordCtrl.instance = self

    self.overlord_view = require("game/overlord/overlord_view").New(self)
    self.overlord_data = require("game/overlord/overlord_data").New(self)
    self.rob_list_view = require("game/overlord/rob_list_view").New(self)
    self.score_log_view = require("game/overlord/score_log_view").New(self)
    self.boss_info_view = require("game/overlord/boss_info_view").New(self)

    self:RegisterAllProtocal()
    self:RegisterEvent()
end

function OverlordCtrl:_delete()
    self.overlord_view:DeleteMe()
    self.overlord_data:DeleteMe()
    self.rob_list_view:DeleteMe()
    self.score_log_view:DeleteMe()
    self.boss_info_view:DeleteMe()

    OverlordCtrl.instance = nil
end

function OverlordCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(31002, "OnOverlordInfo")
    self:RegisterProtocalCallback(31004, "OnOverlordLog")
    self:RegisterProtocalCallback(31006, "OnOverlordRank")
    self:RegisterProtocalCallback(31007, "OnOverlordRank")   --  排行榜推送
    self:RegisterProtocalCallback(31008, "OnOverlordHp")
    self:RegisterProtocalCallback(31022, "OnEnterOverlord")
    self:RegisterProtocalCallback(31024, "OnLeaveOverlord")
    self:RegisterProtocalCallback(31026, "OnEnterRob")
    self:RegisterProtocalCallback(31028, "OnLeaveRob")
    self:RegisterProtocalCallback(31029, "OnOverlordResult")
    self:RegisterProtocalCallback(31030, "OnRobResult")
    self:RegisterProtocalCallback(31031, "OnBeRobResult")
end

function OverlordCtrl:RegisterEvent()
    self:BindEvent(game.SceneEvent.ChangeScene, function(to_scene_id, from_scene_id)
        if from_scene_id == config.sys_config.master_chap_scene.value then
            self.boss_info_view:Close()
            game.FightCtrl.instance:CloseReviveView()
        end
    end)
end

function OverlordCtrl:OpenView()
    self.overlord_view:Open()
end

function OverlordCtrl:SendOverlordInfo()
    self:SendProtocal(31001)
end

function OverlordCtrl:OnOverlordInfo(data)
    self.overlord_data:SetInfo(data)
    self:FireEvent(game.OverlordEvent.Info, data)
end

function OverlordCtrl:GetInfo()
    return self.overlord_data:GetInfo()
end

function OverlordCtrl:SendOverlordLog()
    self:SendProtocal(31003)
end

function OverlordCtrl:OnOverlordLog(data)
    self:FireEvent(game.OverlordEvent.Log, data)
end

function OverlordCtrl:SendOverlordRank()
    self:SendProtocal(31005)
end

function OverlordCtrl:OnOverlordRank(data)
    self.overlord_data:SetRankData(data)
    self:FireEvent(game.OverlordEvent.Rank, data)
end

function OverlordCtrl:GetRankData()
    return self.overlord_data:GetRankData()
end

function OverlordCtrl:OnOverlordHp(data)
    self.overlord_data:SetBossHp(data.hp_pert)
    self:FireEvent(game.OverlordEvent.BossHP, data.hp_pert)
end

function OverlordCtrl:GetBossHp()
    return self.overlord_data:GetBossHp()
end

function OverlordCtrl:SendEnterOverlord()
    self:SendProtocal(31021)
end

function OverlordCtrl:OnEnterOverlord()
    self.overlord_view:Close()
    self:OpenBossInfoView()
end

function OverlordCtrl:SendLeaveOverlord()
    self:SendProtocal(31023)
end

function OverlordCtrl:OnLeaveOverlord()
    self.boss_info_view:Close()
end

function OverlordCtrl:SendEnterRob(id)
    self:SendProtocal(31025, { id = id })
end

function OverlordCtrl:OnEnterRob()
    self.overlord_view:Close()
    self.rob_list_view:Close()
end

function OverlordCtrl:SendLeaveRob()
    self:SendProtocal(31027)
end

function OverlordCtrl:OnLeaveRob()
end

function OverlordCtrl:OpenvRobListView()
    self.rob_list_view:Open()
end

function OverlordCtrl:OpenScoreLogView()
    self.score_log_view:Open()
end

function OverlordCtrl:OpenBossInfoView()
    game.MainUICtrl.instance:SwitchToFighting()
    self.boss_info_view:Open()
end

function OverlordCtrl:SendRegister(flag)
    --  0 取消; 1 注册
    self:SendProtocal(31009, {opt = flag})
end

function OverlordCtrl:OnOverlordResult(data)
    local text = string.format(config.words[4611], data.chap_score)
    local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[4601], text)
    msg_box:Open()
end

function OverlordCtrl:OnRobResult(data)
    local text = string.format(config.words[4612], data.name, data.rob_score)
    if data.succ == 0 then
        text = string.format(config.words[4613], data.name)
    end
    local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[4601], text)
    msg_box:Open()
end

function OverlordCtrl:OnBeRobResult(data)
    local text = string.format(config.words[4614], data.name, data.robbed_score)
    if data.succ == 0 then
        text = string.format(config.words[4615], data.name)
    end
    local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[4601], text)
    msg_box:Open()
end

function OverlordCtrl:GetSelfScore()
    return self.overlord_data:GetSelfScore()
end

game.OverlordCtrl = OverlordCtrl

return OverlordCtrl