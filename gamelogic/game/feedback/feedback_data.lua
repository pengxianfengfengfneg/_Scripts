local FeedbackData = Class(game.BaseData)

function FeedbackData:_init()
end

function FeedbackData:_delete()
end

function FeedbackData:SetFeedbackInfo(info)
    self.feedback_info = info
    self:FireEvent(game.RedPointEvent.UpdateRedPoint, game.OpenFuncId.Feedback, info.flag == 1)
end

function FeedbackData:GetFeedbackInfo()
    return self.feedback_info
end

return FeedbackData
