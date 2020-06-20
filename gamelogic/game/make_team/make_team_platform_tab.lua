local MakeTeamPlatformTab = Class(game.UITemplate)

function MakeTeamPlatformTab:_init(ctrl)
    self.ctrl = ctrl
    
end

function MakeTeamPlatformTab:OpenViewCallBack()
	self:Init()
end

function MakeTeamPlatformTab:CloseViewCallBack()
    
end

function MakeTeamPlatformTab:Init()
	self.img_career = self._layout_objs["img_career"]

	self:GetRoot():AddClickCallBack(function()
		if self.is_selected then
			return
		end

		if self.click_callback then
			self.click_callback(self)
		end
	end)
end

function MakeTeamPlatformTab:UpdateData(data)
	self.data = data
	
	self:GetRoot():SetText(data.name)
end

function MakeTeamPlatformTab:IsMain()
	return self.data.cate==nil
end

function MakeTeamPlatformTab:GetCate()
	return (self.data.cate or self.data.id)
end

function MakeTeamPlatformTab:GetTarget()
	return self.data.target or self.data.id
end

function MakeTeamPlatformTab:SetClickCallback(callback)
	self.click_callback = callback
end

function MakeTeamPlatformTab:SetSelected(val)
	self.is_selected = val
	self:GetRoot():SetSelected(val)
end

function MakeTeamPlatformTab:GetSeq()
	return self.data.seq or 0
end

function MakeTeamPlatformTab:IsSelected()
	return self.is_selected
end

function MakeTeamPlatformTab:GetTargetNum()
	return self.data.target_num or 0
end

return MakeTeamPlatformTab
