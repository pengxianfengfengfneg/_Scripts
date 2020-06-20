local GuildBuildItem = Class(game.UITemplate)

function GuildBuildItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildBuildItem:OpenViewCallBack()
    self:Init()
end

function GuildBuildItem:CloseViewCallBack()

end

function GuildBuildItem:Init()
    self.txt_name = self._layout_objs.txt_name
    self.txt_level = self._layout_objs.txt_level
    self.txt_desc = self._layout_objs.txt_desc
    self.txt_cond = self._layout_objs.txt_cond
    self.txt_funds = self._layout_objs.txt_funds

    self.img_icon = self._layout_objs.img_icon
    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2

    self.btn_levelup = self._layout_objs.btn_levelup
    self.btn_levelup:AddClickCallBack(function()
        if self.id then
            self.ctrl:SendGuildBuildUp(self.id)
        end
    end)
end

function GuildBuildItem:SetItemInfo(item_info, idx)
    self.id = item_info.id

    local show_cfg = config.guild_build[item_info.id][1]
    self.txt_name:SetText(show_cfg.name)
    self.txt_level:SetText(string.format(config.words[5667], item_info.lv))
    self.txt_desc:SetText(show_cfg.desc)
    self.txt_cond:SetText(show_cfg.desc2)
    self.img_icon:SetSprite("ui_guild", show_cfg.icon, true)

    local build_cfg = config.guild_build[item_info.id][item_info.lv+1]
    if build_cfg then
        self.txt_funds:SetText(string.format(config.words[4776], build_cfg.cost_funds + self.ctrl:GetDenfFunds()*24))
    else
        self.txt_funds:SetText(config.words[2399])
    end

    self.img_bg:SetVisible(idx % 2 == 1)
    self.img_bg2:SetVisible(idx % 2 == 0)
end

return GuildBuildItem