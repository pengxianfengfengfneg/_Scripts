local GuildYunbiaoResult = Class(game.BaseView)

function GuildYunbiaoResult:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_yunbiao_result"
    self.ctrl = ctrl
end

function GuildYunbiaoResult:_delete()
    
end

function GuildYunbiaoResult:OpenViewCallBack()
    self._layout_objs["btn_again"]:AddClickCallBack(function()

    end)

    self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
    end)

    self:InitAwards()
end

function GuildYunbiaoResult:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function GuildYunbiaoResult:InitAwards()
    local award_items = {}
    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(obj)
        item:SetShowTipsEnable(true)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        local item_info = award_items[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
    end)

    self.ui_list:SetItemNum(#award_items)
end

return GuildYunbiaoResult