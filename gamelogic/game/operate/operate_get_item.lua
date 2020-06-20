local OperateGetItem = Class(require("game/operate/operate_base"))

function OperateGetItem:_init()
    self.oper_type = game.OperateType.GetItem
end

function OperateGetItem:Init(obj, item_id, get_num)
    OperateGetItem.super.Init(self, obj)
    self.item_id = item_id
    self.get_num = get_num or 1
end

function OperateGetItem:Start()
    local item_cfg = config.goods[self.item_id]
    local acquire = item_cfg.acquire

    if not acquire or #acquire<=0 then
        return false
    end

    local way = acquire[1]
    local way_cfg = config.goods_get_way[way]
    local operate_func = way_cfg.operate_func
    if operate_func then
        local params = {operate_func()}
        local oper_type = params[1]
        table.remove(params,1) 
        self.cur_oper = self:CreateOperate(oper_type, self.obj, table.unpack(params))
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false
        end
    else
        if way_cfg.click_func then
            way_cfg.click_func(self.item_id)
        end
    end

    self.close_func = way_cfg.close_func

    self.bag_ctrl = game.BagCtrl.instance
    local item_num = self.bag_ctrl:GetNumById(self.item_id)
    self.target_item_num = item_num + self.get_num

    return true
end

function OperateGetItem:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    local item_num = self.bag_ctrl:GetNumById(self.item_id)
    if item_num >= self.target_item_num then
        if self.close_func then
            self.close_func()
        end
        return true
    end
end

function OperateGetItem:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateGetItem:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateGetItem:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type, self.item_id, self.get_num)
end

return OperateGetItem
