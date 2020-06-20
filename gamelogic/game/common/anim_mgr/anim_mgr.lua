
local AnimMgr = Class()

local _cfg_path_map = {
	[game.BodyType.Role] = "anim/role/%d",
	[game.BodyType.Monster] = "anim/monster/%d",
	[game.BodyType.RoleCreate] = "anim/role_create/%d",
	[game.BodyType.Camera] = "anim/camera/%d",
}

local default_cfg = {__index = function(t, k)
	return 1.0
end}

function AnimMgr:_init()
	self.cfg_map = {}
	for k,v in pairs(_cfg_path_map) do
		self.cfg_map[k] = {}
	end
end

function AnimMgr:_delete()
	self:Clear()
end

function AnimMgr:GetAnimConfig(body_type, id)
	local cfg = self.cfg_map[body_type][id]
	if not cfg then
		cfg = require(string.format(_cfg_path_map[body_type], id)) or default_cfg
		self.cfg_map[body_type][id] = cfg
	end
	return cfg
end

game.AnimMgr = AnimMgr.New()
