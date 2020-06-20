local MarryRankItem = Class(game.UITemplate)

function MarryRankItem:_init(parent)
    self.parent = parent
end

function MarryRankItem:OpenViewCallBack()
end

function MarryRankItem:CloseViewCallBack()
    self:DelTimer()
end

function MarryRankItem:RefreshItem(idx)

    self.idx = idx

    local list_data = self.parent:GetListData()
    local item_data = list_data[idx]
    self.hus_id = item_data.husband_id
    self._layout_objs["groom_name"]:SetText(item_data.husband_name)
    self._layout_objs["bride_name"]:SetText(item_data.wife_name)

    local cur_time = global.Time:GetServerTime()
    local limit_time = item_data.end_time - cur_time
    self.timer = global.TimerMgr:CreateTimer(1,
    function()
        limit_time = limit_time - 1
        self._layout_objs["n6"]:SetText(game.Utils.SecToTime2(limit_time))

        if limit_time <= 0 then
            self:DelTimer()
        end
    end)
end

function MarryRankItem:SetSelect(val)
    self._layout_objs["n3"]:SetVisible(val)
end

function MarryRankItem:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function MarryRankItem:DoEnter()
   game.MarryProcessCtrl.instance:CsMarryHallEnter(self.hus_id)
end

return MarryRankItem