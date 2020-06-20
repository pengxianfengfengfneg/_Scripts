local BagCtrl = Class(game.BaseCtrl)

local config_words = config.words
local config_goods = config.goods
local config_money_type = config.money_type
local _auto_use_item = config.sys_config.auto_use_item.value

local string_format = string.format
local table_insert = table.insert

function BagCtrl:_init()
    if BagCtrl.instance ~= nil then
        error("BagCtrl Init Twice!")
    end
    BagCtrl.instance = self

    require("game/bag/goods_get_way_config")
    require("game/bag/goods_use_utils")

    self.bag_view = require("game/bag/bag_view").New(self)
    self.data = require("game/bag/bag_data").New()
    self.goods_info_view = require("game/bag/goods_info_view").New(self)
    self.equip_info_view = require("game/bag/equip_info_view").New(self)
    self.bag_equip_info_view = require("game/bag/bag_equip_info_view").New(self)
    self.wear_equip_info_view = require("game/bag/wear_equip_info_view").New(self)
    self.wear_godweapon_info_view = require("game/bag/wear_godweapon_info_view").New(self)
    self.wear_hideweapon_info_view = require("game/bag/wear_hideweapon_info_view").New(self)
    self.wear_weaponsoul_info_view = require("game/bag/wear_weaponsoul_info_view").New(self)
    self.wear_dragondesign_info_view = require("game/bag/wear_dragondesign_info_view").New(self)
    self.bag_storage_view = require("game/bag/bag_storage_view").New(self)
    self.storage_rename_view = require("game/bag/storage_rename_view").New(self)
    self.storage_list_view = require("game/bag/storage_list_view").New(self)
    self.bag_shop_view = require("game/bag/bag_shop_view").New(self)
    self.wear_equip_info_compare_view = require("game/bag/wear_equip_info_compare_view").New(self)
    self.batch_use_view = require("game/bag/batch_use_view").New(self)
    self.chose_gift_use_view = require("game/bag/chose_gift_use_view").New(self)

    self:RegisterAllProtocal()

    self.quick_use_list = {}

    self.show_bag_cell = false

    self:RegisterAllEvents()

    self.next_check_time = 0
    global.Runner:AddUpdateObj(self, 2)
end

function BagCtrl:_delete()
    global.Runner:RemoveUpdateObj(self)
    self.next_check_time = nil
    self.auto_use_checkbox = nil

    self.data:DeleteMe()
    self.bag_view:DeleteMe()
    self.goods_info_view:DeleteMe()
    self.equip_info_view:DeleteMe()
    self.bag_equip_info_view:DeleteMe()
    self.wear_equip_info_view:DeleteMe()
    self.wear_godweapon_info_view:DeleteMe()
    self.wear_hideweapon_info_view:DeleteMe()
    self.wear_weaponsoul_info_view:DeleteMe()
    self.wear_dragondesign_info_view:DeleteMe()
    self.bag_storage_view:DeleteMe()
    self.storage_rename_view:DeleteMe()
    self.storage_list_view:DeleteMe()
    self.bag_shop_view:DeleteMe()
	self.wear_equip_info_compare_view:DeleteMe()
	self.batch_use_view:DeleteMe()
	self.chose_gift_use_view:DeleteMe()

    self.quick_use_list = nil

    BagCtrl.instance = nil
end

local ExpData = {
    type = game.MoneyType.Exp,
    val = 0,
}
local ExpChangeData = {
    changes = {
        ExpData
    },
    moneys = {
        ExpData
    }
}
local RoleMaxExp = game.RoleMaxExp
local RoleLvTotalExp = game.RoleLvTotalExp

