local ScoreLogView = Class(game.BaseView)

function ScoreLogView:_init(ctrl)
    self._package_name = "ui_overlord"
    self._com_name = "score_log_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function ScoreLogView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4608])

    self:BindEvent(game.OverlordEvent.Log, function(data)
        self:UpdateLog(data)
    end)

    self:InitTemplate()

    self.ctrl:SendOverlordLog()
end

function ScoreLogView:OnEmptyClick()
    self:Close()
end

function ScoreLogView:InitTemplate()
    self.log_lists = {}
    for i = 0, 1 do
        local template = self:GetTemplateByObj("game/overlord/score_log_template", self._layout_objs.list_page:GetChildAt(i))
        table.insert(self.log_lists, template)
    end

    self._layout_objs.list_page:SetHorizontalBarTop(true)
end

function ScoreLogView:UpdateLog(data)

    self.log_lists[1]:SetLogList(data.role)
    self.log_lists[2]:SetLogList(data.guild)
end

return ScoreLogView
