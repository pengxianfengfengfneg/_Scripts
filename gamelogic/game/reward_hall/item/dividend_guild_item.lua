local DividendGuildItem = Class(game.UITemplate)

local RankMap = {
    [1] = {
        bg = "pm1",
        sprite = "sl_13",
    },
    [2] = {
        bg = "pm2",
        sprite = "sl_14",
    },
    [3] = {
        bg = "pm3",
        sprite = "sl_15",
    },
}

function DividendGuildItem:OpenViewCallBack()
    self.img_rank_bg = self._layout_objs.img_rank_bg
    self.img_rank = self._layout_objs.img_rank
    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2

    self.txt_rank = self._layout_objs.txt_rank
    self.txt_name = self._layout_objs.txt_name
    self.txt_live = self._layout_objs.txt_live

    self.list_award = self:CreateList("list_award", "game/bag/item/goods_item")
    self.list_award:SetRefreshItemFunc(function(item, idx)
        local item_info = self.award_list_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2], bind = item_info[3]})
        item:SetShowTipsEnable(true)
    end)
end

function DividendGuildItem:SetItemInfo(info, idx)
    local package = "ui_common"
    local img_rank_visible = info.rank <= 3

    if img_rank_visible then
        self.img_rank:SetSprite(package, RankMap[info.rank].sprite)
        self.img_rank_bg:SetSprite(package, RankMap[info.rank].bg)
    else
        self.txt_rank:SetText(info.rank)
    end

    self.img_rank:SetVisible(img_rank_visible)
    self.img_rank_bg:SetVisible(img_rank_visible)
    self.txt_rank:SetVisible(not img_rank_visible)
    
    self.txt_name:SetText(info.name)
    self.txt_live:SetText(info.live)

    self.award_list_data = config.drop[info.reward].client_goods_list
    self.list_award:SetItemNum(#self.award_list_data)

    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)
end

return DividendGuildItem