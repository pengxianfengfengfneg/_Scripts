local GuildTipsView = Class(game.BaseView)

local tips_config = require("game/guild/config/guild_tips_config")

function GuildTipsView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_tips_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Fouth
end

function GuildTipsView:_delete()
    
end

function GuildTipsView:OpenViewCallBack(tips_id, ...)
    self.tips_data = tips_config[tips_id]
    self:Init()
    self:SetData(...)
end

function GuildTipsView:CloseViewCallBack()

end

function GuildTipsView:Init()
    self.txt_content = self._layout_objs["txt_content"]
    self.btn_1 = self._layout_objs["btn_1"]
    self.btn_2 = self._layout_objs["btn_2"]
    self.ctrl_index = self:GetRoot():GetController("ctrl_index")
end

function GuildTipsView:SetData(...)
    local tips_data = self.tips_data
    if tips_data then
        self:GetBgTemplate("common_bg"):SetTitleName(tips_data.title):HideBtnBack()

        self:SetCtrlIndex(tips_data.index)
        self:SetContentText(tips_data.content)
        self:SetBtn(table.pack(...))

        if tips_data.init_func then
            tips_data.init_func(self, ...)
        end
    end
end

function GuildTipsView:SetContentText(content)
    if type(content) == "string" then
        self.txt_content:SetText(content)
        self.txt_content.align = 0
        self.txt_content.verticalAlign = 0
        self.txt_content:SetFontSize(24)
    elseif type(content) == "table" then
        self.txt_content:SetText(content.text)
        self.txt_content.align = content.horizontal_align or 0
        self.txt_content.verticalAlign = content.vertical_align or 0
        self.txt_content:SetFontSize(content.font_size or 24)
    end
end

function GuildTipsView:SetBtn(args)
    for k, v in ipairs(self.tips_data.btn_cfg or {}) do
        local btn = self["btn_"..k]
        if btn then
            btn:SetText(v.name)
            btn:AddClickCallBack(function()
                v.func(self, table.unpack(args))
            end)
        end
    end
end

function GuildTipsView:SetCtrlIndex(index)
    self.ctrl_index:SetSelectedIndexEx(index or 0)
end

return GuildTipsView
