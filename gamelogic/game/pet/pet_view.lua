local PetView = Class(game.BaseView)

local type_image = { "zs_wai", "zs_nei", "zs_ping" }
local gen_type = { "zs_01", "zs_02", "zs_03" }

function PetView:_init(ctrl)
    PetView.instance = self
    self._package_name = "ui_pet"
    self._com_name = "pet_view"
    self._show_money = true

    self.ctrl = ctrl
end

function PetView:OpenViewCallBack()
    self:InitBg()
    self:InitBtns()
    self:InitPetList()
    self:InitModel()
    self:RegisterAllEvents()

    self.pet_power = self._layout_objs["role_fight_com/txt_fight"]
    self._layout_objs["role_fight_com/btn_look"]:SetVisible(false)

    self:SetPetList()
end

function PetView:CloseViewCallBack()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function PetView:RegisterAllEvents()
    local events = {
        {
            game.PetEvent.PetChange,
            function(data)
                if self.cur_select_pet and data.grid == self.cur_select_pet.grid then
                    self:SetPetInfo(data)
                end
            end
        },
        {
            game.PetEvent.PetAdd,
            function()
                self:SetPetList()
            end
        },
        {
            game.PetEvent.BagPetDelete,
            function()
                self:SetPetList()
            end
        },

    }
    for _, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function PetView:InitBtns()
    self._layout_objs.btn_rename:AddClickCallBack(function()
        if self.cur_select_pet then
            self.ctrl:OpenRenameView(self.cur_select_pet)
        end
    end)

    self._layout_objs.btn_battle:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_pet/pet_view/btn_battle"})
        if self.cur_select_pet then
            local role_lv = game.RoleCtrl.instance:GetRoleLevel()   --获取自身等级
            local pet_cfg = config.pet[self.cur_select_pet.cid]     --获取珍兽信息
            if role_lv >= pet_cfg.carry_lv then                     --自身等级大于珍兽等级
                local main_role = game.Scene.instance:GetMainRole()
                if main_role then
                    if main_role:CanDoCallPet() then
                        main_role:DoCallPet(self.cur_select_pet.grid)
                    else
                        game.GameMsgCtrl.instance:PushMsg(config.words[1116])
                    end
                end
            else
                game.GameMsgCtrl.instance:PushMsg(config.words[1549])
            end
        end
    end)

    self._layout_objs.btn_split:AddClickCallBack(function()
        if self.cur_select_pet then
            local zhenfa_id
            local attach_info = self.ctrl:GetAttachInfo()
            for _, v in pairs(attach_info) do
                if v.attach.pet_grid == self.cur_select_pet.grid then
                    zhenfa_id = v.attach.attach_id
                    break
                end
            end
            if zhenfa_id then
                self.ctrl:SendPetUnAttach(zhenfa_id)
            end
        end
    end)

    self._layout_objs.btn_rest:SetVisible(false)
    self._layout_objs.btn_rest:AddClickCallBack(function()
        self.ctrl:SendRest()
    end)

    self._layout_objs.btn_tip:AddClickCallBack(function()
        if self.cur_select_pet then
            self.ctrl:OpenSkillSuitView(self.cur_select_pet)
        end
    end)
    self._layout_objs.btn_breed:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        local npc_id = config.pet_common.hatch_npc[1]
        if main_role then
            self.ctrl:ClosePetView()
            main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
        end
    end)

    self._layout_objs.btn_attr:AddClickCallBack(function()
        self.ctrl:OpenPetAttrView(self.cur_select_pet)
    end)

    self._layout_objs.btn_train:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_pet/pet_view/btn_train"})
        self.ctrl:OpenPetTrainView(self.cur_select_pet)
    end)

    self._layout_objs.btn_inherit:AddClickCallBack(function()
        self.ctrl:OpenPetInheritView()
    end)

    self._layout_objs.btn_futi:AddClickCallBack(function()
        self.ctrl:OpenPetFutiView()
    end)

    self._layout_objs.btn_book:AddClickCallBack(function()
        self.ctrl:OpenHandbookView()
    end)

    --珍兽仓库面板
    self._layout_objs.btn_storage:AddClickCallBack(function()
        self.ctrl:OpenStorageView()
    end)

    self._layout_objs.btn_awaken:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        local npc_id = config.pet_common.awaken_npc[1]
        if main_role then
            main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
            self.ctrl:ClosePetView()
        end
    end)

    local catch_scene_id = config.sys_config.scene_pet_catch_show.value
    self._layout_objs.btn_catch:SetText(string.format(config.words[1468], config.scene[catch_scene_id].name))
    self._layout_objs.btn_catch:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:GetOperateMgr():DoChangeScene(catch_scene_id)
            self.ctrl:ClosePetView()
        end
    end)

    local btn_list = {"btn_attr", "btn_train", "btn_inherit", "btn_futi", "btn_book"}
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local pos = 20
    for i = 1, 5 do
        if role_lv >= config.func[3100 + i].show_lv[1] then
            self._layout_objs[btn_list[i]]:SetVisible(true)
            self._layout_objs[btn_list[i]]:SetPositionX(pos)
            pos = pos + 140
        else
            self._layout_objs[btn_list[i]]:SetVisible(false)
        end
    end

    --放生UI
    self._layout_objs.btn_free:AddClickCallBack(function()
        if self.cur_select_pet then
            self.ctrl:OpenFreeView(self.cur_select_pet)
        end
    end)
