local ArenaRankTemplate = Class(game.UITemplate)

function ArenaRankTemplate:_init()

end

function ArenaRankTemplate:OpenViewCallBack()

end

function ArenaRankTemplate:CloseViewCallBack()
    self:DelItems()
end

function ArenaRankTemplate:RefreshItem(idx)

    local arena_data = game.ArenaCtrl.instance:GetData()
    local rank_list = arena_data:GetRankList()

    local item_data = rank_list[idx]
    self.item_data = item_data

    self._layout_objs["n6"]:SetText(tostring(idx))
    self._layout_objs["n7"]:SetText(item_data.name)
    self._layout_objs["n8"]:SetText(item_data.fight)

    if (idx % 2) == 1 then
    	self._layout_objs["n1"]:SetSprite("ui_common","00qp_05")
    else
    	self._layout_objs["n1"]:SetSprite("ui_common","006")
    end

    for index = 1,3 do
        self._layout_objs["item"..index]:SetVisible(false)
    end

    self:DelItems()

    local drop_id = self:GetAwardDropId(idx)
    if drop_id then

        local index = 1
        local client_goods_list = config.drop[drop_id].client_goods_list

        for key, item_info in pairs(client_goods_list) do

            local item_root = self._layout_objs["item"..index]
            if item_root then
                local item = require("game/bag/item/goods_item").New()
                item:SetVirtual(item_root)
                item:Open()
                table.insert(self.item_list, item)

                item:SetItemInfo({ id = item_info[1], num = item_info[2]})
                item:SetShowTipsEnable(true)
                item_root:SetVisible(true)
            end
        end
    end
end

function ArenaRankTemplate:GetAwardDropId(rank_num)

    local drop_id

    for key, var in ipairs(config.arena_rank_award) do

        if rank_num >= var.low and rank_num <= var.high then
            drop_id = var.drop_id
            break
        end
    end

    return drop_id
end

function ArenaRankTemplate:DelItems()

    for key, var in pairs(self.item_list or {}) do

        var:DeleteMe()
    end

    self.item_list = {}
end

return ArenaRankTemplate