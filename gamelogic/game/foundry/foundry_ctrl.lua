local FoundryCtrl = Class(game.BaseCtrl)

function FoundryCtrl:_init()
    if FoundryCtrl.instance ~= nil then
        error("FoundryCtrl Init Twice!")
    end
    FoundryCtrl.instance = self

    self.foundry_data = require("game/foundry/foundry_data").New(self)
    self.foundry_view = require("game/foundry/foundry_view").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()
end

function FoundryCtrl:_delete()
    self.foundry_view:DeleteMe()
    self.foundry_data:DeleteMe()

    if self.stren_suit_attr_view then
        self.stren_suit_attr_view:DeleteMe()
        self.stren_suit_attr_view = nil
    end

    if self.stone_suit_attr_view then
        self.stone_suit_attr_view:DeleteMe()
        self.stone_suit_attr_view = nil
    end

    if self.stone_advance_view then
        self.stone_advance_view:DeleteMe()
        self.stone_advance_view = nil
    end

    if self.foundry_score_roraty_view then
        self.foundry_score_roraty_view:DeleteMe()
        self.foundry_score_roraty_view = nil
    end

    if self.foundry_collect_view then
        self.foundry_collect_view:DeleteMe()
        self.foundry_collect_view = nil
    end

    if self.foundry_smelt_set_view then
        self.foundry_smelt_set_view:DeleteMe()
        self.foundry_smelt_set_view = nil
    end

    if self.foundry_smelt_view then
        self.foundry_smelt_view:DeleteMe()
        self.foundry_smelt_view = nil
    end

    if self.foundry_smelt_select_view then
        self.foundry_smelt_select_view:DeleteMe()
        self.foundry_smelt_select_view = nil
    end

    if self.foundry_refine_view then
        self.foundry_refine_view:DeleteMe()
        self.foundry_refine_view = nil
    end

    if self.foundry_godweapon_view then
        self.foundry_godweapon_view:DeleteMe()
        self.foundry_godweapon_view = nil
    end

    if self.hideweapon_skill_preview then
        self.hideweapon_skill_preview:DeleteMe()
        self.hideweapon_skill_preview = nil
    end

    if self.foundry_huanhua_allattr_view then
        self.foundry_huanhua_allattr_view:DeleteMe()
        self.foundry_huanhua_allattr_view = nil
    end

    if self.refine_stren_view then
        self.refine_stren_view:DeleteMe()
        self.refine_stren_view = nil
    end

    if self.refine_inlay_view then
        self.refine_inlay_view:DeleteMe()
        self.refine_inlay_view = nil
    end

    if self.refine_takeoff_view then
        self.refine_takeoff_view:DeleteMe()
        self.refine_takeoff_view = nil
    end

    if self.refine_upgrade_view then
        self.refine_upgrade_view:DeleteMe()
        self.refine_upgrade_view = nil
    end

    if self.hideweapon_view then
        self.hideweapon_view:DeleteMe()
        self.hideweapon_view = nil
    end

    if self.foundry_godweapon_showview then
        self.foundry_godweapon_showview:DeleteMe()
        self.foundry_godweapon_showview = nil
    end

    if self.foundry_hideweapon_showview then
        self.foundry_hideweapon_showview:DeleteMe()
        self.foundry_hideweapon_showview = nil
    end

    if self.foundry_godweapon_collect_view then
        self.foundry_godweapon_collect_view:DeleteMe()
        self.foundry_godweapon_collect_view = nil
    end

    if self.foundry_godweapon_preview then
        self.foundry_godweapon_preview:DeleteMe()
        self.foundry_godweapon_preview = nil
    end
    FoundryCtrl.instance = nil
end

function FoundryCtrl:OpenView(index)
    self.foundry_view:Open(index)
end

function FoundryCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginRoleRet, function(value)
            if value then
                self:CsEquipInfo()
                self:CsGatherInfo()
                self:CsArtifactGetInfo()
                self:CsAnqiGetInfo()
            end
        end},

        {game.SceneEvent.CommonlyValueRespon, handler(self, self.OnCommonlyKeyValue)}
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FoundryCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(20202, "ScEquipInfo")
    self:RegisterProtocalCallback(20204, "ScEquipWear")
    self:RegisterProtocalCallback(20206, "ScEquipTakeOff")
    self:RegisterProtocalCallback(20208, "ScEquipStren")
    self:RegisterProtocalCallback(20210, "ScEquipOneKeyStren")
    self:RegisterProtocalCallback(20212, "ScEquipInlayStone")
    self:RegisterProtocalCallback(20214, "ScEquipAdvStone")
    self:RegisterProtocalCallback(20216, "ScEquipInlayParis")
    self:RegisterProtocalCallback(20220, "ScEquipStripParis")
    self:RegisterProtocalCallback(20702, "ScRefineCompose")
    self:RegisterProtocalCallback(20704, "ScRefineForge")
    self:RegisterProtocalCallback(20712, "ScRefineForgeWheel")
    self:RegisterProtocalCallback(42202, "ScSmeltInfo")
    self:RegisterProtocalCallback(42204, "ScSmeltDo")
    self:RegisterProtocalCallback(52202, "ScArtifactGetInfo")
    self:RegisterProtocalCallback(52204, "ScArtifactAddExtraAttr")
    self:RegisterProtocalCallback(52206, "ScArtifactLvUp")
    self:RegisterProtocalCallback(52208, "ScArtifactChangeAvatar")
    self:RegisterProtocalCallback(52209, "ScArtifactRefreshAvatars")
    self:RegisterProtocalCallback(52211, "ScArtifactUpdateNew")
    self:RegisterProtocalCallback(52602, "ScAnqiGetInfo")
    self:RegisterProtocalCallback(52604, "ScAnqiPractice")
    self:RegisterProtocalCallback(52606, "ScAnqiForge")
    self:RegisterProtocalCallback(52608, "ScAnqiLvUp")
    self:RegisterProtocalCallback(52610, "ScAnqiChangePlan")
    self:RegisterProtocalCallback(52612, "ScAnqiUnlockPlan")
    self:RegisterProtocalCallback(52614, "ScAnqiRefreshPlan")
    self:RegisterProtocalCallback(52616, "ScAnqiReplacePlan")
    self:RegisterProtocalCallback(52617, "ScAnqiNewPlanUpdate")
    self:RegisterProtocalCallback(52621, "ScAnqiPoisonSlotUpdate")
end

--装备信息
function FoundryCtrl:CsEquipInfo()
    self:SendProtocal(20201,{})
end

function FoundryCtrl:ScEquipInfo(data_list)
    self.foundry_data:SetEquipInfo(data_list)
end

function FoundryCtrl:SetEquipInfo(info)
    self.foundry_data:SetEquipInfo(info)
end

function FoundryCtrl:GetEquipInfo()
    return self.foundry_data:GetEquipInfo()
end

function FoundryCtrl:GetEquipInfoByType(type)
    -- 装备位置
    -- 1.帽子 2.衣服 3.肩膀 4.鞋子 5.护腕 6.项链 7.戒指 8.护符
    return self.foundry_data:GetEquipInfoByType(type)
end

--装备穿戴
function FoundryCtrl:CsEquipWear(cell_t)
    self:SendProtocal(20203,{cell = cell_t})
end

function FoundryCtrl:ScEquipWear(data)
    self.foundry_data:UpdateEquipInfo(data)
end

--装备卸下
function FoundryCtrl:CsEquipTakeOff(pos_t)
    self:SendProtocal(20205,{pos = pos_t})
end

function FoundryCtrl:ScEquipTakeOff(data)
    self.foundry_data:TakeOffEquip(data)
    self:FireEvent(game.FoundryEvent.EquipRefresh, data)
end

--装备一键穿戴
function FoundryCtrl:CsEquipOneKeyWear()
    self:SendProtocal(20205,{})
end

function FoundryCtrl:ScEquipOneKeyWear(data)
    local info = game.FoundryCtrl.instance:GetEquipInfo()
    if info then
        local flag
        for _, value in pairs(data_list.changes) do
            flag = true
            for _, equip in pairs(info.equips) do
                if value.equip.pos == equip.equip.pos then
                    equip.equip = value.equip
                    flag = false
                end
            end
            if flag then
                table.insert(info.equips, value)
            end
        end
        info.suit_lv = data_list.suit_lv
        self.foundry_data:SetEquipInfo(info)
        self:FireEvent(game.RoleEvent.WearEquip, data_list.changes)
    end
