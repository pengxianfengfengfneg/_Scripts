local MakeTeamTargetItem = Class(game.UITemplate)

function MakeTeamTargetItem:_init(ctrl)
    self.ctrl = ctrl
    
end

function MakeTeamTargetItem:OpenViewCallBack()
	self:Init()
end

function MakeTeamTargetItem:CloseViewCallBack()
    
end

function MakeTeamTargetItem:Init()
	self.img_fold_on = self._layout_objs["img_fold_on"]
	self.img_fold_off = self._layout_objs["img_fold_off"]

	self:GetRoot():AddClickCallBack(function()
		if self.is_selected then
			return
		end

		if self.click_callback then
			self.click_callback(self)
		end
	end)
end

function MakeTeamTargetItem:UpdateData(data)
	self.data = data
	
	self:GetRoot():SetText(data.name)

	if self.img_fold_off then
		self.img_fold_off:SetVisible(data.target_num>1)
	end

	self.min_lv,self.max_lv,self.recommend_min_lv,self.recommend_max_lv = self:CalcLevel()
end

function MakeTeamTargetItem:IsMain()
	return self.data.cate==nil
end

function MakeTeamTargetItem:GetCate()
	return (self.data.cate or self.data.id)
end

function MakeTeamTargetItem:GetTarget()
	return self.data.target or self.data.id
end

function MakeTeamTargetItem:SetClickCallback(callback)
	self.click_callback = callback
end

function MakeTeamTargetItem:SetSelected(val)
	self.is_selected = val
	self:GetRoot():SetSelected(val)

	if self.img_fold_off then
		if self.data.target_num>1 then
			self.img_fold_off:SetVisible(not val)
			self.img_fold_on:SetVisible(val)
		else
			self.img_fold_off:SetVisible(false)
			self.img_fold_on:SetVisible(false)
		end
	end
end

function MakeTeamTargetItem:GetSeq()
	return self.data.seq or 0
end

function MakeTeamTargetItem:IsSelected()
	return self.is_selected
end

function MakeTeamTargetItem:GetRecommendMinMaxLv()
	return self.recommend_min_lv,self.recommend_max_lv
end

function MakeTeamTargetItem:GetMinMaxLv()
	return self.min_lv,self.max_lv
end

function MakeTeamTargetItem:CalcLevel()
	local min_lv = 1000
	local max_lv = 0
	local role_lv = game.Scene.instance:GetMainRoleLevel()
	local recommend_min_lv = role_lv
	local recommend_max_lv = role_lv
	for _,v in ipairs(self.data.apply_lv or {}) do
		min_lv = math.min(min_lv, v[1])
		min_lv = math.min(min_lv, v[2])

		max_lv = math.max(max_lv, v[1])
		max_lv = math.max(max_lv, v[2])

		if role_lv>=v[1] and role_lv<=v[2] then
			recommend_min_lv = math.min(v[1], v[2])
			recommend_max_lv = math.max(v[1], v[2])
		end
	end

	return min_lv,max_lv,recommend_min_lv,recommend_max_lv
end

return MakeTeamTargetItem
