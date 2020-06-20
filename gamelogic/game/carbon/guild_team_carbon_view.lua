local GuildTeamCarbonView = Class(game.BaseView)

function GuildTeamCarbonView:_init()
    self._package_name = "ui_carbon"
    self._com_name = "guild_team_carbon_view"

    self._show_money = true
end

function GuildTeamCarbonView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1426])

    self:InitList()
    self:InitBtn()
    self:InitModel()

    self:SetCurChapter()
    self:SetTimes()
end

function GuildTeamCarbonView:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function GuildTeamCarbonView:SetTimes()
    local dung_id = config.sh_dung_info[1].dung_id
    local dung_info = game.CarbonCtrl.instance:GetDungeDataByID(dung_id)

    local left_times = 1 - dung_info.chal_times
    self._layout_objs.challenge_times:SetText(left_times)
    local color = cc.GoodsColor[2]
    if left_times <= 0 then
        color = cc.GoodsColor[6]
    end
    self._layout_objs.challenge_times:SetColor(color.x, color.y, color.z, color.w)

    left_times = config.sys_config.sh_dung_assist_times.value - dung_info.assist_times
    self._layout_objs.help_times:SetText(left_times)
    local color = cc.GoodsColor[2]
    if left_times <= 0 then
        color = cc.GoodsColor[6]
    end
    self._layout_objs.help_times:SetColor(color.x, color.y, color.z, color.w)
end

function GuildTeamCarbonView:SetCurChapter()
    local guild_info = game.GuildCtrl.instance:GetGuildInfo()
    local cfg = config.sh_dung_info[guild_info.sh_cur_page]
    self.cur_chapter_cfg = cfg
    self._layout_objs.name:SetText(cfg.name)
    self.model:SetModel(game.ModelType.Body, cfg.model)
    self.model:PlayAnim(game.ObjAnimName.Idle)
end

function GuildTeamCarbonView:InitBtn()
    self._layout_objs.btn_start:AddClickCallBack(function()
        game.CarbonCtrl.instance:SendDungEnterTeam(self.cur_chapter_cfg.dung_id)
    end)
end

function GuildTeamCarbonView:InitList()
    local carbon_list = self:CreateList("list", "game/carbon/item/guild_team_carbon_item")
    carbon_list:SetRefreshItemFunc(function(item, idx)
        config.sh_dung_info[idx].id = idx
        item:SetItemInfo(config.sh_dung_info[idx])
    end)
    carbon_list:SetItemNum(#config.sh_dung_info)

    local reward_list = self:CreateList("reward", "game/bag/item/goods_item")
    local drop_id = config.sys_config.sh_dung_show_reward.value
    local rewards = config.drop[drop_id].client_goods_list
    reward_list:SetRefreshItemFunc(function(item, idx)
        local info = rewards[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)
    reward_list:SetItemNum(#rewards)
end

function GuildTeamCarbonView:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.model, game.BodyType.Monster)
    self.model:SetPosition(0, -1.15, 4.5)
    self.model:SetRotation(0, 140, 0)
end

return GuildTeamCarbonView