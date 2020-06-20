local GuildYunbiaoStartView = Class(game.BaseView)

function GuildYunbiaoStartView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_yunbiao_start"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function GuildYunbiaoStartView:_delete()
    
end

function GuildYunbiaoStartView:OpenViewCallBack()
	self:GetBgTemplate("common_bg"):SetTitleName(config.words[5301]):HideBtnBack()

    self._layout_objs["btn_start"]:AddClickCallBack(function()
    	self.ctrl:SendStartCarryReq()
    	self.ctrl:CloseGuildYunbiaoView()
    	self:Close()
    end)

    self._layout_objs["btn_cancel"]:AddClickCallBack(function()
        self:Close()
    end)

    local info = self.ctrl:GetYunbiaoData()
    local lv = game.Scene.instance:GetMainRoleLevel()
    local cost_coin = config_help.ConfigHelpCarry.GetCost(info.quality, lv) 
    local all_coin = game.BagCtrl.instance:GetCopper()
    self._layout_objs["cost_money"]:SetText(cost_coin)
    self._layout_objs["all_money"]:SetText(all_coin)

    self._layout_objs["quality"]:SetText(config.words[5304 + info.quality])
    local color = game.ItemColor2[info.quality+1]
    self._layout_objs["quality"]:SetColor(color[1], color[2], color[3], color[4])
end

function GuildYunbiaoStartView:CloseViewCallBack()
    
end

return GuildYunbiaoStartView