end

--强化
function FoundryCtrl:CsEquipStren(pos_t)
    self:SendProtocal(20207,{pos = pos_t})
end

function FoundryCtrl:ScEquipStren(data)
    self.foundry_data:ChangeStrenLv(data)
    self:FireEvent(game.FoundryEvent.StrenSucc, data)
    self:FireEvent(game.FoundryEvent.MainUIRedpoint)
end

--一键强化
function FoundryCtrl:CsEquipOneKeyStren()
    self:SendProtocal(20209,{})
end

function FoundryCtrl:ScEquipOneKeyStren(data)
    local changes = data.changes
    for _, v in pairs(changes) do
        self.foundry_data:ChangeStrenLv(v)
    end

    self:FireEvent(game.FoundryEvent.OneKeyStrenSucc, data)

    self:FireEvent(game.FoundryEvent.MainUIRedpoint)
end

--镶嵌
function FoundryCtrl:CsEquipInlayStone(pos_t, id_t)
    self:SendProtocal(20211,{pos = pos_t, id = id_t})
end

function FoundryCtrl:ScEquipInlayStone(data)
    self.foundry_data:ChangeStoneInlay(data)
    self:FireEvent(game.FoundryEvent.InlaySucc, data)
    self:FireEvent(game.FoundryEvent.MainUIRedpoint)
end

--提升
function FoundryCtrl:CsEquipAdvStone(pos_t)
    self:SendProtocal(20213,{pos = pos_t})
end

function FoundryCtrl:ScEquipAdvStone(data)
    self.foundry_data:ChangeStoneInlay(data)
    self:FireEvent(game.FoundryEvent.InlaySucc, data)
end

--合成
function FoundryCtrl:CsRefineCompose(bag_id_t, pos_arr, type_t)
    self:SendProtocal(20701, {bag_id = bag_id_t, poses = pos_arr, type = type_t})
end

function FoundryCtrl:ScRefineCompose(data)
    self:FireEvent(game.FoundryEvent.ComposeSucc, data)
    self:FireEvent(game.FoundryEvent.MainUIRedpoint)
end

--打造
function FoundryCtrl:CsRefineForge(forge_id, forge_type, use_unbind)
    self:SendProtocal(20703, {id = forge_id, type = forge_type, opt = use_unbind})
end

function FoundryCtrl:ScRefineForge(data)
    self:FireEvent(game.FoundryEvent.ForgeSucc, data)
end

function FoundryCtrl:GetComposeBagItemList()

    local bag_data = game.BagCtrl.instance:GetData()
    local result = bag_data:GetComposeBagItemList()
    return result
end

function FoundryCtrl:OpenStrenSuitAttrView(career, stren_lv_list)

    if not self.stren_suit_attr_view then
        self.stren_suit_attr_view = require("game/foundry/foundry_stren_suit_attr_view").New()
    end
    self.stren_suit_attr_view:SetCfg(career, stren_lv_list)
    self.stren_suit_attr_view:Open()
end

function FoundryCtrl:OpenStoneSuitAttrView(career, stone_min_lv_list)

    if not self.stone_suit_attr_view then
        self.stone_suit_attr_view = require("game/foundry/foundry_stone_suit_attr_view").New()
    end
    self.stone_suit_attr_view:SetCfg(career, stone_min_lv_list)
    self.stone_suit_attr_view:Open()
end

function FoundryCtrl:GetData()
    return self.foundry_data
end

function FoundryCtrl:OpenAdvanceView(sour_item)

    local sour_item_id = sour_item[1]
    local stone_pos = sour_item[2]

    local stone_cfg
    for k, v in pairs(config.equip_stone) do

        for item_id, vt in pairs(v) do

            if item_id == sour_item_id then
                stone_cfg = vt
                break
            end
        end

        if stone_cfg then
            break
        end
    end

    if not stone_cfg or stone_cfg.next_id == 0 then
        game.GameMsgCtrl.instance:PushMsg(config.words[1219])
        return
    end

    if not self.stone_advance_view then
        self.stone_advance_view = require("game/foundry/foundry_stone_advance_view").New()
    end
    self.stone_advance_view:Open(sour_item)
