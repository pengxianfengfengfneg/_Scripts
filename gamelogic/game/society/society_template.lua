local SocietyTemplate = Class(game.UITemplate)

function SocietyTemplate:_init(tag_index)
    self.tag_index = tag_index
end

function SocietyTemplate:OpenViewCallBack()

    self:InitList()

    self:UpdateList()

    self:SetActivityTimer()

    self:BindEvent(game.SocietyEvent.RefreshTaskState, function()
        self:UpdateList()
    end)
end

function SocietyTemplate:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
    self:DelTimer()
end

function SocietyTemplate:InitList()

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/society/society_item").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddClickItemCallback(function(item)
    end)

    self.ui_list:SetItemNum(0)
end

function SocietyTemplate:UpdateList()

    local data_list = game.SocietyCtrl.instance:GetTasksByTag(self.tag_index)
    self.data_list = data_list

    self.ui_list:SetItemNum(#data_list)
end

function SocietyTemplate:GetDataList()
    return self.data_list
end

function SocietyTemplate:SetActivityTimer()

    local society_data = game.SocietyCtrl.instance:GetData()
    local open_time = society_data:GetOpenTime()
    local open_start_time = game.Utils.NowDaytimeStart(open_time)
    local end_time = open_start_time + (7)*86400
    local cur_time = global.Time:GetServerTime()
    local off_time = end_time - cur_time

    self.timer_id = global.TimerMgr:CreateTimer(1,
        function()

            off_time = off_time - 1
            local str = game.Utils.SecToTimeCn(off_time, game.TimeFormatCn.DayHourMinSec)
            self._layout_objs["over_time"]:SetText(str)

            if off_time <= 0 then
                self:DelTimer()
                self._layout_objs["over_time"]:SetText(config.words[4025])
                self:FireEvent(game.SocietyEvent.RefreshMainUI)
            end
        end)

end

function SocietyTemplate:DelTimer()
    if self.timer_id then
        global.TimerMgr:DelTimer(self.timer_id)
        self.timer_id = nil
    end
end

return SocietyTemplate