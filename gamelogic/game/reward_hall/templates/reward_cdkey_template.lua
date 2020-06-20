local RewardCdkeyTemplate = Class(game.UITemplate)

function RewardCdkeyTemplate:_init()
	self._package_name = "ui_reward_hall"
    self._com_name = "cdkey_template"
end

function RewardCdkeyTemplate:OpenViewCallBack()
    self:Init()
end

function RewardCdkeyTemplate:CloseViewCallBack()
	
end

function RewardCdkeyTemplate:Init()
    self.txt_title = self._layout_objs["txt_title"]
    self.txt_title:SetText(config.words[3016])

    self.txt_cdkey = self._layout_objs["txt_cdkey"]
    self.txt_cdkey.promptText = config.words[3017]

    self.txt_desc = self._layout_objs["txt_desc"]
    self.txt_desc:SetText(config.words[3018])

    self.btn_get = self._layout_objs["btn_get"]
    self.btn_get:SetText(config.words[3015])
    self.btn_get:AddClickCallBack(handler(self, self.OnGetReward))
end

function RewardCdkeyTemplate:OnGetReward()
    local cdkey = self.txt_cdkey:GetText()
    game.ServiceMgr:RequestGetGift(cdkey, function (success, data)
        local json_data = N3DClient.JsonConverter.ParseJsonToLua(data)
        if json_data then
            if json_data.info == 1 then
                game.GameMsgCtrl.instance:PushMsg(config.words[3033])
            else
                local error = config.http_code[json_data.info]
                if error then
                    game.GameMsgCtrl.instance:PushMsg(error.msg)
                else
                    game.GameMsgCtrl.instance:PushMsg(config.words[3034])
                end
            end
        end
    end)
end

return RewardCdkeyTemplate