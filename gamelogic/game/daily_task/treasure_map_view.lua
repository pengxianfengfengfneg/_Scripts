local TreasureMapView = Class(game.BaseView)

function TreasureMapView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "treasure_map_view"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function TreasureMapView:_delete()

end

function TreasureMapView:OpenViewCallBack(item_id)
    self.item_id = item_id
    self:Init()
    self:InitBg()
    self:TryAutoUse()
end

function TreasureMapView:CloseViewCallBack()
    self:StopCounter()
end

function TreasureMapView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(""):HideBtnBack()
end

function TreasureMapView:Init()
    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    self.goods_item:SetItemInfo({id = self.item_id})

    local goods_info = config.goods[self.item_id]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_name:SetText(goods_info.name)

    self.btn_use = self._layout_objs["btn_use"]
    self.btn_use:SetText(config.words[1961])
    self.btn_use:AddClickCallBack(function()
        self.ctrl:DoUseTreasureMap(self.item_id)
        self:Close()
    end)
end

function TreasureMapView:TryAutoUse()
    local delay = 1
    self:StopCounter()
    self.tween = DOTween:Sequence()
    self.tween:AppendInterval(delay)
    self.tween:AppendCallback(function()
        local treas_info = self.ctrl:GetTreasureMapInfo()
        local role_lv = game.RoleCtrl.instance:GetRoleLevel()
        local treasure_cfg = config.treasure_map_info
        if treas_info.task_times < treasure_cfg.nor_map_times and self.item_id == treasure_cfg.nor_map_id and role_lv >= treasure_cfg.auto_use_lv then
            self.ctrl:DoUseTreasureMap(self.item_id)
            self:Close()
        end
    end)
end

function TreasureMapView:StopCounter()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

return TreasureMapView