config_money_type[game.MoneyType.PetExp] = {
    id = game.MoneyType.PetExp,
    name = "",
    icon = "",
    goods = 16160101,
}
local PetExpData = {
    type = game.MoneyType.PetExp,
    val = 0,
}
local PetExpChangeData = {
    changes = {
        PetExpData
    },
    moneys = {
        PetExpData
    }
}
local PetMaxExp = game.PetMaxExp
local PetLvTotalExp = game.PetLvTotalExp
function BagCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginRoleRet, function(value)
            if value then
                self:SendGetMoneyInfo()
            end
        end},
        {game.RoleEvent.LevelChange, function(data)
            local now_exp = RoleLvTotalExp[data.level] + data.exp
            ExpData.val = now_exp
            ExpData.op_type = data.op_type
            self:OnMoneyChange(ExpChangeData, true)
        end},
        {game.RoleEvent.LevelUpgrade, function(data)
            if #self:RefreshQuickUseList(data.level) > 0 then
                game.MainUICtrl.instance:OpenQuickUseView()
            else
                game.MainUICtrl.instance:CloseQuickUseView()
            end
        end},
        {game.SceneEvent.UpdateEnterSceneInfo, function(data)
            local now_exp = (RoleLvTotalExp[data.level] or RoleMaxExp) + data.exp
            ExpData.val = now_exp
            self:OnMoneyInfo(ExpChangeData)

            self.check_auto_use_state = false
        end},
         {game.SceneEvent.FixRoleAttr, function()
             self.check_auto_use_state = true
         end},
        {game.PetEvent.OnPetInfo, function()
            local pet_info = game.PetCtrl.instance:GetFightingPet()
            if pet_info then
                local now_exp = (PetLvTotalExp[pet_info.level] or PetMaxExp) + pet_info.exp
                PetExpData.val = now_exp
                self:OnMoneyInfo(PetExpChangeData)
            end
        end},
        {game.PetEvent.PetChange, function(pet_info)
            local now_exp = PetLvTotalExp[pet_info.level] + pet_info.exp
            PetExpData.val = now_exp
            PetExpData.op_type = pet_info.op_type

            self:OnMoneyChange(PetExpChangeData, true)
        end},
    }
    for _,v in ipairs(events) do
         self:BindEvent(v[1], v[2])
    end
end

function BagCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(20402, "OnMoneyInfo")
    self:RegisterProtocalCallback(20403, "OnMoneyChange")

    self:RegisterProtocalCallback(20102, "OnBagGetInfo")
    self:RegisterProtocalCallback(20104, "OnBagReset")
    self:RegisterProtocalCallback(20106, "OnBagSellItem")
    self:RegisterProtocalCallback(20108, "OnBagExtendCell")
    self:RegisterProtocalCallback(20110, "OnBagClear")
    self:RegisterProtocalCallback(20111, "OnBagChange")
    self:RegisterProtocalCallback(20114, "OnStorageExtend")
    self:RegisterProtocalCallback(20116, "OnStorageRename")
    self:RegisterProtocalCallback(20120, "OnBagGetBag")
end

function BagCtrl:InitAutoUse()
    self.auto_use_item = {}
    for _, v in ipairs(config.sys_config.auto_use_item.value) do
        table.insert(self.auto_use_item, {id = v[1], cd = 0})
    end

    self.auto_use_checkbox = {}

end

local lim_per = {}
function BagCtrl:Update(now_time, elapse_time)
    if self.next_check_time and now_time < self.next_check_time then
        return
    end
    self.next_check_time = now_time + 1
    if self.auto_use_checkbox == nil then
        return
    end
    local main_role = game.Scene.instance:GetMainRole()
    if main_role and not main_role:IsDead() then
        local auto_use_setting = game.SysSettingCtrl.instance:GetAutoUseSetting()
        lim_per[1] = main_role:GetHpPercent()
        lim_per[2] = main_role:GetMpPercent()
        local pet_obj = main_role:GetPet()
        lim_per[3] = 100
        if pet_obj and not pet_obj:IsDead() then
            lim_per[3] = pet_obj:GetHpPercent()
        end
        local role_lv = game.RoleCtrl.instance:GetRoleLevel()
        for i, v in ipairs(lim_per) do
            local setting = auto_use_setting[i]
            if math.floor(setting / 1000) == 1 then
                local percent = math.floor(v * 100)
                if percent < setting % 1000 and self.auto_use_item[i].cd <= 0 and self.check_auto_use_state then
                    local own = self:GetNumById(self.auto_use_item[i].id)
                    if own > 0 then
                        local pos = self:GetPosById(self.auto_use_item[i].id)
                        self:SendUseGoods(pos, 1)
                        self.auto_use_item[i].cd = _auto_use_item[i][2]
                    else
                        if self.auto_use_checkbox[i] ~= true and role_lv >= _auto_use_item[i][3] then
                            local content = config_goods[self.auto_use_item[i].id].name .. config_words[1567]
                            local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(content)
                            tips_view:SetBtn1(nil, function()
                                self:OpenBagShopView()
                            end)
                            tips_view:SetCheckBox(self.auto_use_checkbox[i], function(state)
                                self.auto_use_checkbox[i] = state
                            end)
                            tips_view:Open()
                            self.auto_use_item[i].cd = _auto_use_item[i][2]
                        end
                    end
                else
                end
                if self.auto_use_item[i].cd > 0 then
                    self.auto_use_item[i].cd = self.auto_use_item[i].cd - 1
                end
            end
        end
    end
