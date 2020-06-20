local TaskItemSelectView = Class(game.BaseView)

local PageIndex = {
    Item = 0,
    Pet = 1,
}

function TaskItemSelectView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "task_item_select_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
    self:AddPackage("ui_pet")
end

function TaskItemSelectView:_delete()

end

function TaskItemSelectView:OpenViewCallBack(task_cfg)
    self.task_cfg = task_cfg
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    game.Scene.instance:GetMainRole():SetPauseOperate(true)
end

function TaskItemSelectView:CloseViewCallBack()
    self.click_item = nil

    local scene = game.Scene.instance
    if scene then
        local main_role = scene:GetMainRole()
        if main_role then
            main_role:SetPauseOperate(false)
        end
    end
end

function TaskItemSelectView:Init()
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
                if self.type == 4 then
                    arg = self.click_item:GetItemInfo().grid
                end
            end
        end
        self.ctrl:SendGuildTaskFinish(self.type, arg)
    end)

    self.item_list = {}
    self.obj_id = self.task_cfg.obj_id
    self.obj_num = self.task_cfg.obj_num
    self.type = self.task_cfg.type

    self.page_index = PageIndex.Item
    if self.type == 4 then
        self.pet_id = self.obj_id
        self.obj_id = config.pet[self.obj_id].active_item
        self.page_index = PageIndex.Pet
    end
    self:GetRoot():GetController("ctrl_state"):SetSelectedIndexEx(self.page_index)
    self.item_list[self.obj_id] =  self.obj_num

    self:InitItemList()
    self:InitPetList()

    if self.type == 4 then
        self:UpdatePetList()
    elseif self.type == 5 then
        self:UpdateItemList()
    end
end

function TaskItemSelectView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5104]):HideBtnBack()
end

function TaskItemSelectView:InitItemList()
    self.list_item = self:CreateList("list_item", "game/bag/item/goods_item")
    self.list_item:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_list_data[idx]
        item:SetItemInfo(item_info)
        item:SetNumText(string.format("%d/%d", item_info.num, self.item_list[item_info.id]))
        item:SetShowTipsEnable(true)
        self:OnItemClick(item)
    end)

    self:OnItemClick()
end

function TaskItemSelectView:UpdateItemList()
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

function TaskItemSelectView:OnItemClick(item)
    if self.click_item then
        self.click_item:SetSelect(false)
        self.click_item = nil
    end
    if item then
        self.click_item = item
        self.click_item:SetSelect(true)
    end
end

function TaskItemSelectView:InitPetList()
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

function TaskItemSelectView:UpdatePetList()
    self.pet_list = game.PetCtrl.instance:GetBaby(self.pet_id)
    self.list_pet:SetItemNum(#self.pet_list)
end

function TaskItemSelectView:RegisterAllEvents()
    local events = {
        [game.DailyTaskEvent.GuildTaskFinish] = function(data)
            -- daily_times__C -- 今日已完成次数
            -- flag__C -- 状态(0:未接取|1:正在进行)
            if data.flag == 0 then
                self:Close()
            end
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return TaskItemSelectView
