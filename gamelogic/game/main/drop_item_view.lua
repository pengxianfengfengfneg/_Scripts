local DropItemView = Class(game.BaseView)

function DropItemView:_init()
    self._package_name = "ui_main"
    self._com_name = "drop_item_view"

    self._ui_order = game.UIZOrder.UIZOrder_Top

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

    self.item_cache = {}
    self.item_using_list = {}
end

function DropItemView:OpenViewCallBack()
end

function DropItemView:CloseViewCallBack()
    if self.item_using_list then
        for _, v in pairs(self.item_using_list) do
            v:DeleteMe()
        end
        self.item_using_list = nil
    end
    if self.item_cache then
        for _, v in pairs(self.item_cache) do
            v:DeleteMe()
        end
        self.item_cache = nil
    end
end

function DropItemView:GetItem()
    local item = self.item_cache[1]
    if item then
        table.remove(self.item_cache, 1)
    else
        item = require("game/bag/item/goods_item").New()
        item:SetPackage()
        item:Open()
        item:SetParent(self:GetRoot())
    end
    return item
end

function DropItemView:ShowDrop(item_list)
    if #item_list == 0 then
        return
    end
    local bag_pos_x, bag_pos_y = game.MainUICtrl.instance:GetBtnPos(game.OpenFuncId.Bag)
    if bag_pos_x == nil or bag_pos_y == nil then
        return
    end
    for i, v in ipairs(item_list) do
        local tween = DOTween.Sequence()
        tween:AppendInterval(0.1 * i)
        tween:AppendCallback(function()
            local item = self:GetItem()
            item:GetRoot():SetPosition(game.DesignWidth / 2, game.DesignHeight / 2)
            item:GetRoot():SetScale(1.0, 1.0)
            item:GetRoot():SetVisible(true)
            item:SetItemInfo(v)
            table.insert(self.item_using_list, item)
            item:GetRoot():TweenMove({bag_pos_x - 50, bag_pos_y}, 0.8)
            item:GetRoot():TweenScale({0.0, 0.0}, 0.8)
        end)
        tween:AppendInterval(0.8)
        tween:SetAutoKill(true)
        tween:OnComplete(function()
            local using_item = self.item_using_list[1]
            if using_item then
                using_item:GetRoot():SetVisible(false)
                table.remove(self.item_using_list, 1)
                table.insert(self.item_cache, using_item)
            end
        end)
    end
end

return DropItemView