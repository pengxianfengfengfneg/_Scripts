local FieldBattleDrumView = Class(game.BaseView)

function FieldBattleDrumView:_init(ctrl)
    self._package_name = "ui_field_battle"
    self._com_name = "field_battle_drum_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function FieldBattleDrumView:_delete()

end

function FieldBattleDrumView:OpenViewCallBack()
    self:Init()
    self:InitBg()

    self:RegisterAllEvents()
end

function FieldBattleDrumView:CloseViewCallBack()
    for _,v in ipairs(self.item_list or {}) do
        v:DeleteMe()
    end
    self.item_list = nil
end

function FieldBattleDrumView:RegisterAllEvents()
    local events = {
        {game.FieldBattleEvent.OnTerritoryBeatDrum, handler(self, self.OnTerritoryBeatDrum)},
        {game.FieldBattleEvent.OnTerritoryNotifyDrum, handler(self, self.OnTerritoryNotifyDrum)},
           
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

function FieldBattleDrumView:Init()
    self.list_item = self._layout_objs["list_item"]
    
    self.item_list = {}
    local item_class = require("game/field_battle/field_battle_drum_item")
    local item_num = self.list_item:GetItemNum()
    for i=1,item_num do
        local obj = self.list_item:GetChildAt(i-1)
        local item = item_class.New()
        item:SetVirtual(obj)
        item:Open()
        item:UpdateData(config.territory_drum[i])

        table.insert(self.item_list, item)
    end
end

function FieldBattleDrumView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5252])
end

function FieldBattleDrumView:OnEmptyClick()
    self:Close()
end

function FieldBattleDrumView:OnTerritoryBeatDrum(id)
    local item = self.item_list[id]
    if item then
        item:UpdateState()
    end
end

function FieldBattleDrumView:OnTerritoryNotifyDrum(data)
    for _,v in ipairs(self.item_list) do
        v:UpdateState()
    end
end

return FieldBattleDrumView
