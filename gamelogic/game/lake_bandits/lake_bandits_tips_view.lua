local LakeBanditsTipsView = Class(game.BaseView)

function LakeBanditsTipsView:_init(ctrl)
    self._package_name = "ui_lake_bandits"
    self._com_name = "tips_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
end

function LakeBanditsTipsView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function LakeBanditsTipsView:CloseViewCallBack()
   self:StopTimeCounter()
end

function LakeBanditsTipsView:Init()
    self._layout_objs["txt_content"]:SetText(string.format(config.words[2412], config.words[4907]))

    self._layout_objs["btn_ok"]:AddClickCallBack(function()
        self.ctrl:SendLakeBanditsEnter()
        self:Close()
    end)
    self._layout_objs["btn_cancel"]:AddClickCallBack(function()
        self:Close()
    end)

    self:StartTimeCounter()
end

function LakeBanditsTipsView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1660])
end

function LakeBanditsTipsView:StartTimeCounter()
    self:StopTimeCounter()
    local time = 10
    self.seq = DOTween:Sequence()
    self.seq:AppendCallback(function()
        self._layout_objs["txt_time"]:SetText(string.format(config.words[4906], time))
        time = time - 1
        if time <= 0 then
            self:StopTimeCounter()
            self:Close()
        end
    end)
    self.seq:AppendInterval(1)
    self.seq:SetLoops(-1)
    self.seq:Play()
end

function LakeBanditsTipsView:StopTimeCounter()
    if self.seq then
        self.seq:Kill(false)
        self.seq = nil
    end
end

return LakeBanditsTipsView
