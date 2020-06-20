local VowSuccessView = Class(game.BaseView)

function VowSuccessView:_init(ctrl)
    self._package_name = "ui_vow"
    self._com_name = "vow_success_view"
    self.ctrl = ctrl
    self.vow_data = self.ctrl:GetData()
end

function VowSuccessView:_delete()
end

function VowSuccessView:OpenViewCallBack()
    self:PlayEffect()
    self:PlayImg()
end

function VowSuccessView:CloseViewCallBack()
    self:DelTimer()
    self.ctrl:OpenView()
end

function VowSuccessView:PlayImg()

    local time = 1
    local index = 1
    local per = 0
    self.timer = global.TimerMgr:CreateTimer(0.1, function()
        

        if time <= 10 then
            index = 1
        elseif time <= 20 then
            index = 2
        elseif time <= 30 then
            index = 3
        elseif time <= 40 then
            index = 4
        elseif time <= 50 then
            index = 5
        elseif time <= 60 then
            index = 6
        end

        per = (time - (index-1)*10)/10

        if index <= 6 then
            self._layout_objs["n"..index]:SetFillAmount(per)
        end

        time = time + 1
        if time >= 70 then
            self:DelTimer()
            self:Close()
        end
    end)
end

function VowSuccessView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function VowSuccessView:PlayEffect()
    local ui_effect = self:CreateUIEffect(self._layout_objs["effect"], "effect/ui/vow_info_show.ab")
    ui_effect:SetLoop(true)
end

return VowSuccessView