end

function PetView:SetPetInfo(info)
    self.cur_select_pet = info
    self._layout_objs.group_null:SetVisible(info == nil)
    self._layout_objs.group_btn:SetVisible(info ~= nil)
    self._layout_objs.group_info:SetVisible(info ~= nil)
    self._layout_objs.top_info:SetVisible(info ~= nil)
    if info then
        self._layout_objs.btn_battle:SetVisible(info.stat == 0)
        self._layout_objs.btn_split:SetVisible(info.stat == 2)
        self._layout_objs.btn_rest:SetVisible(info.stat == 5)
        self.list:Foreach(function(obj)
            local item_info = obj:GetItemInfo()
            if item_info then
                obj:SetSelect(item_info.grid == info.grid)
            end
        end)

        self._layout_objs.level:SetText(info.level .. config.words[1217])
        self._layout_objs.name:SetText(info.name)
        for i = 1, 9 do
            self._layout_objs["star" .. i]:SetVisible(info.star >= i)
        end
        local pet_cfg = config.pet[info.cid]
        self._layout_objs.type:SetSprite("ui_common", type_image[pet_cfg.type])
        local pet_type = gen_type[1]
        if pet_cfg.quality == 2 then
            pet_type = gen_type[3]
        elseif info.star == 0 then
            pet_type = gen_type[2]
        end
        self._layout_objs.gen_type:SetSprite("ui_common", pet_type)

        self._layout_objs.carry_level:SetText(pet_cfg.carry_lv .. config.words[1217])
        self._layout_objs.grow:SetText(config.words[1520 + info.growup_lv] .. info.growup_rate)
        local color = cc.GoodsColor[info.growup_lv]
        self._layout_objs.grow:SetColor(color.x, color.y, color.z, color.w)
        self.pet_scale = pet_cfg.scale
        self.pet_height = pet_cfg.height
        self.model:SetModel(game.ModelType.Body, self.ctrl:GetPetModel(info))
        self.show_effect = pet_cfg.show_effect
        if pet_cfg.show_effect ~= "" then
            self.model:PlayAnim(game.ObjAnimName.Show1)
        else
            self.model:PlayAnim(game.ObjAnimName.Idle)
        end
        self._layout_objs.btn_breed:SetVisible(info.star == 0 and pet_cfg.quality ~= 2)
        self._layout_objs.awake_text:SetVisible(pet_cfg.quality == 2)
        self._layout_objs.awake_lv:SetVisible(pet_cfg.quality == 2)
        self._layout_objs.awake_lv:SetText(info.awaken .. "/3")
        self._layout_objs.btn_awaken:SetVisible(pet_cfg.quality == 2 and info.awaken < 3)

        local skill_suit = {}
        for _, v in pairs(info.skills) do
            for j = 1, v.lv do
                if skill_suit[j] then
                    skill_suit[j] = skill_suit[j] + 1
                else
                    skill_suit[j] = 1
                end
            end
        end
        local suit_lv = 0
        for _, v in ipairs(config.pet_skill_suit_cond) do
            if skill_suit[v.level] and skill_suit[v.level] >= v.num then
                suit_lv = v.suit_lv
            end
        end
        self._layout_objs.num_text:SetText(suit_lv)
        self.pet_power:SetText(self:CalcFight(info))
    else
        self:Reset()
    end
