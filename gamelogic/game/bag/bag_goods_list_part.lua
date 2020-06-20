local BagGoodsListPart = Class(game.UITemplate)

local bag_ctrl = game.BagCtrl.instance

function BagGoodsListPart:OpenViewCallBack()
    self.list = self:CreateList("list", "game/bag/item/goods_item", true)
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.goods_list[idx]
        if info then
            item:SetItemInfo(info)
            if game.__DEBUG__ and bag_ctrl:GetShowBagCell() then
                item:SetItemLevel(info.pos)
            end
            item:AddClickEvent(function()
                self.click_func(info)
            end)
            item:AddDoubleClickEvent(function()
                self.double_click_func(info)
            end)
        else
            item:ResetItem()
            item:ResetFunc()
        end
    end)
    self._layout_objs.list:SetSize(720, 328)
end

function BagGoodsListPart:CloseViewCallBack()
    self.list = nil
    self.goods_list = nil
end

function BagGoodsListPart:RefreshGoods(goods_list)
    self.goods_list = goods_list
    if self.goods_list == nil then
        self.goods_list = {}
    end

    --随身仓库最大容量
    local max_size = config.bag[1].size
    self.list:SetItemNum(max_size)
end

function BagGoodsListPart:SetCurStorage(id)

    --仓库存入
    self.click_func = function(info)
        bag_ctrl.goods_info_view:OverrideSellEvent(config.words[1563], function()
            bag_ctrl:SendBagGoodsTransfer(1, id, info.pos)
        end)
        bag_ctrl:OpenGoodsInfoView(info, 0)
    end

    --双击仓库存入
    self.double_click_func = function(info)
        bag_ctrl:SendBagGoodsTransfer(1, id, info.pos)
    end
end

function BagGoodsListPart:SetSelectSell(callback)
    self.click_func = function(info)
        --出售
        bag_ctrl.goods_info_view:OverrideSellEvent(config.words[1562], function()
            local cfg = config.goods[info.id]
            if #cfg.price == 0 then
                game.GameMsgCtrl.instance:PushMsg(config.words[1565])
                return
            end
            for i, v in ipairs(self.goods_list) do
                if v.pos == info.pos then
                    table.remove(self.goods_list, i)
                    break
                end
            end
            self:RefreshGoods(self.goods_list)
            callback(info)
        end)
        bag_ctrl:OpenGoodsInfoView(info, 0)
    end

    self.double_click_func = function(info)
        local cfg = config.goods[info.id]
        if #cfg.price == 0 then
            game.GameMsgCtrl.instance:PushMsg(config.words[1565])
            return
        end
        for i, v in ipairs(self.goods_list) do
            if v.pos == info.pos then
                table.remove(self.goods_list, i)
                break
            end
        end
        self:RefreshGoods(self.goods_list)
        callback(info)
    end
end

return BagGoodsListPart