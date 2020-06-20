local SceneLogicCatchPet = Class(require("game/scene/scene_logic/scene_logic_base"))

local goods_cfg = config.goods
local image_item = config.sys_config["catch_pet_cost_item"].value

function SceneLogicCatchPet:CreateGather(vo)
    local gather = self.scene:_CreateGather(vo)
    local role_id = game.RoleCtrl.instance:GetRoleId()
    if role_id ~= vo.owner_id then
        gather:SetHudImg(game.HudItem.NamePrefixImg, "9")
    else
        gather:SetHudImg(game.HudItem.NamePrefixImg, "10")
    end
    return gather
end

function SceneLogicCatchPet:CanDoGather()
    if game.PetCtrl.instance:IsFullBag() then
        game.GameMsgCtrl.instance:PushMsg(config.words[1973])
        return false, game.CatchPetCode.FullBag
    end
    local own_num = game.BagCtrl.instance:GetNumById(image_item)
    if own_num < 1 then
        local item_cfg = goods_cfg[image_item]
        local str = string.format(config.words[1500], item_cfg.name)
        local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(str)
        msg_box:SetBtn1(nil, function()
            game.ShopCtrl.instance:OpenViewByShopId(3, image_item)
        end)
        msg_box:SetBtn2(config.words[101])
        msg_box:Open()
        return false, game.CatchPetCode.LackRope
    end
    return true
end

function SceneLogicCatchPet:IsShowLogicTaskCom()
    return true
end

function SceneLogicCatchPet:CanDoCrossOperate()
    
    return true
end

return SceneLogicCatchPet
