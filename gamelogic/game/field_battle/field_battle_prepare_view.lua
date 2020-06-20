local FieldBattlePrepareView = Class(game.BaseView)

local MaxNum = 40

function FieldBattlePrepareView:_init(ctrl)
    self._package_name = "ui_field_battle"
    self._com_name = "field_battle_prepare_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
end

function FieldBattlePrepareView:_delete()

end

function FieldBattlePrepareView:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function FieldBattlePrepareView:CloseViewCallBack()
    self.controller:SetSelectedIndex(0)
    self:ClearTimer()
end

function FieldBattlePrepareView:Init()
    self.img_bg = self._layout_objs["img_bg"]

    self.rtx_time = self._layout_objs["rtx_time"]

    self.field_battle_id = 1

    -- self.btn_wh = self._layout_objs["btn_wh"]
    -- self.btn_wh:AddClickCallBack(function()

    -- end)

    -- self.btn_back = self._layout_objs["btn_back"]
    -- self.btn_back:AddClickCallBack(function()
    --     self.ctrl:SendTerritoryLeave()
    -- end)

    self.list_tab = self._layout_objs["list_tab"]
    
    self.controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:OnClickTab(idx+1)
    end)

    self:UpdateInfo()
    self:UpdateTime()
end

function FieldBattlePrepareView:RegisterAllEvents()
    local events = {
        {game.ChatEvent.OpenChatView, handler(self, self.OnOpenChatView)},
        {game.ChatEvent.CloseChatView, handler(self, self.OnCloseChatView)},
        {game.FieldBattleEvent.OnTerritoryScenePrepare, handler(self, self.OnTerritoryScenePrepare)},
        {game.FieldBattleEvent.OnTerritoryNotifySelect, handler(self, self.OnTerritoryNotifySelect)},
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FieldBattlePrepareView:UpdateInfo()
    local info = self.ctrl:GetPrepareSelectionInfo() 
    for i=1,3 do
        local child = self.list_tab:GetChildAt(i-1)
        local num = 0
        for _,v in ipairs(info or game.EmptyTable) do
            if v.room == i then
                num = v.num
                break
            end
        end
        child:SetText(string.format("%s/%s", num, MaxNum))
    end

    if info then
        self:GetRoot():SetVisible(true)
        
        self.field_battle_id = self.ctrl:GetPrepareFieldId() or 0

        if self.field_battle_id <= 0 then
            self.field_battle_id = 1
            self.ctrl:SendTerritorySwitch(1)
        end

        self.controller:SetSelectedIndex(self.field_battle_id-1)

        local cfg = config.territory_room [self.field_battle_id] or game.EmptyTable
        self.field_name = cfg.name or ""
    else
        self:GetRoot():SetVisible(false)
    end
end

local ActCfg = {
    game.ActivityId.Territory_1,
    game.ActivityId.Territory_2,
    game.ActivityId.Territory_3,
}
function FieldBattlePrepareView:GetActStartTime()
    local act_info = nil
    for _,v in ipairs(ActCfg) do
        act_info = game.ActivityMgrCtrl.instance:GetActivity(v)
        if act_info then
            return act_info.start_time
        end
    end
    return 0
end

local prepare_min = 5
function FieldBattlePrepareView:UpdateTime()
    local start_time = self:GetActStartTime()
    local left_time = (start_time+prepare_min*60-global.Time:GetServerTime())
    local cfg = config.territory_room [self.field_battle_id]
    self.field_name = cfg.name

    local str = string.format(config.words[5264], left_time, self.field_name)
    self.rtx_time:SetText(str)

    self:ClearTimer()
    self.timer_id = global.TimerMgr:CreateTimer(1,function()
        left_time = left_time - 1
        local str = string.format(config.words[5264], left_time, self.field_name)
        self.rtx_time:SetText(str)

        if left_time <= 0 then
            self:ClearTimer()
            return true
        end
    end)
end

function FieldBattlePrepareView:ClearTimer()
    if self.timer_id then
        global.TimerMgr:DelTimer(self.timer_id)
        self.timer_id = nil
    end
end

function FieldBattlePrepareView:OnClickTab(idx)
    local cfg = config.territory_room [idx]
    local num = self.ctrl:GetPrepareRoomNum(idx)
    local str_num = string.format("%s/%s", num, MaxNum)
    local str = string.format(config.words[5263], cfg.name, str_num, cfg.name)
    self.ctrl:OpenTipsView(str, function()
        self.field_battle_id = idx

        self.ctrl:SendTerritorySwitch(idx)
    end, function()
        self.controller:SetSelectedIndex(self.field_battle_id-1)
    end)
    
end

function FieldBattlePrepareView:OnOpenChatView()
    self:GetRoot():PlayTransition("t0")
end

function FieldBattlePrepareView:OnCloseChatView()
    self.img_bg:SetPosition(23,940)
end

function FieldBattlePrepareView:OnTerritoryScenePrepare(data)
    self.field_battle_id = data.select

    self:UpdateInfo()
end

function FieldBattlePrepareView:OnTerritoryNotifySelect()
    self:UpdateInfo()

end

return FieldBattlePrepareView