end

function BagCtrl:OpenView(index)
    game.GuideCtrl.instance:FinishCurGuideInfo({on_view = "ui_bag/bag_view"})
    -- 检查是否有过期物品
    if self.data:CheckExpire() then
        self:SendBagClear(1)
        local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(config.words[1551], config.words[102])
        msg_box:Open()
    end

    if not self.bag_view:IsOpen() then
        self.bag_view:Open(index)
    else
        self.bag_view:RefreshView(index)
    end
end

function BagCtrl:CloseView()
    self.bag_view:Close()
end

function BagCtrl:CloseGoodsInfoView()
    self.goods_info_view:Close()
end

function BagCtrl:SendGetMoneyInfo()
    self:SendProtocal(20401, {})
end

function BagCtrl:OnMoneyInfo(data_list)
    -- 2:元宝 3:绑元 4:铜钱 9:友情币 10:帮会贡献 11:声望
    for k, v in pairs(data_list.moneys) do
        self.data:SetMoney(v.type, v.val)
    end
end

function BagCtrl:GetMoneyByType(type)
    return self.data:GetMoneyByType(type)
end

function BagCtrl:GetHistoryMoneyByType(type)
    return self.data:GetHistoryMoneyByType(type)
end

function BagCtrl:GetGold()
    return self.data:GetMoneyByType(game.MoneyType.Gold)
end

function BagCtrl:GetBackupGold()
    return self.data:GetMoneyByType(game.MoneyType.BackupGold)
end

function BagCtrl:GetCombineGold()
    local gold = self:GetGold()
    local backup_gold = self:GetBackupGold()
    return (gold+backup_gold)
end

function BagCtrl:GetBindGold()
    return self.data:GetMoneyByType(game.MoneyType.BindGold)
end

function BagCtrl:GetCopper()
    return self.data:GetMoneyByType(game.MoneyType.Copper)
end

function BagCtrl:GetFriendCoin()
    return self.data:GetMoneyByType(game.MoneyType.Friend)
end

function BagCtrl:OnMoneyChange(data_list, is_exp)
    local change_list = {}
    local msg_list = {}
    for i, v in pairs(data_list.changes or {}) do
        local old_money = self.data:GetMoneyByType(v.type)
        local delta_money = v.val - old_money

        self.data:SetMoney(v.type, v.val)
        change_list[v.type] = v.val

        if delta_money > 0 and v.type < 126 then
            local cfg = config_money_type[v.type] or {}
            local info = {
                desc = string_format(config_words[1574], cfg.name or "", delta_money),
                is_chat = true,
            }

            if v.type == game.MoneyType.Exp and v.op_type == game.OpType.MonDrop then
                local extra_exp = game.LakeExpCtrl.instance:GetExtraExp(delta_money)
                if extra_exp > 0 then
                    info.desc = string_format(config_words[5414], delta_money-extra_exp, extra_exp)
                end
            end

            if v.type ~= game.MoneyType.PetExp then
                table_insert(msg_list, info)
            end
        end
    end

    self:FireEvent(game.MsgEvent.AddChatMsg, msg_list)
    game.GameMsgCtrl.instance:PushMsg(msg_list)

    self:FireEvent(game.MoneyEvent.Change, change_list)
end

function BagCtrl:SendBagGetInfo()
    self:SendProtocal(20101, {})
end

function BagCtrl:OnBagGetInfo(data_list)
    self.data:SetBagInfo(data_list.bags)
    self:FireEvent(game.BagEvent.BagChange)
end

-- 整理背包
function BagCtrl:SendBagReset(bag_id)
    self:SendProtocal(20103, { bag_id = bag_id })