end

function FoundryCtrl:OpenCollectView()

    if not self.foundry_collect_view then
        self.foundry_collect_view = require("game/foundry/foundry_collect_view").New(self)
    end
    self.foundry_collect_view:Open()
end

function FoundryCtrl:CsGatherInfo()
    self:SendProtocal(20801,{})
end

function FoundryCtrl:ScGatherInfo(data)
    self.foundry_data:SetGatherData(data)
end

function FoundryCtrl:CsGatherUpgrade()
    self:SendProtocal(20803,{})
end

function FoundryCtrl:ScGatherUpgrade(data)
    self.foundry_data:UpdateGatherLevel(data)
    self:FireEvent(game.FoundryEvent.GatherUpgrade, data)
end

function FoundryCtrl:CsGatherColl(id_t)
    self:SendProtocal(20805,{id = id_t})
end

function FoundryCtrl:ScGatherColl(data)
    self.foundry_data:UpdateGatherVitality(data)
    self:FireEvent(game.FoundryEvent.GatherUpgrade, data)
end

function FoundryCtrl:CsRefineForgeWheel()
    self:SendProtocal(20711,{})
end

function FoundryCtrl:ScRefineForgeWheel(data)
    --结果索引
    local index = data.id

    self:FireEvent(game.FoundryEvent.ScoreRotaty, index)
end

function FoundryCtrl:OpenScoreRotatyView(end_time)

    if not self.foundry_score_roraty_view then
        self.foundry_score_roraty_view = require("game/foundry/foundry_score_roraty_view").New(self)
    end
    self.foundry_score_roraty_view:Open(end_time)
end

function FoundryCtrl:OpenSmeltView()

    if not self.foundry_smelt_view then
        self.foundry_smelt_view = require("game/foundry/foundry_smelt_view").New(self)
    end
    self.foundry_smelt_view:Open()
end

function FoundryCtrl:OpenSmeltSelectView(bag_pos)

    if not self.foundry_smelt_select_view then
        self.foundry_smelt_select_view = require("game/foundry/foundry_smelt_select_view").New(self)
    end
    self.foundry_smelt_select_view:Open(bag_pos)
end

function FoundryCtrl:OpenSmeltSetView()

    if not self.foundry_smelt_set_view then
        self.foundry_smelt_set_view = require("game/foundry/foundry_smelt_set_view").New(self)
    end
    self.foundry_smelt_set_view:Open()
end

function FoundryCtrl:OpenRefineView(index)

    if not self.foundry_refine_view then
        self.foundry_refine_view = require("game/foundry/foundry_refine_view").New(self)
    end
    self.foundry_refine_view:Open(index)
end

--熔炼信息
function FoundryCtrl:CsSmeltInfo()
    self:SendProtocal(42201,{})
end

function FoundryCtrl:ScSmeltInfo(data)
    self.foundry_data:SetSmetlData(data)
    self:FireEvent(game.FoundryEvent.UpdateSmeltInfo, data)
end

--执行熔炼
function FoundryCtrl:CsSmeltDo(post)
    self:SendProtocal(42203,{poses = post})
end

function FoundryCtrl:ScSmeltDo(data)
   self.foundry_data:SetSmetlData(data) 
   self:FireEvent(game.FoundryEvent.UpdateSmeltInfo, data)
end

function FoundryCtrl:OnCommonlyKeyValue(data)
    self.smelt_data = data
end

function FoundryCtrl:GetSmeltData()

    if self.smelt_data and self.smelt_data.key == game.CommonlyKey.SmeltColor then
        return self.smelt_data
    else
        self.smelt_data = {}
        self.smelt_data.key = game.CommonlyKey.SmeltColor
        self.smelt_data.value = 2
        return self.smelt_data
    end
end

function FoundryCtrl:SetSmelData(color)
    self.smelt_data = {}
    self.smelt_data.key = game.CommonlyKey.SmeltColor
    self.smelt_data.value = color

    game.MainUICtrl.instance:SendSetCommonlyKeyValue(game.CommonlyKey.SmeltColor, color)
end

--重楼镶嵌 / 强化
function FoundryCtrl:CsEquipInlayParis(pos_t)
    self:SendProtocal(20215, {pos = pos_t})
