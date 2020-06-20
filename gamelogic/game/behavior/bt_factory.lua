bt = {}

require("game/behavior/base/bt_node")
require("game/behavior/base/bt_action")
require("game/behavior/base/bt_composite")
require("game/behavior/base/bt_decorator")
require("game/behavior/base/bt_condition")
require("game/behavior/base/bt_blackboard")

require("game/behavior/custom/bt_move")
require("game/behavior/custom/bt_attack")
require("game/behavior/custom/bt_custom")

require("game/behavior/bt_tree")

local BtFactory = Class()

function BtFactory:_init()if 
	BtFactory.instance ~= nil then
		error("BtFactory Init Twice!")
	end
	BtFactory.instance = self

	self.bt_map = {}
end

function BtFactory:_delete()
	for k,v in pairs(self.bt_map) do
		v:DeleteMe()
	end
	self.bt_map = nil

	BtFactory.instance = nil
end

function BtFactory:Create(name)
	local pool = self.bt_map[name]
	if not pool then
		pool = global.CollectPool.New(function()
			return bt[name].New()
		end,
		function(node)
			node:DeleteMe()
		end,
		function(node)
			node:Reset()
		end)
		self.bt_map[name] = pool
	end

	return self.bt_map[name]:Create()
end

function BtFactory:Free(node)
	return self.bt_map[node._name]:Free(node)
end

game.BtFactory = BtFactory