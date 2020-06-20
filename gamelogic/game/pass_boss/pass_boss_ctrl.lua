local PassBossCtrl = Class(game.BaseCtrl)

local handler = handler
local global_time = global.Time
local event_mgr = global.EventMgr
local config_func = config.func

function PassBossCtrl:_init()
    if PassBossCtrl.instance ~= nil then
        error("PassBossCtrl Init Twice!")
    end
    PassBossCtrl.instance = self

    self.view = require("game/pass_boss/pass_boss_view").New(self)
    self.help_view = require("game/pass_boss/pass_help_view").New(self)
    self.reward_view = require("game/pass_boss/pass_reward_view").New(self)

    self.data = require("game/pass_boss/pass_boss_data").New(self)

    self._is_auto_pass = false
    self._is_doing_pass = false

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()

end

function PassBossCtrl:_delete()

    self.view:DeleteMe()
    self.help_view:DeleteMe()
    self.reward_view:DeleteMe()

    self.data:DeleteMe()

    PassBossCtrl.instance = nil
end

function PassBossCtrl:RegisterAllEvents()
    local events = {
        {game.GameEvent.StartPlay, handler(self, self.OnStartPlay)},
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function PassBossCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(10842, "OnGetTaskBossInfoResp")
    self:RegisterProtocalCallback(10844, "OnChallengePassResp")
    self:RegisterProtocalCallback(10846, "OnGetPassRewardResp")
    self:RegisterProtocalCallback(10847, "OnNotifyPassProcChange")
    self:RegisterProtocalCallback(10849, "OnNextPassResp")

end

function PassBossCtrl:OpenView(pass_id)
    local pass_id = pass_id or self:GetCurPassId()
    self.view:Open(pass_id)
end

function PassBossCtrl:CloseView()
    self.view:Close()
end

function PassBossCtrl:OpenHelpView(pass_id)
    self.help_view:Open(pass_id)
end

function PassBossCtrl:OpenRewardView()
    local reward_list = self:GetPassRewardList()
    if #reward_list <= 0 then
        return
    end

    self.reward_view:Open()
end

function PassBossCtrl:SendGetTaskBossInfoReq()
    local proto = {

    }
    self:SendProtocal(10841, proto)
end

function PassBossCtrl:OnGetTaskBossInfoResp(data)
    --[[
        "pass__I",
        "stat__C",
        "req_proc__T__mon_id@I##cur@H##require@H",
        "rewards__T__pass@I",
    ]]
    --PrintTable(data)

    self.data:OnGetTaskBossInfoResp(data)

    self:FireEvent(game.PassBossEvent.UpdatePass, data.pass, data.stat)
    self:FireEvent(game.PassBossEvent.UpdateReward, data.pass)

    if data.stat == 4 then
        self:SendNextPassResp()
    end
end

function PassBossCtrl:SendChallengePassReq()
    local proto = {

    }
    self:SendProtocal(10843, proto)

    --PrintTable(proto)
end

function PassBossCtrl:OnChallengePassResp(data)
    --[[
        "ret__C",
    ]]
    --PrintTable(data)

    if data.ret == 0 then
        self:CloseView()

        self:FireEvent(game.PassBossEvent.BossComing)
    end
end

function PassBossCtrl:SendGetPassRewardReq(pass)
    local proto = {
        pass = pass,
    }
    self:SendProtocal(10845, proto)
end

function PassBossCtrl:OnGetPassRewardResp(data)
    --[[
        "ret__C",
        "pass__I",
        "rewards__T__pass@I",
    ]]
    --PrintTable(data)

    self.data:OnGetPassRewardResp(data)

    self:FireEvent(game.PassBossEvent.UpdateReward, data.pass)

    self:OpenRewardView()
end

function PassBossCtrl:OnNotifyPassProcChange(data)
    --[[
        "pass__I",
        "stat__C",
        "proc__T__mon_id@I##cur@H##require@H",
    ]]
    --PrintTable(data)

    self.data:OnNotifyPassProcChange(data)

    self:FireEvent(game.PassBossEvent.UpdatePass, data.pass, data.stat)

    if data.stat == 2 then
        if self:IsAutoPass() then
            self:SendChallengePassReq()
        end
    end

end

function PassBossCtrl:SendNextPassResp()
    local proto = {
        
    }
    self:SendProtocal(10848, proto)
end

function PassBossCtrl:OnNextPassResp(data)
    --[[
        "ret__C",
    ]]
    --PrintTable(data)
end

function PassBossCtrl:IsSectionCompleted(pass_id)
    return self.data:IsSectionCompleted(pass_id)
end

function PassBossCtrl:IsChapterCompleted(pass_id)
    return self.data:IsChapterCompleted(pass_id)
end

function PassBossCtrl:GetChapterName(pass_id)
    return self.data:GetChapterName(pass_id)
end

function PassBossCtrl:GetSectionName(pass_id)
    return self.data:GetSectionName(pass_id)
end

function PassBossCtrl:CalcSectionProgress(pass_id)
    return self.data:CalcSectionProgress(pass_id)
end

function PassBossCtrl:GetPassAcceptRequireInfo()
    return self.data:GetPassAcceptRequireInfo()
end

function PassBossCtrl:CanChallengePass()
    return self.data:CanChallengePass()
end

function PassBossCtrl:IsDoingChallenge()
    return self.data:IsDoingChallenge()
end

function PassBossCtrl:GetCurPassState()
    return self.data:GetCurPassState()
end

function PassBossCtrl:GetCurPassId()
    return self.data:GetCurPassId()
end

function PassBossCtrl:GetPassRewardList()
    return self.data:GetPassRewardList()
end

function PassBossCtrl:CheckRedPoint()
    local reward_list = self:GetPassRewardList() or {}
    return #reward_list>0
end

function PassBossCtrl:GetPassSectionRewardId(pass_id)
    return self.data:GetPassSectionRewardId(pass_id)
end

function PassBossCtrl:IsAutoPass()
    return self._is_auto_pass
end

function PassBossCtrl:IsDoingPass()
    return self._is_doing_pass
end

function PassBossCtrl:SetAutoPass(val)
    self._is_auto_pass = false

    local pass_scene_id = self:GetCurPassScene()
    local scene_logic = game.Scene.instance:GetSceneLogic()
    if not scene_logic:CanChangeScene(pass_scene_id) then
        return false, false, 0, true
    end

    self._is_auto_pass = val

    local cur_scene = game.Scene.instance
    local cur_scene_id = cur_scene:GetSceneID()    
    local is_pass_scene = (cur_scene_id==pass_scene_id)

    if val then
        if is_pass_scene then
            if self:CanChallengePass() then
                self:SendChallengePassReq()
            end
        else
            cur_scene:SendChangeSceneReq(pass_scene_id)
        end
    end

    return val,is_pass_scene,pass_scene_id,false
end

function PassBossCtrl:GetCurPassScene()
    return self.data:GetCurPassScene()
end

function PassBossCtrl:OnStartPlay(scene_id)
    if self:IsAutoPass() then
        if scene_id == self:GetCurPassScene() then
            if self:CanChallengePass() then
                self:SendChallengePassReq()
            end
            self:FireEvent(game.SceneEvent.MainRoleAutoPass, true)
        end
    end
end

function PassBossCtrl:GetCurChapter()
    return self.data:GetCurChapter()
end

function PassBossCtrl:GetCurChapterConfig()
    return self.data:GetCurChapterConfig()
end

function PassBossCtrl:GetPassSceneConfig(scene_id)
    return self.data:GetPassSceneConfig(scene_id)
end

game.PassBossCtrl = PassBossCtrl

return PassBossCtrl
