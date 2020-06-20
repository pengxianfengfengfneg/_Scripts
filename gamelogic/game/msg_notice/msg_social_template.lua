local MsgSocialTemplate = Class(game.UITemplate)

local config_msg_notice = config.msg_notice

function MsgSocialTemplate:_init()
    
end

function MsgSocialTemplate:OpenViewCallBack()
	self.img_fold = self._layout_objs["img_fold"]
	self.img_open = self._layout_objs["img_open"]

end

function MsgSocialTemplate:CloseViewCallBack()
    
end

function MsgSocialTemplate:UpdateData(item)
	
end

return MsgSocialTemplate
