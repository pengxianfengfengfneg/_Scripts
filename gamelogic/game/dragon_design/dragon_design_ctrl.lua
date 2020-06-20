local DragonDesignCtrl = Class(game.BaseCtrl)

function DragonDesignCtrl:_init()
    if DragonDesignCtrl.instance ~= nil then
        error("DragonDesignCtrl Init Twice!")
    end
    DragonDesignCtrl.instance = self

    self.dragon_design_data = require("game/dragon_design/dragon_design_data").New(self)
    self.dragon_design_view = require("game/dragon_design/dragon_design_view").New(self)
    self.dragon_design_meta_view = require("game/dragon_design/dragon_design_meta_view").New(self)
    self.dragon_equip_view = require("game/dragon_design/dragon_equip_view").New(self)
    self.dragon_equip_oper_view = require("game/dragon_design/dragon_equip_oper_view").New(self)
    self.dragon_design_eat_view = require("game/dragon_design/dragon_design_eat_view").New(self)
    self.dragon_design_eat_set_view = require("game/dragon_design/dragon_design_eat_set_view").New(self)
    self.dragon_get_ten_view = require("game/dragon_design/dragon_get_ten_view").New(self)
    self.dragon_bag_oper_view = require("game/dragon_design/dragon_bag_oper_view").New(self)
    self.dragon_design_preview = require("game/dragon_design/dragon_design_preview").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()

    self.eat_color = 1
end

function DragonDesignCtrl:_delete()
    self.dragon_design_view:DeleteMe()
    self.dragon_design_meta_view:DeleteMe()
    self.dragon_equip_view:DeleteMe()
    self.dragon_equip_oper_view:DeleteMe()
    self.dragon_design_eat_view:DeleteMe()
    self.dragon_design_eat_set_view:DeleteMe()
    self.dragon_get_ten_view:DeleteMe()
    self.dragon_bag_oper_view:DeleteMe()
    self.dragon_design_preview:DeleteMe()
    self.dragon_design_data:DeleteMe()

    DragonDesignCtrl.instance = nil
end

function DragonDesignCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(20902, "ScDragonInfo")
    self:RegisterProtocalCallback(20904, "ScDragonLevelUp")
    self:RegisterProtocalCallback(20906, "ScDragonRefine")
    self:RegisterProtocalCallback(20908, "ScDragonReplace")
    self:RegisterProtocalCallback(20910, "ScDragonCondense")
    self:RegisterProtocalCallback(20912, "ScDragonEquip")
    self:RegisterProtocalCallback(20914, "ScDragonEat")
end

function DragonDesignCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginRoleRet, function(value)
            if value then
                self:CsDragonInfo()
            end
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function DragonDesignCtrl:GetData()
    return self.dragon_design_data
end

function DragonDesignCtrl:OpenView(template_index)
    if not self.dragon_design_view:IsOpen() then
        self.dragon_design_view:Open(template_index)
    end
end

function DragonDesignCtrl:CsDragonInfo()
    self:SendProtocal(20901,{})
end

function DragonDesignCtrl:ScDragonInfo(data)
    self.dragon_design_data:SetAllData(data)
end

function DragonDesignCtrl:CsDragonLevelUp()
    self:SendProtocal(20903,{})
end

function DragonDesignCtrl:ScDragonLevelUp(data)

    self.dragon_design_data:UpdateGrowthData(data)

    self:FireEvent(game.DragonDesignEvent.UpdateGrowth)
end

function DragonDesignCtrl:CsDragonRefine()
    self:SendProtocal(20905,{})
end

function DragonDesignCtrl:ScDragonRefine(data)

    self.dragon_design_data:UpdateRefine(data)

    self:FireEvent(game.DragonDesignEvent.UpdateRefine)
end

function DragonDesignCtrl:CsDragonReplace()
    self:SendProtocal(20907,{})
end

function DragonDesignCtrl:ScDragonReplace(data)
    self.dragon_design_data:UpdateReplace(data)

    self:FireEvent(game.DragonDesignEvent.UpdateReplace)
end

function DragonDesignCtrl:CsDragonCondense(condense_times)
    self:SendProtocal(20909,{times = condense_times})
end

function DragonDesignCtrl:ScDragonCondense(data)
    self.dragon_design_data:UpdateCondenseData(data)

    local item_num = 0
    for k, v in pairs(data.items) do
        item_num = item_num + v.num
    end

    --10次弹出结果界面
    if item_num > 1 then
        self:OpenDragonGetTenView(data.items)
    else

        local item_id = data.items[1].id
        local goods_cfg = config.goods[item_id]
        local str = string.format(config.words[6133], goods_cfg.name)
        game.GameMsgCtrl.instance:PushMsg(str)
    end

    self:FireEvent(game.DragonDesignEvent.UpdateGetDragon)
end

--pos_t 龙元位置 1-16 ， bag_pos_t龙元背包物品位置
function DragonDesignCtrl:CsDragonEquip(pos_t, bag_pos_t)
    self:SendProtocal(20911,{pos= pos_t, bag_pos = bag_pos_t})
end

function DragonDesignCtrl:ScDragonEquip(data)

    self.dragon_design_data:UpdateEquipData(data)

    self:FireEvent(game.DragonDesignEvent.UpdateEquip)
end

function DragonDesignCtrl:CsDragonEat(type_t, pos_t, bag_pos_t)
    self:SendProtocal(20913,{type = type_t, pos = pos_t, bag_pos = bag_pos_t})
end

function DragonDesignCtrl:ScDragonEat(data)
    self.dragon_design_data:UpdateEatData(data)

    self:FireEvent(game.DragonDesignEvent.UpdateEat, data)
end

function DragonDesignCtrl:OpenDragonMetaView(tab_index)
    if not self.dragon_design_meta_view:IsOpen() then
        self.dragon_design_meta_view:Open(tab_index)
    end
end

function DragonDesignCtrl:OpenDragonEquipView(equip_info)
    if not self.dragon_equip_view:IsOpen() then
        self.dragon_equip_view:Open(equip_info)
    end
end

function DragonDesignCtrl:OpenDragonOperView(item_info, hide_btn)
    if not self.dragon_equip_oper_view:IsOpen() then
        self.dragon_equip_oper_view:Open(item_info, hide_btn)
    end
end

function DragonDesignCtrl:OpenDragonBagOperView(item_info)
    if not self.dragon_bag_oper_view:IsOpen() then
        self.dragon_bag_oper_view:Open(item_info)
    end
end

function DragonDesignCtrl:OpenDragonEatView(item_info, in_bag_flag)
    if not self.dragon_design_eat_view:IsOpen() then
        self.dragon_design_eat_view:Open(item_info, in_bag_flag)
    end
end

function DragonDesignCtrl:OpenDragonEatSetView()
    if not self.dragon_design_eat_set_view:IsOpen() then
        self.dragon_design_eat_set_view:Open()
    end
end

function DragonDesignCtrl:OpenDragonDesignPreView()
    if not self.dragon_design_preview:IsOpen() then
        self.dragon_design_preview:Open()
    end
end

--10次凝元结果界面
function DragonDesignCtrl:OpenDragonGetTenView(get_items)
    if not self.dragon_get_ten_view:IsOpen() then
        self.dragon_get_ten_view:Open(get_items)
    end
end

function DragonDesignCtrl:GetEatColor()
    return self.eat_color
end

function DragonDesignCtrl:SetEatColor(color)
    self.eat_color = color
end

function DragonDesignCtrl:GetAttrCombatPower()
    return self.dragon_design_data:GetAttrCombatPower()
end

game.DragonDesignCtrl = DragonDesignCtrl

return DragonDesignCtrl