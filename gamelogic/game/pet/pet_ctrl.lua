local PetCtrl = Class(game.BaseCtrl)

local _star_range = config.pet_common.star_range
local _cfg_pet = config.pet
local _probability = config.pet_common.bubble_probability

function PetCtrl:_init()
    if PetCtrl.instance ~= nil then
        error("PetCtrl Init Twice!")
    end
    PetCtrl.instance = self

    self.pet_view = require("game/pet/pet_view").New(self)
    self.pet_data = require("game/pet/pet_data").New(self)
    self.pet_rename_view = require("game/pet/pet_rename_view").New(self)

    self.skill_commend_view = require("game/pet/skill_commend_view").New(self)
    self.neidan_commend_view = require("game/pet/neidan_commend_view").New(self)
    self.skill_preview = require("game/pet/pet_skill_preview").New(self)
    self.pet_handbook_view = require("game/pet/pet_handbook_view").New(self)
    self.pet_quality_view = require("game/pet/pet_quality_view").New(self)
    self.pet_storage_view = require("game/pet/pet_storage_view").New(self)
    self.pet_breed_view = require("game/pet/pet_breed_view").New(self)
    self.pet_hire_breed_view = require("game/pet/pet_hire_breed_view").New(self)
    self.skill_learn_view = require("game/pet/skill_learn_view").New(self)
    self.pet_egg_view = require("game/pet/pet_egg_view").New(self)
    self.pet_get_view = require("game/pet/pet_get_view").New(self)
    self.pet_zhenfa_view = require("game/pet/pet_zhenfa_view").New(self)
    self.skill_upgrade_view = require("game/pet/skill_upgrade_view").New(self)
    self.skill_senior_view = require("game/pet/skill_senior_view").New(self)
    self.neidan_append_view = require("game/pet/neidan_append_view").New(self)
    self.free_tip_view = require("game/pet/free_tip_view").New(self)
    self.neidan_upgrade_view = require("game/pet/neidan_upgrade_view").New(self)
    self.skill_suit_view = require("game/pet/skill_suit_view").New(self)
    self.pet_inherit_preview = require("game/pet/pet_inherit_preview").New(self)
    self.skill_super_view = require("game/pet/skill_super_view").New(self)
    self.lucky_view = require("game/pet/lucky_view").New(self)
    self.god_pet_call_view = require("game/pet/god_pet_call_view").New(self)
    self.god_pet_awake_view = require("game/pet/god_pet_awake_view").New(self)
    self.pet_team_breed_view = require("game/pet/pet_team_breed_view").New(self)
    self.pet_attr_view = require("game/pet/pet_attr_view").New(self)
    self.pet_train_view = require("game/pet/pet_train_view").New(self)
    self.pet_inherit_view = require("game/pet/pet_inherit_view").New(self)
    self.pet_futi_view = require("game/pet/pet_futi_view").New(self)

    self:BindEvent(game.LoginEvent.LoginRoleRet, function(value)
        if value then
            self:SendPetInfo()
            self:SendGetPetStorage()
            self:SendHatchInfo()
            self:SendAttachInfo()
            self:SendGetLucky()

            self.random_text_time = global.Time.now_time
            self.condition_text_time = global.Time.now_time
        end
    end)

    self:BindEvent(game.SceneEvent.MainRolePetHpChange, function(percent, hp)
        self:SynBattlePetHP(hp)
    end)

    self:RegisterAllProtocal()

    global.Runner:AddUpdateObj(self, 2)
end

