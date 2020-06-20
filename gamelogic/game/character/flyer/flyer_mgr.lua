local FlyerMgr = Class()

local _effect_mgr = game.EffectMgr
local _fly_item_cls = require("game/character/flyer/flyer")

function FlyerMgr:_init()
	self.item_list = {}
	self.free_id_map = {}
	self.free_id_list = {}
end

function FlyerMgr:_delete()
	for i,v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
end

function FlyerMgr:Create(scene, vo)
	local id
	if #self.free_id_list > 0 then
		id = self.free_id_list[1]
		table.remove(self.free_id_list, 1)
	else
		id = #self.item_list + 1
		local item = _fly_item_cls.New(id)
		table.insert(self.item_list, item)
	end

	local item = self.item_list[id]
	self.free_id_map[id] = false
	item:Init(scene, vo)
	return item
end

function FlyerMgr:Free(id)
	if self.free_id_map[id] then
		return
	end

	local item = self.item_list[id]
	if item then
		item:Reset()
		table.insert(self.free_id_list, id)
		self.free_id_map[id] = true
	end
end

function FlyerMgr:Update(now_time, elapse_time)
	for i,v in ipairs(self.item_list) do
		if not self.free_id_map[i] then
			v:Update(now_time, elapse_time)
		end
	end
end

function FlyerMgr:ClearAll()
	for i,v in ipairs(self.item_list) do
		if not self.free_id_map[i] then
			self:Free(i)
		end
	end
end

function FlyerMgr:Debug()
	local use_num = 0
	for i,v in ipairs(self.item_list) do
		if not self.free_id_map[i] then
			use_num = use_num + 1
		end
	end
	return use_num, #self.item_list
end

return FlyerMgr
