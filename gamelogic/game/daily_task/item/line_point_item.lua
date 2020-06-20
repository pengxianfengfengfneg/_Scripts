local LinePointItem = Class(game.UITemplate)

local PointIndex = {
    Common = 0,
    Highlight = 1,
}

function LinePointItem:_init(data, idx)
    self._package_name = "ui_daily_task"
    self._com_name = "line_point_item"
    self.pos = cc.vec2(data[1], data[2])
    self.index = idx
end

function LinePointItem:OpenViewCallBack()
    self:InitInfos()
    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event()
        end
    end)
end

function LinePointItem:InitInfos()
	self:GetRoot():SetPosition(self.pos.x, self.pos.y)
    self.ctrl_index = self:GetRoot():GetController("ctrl_index")

    self.wrapper = self._layout_objs.wrapper
    self.wrapper:SetVisible(false)
end

function LinePointItem:SetHighlight(val)
    self.ctrl_index:SetSelectedIndexEx(val and PointIndex.Highlight or PointIndex.Common)
end

function LinePointItem:GetPosition()
    return self.pos
end

function LinePointItem:GetIndex()
    return self.index
end

function LinePointItem:GetSize()
    return self:GetRoot():GetSize()
end

function LinePointItem:PlayEffect()
    self.wrapper:SetVisible(true)
    local ui_effect = self:CreateUIEffect(self._layout_objs.wrapper,  "effect/ui/ui_ligature_boom.ab")
    ui_effect:SetLoop(true)
    ui_effect:Play()
end

return LinePointItem
