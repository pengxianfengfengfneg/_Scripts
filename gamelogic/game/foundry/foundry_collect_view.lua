local FoundryCollectView = Class(game.BaseView)

function FoundryCollectView:_init(ctrl)
	self._package_name = "ui_foundry"
    self._com_name = "foundry_collect_view"

    self.ctrl = ctrl
end

function FoundryCollectView:OpenViewCallBack()

	self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1232])

	self:InitTopList()

	self:Setvitality()

	--升级
    self._layout_objs["n13"]:AddClickCallBack(function()

    	if not self.guild_lv_cond then
    		game.GameMsgCtrl.instance:PushMsg(config.words[1236])
    		return
    	end

    	if not self.guild_gold_cond then
    		game.GameMsgCtrl.instance:PushMsg(config.words[1235])
    		return
    	end

    	local str = string.format(config.words[1234], self.need_guild_gold )
    	local msg_box = game.GameMsgCtrl.instance:CreateMsgBoxSec(config.words[102], str)
        msg_box:SetOkBtn(function()
            self.ctrl:CsGatherUpgrade()
            msg_box:DeleteMe()
        end)
        msg_box:Open()

    end)

    self:BindEvent(game.FoundryEvent.GatherUpgrade, function()
        self:Setvitality()
    end)
end

function FoundryCollectView:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end
end

function FoundryCollectView:InitTopList()

	local item_num = #config.gather_item

	self.list = self._layout_objs["n5"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/foundry/foundry_collect_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddClickItemCallback(function(item)

    end)

    self.ui_list:SetItemNum(item_num)
end

function FoundryCollectView:Setvitality()

	local foundry_data = self.ctrl:GetData()
	local gather_data = foundry_data:GetGatherData()
	local vitality = gather_data.vitality
	local level = gather_data.level
	local cd = config.sys_config["gather_reward_vitality_cd"].value
	local max_vitality = config.sys_config["gather_max_store_vitality"].value

	self._layout_objs["n3"]:SetProgressValue(vitality/max_vitality*100)
	self._layout_objs["n3"]:GetChild("title"):SetText(vitality.."/"..max_vitality)

	self._layout_objs["cur_lv"]:SetText(level..config.words[1217])

	local own_money = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.GuildGold)
	local need_guild_gold = config.gather_level[level].currency
	self.need_guild_gold = need_guild_gold
	self._layout_objs["tb_txt"]:SetText(own_money.."/"..need_guild_gold)

	if own_money >= need_guild_gold then
		self.guild_gold_cond = true
		self._layout_objs["tb_txt"]:SetColor(112,83,52,255)
	else
		self.guild_gold_cond = false
		self._layout_objs["tb_txt"]:SetColor(255,0,0,255)
	end
	local need_guild_lv = config.gather_level[level].guild_lv
	local cur_guild_lv = game.GuildCtrl.instance:GetGuildLevel()

	self._layout_objs["guild_lv_txt"]:SetText(string.format(config.words[1231], tostring(need_guild_lv), tostring(cur_guild_lv)))

	if cur_guild_lv >= need_guild_lv then
		self.guild_lv_cond = true
		self._layout_objs["guild_lv_txt"]:SetColor(112,83,52,255)
	else
		self.guild_lv_cond = false
		self._layout_objs["guild_lv_txt"]:SetColor(255,0,0,255)
	end

end

return FoundryCollectView