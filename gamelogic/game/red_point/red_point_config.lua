--[[
	红点配置
	id 			功能id
	event 		事件监听列表，接收到对应事件时，触发红点更新  可忽略
	delta 		红点更新间隔时间，默认0.1秒  填写0即代表下一帧更新 可忽略
]]
local red_point_config = {
    {
        id = game.SysId.Fighting,
        event = {

	    },
	    time = 0,
    },
}

return red_point_config