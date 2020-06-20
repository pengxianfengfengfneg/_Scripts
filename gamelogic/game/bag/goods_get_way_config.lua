local goods_get_way = config.goods_get_way

--[[
	click_func 	跳转函数
	close_func  结束函数
]]
local _id_config = {
	-- 元宝商店购买
	[1] = {
        click_func = function(item_id)
			game.ShopCtrl.instance:OpenViewByShopId(1, item_id)
        end,
	},
	-- 绑元商店购买
	[2] = {
		click_func = function(item_id)
			game.ShopCtrl.instance:OpenViewByShopId(2, item_id)
        end,
	},
	-- 商会购买
	[4] = {
		click_func = function(item_id)
			game.MarketCtrl.instance:OpenBuyViewByItemId(item_id)
		end,
		close_func = function()
			game.MarketCtrl.instance:CloseView()
		end,
	},
	-- 拍卖行购买
	[5] = {
		click_func = function()
			game.AuctionCtrl.instance:CsAuctionInfo(true)
		end,
	},
	-- 随身商店
	[6] = {
		click_func = function()
			game.BagCtrl.instance:OpenBagShopView()
		end,
		close_func = function()
			game.BagCtrl.instance:CloseBagShopView()
		end,
	},
	-- 装备强化
	[11] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenView(1)
		end,
	},
	-- 镶嵌宝石
	[12] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenView(2)
		end,
	},
	-- 道具合成
	[13] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenView(4)
		end,
	},
	-- 英雄谱
	[14] = {
		click_func = function()
			game.HeroCtrl.instance:OpenView()
		end,
	},
	-- 经脉
	[15] = {
		click_func = function()
			local role_lv = game.RoleCtrl.instance:GetRoleLevel()
			local low_lv = 100
			for _, v in pairs(config.pulse) do
				if v.level < low_lv then
					low_lv = v.level
				end
			end
			if role_lv >= low_lv then
				game.HeroCtrl.instance:OpenView(2)
			else
				game.GameMsgCtrl.instance:PushMsg(low_lv .. config.words[2101])
			end
		end,
	},
	-- 经脉夺宝
	[16] = {
		click_func = function()
			local role_lv = game.RoleCtrl.instance:GetRoleLevel()
			local low_lv = 100
			for _, v in pairs(config.pulse) do
				if v.level < low_lv then
					low_lv = v.level
				end
			end
			if role_lv >= low_lv then
				game.HeroCtrl.instance:OpenTreasureView()
			else
				game.GameMsgCtrl.instance:PushMsg(low_lv .. config.words[2101])
			end
		end,
	},
	-- 珍兽属性
	[17] = {
		click_func = function()
			local pet_info = game.PetCtrl.instance:GetPetInfoById(1)
			game.PetCtrl.instance:OpenPetTrainView(pet_info)
		end,
	},
	-- 珍兽技能
	[18] = {
		click_func = function()
			local pet_info = game.PetCtrl.instance:GetPetInfoById(1)
			game.PetCtrl.instance:OpenPetTrainView(pet_info, 2)
		end,
	},
	-- 珍兽继承
	[19] = {
		click_func = function()
			game.PetCtrl.instance:OpenPetInheritView()
		end,
	},
	-- 珍兽附体
	[20] = {
		click_func = function()
			game.PetCtrl.instance:OpenPetFutiView()
		end,
	},
	-- 时装染色
	[21] = {
		click_func = function()
			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				game.BagCtrl.instance:CloseView()
				main_role:GetOperateMgr():DoGoToTalkNpc(37)
			end
		end,
	},
	-- 发型更换
	[22] = {
		click_func = function()
			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				game.BagCtrl.instance:CloseView()
				main_role:GetOperateMgr():DoGoToTalkNpc(38)
			end
		end,
	},
	-- 采集
	[23] = {
		click_func = function()
			game.SkillCtrl.instance:OpenView(2)
		end,
	},
	-- 装备打造
	[24] = {
		click_func = function()
		end,
	},
	-- 神器铸造
	[25] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenGodWeaponView(1)
		end,
	},
	-- 神器幻化
	[26] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenGodWeaponView(2)
		end,
	},
	-- 暗器打造
	[27] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenHideWeaponView(1)
		end,
	},
	-- 暗器打造
	[28] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenHideWeaponView(2)
		end,
	},
	-- 暗器升阶
	[29] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenHideWeaponView(3)
		end,
	},
	-- 暗器技能
	[30] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenHideWeaponView(4)
		end,
	},
	-- 头衔
	[31] = {
		click_func = function()
			game.RoleCtrl.instance:OpenHonorView()
		end,
	},
	-- 日常活动
	[32] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 限时活动
	[33] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(2)
		end,
	},
	-- 好友
	[34] = {
		click_func = function()
			game.FriendCtrl.instance:OpenFriendView()
		end,
	},
	-- 银两商店
	[35] = {
		click_func = function()
			game.ShopCtrl.instance:OpenViewByShopId(3)
		end,
	},
	-- 技能
	[36] = {
		click_func = function()
			game.SkillCtrl.instance:OpenView(1)
		end,
	},
	-- 每日礼包
	[37] = {
		click_func = function()
			game.RewardHallCtrl.instance:OpenView(2)
		end,
	},
	-- 游龙卡
	[38] = {
		click_func = function()
			game.RewardHallCtrl.instance:OpenView(3)
		end,
	},
	-- 英雄试炼
	[39] = {
		click_func = function()
			local main_role = game.Scene.instance:GetMainRole()
			local npc_id = config.sys_config.hero_trial_npc.value
			if main_role then
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				game.ViewMgr:CloseAllView()
			end
		end,
	},
	-- 老三环
	[40] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 燕子坞
	[41] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 四绝庄
	[42] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 缥缈峰
	[43] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 镜湖剿匪
	[44] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 藏宝图
	[45] = {
		go_visible = false,
	},
	-- 充值回馈
	[46] = {
		click_func = function()
			game.RechargeCtrl.instance:OpenView(3)
		end,
	},
	-- 累计充值
	[47] = {
		click_func = function()
			game.RechargeCtrl.instance:OpenView(2)
		end,
	},
	-- 玄武岛
	[48] = {
		click_func = function()
			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				game.ViewMgr:CloseAllView()
				main_role:GetOperateMgr():DoChangeScene(config.sys_config.scene_pet_catch_show.value)
			end
		end,
	},
	-- 神兽召唤
	[49] = {
		click_func = function()
			local main_role = game.Scene.instance:GetMainRole()
			local npc_id = config.pet_common.awaken_npc[1]
			if main_role then
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				game.ViewMgr:CloseAllView()
			end
		end,
	},
	-- 惩凶打图
	[50] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 稀世藏宝图
	[51] = {
		go_visible = false,
	},
	--帮会商店
	[52] = {
		click_func = function(item_id)
			game.ShopCtrl.instance:OpenViewByShopId(13, item_id)
		end,
	},
	-- 夺宝马贼
	[53] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 分金定穴
	[54] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 藏宝阁
	[55] = {
		click_func = function(item_id)
			game.ShopCtrl.instance:OpenViewByShopId(20, item_id)
		end,
	},
	-- 杂货商店 苏州
	[56] = {
		click_func = function()
			local cfg = goods_get_way[56]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
		operate_func = function()
			local cfg = goods_get_way[56]
			if cfg.param then
				local npc_id = cfg.param[2]
				local shop_id = cfg.param[3]
				return game.OperateType.GoToNpc,npc_id,function()
					game.ShopCtrl.instance:OpenViewByShopId(shop_id)
				end
			end
			return 
		end,
		close_func = function()
			game.ShopCtrl.instance:CloseView()
		end,
	},
	-- 杂货商店 洛阳
	[57] = {
		click_func = function()
			local cfg = goods_get_way[57]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
		operate_func = function()
			local cfg = goods_get_way[57]
			if cfg.param then
				local npc_id = cfg.param[2]
				local shop_id = cfg.param[3]
				return game.OperateType.GoToNpc,npc_id,function()
					game.ShopCtrl.instance:OpenViewByShopId(shop_id)
				end
			end
			return 
		end,
		close_func = function()
			game.ShopCtrl.instance:CloseView()
		end,
	},
	-- 杂货商店 聚贤庄
	[58] = {
		click_func = function()
			local cfg = goods_get_way[58]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
		operate_func = function()
			local cfg = goods_get_way[58]
			if cfg.param then
				local npc_id = cfg.param[2]
				local shop_id = cfg.param[3]
				return game.OperateType.GoToNpc,npc_id,function()
					game.ShopCtrl.instance:OpenViewByShopId(shop_id)
				end
			end
			return 
		end,
		close_func = function()
			game.ShopCtrl.instance:CloseView()
		end,
	},
	-- 杂货商店 天龙寺
	[59] = {
		click_func = function()
			local cfg = goods_get_way[59]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
		operate_func = function()
			local cfg = goods_get_way[59]
			if cfg.param then
				local npc_id = cfg.param[2]
				local shop_id = cfg.param[3]
				return game.OperateType.GoToNpc,npc_id,function()
					game.ShopCtrl.instance:OpenViewByShopId(shop_id)
				end
			end
			return 
		end,
		close_func = function()
			game.ShopCtrl.instance:CloseView()
		end,
	},
	-- 杂货商店 燕子坞
	[60] = {
		click_func = function()
			local cfg = goods_get_way[60]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
		operate_func = function()
			local cfg = goods_get_way[60]
			if cfg.param then
				local npc_id = cfg.param[2]
				local shop_id = cfg.param[3]
				return game.OperateType.GoToNpc,npc_id,function()
					game.ShopCtrl.instance:OpenViewByShopId(shop_id)
				end
			end
			return 
		end,
		close_func = function()
			game.ShopCtrl.instance:CloseView()
		end,
	},
	-- 杂货商店 夜西湖
	[61] = {
		click_func = function()
			local cfg = goods_get_way[61]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
		operate_func = function()
			local cfg = goods_get_way[61]
			if cfg.param then
				local npc_id = cfg.param[2]
				local shop_id = cfg.param[3]
				return game.OperateType.GoToNpc,npc_id,function()
					game.ShopCtrl.instance:OpenViewByShopId(shop_id)
				end
			end
			return 
		end,
		close_func = function()
			game.ShopCtrl.instance:CloseView()
		end,
	},
	-- 杂货商店 擂鼓山
	[62] = {
		click_func = function()
			local cfg = goods_get_way[62]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
		operate_func = function()
			local cfg = goods_get_way[62]
			if cfg.param then
				local npc_id = cfg.param[2]
				local shop_id = cfg.param[3]
				return game.OperateType.GoToNpc,npc_id,function()
					game.ShopCtrl.instance:OpenViewByShopId(shop_id)
				end
			end
			return 
		end,
		close_func = function()
			game.ShopCtrl.instance:CloseView()
		end,
	},
	-- 杂货商店 缥缈峰
	[63] = {
		click_func = function()
			local cfg = goods_get_way[63]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
		operate_func = function()
			local cfg = goods_get_way[63]
			if cfg.param then
				local npc_id = cfg.param[2]
				local shop_id = cfg.param[3]
				return game.OperateType.GoToNpc,npc_id,function()
					game.ShopCtrl.instance:OpenViewByShopId(shop_id)
				end
			end
			return 
		end,
		close_func = function()
			game.ShopCtrl.instance:CloseView()
		end,
	},
	-- 杂货商店 备用...
	[64] = {
		click_func = function()
			local cfg = goods_get_way[64]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
		operate_func = function()
			local cfg = goods_get_way[64]
			if cfg.param then
				local npc_id = cfg.param[2]
				local shop_id = cfg.param[3]
				return game.OperateType.GoToNpc,npc_id,function()
					game.ShopCtrl.instance:OpenViewByShopId(shop_id)
				end
			end
			return 
		end,
		close_func = function()
			game.ShopCtrl.instance:CloseView()
		end,
	},
	[65] = {
		click_func = function()
			local cfg = goods_get_way[65]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
				end
			end
		end,
	},
	-- 日常活动-每日任务
	[66] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 日常活动-帮会任务
	[67] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 日常活动-科举考试
	[68] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 日常活动-武林悬赏令
	[69] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 限时活动-珍珑棋局
	[70] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(2)
		end,
	},
	-- 限时活动-帮会练功
	[71] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(2)
		end,
	},
	-- 限时活动-帮会行酒令	
	[72] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(2)
		end,
	},
	-- 限时活动-帮会守卫战
	[73] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(2)
		end,
	},
	-- 限时活动-帮会领地战
	[74] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(2)
		end,
	},
	-- 限时活动-宋辽大战
	[75] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(2)
		end,
	},
	-- 背包-装备页
	[76] = {
		click_func = function()
			game.BagCtrl.instance:OpenView(2)
			game.BagCtrl.instance:CloseGoodsInfoView()
		end,
	},
	-- 外观-时装页
	[77] = {
		click_func = function()
			game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.Exterior, 2)
		end,
	},
	-- 技能-技能升级页
	[78] = {
		click_func = function()
			game.SkillCtrl.instance:OpenView()
		end,
	},
	-- 技能-修炼页
	[79] = {
		click_func = function()
			game.SkillCtrl.instance:OpenView(2)
		end,
	},
	-- 技能-采集页-采集指南页签
	[80] = {
		click_func = function()
			game.SkillCtrl.instance:OpenView(3)
		end,
	},
	-- 锻造-熔炼界面
	[81] = {
		click_func = function()
			game.FoundryCtrl.instance:OpenView(3)
		end,
	},
	-- 货币兑换-铜钱界面
	[82] = {
		click_func = function()
			game.MainUICtrl.instance:OpenMoneyExchangeView(2)
		end,
	},
	-- 货币兑换-银两界面
	[83] = {
		click_func = function()
			game.MainUICtrl.instance:OpenMoneyExchangeView(1)
		end,
	},
	-- 帮会福利界面
	[84] = {
		click_func = function()
			game.GuildCtrl.instance:OpenView(4)
			game.BagCtrl.instance:CloseGoodsInfoView()
		end,
	},
	-- 外观-坐骑页
	[85] = {
		click_func = function()
			game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.Exterior)
		end,
	},
	-- 武魂-精铸界面
	[86] = {
		click_func = function()
			game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.WeaponSoul, 1)
		end,
	},
	-- 龙纹-属性界面
	[87] = {
		click_func = function()
			game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.DragonDesign)
		end,
	},
	-- 日常活动-少室山
	[88] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 武魂-精魄界面
	[89] = {
		click_func = function()
			game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.WeaponSoul, 4)
		end,
	},
	-- 日常活动-跑环任务
	[90] = {
		click_func = function()
			game.ActivityMgrCtrl.instance:OpenActivityHallView(1)
		end,
	},
	-- 福利-找回界面
	[91] = {
		click_func = function()
			game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.BenifitHall, 7)
		end,
	},
	-- 珍兽繁殖
	[92] = {
		click_func = function()
			local cfg = goods_get_way[92]
			if cfg.param then
				local npc_id = cfg.param[2]
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
					game.ViewMgr:CloseAllView()
				end
			end
		end,
	},
	-- 商会-出售界面
	[93] = {
		click_func = function()
			game.MarketCtrl.instance:OpenView(2)
		end,
	},
}

local click_func = function()

end

local close_func = function()

end

local _et = {}
for _,v in pairs(goods_get_way) do
	local cfg = _id_config[v.type] or _et
	if cfg then
		v.click_func = cfg.click_func or click_func
		v.close_func = cfg.close_func or close_func
		v.operate_func = cfg.operate_func
		v.go_visible = cfg.go_visible
	end
end

return goods_get_way