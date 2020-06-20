local LineItem = Class(game.UITemplate)

local vec2 = cc.vec2
local pGetDistance = cc.pGetDistance
local pSub = cc.pSub
local math_atan = math.atan
local math_radian2angle = math.radian2angle

local LineIndex = {
    Common = 0,
    Highlight = 1,
}

function LineItem:_init(start_pos, end_pos, idx)
    self._package_name = "ui_daily_task"
    self._com_name = "line_item"

    self.start_pos = vec2(start_pos[1], start_pos[2])
    self.end_pos = vec2(end_pos[1], end_pos[2])
    self.index = idx
end

function LineItem:OpenViewCallBack()
    self:InitInfos()
end

function LineItem:CloseViewCallBack()
    
end

function LineItem:InitInfos()
    self.root = self:GetRoot()
    self.root:SetPosition(self.start_pos.x, self.start_pos.y)
    self.root:SetWidth(pGetDistance(self.start_pos, self.end_pos))

    self:SetEndPos(self.end_pos)
    self.ctrl_index = self:GetRoot():GetController("ctrl_index")
end

function LineItem:SetLength(end_pos)
    self.root:SetWidth(pGetDistance(self.start_pos, end_pos))
end

function LineItem:SetWidth(w)
    self.root:SetWidth(w)
end

function LineItem:GetWidth()
    return pGetDistance(self.start_pos, self.end_pos)
end

function LineItem:SetStartPos(pos)
    self.start_pos = pos
    self.root:SetPosition(pos.x, pos.y)
end

function LineItem:SetPosition(pos)
    self.root:SetPosition(pos.x, pos.y)
end

function LineItem:SetEndPos(end_pos)
    self.end_pos = end_pos
    self:SetLength(end_pos)
    local dir = pSub(end_pos, self.start_pos)

    local angle = math_radian2angle(math_atan(-1 * dir.y, dir.x))
    self.root:SetRotation(self:ClampLineAngle(angle))
end

function LineItem:GetEndPos()
    return self.end_pos
end

function LineItem:SetHighlight(val)
    self.ctrl_index:SetSelectedIndexEx(val and LineIndex.Highlight or LineIndex.Common)
end

function LineItem:GetIndex()
    return self.index
end

function LineItem:ClampLineAngle(angle)
    while angle > 180 do
        angle = angle - 360
    end
    while angle < -180 do
        angle = angle + 360
    end
    angle = angle * -1
    return angle
end

return LineItem