function PetCtrl:_delete()
    self.random_text_time = nil
    self.condition_text_time = nil
    global.Runner:RemoveUpdateObj(self)

    self.pet_view:DeleteMe()
    self.pet_data:DeleteMe()
    self.pet_rename_view:DeleteMe()

    self.skill_commend_view:DeleteMe()
    self.neidan_commend_view:DeleteMe()
    self.skill_preview:DeleteMe()
    self.pet_handbook_view:DeleteMe()
    self.pet_quality_view:DeleteMe()
    self.pet_storage_view:DeleteMe()
    self.pet_breed_view:DeleteMe()
    self.pet_hire_breed_view:DeleteMe()
    self.skill_learn_view:DeleteMe()
    self.pet_egg_view:DeleteMe()
    self.pet_get_view:DeleteMe()
    self.pet_zhenfa_view:DeleteMe()
    self.skill_upgrade_view:DeleteMe()
    self.skill_senior_view:DeleteMe()
    self.neidan_append_view:DeleteMe()
    self.free_tip_view:DeleteMe()
    self.neidan_upgrade_view:DeleteMe()
    self.skill_suit_view:DeleteMe()
    self.pet_inherit_preview:DeleteMe()
    self.skill_super_view:DeleteMe()
    self.lucky_view:DeleteMe()
    self.god_pet_call_view:DeleteMe()
    self.god_pet_awake_view:DeleteMe()
    self.pet_team_breed_view:DeleteMe()
    self.pet_attr_view:DeleteMe()
    self.pet_train_view:DeleteMe()
    self.pet_inherit_view:DeleteMe()
    self.pet_futi_view:DeleteMe()

    PetCtrl.instance = nil
    game.PetView.instance = nil
end

function PetCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(41002, "OnPetInfo")
    self:RegisterProtocalCallback(41004, "OnPetStorage")
    self:RegisterProtocalCallback(41008, "OnPetChange")
    self:RegisterProtocalCallback(41009, "OnPetDelete")
    self:RegisterProtocalCallback(41011, "OnPetStorageChange")
    self:RegisterProtocalCallback(41019, "OnPetSavvy")
    self:RegisterProtocalCallback(41020, "OnPetWash")
    self:RegisterProtocalCallback(41022, "OnHatchInfo")
    self:RegisterProtocalCallback(41024, "OnHatchPanel")
    self:RegisterProtocalCallback(41034, "OnGetLucky")
    self:RegisterProtocalCallback(41052, "OnAttachInfo")
    self:RegisterProtocalCallback(41058, "OnAttachChange")
    self:RegisterProtocalCallback(41074, "OnPetExpChange")
end

function PetCtrl:OpenView()
    self.pet_view:Open()
end

function PetCtrl:SendPetInfo()
    self:SendProtocal(41001)
end

function PetCtrl:OpenRenameView(info)
    self.pet_rename_view:Open(info)
end

function PetCtrl:OnPetInfo(data_list)
    self.pet_data:SetPetInfo(data_list.pet_list)

    self:FireEvent(game.PetEvent.OnPetInfo)
end

function PetCtrl:SendGetPetStorage()
    self:SendProtocal(41003)
end

function PetCtrl:OnPetStorage(data)
    self.pet_data:SetStorage(data)
end

function PetCtrl:GetPetStorage()
    return self.pet_data:GetStorage()
end

function PetCtrl:SendPetActive(id)
    -- 道具ID
    self:SendProtocal(41007, { goods_id = id })
end

function PetCtrl:OnPetChange(data_list)
    self.pet_data:PetChange(data_list)
end

function PetCtrl:OnPetDelete(data_list)
    if data_list.type == 1 then
        self.pet_data:DeleteBagPet(data_list.grids)
        self:FireEvent(game.PetEvent.BagPetDelete, data_list.grids)
    elseif data_list.type == 2 then
        self.pet_data:DeleteStoragePet(data_list.grids)
        self:FireEvent(game.PetEvent.StoragePetDelete, data_list.grids)
    end
end

function PetCtrl:OnPetStorageChange(data_list)
    self.pet_data:StorageChange(data_list.dpets)
    self:FireEvent(game.PetEvent.StorageChange, data_list.dpets)
end

function PetCtrl:SendFreePet(id)
    self:SendProtocal(41012, { grid = id })
end

function PetCtrl:SendOutStorage(id)
    self:SendProtocal(41013, { grid = id })
end

function PetCtrl:SendInStorage(id)
    self:SendProtocal(41014, { grid = id })
end

function PetCtrl:SendSavvy(id)
    self:SendProtocal(41010, { grid = id })
end

function PetCtrl:SendWash(id)
    self:SendProtocal(41015, { grid = id })
end

