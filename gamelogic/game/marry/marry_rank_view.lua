local MarryRankView = Class(game.BaseView)

function MarryRankView:_init()
    self._package_name = "ui_marry"
    self._com_name = "marry_rank_view"

    self._show_money = true
end

function MarryRankView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1413])

    self:BindEvent(game.RankEvent.UpdateRightList, function(data)
        self:UpdateRank(data)
    end)

    game.RankCtrl.instance:GetRankDataReq(game.RankId.MarryLove, 1)
end

function MarryRankView:UpdateRank(data)
    if data.info.type == game.RankId.MarryLove then
        if data.info.page < data.info.total then
            game.RankCtrl.instance:GetRankDataReq(data.info.type, data.info.page + 1)
        else
            local rank_data = game.RankCtrl.instance:GetRankData()
            local rank_list = rank_data:GetRankDataByType(data.info.type)
            self:SetRankList(rank_list)
            local my_rank = rank_data:GetMyRank(data.info.type)
            self:SetMyRank(my_rank)
        end
    end
end

function MarryRankView:SetMyRank(rank_info)
    local sex = game.RoleCtrl.instance:GetSex()
    local career = game.RoleCtrl.instance:GetCareer()
    local main_role = game.Scene.instance:GetMainRole()
    local marry_info = game.MarryCtrl.instance:GetMarryInfo()

    self._layout_objs.love:SetText(game.MarryCtrl.instance:GetHisLove())
    if rank_info and rank_info[1] then
        self._layout_objs.my_rank_num:SetText(rank_info[1].item.rank)
        self._layout_objs.love:SetText(rank_info[1].item.columns[9].column)
        self._layout_objs.name_male:SetText(rank_info[1].item.columns[2].column)
        self._layout_objs.career_male:SetVisible(true)
        self._layout_objs.career_male:SetSprite("ui_common", "career" .. rank_info[1].item.columns[3].column)
        self._layout_objs.name_female:SetText(rank_info[1].item.columns[6].column)
        self._layout_objs.career_female:SetVisible(true)
        self._layout_objs.career_female:SetSprite("ui_common", "career" .. rank_info[1].item.columns[7].column)
    else
        self._layout_objs.my_rank_num:SetText(config.words[1425])
        if sex == game.Gender.Male then
            self._layout_objs.name_male:SetText(main_role:GetName())
            self._layout_objs.career_male:SetVisible(true)
            self._layout_objs.career_male:SetSprite("ui_common", "career" .. career)
            if marry_info.mate_id == 0 then
                self._layout_objs.name_female:SetText(config.words[2215])
                self._layout_objs.career_female:SetVisible(false)
            else
                self._layout_objs.name_female:SetText(marry_info.mate_name)
                self._layout_objs.career_female:SetVisible(true)
                self._layout_objs.career_female:SetSprite("ui_common", "career" .. marry_info.mate_career)
            end
        else
            self._layout_objs.name_female:SetText(main_role:GetName())
            self._layout_objs.career_female:SetVisible(true)
            self._layout_objs.career_female:SetSprite("ui_common", "career" .. career)
            if marry_info.mate_id == 0 then
                self._layout_objs.name_male:SetText(config.words[2215])
                self._layout_objs.career_male:SetVisible(false)
            else
                self._layout_objs.name_male:SetText(marry_info.mate_name)
                self._layout_objs.career_male:SetVisible(true)
                self._layout_objs.career_male:SetSprite("ui_common", "career" .. marry_info.mate_career)
            end
        end
    end
end

function MarryRankView:SetRankList(data)
    -- 排行榜字段 [ID, 名字, 职业, 头衔, ID, 名字, 职业, 头衔, 恩爱值]
    local rank_data = {}
    for _, v in ipairs(data) do
        local rank_item = {}
        rank_item.rank = v.item.rank
        rank_item.male_id = tonumber(v.item.columns[1].column)
        rank_item.male_name = v.item.columns[2].column
        rank_item.male_career = v.item.columns[3].column
        rank_item.male_honor = tonumber(v.item.columns[4].column)
        rank_item.female_id = tonumber(v.item.columns[5].column)
        rank_item.female_name = v.item.columns[6].column
        rank_item.female_career = v.item.columns[7].column
        rank_item.female_honor = tonumber(v.item.columns[8].column)
        rank_item.love_value = v.item.columns[9].column
        table.insert(rank_data, rank_item)
    end
    self:UpdateRankList(rank_data)
end

function MarryRankView:UpdateRankList(rank_data)
    local role_list = self:CreateList("list", "game/marry/item/rank_item")
    role_list:SetRefreshItemFunc(function(item, idx)
        local item_data = rank_data[idx]
        item:SetItemInfo(item_data)
        item:SetBg(idx % 2 == 1)
    end)
    role_list:SetItemNum(#rank_data)

end

return MarryRankView