end

function FoundryCtrl:ScEquipInlayParis(data)
    self.foundry_data:UpdateEquipParis(data)
    self:FireEvent(game.FoundryEvent.UpdateInlayStren, data)
end

--重楼拆卸
function FoundryCtrl:CsEquipStripParis(pos_t)
    self:SendProtocal(20219, {pos = pos_t})
end

function FoundryCtrl:ScEquipStripParis(data)
    self.foundry_data:UpdateEquipStrip(data)
    self:FireEvent(game.FoundryEvent.UpdateStrip, data)
end

function FoundryCtrl:OpenGodWeaponView(index)
    if self:CheckGetGodweapon() then
        if not self.foundry_godweapon_view then
            self.foundry_godweapon_view = require("game/foundry/foundry_godweapon_view").New(self)
        end
        self.foundry_godweapon_view:Open(index)
    else
        self:OpenGodWeaponCollectView()
    end
end

---神器
function FoundryCtrl:CsArtifactGetInfo()
    self:SendProtocal(52201, {})
end

function FoundryCtrl:ScArtifactGetInfo(data)

    self.foundry_data:SetGodweaponData(data)
    if data.open_ui == 1 then
        self:OpenGodWeaponPreView(true)
    end
    self:FireEvent(game.FoundryEvent.UpdateGodweaponInfo, data)

    self:FireEvent(game.FoundryEvent.GodweaponCollect)
end

--铸造
function FoundryCtrl:CsArtifactAddExtraAttr(pos_t)
    self:SendProtocal(52203, {pos = pos_t})
end

function FoundryCtrl:ScArtifactAddExtraAttr(data)
    self.foundry_data:UpdateGodweaponData(data)
    self:FireEvent(game.FoundryEvent.UpdateGodweaponInfoPos, data)
end

--突破
function FoundryCtrl:CsArtifactLvUp()
    self:SendProtocal(52205, {})
end

function FoundryCtrl:ScArtifactLvUp(data)
    self.foundry_data:UpdateUpgradeData(data)
    self:FireEvent(game.FoundryEvent.UpdateGodweaponTupo, data)
end

--切换幻化
function FoundryCtrl:CsArtifactChangeAvatar(avatar_id_t)
    self:SendProtocal(52207, {avatar_id = avatar_id_t})
end

function FoundryCtrl:ScArtifactChangeAvatar(data)
    self.foundry_data:UpdateHuanhua(data)
    self:FireEvent(game.FoundryEvent.ChangeAvatar, data)
end

function FoundryCtrl:ScArtifactRefreshAvatars(data)
    self.foundry_data:RefreshHuanhua(data)
end

--神器碎片收集
function FoundryCtrl:CsArtifactTakeAward(level)
    self:SendProtocal(52210, {lv = level})
end

function FoundryCtrl:ScArtifactUpdateNew(data)
    self.foundry_data:SetGodweaponChip(data)
    self:FireEvent(game.FoundryEvent.GodweaponCollect)
end

function FoundryCtrl:CsArtifactActivate()
    self:SendProtocal(52212, {})
end

function FoundryCtrl:OpenHideWeaponView(template_index)
    if not self.hideweapon_view then
        self.hideweapon_view = require("game/foundry/foundry_hideweapon_view").New(self)
    end
    self.hideweapon_view:Open(template_index)
end

--暗器总信息
function FoundryCtrl:CsAnqiGetInfo()
    self:SendProtocal(52601, {})
end

function FoundryCtrl:ScAnqiGetInfo (data)
    -- print("-------52602-------") PrintTable(data)
    self.foundry_data:SetHideWeaponData(data)
end

function FoundryCtrl:CsAnqiPractice()
    self:SendProtocal(52603, {})
end

function FoundryCtrl:ScAnqiPractice(data)
    self.foundry_data:UpdateHideweaponPractice(data)
    self:FireEvent(game.FoundryEvent.UpdateHWPractice)
    self:FireEvent(game.FoundryEvent.UpdateHWForge)
    self:FireEvent(game.FoundryEvent.UpdateHWUpgrade)
end

function FoundryCtrl:CsAnqiForge()
    self:SendProtocal(52605, {})
end