end

function PetView:InitPetList()
    self.list = self:CreateList("list", "game/pet/item/pet_icon_item")

    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.pet_list[idx]
        if info then
            item:SetItemInfo(info.pet)
        else
            item:ResetItem()
        end
    end)
    self.list:AddClickItemCallback(function(obj)
        local info = obj:GetItemInfo()
        if info then
            if self.cur_select_pet and self.cur_select_pet.grid == info.grid then
                return
            end
            self:SetPetInfo(info)
        end
    end)
    self.list:AddScrollEndCallback(function(perX)
        self._layout_objs.left:SetVisible(perX > 0)
        self._layout_objs.right:SetVisible(perX < 1)
    end)
end

function PetView:SetPetList()
    self.pet_list = game.PetCtrl.instance:GetPetInfo()

    table.sort(self.pet_list, function(a, b)
        if a.pet.stat == b.pet.stat then
            if a.pet.stat == 0 then
                if a.pet.star * b.pet.star == 0 then
                    return a.pet.star > b.pet.star
                else
                    return self:CalcFight(a.pet) > self:CalcFight(b.pet)
                end
            else
                return self:CalcFight(a.pet) > self:CalcFight(b.pet)
            end
        else
            return a.pet.stat > b.pet.stat
        end
    end)
    self.list:SetItemNum(10)
    if self.pet_list and #self.pet_list > 0 then
        self:SetPetInfo(self.pet_list[1].pet)
    else
        self:SetPetInfo()
    end
end

function PetView:InitBg()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1654])
end

function PetView:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.wrapper, game.BodyType.Monster)
    self.model:SetModelChangeCallBack(function()
        if self.tween then
            self.tween:Kill(false)
            self.tween = nil
        end
        self.model:SetRotation(0, 140, 0)
        self.model:SetPosition(0, 0 - self.pet_height, 3.7)
        self.model:SetScale(self.pet_scale)
        if self.show_effect ~= "" then
            self.model:SetEffect(game.ModelNodeName.Root, self.show_effect, game.ModelType.Body)
            local anim_cfg = game.AnimMgr:GetAnimConfig(game.BodyType.Monster, self.ctrl:GetPetModel(self.cur_select_pet))
            self.tween = DOTween.Sequence()
            self.tween:AppendInterval(anim_cfg.show1)
            self.tween:AppendCallback(function()
                self.model:PlayAnim(game.ObjAnimName.Idle)
            end)
            self.tween:SetAutoKill(false)
        end
    end)
end

function PetView:Reset()
    self._layout_objs.level:SetText("")
    self._layout_objs.name:SetText("")
    for i = 1, 9 do
        self._layout_objs["star" .. i]:SetVisible(false)
    end
    self._layout_objs.level:SetText("")
    self._layout_objs.grow:SetText("")
    self.pet_power:SetText(0)
    self._layout_objs.carry_level:SetText("")
    self._layout_objs.awake_text:SetVisible(false)
    self._layout_objs.awake_lv:SetVisible(false)
    self._layout_objs.num_text:SetText(0)
end

function PetView:CalcFight(pet_info)
    return self.ctrl:CalcFight(pet_info)
end

--显示仓库UI
function PetView:Storage(IsShow)
    if IsShow then
        self._layout_objs.btn_storage:SetEnable(true)
    else
        self._layout_objs.btn_storage:SetEnable(false)
    end
end

function PetView:Free(IsShow)
    if IsShow then
        self._layout_objs.btn_free:SetEnable(true)
    else
        self._layout_objs.btn_free:SetEnable(false)
    end
end

function PetView:Battle(IsShow)
    if IsShow then
        self._layout_objs.btn_battle:SetVisible(true)
    else
        self._layout_objs.btn_battle:SetVisible(false)
    end
end

game.PetView = PetView

return PetView
