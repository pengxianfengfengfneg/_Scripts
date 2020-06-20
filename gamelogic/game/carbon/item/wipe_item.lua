local WipeItem = Class(game.UITemplate)

local _cfg_money_type = config.money_type
local _cfg_dun_lv = config.dungeon_lv

function WipeItem:SetDunID(dun_id)
    self.dun_id = dun_id
end

function WipeItem:SetItemInfo(info)

    local dun_lv_cfg = _cfg_dun_lv[self.dun_id][info.lv]
    local name = dun_lv_cfg.chapter_name .. " " .. dun_lv_cfg.name
    self._layout_objs.name:SetText(name)

    local list = self:CreateList("list", "game/bag/item/goods_item")
    list:SetRefreshItemFunc(function(item, idx)
        local item_info = info.rewards[idx]
        local item_id = item_info.id
        if item_id == 0 then
            item_id = _cfg_money_type[v.type]
        end
        item:SetItemInfo({ id = item_id, num = item_info.num })
        item:SetShowTipsEnable(true)
    end)
    list:SetItemNum(#info.rewards)
end

function WipeItem:SetBG(val)
    self._layout_objs.bg:SetVisible(val)
end

return WipeItem