local SurfaceSuitData = Class(game.BaseData)

local config_surface_suit = config.surface_suit

function SurfaceSuitData:_init()
    self.suit_data = {}
end

function SurfaceSuitData:_delete()

end

function SurfaceSuitData:OnSurfaceInfo(data)
	for _,v in ipairs(data.surfaces) do
		local surface = v.surface
		self.suit_data[surface.id] = surface
	end

	self:FireEvent(game.SurfaceSuitEvent.UpdateSuitInfo)
end

function SurfaceSuitData:OnSurfaceChange(data)
	for _,v in ipairs(data.surfaces) do
		local surface = v.surface
		local info = self.suit_data[surface.id]
		for ck,cv in pairs(info) do
			info[ck] = surface[ck]
		end
	end

	self:FireEvent(game.SurfaceSuitEvent.UpdateSuitInfo)
end

function SurfaceSuitData:GetSuitInfo(id)
	return self.suit_data[id]
end

function SurfaceSuitData:GetSuitActivedNum(id)
	local info = self.suit_data[id]
	if info then
		return info.num
	end
	return 0
end

function SurfaceSuitData:IsMountActived(id)
	local info = self.suit_data[id]
	if info then
		return info.mount>0
	end
	return false
end

function SurfaceSuitData:IsFashionActived(id)
	local info = self.suit_data[id]
	if info then
		return info.fashion>0
	end
	return false
end

function SurfaceSuitData:IsWingActived(id)
	local info = self.suit_data[id]
	if info then
		return info.wing>0
	end
	return false
end

function SurfaceSuitData:IsWeaponActived(id)
	local info = self.suit_data[id]
	if info then
		return info.god>0
	end
	return false
end

function SurfaceSuitData:CalcSuitPower(id)
	local active_num = self:GetSuitActivedNum(id)

	local power = 0
	local suit_cfg = config_surface_suit[id]
	if suit_cfg then
		if active_num >= 2 then
			PrintTable(suit_cfg.attr2)
			power = power + game.Utils.CalculateCombatPower(suit_cfg.attr2)
		end
		
		if active_num >= 3 then
			PrintTable(suit_cfg.attr3)
			power = power + game.Utils.CalculateCombatPower(suit_cfg.attr3)
		end

		if active_num >= 4 then
			power = power + game.Utils.CalculateCombatPower(suit_cfg.attr4)
		end
	end

	return power
end

return SurfaceSuitData
