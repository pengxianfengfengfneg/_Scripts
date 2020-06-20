local MsgSysTemplate = Class(game.UITemplate)

local config_msg_notice = config.msg_notice

function MsgSysTemplate:_init()
    
end

function MsgSysTemplate:OpenViewCallBack()
	self.rtx_content = self._layout_objs["rtx_content"]

end

function MsgSysTemplate:CloseViewCallBack()
    
end

function MsgSysTemplate:UpdateData(item)
	local content = item:GetMsgContent()
	self.rtx_content:SetText(content)
end

return MsgSysTemplate
