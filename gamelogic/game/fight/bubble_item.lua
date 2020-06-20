local BubbleItem = Class(game.UITemplate)

function BubbleItem:_init()
	self._package_name = "ui_scene"
    self._com_name = "bubble_item"
end

function BubbleItem:_delete()
	
end

function BubbleItem:Init()
	self._layout_root:SetVisible(false)
	
end

function BubbleItem:Reset()
	
	self._layout_root:SetVisible(false)
end

function BubbleItem:OpenViewCallBack()
	self.txt_content = self._layout_objs["txt_content"]
	
	-- self.hud_item = self._layout_root:AppendToHudComponent()
end

function BubbleItem:_DestroyLayout()
    if self._layout_root then
    	self._layout_root:Dispose()
    	self._layout_root = nil
    end

    if self.hud_item then
    	self.hud_item:Dispose()
    	self.hud_item = nil
    end
end

function BubbleItem:SetParent(parent)
	if self._is_open then
		if self.hud_item then
			parent:AddChild(self.hud_item)
		end
	end
end

function BubbleItem:SetOwner(obj, offset)
	self.hud_item:SetOwner(obj, offset)
end

function BubbleItem:ShowBubble(content)
	self._layout_root:SetVisible(true)

	self.txt_content:SetText(content or "")

	self.hide_bubble_time = global.Time.now_time + 5
end

function BubbleItem:HideBubble()
	self._layout_root:SetVisible(false)
end

function BubbleItem:Update(now_time, elapse_time)
	if self.hide_bubble_time then
		if now_time >= self.hide_bubble_time then
			self:HideBubble()
			self.hide_bubble_time = nil
		end
	end
end

return BubbleItem
