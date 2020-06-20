local GatherTab = Class(game.UITemplate)

local config_drop = config.drop
local config_gather_skill = config.gather_skill

local GatherTypeRes = {
    [1] = "cj_01",
    [2] = "cj_02",
    [3] = "cj_03",
    [4] = "cj_04",
}

function GatherTab:_init(ctrl, gather_id)
    self.ctrl = ctrl
    self.gather_id = gather_id
end

function GatherTab:OpenViewCallBack()
    self:Init()
end

function GatherTab:CloseViewCallBack()
    if self.goods_item then
        self.goods_item:DeleteMe()
        self.goods_item = nil
    end
end

function GatherTab:Init()
    self.txt_name = self._layout_objs["n5"]
    self.txt_gather_lv = self._layout_objs["n6"]
    self.item_obj = self._layout_objs["n4"]

    self.goods_item = game_help.GetGoodsItem(self.item_obj)

    self:UpdateData()
end

function GatherTab:UpdateData(data)
    local data = data or self.ctrl:GetGatherSkillInfo(self.gather_id)

    local cfg = config_gather_skill[self.gather_id]
    local skill_lv = data.level

    local lv_cfg = cfg[skill_lv]
    local drop_id = lv_cfg.reward
    local drop_cfg = config_drop[drop_id]
    local item_id = drop_cfg.client_goods_list[1][1]

    self.txt_name:SetText(lv_cfg.name)
    self.txt_gather_lv:SetText(string.format(config.words[5450], skill_lv, #cfg))

    self.goods_item:SetItemInfo({id=item_id,num=0})
    self.goods_item:SetItemImage(GatherTypeRes[self.gather_id])
end

function GatherTab:GetGatherId()
    return self.gather_id
end

return GatherTab