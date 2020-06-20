local BtnFunc = Class(game.UITemplate)

function BtnFunc:_init()
    
end

function BtnFunc:OpenViewCallBack()
	self:Init()
	
end

function BtnFunc:CloseViewCallBack()
    
end

function BtnFunc:Init()
	self.is_visible = true

	self.title = self._layout_objs["title"]	
	self.img_red = self._layout_objs["img_red"]
	self.show_text = self._layout_objs["func_txt"]
	self.effect = self._layout_objs["effect"]
	
	--self:SetRedPoint(false)
	
	self.root_obj = self:GetRoot()
	self.root_obj:AddClickCallBack(function()
		if self.func_data.click_func then
			self.func_data.click_func()
		end
		self:ClearOpenEffect()
	end)
end

function BtnFunc:UpdateData(data)
	self.func_data = data

	if not data then
		return
	end

	self.root_obj:SetIcon("ui_main", data.icon, true)

	self:UnRegisterRedPoint()
	self:RegisterRedPoint(self.root_obj, data.id, function(is_red)
		self:SetRedPoint(is_red)
	end)

	--self:CheckRedPoint()

	self:SetBtnText()

	if game.OpenFuncCtrl.instance:IsFuncPlayEffect(data.id) then
		self:ShowOpenEffect()
	else
		self:ClearOpenEffect()
	end
end

function BtnFunc:SetVisible(val)
	if self.is_visible == val then
		return
	end
	self.is_visible = val
	self:GetRoot():SetVisible(val)
end

function BtnFunc:CheckRedPoint()
	if not self.func_data then return end

	local is_red = self.func_data.check_red_func()
	self:SetRedPoint(is_red)
end

function BtnFunc:SetRedPoint(is_red)
	if self.is_red == is_red then
		return
	end

	self.is_red = is_red
	self.img_red:SetVisible(is_red or false)

	if self.red_point_callback then
		self.red_point_callback(self)
	end
end

function BtnFunc:SetRedPointCallback(callback)
	self.red_point_callback = callback
end

function BtnFunc:GetFuncId()
	if self.func_data then
		return self.func_data.id
	end
	return -1
end

function BtnFunc:IsRedPoint()
	return self.is_red
end

function BtnFunc:SetPageNum(page_num)
	self.page_num = page_num
end

function BtnFunc:GetPageNum()
	return self.page_num
end

function BtnFunc:SetBtnText()

	if not self.func_data then return end

	if self.func_data.check_show_text then
		local str = self.func_data.check_show_text()
		self.show_text:SetVisible(true)
		self.show_text:SetText(str)
	end
end

function BtnFunc:ShowOpenEffect()
	if not self.func_data then
		return
	end
	local end_time = game.OpenFuncCtrl.instance:GetFuncEffectEndTime(self.func_data.id)
	if end_time and end_time >= 0 then
		if not self.ui_effect then
			self.ui_effect = self:CreateUIEffect(self.effect,  "effect/ui/hd_tishi.ab")
		end
		if end_time == 0 then
			self.ui_effect:SetLoop(true)
		elseif end_time > 0 then
			local life_time = end_time - global.Time.now_time
			self.ui_effect:SetLifeTime(life_time)
			self.ui_effect:SetLoop(false)
		end
	else
		self:ClearOpenEffect()
	end
end

function BtnFunc:ClearOpenEffect()
	self.ui_effect = nil
	self:StopUIEffect(self.effect)
	if self.func_data then
		game.OpenFuncCtrl.instance:ResetFuncEffect(self.func_data.id)
	end
end

return BtnFunc
