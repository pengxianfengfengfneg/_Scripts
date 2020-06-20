local FieldBattlePkView = Class(game.BaseView)

local PkConfig = {
    [1] = {2,3},
    [2] = {4,5},
    [3] = {6,7},
    [4] = {8,9},
    [5] = {10,11},
    [6] = {12,13},
    [7] = {14,15}
}

function FieldBattlePkView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "field_battle_pk_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function FieldBattlePkView:_delete()

end

function FieldBattlePkView:OpenViewCallBack(field_id, next_delta_time)
    self.field_id = field_id
    self.next_delta_time = next_delta_time or 0

    self:Init()
    self:InitBg()
    self:StartTimer()
end

function FieldBattlePkView:CloseViewCallBack()
    self:ClearTimer()
end

function FieldBattlePkView:Init()
    self.img_field = self._layout_objs["img_field"]
    self.txt_blue = self._layout_objs["txt_blue"]
    self.txt_red = self._layout_objs["txt_red"]
    self.txt_time = self._layout_objs["txt_time"]

    local battle_ctrl = game.FieldBattleCtrl.instance
    local pk_cfg = PkConfig[self.field_id]
    local blue_info = battle_ctrl:GetTerritoryInfoForId(pk_cfg[1])
    local red_info = battle_ctrl:GetTerritoryInfoForId(pk_cfg[2])

    local cfg = config.territory[self.field_id] or {}
    self.img_field:SetSprite("ui_guild", cfg.icon)
    self.txt_blue:SetText(blue_info.name)
    self.txt_red:SetText(red_info.name)
end

function FieldBattlePkView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5251])
end

function FieldBattlePkView:UpdateData()
    
end

function FieldBattlePkView:OnEmptyClick()
    self:Close()
end

function FieldBattlePkView:StartTimer()
    self:ClearTimer()


    if self.next_delta_time <= 0 then
        -- 争夺进行中
        self.txt_time:SetText(config.words[5271])
        return
    end

    local str = game.Utils.SecToTimeCn(self.next_delta_time, game.TimeFormatCn.DayHourMinSec)
    self.txt_time:SetText(str)

    self.timer_id = global.TimerMgr:CreateTimer(1, function()
        self.next_delta_time = self.next_delta_time - 1

        local str = game.Utils.SecToTimeCn(self.next_delta_time, game.TimeFormatCn.DayHourMinSec)
        self.txt_time:SetText(str)

        if self.next_delta_time <= 0 then
            self:ClearTimer()
            return true
        end
    end)
end

function FieldBattlePkView:ClearTimer()
    if self.timer_id then
        global.TimerMgr:DelTimer(self.timer_id)
        self.timer_id = nil
    end
end

return FieldBattlePkView
