local DailyTaskItemView = Class(game.BaseView)

local PageIndex = {
    Item = 0,
    Pet = 1,
}

function DailyTaskItemView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "task_item_select_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
    self:AddPackage("ui_pet")
end

function DailyTaskItemView:_delete()

end

function DailyTaskItemView:OnPreOpen()
    self.main_role = game.Scene.instance:GetMainRole()
    self.main_role:SetPauseOperate(true)
end

function DailyTaskItemView:OpenViewCallBack(task_cfg)
    self:Init(task_cfg)
    self:InitBg()
    game.Scene.instance:GetMainRole():SetPauseOperate(true)
end

function DailyTaskItemView:CloseViewCallBack()
    self.click_item = nil

    local scene = game.Scene.instance
    if scene then
        local main_role = scene:GetMainRole()
        if main_role then
            main_role:SetPauseOperate(false)
        end
    end
end

function DailyTaskItemView:Init(task_cfg)
    self._layout_objs["txt_info"]:SetText(config.words[5105])

    self.btn_submit = self._layout_objs["btn_submit"]
    self.btn_submit:SetText(config.words[5106])
    self.btn_submit:AddClickCallBack(function()
        local arg = 0
        if self.page_index == PageIndex.Pet then
            if not self.click_item then
                game.GameMsgCtrl.instance:PushMsg(config.words[5121])
                return
            else
                arg = self.click_item:GetItemInfo().grid
            end
        end   
        game.TaskCtrl.instance:SendTaskGetReward(task_cfg.id, arg)
        self:Close()
    end)

    self.item_list = {}
    self.page_index = nil 

    for k, v in pairs(task_cfg.costs) do
        self.item_list[v[1]] = v[2]
    end

    if table.nums(self.item_list) > 0 then
        self.page_index = PageIndex.Item
    else
        self.pet_id = task_cfg.pet_id
        self.page_index = PageIndex.Pet
    end

    self:GetRoot():GetController("ctrl_state"):SetSelectedIndexEx(self.page_index)

    self:InitItemList()
    self:InitPetList()

    if self.page_index == PageIndex.Pet then
        self:UpdatePetList()
    elseif self.page_index == PageIndex.Item then
        self:UpdateItemList()
    end
end

function DailyTaskItemView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5104]):HideBtnBack()
end

function DailyTaskItemView:InitItemList()
    self.list_item = self:CreateList("list_item", "game/bag/item/goods_item")
    self.list_item:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_list_data[idx]
        item:SetItemInfo(item_info)
        item:SetNumText(string.format("%d/%d", item_info.num, self.item_list[item_info.id]))
        item:SetShowTipsEnable(true)
        self:OnItemClick(item)
    end)
end

function DailyTaskItemView:UpdateItemList()
    if not self.list_item then
        return
    end
    
    self.item_list_data = {}
    for obj_id, v in pairs(self.item_list or {}) do
        local num = game.BagCtrl.instance:GetNumById(obj_id)
        table.insert(self.item_list_data, {
            id = obj_id,
            num = num,
        })
    end
    self.list_item:SetItemNum(#self.item_list_data)
end

function DailyTaskItemView:OnItemClick(item)
    if self.click_item then
        self.click_item:SetSelect(false)
        self.click_item = nil
    end
    if item then
        self.click_item = item
        self.click_item:SetSelect(true)
    end
end

function DailyTaskItemView:InitPetList()
    self.list_pet = self:CreateList("list_pet", "game/pet/item/pet_icon_item")

    self.list_pet:SetRefreshItemFunc(function(item, idx)
        local info = self.pet_list[idx]
        item:SetItemInfo(info)
        item:AddClickEvent(function()
            self:OnItemClick(item)
            game.MarketCtrl.instance:OpenPetInfoView(info)
        end)
        if idx == 1 then
            self:OnItemClick(item)
        end
    end)

    self:OnItemClick()
end

function DailyTaskItemView:UpdatePetList()
    self.pet_list = game.PetCtrl.instance:GetBaby(self.pet_id)
    
    self.list_pet:SetItemNum(#self.pet_list)
end

return DailyTaskItemView
