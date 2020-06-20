local GuildCreateView = Class(game.BaseView)

local CheckMaskWords = game.Utils.CheckMaskWords

function GuildCreateView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_create_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function GuildCreateView:_delete()
    
end

function GuildCreateView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function GuildCreateView:Init()
    self.guild_type = 1

    self.label_guild_name = self._layout_objs["label_guild_name"]
    self.label_guild_name:SetText(config.words[2313])

    self.txt_cost = self._layout_objs["txt_cost"]
    self.txt_cost:SetText(config.guild_create[self.guild_type].silver)

    self.txt_num = self._layout_objs["txt_num"]
    self.txt_num:SetText(string.format(config.words[6002], config.guild_build[1002][1].effect))

    self.txt_announce = self._layout_objs["txt_announce"]

    self.img_money = self._layout_objs["img_money"]
    self.img_money:SetSprite("ui_common", config.money_type[game.MoneyType.Silver].icon)

    self.txt_guild_name = self._layout_objs["txt_guild_name"]
    self.btn_create_guild = self._layout_objs["btn_create_guild"]

    self.btn_create_guild:AddClickCallBack(function()
        local guild_name = self.txt_guild_name:GetText()
        local announce = self.txt_announce:GetText()
        if CheckMaskWords(guild_name) then
            game.GameMsgCtrl.instance:PushMsg(config.words[6000])
        elseif CheckMaskWords(announce) then
            game.GameMsgCtrl.instance:PushMsg(config.words[6001])
        else
            self.ctrl:SendGuildCreate(self.guild_type, guild_name, announce)
        end
    end)

    self:RegisterAllEvents()
end

function GuildCreateView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2311]):HideBtnBack()

    self.btn_create_guild:SetText(config.words[2311])
end

function GuildCreateView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.CreateGuild] = function(guild_id)
            self.ctrl:OpenGuildNewView()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildCreateView
