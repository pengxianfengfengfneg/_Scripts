local BubbleView = Class(game.BaseView)

function BubbleView:_init()
	self._package_name = "ui_scene"
    self._com_name = "bubble_view"
	self._cache_time = 600
	self._swallow_touch = false
	self._ui_order = game.UIZOrder.UIZOrder_Scene

	self._mask_type = game.UIMaskType.None
	self._view_level = game.UIViewLevel.Keep

end

function BubbleView:OpenViewCallBack()
	self.bubble_id = 0
	self.bubble_map = {}
	self.obj_pool = global.CollectPool.New(function()
			local item = require("game/fight/bubble_item").New()
			item:Open()
			item:SetParent(self._layout_root)
			return item
		end, function(item)
			item:DeleteMe()
		end, function(item)
			item:Reset()
		end, 0)
end

function BubbleView:CloseViewCallBack()
	self.bubble_id = 0
	self.bubble_map = {}

	if self.obj_pool then
		self.obj_pool:DeleteMe()
		self.obj_pool = nil
	end
end

function BubbleView:RegisterBubble(obj, offset)
	local item = self.obj_pool:Create()
	item:Init()
	item:SetOwner(obj, offset)
	self.bubble_id = self.bubble_id + 1
	self.bubble_map[self.bubble_id] = item
	return self.bubble_id
end

function BubbleView:UnRegisterBubble(id)
	local item = self.bubble_map[id]
	if item then
		self.obj_pool:Free(item)
		self.bubble_map[id] = nil
	end
end

function BubbleView:ShowBubble(id, content)
	local bubble = self.bubble_map[id]
	if bubble then
		bubble:ShowBubble(content)
	end
end

function BubbleView:Update(now_time, elapse_time)
	for _,v in pairs(self.bubble_map or {}) do
		v:Update(now_time, elapse_time)
	end
end

return BubbleView
