local BagStorageView = Class(game.BaseView)

function BagStorageView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "bag_storage"
    self._view_level = game.UIViewLevel.Second
    self._show_money = true

    self.ctrl = ctrl
end

function BagStorageView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1674])

    self:InitBtn()

    self:InitTemplate()

    self:InitStorageList()

    self:RegisterEvent()

    self:RefreshBag()

    self:SetStorageInfo(3)
end

function BagStorageView:RegisterEvent()
    self:BindEvent(game.BagEvent.StorageRename, function(data)
        if data.bag_id == self.cur_storage then
            self._layout_objs.storage_name:SetText(data.name)
        end
    end)

    self:BindEvent(game.BagEvent.StorageExtend, function()
        self._layout_objs.btn_right:SetVisible(self.ctrl:GetGoodsBagByBagId(self.cur_storage + 1) ~= nil)
    end)

    self:BindEvent(game.BagEvent.SelectStorage, function(id)
        self:SetStorageInfo(id)
    end)

    self:BindEvent(game.BagEvent.BagItemChange, function()
        self:RefreshBag()
        self:SetStorageInfo(self.cur_storage)
    end)

    self:BindEvent(game.BagEvent.BagChange, function()
        self:RefreshBag()
        self:SetStorageInfo(self.cur_storage)
    end)
end

function BagStorageView:InitBtn()
    local btn = self._layout_objs.tab_list:GetChildAt(0)
    btn:SetText(config.words[1561])
    for i = 1, 3 do
        btn = self._layout_objs.tab_list:GetChildAt(i)
        btn:SetText(config.bag_type[i].name)
    end

    self._layout_objs.btn_tidy:AddClickCallBack(function()
        self.ctrl:SendBagReset(1)
    end)

    self._layout_objs.btn_tidy_storage:AddClickCallBack(function()
        self.ctrl:SendBagReset(self.cur_storage)
    end)

    --一键存入
    self._layout_objs.btn_in:AddClickCallBack(function()
        self.ctrl:SendBagGoodsTransfer(1, self.cur_storage, 0)
    end)
    --一键取出
    self._layout_objs.btn_out:AddClickCallBack(function()
        self.ctrl:SendBagGoodsTransfer(self.cur_storage, 1, 0)
    end)

    self._layout_objs.btn_rename:AddClickCallBack(function()
        self.ctrl:OpenStorageRename(self.cur_storage)
    end)

    self.storage_pages = {}
    for _, v in pairs(config.bag) do
        if v.id >= 3 then
            table.insert(self.storage_pages, v)
        end
    end
    table.sort(self.storage_pages, function(a, b)
        return a.id < b.id
    end)
    self._layout_objs.btn_extend:AddClickCallBack(function()
        local next_page = 0
        local cost = 0
        for _, v in ipairs(self.storage_pages) do
            if self.ctrl:GetGoodsBagByBagId(v.id) == nil then
                next_page = v.id
                cost = v.cost
                break
            end
        end
        if next_page == 0 then
            game.GameMsgCtrl.instance:PushMsg(config.words[1560])
            return
        end
        local str = string.format(config.words[1559], next_page - 2, cost)
        local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(str)
        msg_box:SetBtn1(nil, function()
            self.ctrl:SendStorageExtend(next_page)
        end)
        msg_box:SetBtn2(config.words[101])
        msg_box:Open()
    end)

    self._layout_objs.btn_left:AddClickCallBack(function()
        self:SetStorageInfo(self.cur_storage - 1)
    end)

    self._layout_objs.btn_right:AddClickCallBack(function()
        self:SetStorageInfo(self.cur_storage + 1)
    end)

    self._layout_objs.btn_storage:SetTouchDisabled(false)
    self._layout_objs.btn_storage:AddClickCallBack(function()
        self.ctrl:OpenStorageListView()
    end)
end

function BagStorageView:InitTemplate()
    self.bag_lists = {}
    for i = 0, 3 do
        local template = self:GetTemplateByObj("game/bag/bag_goods_list_part", self._layout_objs.list:GetChildAt(i))
        table.insert(self.bag_lists, template)
    end

    self._layout_objs.list:SetHorizontalBarTop(true)
end

function BagStorageView:InitStorageList()
    self.storage_list = self:CreateList("storage_list", "game/bag/item/goods_item")
    self.storage_list:SetRefreshItemFunc(function(item, idx)
        local info = self.storage_goods[idx]
        if info then
            item:SetItemInfo(info)
            if game.__DEBUG__ and self.ctrl:GetShowBagCell() then
                item:SetItemLevel(info.pos)
            end
            item:AddClickEvent(function()
                self.ctrl.goods_info_view:OverrideSellEvent(config.words[1564], function()
                    self.ctrl:SendBagGoodsTransfer(self.cur_storage, 1, info.pos)
                end)
                self.ctrl:OpenGoodsInfoView(info, 0)
            end)
            item:AddDoubleClickEvent(function()
                self.ctrl:SendBagGoodsTransfer(self.cur_storage, 1, info.pos)
            end)
        else
            item:ResetItem()
        end
    end)
end

function BagStorageView:RefreshBag()
    local bag_info = self.ctrl:GetGoodsBagByBagId(1)
    local all_goods = {}
    for _, v in pairs(bag_info.goods) do
        all_goods[v.goods.pos] = v.goods
    end
    self.bag_lists[1]:RefreshGoods(all_goods)

    local goods_cate = {}
    for i = 1, 3 do
        goods_cate[i] = {}
        local goods_type = config.bag_type[i].type
        for _, v in ipairs(all_goods) do
            local goods_cfg = config.goods[v.id]
            for _, val in pairs(goods_type) do
                if goods_cfg.type == val then
                    table.insert(goods_cate[i], v)
                end
            end
        end
        self.bag_lists[i + 1]:RefreshGoods(goods_cate[i])
    end
end

function BagStorageView:SetStorageInfo(id)
    self.cur_storage = id
    for _, v in pairs(self.bag_lists) do
        v:SetCurStorage(id)
    end
    local bag_info = self.ctrl:GetGoodsBagByBagId(id)
    self._layout_objs.storage_name:SetText(bag_info.name)

    self.storage_goods = {}
    for _, v in pairs(bag_info.goods) do
        self.storage_goods[v.goods.pos] = v.goods
    end
    self.storage_list:SetItemNum(bag_info.cell_num)

    self._layout_objs.btn_left:SetVisible((id - 2) > 1)
    self._layout_objs.btn_right:SetVisible(self.ctrl:GetGoodsBagByBagId(id + 1) ~= nil)
end

return BagStorageView
