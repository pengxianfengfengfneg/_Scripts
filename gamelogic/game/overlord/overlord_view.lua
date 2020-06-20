local OverlordView = Class(game.BaseView)

local boss_cd = config.sys_config.master_chap_cd.value
local rob_cd = config.sys_config.master_rob_cd.value
local hp_ratio = config.sys_config.master_chap_hp_ratio.value

function OverlordView:_init(ctrl)
    self._package_name = "ui_overlord"
    self._com_name = "overlord_view"

    self._show_money = true

    self.ctrl = ctrl
end

function OverlordView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[4601])
    

    self:InitBtn()

    self:BindEvent(game.OverlordEvent.Rank, function(data)
        self:UpdateRankRole(data.role)
        self:UpdateRankGuild(data.guild)
    end)

    self:BindEvent(game.OverlordEvent.Info, function(data)
        self:UpdateInfo(data)
    end)

    --self:BindEvent(game.ChatEvent.OpenChatView, function()
    --    self._layout_objs.chat_com:SetVisible(false)
    --end)
    --
    --self:BindEvent(game.ChatEvent.CloseChatView, function()
    --    self._layout_objs.chat_com:SetVisible(true)
    --end)

    --self:BindEvent(game.ChatEvent.UpdateNewChat, function(data)
    --    self:OnUpdateNewChat(data)
    --end)

    self:BindEvent(game.OverlordEvent.BossHP, function(data)
        self:UpdateHp(data)
    end)

    self:BindEvent(game.RankEvent.UpdateRightList, function(data)
        self:UpdateRank(data)
    end)

    self:SetActTime()

    self.ctrl:SendOverlordInfo()
    self.ctrl:SendOverlordRank()
    self.ctrl:SendRegister(1)

    local rank_data = self.ctrl:GetRankData()
    if rank_data then
        self:UpdateRankRole(rank_data.role)
        self:UpdateRankGuild(rank_data.guild)
    end

    local info = self.ctrl:GetInfo()
    if info then
        self:UpdateInfo(info)
    end
end

function OverlordView:CloseViewCallBack()
    self:StopRobCountTime()
    self:StopBossCountTime()
    self:StopActCountTime()
    self.ctrl:SendRegister(0)
end

function OverlordView:InitBtn()
    self._layout_objs.btn_boss:AddClickCallBack(function()
        self.ctrl:SendEnterOverlord()
    end)

    self._layout_objs.btn_score:AddClickCallBack(function()
        self.ctrl:OpenvRobListView()
    end)

    self._layout_objs.btn_record:AddClickCallBack(function()
        self.ctrl:OpenScoreLogView()
    end)

    self._layout_objs.chat_com:AddClickCallBack(function()
        game.ChatCtrl.instance:OpenView()
    end)

    --self.rtx_chat = self._layout_objs.chat_com:GetChild("rtx_chat")
    --self.rtx_chat:SetupEmoji("ui_emoji", 28, 28)
end

