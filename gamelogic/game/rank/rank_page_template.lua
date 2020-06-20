local RankPageTemplate = Class(game.UITemplate)

function RankPageTemplate:_init(parent, param)
	self.parent = parent
	self.idx = param
	self.rank_data = game.RankCtrl.instance:GetRankData()
end

function RankPageTemplate:SetRankId(rank_id)
    self.rank_id = rank_id
end

function RankPageTemplate:GetRankId()
    return self.rank_id
end

function RankPageTemplate:OpenViewCallBack()

    self:BindEvent(game.RankEvent.UpdateRightList, function(data)
        if data.info.type == self.rank_id then
            self:UpdateList()
        end
    end)

    self:InitList()

    game.RankCtrl.instance:GetRankDataReq(self.rank_id, 1)

    self:SetTitleInfo()

    self:OnUpdateMyRank()
end

function RankPageTemplate:CloseViewCallBack()

    if self.ui_right_list then
        self.ui_right_list:DeleteMe()
        self.ui_right_list = nil
    end
end

function RankPageTemplate:InitList()

    self.ui_right_list = game.UIList.New(self._layout_objs["n4"])
    self.ui_right_list:SetVirtual(true)

    self.ui_right_list:SetCreateItemFunc(function(obj)

        local item = require("game/rank/rank_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_right_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_right_list:AddItemProviderCallback(function(idx)
        return "ui_rank:rank_template"
    end)

    self.ui_right_list:AddScrollEndCallback(function (perX, perY)
        if perY > 0 then
            game.RankCtrl.instance:GetNextPageData(self.rank_id)
        end
    end)

    self.ui_right_list:SetItemNum(0)
end

function RankPageTemplate:UpdateList()

    local type_list = self.rank_data:GetRankDataByType(self.rank_id)

    local num = #type_list

    self.ui_right_list:SetItemNum(num)

    self:OnUpdateMyRank()
end

function RankPageTemplate:OnUpdateMyRank()

    local my_rank_data = self.rank_data:GetMyRank(self.rank_id)

    if my_rank_data and my_rank_data[1] then

        local my_rank_num = my_rank_data[1].item.rank
        self._layout_objs["my_rank_num"]:SetText(string.format(config.words[1410], my_rank_num))

        self._layout_objs["my_column1"]:SetText(my_rank_data[1].item.columns[1].column)
        self._layout_objs["my_column2"]:SetText(my_rank_data[1].item.columns[2].column)

        local str = tostring(my_rank_data[1].item.columns[3].column)
        self._layout_objs["my_column3"]:SetText(str)

        if my_rank_data[1].item.columns[4] and tonumber(my_rank_data[1].item.columns[4].column) > 0 then
            self._layout_objs["my_column4"]:SetText(tostring(my_rank_data[1].item.columns[4].column))
        else
            self._layout_objs["my_column4"]:SetText("")
        end

        self._layout_objs["my_career_icon"]:SetSprite("ui_common", "career"..my_rank_data[1].item.columns[5].column)
    else
        self._layout_objs["my_rank_num"]:SetText(config.words[1425])

        local col_1 = self:GetMyColomnOne(self.rank_id)

        self._layout_objs["my_column2"]:SetText(tostring(col_1))

        local col_2 = self:GetMyColomnSec(self.rank_id)
        self._layout_objs["my_column1"]:SetText(tostring(col_2))

        local col_3 = self:GetMyColomnThird(self.rank_id)
        self._layout_objs["my_column3"]:SetText(tostring(col_3))

        local col_4 = self:GetMyColomnFour(self.rank_id)
        self._layout_objs["my_column4"]:SetText(tostring(col_4))
    end
end

function RankPageTemplate:SetTitleInfo()

    local rank_cfg = config.rank_ex[self.rank_id]
    self._layout_objs["title2"]:SetText(rank_cfg.desc3)
    self._layout_objs["title3"]:SetText(rank_cfg.desc1)
    self._layout_objs["title4"]:SetText(rank_cfg.desc2)

    if rank_cfg.desc1 == "" then
        self._layout_objs["title2"]:SetPosition(270, 95)
        self._layout_objs["my_career_icon"]:SetPosition(257, 1074)
        self._layout_objs["my_column1"]:SetPosition(313, 1065)
        self._layout_objs["my_column2"]:SetPosition(313, 1101)
    else
        self._layout_objs["title2"]:SetPosition(170, 95)
        self._layout_objs["my_career_icon"]:SetPosition(157, 1074)
        self._layout_objs["my_column1"]:SetPosition(213, 1065)
        self._layout_objs["my_column2"]:SetPosition(213, 1101)
    end
end



function RankPageTemplate:GetMyColomnOne(rank_id)

    --帮会名称
    local column1 = {1001, 1002,1004,2001,2002,2003,2004}
    for k, v in pairs(column1) do
        if v == rank_id then

            local guild_name = game.GuildCtrl.instance:GetGuildName()
            return guild_name
        end
    end

    --玩家名字
    local column2 = {1003,3001,3002,3003,3004,3005,3006,3007,3008}
    for k, v in pairs(column2) do
        if v == rank_id then

            local role_name = game.Scene.instance:GetMainRoleName()
            return role_name
        end
    end

    --帮主名称
    local column3 = {4001,4002,4003}
    for k, v in pairs(column3) do
        if v == rank_id then

            local guilder_name = game.GuildCtrl.instance:GetChiefName()
            return guilder_name
        end
    end
end

function RankPageTemplate:GetMyColomnSec(rank_id)

    --玩家名字
    local column1 = {1001, 1002,1004,2001,2002,2003,2004}
    for k, v in pairs(column1) do
        if v == rank_id then

            local role_name = game.Scene.instance:GetMainRoleName()
            return role_name
        end
    end

    if rank_id == 1003  then
        local pet_name = ""
        local pet_info = game.PetCtrl.instance:GetFightingPet()
        if pet_info then
            pet_name = pet_info.name
        end
        return pet_name
    end

    local pos = 0
    if rank_id == 3001 then
        pos = 1
    end

    if rank_id == 3002 then
        pos = 5
    end

    if rank_id == 3003 then
        pos = 2
    end

    if rank_id == 3004 then
        pos = 6
    end

    if rank_id == 3005 then
        pos = 3
    end

    if rank_id == 3006 then
        pos = 7
    end

    if rank_id == 3007 then
        pos = 4
    end

    if rank_id == 3008 then
        pos = 8
    end

    if pos > 0 then
        local equip_name = ""
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)
        if equip_info and equip_info.id > 0 then
            equip_name = config.goods[equip_info.id].name
        end

        return equip_name
    end

    --帮会名称
    local column3 = {4001,4002,4003}
    for k, v in pairs(column3) do
        if v == rank_id then

            local guild_name = game.GuildCtrl.instance:GetGuildName()
            return guild_name
        end
    end