function PetCtrl:SendInherit(id1, id2, type)
    -- 继承类型 1:悟性 2:技能 3:同时
    self:SendProtocal(41016, { material = id1, target = id2, type = type })
end

function PetCtrl:SendHatchInfo()
    self:SendProtocal(41021)
end

function PetCtrl:OnHatchInfo(data_list)
    self.pet_data:SetHatchInfo(data_list)
    -- 0:未孵化, 1:正操作 2:正孵化  3:可领取
    if data_list.stat == 2 then
        self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, 1005)
        self:CloseBreedView()
        if self.last_stat == 1 or self.last_stat == 0 then
            self:OpenPetEggView()
        end
    elseif data_list.stat == 1 and self:BreedViewIsOpen() == false then
        -- 重登后取消上次有繁殖操作
        self:SendCancelHatch()
    elseif data_list.stat == 3 then
        self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, 1006)
    end
    self.last_stat = data_list.stat
    self:FireEvent(game.PetEvent.HatchInfo, data_list)
end

function PetCtrl:GetHatchInfo()
    return self.pet_data:GetHatchInfo()
end

function PetCtrl:SetHireBreed(val)
    self.hire_breed = val
end

function PetCtrl:SendHatchType(type)
    -- 1:单人孵化  2:组队孵化
    if type == 2 then
        if game.MakeTeamCtrl.instance:HasTeam() == false then
            game.GameMsgCtrl.instance:PushMsg(config.words[5001])
            return
        end
        local role_id = game.RoleCtrl.instance:GetRoleId()
        if game.MakeTeamCtrl.instance:IsLeader(role_id) == false then
            game.GameMsgCtrl.instance:PushMsg(config.words[5012])
            return
        end
    end
    local info = self:GetHatchInfo()
    if info.stat == 3 or info.stat == 2 then
        -- 先领取宠物
        game.GameMsgCtrl.instance:PushMsg(config.words[1543])
        self:OpenPetEggView()
        return
    end
    self:SendProtocal(41023, { type = type })
end

function PetCtrl:OnHatchPanel(data)
    self.pet_data:SetHatchPanel(data)
    if data.hatch_id == 0 then
        self:CloseBreedView()
    else
        if data.type == 2 then
            if self.pet_team_breed_view:IsOpen() then
                self.pet_team_breed_view:UpdateMemberPet(data.pet_babies)
            else
                self.pet_team_breed_view:Open(data.pet_babies)
            end
        elseif data.type == 1 then
            if self.hire_breed then
                self:OpenHireBreedView()
            else
                self:OpenBreedView()
            end
        end
    end
    self.team_breed = false
end

function PetCtrl:SendCancelHatch()
    local id = self.pet_data:GetHatchID()
    self:SendProtocal(41025, { hatch_id = id })
end

function PetCtrl:SendSelectHatchPet(pet)
    local id = self.pet_data:GetHatchID()
    self:SendProtocal(41026, {hatch_id = id, pet_grid = pet})
end

function PetCtrl:SendCancelSelectHatchPet()
    local id = self.pet_data:GetHatchID()
    self:SendProtocal(41027, { hatch_id = id })
end

function PetCtrl:SendLockHatchPet()
    local id = self.pet_data:GetHatchID()
    self:SendProtocal(41028, { hatch_id = id })
end

function PetCtrl:SendUnlockHatchPet()
    local id = self.pet_data:GetHatchID()
    self:SendProtocal(41029, { hatch_id = id })
end

function PetCtrl:SendStartHatch()
    local id = self.pet_data:GetHatchID()
    self:SendProtocal(41030, { hatch_id = id })
end

function PetCtrl:SendHatchSelf(ids)
    local id = self.pet_data:GetHatchID()
    self:SendProtocal(41031, { hatch_id = id, grids = ids })
end

function PetCtrl:SendGetHatchPet()
    local id = self.pet_data:GetHatchID()
    self:SendProtocal(41035, { hatch_id = id })
end

function PetCtrl:SendLearnSkill(id, grid, skill_id)
    self:SendProtocal(41041, { pet_grid = id, skill_grid = grid, skill_id = skill_id })
end

function PetCtrl:SendForgetSkill(id, grid)
    self:SendProtocal(41042, { pet_grid = id, skill_grid = grid })
