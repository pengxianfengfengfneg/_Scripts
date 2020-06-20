local RoleCoinTemplate = Class(game.UITemplate)

local coin_cfg = {
	{
		name = config.words[5550],
		img = "0_01",
		get_func = function()
			return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.SongLiao)
		end,
		use_func = function()
			game.ShopCtrl.instance:OpenViewByShopId(18)
		end
	},
	-- {
	-- 	name = config.words[5551],
	-- 	img = "0_02",
	-- 	get_func = function()
	-- 		return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.WFuit)
	-- 	end,
	-- 	use_func = function()
	-- 		game.ShopCtrl.instance:OpenViewByShopId(19)
	-- 	end
	-- },
	{
		name = config.words[5552],
		img = "0_03",
		get_func = function()
			return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.TBall)
		end,
		use_func = function()
			game.ShopCtrl.instance:OpenViewByShopId(20)
		end
	},
	{
		name = config.words[5553],
		img = "0_04",
		get_func = function()
			return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.JiFen)
		end,
		use_func = function()
			game.ShopCtrl.instance:OpenViewByShopId(21)
		end
	},
	-- {
	-- 	name = config.words[5554],
	-- 	img = "0_05",
	-- 	get_func = function()
	-- 		return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.PeachValue)
	-- 	end,
	-- 	use_func = function()
	-- 		game.ShopCtrl.instance:OpenViewByShopId(22)
	-- 	end
	-- },
	-- {
	-- 	name = config.words[5555],
	-- 	img = "0_06",
	-- 	get_func = function()
	-- 		return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.LoveValue)
	-- 	end,
	-- 	use_func = function()
	-- 		game.ShopCtrl.instance:OpenViewByShopId(23)
	-- 	end
	-- },
	-- {
	-- 	name = config.words[5556],
	-- 	img = "0_07",
	-- 	get_func = function()
	-- 		return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Essence)
	-- 	end,
	-- 	use_func = function()
	-- 		game.ShopCtrl.instance:OpenViewByShopId(24)
	-- 	end
	-- },
	{
		name = config.words[5557],
		img = "0_08",
		get_func = function()
			return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.XiaYi)
		end,
		use_func = function()
			game.ShopCtrl.instance:OpenViewByShopId(25)
		end
	},
	-- {
	-- 	name = config.words[5558],
	-- 	img = "0_09",
	-- 	get_func = function()
	-- 		return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.FateToken)
	-- 	end,
	-- 	use_func = function()
	-- 		game.ShopCtrl.instance:OpenViewByShopId(26)
	-- 	end
	-- },
}

function RoleCoinTemplate:_init(view)
    self.ctrl = game.RoleCtrl.instance
end

function RoleCoinTemplate:OpenViewCallBack()
	self:RefreshMoney()
	self:BindEvent(game.MoneyEvent.Change, function()
		self:RefreshMoney()
	end)
end

function RoleCoinTemplate:CloseViewCallBack()

end

function RoleCoinTemplate:RefreshMoney()
	local idx = 1
	for i,v in ipairs(coin_cfg) do
		idx = i + 1
		self._layout_objs["cn" .. i]:SetText(v.name)
		self._layout_objs["cimg" .. i]:SetSprite("ui_common", v.img)
		self._layout_objs["cv" .. i]:SetText(v.get_func())
		self._layout_objs["cbtn" .. i]:AddClickCallBack(v.use_func)
	end

	for i=idx,9 do
		self._layout_objs["cn" .. i]:SetVisible(false)
		self._layout_objs["cimg" .. i]:SetVisible(false)
		self._layout_objs["cv" .. i]:SetVisible(false)
		self._layout_objs["cbtn" .. i]:SetVisible(false)
	end
end

return RoleCoinTemplate
