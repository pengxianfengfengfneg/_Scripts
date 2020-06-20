local GuildWelfareItem = Class(game.UITemplate)

local welfare_cfg = require("game/guild/config/guild_welfare_config")

function GuildWelfareItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildWelfareItem:_delete()

end

function GuildWelfareItem:OpenViewCallBack()
    self:Init()
end

function GuildWelfareItem:CloseViewCallBack()

end

function GuildWelfareItem:Init()
    self.txt_title = self._layout_objs.txt_title
    self.txt_content = self._layout_objs.txt_content

    self.img_icon_bg = self._layout_objs.img_icon_bg
    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2

    self.btn_open = self._layout_objs.btn_open
    self.btn_open:SetText(config.words[2771])
    self.btn_open:AddClickCallBack(handler(self, self.OnOpen))
end

function GuildWelfareItem:SetItemInfo(item_info, idx)
    self.idx = idx
    self.item_info = item_info
    self.txt_title:SetText(item_info.name)
    self.txt_content:SetText(item_info.desc)

    self.img_icon_bg:SetSprite("ui_guild", item_info.icon, true)
    self.func = welfare_cfg[item_info.id].func

    self.img_bg:SetVisible(idx % 2 == 1)
    self.img_bg2:SetVisible(idx % 2 == 0)
end

function GuildWelfareItem:SetBtnEnable(val)
    self.btn_open:SetEnable(val)
end

function GuildWelfareItem:OnOpen()
    if self.idx == 6 then
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_guild/guild_new_view/guild_welfare_template/btn_open6"})
    end
    if self.idx == 2 then
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_guild/guild_new_view/guild_welfare_template/btn_open2"})
    end

    if self.func then
        self.func()
    end
end

return GuildWelfareItem