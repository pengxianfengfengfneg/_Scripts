local GuildBonusView = Class(game.BaseView)

local config_bonus = config.guild_bonus

function GuildBonusView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_bonus_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildBonusView:_delete()

end

function GuildBonusView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitTabList()
    self:InitBounsList()
    self:RegisterAllEvents()
    self:Refresh()
end

function GuildBonusView:CloseViewCallBack()

end

function GuildBonusView:Init()
    self.txt_bonus_value = self._layout_objs["txt_bonus_value"]

    self._layout_objs["txt_top_info"]:SetText(config.words[2795])
    self._layout_objs["txt_base_bonus"]:SetText(config.words[2796])
    self._layout_objs["txt_bottom_info"]:SetText(config.words[2797])
end

function GuildBonusView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2794])
end

function GuildBonusView:InitTabList()
    local tab_num = #config_bonus

    self.ctrl_tabs = self:GetRoot():AddControllerCallback("ctrl_tabs",function(idx)
        self:OnClickTab(idx + 1)
    end)
    self.ctrl_tabs:SetPageCount(tab_num)

    self.list_tabs = self._layout_objs["list_tabs"]
    self.list_tabs:SetItemNum(tab_num)

    for idx, v in ipairs(config_bonus) do
        self.list_tabs:GetChildAt(idx - 1):SetText(config_bonus[idx][1].name)
    end

    self.index = self.index or 1
end

function GuildBonusView:OnClickTab(index)
    if index <= #config_bonus then
        self.index = index
        local bonus_data = config.guild_bonus[index]
        self:UpdateBonusList(bonus_data)
    end
end

function GuildBonusView:InitBounsList()
    self.list_bonus = self:CreateList("list_bonus", "game/guild/item/guild_bonus_item")
    self.list_bonus:SetRefreshItemFunc(function(item, idx)
        local item_info = self.bonus_list_data[idx]
        local bonus_info = self:GetBonusInfoById(item_info.type)
        item_info.times = bonus_info and bonus_info.times or 0
        item:SetItemInfo(item_info)
    end)
end

function GuildBonusView:UpdateBonusList(bonus_list_data)
    self.bonus_list_data = bonus_list_data or {}
    self.list_bonus:SetItemNum(#self.bonus_list_data)
end

function GuildBonusView:SetBonusValue()
    local bonus_value = self:CalcuteBonusValue()
    self.txt_bonus_value:SetText(bonus_value)
end

function GuildBonusView:Refresh()
    self.ctrl_tabs:SetSelectedIndexEx(self.index - 1)
    self:SetBonusValue()
end

function GuildBonusView:GetBonusInfoById(id)
    local guild_info = self.ctrl:GetGuildInfo()
    for k, v in pairs(guild_info.bonus or {}) do
        if v.id == id then
            return v
        end
    end
end

function GuildBonusView:CalcuteBonusValue()
    local guild_info = self.ctrl:GetGuildInfo()
    local bonus_cfg = config.guild_bonus
    local bonus = 0
    for k, v in pairs(guild_info.bonus or {}) do
        for j, k in ipairs(bonus_cfg[v.id]) do
            if v.times >= k.num then
                bonus = bonus + k.bonus
            else
                break
            end
        end
    end
    return bonus
end

function GuildBonusView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateGuildInfo] = function()
            self:Refresh()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildBonusView
