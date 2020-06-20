local OverlordLogItem = Class(game.UITemplate)

function OverlordLogItem:SetRoleInfo(info)
    self.info = info
    self._layout_objs.text:SetText(info.log)
end

function OverlordLogItem:SetGuildInfo(info)
    self.info = info
    self._layout_objs.text:SetText(info.log)
end

function OverlordLogItem:SetBg(val)
    self._layout_objs.bg:SetVisible(val)
end

return OverlordLogItem