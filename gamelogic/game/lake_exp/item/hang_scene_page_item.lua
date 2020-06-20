local HangScenePageItem = Class(game.UITemplate)

function HangScenePageItem:_init()
	self.ctrl = game.LakeExpCtrl.instance
end

function HangScenePageItem:OpenViewCallBack()
    self.list_item = self:CreateList("list_item", "game/lake_exp/item/hang_scene_item")
    self.list_item:SetRefreshItemFunc(function(item, idx)
        local item_info = self.scene_config[idx]
        item:SetItemInfo(item_info, idx)
    end)
end

function HangScenePageItem:SetItemInfo(item_info)
    self.scene_config = config.kill_mon_exp_scene[item_info.page]
    self.list_item:SetItemNum(#self.scene_config)
end

return HangScenePageItem