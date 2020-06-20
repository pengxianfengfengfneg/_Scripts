local SocietyItem = Class(game.UITemplate)

function SocietyItem:_init(parent)
    self.parent = parent
    self.society_data = game.SocietyCtrl.instance:GetData()
end

function SocietyItem:OpenViewCallBack()
    self._layout_objs["get_btn"]:AddClickCallBack(function()
        if self.state == 3 or self.state == 4 then
            game.SocietyCtrl.instance:CsSocietyGetReward(self.item_data.id)
        else
            local go_func_id = self.item_data.link
            local cfg = config.goods_get_way[go_func_id]

            if cfg and cfg.click_func then
                cfg.click_func()
            end
        end
    end)
end

function SocietyItem:CloseViewCallBack()
    if self.goods_item then
        self.goods_item:DeleteMe()
        self.goods_item = nil
    end
end

function SocietyItem:RefreshItem(idx)
    local data_list = self.parent:GetDataList()
    local item_data = data_list[idx]
    self.item_data = item_data

    self._layout_objs["n6"]:SetText(item_data.desc)

    self._layout_objs["n8"]:SetText(item_data.star)

    if not self.goods_item then
        self.goods_item = require("game/bag/item/goods_item").New()
        self.goods_item:SetVirtual(self._layout_objs["n5"])
        self.goods_item:Open()
        self.goods_item:SetShowTipsEnable(true)
    end

    local reward = item_data.reward
    local item_info = config.drop[reward].client_goods_list[1]
    self.goods_item:SetItemInfo({ id = item_info[1], num = item_info[2]})

    local state = self.society_data:GetTaskState(item_data.id)
    self.state = state
    self._layout_objs["get_btn"]:SetGray(false)
    if state == 4 then
        self._layout_objs["get_btn"]:SetText(config.words[2804])
        self._layout_objs["n11"]:SetVisible(false)
        self._layout_objs["get_btn"]:SetGray(true)
    elseif state == 3 then
        self._layout_objs["get_btn"]:SetText(config.words[2803])
        self._layout_objs["n11"]:SetVisible(true)
    else
        self._layout_objs["get_btn"]:SetText(config.words[1768])
        self._layout_objs["n11"]:SetVisible(false)
    end
end

return SocietyItem