local FashionData = Class(game.BaseData)

local event_mgr = global.EventMgr
local config_fashion = config.fashion
local config_fashion_color = config.fashion_color

function FashionData:_init()
    
	self.fashion_list = {}
	self.new_action_fashion = {}
end

function FashionData:_delete()
	self.new_action_fashion = nil
end

function FashionData:OnFashionGetInfo(data)
	--[[
        "current__I",
        "fashions__T__id@H##colors@H##time@I",
    ]]

    self.cur_fashion_id = data.current
    for _,v in ipairs(data.fashions) do
    	self.fashion_list[v.id] = v
    end

    if #data.fashions <= 0 then
    	self.cur_fashion_id = 0
    end
end

function FashionData:GetFashionInfo(id)
	return self.fashion_list[id]
end

function FashionData:GetFashionColors(id)
	return (self.fashion_list[id] or {}).colors
end

function FashionData:OnFashionActivate(data)
	--self.cur_fashion_id = data.id
	data.time = data.exp_time
	self.fashion_list[data.id] = data

	if self.new_action_fashion[data.id] == nil then
		self.new_action_fashion[data.id] = true
	end
	self:FireEvent(game.RedPointEvent.UpdateRedPoint, game.OpenFuncId.Exterior, game.ExteriorCtrl.instance:GetTipState())
end

function FashionData:RemoveNewActionFashionState(id)
	if self.new_action_fashion[id] then
		self.new_action_fashion[id] = nil
		self:FireEvent(game.RedPointEvent.UpdateRedPoint, game.OpenFuncId.Exterior, game.ExteriorCtrl.instance:GetTipState())
		game.ExteriorCtrl.instance:RefreshViewTips()
	end
end

function FashionData:GetAllFashionNewActionState()
	for _, v in pairs(self.new_action_fashion) do
		if v then
			return true
		end
	end
end

function FashionData:GetFashionNewActionState(id)
	return self.new_action_fashion[id] == true
end

function FashionData:OnFashionWear(data)
	self.cur_fashion_id = data.id

end

function FashionData:OnFashionDyeing(data)
	local info = self.fashion_list[data.id] or {}
	info.colors = data.dyeing
end

function FashionData:OnFashionExpire(data)
	local info = self.fashion_list[data.expires__id]
	if info == nil then
		return
	end
	self.cur_fashion_id = data.current

	info.time = -1
end

function FashionData:OnHairSwitch(data)
	self.cur_hair_id = data.id
end

function FashionData:OnHairChange(data)
	
end

function FashionData:IsFashionActived(id)
	local info = self.fashion_list[id]
	if not info then
		return false
	end
	return (info.time>=0)
end

function FashionData:IsFashionWeared(id)
	if not self.cur_fashion_id or self.cur_fashion_id<=0 then 
		return false 
	end

	local cur_id = self.cur_fashion_id>>16
	return (cur_id == id)
end

local color_mask = 0xffff
function FashionData:IsColorActived(id, color)
	local info = self.fashion_list[id]
	if not info then return false end

	local hex_color = 1<<(color-1)

	return (info.colors & hex_color)>0
end

function FashionData:IsAllColorActived(id)
	local cfg = config_fashion[id] or {}
	for _,v in ipairs(cfg.unlock or {}) do
		if not self:IsColorActived(id, v) then
			return false
		end
	end
	return true
end

function FashionData:IsColorUsed(id, color)
	if not self.cur_fashion_id or self.cur_fashion_id<=0 then 
		return false 
	end

	local cur_id = self.cur_fashion_id>>16
	if cur_id ~= id then
		return false
	end

	local hex_color = 1<<(color-1)
	local cur_colors = (self.cur_fashion_id & color_mask)

	return (cur_colors & hex_color)>0
end

function FashionData:IsHairUsed(id)
	return self.cur_hair_id==id
end

function FashionData:GetFashionColorConfig(fashion_id)
	if not self._career then
		self._career = game.RoleCtrl.instance:GetCareer()
	end

	return config_fashion_color[fashion_id][self._career]
end

function FashionData:GetFashionColorActivedNum(id)
	local fashion_cfg = config_fashion[id]
	local item_num = #fashion_cfg.colors

	local colors = self:GetFashionColors(id)
	local count = 0
	for i=0,item_num-1 do
		if (colors&(1<<i)) > 0 then
			count = count + 1
		end
	end
	return count,item_num
end

function FashionData:CheckRedPoint()
	for _,v in pairs(config_fashion) do
		if self:CanActived(v.id) then
			return true
		end

		if self:CanColored(v.id) then
			return true
		end
	end

	return false
end

function FashionData:CanActived(fashion_id)
	if self.fashion_list[fashion_id] then
		return false
	end

	local cfg = config_fashion[fashion_id]
	if cfg then
		local item_id = cfg.item_id
		local item_num = game.BagCtrl.instance:GetNumById(item_id)
		return (item_num>=1)
	end
	return false
end

function FashionData:CanColored(fashion_id)
	if not self:IsFashionActived(fashion_id) then
		return false
	end

	if self:IsAllColorActived(fashion_id) then
		return false
	end

	local fashion_cfg = config_fashion[fashion_id]
	if #fashion_cfg.colors <= 1 then
		return false
	end

	local color_cost = fashion_cfg.cost
	local bag_ctrl = game.BagCtrl.instance
	for _,v in ipairs(color_cost) do
		local num = bag_ctrl:GetNumById(v[1])
		if num < v[2] then
			return false
		end
	end

	return true
end

return FashionData
