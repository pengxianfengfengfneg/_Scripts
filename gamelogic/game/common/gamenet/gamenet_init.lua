
local GameNet = game.GameNet or Class()

local _net_mgr = N3DClient.NetManager:GetInstance()

function GameNet:RegisterProtocal(protocal)
	_net_mgr:RegisterLuaProtocal(protocal[1], protocal[2])
end

function GameNet:RegisterAllProtocal()
 	for key, value in pairs(proto) do
 		if type(value[1]) == "number" then
 			self:RegisterProtocal(value)
 		end
 	end
end
