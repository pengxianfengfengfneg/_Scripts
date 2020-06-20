local ViewOthersCtrl = Class(game.BaseCtrl)

function ViewOthersCtrl:_init()
    if ViewOthersCtrl.instance ~= nil then
        error("ViewOthersCtrl Init Twice!")
    end
    ViewOthersCtrl.instance = self

    self.view_others_view = require("game/view_others/view_others_view").New()
    self.operate_list = require("game/view_others/operate_list").New()

    self:RegisterAllProtocal()
end

function ViewOthersCtrl:_delete()
    self.view_others_view:DeleteMe()
    self.operate_list:DeleteMe()

    ViewOthersCtrl.instance = nil
end

function ViewOthersCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(40402, "OnViewOthersInfo")
    self:RegisterProtocalCallback(40404, "OnViewGetRoleCommonInfo")
end

function ViewOthersCtrl:SendViewOthersInfo(type, role_id, platform, server_num)
    if role_id ~= game.RoleCtrl.instance:GetRoleId() then
        self:SendProtocal(40401, { type = type, id = role_id, platform = platform, server_num = server_num })
    end
end

function ViewOthersCtrl:OnViewOthersInfo(data)
    if data.type == game.GetViewRoleType.ViewOthers then
        self.operate_list:Open(data)
    end
    if data.type >= 11 and data.type <= 18 then
        local equip_info
        for _, v in pairs(data.info.equips) do
            if v.equip.pos == data.type % 10 then
                if type == 7 then
                    v.equip.mate_name = self.info.marriage.mate_name
                    v.equip.marry_bless = self.info.marriage.bless
                end
                equip_info = v.equip
            end
        end
        if equip_info then
            game.BagCtrl.instance:OpenWearEquipInfoView(equip_info, true)
        end
    end
    if data.type == game.GetViewRoleType.ViewPet then
        local pet_info
        local power = 0
        for _, v in pairs(data.pet_list) do
            local pet_power = game.PetCtrl.instance:CalcFight(v.pet)
            if pet_power > power then
                power = pet_power
                pet_info = v.pet
            end
        end
        if pet_info then
            game.MarketCtrl.instance:OpenPetInfoView(pet_info)
        end
    end
end

function ViewOthersCtrl:SendViewGetRoleCommonInfo(role_id)
    self:SendProtocal(40403, {role_id = role_id})
end

function ViewOthersCtrl:OnViewGetRoleCommonInfo(data)
    self:FireEvent(game.SceneEvent.OnRoleCommonInfo, data)
end

function ViewOthersCtrl:OpenViewOthers(info)
    self.view_others_view:Open(info)
end

game.ViewOthersCtrl = ViewOthersCtrl

return ViewOthersCtrl