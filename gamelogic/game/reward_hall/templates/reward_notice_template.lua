local RewardNoticeTemplate = Class(game.UITemplate)

function RewardNoticeTemplate:_init()
	self._package_name = "ui_reward_hall"
    self._com_name = "notice_template"
end

function RewardNoticeTemplate:OpenViewCallBack()
    self:Init()
    game.ServiceMgr:RequestServerNotice(function(json_data)
        self:SetTitleText(json_data.data.title)
        self:SetContentText(json_data.data.content)
    end)
end

function RewardNoticeTemplate:CloseViewCallBack()
	
end

function RewardNoticeTemplate:Init()
    self.list_content = self._layout_objs["list_content"]
    self.list_content:SetItemNum(1)

    local notice = self.list_content:GetChildAt(0)
    self.txt_title = notice:GetChild("txt_title")
    self.txt_content = notice:GetChild("txt_content")
end

function RewardNoticeTemplate:SetContentText(content)
    self.txt_content:SetText(content)
end

function RewardNoticeTemplate:SetTitleText(title)
    self.txt_title:SetText(title)
end

return RewardNoticeTemplate