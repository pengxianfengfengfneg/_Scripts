local MsgNoticeItem = Class(game.UITemplate)

local config_msg_notice = config.msg_notice

function MsgNoticeItem:_init()
    
end

function MsgNoticeItem:OpenViewCallBack()
	self.ctrl = game.MsgNoticeCtrl.instance

	self.img_fold = self._layout_objs["img_fold"]
	self.img_open = self._layout_objs["img_open"]

	self.txt_title = self._layout_objs["txt_title"]
	self.txt_time = self._layout_objs["txt_time"]
end

function MsgNoticeItem:CloseViewCallBack()
    
end

function MsgNoticeItem:UpdateData(data)
	self.id = tonumber(data[1])
	self.time_stamp = tonumber(data[2])
	self.read_flag = tonumber(data[3])

	self.msg_cfg = config_msg_notice[self.id]

	self.msg_params = {data[4], data[5], data[6], data[7], data[8], data[9]}
	
	local is_read = (self.read_flag==1)
	self.img_fold:SetVisible(not is_read)
	self.img_open:SetVisible(is_read)

	self.txt_title:SetText(self.msg_cfg.title)
	self.txt_time:SetText(self:GetTimeStr(math.floor(self.time_stamp*0.01)))
end

function MsgNoticeItem:GetId()
	return self.id
end

function MsgNoticeItem:GetType()
	return self.msg_cfg.type
end

function MsgNoticeItem:GetCfg()
	return self.msg_cfg
end

function MsgNoticeItem:GetMsgContent()
	if not self.msg_content then
		local count = 0
	    for word in string.gmatch(self.msg_cfg.desc, "%%s") do
	        count = count + 1
	    end

	    if #self.msg_params >= count then
			self.msg_content = string.format(self.msg_cfg.desc, table.unpack(self.msg_params))
		else
			self.msg_content = self.msg_cfg.desc
		end
	end
	return self.msg_content
end

function MsgNoticeItem:GetTimeStr(time_stamp)
	local date = os.date("*t", time_stamp)

	return string.format("%s-%02d-%02d %02d:%02d:%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
end

function MsgNoticeItem:SetReadFlag()
	if self.read_flag == 1 then
		return
	end

	self.read_flag = 1

	local is_read = (self.read_flag==1)
	self.img_fold:SetVisible(not is_read)
	self.img_open:SetVisible(is_read)

	self.ctrl:SetReadFlag(self.id, self.time_stamp)
end

function MsgNoticeItem:IsRead()
	return (self.read_flag==1)
end

function MsgNoticeItem:GetTimeStamp()
	return self.time_stamp
end

function MsgNoticeItem:GetMsgParams()
	return self.msg_params
end

return MsgNoticeItem
