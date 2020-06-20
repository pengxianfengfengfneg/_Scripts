local FashionColorView = Class(game.BaseView)

function FashionColorView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_fashion_color_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function FashionColorView:OpenViewCallBack(fashion_id)
    self.fashion_id = fashion_id

    self:Init()    
    self:InitBg()
    self:InitBtns()
    self:InitList()

    self:RegisterAllEvents()
end

function FashionColorView:CloseViewCallBack()
    
end

function FashionColorView:RegisterAllEvents()
    local events = {
        {game.FashionEvent.DyeingFashion, function(id, color)
            self:OnDyeingFashion(id, color)
        end},
        {game.BagEvent.BagItemChange, function(change_list)
            self:OnBagItemChange(change_list)
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FashionColorView:Init()
    self.txt_unlock_name = self._layout_objs["txt_unlock_name"]

    self.txt_color_name = self._layout_objs["txt_color_name"]
    self.txt_color_num = self._layout_objs["txt_color_num"]
    self.txt_get = self._layout_objs["txt_get"]
    self.txt_get:AddClickCallBack(function()
        game_help.JumpToGetway(self.cost_id)
    end)

    self.item_fashion = game_help.GetGoodsItem(self._layout_objs["item_fashion"], true)
    self.item_color = game_help.GetGoodsItem(self._layout_objs["item_color"], true)

    local career = game.RoleCtrl.instance:GetCareer()
    self.color_cfg = config.fashion_color[self.fashion_id][career]
    self.fashion_cfg = config.fashion[self.fashion_id]

    self:UpdateCost()
end

function FashionColorView:InitBtns()
    self.btn_color = self._layout_objs["btn_color"]
    self.btn_color:AddClickCallBack(function()
        if self:CheckColorable() then
            self.ctrl:SendFashionDyeing(self.fashion_id)
        end
    end)

end

function FashionColorView:CheckColorable()
    local is_all_actived = self.ctrl:IsAllColorActived(self.fashion_id)
    if is_all_actived then
        game.GameMsgCtrl.instance:PushMsg(config.words[2001])
        return false
    end

    local cur_num = game.BagCtrl.instance:GetNumById(self.cost_id)
    if cur_num < self.cost_num then
        game.GameMsgCtrl.instance:PushMsg(config.words[2000])
        return false
    end
    return true
end

function FashionColorView:InitList()
    self.color_ctrl = self:GetRoot():AddControllerCallback("color_ctrl",function(idx)
        
        
    end)

    local item_num = #self.fashion_cfg.unlock

    self.color_ctrl:SetPageCount(item_num)

    self.list_items = self._layout_objs["list_items"]
    self.list_items:SetItemNum(item_num)
    self.list_items:SetTouchEnable(false)

    local used_idx = 1
    self.color_item_list = {}
    for k,v in ipairs(self.fashion_cfg.unlock) do
        local cfg = self.color_cfg[v]
        local child = self.list_items:GetChildAt(k-1)

        local color_item = require("game/fashion/fashion_color_item").New()
        color_item:SetVirtual(child)
        color_item:Open()
        color_item:UpdateData(cfg)

        if color_item:IsUsed() then
            used_idx = k
        end

        table.insert(self.color_item_list, color_item)
    end

    self.color_ctrl:SetSelectedIndex(used_idx-1)
    self.list_items:ScrollToView(used_idx-1)

    local active_color_id = self.fashion_cfg.active
    local active_cfg = self.color_cfg[active_color_id]
    local info = {
        id = active_cfg.item_id,
        num = 0,
    }
    self.item_fashion:SetItemInfo(info)

    self.active_color_id = active_cfg.color
    self.txt_unlock_name:SetText(active_cfg.name)

    self:UpdateFashionItem()
end

function FashionColorView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1652])
end

function FashionColorView:OnEmptyClick()
    self:Close()
end

function FashionColorView:UpdateCost()
    local info = config.fashion[self.fashion_id]
    if not info then return end

    if not self.cost_id then
        local cost = info.cost or {}
        local cost_id = cost[1][1]
        local cost_num = cost[1][2]

        self.cost_id = cost_id
        self.cost_num = cost_num

        local info = {
            id = cost_id,
            num = 0
        }
        self.item_color:SetItemInfo(info)

        local goods_cfg = config.goods[cost_id]
        self.txt_color_name:SetText(goods_cfg.name)
    end

    local item_num = game.BagCtrl.instance:GetNumById(self.cost_id)
    local is_enough = (item_num>=self.cost_num)

    local color = (is_enough and game.Color.DarkGreen or game.Color.Red)
    self.txt_color_num:SetColor(table.unpack(color))
    self.txt_color_num:SetText(string.format("(%s/%s)", item_num, self.cost_num))
end

function FashionColorView:OnDyeingFashion(id, colors, old_colors)
    self:UpdateCost()

    local update_idx = self:UpdateColorItemState()
    local idx = update_idx[1] or 1
    self.color_ctrl:SetSelectedIndex(idx-1)

    local color_item = self.color_item_list[idx]
    game.GameMsgCtrl.instance:PushMsg(string.format(config.words[2005], color_item:GetName()))

    self:UpdateFashionItem()
end

function FashionColorView:UpdateColorItemState()
    local update_idx = {}
    for k,v in ipairs(self.color_item_list or {}) do
        v:UpdateState()

        if v:IsStateDirty() then
            table.insert(update_idx, k)
            v:ClearStateDirty()
        end
    end
    return update_idx
end

function FashionColorView:UpdateFashionItem()
    local is_actived = self.ctrl:IsColorActived(self.fashion_id, self.active_color_id)
    self.item_fashion:SetGray(not is_actived)
end

function FashionColorView:OnBagItemChange(change_list)
    if not change_list[self.cost_id] then
        return
    end
    self:UpdateCost()
end

return FashionColorView
