local TreasureRewardView = Class(game.BaseView)

function TreasureRewardView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "treasure_reward_view"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self:AddPackage("ui_anger_boss")
end

function TreasureRewardView:_delete()

end

function TreasureRewardView:InitConfig()
    self.config = {
        [1] = {
            sprite = "jz03",
            title = config.words[1956],
            content = config.words[1957],
        },
        [2] = {
            sprite = "jz02",
            title = config.words[1958],
            content = config.words[1959],
        },
        [3] = {
            sprite = "jz04",
            title = config.words[5176],
            content = config.words[5177],
        },
    }
end

function TreasureRewardView:OpenViewCallBack(cfg_idx)
    self:InitConfig()
    self:Init(cfg_idx)
    self:PlayTransition("t0", function()
        self:StartCloseCounter()
    end)
end

function TreasureRewardView:CloseViewCallBack()
    self:StopCloseCounter()
    self:StopTransition("t0")
end

function TreasureRewardView:Init(cfg_idx)
    if cfg_idx then
        self:SetItemInfo(self.config[cfg_idx])
    end
end

function TreasureRewardView:SetSprite(name)
    self._layout_objs["img_icon"]:SetSprite("ui_daily_task", name)
end

function TreasureRewardView:SetTitle(title)
    self._layout_objs["txt_title"]:SetText(title)
end

function TreasureRewardView:SetContent(content)
    self._layout_objs["txt_content"]:SetText(content)
end

function TreasureRewardView:SetItemInfo(item_info)
    self:SetSprite(item_info.sprite)
    self:SetTitle(item_info.title)
    self:SetContent(item_info.content)
end

function TreasureRewardView:StartCloseCounter()
    local auto_close = 3
    self:StopCloseCounter()
    self.tw_close = DOTween:Sequence()
    self.tw_close:AppendInterval(auto_close)
    self.tw_close:AppendCallback(function()
        self:Close()
    end)
    self.tw_close:Play()
end

function TreasureRewardView:StopCloseCounter()
    if self.tw_close then
        self.tw_close:Kill(false)
        self.tw_close = nil
    end
end

return TreasureRewardView