function FoundryCtrl:ScAnqiForge(data)
    self.foundry_data:UpdateHWForge(data)
    self:FireEvent(game.FoundryEvent.UpdateHWForge)
    self:FireEvent(game.FoundryEvent.UpdateHWPractice)
    self:FireEvent(game.FoundryEvent.UpdateHWUpgrade)
end

function FoundryCtrl:CsAnqiLvUp()
    self:SendProtocal(52607, {})
end

function FoundryCtrl:ScAnqiLvUp(data)
    self.foundry_data:UpdateHWLvUp(data)
    self:FireEvent(game.FoundryEvent.UpdateHWUpgrade)
end

--切换方案
function FoundryCtrl:CsAnqiChangePlan(plan_t)
    self:SendProtocal(52609, {plan = plan_t})
end

function FoundryCtrl:ScAnqiChangePlan(data)
    self.foundry_data:ChangeHWPlan(data)
    self:FireEvent(game.FoundryEvent.ChangeHWSkillPlan)
end

--解锁方案
function FoundryCtrl:CsAnqiUnlockPlan(plan_t)
    self:SendProtocal(52611, {plan = plan_t})
end

function FoundryCtrl:ScAnqiUnlockPlan(data)
    self.foundry_data:UnlockHWPlan(data)
    self:FireEvent(game.FoundryEvent.UnlockSkillPlan, data)
end

--重洗方案
function FoundryCtrl:CsAnqiRefreshPlan()
    self:SendProtocal(52613, {})
end

function FoundryCtrl:ScAnqiRefreshPlan(data)
    self.foundry_data:RefreshHWPlan(data)
    self:FireEvent(game.FoundryEvent.RefreshSkillPlan)
end

--替换方案
function FoundryCtrl:CsAnqiReplacePlan(plan_t)
    self:SendProtocal(52615, {plan = plan_t})
end

function FoundryCtrl:ScAnqiReplacePlan(data)
    self.foundry_data:ReplaceHWPlan(data)

    self:FireEvent(game.FoundryEvent.ReplaceSkillPlan)
end

--新技能更新
function FoundryCtrl:ScAnqiNewPlanUpdate(data)
    self.foundry_data:UpdateNewSkillOpen(data)
    self:FireEvent(game.FoundryEvent.OpenFirstPlan, data)
end

--开启新的毒孔
function FoundryCtrl:CsAnqiOpenPoisonSlot(index_t)
    self:SendProtocal(52618, {index = index_t})
end

--对毒孔 炼毒
function FoundryCtrl:CsAnqiCreatePoison(index_t)
    self:SendProtocal(52619, {index = index_t})
end

--替换毒孔属性
function FoundryCtrl:CsAnqiReplacePoisonAttr(index_t)
    self:SendProtocal(52620, {index = index_t})
end

function FoundryCtrl:ScAnqiPoisonSlotUpdate(data)

    self.foundry_data:UpdateHWPoisonInfo(data)

    self:FireEvent(game.FoundryEvent.UpdateHWPoison)
end

function FoundryCtrl:OpenHWSkillPreview()

    if not self.hideweapon_skill_preview then
        self.hideweapon_skill_preview = require("game/foundry/foundry_hideweapon_skill_preview").New(self)
    end
    self.hideweapon_skill_preview:Open()
end

function FoundryCtrl:OpenGodWeaponHHAttr()

    if not self.foundry_huanhua_allattr_view then
        self.foundry_huanhua_allattr_view = require("game/foundry/foundry_huanhua_allattr_view").New(self)
    end
    self.foundry_huanhua_allattr_view:Open()
end

function FoundryCtrl:OpenStoneInlayView(stone_pos)
    if not self.foundry_stone_inlay_view then
        self.foundry_stone_inlay_view = require("game/foundry/foundry_stone_inlay_view").New(self)
    end
    self.foundry_stone_inlay_view:Open(stone_pos)
end

function FoundryCtrl:OpenRefineStrenView()
    if not self.refine_stren_view then
        self.refine_stren_view = require("game/foundry/refine_stren_view").New(self)
    end
    self.refine_stren_view:Open()
end

function FoundryCtrl:OpenRefineInlayView()
    if not self.refine_inlay_view then
        self.refine_inlay_view = require("game/foundry/refine_inlay_view").New(self)
    end
    self.refine_inlay_view:Open()
