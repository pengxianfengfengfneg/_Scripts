local GuildYunbiaoView = Class(game.BaseView)

local max_carry_times = config.carry_common.carry_times

function GuildYunbiaoView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_yunbiao"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function GuildYunbiaoView:_delete()
    
end

function GuildYunbiaoView:OpenViewCallBack()
	self.is_max_times = false
	
    --刷新品质
    self._layout_objs["refresh_btn"]:AddClickCallBack(function()
    	if self:CheckYunbiao(true) then
	    	self.ctrl:SendRefreshCarryReq(1)
	    end
    end)

    --领橙色镖
    self._layout_objs["get_btn"]:AddClickCallBack(function()
    	if self:CheckYunbiao(true) then
    		if game.BagCtrl.instance:GetNumById(config.carry_common.onekey_refresh_item) == 0 then
    			local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(config.words[5304], config.words[1660])
    			msg_box:SetBtn1(config.words[101], function()

    			end)
    			msg_box:SetBtn2(config.words[100], function()
    				game.ShopCtrl.instance:OpenViewByShopId(2, config.carry_common.onekey_refresh_item)
    			end)
    			msg_box:Open()
    		else
	    		self.ctrl:SendRefreshCarryReq(2)
	    	end
	    end
    end)

    --开启运镖
    self._layout_objs["start_btn"]:AddClickCallBack(function()
    	if self:CheckYunbiao(true) then
			game.GuildCtrl.instance:OpenGuildYunbiaoStartView()
		end
    end)

    self:BindEvent(game.GuildEvent.YunbiaoInfoChange, function()
    	self:RefreshInfo()
    end)

    self:InitBg()
    self:InitRewards()
    self:RefreshInfo()
end

function GuildYunbiaoView:CloseViewCallBack()
	for i,v in ipairs(self.carry_list) do
		v:DeleteMe()
	end
	self.carry_list = nil
end

function GuildYunbiaoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1417])
end

function GuildYunbiaoView:InitRewards()
	self.carry_list = {}
	local ls = self._layout_objs["carry_list"]
	ls:SetTouchEnable(false)
	for i=1,4 do
		local item = require("game/guild/item/guild_yunbiao_com").New(i)
		item:SetVirtual(ls:GetChild("item" .. i))
		item:Open()
		table.insert(self.carry_list, item)
	end
    self._layout_objs["refresh_btn_txt"]:SetText(string.format(config.words[5303], config.carry_common.refresh_cost))
end

function GuildYunbiaoView:RefreshInfo()
    local info = self.ctrl:GetYunbiaoData()
    if not info or (info.quality == 0 and info.carry_times<max_carry_times) then
    	self.ctrl:SendBookCarryReq()
    	return
	end

	self.is_max_times = info.carry_times>=max_carry_times
	
	self._layout_objs["get_btn"]:SetEnable(info.quality ~= 4)
	self._layout_objs["refresh_btn"]:SetEnable(info.expire_time == 0)
	self._layout_objs["start_btn"]:SetEnable(info.expire_time == 0)

    self:GetRoot():GetController("c1"):SetSelectedIndexEx(info.quality - 1)

	self._layout_objs["carry_times"]:SetText(string.format(config.words[5300], info.carry_times, config.carry_common.carry_times))

    if info.refresh_times == 0 then
        self._layout_objs["free_refresh_btn_txt"]:SetVisible(true)
        self._layout_objs["refresh_money_icon"]:SetVisible(false)
        self._layout_objs["refresh_btn_txt"]:SetVisible(false)
    else
        self._layout_objs["free_refresh_btn_txt"]:SetVisible(false)
        self._layout_objs["refresh_money_icon"]:SetVisible(true)
        self._layout_objs["refresh_btn_txt"]:SetVisible(true)
    end
end

function GuildYunbiaoView:CheckYunbiao(is_tips)
	if self.is_max_times then
		if is_tips then
			game.GameMsgCtrl.instance:PushMsg(config.words[5302])
		end
		return false
	end
	return true
end

return GuildYunbiaoView
