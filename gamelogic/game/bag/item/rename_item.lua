local RenameItem = Class(game.UITemplate)

function RenameItem:OpenViewCallBack()
end

function RenameItem:CloseViewCallBack()
    self.info = nil
end

function RenameItem:SetItemInfo(info)
    self.info = info
    self._layout_objs.num:SetText(info.id - 2)
    local bag_info = game.BagCtrl.instance:GetGoodsBagByBagId(info.id)
    if bag_info then
        self._layout_objs.name:SetText(bag_info.name)
        local clr = cc.GoodsColor[1]
        self._layout_objs.name:SetColor(clr.x, clr.y, clr.z, clr.w)
    else
        self._layout_objs.name:SetTouchEnable(false)
        local clr = cc.GoodsColor[6]
        self._layout_objs.name:SetColor(clr.x, clr.y, clr.z, clr.w)
    end
end

function RenameItem:SaveNewName()
    local bag_info = game.BagCtrl.instance:GetGoodsBagByBagId(self.info.id)
    if bag_info then
        local new_name = self._layout_objs.name:GetText()
        if new_name ~= bag_info.name then
            game.BagCtrl.instance:SendStorageRename(self.info.id, new_name)
        end
    end
end

return RenameItem