local BossInfoView = Class(game.BaseView)

function BossInfoView:_init(ctrl)
    self._package_name = "ui_overlord"
    self._com_name = "boss_info_view"
    self._view_level = game.UIViewLevel.Standalone
    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Main_UI+1

    self.ctrl = ctrl
end

function BossInfoView:OpenViewCallBack()

    self:BindEvent(game.OverlordEvent.BossHP, function(data)
        self:UpdateBlood(data)
    end)

    self._layout_objs["bar/bar"]:SetSprite("ui_common", "jyt_04")

    self._layout_objs.btn_exit:AddClickCallBack(function()
        self.ctrl:SendLeaveOverlord()
    end)

    local hp = self.ctrl:GetBossHp()
    if hp then
        self:UpdateBlood(hp)
    end

    self:StartCountTime(config.sys_config.master_chap_time.value)
    self.ctrl:SendRegister(1)
end

function BossInfoView:CloseViewCallBack()
    self.ctrl:SendRegister(0)
    self:StopCountTime()
end

function BossInfoView:UpdateBlood(hp)
    self._layout_objs.bar:SetProgressValue(hp)
end


function BossInfoView:StartCountTime(count_time)
    self:StopCountTime()
    self.tween = DOTween.Sequence()
    self.tween:AppendCallback(function()
        count_time = count_time - 1
        if count_time < 0 then
            self:StopCountTime()
        else
            local str = string.format(config.words[2115], count_time // 60, count_time % 60)
            game.MainUICtrl.instance:SetActTime(str)
        end
    end)
    self.tween:AppendInterval(1)
    self.tween:SetLoops(-1)
end

function BossInfoView:StopCountTime()
    game.MainUICtrl.instance:SetActTime()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

return BossInfoView
