local FieldBattleFightInfoView = Class(game.BaseView)

function FieldBattleFightInfoView:_init(ctrl)
    self._package_name = "ui_field_battle"
    self._com_name = "field_battle_fight_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function FieldBattleFightInfoView:_delete()

end

function FieldBattleFightInfoView:OpenViewCallBack()
    self:Init()
    self:InitBg()

    self:RequestData()

    self:RegisterAllEvents()
end

function FieldBattleFightInfoView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function FieldBattleFightInfoView:RegisterAllEvents()
    local events = {
        {game.FieldBattleEvent.OnTerritoryRank, handler(self, self.OnTerritoryRank)}   
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FieldBattleFightInfoView:Init()
    self.txt_blue = self._layout_objs["txt_blue"]
    self.txt_red = self._layout_objs["txt_red"]
    self.txt_my_rank = self._layout_objs["txt_my_rank"]

    self.btn_all = self._layout_objs["btn_all"]
    self.btn_all:AddClickCallBack(function()
        self.ctrl:OpenPkInfoView()
    end)

    self.list_item = self._layout_objs["list_item"]
    self.ui_list = game.UIList.New(self.list_item)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local chat_item = require("game/field_battle/field_battle_fight_info_item").New(self.ctrl)
        chat_item:SetVirtual(obj)
        chat_item:Open()

        return chat_item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetRankData(idx)
        item:UpdateData(data)
    end)

    local battle_info = self.ctrl:GetBattleInfo()
    for _,v in ipairs(battle_info.camps or game.EmptyTable) do
        if v.camp == 1 then
            self.txt_red:SetText(v.name)
        end

        if v.camp == 2 then
            self.txt_blue:SetText(v.name)
        end
    end
end

function FieldBattleFightInfoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5253])
end

function FieldBattleFightInfoView:RequestData()
    self.ctrl:SendTerritoryRank()
end

function FieldBattleFightInfoView:OnEmptyClick()
    self:Close()
end

function FieldBattleFightInfoView:OnTerritoryRank(data)
    --[[
        "ranks__T__rank@C##name@s##kill@H##score@L",
    ]]
    self.rank_data = data.ranks

    table.sort(self.rank_data, function(v1,v2)
        return v1.rank<v2.rank
    end)

    self.list_item:SetItemNum(#data.ranks)

    self:UpdateSelfRank()
end

function FieldBattleFightInfoView:GetRankData(idx)
    return self.rank_data[idx]
end

function FieldBattleFightInfoView:UpdateSelfRank()
    local self_rank = nil
    local role_id = game.Scene.instance:GetMainRoleID()
    for _,v in ipairs(self.rank_data) do
        if v.id == role_id then
            self_rank = v.rank
            break
        end
    end

    self.txt_my_rank:SetText(self_rank or "--")
end

return FieldBattleFightInfoView
