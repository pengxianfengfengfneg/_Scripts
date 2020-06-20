local PlatformSwornItem = Class(game.UITemplate)

function PlatformSwornItem:_init(ctrl)
    self.ctrl = game.SwornCtrl.instance
end

function PlatformSwornItem:OpenViewCallBack()
    self.txt_name = self._layout_objs.txt_name
    self.txt_level = self._layout_objs.txt_level
    self.txt_guild = self._layout_objs.txt_guild

    self.txt_tend_career = self._layout_objs.txt_tend_career
    self.txt_tend_lv = self._layout_objs.txt_tend_lv
    self.txt_tend_time = self._layout_objs.txt_tend_time

    self.img_career = self._layout_objs.img_career
    self.head_icon = self:GetIconTemplate("head_icon")

    self.btn_greet = self._layout_objs.btn_greet
    self.btn_greet:AddClickCallBack(function()
        if self.info then
            self.ctrl:SendSwornGreet(1, self.info.role_id)
        end
    end)
end

function PlatformSwornItem:SetItemInfo(item_info, idx)
    self.info = item_info

    self.txt_name:SetText(item_info.name)
    self.txt_level:SetText(string.format(config.words[6257], item_info.lv))
    self.txt_guild:SetText(string.format(config.words[6258], string.len(item_info.guild_name) > 0 and item_info.guild_name or config.words[6270]))

    self.txt_tend_career:SetText(string.format(config.words[6259], self:WrapperColor(self.ctrl:GetTendCareer(item_info.tend_career), game.ColorString.GrayBrown)))
    self.txt_tend_lv:SetText(string.format(config.words[6260], self:WrapperColor(self.ctrl:GetTendLevel(item_info.tend_lv), game.ColorString.GrayBrown)))
    self.txt_tend_time:SetText(string.format(config.words[6261], self:WrapperColor(self.ctrl:GetTendTime(item_info.tend_time), game.ColorString.GrayBrown)))

    self.img_career:SetSprite("ui_common", "career"..item_info.career)
    self.head_icon:UpdateData(item_info)

    local txt = self.ctrl:IsGreet(self.info.type, self.info.role_id) and config.words[6244] or config.words[6243]
    self.btn_greet:SetText(txt)
end

function PlatformSwornItem:WrapperColor(str, color)
    return string.format("[color=#%s]%s[/color]", color, str)
end

return PlatformSwornItem