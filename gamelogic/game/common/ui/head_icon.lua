local HeadIcon = Class(game.UITemplate)

local config_role_icon = config.role_icon
local config_icon_frame = config.icon_frame

function HeadIcon:_init(view)
    self.parent_view = view
end

function HeadIcon:OpenViewCallBack()
	self:Init()
end

function HeadIcon:CloseViewCallBack()
    
end

function HeadIcon:Init()
	self.img_icon = self._layout_objs["img_icon"]	
	self.img_frame = self._layout_objs["img_frame"]
	self.img_lock = self._layout_objs["img_lock"]

	self.img_flower_1 = self._layout_objs["img_flower_1"]
	self.img_flower_2 = self._layout_objs["img_flower_2"]

	self:GetRoot():AddClickCallBack(function(x,y)
		if self.click_callback then
			self.click_callback(x,y)
		end
	end)
end

function HeadIcon:UpdateData(data)
	self:UpdateIcon(data.icon or 1)
	self:UpdateFrame(data.frame or 0)

	self:UpdateLock(data.lock==true)
end

function HeadIcon:UpdateIcon(icon_id)
	if self.icon_id == icon_id then
		return
	end

	self.icon_id = icon_id
	local cfg = config_role_icon[icon_id]
	if cfg then
		self.icon_res = cfg.icon
		self.img_icon:SetSprite("ui_headicon", cfg.icon)
	end
end

function HeadIcon:UpdateFrame(frame_id)
	if self.frame_id == frame_id then
		return
	end

	self.frame_id = frame_id
	local cfg = config_icon_frame[frame_id]
	if cfg then
		self.img_frame:SetSprite("ui_main", cfg.res)

		local is_flower_1 = (cfg.flower_1~="")
		local is_flower_2 = (cfg.flower_2~="")
		self.img_flower_1:SetVisible(is_flower_1)
		self.img_flower_2:SetVisible(is_flower_2)

		if is_flower_1 then
			self.img_flower_1:SetSprite("ui_main", cfg.flower_1)
			self.img_flower_1:SetPosition(cfg.offset_1[1] or 0, cfg.offset_1[2] or 0)
		end

		if is_flower_2 then
			self.img_flower_2:SetSprite("ui_main", cfg.flower_2)
			self.img_flower_2:SetPosition(cfg.offset_2[1] or 0,cfg.offset_2[2] or 0)
		end
	end
end

function HeadIcon:UpdateLock(is_lock)
	self.img_icon:SetVisible(not is_lock)
	self.img_lock:SetVisible(is_lock)
end

function HeadIcon:SetClickCallback(callback)
	self.click_callback = callback
end

function HeadIcon:SetGray(val)
	if self.is_gray == val then
		return
	end

	self.is_gray = val
	self.img_icon:SetGray(val)
end

function HeadIcon:SetFlip(val)
	if self.is_flip == val then
		return
	end

	self.is_flip = val
	self.img_icon:SetFlipX(val)
end

function HeadIcon:SetVisible(val)
	if self.is_visible == val then
		return
	end

	self.is_visible = val
	self:GetRoot():SetVisible(val)
end

function HeadIcon:SetIconVisible(val)
	if self.is_icon_visible == val then
		return
	end

	self.is_icon_visible = val
	self.img_icon:SetVisible(val)
end

function HeadIcon:SetFrameVisible(val)
	if self.is_frame_visible == val then
		return
	end

	self.is_frame_visible = val
	self.img_flower_1:SetVisible(val)
	self.img_flower_2:SetVisible(val)
end

function HeadIcon:GetIconRes()
	return self.icon_res or ""
end

return HeadIcon