end

function PetCtrl:SendUpgradeSkill(id, grid, num)
    self:SendProtocal(41043, { pet_grid = id, skill_grid = grid, stone_num = num })
end

--珍兽出战接口
function PetCtrl:SendFight(id)
    self:SendProtocal(41017, { grid = id })
end

function PetCtrl:SendRest()
    self:SendProtocal(41018)
end

function PetCtrl:SendAttachInfo()
    self:SendProtocal(41051)
end

function PetCtrl:OnAttachInfo(data)
    self.pet_data:SetAttachInfo(data.attach_list)
end

function PetCtrl:GetAttachInfo()
    return self.pet_data:GetAttachInfo()
end

function PetCtrl:SendPetAttack(id, pet)
    local pet_info = self:GetPetInfoById(pet)
    if pet_info then
        local pet_cfg = _cfg_pet[pet_info.cid]
        if pet_cfg.quality == 2 or pet_cfg.carry_lv >= config.internal_hole[8] then
            self:SendProtocal(41053, { attach_id = id, pet_grid = pet })
        else
            local str = string.format(config.words[1484], config.internal_hole[8])
            local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(str)
            tips_view:SetBtn1(nil, function()
                self:SendProtocal(41053, { attach_id = id, pet_grid = pet })
            end)
            tips_view:SetBtn2(config.words[101])
            tips_view:Open()
        end
    end
end

function PetCtrl:SendPetUnAttach(id)
    local str = string.format(config.words[1485], config.pet_zhenfa[id].name)
    local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(str)
    tips_view:SetBtn1(nil, function()
        self:SendProtocal(41054, { attach_id = id })
    end)
    tips_view:SetBtn2(config.words[101])
    tips_view:Open()
end

function PetCtrl:SendSetNeidan(zhenfa, grid, neidan)
    self:SendProtocal(41055, { attach_id = zhenfa, internal_grid = grid, internal = neidan })
end

function PetCtrl:SendUpgradeNeidan(zhenfa, grid)
    self:SendProtocal(41056, { attach_id = zhenfa, internal_grid = grid })
end

function PetCtrl:SendRemoveNeidan(zhenfa, grid)
    self:SendProtocal(41057, { attach_id = zhenfa, internal_grid = grid })
end

function PetCtrl:OnAttachChange(data)
    self.pet_data:AttachInfoChange(data.attach)
    self:FireEvent(game.PetEvent.AttachChange, data.attach)
end

function PetCtrl:GetAttach(id)
    return self.pet_data:GetAttach(id)
end

function PetCtrl:SendPetRename(id, new_name)
    self:SendProtocal(41071, { grid = id, name = new_name })
end

function PetCtrl:OnPetSavvy(data)
    self:FireEvent(game.PetEvent.Savvy, data)
end

function PetCtrl:OnPetWash(data)
    self:FireEvent(game.PetEvent.Wash, data)
end

function PetCtrl:GetPetInfo()
    return self.pet_data:GetPetInfo()
end

function PetCtrl:GetPetInfoById(id)
    return self.pet_data:GetPetInfoById(id)
end

function PetCtrl:OpenHandbookView()
    self.pet_handbook_view:Open()
end

function PetCtrl:OpenCommendView()
    self.skill_commend_view:Open()
end

function PetCtrl:OpenSkillPreview()
    self.skill_preview:Open()
end

function PetCtrl:OpenQualityView(info)
    self.pet_quality_view:Open(info)
end

function PetCtrl:OpenStorageView()
    self.pet_storage_view:Open()
end

function PetCtrl:OpenBreedView()
    self.pet_breed_view:Open()
end

function PetCtrl:GetBreedView()
    return self.pet_breed_view
end

function PetCtrl:OpenHireBreedView()
    self.pet_hire_breed_view:Open()
end

function PetCtrl:CloseBreedView()
    self.pet_breed_view:Close()
    self.pet_hire_breed_view:Close()
    self.pet_team_breed_view:Close()
end

function PetCtrl:BreedViewIsOpen()
    return self.pet_breed_view:IsOpen() and self.pet_hire_breed_view:IsOpen() and self.pet_team_breed_view:IsOpen()
