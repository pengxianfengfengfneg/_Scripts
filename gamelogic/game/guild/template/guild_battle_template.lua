local GuildBattleTemplate = Class(game.UITemplate)

local PageConfig = {
    {
        item_path = "war_template",
        item_class = "game/guild/template/battle_war_template",
        img_icon = "bt_icon_01",
        img_icon2 = "bt_icon_02",
    },
    {
        item_path = "seat_template",
        item_class = "game/guild/template/battle_seat_template",
        img_icon = "bt_icon_03",
        img_icon2 = "bt_icon_04",
    },
    {
        item_path = "hostile_template",
        item_class = "game/guild/template/battle_hostile_template",
        img_icon = "bt_icon_05",
        img_icon2 = "bt_icon_06",
    },
}

function GuildBattleTemplate:_init(view, args)
    self.parent = view
    self.ctrl = game.GuildCtrl.instance
    self.args = args
end

function GuildBattleTemplate:OpenViewCallBack()
    self:Init()
end

function GuildBattleTemplate:Init()
    local package = "ui_guild"
    for k, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path)
        local btn_tab = self._layout_objs["list_tab"]:GetChildAt(k-1)
        btn_tab:GetChild("img_icon"):SetSprite(package, v.img_icon)
        btn_tab:GetChild("img_icon2"):SetSprite(package, v.img_icon2)
    end
    self:RefreshView(self.args)
end

function GuildBattleTemplate:RefreshView(args)
    local open_idx = args and table.unpack(args) or 1
    self:GetRoot():GetController("ctrl_tab"):SetSelectedIndexEx(open_idx-1)
end

return GuildBattleTemplate