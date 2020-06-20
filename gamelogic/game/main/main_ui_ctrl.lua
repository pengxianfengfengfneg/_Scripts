local MainUICtrl = Class(game.BaseCtrl)

local event_mgr = global.EventMgr

function MainUICtrl:_init()
    if MainUICtrl.instance ~= nil then
        error("MainUICtrl Init Twice!")
    end
    MainUICtrl.instance = self

    --self.main_ui_view = require("game/main/main_ui_view").New(self)  
    self.data = require("game/main/main_ui_data").New(self) 
    self.main_ui_view = require("game/main/main_new/main_new_view").New(self)   

    self.chose_pet_view = require("game/main/chose_pet_view").New(self)
    self.chose_mount_view = require("game/main/chose_mount_view").New(self)
    self.rumor_view = require("game/main/rumor_view").New(self)
    self.buff_view = require("game/main/buff_view").New(self)
    self.money_view = require("game/main/money_view").New(self)
    self.other_player_view = require("game/main/other_player_view").New(self)
    self.battle_info_view = require("game/main/battle_info_view").New(self)

    self.chat_horn_view = require("game/chat/chat_horn_view").New(self)
    self.number_keyboard = require("game/main/number_keyboard").New(self)
    self.money_exchange_view = require("game/main/money_exchange_view").New(self)
    self.quick_use_view = require("game/main/quick_use_view").New(self)
    self.drop_item_view = require("game/main/drop_item_view").New(self)
    self.auto_money_exchange_view = require("game/main/auto_money_exchange_view").New(self)
    self.play_action_view = require("game/main/play_action_view").New(self)
    self.gather_bar_view = require("game/main/gather_bar_view").New(self)

    self:RegisterAllEvents() 
    self:RegisterAllProtocal()   

    global.Runner:AddUpdateObj(self, 1)
end

function MainUICtrl:_delete()
    global.Runner:RemoveUpdateObj(self)

    self.main_ui_view:DeleteMe()
    self.chose_pet_view:DeleteMe()
    self.chose_mount_view:DeleteMe()
    self.rumor_view:DeleteMe()
    self.buff_view:DeleteMe()
    self.money_view:DeleteMe()
    self.other_player_view:DeleteMe()
    self.battle_info_view:DeleteMe()

    self.chat_horn_view:DeleteMe()
    self.number_keyboard:DeleteMe()
    self.money_exchange_view:DeleteMe()
    self.quick_use_view:DeleteMe()
    self.drop_item_view:DeleteMe()
    self.auto_money_exchange_view:DeleteMe()
    self.play_action_view:DeleteMe()
    self.gather_bar_view:DeleteMe()

    self.data:DeleteMe()

    MainUICtrl.instance = nil
end

function MainUICtrl:GetFuncBtn(func_id)
    return self.main_ui_view:GetFuncBtn(func_id)
end

function MainUICtrl:GetBtnPos(func_id)
    return self.main_ui_view:GetBtnPos(func_id)
end

function MainUICtrl:RegisterAllEvents()
    self:BindEvent(game.LoginEvent.LoginSuccess, function()
        self:SendGetOpAndMerDay()
        self:SendGetWorldLv()
        self:SendBattleLogInfo()
    end)
end

function MainUICtrl:RegisterAllProtocal()
    -- self:RegisterProtocalCallback(20402, "OnMoneyInfo")
    self:RegisterProtocalCallback(10504, "OnOpAndMerDay")
    self:RegisterProtocalCallback(10506, "OnCommonlyKeyValue")
    self:RegisterProtocalCallback(10509, "OnGetWorldLv")
    self:RegisterProtocalCallback(10511, "OnGetOnlineTime")
    self:RegisterProtocalCallback(20406, "OnMoneyExchange")

    self:RegisterProtocalCallback(90123, "OnBattleLogInfo")
    self:RegisterProtocalCallback(90125, "OnBattleLogDelete")
    self:RegisterProtocalCallback(90126, "OnBattleLogNew")
end

