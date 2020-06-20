local MiniRotatyView = Class(game.BaseView)

function MiniRotatyView:_init(ctrl)
    self._package_name = "ui_mini_game"
    self._com_name = "rotaty_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self:AddPackage("ui_arena")

    self.ctrl = ctrl
end

function MiniRotatyView:OpenViewCallBack(task_id)
    self.task_id = task_id

    self.img_bg1 = self._layout_objs.img_bg1
    self.img_bg2 = self._layout_objs.img_bg2

    self.outer_ring = self._layout_objs.outer_ring
    self.outer_touch_com = self._layout_objs.outer_touch_com

    self.inner_ring = self._layout_objs.inner_ring
    self.inner_touch_com = self._layout_objs.inner_touch_com

    self.btn_close = self._layout_objs.btn_close
    self.btn_close:AddClickCallBack(function()
        self:Close()
    end)

    self:Init()
end

function MiniRotatyView:CloseViewCallBack()
    self:StopCloseCounter()
end

function MiniRotatyView:Init()
    self.play_end = false

    self.outer_angle = self:ConvertImageAngle(math.random(0, 360))
    self.inner_angle = self:ConvertImageAngle(self:ClampAngle(self.outer_angle + math.random(100,160)))

    self.img_bg1:SetRotation(self.outer_angle)
    self.img_bg2:SetRotation(self.outer_angle)
    self.outer_ring:SetRotation(self.outer_angle)

    self.inner_ring:SetRotation(self.inner_angle)

    self.outer_touch_com:SetTouchEnable(true)
    self.outer_touch_com:SetTouchBeginCallBack(function(x, y)
        x, y = self.outer_touch_com:ToLocalPos(x, y)
        self.angle = self:ConvertImageRotation(x, y)
    end)

    self.outer_touch_com:SetTouchMoveCallBack(function(x, y)
        local x, y = self.outer_touch_com:ToLocalPos(x, y)
        local angle = self:ConvertImageRotation(x, y)

        local rotation = self.outer_ring.rotation + angle - self.angle
        self.outer_ring:SetRotation(rotation)
        self.img_bg1:SetRotation(rotation)
        self.img_bg2:SetRotation(rotation)  

        self.angle = angle
    end)

    self.outer_touch_com:SetTouchEndCallBack(function(x, y)
        if self:CheckGameOver() then
            self:GameOver()
        end
    end)

    self.inner_touch_com:SetTouchEnable(true)
    self.inner_touch_com:SetTouchBeginCallBack(function(x, y)
        local x, y = self.inner_touch_com:ToLocalPos(x, y)
        self.angle = self:ConvertImageRotation(x, y)
    end)

    self.inner_touch_com:SetTouchMoveCallBack(function(x, y)
        local x, y = self.inner_touch_com:ToLocalPos(x, y)
        local angle = self:ConvertImageRotation(x, y)

        local rotation = self.inner_ring.rotation + angle - self.angle

        self.inner_ring:SetRotation(rotation)
        self.angle = angle
    end)

    self.inner_touch_com:SetTouchEndCallBack(function(x, y)
        if self:CheckGameOver() then
            self:GameOver()
        end
    end)
end

function MiniRotatyView:CheckGameOver()
    local outer_angle = self:ClampAngle(self.outer_ring.rotation)
    local inner_angle = self:ClampAngle(self.inner_ring.rotation)

    local targte_angle = 0
    local delta = 8

    local outer_angle_delta = math.abs(outer_angle-targte_angle)
    local inner_angle_delta = math.abs(inner_angle-targte_angle)

    if outer_angle_delta > 180 then
        outer_angle_delta = 360 - outer_angle
    end
    if inner_angle_delta > 180 then
        inner_angle_delta = 360 - inner_angle_delta
    end

    if outer_angle_delta <= delta and inner_angle_delta <= delta then
        return true
    end
    return false
end

function MiniRotatyView:FinishTask()
    game.TaskCtrl.instance:SendTaskGetReward(self.task_id)
end

function MiniRotatyView:GameOver()
    if self.play_end then
        return
    end

    self:FinishTask()

    local angle = 0
    self.img_bg1:SetRotation(angle)
    self.img_bg2:SetRotation(angle)
    self.outer_ring:SetRotation(angle)
    self.inner_ring:SetRotation(angle)

    self.outer_ring:SetTouchEnable(false)
    self.inner_ring:SetTouchEnable(false)

    self:StartCloseCounter()

    self.play_end = true
end

function MiniRotatyView:ClampAngle(angle)
    while angle > 360 do
        angle = angle - 360
    end
    while angle < 0 do
        angle = angle + 360
    end
    return angle
end

function MiniRotatyView:StartCloseCounter()
    self:StopCloseCounter()
    self.tween_close = DOTween:Sequence()
    self.tween_close:AppendInterval(2)
    self.tween_close:AppendCallback(function()
        self:Close()
    end)
    self.tween_close:Play()
end

function MiniRotatyView:StopCloseCounter()
    if self.tween_close then
        self.tween_close:Kill(false)
        self.tween_close = nil
    end
end

function MiniRotatyView:ConvertImageRotation(x, y)
    return self:ConvertImageAngle(math.radian2angle(math.atan(-y, x)))
end

function MiniRotatyView:ConvertImageAngle(angle)
    return 270 - angle
end

return MiniRotatyView