end

function RankPageTemplate:GetMyColomnThird(rank_id)

    if rank_id == 1001 then
        local role_lv = game.RoleCtrl.instance:GetRoleLevel()
        return role_lv
    end

    if rank_id == 1004 then
        local max_lv = 0
        local dunge_data = game.CarbonCtrl.instance:GetData()
        local hero_dun_data = dunge_data:GetDungeDataByID(550)
        if hero_dun_data then
            max_lv = hero_dun_data.max_lv
        end
        return max_lv
    end

    if rank_id == 4001 or rank_id == 4002 then
        local lv = game.GuildCtrl.instance:GetGuildLevel()
        return lv
    end

    if rank_id == 4003 then
        local score = game.OverlordCtrl.instance:GetSelfScore()
        return score
    end

    --战力
    local combat_power = game.RoleCtrl.instance:GetCombatPower()
    return combat_power
end

function RankPageTemplate:GetMyColomnFour(rank_id)
    if rank_id == 4001 then
        local combat_power = game.RoleCtrl.instance:GetCombatPower()
        return combat_power
    end

    if rank_id == 4002 then
        if game.GuildCtrl.instance:IsGuildMember() then
            return game.GuildCtrl.instance:GetGuildInfo().recently_live
        else
            return 0
        end
    end

    if rank_id == 4003 then
        return 0
    end

    return ""
end

return RankPageTemplate