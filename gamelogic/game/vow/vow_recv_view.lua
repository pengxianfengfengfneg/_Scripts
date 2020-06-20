local VowRecvView = Class(game.BaseView)

function VowRecvView:_init(ctrl)
    self._package_name = "ui_vow"
    self._com_name = "ui_vow_recv"
    self._view_level = game.UIViewLevel.Second 
    self._mask_type = game.UIMaskType.Full1
    self.ctrl = ctrl
end

function VowRecvView:_delete()
end

function VowRecvView:OpenViewCallBack(other_vow_data)
	self.ctrl:CsVowOtherVow(other_vow_data.role_id)

	self.other_vow_data = other_vow_data
	self:BindEvent(game.VowEvent.UpdateOtherAgree, function(data)
		if self.role_data.is_like == 1 then
			self.role_data.is_like = 2
		elseif self.role_data.is_like == 2 then
			self.role_data.is_like = 1
		end
        self:InitView(self.role_data)
    end)

	self:BindEvent(game.VowEvent.GetOtherVow, function(data)
		self.role_data = data
        self:InitView(data)
    end)

    self._layout_objs["recv_btn"]:AddClickCallBack(function()
    	self.ctrl:CsVowGet(self.other_vow_data.role_id)
    end)

    self._layout_objs["n72"]:AddClickCallBack(function()
    	self:Close()
    end)

    self._layout_objs["heart_recv"]:SetTouchDisabled(false)
    self._layout_objs["heart_recv"]:AddClickCallBack(function()
    	if self.role_data.is_like==1 then
    		self.ctrl:CsVowCancelLike(self.role_data.role_id)
    	else
        	self.ctrl:CsVowAgree(self.role_data.role_id)
        end
    end)
end

function VowRecvView:CloseViewCallBack()
    self:FireEvent(game.VowEvent.UpdatgeVowInfo)
end

function VowRecvView:InitView(data)
	if data.is_like==1 then
		self._layout_objs["heart_recv"]:SetSprite("ui_vow", "03")
	else
		self._layout_objs["heart_recv"]:SetSprite("ui_vow", "07")
	end

	self._layout_objs["role2"]:SetText(tostring(data.level).."."..data.name)

	self._layout_objs["input_txt2"]:SetText(data.context)

	self._layout_objs["career_img2"]:SetSprite("ui_common", "career" .. data.career)
end

return VowRecvView