function MainUICtrl:Update(now_time, elapse_time)
    if self:IsViewOpen() then
        self.main_ui_view:Update(now_time, elapse_time)
    end

    if self.rumor_view:IsOpen() then
        self.rumor_view:Update(now_time, elapse_time)
    end

    if self.chat_horn_view:IsOpen() then
        self.chat_horn_view:Update(now_time, elapse_time)
    end

end

function MainUICtrl:GetData()
    return self.data
end

function MainUICtrl:OpenView()
    self.main_ui_view:Open()    
end

function MainUICtrl:CloseView()
    self.main_ui_view:Close()
end

function MainUICtrl:OpenMoneyView()
    self.money_view:Open()
end

function MainUICtrl:OpenChosePetView(info)
    self.chose_pet_view:Open(info)
end

function MainUICtrl:OpenChoseMountView()
    self.chose_mount_view:Open()
end

function MainUICtrl:OpenRumorView()
    self.rumor_view:Open()
end

function MainUICtrl:OpenOtherPlayerView()
    self.other_player_view:Open()
end

function MainUICtrl:OpenChatHornView()
    self.chat_horn_view:Open()
end

function MainUICtrl:CloseOtherPlayerView()
    self.other_player_view:Close()
end

function MainUICtrl:IsViewOpen()
    return self.main_ui_view:IsOpen()
end

function MainUICtrl:OpenBattleInfoView()
    self.battle_info_view:Open()
end

--根据场景类型显示不同的战斗界面
function MainUICtrl:SwitchToFighting()
    self.main_ui_view:SwitchToFighting()
end

function MainUICtrl:SwitchToMainCity()
    self.main_ui_view:SetShowMainFuncGroup(true)
end

function MainUICtrl:SetActTime(time)
    self.main_ui_view:SetActTime(time)
end

function MainUICtrl:SendSetCommonlyKeyValue(key, val)
    local proto = {
        key = key,
        value = val,
    }
    self:SendProtocal(10507, proto)
end

function MainUICtrl:SendGetCommonlyKeyValue(key)
    self:SendProtocal(10505, {key=key})
end

function MainUICtrl:OnCommonlyKeyValue(data)
    self:FireEvent(game.SceneEvent.CommonlyValueRespon, data)
end

function MainUICtrl:SendGetOpAndMerDay()
    self:SendProtocal(10503, {})
end

function MainUICtrl:OnOpAndMerDay(data)
    self.open_day = data.op_day
    self.merge_day = data.merge_day
    self.login_days = data.login_days
    self:FireEvent(game.SceneEvent.OpAndMerDayRespon, data)
end

function MainUICtrl:GetOpenDay()
    return self.open_day
end

function MainUICtrl:SendGetWorldLv()
    local proto = {}
    self:SendProtocal(10508, proto)
end

function MainUICtrl:OnGetWorldLv(data)
    self.world_lv = data.world_lv
    self.pioneer_lv = data.pioneer_lv
end

function MainUICtrl:GetWorldLv()
    return self.world_lv or 40
end

function MainUICtrl:GetPioneerLv()
    return self.pioneer_lv or 0
end

function MainUICtrl:OpenBuffView(list_data)
    self.buff_view:Open(list_data)
    return self.buff_view
end

function MainUICtrl:GetMainUIView()
    return self.main_ui_view
end

function MainUICtrl:SetShowBtnExit(val)
    self.main_ui_view:SetShowBtnExit(val)
end

function MainUICtrl:SetShowBtnDetail(val)
    self.main_ui_view:SetShowBtnDetail(val)
end

function MainUICtrl:SetShowTaskCom(val)
    self.main_ui_view:SetShowTaskCom(val)
end

function MainUICtrl:SetDunAssistEnable(val)
    self.main_ui_view:SetDunAssistEnable(val)
end

function MainUICtrl:SendGetOnlineTime()
    self:SendProtocal(10510)
end

function MainUICtrl:OnGetOnlineTime(data)
    self:FireEvent(game.ActivityEvent.TodayOnlineTime, data.today_online_time)
