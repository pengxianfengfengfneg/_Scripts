local GuildResearchView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/product_template",
        item_class = "game/guild/template/research_template",
    },
    {
        item_path = "list_page/military_template",
        item_class = "game/guild/template/research_template",
    },
}

function GuildResearchView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_research_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildResearchView:OpenViewCallBack(open_idx)
    self:Init(open_idx)
    self:InitBg()
    self:RegisterAllEvents()
end

function GuildResearchView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UpdateGuildInfo, handler(self, self.UpdateFundsText)},
    }
    for k,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildResearchView:Init(open_idx)
    self.research_item = self:GetTemplate("game/guild/item/guild_research_item", "research_item")
    self.research_item:ShowCircle(false)

    self.txt_name = self._layout_objs.txt_name
    self.txt_cond = self._layout_objs.txt_cond
    self.txt_pre = self._layout_objs.txt_pre
    self.txt_desc = self._layout_objs.txt_desc
    self.txt_next_effect = self._layout_objs.txt_next_effect

    self.txt_cost = self._layout_objs.txt_cost
    self.txt_funds = self._layout_objs.txt_funds

    self.btn_research = self._layout_objs.btn_research
    self.btn_research:AddClickCallBack(function()
        if self.click_item_info then
            self.ctrl:SendGuildStudyUp(self.click_item_info.id)
        end
    end)

    self.click_item_info = nil

    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true, 23)
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
    end)

    self:InitView()
    self:UpdateFundsText()

    self.open_idx = open_idx or 1
    self.ctrl_page:SetSelectedIndexEx(self.open_idx-1)
end

function GuildResearchView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4778])
end

function GuildResearchView:InitView()
    for k, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path, k)
    end
end

function GuildResearchView:OnItemClick(item_info)
    if not item_info then
        return
    end

    self.click_item_info = item_info
    local info = config.guild_research_info[item_info.id]
    local cur_cfg = config.guild_research[item_info.id][item_info.lv]
    local next_cfg = config.guild_research[item_info.id][item_info.lv+1]

    self.txt_name:SetText(info.name .. string.format(config.words[5667], item_info.lv))
    self.txt_cond:SetText(string.format(config.words[4783], info.need_lv))
    self.txt_pre:SetText(self:GetPrevText(item_info.id, info.prev, info.need_num))
    self.txt_desc:SetText(cur_cfg and string.format(info.desc, cur_cfg.effect) or config.words[4779])
    self.txt_next_effect:SetText(next_cfg and string.format(info.desc, next_cfg.effect) or config.words[4779])
    self.txt_cost:SetText(next_cfg and next_cfg.cost or config.words[2399])

    self.research_item:SetItemInfo(info)
end

function GuildResearchView:UpdateFundsText()
    local funds = self.ctrl:GetGuildInfo().funds
    self.txt_funds:SetText(funds)
end

function GuildResearchView:GetClickItemInfo()
    return self.click_item_info
end

function GuildResearchView:GetOpenIndex()
    return self.open_idx
end

function GuildResearchView:GetClickItemId()
    if self.click_item_info then
        return self.click_item_info.id
    end
end

function GuildResearchView:GetPrevText(cur, prev, need_num)
    if prev == 0 and need_num == 0 then
        return config.words[4779]
    end

    local max_lv = prev ~= 0 and #config.guild_research[prev]
    local prev_str = prev ~= 0 and config.guild_research_info[prev].name..string.format(config.words[5663], max_lv) or ""
    local need_num_str = need_num ~= 0 and string.format(config.words[4784], need_num) or ""
    local split = (prev_str ~= "" and need_num_str ~= "") and ", " or ""
    return prev_str .. split .. need_num_str
end

return GuildResearchView