end

function BagCtrl:OnBagReset()
end

-- 出售道具
function BagCtrl:SendBagSellItem(bag_id, poses)
    local proto = { bag_id = bag_id, poses = poses }
    self:SendProtocal(20105, proto)
end

function BagCtrl:OnBagSellItem()
end

-- 扩充背包格子
function BagCtrl:SendBagExtend(bag_id, num)
    self:SendProtocal(20107, { bag_id = bag_id, num = num })
end

function BagCtrl:OnBagExtendCell(data_list)
    self.data:BagExtendCell(data_list)
    self:FireEvent(game.BagEvent.BagAddCell)
end

-- 清理背包(移除过期物品)
function BagCtrl:SendBagClear(bag_id)
    self:SendProtocal(20109, { bag_id = bag_id })
end

function BagCtrl:OnBagClear(data_list)
end

function BagCtrl:OnBagChange(data_list)
    local msg_list = {}
    local drop_list = {}
    local change_list = {}
    local delete_list = {}
    local career = game.RoleCtrl.instance:GetCareer()
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()

    for _,v in ipairs(data_list.changes) do
        if v.change.bag_id == 1 then
            for _,cv in ipairs(v.change.change) do
                local goods = cv.goods
                local goods_id = goods.id
                local cfg = config_goods[goods_id]
                if cfg.quick_use == 1 and role_lv >= cfg.lv then
                    if cfg.pos >= 1 and cfg.pos <= 8 then
                        if (cfg.career == career or cfg.career == 0) and game.FoundryCtrl.instance:CalEquipOffsetScore(goods) > 0 then
                            table.insert(self.quick_use_list, goods)
                        end
                    else
                        for _, value in pairs(self.quick_use_list) do
                            if value.pos == goods.pos then
                                self:RemoveQuickUseList(value)
                            end
                        end
                        table.insert(self.quick_use_list, goods)
                    end
                end

                local info = change_list[goods.id]
                if not change_list[goods.id] then
                    info = {pre=0, now=0}
                    change_list[goods.id]  = info
                end

                info.pre = info.pre + self:GetNumByPos(goods.pos)
                info.now = info.now + goods.num
                info.pos = goods.pos
            end

            for _,cv in ipairs(v.change.delete) do
                local goods_id = self.data:GetIDByPos(cv.pos)
                if goods_id then
                    delete_list[goods_id] = 0
                end
            end
        end
    end

    self.data:BagChange(data_list.changes)

    local bag_item_change = {}
    for k,v in pairs(change_list) do
        bag_item_change[k] = self:GetNumById(k)

        local add_num = v.now - v.pre
        if add_num > 0 then
            local cfg = config_goods[k]
            local info = {
                desc = string_format(config_words[1550], cfg.name, add_num),
                is_chat = true,
            }
            table_insert(msg_list, info)
            table_insert(drop_list, {id = k, num = add_num})

            if cfg.auto_use == 1 then
                game.GoodsUseUtils.Use({id = k, pos = v.pos, num = v.now})
            end
        end
    end

    if #self:GetQuickUseList() > 0 then
        game.MainUICtrl.instance:OpenQuickUseView()
    else
        game.MainUICtrl.instance:CloseQuickUseView()
    end

    for k,v in pairs(delete_list) do
        bag_item_change[k] = self:GetNumById(k)
    end

    self:FireEvent(game.BagEvent.BagItemChange, bag_item_change)

    self:FireEvent(game.MsgEvent.AddChatMsg, msg_list)

    if game.FoundryScoreRoratyView ~= nil then
        --获取抽奖转盘是否停止
        local index = game.FoundryScoreRoratyView.instance:Getvisibles()
        --转盘正在转动的时候,将抽奖获得的物品的值
        if index then
            game.FoundryScoreRoratyView.instance:GetMsgValue(msg_list,drop_list)
            return
        end
    end

    game.GameMsgCtrl.instance:PushMsg(msg_list)
    game.MainUICtrl.instance:ShowDrop(drop_list)
end

function BagCtrl:SendSmeltEquip(equip_list)
    self:SendProtocal(20113, {poses = equip_list})
end

function BagCtrl:GetGoodsBagByBagId(bag_id)
    return self.data:GetGoodsBagByBagId(bag_id)
end

function BagCtrl:OpenGoodsInfoView(info, bag_id)
    self.goods_info_view:Open(info, bag_id)
end

function BagCtrl:GetNumById(id)
    return self.data:GetNumById(id)
end

function BagCtrl:GetPosById(id)
    return self.data:GetPosById(id)
end

function BagCtrl:GetBindNumById(id, bind_type)
    return self.data:GetBindNumById(id, bind_type)
end

function BagCtrl:GetNumByPos(pos)
    return self.data:GetNumByPos(pos)
end

function BagCtrl:GetSmeltEquip()
    return self.data:GetSmeltEquip()
end

function BagCtrl:GetAdvanceEquipById(id)
    return self.data:GetAdvanceEquipById(id)
end

function BagCtrl:IsEquipGoods(id)
    local cfg = config.goods[id]
    local equip_type = config.sys_config.equip_goods_type.value
    for i, v in pairs(equip_type) do
        if cfg.type == v then
            return true
        end
    end
    return false
end

function BagCtrl:OpenTipsView(info, bag_id, in_bag, is_chat)

    if self:IsHeroEquip(info.id) then
        game.HeroCtrl.instance:OpenEquipInfoView(nil, info.pos, info.id, true, info.pos ~= nil, in_bag)
    elseif self:IsEquipGoods(info.id) then
        if in_bag then
            if info.id ~= 0 then
                self:OpenBagEquipInfoView(info, is_chat)
            end
        else
            self:OpenGoodsInfoView(info, bag_id, is_chat)
        end
    else
        self:OpenGoodsInfoView(info, bag_id, is_chat)
    end
end

function BagCtrl:OpenEquipInfoView(info)
    self.equip_info_view:Open(info)
end

function BagCtrl:OpenBagEquipInfoView(info, hide_wear)
    self.bag_equip_info_view:SetWearBtnHide(hide_wear)
    self.bag_equip_info_view:Open(info)
end

function BagCtrl:OpenRechargeInfoView(info)
    self.bag_equip_info_view:Open(info)
end

function BagCtrl:OpenWearEquipInfoView(info, hide_wear)
    self.wear_equip_info_view:SetWearBtnHide(hide_wear)
    self.wear_equip_info_view:Open(info)
end

function BagCtrl:OpenWearGodweaponInfoView(info, btn_visible)
    self.wear_godweapon_info_view:SetBtnVisible(btn_visible == nil or btn_visible == true)
    self.wear_godweapon_info_view:Open(info)
end

function BagCtrl:OpenWearEquipInfoCompareView(info, hide_wear, params_table)
    self.wear_equip_info_compare_view:SetWearBtnHide(hide_wear)
    self.wear_equip_info_compare_view:SetParams(params_table)
    self.wear_equip_info_compare_view:Open(info)
end

function BagCtrl:OpenWearHideweaponInfoView(info, btn_visible)
    self.wear_hideweapon_info_view:SetBtnVisible(btn_visible == nil or btn_visible == true)
    self.wear_hideweapon_info_view:Open(info)
end

function BagCtrl:OpenWearWeaponSoulInfoView(info, btn_visible)
    self.wear_weaponsoul_info_view:SetBtnVisible(btn_visible == nil or btn_visible == true)
    self.wear_weaponsoul_info_view:Open(info)
end

function BagCtrl:OpenWearDragonDesignInfoView(info, btn_visible)
    self.wear_dragondesign_info_view:SetBtnVisible(btn_visible == nil or btn_visible == true)
    self.wear_dragondesign_info_view:Open(info)
end

function BagCtrl:GetData()
    return self.data
end

function BagCtrl:SetShowBagCell()
    self.show_bag_cell = not self.show_bag_cell
end

function BagCtrl:GetShowBagCell()
    return self.show_bag_cell
end

function BagCtrl:GetSmeltEquipList()
    local result = {}
    local list = self.data:GetBagItemsByMainType(10)
    local cfg = config.equip_attr

    for k, v in pairs(list) do
        
        local item_id = v.goods.id
        local smelt_value = cfg[item_id].smelt or 0

        if smelt_value > 0 then
            table.insert(result, v)
        end
    end

    return result
end

function BagCtrl:SendUseGoods(pos, num, arg)
    local goods_id = self.data:GetIDByPos(pos)
    for i, v in ipairs(self.auto_use_item) do
        if v.id == goods_id then
            if v.cd > 0 then
                game.GameMsgCtrl.instance:PushMsg(config_words[1566])
                return
            else
                v.cd = _auto_use_item[i][2]
            end
        end
    end

    self:SendProtocal(20141, {pos = pos, num = num, arg = arg or 0})
end

function BagCtrl:OpenStorageView()
    self.bag_storage_view:Open()
end

function BagCtrl:SendStorageExtend(id)
    self:SendProtocal(20113, {bag_id = id})
end

function BagCtrl:OnStorageExtend(data)
    self.data:StorageExtend(data)
    self:FireEvent(game.BagEvent.StorageExtend, data)
end

function BagCtrl:SendStorageRename(id, name)
    self:SendProtocal(20115, {bag_id = id, name = name})
end

function BagCtrl:OnStorageRename(data)
    self.data:StorageRename(data)
    self:FireEvent(game.BagEvent.StorageRename, data)
end

function BagCtrl:SendBagGoodsTransfer(src_bag, dst_bag, pos)
    self:SendProtocal(20117, {src_bag = src_bag, dst_bag = dst_bag, pos = pos})
end

function BagCtrl:OpenStorageRename(id)
    self.storage_rename_view:Open(id)
end

function BagCtrl:OpenStorageListView()
    self.storage_list_view:Open()
end

function BagCtrl:OpenBagShopView()
    self.bag_shop_view:Open()
end

function BagCtrl:CloseBagShopView()
    self.bag_shop_view:Close()
end

function BagCtrl:SendBagGetBag(id)
    self:SendProtocal(20119, { bag_id = id })
end

function BagCtrl:OnBagGetBag(data)
    self.data:OnBagGetBag(data.bag)
    self:FireEvent(game.BagEvent.BagChange)
end

function BagCtrl:OpenBatchUseView(info)
    self.batch_use_view:Open(info)
end

local _quick_use_cfg = require("game/bag/quick_use_config")
function BagCtrl:GetQuickUseList()
    for i, v in pairs(self.quick_use_list) do
        local cfg = config_goods[v.id]
        local dirty = false
        if cfg.quick_use == 1 and cfg.pos >= 1 and cfg.pos <= 8 then
            if game.FoundryCtrl.instance:CalEquipOffsetScore(v) <= 0 then
                table.remove(self.quick_use_list, i)
                dirty = true
            end
        end
        if not dirty and self:GetNumByPos(v.pos) == 0 then
            table.remove(self.quick_use_list, i)
            dirty = true
        end
        if not dirty and _quick_use_cfg[v.id] then
            if not _quick_use_cfg[v.id].check_func() then
                table.remove(self.quick_use_list, i)
                dirty = true
            end
        end
    end
    return self.quick_use_list
end

function BagCtrl:RemoveQuickUseList(item)
    for i, v in ipairs(self.quick_use_list) do
        if item.pos == v.pos then
            table.remove(self.quick_use_list, i)
        end
    end
end

function BagCtrl:RefreshQuickUseList(role_lv)
    local career = game.RoleCtrl.instance:GetCareer()
    local bag_info = self:GetGoodsBagByBagId(1)
    self.quick_use_list = {}

    for _, v in pairs(bag_info.goods) do
        local cfg = config_goods[v.goods.id]
        if cfg.quick_use == 1 and role_lv >= cfg.lv then
            if cfg.pos >= 1 and cfg.pos <= 8 then
                if (cfg.career == career or cfg.career == 0) and game.FoundryCtrl.instance:CalEquipOffsetScore(v.goods) > 0 then
                    table.insert(self.quick_use_list, v.goods)
                end
            else
                table.insert(self.quick_use_list, v.goods)
            end
        end
    end

    return self.quick_use_list
end

function BagCtrl:IsHeroEquip(id)
    return config.pulse_equip[id] ~= nil
end

function BagCtrl:OpenChoseGiftView(info)
    self.chose_gift_use_view:Open(info)
end

function BagCtrl:GetInfoListById(id)
    return self.data:GetInfoListById(id)
end

game.BagCtrl = BagCtrl

return BagCtrl
