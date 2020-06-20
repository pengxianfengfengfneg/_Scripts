local FeedbackCtrl = Class(game.BaseCtrl)

function FeedbackCtrl:_init()
    if FeedbackCtrl.instance ~= nil then
        error("FeedbackCtrl Init Twice!")
    end
    FeedbackCtrl.instance = self

    self.view = require("game/feedback/feedback_view").New(self)
    self.data = require("game/feedback/feedback_data").New(self)
   
    self:RegisterAllProtocal()

    global.Runner:AddUpdateObj(self, 2)
end

function FeedbackCtrl:_delete()
    global.Runner:RemoveUpdateObj(self)
    self.view:DeleteMe()
    self.data:DeleteMe()
    
    FeedbackCtrl.instance = nil
end

function FeedbackCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(53702, "OnFeedbackInfo")
    self:RegisterProtocalCallback(53704, "OnFeedbackCommit")
end

function FeedbackCtrl:OpenView()
    local info = self:GetFeedbackInfo()
    -- ID为0 就是没有开启
    if info and info.id ~= 0 then
        self.view:Open()
    end
end

function FeedbackCtrl:SendFeedbackInfo()
    self:SendProtocal(53701)
end

function FeedbackCtrl:GetFeedbackInfo()
    return self.data:GetFeedbackInfo()
end

function FeedbackCtrl:OnFeedbackInfo(info)
    self.data:SetFeedbackInfo(info)
end

function FeedbackCtrl:SendFeedbackCommit(star, content)
    if content == "" then
        game.GameMsgCtrl.instance:PushMsg(config.words[3272])
        return
    end
    if self.last_commit_time and self.last_commit_time > self.now_time - 60 then
        game.GameMsgCtrl.instance:PushMsg(config.words[3271])
        return
    end
    local info = self:GetFeedbackInfo()
    self:SendProtocal(53703, {id = info.id, star = star, context = content})
end

function FeedbackCtrl:OnFeedbackCommit(info)
    self.last_commit_time = self.now_time
    self.data:SetFeedbackInfo(info)
    if self.view:IsOpen() then
        self.view:UpdateView()
    end
end

function FeedbackCtrl:TipState()
    local info = self:GetFeedbackInfo()
    if info and info.flag == 1 then
        return true
    else
        return false
    end
end

function FeedbackCtrl:Update(now_time)
    self.now_time = now_time
end

game.FeedbackCtrl = FeedbackCtrl

return FeedbackCtrl