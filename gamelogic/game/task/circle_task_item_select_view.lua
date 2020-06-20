local CircleTaskItemSelectView = Class(game.BaseView)

function CircleTaskItemSelectView:_init(ctrl)
    self._package_name = "ui_task"
    self._com_name = "circle_task_item_select_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl
end

function CircleTaskItemSelectView:OnPreOpen()
    self.main_role = game.Scene.instance:GetMainRole()
    self.main_role:SetPauseOperate(true)
end

function CircleTaskItemSelectView:OnPreClose()
    self.main_role:SetPauseOperate(false)
end

function CircleTaskItemSelectView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function CircleTaskItemSelectView:CloseViewCallBack()

end

function CircleTaskItemSelectView:RegisterAllEvents()
    local events = {
        {game.TaskEvent.OnCircleQuick, handler(self,self.OnCircleQuick)},
        {game.BagEvent.BagItemChange, handler(self,self.OnBagItemChange)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function CircleTaskItemSelectView:Init()
    self.cur_select_num = 0

    self.btn_submit = self._layout_objs["btn_submit"]
    self.btn_submit:AddClickCallBack(function()
        self:OnClickBtnSubmit()
    end)

    self.btn_shop = self._layout_objs["btn_shop"]
    self.btn_shop:AddClickCallBack(function()
        self:OnClickBtnShop()
    end)

    self.circle_task_info = self.ctrl:GetCircleTaskInfo()

    self.rtx_desc = self._layout_objs["rtx_desc"]
    self.txt_cur_num = self._layout_objs["txt_cur_num"]
    self.txt_need_num = self._layout_objs["txt_need_num"]
    self.txt_tips = self._layout_objs["txt_tips"]

    self.txt_cur_num:SetColor(table.unpack(game.Color.Red))
    self.txt_cur_num:SetText(0)

    local quick_id = self.circle_task_info.quick_item
    local quick_cfg = config.circle_quick[quick_id]
    if not quick_cfg then
        self:Close()
        return
    end

    self.cost_list = quick_cfg.goods

    local start_circle = self.circle_task_info.times+1
    local end_circle = math.min(self.circle_task_info.times+10,self.circle_task_info.round_times*3)

    self.txt_need_num:SetText("/" .. self.circle_task_info.quick_num)
    self.rtx_desc:SetText(string.format(config.words[6301], 
                        self.circle_task_info.quick_num, 
                        quick_cfg.name, 
                        start_circle,
                        end_circle
                        ))
    
    self:InitItemList()
    self:UpdateItemList()
end

function CircleTaskItemSelectView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6300])
end

function CircleTaskItemSelectView:InitItemList()
    self.list_item = self._layout_objs["list_item"]

    self.ui_list = self:CreateList("list_item", "game/bag/item/goods_item")
    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_info_list[idx]
        item:SetItemInfo(item_info)
        item:SetNumText(string.format("%d/%d", item_info.num, 0))
        item:SetShowTipsEnable(true)

        item:AddClickEvent(function(goods_item)
            self:OnItemClick(goods_item)
        end)
    end)
end

function CircleTaskItemSelectView:UpdateItemList()
    if not self.ui_list then
        return
    end

    self.cur_select_num = 0
    self.item_info_list = {}
    local bag_ctrl = game.BagCtrl.instance
    for _,v in ipairs(self.cost_list) do
        local info_list = bag_ctrl:GetInfoListById(v)
        for _,cv in ipairs(info_list) do
            table.insert(self.item_info_list, cv)
        end
    end
    
    local item_num = #self.item_info_list
    self.ui_list:SetItemNum(item_num)

    self.txt_tips:SetVisible(item_num<=0)
    self.list_item:SetVisible(item_num>0)

    if item_num > 0 then
        local obj = self.list_item:GetChildAt(0)
        local item = self.ui_list:GetItemByObj(obj)
        self:OnItemClick(item)
    end
end

function CircleTaskItemSelectView:OnItemClick(item)
    local need_num = (self.circle_task_info.quick_num - self.cur_select_num)

    local is_select = (not item:GetSelect()) and (need_num>0)
    if is_select == item:GetSelect() then
        return
    end

    local item_info = item:GetItemInfo()
    local select_num = (is_select and math.min(item_info.num, need_num) or 0)
    item:SetSelect(is_select)
    item:SetSelectNum(select_num)
    item:SetNumText(string.format("%d/%d", item_info.num, select_num))

    --game.BagCtrl.instance:OpenTipsView(item_info, nil, false)

    self.cur_select_num = 0
    self.ui_list:Foreach(function(item)
        if item:GetSelect() then
            self.cur_select_num = self.cur_select_num + item:GetSelectNum()
        end
    end)

    self.cur_select_num = math.min(self.cur_select_num, self.circle_task_info.quick_num)
    local color = (self.cur_select_num>=self.circle_task_info.quick_num and game.Color.DarkGreen or game.Color.Red)
    self.txt_cur_num:SetColor(table.unpack(color))
    self.txt_cur_num:SetText(self.cur_select_num)
end

function CircleTaskItemSelectView:OnCircleQuick()
    self:Close()
end

function CircleTaskItemSelectView:OnClickBtnSubmit()
    if self.circle_task_info.quick_num - self.cur_select_num > 0 then
        game.GameMsgCtrl.instance:PushMsg(config.words[6310])
        return
    end

    local poses = {}
    self.ui_list:Foreach(function(item)
        if item:GetSelect() then
            local info = item:GetItemInfo()
            table.insert(poses, {pos=info.pos, num=item:GetSelectNum()})
        end
    end)

    self.ctrl:SendCircleQuick(poses)
end

function CircleTaskItemSelectView:OnClickBtnShop()
    if not self.cost_list[2] then
        game.MarketCtrl.instance:OpenBuyViewByItemId(self.cost_list[1])
    else
        game.MarketCtrl.instance:OpenBuyViewByTagId(42)
    end
end

function CircleTaskItemSelectView:OnBagItemChange(change_data)
    local is_update = false
    for _,v in ipairs(self.cost_list) do
        if change_data[v] then
            is_update = true
            break
        end
    end

    if is_update then
        self:UpdateItemList()
    end
end

return CircleTaskItemSelectView
