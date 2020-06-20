local ArenaResultView = Class(game.BaseView)

function ArenaResultView:_init(ctrl)
	self._package_name = "ui_arena"
    self._com_name = "arena_succ_result_view"

    self.ctrl = ctrl
end

function ArenaResultView:OpenViewCallBack(data)

    self._layout_objs["n3"]:SetTouchDisabled(false)
    self._layout_objs["bg"]:AddClickCallBack(function()
        self:Close()
    end)

    local drop_id
    local success = data.succeed
    if success == 1 then
        self._layout_objs["n4"]:SetSprite("ui_common", "zdjs_tzcg")
        self._layout_objs["n48"]:SetText(string.format(config.words[2501], data.rank_new))
        drop_id = config.sys_config["arena_victory_reward"].value
    else
        self._layout_objs["n4"]:SetSprite("ui_common", "zdjs_tzsb")
        self._layout_objs["n48"]:SetText(config.words[2502])
        drop_id = config.sys_config["arena_failure_reward"].value
    end

    --奖励
    self._layout_objs["n3"]:SetTouchDisabled(false)
    self._layout_objs["bg"]:AddClickCallBack(function()
        self.ctrl:CsArenaQuit()
        self:Close()
    end)

    local award_items = config.drop[drop_id].client_goods_list
    local list = self._layout_objs["n51"]
    self.ui_list = game.UIList.New(list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(obj)
        item:SetShowTipsEnable(true)
        item:Open()
        item:GetRoot():SetScale(0.8, 0.8)

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        local item_info = award_items[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
    end)

    self.ui_list:SetItemNum(#award_items)
end

function ArenaResultView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

return ArenaResultView