end

function PetCtrl:OpenSkillLearnView(pet, grid)
    self.skill_learn_view:Open(pet, grid)
end

function PetCtrl:OpenPetEggView()
    self.pet_egg_view:Open()
end

function PetCtrl:ClosePetEggView()
    self.pet_egg_view:Close()
end

function PetCtrl:OpenPetGetView(info)
    if not self.pet_egg_view:IsOpen() then
        self.pet_get_view:Open(info)
    end
end

function PetCtrl:ClosePetView()
    self.pet_view:Close()
end

function PetCtrl:OpenNeidanCommendView()
    self.neidan_commend_view:Open()
end

function PetCtrl:OpenZhenFaView(info)
    self.pet_zhenfa_view:Open(info)
end

function PetCtrl:OpenSkillUpgradeView(pet, skill)
    self.skill_upgrade_view:Open(pet, skill)
end

function PetCtrl:OpenSkillSeniorView(pet, skill)
    self.skill_senior_view:Open(pet, skill)
end

function PetCtrl:OpenSkillSuperView(pet, skill)
    self.skill_super_view:Open(pet, skill)
end

function PetCtrl:OpenNeidanAppendView(zhenfa, grid)
    self.neidan_append_view:Open(zhenfa, grid)
end

function PetCtrl:OpenFreeView(pet)
    self.free_tip_view:Open(pet)
end

function PetCtrl:OpenNeidanUpgradeView(zhenfa, grid)
    self.neidan_upgrade_view:Open(zhenfa, grid)
end

function PetCtrl:OpenSkillSuitView(pet)
    self.skill_suit_view:Open(pet)
end

function PetCtrl:OpenInheritPreview(pet1, pet2, savvy, skill)
    self.pet_inherit_preview:Open(pet1, pet2, savvy, skill)
end

function PetCtrl:SendGetLucky()
    self:SendProtocal(41033)
end

function PetCtrl:OnGetLucky(data)
    self.pet_data:SetLucky(data.lucky)
end

function PetCtrl:GetLucky()
    return self.pet_data:GetLucky()
end

function PetCtrl:OpenLuckyView()
    self.lucky_view:Open()
end

function PetCtrl:OpenGodPetCallView()
    self.god_pet_call_view:Open()
end

function PetCtrl:OpenGodPetAwakeView()
    self.god_pet_awake_view:Open()
end

function PetCtrl:SendCallGodPet(id)
    self:SendProtocal(41072, { pet_cid = id })
end

function PetCtrl:SendAwakeGodPet(id)
    self:SendProtocal(41073, { pet_grid = id })
end

function PetCtrl:OpenPetAttrView(pet_info, idx)
    if pet_info then
        self.pet_attr_view:Open(pet_info, idx)
    end
end

function PetCtrl:OpenPetTrainView(pet_info, idx)
    if pet_info then
        self.pet_train_view:Open(pet_info, idx)
    end
end

function PetCtrl:OpenPetInheritView()
    self.pet_inherit_view:Open()
end

function PetCtrl:OpenPetFutiView()
    self.pet_futi_view:Open()
end

function PetCtrl:GetGridByPetId(pet_id)
    return self.pet_data:GetGridByPetId(pet_id)
end

function PetCtrl:GetPetNum(pet_id)
    return self.pet_data:GetPetNum(pet_id)
end

local config_skill = config.skill
local config_combat_power_battle = config.combat_power_battle
function PetCtrl:CalcFight(pet_info)
    local fight = 0

    for _, v in pairs(pet_info.bt_attr) do
        fight = fight + v.value * config_combat_power_battle[v.type].pet
    end

    for _, v in pairs(pet_info.skills) do
        fight = fight + config_skill[v.id][v.lv].power
    end

    return math.floor(fight)
end

function PetCtrl:GetFightingPet()
    local pet_info = self:GetPetInfo()
    if pet_info == nil then
        return nil
    end
    local fight_pet_info = pet_info[1]
    if fight_pet_info and fight_pet_info.pet.stat == 5 then
        return fight_pet_info.pet
    end

    return nil
