local DailyTaskTreasureTemplate = Class(game.UITemplate)

function DailyTaskTreasureTemplate:_init(view)
    self.parent = view
    self.ctrl = game.DailyTaskCtrl.instance   
end

function DailyTaskTreasureTemplate:OpenViewCallBack()
    self:Init()
    self:InitItemList()
    self:RegisterAllEvents()
    self.ctrl:SendTreasureMapInfo()
end

function DailyTaskTreasureTemplate:CloseViewCallBack()
    
end

function DailyTaskTreasureTemplate:Init()
    self.txt_info = self._layout_objs["txt_info"]

    self.txt_level = self._layout_objs["txt_level"]
    self.txt_level:SetText(string.format(config.words[1953], config.treasure_map_info.open_lv))

    self.btn_get = self._layout_objs["btn_get"]
    self.btn_get:SetText(config.words[1951])
    self.btn_get:AddClickCallBack(function()
        self.ctrl:SendTreasureMapGet()
    end)

    self.btn_finish = self._layout_objs["btn_finish"]
    self.btn_finish:SetText(config.words[1952])
    self.btn_finish:AddClickCallBack(function()
        game.Scene.instance:GetMainRole():GetOperateMgr():DoHangTaskTreasureMap()
    end)

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    
    self.max_num = config.treasure_map_info.nor_map_times
end

function DailyTaskTreasureTemplate:InitItemList()
    self.list_item = self:CreateList("list_item", "game/bag/item/goods_item")
    self.list_item:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_list_data[idx]
        item:SetShowTipsEnable(true)
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
    end)
    self:UpdateRewardList()
end

function DailyTaskTreasureTemplate:UpdateRewardList()
    local box_reward = config.treasure_map_info.box_reward
    local level = game.RoleCtrl.instance:GetRoleLevel()
    local drop_id
    for k, v in pairs(box_reward) do
        if level >= v[1] and level <= v[2] then
            drop_id = v[3]
            break
        end
    end
    self.item_list_data = config.drop[drop_id].client_goods_list or {}
    self.list_item:SetItemNum(#self.item_list_data)
end

function DailyTaskTreasureTemplate:Refresh(data)
    local index = 0
    if data.is_trigger == 1 then
        if data.is_complete == 1 then
            index = 3
        else
            index = 2
        end
    else
        local role_level = game.RoleCtrl.instance:GetRoleLevel()
        if role_level < config.treasure_map_info.open_lv then
            index = 0
        else
            index = 1
        end
    end
    self:SetStateCtrl(index)
end

function DailyTaskTreasureTemplate:SetStateCtrl(index)
    self.ctrl_state:SetSelectedIndex(index)
    if index == 1 then
        self.txt_info:SetText(config.words[1955])
    elseif index == 2 then
        local goods = config.goods[config.treasure_map_info.nor_map_id]
        self.txt_info:SetText(string.format(config.words[1954], goods.name, self.max_num, self.treas_info.task_times or 0, self.max_num))
    end
end

function DailyTaskTreasureTemplate:RegisterAllEvents()
    local events = {
        [game.DailyTaskEvent.UpdateTreasureMapInfo] = function(data)
            --[[
                is_trigger__C -- 是否已接任务
                task_times__C -- 完成任务次数
                today_times__I -- 今日使用藏宝图次数
                is_complete__C -- 是否已完成 0 1
                event_id__C  -- 事件ID
            ]]
            self.treas_info = data
            self:Refresh(data)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return DailyTaskTreasureTemplate