local ZoneTemplate = Class(game.UITemplate)

function ZoneTemplate:_init()

end

function ZoneTemplate:Refresh(idx, data)
	self.zone_idx = idx
    self._layout_objs["title"]:SetText(data.name)
end

function ZoneTemplate:GetZoneIdx()
	return self.zone_idx
end

return ZoneTemplate