end

function PetCtrl:GetPetModel(info)
    local pet_cfg = _cfg_pet[info.cid or info.pet_cid]
    if pet_cfg.quality == 2 then
        if info.awaken ~= nil then
            return pet_cfg.model_id[info.awaken + 1]
        else
            return  pet_cfg.model_id[1]
        end
    else
        for i, v in ipairs(_star_range) do
            if info.star >= v[1] and info.star <= v[2] then
                return pet_cfg.model_id[i]
            end
        end
    end
end

function PetCtrl:GetPetIcon(info)
    local pet_cfg = _cfg_pet[info.cid]
    if pet_cfg.quality == 2 then
        if info.awaken ~= nil then
            return pet_cfg.icon[info.awaken + 1]
        else
            return  pet_cfg.icon[1]
        end
    else
        for i, v in ipairs(_star_range) do
            if info.star >= v[1] and info.star <= v[2] then
                return pet_cfg.icon[i]
            end
        end
    end
end

function PetCtrl:GetPetMainIcon(info)
    local pet_cfg = _cfg_pet[info.pet_cid]
    if pet_cfg.quality == 2 then
        if info.awaken ~= nil then
            return pet_cfg.main_icon[info.awaken + 1]
        else
            return  pet_cfg.main_icon[1]
        end
    else
        for i, v in ipairs(_star_range) do
            if info.star >= v[1] and info.star <= v[2] then
                return pet_cfg.main_icon[i]
            end
        end
    end
end

function PetCtrl:GetBaby(id)
    local pet_list = self:GetPetInfo()
    local baby_list = {}
    for _, v in pairs(pet_list) do
        if id == v.pet.cid and v.pet.star == 0 and v.pet.stat == 0 then
            table.insert(baby_list, v.pet)
        end
    end
    return baby_list
end

function PetCtrl:SynBattlePetHP(hp)
    local pet_list = self:GetPetInfo()
    for _, v in pairs(pet_list) do
        if v.pet.stat == 5 then
            v.pet.hp = hp
            break
        end
    end
end

function PetCtrl:OnPetExpChange(data)
    local pet_list = self:GetPetInfo()
    for _, v in pairs(pet_list) do
        if v.pet.stat == 5 then
            v.pet.level = data.level
            v.pet.exp = data.exp
            break
        end
    end
    self:FireEvent(game.PetEvent.ExpChange, data)

    local desc = nil
    if data.dl_exp > 0 then
        desc = string.format(config.words[1577], data.add_exp - data.dl_exp, data.dl_exp)
    else
        desc = string.format(config.words[1575], data.add_exp)
    end

    local info = {
        desc = desc,
        is_chat = true,
    }
    game.GameMsgCtrl.instance:PushMsg({info})
end

function PetCtrl:Update(now_time)
    local main_role = game.Scene.instance:GetMainRole()
    local pet_info = self:GetFightingPet()
    if main_role and not main_role:IsDead() and pet_info and self.condition_text_time then
        local pet_obj = main_role:GetPet()
        if pet_obj and not pet_obj:IsDead() then
            local hp_per = main_role:GetHpPercent()
            if hp_per < 0.1 and now_time > self.condition_text_time then
                self.condition_text_time = now_time + 60
                self.random_text_time = now_time + 60
                local text = _cfg_pet[pet_info.cid].condition_text
                local index = math.random(#text)
                if text[index] then
                    pet_obj:SetSpeakBubble(_cfg_pet[pet_info.cid].condition_text[index])
                end
            end

            if now_time > self.random_text_time then
                self.random_text_time = now_time + 60
                local text = _cfg_pet[pet_info.cid].random_text
                local index = math.random(math.ceil(#text / _probability))
                if text[index] then
                    pet_obj:SetSpeakBubble(_cfg_pet[pet_info.cid].random_text[index])
                end
            end
        end
    end
end

local _et = {}
local carry_pet_num = config.pet_common.carry_pet_num
function PetCtrl:IsFullBag()
    local pet_info = self:GetPetInfo() or _et
    return #pet_info >= carry_pet_num
end

game.PetCtrl = PetCtrl

return PetCtrl