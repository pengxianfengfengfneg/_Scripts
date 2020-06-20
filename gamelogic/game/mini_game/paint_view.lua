local PaintView = Class(game.BaseView)

function PaintView:_init()
    self._package_name = "ui_mini_game"
    self._com_name = "paint_view"

    self._mask_type = game.UIMaskType.FullAlpha
    self._view_level = game.UIViewLevel.Standalone

    self:AddPackage("ui_eraser")
end

function PaintView:OpenViewCallBack(task_id)
    self.task_id = task_id

    self._layout_objs.btn_close:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.n2:SetVisible(true)
    self._layout_objs.n2:SetTouchDisabled(false)
    local radius = 50
    self._layout_objs.n2:SetTouchBeginCallBack(function(x, y)
        x, y = self._layout_objs.n2:ToLocalPos(x, y)
        self.last_x = math.floor(x)
        self.last_y = math.floor(y)
        self._layout_objs.n2:SetPixelAlpha(self.last_x, self.last_y, 0, radius)
    end)
    self._layout_objs.n2:SetTouchMoveCallBack(function(x, y)
        x, y = self._layout_objs.n2:ToLocalPos(x, y)
        self:InterpolatePixel(x, y, radius)
    end)
    self._layout_objs.n2:SetTouchEndCallBack(function()
        local percent = self._layout_objs.n2:CalcEraserPixel(0)
        if percent > 0.5 then
            self:FinishTask()
            self._layout_objs.n2:SetVisible(false)
            self.tween = DOTween.Sequence()
            self.tween:AppendInterval(3)
            self.tween:SetAutoKill(false)
            self.tween:OnComplete(function()
                self:Close()
            end)
        end
    end)
end

function PaintView:CloseViewCallBack()
    self._layout_objs.n2:ResetPixelAlpha()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function PaintView:InterpolatePixel(x, y, radius)
    local dist_x, dist_y = math.abs(x - self.last_x), math.abs(y - self.last_y)
    local cos_val = (x - self.last_x) / math.sqrt(dist_x ^ 2 + dist_y ^ 2)
    local sin_val = (y - self.last_y) / math.sqrt(dist_x ^ 2 + dist_y ^ 2)
    while dist_x ^ 2 + dist_y ^ 2 > radius ^ 2 do
        self.last_x = self.last_x + radius * cos_val
        self.last_y = self.last_y + radius * sin_val
        self._layout_objs.n2:SetPixelAlpha(math.floor(self.last_x), math.floor(self.last_y), 0, radius)
        dist_x, dist_y = math.abs(x - self.last_x), math.abs(y - self.last_y)
    end
    self.last_x = x
    self.last_y = y
    self._layout_objs.n2:SetPixelAlpha(math.floor(self.last_x), math.floor(self.last_y), 0, radius)
end

function PaintView:FinishTask()
    game.TaskCtrl.instance:SendTaskGetReward(self.task_id)
end

return PaintView

