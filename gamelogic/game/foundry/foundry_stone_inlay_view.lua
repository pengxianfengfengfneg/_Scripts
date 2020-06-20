local FoundryStoneInlayView = Class(game.BaseView)

function FoundryStoneInlayView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_stone_inlay_view"
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function FoundryStoneInlayView:_delete()
end

function FoundryStoneInlayView:OpenViewCallBack(stone_pos)

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1268])

    self._layout_objs["common_bg/btn_close"]:AddClickCallBack(function ()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_stone_inlay_view/close_btn"})
        self:Close()
    end)

    self.stone_pos = stone_pos

    self:InitTopItem()

    self:SetTopItem()

    self:InitList()

    self:UpdateListData()

    self:UpdateRightList()

    self:BindEvent(game.FoundryEvent.InlaySucc, function(data)
        self:SetTopItem()
        self:UpdateListData()
        self:UpdateRightList()
    end)

    self._layout_objs["cur_item/sub_btn"]:AddClickCallBack(function()
        if self.stone_pos then
            game.FoundryCtrl.instance:CsEquipInlayStone(self.stone_pos, 0)
        end
    end)
end

function FoundryStoneInlayView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end

    if self.inlay_item then
        self.inlay_item:DeleteMe()
        self.inlay_item = nil
    end
end

function FoundryStoneInlayView:InitTopItem()

    local item = require("game/bag/item/goods_item").New()
    item:SetVirtual(self._layout_objs["cur_item"])
    item:Open()
    item:SetTouchEnable(true)
    item:ResetItem()
    self.inlay_item = item
end

function FoundryStoneInlayView:SetTopItem()

    local equip_pos = math.floor(self.stone_pos/10)

    --装备信息
    local equip_info
    if equip_pos == 9 then
        equip_info = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    elseif equip_pos == 10 then
        equip_info = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    elseif equip_pos == 11 then
        equip_info = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    else
        equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(equip_pos)
    end

    --装备某位置 宝石信息
    local stone_item_id = 0
    if equip_info and equip_info.stones then

        for _, v in pairs(equip_info.stones) do
            if v.pos == self.stone_pos then
                stone_item_id = v.id
                break
            end
        end
    end

    --未镶嵌
    if stone_item_id == 0 then
        self.inlay_item:ResetItem()
        self._layout_objs["cur_item/stone_name"]:SetText("")
        self._layout_objs["cur_item/item_attr"]:SetText("")
        self._layout_objs["cur_item/jh_img"]:SetVisible(true)
    else
        local item_cfg = config.goods[stone_item_id]
        local cfg = self:GetStoneCfg(stone_item_id)
        local attr = cfg.attr
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[1])

        self._layout_objs["cur_item/stone_name"]:SetText(item_cfg.name)

        self.inlay_item:SetItemInfo({id = stone_item_id, num = 1})

        self._layout_objs["cur_item/item_attr"]:SetText(string.format(config.words[1226], attr_name, attr[2]))
        self._layout_objs["cur_item/sub_btn"]:SetVisible(true)
        self._layout_objs["cur_item/jh_img"]:SetVisible(false)
    end
end

function FoundryStoneInlayView:GetStoneCfg(stone_item_id)

    local cfg

    for k, v in pairs(config.equip_stone) do

        for item_id, v2 in pairs(v) do

            if item_id == stone_item_id then
                cfg = v2
                break
            end
        end

        if cfg then
            break
        end
    end

    return cfg
end

function FoundryStoneInlayView:InitList()

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/foundry/foundry_stone_right_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddClickItemCallback(function(item)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)

        local data = self.list_data[idx]
        if data.type == 1 then
            return "ui_foundry:stone_right_template1"
        else
            return "ui_foundry:stone_right_template2"
        end
    end)

    self.ui_list:SetItemNum(0)
end

function FoundryStoneInlayView:UpdateListData()

    local equip_pos = math.floor(self.stone_pos/10)
    local career = game.RoleCtrl.instance:GetCareer()
    local cfg = config.equip_stone_pos[equip_pos][self.stone_pos]
    local inlay_types = cfg["inlay_type_"..career]

    self.list_data = {}

    for k, v in ipairs(inlay_types) do

        local t = {}
        t.type = 1
        t.stone_type = v

        table.insert(self.list_data, t)
    end
end

--点击宝石类型 增加该类型的宝石 入列表
function FoundryStoneInlayView:InsertRightListData(stone_type, stone_list)

    --删除物品 保留类型
    local new_list = {}
    for k, v in ipairs(self.list_data) do

        if v.type ~= 2 then
            table.insert(new_list, v)
        end
    end

    --添加物品

    if stone_list then

        local length = #new_list
        local insert_pos = length+1
        for i = length, 1, -1 do

            if new_list[i].stone_type == stone_type then
                break
            end

            insert_pos = i
        end

        --每两个存入一次 new_list
        local t
        local count = 0
        local max_num = #stone_list
        for k, v in ipairs(stone_list) do

            if count == 0 then
                t = {}
                t.type = 2
                t.data1  = v
                count = count + 1

                --如果是最后一个直接存入列表
                if k == max_num then
                    table.insert(new_list, insert_pos, t)
                end

            elseif count == 1 then
                t.data2  = v
                table.insert(new_list, insert_pos, t)
                insert_pos = insert_pos + 1

                count = 0
            end
        end
    end

    self.list_data = new_list
end

function FoundryStoneInlayView:UpdateRightList()

    local num = #self.list_data

    self.ui_list:SetItemNum(num)

    self.ui_list:Foreach(function(v)
        v:SetSelect(false)
    end)
end

function FoundryStoneInlayView:GetListData()
    return self.list_data
end

function FoundryStoneInlayView:OnSelectTypeItem(index, item)

    local item_data = self.list_data[index]

    --选中类型框
    if item_data.type == 1 then

        if item:GetSelectFlag() then
            item:SetSelect(false)
            self:InsertRightListData()
            self:UpdateRightList()
        else
            local stone_type = item_data.stone_type
            local bag_data = game.BagCtrl.instance:GetData()
            local stone_list = bag_data:GetStonesByTypes({stone_type})

            self:InsertRightListData(stone_type, stone_list)
            self:UpdateRightList()
            item:SetSelect(true)
        end

    --选中物品
    elseif item_data.type == 2 then
        -- item:SetSelect(true)

        -- local type_item = self:GetTypeItem(index)
        -- type_item:SetSelect(true)

        -- local pos_t = self.select_index * 10 + self.select_stone_index
        -- local stone_item_id = item_data.data.goods.id
        -- game.FoundryCtrl.instance:CsEquipInlayStone(pos_t, stone_item_id)
    end
end

return FoundryStoneInlayView
