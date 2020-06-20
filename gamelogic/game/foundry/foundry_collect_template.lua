local FoundryCollectTemplate = Class(game.UITemplate)

function FoundryCollectTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "foundry_collect_template"
    self.parent = parent
end

function FoundryCollectTemplate:OpenViewCallBack()

    --采集
    self._layout_objs["n5"]:AddClickCallBack(function()

        if self.idx then
            local foundry_data = game.FoundryCtrl.instance:GetData()
            local gather_data = foundry_data:GetGatherData()
            local vitality = gather_data.vitality
            local cfg = config.gather_item[self.idx]
            local str = string.format(config.words[1233], vitality, cfg.level)

            local msg_box = game.GameMsgCtrl.instance:CreateMsgBoxSec(config.words[102], str)
            msg_box:SetOkBtn(function()
                game.FoundryCtrl.instance:CsGatherColl(self.idx)
                msg_box:DeleteMe()
            end)
            msg_box:Open()
        end
    end)
end

function FoundryCollectTemplate:RefreshItem(idx)
	self.idx = idx

    local cfg = config.gather_item[idx]
    local cfg_drop = config.drop[cfg.reward]
    local cfg_item = cfg_drop.client_goods_list[1]
    local item_id = cfg_item[1]
    local item_num = cfg_item[2]
    local item_cfg  = config.goods[item_id]

    if not self.goods_item then
        self.goods_item =  require("game/bag/item/goods_item").New()
        self.goods_item:SetVirtual(self._layout_objs["item"])
        self.goods_item:Open()
    end

    self.goods_item:SetItemInfo({id = item_id, num = item_num})

    self._layout_objs["name"]:SetText(item_cfg.name)

    self._layout_objs["n4"]:SetText(string.format(config.words[1230], cfg.level))
end

function FoundryCollectTemplate:CloseViewCallBack()
    if self.goods_item then
        self.goods_item:DeleteMe()
        self.goods_item = nil
    end
end

return FoundryCollectTemplate