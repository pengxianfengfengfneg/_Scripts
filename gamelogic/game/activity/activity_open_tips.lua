local ActivityOpenTips = Class(game.BaseView)

function ActivityOpenTips:_init()
	self._package_name = "ui_activity"
    self._com_name = "activity_open_tips"
    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Fouth
end

function ActivityOpenTips:OpenViewCallBack(activity_id)

	self.activity_id = activity_id

	local act_cfg = config.activity[activity_id]
	self._layout_objs["act_name"]:SetText(act_cfg.name)
	self._layout_objs["act_img"]:SetSprite("ui_activity", act_cfg.icon, true)

	self._layout_objs["btn_enter"]:AddClickCallBack(function()
		local link_cfg = game.ActivityLinkFunc[self.activity_id]
		if link_cfg then
			self:Close()
			link_cfg.click_func()
		end
    end)

    self._layout_objs["btn_close"]:AddClickCallBack(function()
		self:Close()
    end)

    self:SetTimer()
end

function ActivityOpenTips:CloseViewCallBack()

	self:DelTimer()
end

local stay_time = 30
function ActivityOpenTips:SetTimer()
	local limit_time = stay_time
	self.timer = global.TimerMgr:CreateTimer(1,
    function()
        limit_time = limit_time - 1
        local str = game.Utils.SecToTime2(limit_time)
        self._layout_objs["close_time"]:SetText(str)

        if limit_time <= 0 then
            self:DelTimer()
            self:Close()
        end
    end)
end

function ActivityOpenTips:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

return ActivityOpenTips