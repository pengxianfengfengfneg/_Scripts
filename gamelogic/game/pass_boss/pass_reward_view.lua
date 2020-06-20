local PassRewardView = Class(game.BaseView)

function PassRewardView:_init(ctrl)
    self._package_name = "ui_pass_boss"
    self._com_name = "pass_reward_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function PassRewardView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitBtns()
    self:InitReward()

end

function PassRewardView:CloseViewCallBack()
    if self.reward_item then
        self.reward_item:DeleteMe()
        self.reward_item = nil
    end
end

function PassRewardView:Init()
    local reward_list = self.ctrl:GetPassRewardList()

    table.sort(reward_list, function(v1, v2)
        return v1.pass<v2.pass
    end)

    self.pass_id = reward_list[1].pass

    self.pass_cfg = config.task_pass[self.pass_id]

    self.txt_desc = self._layout_objs["txt_desc"]
    self.txt_desc:SetText(string.format(config.words[2157],self.ctrl:GetSectionName(self.pass_id)))
end

function PassRewardView:InitBtns()
    self.btn_get = self._layout_objs["btn_get"]
    self.btn_get:AddClickCallBack(function()
        self.ctrl:SendGetPassRewardReq(self.pass_id)
        self:Close()
    end)

end

function PassRewardView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1658]):HideBtnBack()
end

function PassRewardView:InitReward()
    local drop_id = self.ctrl:GetPassSectionRewardId(self.pass_id)
    local drop_cfg = config.drop[drop_id] or {}
    local drop_goods = drop_cfg.client_goods_list or {}
    local drop_item = drop_goods[1]

    local info = {
        id = drop_item[1],
        num = drop_item[2] 
    }
    self.reward_item = game_help.GetGoodsItem(self._layout_objs["item"])
    self.reward_item:SetItemInfo(info)
    self.reward_item:SetShowTipsEnable(true)
end

function PassRewardView:OnEmptyClick()
    self:Close()
end


return PassRewardView