function OverlordView:UpdateRankRole(rank_data)
    local role_list = self:CreateList("self_list", "game/overlord/item/overlord_rank_item")
    local item_list = rank_data
    role_list:SetRefreshItemFunc(function(item, idx)
        local item_data = item_list[idx]
        item:SetRoleInfo(item_data)
        item:SetBg(idx % 2 == 1)
    end)
    role_list:SetItemNum(#item_list)

    local my_rank, my_score = 0, 0
    local role_id = game.RoleCtrl.instance:GetRoleId()
    for _, v in pairs(rank_data) do
        if v.id == role_id then
            my_rank = v.rank
            my_score = v.score
        end
    end
    if my_score == 0 then
        self._layout_objs.my_rank:SetText(config.words[1411])
    else
        self._layout_objs.my_rank:SetText(my_rank)
    end
    self._layout_objs.my_score:SetText(my_score)
end

function OverlordView:UpdateRankGuild(rank_data)

    local guild_list = self:CreateList("guild_list", "game/overlord/item/overlord_rank_item")
    local item_list = rank_data
    guild_list:SetRefreshItemFunc(function(item, idx)
        local item_data = item_list[idx]
        item:SetGuildInfo(item_data)
        item:SetBg(idx % 2 == 1)
    end)
    guild_list:SetItemNum(#item_list)

    local my_rank, my_score = 0, 0
    local guild_id = game.GuildCtrl.instance:GetGuildId()
    for _, v in pairs(rank_data) do
        if v.id == guild_id then
            my_rank = v.rank
            my_score = v.score
        end
    end
    if my_score == 0 then
        self._layout_objs.guild_rank:SetText(config.words[1411])
    else
        self._layout_objs.guild_rank:SetText(my_rank)
    end
    self._layout_objs.guild_score:SetText(my_score)
end

function OverlordView:UpdateInfo(data)
    if data.last_rob > 0 then
        self:StartRobCountTime(data.last_rob)
    end
    if data.last_chap > 0 then
        self:StartBossCountTime(data.last_chap)
    end

    self:UpdateHp(data.hp_pert)
end

function OverlordView:StartRobCountTime(refresh_time)
    self:StopRobCountTime()
    self.rob_tween = DOTween.Sequence()
    self.rob_tween:AppendCallback(function()
        local count_time = rob_cd + refresh_time - global.Time:GetServerTime()
        if count_time < 0 then
            self:StopRobCountTime()
        else
            self._layout_objs.btn_score:SetText(string.format("%02d:%02d", count_time // 60, count_time % 60))
        end
        count_time = count_time - 1
    end)
    self.rob_tween:AppendInterval(1)
    self.rob_tween:SetLoops(-1)
end

function OverlordView:StopRobCountTime()
    self._layout_objs.btn_score:SetText(config.words[4603])
    if self.rob_tween then
        self.rob_tween:Kill(false)
        self.rob_tween = nil
    end
end

function OverlordView:StartBossCountTime(refresh_time)
    self:StopBossCountTime()
    self.boss_tween = DOTween.Sequence()
    self.boss_tween:AppendCallback(function()
        local count_time = boss_cd + refresh_time - global.Time:GetServerTime()
        if count_time < 0 then
            self:StopBossCountTime()
        else
            self._layout_objs.btn_boss:SetText(string.format("%02d:%02d", count_time // 60, count_time % 60))
        end
        count_time = count_time - 1
    end)
    self.boss_tween:AppendInterval(1)
    self.boss_tween:SetLoops(-1)
end

function OverlordView:StopBossCountTime()
    self._layout_objs.btn_boss:SetText(config.words[4602])
    if self.boss_tween then
        self.boss_tween:Kill(false)
        self.boss_tween = nil
    end
end

function OverlordView:OnUpdateNewChat(data)
    local channel_name = game.ChatChannelWord[data.channel] or ""
    local color = game.ChatChannelColor[data.channel]
    local name_color = game.ChatGenderColor[data.sender.gender] or game.ColorString.Green
    local str_name = (data.sender.name ~= "" and (data.sender.name .. "：") or "")
    local str_content = ""
    if data.is_rumor then
        str_content = string.format("<font color='#%s'>%s</font>%s", name_color, str_name, data.content or "" )
    else
        str_content = string.format("<font color='#%s'>【%s】</font><font color='#%s'>%s</font>%s", color, channel_name, name_color, str_name, data.content or "" )

        str_content = string.gsub(str_content, "width=0 height=0", function()
            return "width=28 height=28"
        end)

    end
    self.rtx_chat:SetText(str_content)
end

function OverlordView:SetActTime()
    local act_info = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.Overlord)
    if act_info and act_info.state == game.ActivityState.ACT_STATE_ONGOING then
        self:StartActCountTime(act_info.end_time)
    else
        self._layout_objs.act_time:SetText("")
        self._layout_objs.act_text:SetText(config.words[4609])

        local rank_data = game.RankCtrl.instance:GetRankData()
        local role_rank_list = rank_data:GetRankDataByType(game.RankId.OverlordRole)
        if role_rank_list and #role_rank_list > 0 then
            self:SetRoleRankData(role_rank_list)
        else
            game.RankCtrl.instance:GetRankDataReq(game.RankId.OverlordRole, 1)
        end

        local guild_rank_list = rank_data:GetRankDataByType(game.RankId.OverlordGuild)
        if guild_rank_list and #guild_rank_list > 0 then
            self:SetGuildRankData(guild_rank_list)
        else
            game.RankCtrl.instance:GetRankDataReq(game.RankId.OverlordGuild, 1)
        end
    end
end

function OverlordView:StartActCountTime(end_time)
    self:StopActCountTime()
    self.act_tween = DOTween.Sequence()
    self.act_tween:AppendCallback(function()
        local count_time = end_time - global.Time:GetServerTime()
        if count_time < 0 then
            self:StopActCountTime()
        else
            self._layout_objs.act_text:SetText(config.words[4610])
            self._layout_objs.act_time:SetText(string.format("%02d:%02d", count_time // 60, count_time % 60))
        end
        count_time = count_time - 1
    end)
    self.act_tween:AppendInterval(1)
    self.act_tween:SetLoops(-1)
end

function OverlordView:StopActCountTime()
    self._layout_objs.act_time:SetText("")
    self._layout_objs.act_text:SetText(config.words[4609])
    if self.act_tween then
        self.act_tween:Kill(false)
        self.act_tween = nil
    end
end

local hp_color = { "jyt_01", "jyt_03", "jyt_04" }
function OverlordView:UpdateHp(hp)
    for _, v in ipairs(hp_ratio) do
        if hp >= v[1] and hp <= v[2] then
            self._layout_objs.score:SetSprite("ui_overlord", "mz_0" .. v[3])
            self._layout_objs["bar/bar"]:SetSprite("ui_common", hp_color[v[3]])
        end
    end
    self._layout_objs.bar:SetProgressValue(hp)
end

function OverlordView:UpdateRank(data)
    if data.info.type == game.RankId.OverlordRole then
        if data.info.page < data.info.total then
            game.RankCtrl.instance:GetRankDataReq(data.info.type, data.info.page + 1)
        else
            local rank_data = game.RankCtrl.instance:GetRankData()
            local rank_list = rank_data:GetRankDataByType(data.info.type)
            self:SetRoleRankData(rank_list)
        end
    end
    if data.info.type == game.RankId.OverlordGuild then
        if data.info.page < data.info.total then
            game.RankCtrl.instance:GetRankDataReq(data.info.type, data.info.page + 1)
        else
            local rank_data = game.RankCtrl.instance:GetRankData()
            local rank_list = rank_data:GetRankDataByType(data.info.type)
            self:SetGuildRankData(rank_list)
        end
    end
end

function OverlordView:SetRoleRankData(data)
    local rank_data = {}
    for _, v in ipairs(data) do
        local rank_item = {}
        rank_item.rank = v.item.rank
        rank_item.id = v.item.id
        rank_item.name = v.item.columns[1].column
        rank_item.career = tonumber(v.item.columns[2].column)
        rank_item.guild = v.item.columns[3].column
        rank_item.score = v.item.columns[4].column
        table.insert(rank_data, rank_item)
    end
    self:UpdateRankRole(rank_data)
end

function OverlordView:SetGuildRankData(data)
    local rank_data = {}
    for _, v in ipairs(data) do
        local rank_item = {}
        rank_item.rank = v.item.rank
        rank_item.id = v.item.id
        rank_item.name = v.item.columns[1].column
        rank_item.num = v.item.columns[2].column
        rank_item.chief = v.item.columns[3].column
        rank_item.score = v.item.columns[4].column
        table.insert(rank_data, rank_item)
    end
    self:UpdateRankGuild(rank_data)
end

return OverlordView
