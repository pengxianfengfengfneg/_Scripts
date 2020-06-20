--龙元行囊
local DragonMetaXNTemplate = Class(game.UITemplate)

function DragonMetaXNTemplate:_init(parent)
	self.parent = parent
	self.ctrl = game.DragonDesignCtrl.instance
	self.dragon_design_data = self.ctrl:GetData()
end

function DragonMetaXNTemplate:_delete()
end

function DragonMetaXNTemplate:OpenViewCallBack()

	self:InitList()
	self:UpdateList()

    self._layout_objs["preview_btn"]:AddClickCallBack(function()
        self.ctrl:OpenDragonDesignPreView()
    end)

    self._layout_objs["clear_btn"]:AddClickCallBack(function()
        
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateGetDragon, function(data)
        self:UpdateList()
    end)
end

function DragonMetaXNTemplate:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function DragonMetaXNTemplate:InitList()

    self.item_list = {}
    self.select_items = {}

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
        item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        item:SetShowTipsEnable(true)
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        local item_info = self.item_list[idx]
        item.idx = idx
        item:SetItemInfo({ id = item_info.goods.id, num = item_info.goods.num, bind = item_info.goods.bind})
        item:SetItemLevel(string.format(config.words[6266], item_info.goods.level))
        item:AddClickEvent(function()
            self.ctrl:OpenDragonBagOperView(item_info.goods)
        end)
    end)

    self.ui_list:SetItemNum(#self.item_list)
end

function DragonMetaXNTemplate:UpdateList()

    self.item_list = self.dragon_design_data:GetCanEquipList(0)
    self.ui_list:SetItemNum(#self.item_list)

    self.ui_list:Foreach(function(v)
        v:SetSelect(false)
        v:SetTouchEnable(true)
    end)
end

return DragonMetaXNTemplate