local CircleTaskHelpSelectView = Class(game.BaseView)

function CircleTaskHelpSelectView:_init(ctrl)
    self._package_name = "ui_task"
    self._com_name = "circle_task_help_select_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl
end

function CircleTaskHelpSelectView:OnPreOpen()
    self.main_role = game.Scene.instance:GetMainRole()
    self.main_role:SetPauseOperate(true)
end

function CircleTaskHelpSelectView:OnPreClose()
    self.main_role:SetPauseOperate(false)
end

function CircleTaskHelpSelectView:OpenViewCallBack(info)
    self:Init(info)
    self:InitBg()
    self:RegisterAllEvents()
end

function CircleTaskHelpSelectView:CloseViewCallBack()

end

function CircleTaskHelpSelectView:RegisterAllEvents()
    local events = {
        {game.BagEvent.BagItemChange, handler(self,self.OnBagItemChange)},
        {game.TaskEvent.OnCircleHelp, handler(self,self.OnCircleHelp)},
        
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function CircleTaskHelpSelectView:Init(info)
    self.help_info = info
    self.click_item = nil

    self.btn_submit = self._layout_objs["btn_submit"]
    self.btn_submit:AddClickCallBack(function()
        self:OnClickBtnSubmit()
    end)

    self:InitItemList()
    self:UpdateItemList()
end

function CircleTaskHelpSelectView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6308])
end

function CircleTaskHelpSelectView:InitItemList()
    self.list_item = self._layout_objs["list_item"]

    self.ui_list = self:CreateList("list_item", "game/bag/item/goods_item")
    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_info_list[idx]
        item:SetItemInfo(item_info)
        item:SetShowTipsEnable(true)

        item:AddClickEvent(function(goods_item)
            self:OnItemClick(goods_item)
        end)
    end)
end

function CircleTaskHelpSelectView:UpdateItemList()
    if not self.ui_list then
        return
    end

    self.item_info_list = {}
    local info_list = game.BagCtrl.instance:GetInfoListById(self.help_info.item_id)
    for _,v in ipairs(info_list) do
        table.insert(self.item_info_list, v)
    end
    
    local item_num = #self.item_info_list
    self.ui_list:SetItemNum(item_num)

    if item_num > 0 then
        local obj = self.list_item:GetChildAt(0)
        local item = self.ui_list:GetItemByObj(obj)
        self:OnItemClick(item)
    end
end

function CircleTaskHelpSelectView:OnItemClick(item)
    if self.click_item == item then
        local is_select = (not item:GetSelect())
        self.click_item:SetSelect(is_select)
    else
        if self.click_item then
            self.click_item:SetSelect(false)
        end

        self.click_item = item
        self.click_item:SetSelect(true)
        self.click_item:SetSelectNum(1)
    end
end

function CircleTaskHelpSelectView:OnClickBtnSubmit()
    if not self.click_item or (not self.click_item:GetSelect()) then
        game.GameMsgCtrl.instance:PushMsg(config.words[6309])
        return
    end

    local poses = {}
    self.ui_list:Foreach(function(item)
        if item:GetSelect() then
            local info = item:GetItemInfo()
            table.insert(poses, {pos=info.pos, num=item:GetSelectNum()})
        end
    end)

    if not poses[1] then
        game.GameMsgCtrl.instance:PushMsg(config.words[6310])
        return
    end

    self.ctrl:SendCircleHelp(self.help_info.role_id, self.help_info.task_id, self.help_info.help_flag, poses)
end

function CircleTaskHelpSelectView:OnBagItemChange(change_data)
    local item_id = self.help_info.item_id
    if change_data[item_id] then
        self:UpdateItemList()
    end
end

function CircleTaskHelpSelectView:OnCircleHelp()
    self:Close()
end

return CircleTaskHelpSelectView
