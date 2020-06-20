local MonitorItem = Class(game.UITemplate)

function MonitorItem:_init()
end

function MonitorItem:SetRefreshFunc(func)
	self.func = func
	self:Refresh()
end

function MonitorItem:Refresh()
	if self.func then
	    self._layout_objs["txt"]:SetText(self.func())
    end
end

return MonitorItem
