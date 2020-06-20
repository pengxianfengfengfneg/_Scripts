local GuildWageItem = Class(game.UITemplate)

function GuildWageItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildWageItem:OpenViewCallBack()
    self:Init()
end

function GuildWageItem:Init()
    self.txt_name = self._layout_objs.txt_name
    self.txt_desc = self._layout_objs.txt_desc
    self.txt_money = self._layout_objs.txt_money
    self.txt_add = self._layout_objs.txt_add
    self.txt_progress = self._layout_objs.txt_progress

    self.img_money = self._layout_objs.img_money
    self.img_icon = self._layout_objs.img_icon

    self.btn_go = self._layout_objs.btn_go
    self.btn_go:AddClickCallBack(function()
        if self.go_event then
            self.go_event()
        end
    end)
end

function GuildWageItem:SetItemInfo(item_info, idx)
    local wage_config = config.guild_wages[item_info.id]
    self.txt_name:SetText(wage_config.name)
    self.txt_desc:SetText(wage_config.desc)
    self.txt_money:SetText(wage_config.bgold)
    self.txt_progress:SetText(string.format(config.words[4777], item_info.times, wage_config.times))

    self.img_icon:SetSprite("ui_activity", wage_config.icon, true)

    self:SetAddText()
end

function GuildWageItem:AddGoEvent(event)
    self.go_event = event
end

function GuildWageItem:SetAddText()
    local res_id = 1004
    local res_lv = self.ctrl:GetResearchLevel(res_id)
    local effect = (res_lv == 0) and 0 or config.guild_research[res_id][res_lv].effect
    local str = ""
    if effect ~= 0 then
        str = string.format("+%d", effect)
    end
    self.txt_add:SetText(str)
end

return GuildWageItem