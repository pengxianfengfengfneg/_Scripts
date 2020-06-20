local WorldBossHurtRankView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format

function WorldBossHurtRankView:_init(ctrl)
    self._package_name = "ui_world_boss"
    self._com_name = "world_boss_hurt_rank_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function WorldBossHurtRankView:OpenViewCallBack(boss_id, hp_lmt, rank_list)
    self.boss_id = boss_id
    self.boss_hp_lmt = hp_lmt
    self.rank_list = rank_list

    print("boss_id, hp_lmt, rank_list XXX", boss_id, hp_lmt, rank_list)

    self:Init()
    self:InitBg()

    self:RegisterAllEvents()
end

function WorldBossHurtRankView:CloseViewCallBack()
    
end

function WorldBossHurtRankView:RegisterAllEvents()
    local events = {
        {game.WorldBossEvent.UpdateHurtRank, handler(self, self.OnUpdateHurtRank)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function WorldBossHurtRankView:Init()
    self.guild_id = game.GuildCtrl.instance:GetGuildId()

    self.txt_self_guild_name = self._layout_objs["txt_self_guild_name"]
    self.txt_self_guild_rank = self._layout_objs["txt_self_guild_rank"]
    self.txt_self_guild_hurt = self._layout_objs["txt_self_guild_hurt"]

    self:InitBase()
    self:UpdateRank(self.rank_list)
end

function WorldBossHurtRankView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1669])
end

function WorldBossHurtRankView:OnEmptyClick()
    self:Close()
end

function WorldBossHurtRankView:InitBase()
    for i=1,5 do
        local txt_guild = self._layout_objs["txt_guild_" .. i]
        if txt_guild then
            txt_guild:SetText(config.words[4450])

            local bar = self._layout_objs["bar_" .. i]
            bar:SetValue(0)

            local txt_hurt = self._layout_objs["txt_hurt_" .. i]
            txt_hurt:SetText("0%")
            
        end
    end

    local guild_name = game.GuildCtrl.instance:GetGuildName()
    self.txt_self_guild_name:SetText(string.format(config.words[4454], guild_name))
    self.txt_self_guild_rank:SetText(string.format(config.words[4455], config.words[4450]))
    self.txt_self_guild_hurt:SetText(string.format(config.words[4456],0))
end

function WorldBossHurtRankView:UpdateRank(rank_list)
    table.sort(rank_list, function(v1,v2)
        return v1.harm>v2.harm
    end)

    for k,v in ipairs(rank_list or {}) do
        local hurt_percent = (v.harm/self.boss_hp_lmt)*100
        local str_percent = string.format("%.2f%%", hurt_percent)

        local txt_guild = self._layout_objs["txt_guild_" .. k]
        if txt_guild then
            txt_guild:SetText(v.guild_name)

            local bar = self._layout_objs["bar_" .. k]
            bar:SetValue(hurt_percent)

            local txt_hurt = self._layout_objs["txt_hurt_" .. k]
            txt_hurt:SetText(str_percent)
            
        end

        if v.guild_id == self.guild_id then
            self.txt_self_guild_name:SetText(string.format(config.words[4454], v.guild_name))
            self.txt_self_guild_rank:SetText(string.format(config.words[4455], k))
            self.txt_self_guild_hurt:SetText(string.format(config.words[4456], str_percent))
        end
    end
end

function WorldBossHurtRankView:OnUpdateHurtRank(data)
    for _,v in ipairs(data) do
        if v.boss_rank.boss_id == self.boss_id then
            self:UpdateRank(v.boss_rank.rank_list)
            break
        end
    end
end

return WorldBossHurtRankView
