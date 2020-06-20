local FieldBattleSideInfoView = Class(game.BaseView)

function FieldBattleSideInfoView:_init(ctrl)
    self._package_name = "ui_field_battle"
    self._com_name = "field_battle_side_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
end

function FieldBattleSideInfoView:_delete()

end

function FieldBattleSideInfoView:OpenViewCallBack()
    self:Init()

    self:RegisterAllEvents()
end

function FieldBattleSideInfoView:CloseViewCallBack()
    self:ClearTimer()
end

function FieldBattleSideInfoView:RegisterAllEvents()
    local events = {
        {game.FieldBattleEvent.OnTerritorySceneBattle, handler(self,self.OnTerritorySceneBattle)},
        {game.FieldBattleEvent.OnTerritoryNotifyFlag, handler(self,self.OnTerritoryNotifyFlag)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

local FlagLogicPos = {x=224, y=354}
function FieldBattleSideInfoView:Init()
    self.txt_time = self._layout_objs["txt_time"]
    self.txt_cond = self._layout_objs["txt_cond"]
    self.txt_seat = self._layout_objs["txt_seat"]

    self.txt_left_time = self._layout_objs["txt_left_time"]

    self.btn_drum = self._layout_objs["btn_drum"]
    self.btn_drum:AddClickCallBack(function()
        self.ctrl:OpenDrumView()
    end)

    self.touch_com = self._layout_objs["touch_com"]
    self.touch_com:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        local ux,uy = game.LogicToUnitPos(FlagLogicPos.x, FlagLogicPos.y)
        main_role:GetOperateMgr():DoFindWay(ux,uy,3)
    end)

    self.self_guild_id = game.GuildCtrl.instance:GetGuildId()

    self:UpdateInfo()
    self:UpdateGatherObj()
    self:StartLeftTimer()
end

function FieldBattleSideInfoView:OnTerritorySceneBattle()    
    self:UpdateInfo()

    self:UpdateGatherObj()
end

function FieldBattleSideInfoView:OnTerritoryNotifyFlag()
    self:UpdateInfo()

    self:UpdateGatherObj()
end

local MaxOccupyTime = 10*60
function FieldBattleSideInfoView:UpdateInfo()
    local battle_info = self.ctrl:GetBattleInfo()
    if not battle_info.flag then
        return
    end

    local camp = battle_info.flag
    if camp > 0 then
        local occupy_time = battle_info.occupy
        local left_time = MaxOccupyTime - (global.Time:GetServerTime() - occupy_time)

        
        local seat_guild_id = nil
        for _,v in ipairs(battle_info.camps) do
            if camp == v.camp then
                seat_guild_id = v.guild
                break
            end
        end

        local seat_word = config.words[5278]
        if seat_guild_id == self.self_guild_id then
            -- 我方占领
            seat_word = config.words[5277]
        end

        self:ClearTimer()
        self:StartTimer(left_time)

        self.txt_seat:SetText(seat_word)
    else
        self.txt_time:SetText("10:00")
        self.txt_seat:SetText(config.words[5268])
    end
end

function FieldBattleSideInfoView:StartTimer(left_time)
    local left_time = left_time or 0
    self.txt_time:SetText(game.Utils.SecToTime2(left_time))

    self.timer_id = global.TimerMgr:CreateTimer(1, function()
        left_time = left_time - 1

        self.txt_time:SetText(game.Utils.SecToTime2(left_time))

        if left_time <= 0 then
            self:ClearTimer()
            return true
        end
    end)
end

function FieldBattleSideInfoView:ClearTimer()
    if self.timer_id then
        global.TimerMgr:DelTimer(self.timer_id)
        self.timer_id = nil
    end
end

local FlagId = config.sys_config["territory_flag"].value
function FieldBattleSideInfoView:UpdateGatherObj()
    local battle_info = self.ctrl:GetBattleInfo()
    if not battle_info.flag then
        return
    end

    local obj_list = game.Scene.instance:GetObjByType(game.ObjType.Gather, function(obj)
        return (obj:GetGatherId()==FlagId)
    end)

    local gather_obj = obj_list[1]
    if gather_obj then
        local camp = battle_info.flag

        if camp > 0 then
            local guild_name = ""
            local guild_id = nil
            for _,v in ipairs(battle_info.camps) do
                if camp == v.camp then
                    guild_name = v.name
                    guild_id = v.guild
                    break
                end
            end

            local my_guild_id = game.GuildCtrl.instance:GetGuildId()
            local color_idx = (my_guild_id==guild_id and 3 or 2)
            gather_obj:SetHudText(game.HudItem.Tips, guild_name, color_idx)
        end
    end
end

function FieldBattleSideInfoView:StartLeftTimer()
    self:ClearLeftTimer()

    local act_info = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.Territory_1)
    if act_info then
        local left_time = act_info.end_time - global.Time:GetServerTime()
        if left_time > 0 then
            local str_time = game.Utils.SecToTimeEn(left_time)
            self.txt_left_time:SetText(str_time)

            self.left_timer_id = global.TimerMgr:CreateTimer(1, function()
                left_time = left_time - 1
                local str_time = game.Utils.SecToTimeEn(left_time)
                self.txt_left_time:SetText(str_time)
            end)
        end
    end
end

function FieldBattleSideInfoView:ClearLeftTimer()
    if self.left_timer_id then
        global.TimerMgr:DelTimer(self.left_timer_id)
        self.left_timer_id = nil
    end
end

return FieldBattleSideInfoView
