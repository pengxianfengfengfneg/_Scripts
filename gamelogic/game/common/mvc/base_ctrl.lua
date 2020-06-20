
local BaseCtrl = Class(require("game/common/mvc/event_handler"))

local gamenet = game.GameNet

function BaseCtrl:_init()
	self._msg_list = {}
end

function BaseCtrl:_delete()
	for i,v in ipairs(self._msg_list) do
		gamenet:RemoveProtocalCallback(v)
	end
	self._msg_list = nil
end

function BaseCtrl:RegisterProtocalCallback(id, func_name)
	local callback =  function(data_list)
		local oper_func = self[func_name]
		if not oper_func then
			return
		end
		oper_func(self, data_list)
	end

	gamenet:RegisterProtocalCallback(id, callback)

	table.insert(self._msg_list, id)
end

function BaseCtrl:SendProtocal(id, data_list)
	gamenet:SendProtocal(id, data_list)
end

function BaseCtrl:RegisterErrorCodeCallback(error_code, callback_func)
    game.GameMsgCtrl.instance:RegisterErrorCodeCallback(error_code, callback_func)
end

function BaseCtrl:UnRegisterErrorCodeCallback(error_code)
    game.GameMsgCtrl.instance:UnRegisterErrorCodeCallback(error_code)
end

game.BaseCtrl = BaseCtrl

return BaseCtrl