end

function FoundryCtrl:OpenRefineTakeoffView()
    if not self.refine_takeoff_view then
        self.refine_takeoff_view = require("game/foundry/refine_takeoff_view").New(self)
    end
    self.refine_takeoff_view:Open()
end

function FoundryCtrl:OpenRefineUpgradeView()
    if not self.refine_upgrade_view then
        self.refine_upgrade_view = require("game/foundry/refine_upgrade_view").New(self)
    end
    self.refine_upgrade_view:Open()
end

function FoundryCtrl:OpenGodWeaponShowView()
    if not self.foundry_godweapon_showview then
        self.foundry_godweapon_showview = require("game/foundry/foundry_godweapon_showview").New(self)
    end
    self.foundry_godweapon_showview:Open()
end

function FoundryCtrl:OpenHideWeaponShowView()
    if not self.foundry_hideweapon_showview then
        self.foundry_hideweapon_showview = require("game/foundry/foundry_hideweapon_showview").New(self)
    end
    self.foundry_hideweapon_showview:Open()
end

function FoundryCtrl:OpenGodWeaponCollectView()
    if not self.foundry_godweapon_collect_view then
        self.foundry_godweapon_collect_view = require("game/foundry/foundry_godweapon_collect_view").New(self)
    end
    self.foundry_godweapon_collect_view:Open()
end

function FoundryCtrl:OpenGodWeaponPreView(need_show_anim)
    if not self.foundry_godweapon_preview then
        self.foundry_godweapon_preview = require("game/foundry/foundry_godweapon_preview").New(self)
    end
    self.foundry_godweapon_preview:Open(need_show_anim)
end

--1-8位置装备评分比较
function FoundryCtrl:CalEquipOffsetScore(bag_equip_info)

    local wear_equip_score = 0
    local bag_equip_score = 0
    local goods_config = config.goods[bag_equip_info.id]
    local pos = goods_config.pos

    --穿戴评分
    local wear_equip = self:GetEquipInfoByType(pos)
    if wear_equip and wear_equip.id > 0 then
        local goods_config = config.goods[wear_equip.id]
        local base_score = game.Utils.CalculateCombatPower2(goods_config.attr)
        local random_score = game.Utils.CalculateCombatPower2(wear_equip.attr)
        wear_equip_score = base_score + random_score
    end

    --待比较评分
    
    local base_score = game.Utils.CalculateCombatPower2(goods_config.attr)
    local random_score = game.Utils.CalculateCombatPower2(bag_equip_info.attr)
    bag_equip_score = base_score + random_score

    local offset_score = bag_equip_score - wear_equip_score

    return offset_score
end

function FoundryCtrl:CheckGetGodweapon()
    return self.foundry_data:CheckGetGodweapon()
end

function FoundryCtrl:GetGodweaponChipText()
    return self.foundry_data:GetGodweaponChipText()
end

function FoundryCtrl:CheckEquipHd()
    return self.foundry_data:CheckEquipHd()
end

function FoundryCtrl:CheckGodweaponChipHd()
    return self.foundry_data:CheckGodweaponChipHd()
end

function FoundryCtrl:GetEquipCombat(equip_pos)
    return self.foundry_data:GetEquipCombat(equip_pos)
end

function FoundryCtrl:GetStoneMinLvByPos(equip_pos)
    if equip_pos <= 8 then
        return self.foundry_data:GetStoneMinLvByPos(equip_pos)
    elseif equip_pos == 9 then
        return self.foundry_data:GetGodweaponStoneMinLv()
    elseif equip_pos == 10 then
        return self.foundry_data:GetHideweaponStoneMinLv()
    elseif equip_pos == 11 then
        return self.foundry_data:GetWeaponSoulStoneMinLv()
    elseif equip_pos == 12 then
        return self.foundry_data:GetStoneMinLvByPos(12)
    end
end

function FoundryCtrl:GetSmeltLv()
    return self.foundry_data:GetSmeltLv()
end

function FoundryCtrl:GetStrenLv(pos)
    return self.foundry_data:GetStrenLv(pos)
end

game.FoundryCtrl = FoundryCtrl

return FoundryCtrl