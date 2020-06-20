local CarbonFailResultView = Class(game.BaseView)

function CarbonFailResultView:_init(ctrl)
    self._package_name = "ui_carbon"
    self._com_name = "carbon_fail_result_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function CarbonFailResultView:CloseViewCallBack()
    self:StopCountTime()
end

function CarbonFailResultView:OpenViewCallBack(result_info)

    self._layout_objs["btn_leave"]:AddClickCallBack(function()
        self:Close()
        game.FightCtrl.instance:SendReviveReq(3)
    end)

    local dun_lv_cfg = config.dungeon_lv[result_info.dung_id][result_info.level]
    self:StartCountTime(dun_lv_cfg.end_wait_time)

    self._layout_objs.defeate:SetText(string.format(config.words[1437], dun_lv_cfg.chapter_name, dun_lv_cfg.name))

    self._layout_objs.btn_strong:SetTouchDisabled(false)
    self._layout_objs.btn_strong:AddClickCallBack(function()
        game.FightCtrl.instance:SendReviveReq(3)
        self:Close()
        game.StrengthenCtrl.instance:OpenView()
    end)

    self._layout_objs.btn_again:AddClickCallBack(function()
        self.ctrl:DungEnterReq(result_info.dung_id, result_info.level)
        self:Close()
    end)
end

function CarbonFailResultView:StartCountTime(count_time)
    self:StopCountTime()
    self.tween = DOTween.Sequence()
    self.tween:AppendCallback(function()
        if count_time < 0 then
            
            self:DoClose()
        else
            self._layout_objs.text:SetText(string.format(config.words[1424], count_time))
        end
        count_time = count_time - 1
    end)
    self.tween:AppendInterval(1)
    self.tween:SetLoops(-1)
end

function CarbonFailResultView:StopCountTime()
    self._layout_objs.text:SetText("")
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function CarbonFailResultView:DoClose()
    self:Close()
end

return CarbonFailResultView