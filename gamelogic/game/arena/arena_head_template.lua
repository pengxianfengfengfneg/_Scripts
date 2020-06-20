local ArenaHeadTemplate = Class(game.UITemplate)

function ArenaHeadTemplate:_init(parent)
    self.parent = parent
end

function ArenaHeadTemplate:OpenViewCallBack()
end

function ArenaHeadTemplate:CloseViewCallBack()
end

function ArenaHeadTemplate:RefreshItem(idx)
    self.idx = idx
    local datas = self.parent:GetMyLeftData()
    if self.ty == 2 then
        datas = self.parent:GetMyRightData()
    end

    if datas and datas[idx] then
        self._layout_objs["hp"]:SetFillAmount(datas[idx].hp_per)
    end
end

function ArenaHeadTemplate:ForceRefresh()
    if self.idx then
        self:RefreshItem(self.idx)
    end
end

function ArenaHeadTemplate:SetType(ty)
    self.ty = ty
end

return ArenaHeadTemplate