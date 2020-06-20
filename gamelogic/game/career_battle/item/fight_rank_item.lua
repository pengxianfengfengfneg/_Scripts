local FightRankItem = Class(game.UITemplate)

function FightRankItem:_init(ctrl)
    self.ctrl = game.CareerBattleCtrl.instance
end

function FightRankItem:_delete()

end

function FightRankItem:OpenViewCallBack()
    self.txt_rank = self._layout_objs["txt_rank"]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_score = self._layout_objs["txt_score"]
    self.txt_guild = self._layout_objs["txt_guild"]

    self.img_rank = self._layout_objs["img_rank"]
    self.img_bg = self._layout_objs["img_bg"]
    self.img_bg2 = self._layout_objs["img_bg2"]
    self.img_career = self._layout_objs["img_career"]
    self.img_icon = self._layout_objs["img_icon"]

    self.btn_reward = self._layout_objs["btn_reward"]
    self.btn_reward:AddClickCallBack(function()
        if self.drop_id then
            self.ctrl:OpenFightRankRewardView(self.drop_id)
        end
    end)

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
end

function FightRankItem:CloseViewCallBack()
    
end

function FightRankItem:SetItemInfo(item_info, index)
    if item_info then
        self.txt_rank:SetText(item_info.rank)
        self.txt_name:SetText(item_info.name)
        self.txt_score:SetText(item_info.score)
        local guild_name = item_info.guild_name
        if guild_name == "" then
            guild_name = config.words[4837]
        end
        self.txt_guild:SetText(string.format(config.words[4836], guild_name))

        local cfg = config.role_icon[item_info.icon]
        if cfg then
            self.img_icon:SetSprite("ui_headicon", cfg.icon)
        end
        self.img_career:SetSprite("ui_common", "career"..item_info.career)

        if item_info.rank <= 3 then
            self.img_rank:SetSprite("ui_common", "pm_" .. item_info.rank)
            self.txt_rank:SetVisible(false)
        else
            self.img_rank:SetVisible(false)
        end
        self.drop_id = item_info.drop_id
        self.ctrl_state:SetSelectedIndexEx(0)
    else
        self.ctrl_state:SetSelectedIndexEx(1)
    end

    self.img_bg:SetVisible(index % 2 == 1)
    self.img_bg2:SetVisible(index % 2 == 0)
end

return FightRankItem