local FieldBattlePkInfoView = Class(game.BaseView)

function FieldBattlePkInfoView:_init(ctrl)
    self._package_name = "ui_field_battle"
    self._com_name = "field_battle_pk_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function FieldBattlePkInfoView:_delete()

end

function FieldBattlePkInfoView:OpenViewCallBack()
    self:Init()
    self:InitBg()

    self:RequestData()
    self:RegisterAllEvents()
end

function FieldBattlePkInfoView:CloseViewCallBack()
    for _,v in ipairs(self.item_list or {}) do
        v:DeleteMe()
    end
    self.item_list = nil
end

function FieldBattlePkInfoView:RequestData()
    self.ctrl:SendTerritoryProgress()
end

function FieldBattlePkInfoView:RegisterAllEvents()
    local events = {
        {game.FieldBattleEvent.OnTerritoryProgress, handler(self, self.OnTerritoryProgress)}
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

function FieldBattlePkInfoView:Init()
    self.txt_blue = self._layout_objs["txt_blue"]
    self.txt_red = self._layout_objs["txt_red"]
    self.list_item = self._layout_objs["list_item"]

    self.item_list = {}
    local item_class = require("game/field_battle/field_battle_pk_info_item")
    local item_num = self.list_item:GetItemNum()
    for i=1,item_num do
        local obj = self.list_item:GetChildAt(i-1)
        local item = item_class.New(i)
        item:SetVirtual(obj)
        item:Open()

        table.insert(self.item_list, item)
    end

    local against_info = self.ctrl:GetGuildAgainstInfo()
    self.txt_blue:SetText(against_info.blue_name)
    self.txt_red:SetText(against_info.red_name)
end

function FieldBattlePkInfoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5251])
end

function FieldBattlePkInfoView:OnEmptyClick()
    self:Close()
end

function FieldBattlePkInfoView:OnTerritoryProgress(data)
    for _,v in ipairs(data.rooms) do
        local item = self.item_list[v.room]
        if item then
            item:UpdateData(v)
        end
    end
end

return FieldBattlePkInfoView
