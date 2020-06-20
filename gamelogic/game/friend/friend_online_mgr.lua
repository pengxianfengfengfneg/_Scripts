--关注好友上线提示
local FriendOnlineMgr = Class()

function FriendOnlineMgr:_init()
	self.online_tip_list = {}
end

function FriendOnlineMgr:_delete()
	self:DelTimer()
end

function FriendOnlineMgr:Add(role_id)
	table.insert(self.online_tip_list, role_id)
end

function FriendOnlineMgr:Start()

	if self.timer then
		return
	end

	local elapse_time = 0
	self.timer = global.TimerMgr:CreateTimer(1,
    function()

    	if elapse_time == 0 or (elapse_time%10 == 0) then

    		if next(self.online_tip_list) then
    			local role_id = table.remove(self.online_tip_list, 1)
    			self:ShowTip(role_id)
    		else
    			self:DelTimer()
    		end
    	end

        elapse_time = elapse_time + 1
    end)
end

function FriendOnlineMgr:Stop()

end

function FriendOnlineMgr:DelTimer()
	if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function FriendOnlineMgr:ShowTip(role_id)
	game.FriendCtrl.instance:OpenFriendOnlineTipsView(role_id)
end

return FriendOnlineMgr