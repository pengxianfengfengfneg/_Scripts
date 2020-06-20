local GuildWageView = Class(game.BaseView)

local wage_config = require("game/guild/config/guild_wage_config")

function GuildWageView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_wage_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self:AddPackage("ui_activity")
end

function GuildWageView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendGuildWagesInfo()
end

function GuildWageView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.OnGuildWagesInfo, handler(self, self.OnGuildWagesInfo)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildWageView:Init()
    self.list_wage = self:CreateList("list_wage", "game/guild/item/guild_wage_item")
    self.list_wage:SetRefreshItemFunc(function(item, idx)
        local item_info = self.wage_list_data[idx]
        item:SetItemInfo(item_info)
        item:AddGoEvent(wage_config[item_info.id])
    end)
end

function GuildWageView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4780]):HideBtnBack()

    self._layout_objs["common_bg/btn_close"]:AddClickCallBack(function ()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_guild/guild_wage_view/btn_close"})
        self:Close()
    end)
end

function GuildWageView:OnGuildWagesInfo(stages)
    self.wage_list_data = {}

    for k, v in ipairs(stages) do
        if v.id ~= 1001 then
            table.insert(self.wage_list_data, v)
        end
    end
    table.sort(self.wage_list_data, function(m, n)
        return m.id < n.id
    end)

    self.list_wage:SetItemNum(#self.wage_list_data)
end

return GuildWageView