end

function MainUICtrl:OpenNumberKeyboard(x, y)
    self.number_keyboard:SetPos(x, y)
    self.number_keyboard:Open()
end

function MainUICtrl:OpenMoneyExchangeView(type)
    self.money_exchange_view:Open(type)
end

function MainUICtrl:SendMoneyExchange(id, val)
    self:SendProtocal(20405, {id = id, val = val})
end

function MainUICtrl:OnMoneyExchange(data)
    self:FireEvent(game.MoneyEvent.Exchange, data)
end

function MainUICtrl:IsHanging()
    return self.main_ui_view:IsHanging()
end

function MainUICtrl:SetFollowHang(val)
    self.is_follow_hang = val
end

function MainUICtrl:ShowTask(task_id)
    self.main_ui_view:ShowTask(task_id)
end

function MainUICtrl:GetShowingTask()
    return self.main_ui_view:GetShowingTask()
end

function MainUICtrl:SendBattleLogInfo()
    self:SendProtocal(90122)
end

function MainUICtrl:SendBattleLogDelete(id)
    self:SendProtocal(90124, {id = id})
end

function MainUICtrl:OnBattleLogInfo(data_list)
    self.data:SetBattleInfo(data_list.logs)
end

function MainUICtrl:OnBattleLogDelete(data_list)
    self.data:DelBattleInfo(data_list.id)
end

function MainUICtrl:OnBattleLogNew(data_list)
    self.data:AddBattleInfo(data_list.new_log)
end

function MainUICtrl:OpenQuickUseView()
    self.quick_use_view:Open()
end

function MainUICtrl:CloseQuickUseView()
    self.quick_use_view:Close()
end

function MainUICtrl:OpenDropItemView()
    self.drop_item_view:Open()
end

function MainUICtrl:ShowDrop(item_list)
    self.drop_item_view:ShowDrop(item_list)
end

function MainUICtrl:SetCameraRotEnable(val)
    if self.main_ui_view then
        self.main_ui_view:SetCameraRotEnable(val)
    end
end

function MainUICtrl:SetClickTerrainEnable(val)
    if self.main_ui_view then
        self.main_ui_view:SetClickTerrainEnable(val)
    end
end

function MainUICtrl:SetCameraRotState(val)
    if self.main_ui_view then
        self.main_ui_view:SetCameraRotState(val)
    end
end

function MainUICtrl:SetGestureCallBack(callback)
    if self.main_ui_view then
        self.main_ui_view:SetGestureCallBack(callback)
    end
end

function MainUICtrl:ShowView(val)
    if val then
        self.main_ui_view:ShowLayout()
    else
        self.main_ui_view:HideLayout()
    end
end

function MainUICtrl:OpenAutoMoneyExchangeView(money_type, num, callback)
    local own = game.BagCtrl.instance:GetMoneyByType(money_type)
    if own >= num then
        if callback then
            callback()
        end
    else
        self.auto_money_exchange_view:Open(money_type, num, callback)
    end
end

function MainUICtrl:IsFollowHanging()
    return self.main_ui_view:IsFollowHanging()
end

function MainUICtrl:SetFollowHanging(val)
    self.main_ui_view:SetFollowHanging(val)
end

function MainUICtrl:OpenPlayActionView()
    self.play_action_view:Open()
end

function MainUICtrl:OpenGatherBarView(txt, time, vitality_str)
    self.gather_bar_view:Open(txt, time, vitality_str)
end

function MainUICtrl:CloseGatherBarView()
    self.gather_bar_view:Close()
end

function MainUICtrl:ShowFuncBtn(func_id)
    self.main_ui_view:ShowFuncBtn(func_id)
end

function MainUICtrl:GetPetCom()
    return self.main_ui_view:GetPetCom()
end

function MainUICtrl:SwitchFuncListPage(page)
    self.main_ui_view:SwitchFuncListPage(page)
end

game.MainUICtrl = MainUICtrl

return MainUICtrl
