local ArenaView = Class(game.BaseView)

function ArenaView:_init(ctrl)
	self._package_name = "ui_arena"
    self._com_name = "arena_view"

    self._show_money = true
    
    self.ctrl = ctrl
    self.arena_data = self.ctrl:GetData()
end

function ArenaView:OpenViewCallBack(template_index)

	self.tab_controller = self:GetRoot():AddControllerCallback("tab_ctrl", function(idx)
		self:SelectTab(idx+1)
    end)

	self.tab_controller:SetSelectedIndexEx((template_index and template_index -1) or 0)

	self:InitRoleTemplate()

	self:InitEvent()

	self.ctrl:ArenaOpponentReq()

	self:SetLeftTimes()

	self:SetMyRankInfo()

	

	self:InitWzRole()

	for index = 1, 3 do
		self._layout_objs["click"..index]:SetTouchEnable(true)
		self._layout_objs["click"..index]:AddClickCallBack(function()
			self:OnClickModel(index)
	    end)
	end

    self._layout_objs["btn_close"]:AddClickCallBack(function()
		self.ctrl:CloseArenaView()
    end)

	self._layout_objs["btn_back"]:AddClickCallBack(function()
		self.ctrl:CloseArenaView()
    end)

	self._layout_objs["n20"]:AddClickCallBack(function()
		game.ShopCtrl.instance:OpenView(1003)
    end)

    self._layout_objs["n19"]:AddClickCallBack(function()
		self.ctrl:OpenRankView()
    end)

    self._layout_objs["btn_plus"]:AddClickCallBack(function()

    	local arena_data = game.ArenaCtrl.instance:GetData()
    	local buy_times = arena_data:GetBuyTimes()
    	local buy_cfg = config.arena_times[buy_times+1]

  		local my_vip = game.VipCtrl.instance:GetVipLevel()

  		local my_gold = game.BagCtrl.instance:GetGold()

  		-- if my_vip < buy_cfg.need_vip then
  		-- 	game.GameMsgCtrl.instance:PushMsg(config.words[2505])
  		-- 	return
  		-- end

  		-- if my_gold < buy_cfg.need_gold then
  		-- 	game.GameMsgCtrl.instance:PushMsg(config.words[2504])
  		-- 	return
  		-- end

  		---vip要传进去
  		local left_buy_times = arena_data:GetLeftBuyTimes()
  		local next_vip_buy_times = arena_data:GetNextVipBuyTimes(my_vip)

  		local str = string.format(config.words[2503], buy_cfg.need_gold, 5, left_buy_times, my_vip+1, next_vip_buy_times)

    	local msg_box = game.GameMsgCtrl.instance:CreateMsgBoxSec(config.words[102], str)
        msg_box:SetOkBtn(function()
        	self.ctrl:ArenaBuyTimesReq()
            msg_box:DeleteMe()
        end)
        msg_box:Open()
    end)
end

function ArenaView:CloseViewCallBack()
	self:DelTemplates()
	self:DelTimer()
	self:DelItems()
end

local pos_cfg = {
	[1] = {217, 143},
	[2] = {-1, 259},
	[3] = {450, 259},
}

function ArenaView:InitRoleTemplate()

	self.template_list = {}

	local role_template_class = require("game/arena/arena_role_template")

	for index = 1, 3 do
		local template = role_template_class.New(self)
		template:Open()
		template:SetParent(self._layout_objs["model_layer"])

		template:GetRoot():SetPosition(pos_cfg[index][1], pos_cfg[index][2])

		table.insert(self.template_list, template)
	end
end

function ArenaView:SetOpp()

end

function ArenaView:DelTemplates()
	for key, var in pairs(self.template_list or {}) do
		var:DeleteMe()
	end

	self.template_list = nil
end

function ArenaView:InitEvent()
	self:BindEvent(game.ArenaEvent.UpdateOpp, function(data)
        self:UpdateOpp()
    end)

	self:BindEvent(game.ArenaEvent.UpdateTimes, function(data)
        self:SetLeftTimes()
    end)
end

function ArenaView:UpdateOpp()

	local opp_data = self.arena_data:GetOppData()

	local one_info = opp_data.one

	self:UpdateSingleOpp(1, opp_data.one)
	self:UpdateSingleOpp(2, opp_data.two)
	self:UpdateSingleOpp(3, opp_data.three)
end

function ArenaView:UpdateSingleOpp(index, role_info)

	if self.template_list and self.template_list[index] then
		self.template_list[index]:UpdateInfo(role_info)
	end
end

function ArenaView:SetLeftTimes()

	self._layout_objs["n24"]:SetText(string.format(config.words[1709], self.arena_data:GetLeftTimes()))

	local reward_time = self.arena_data:GetRewardTime()
	local cur_time = global.Time:GetServerTime()
	local off_time = cur_time - reward_time
	local cfg_time = config.sys_config["arena_reward_times_cd"].value
	local left_time = cfg_time - off_time

	if left_time > 0 then
		self:SetTimer(left_time)
	else
		self:DelTimer()
		self._layout_objs["n25"]:SetText("")
	end
end

function ArenaView:SetTimer(left_time)

	self:DelTimer()

	local time = left_time

	self.timer = global.TimerMgr:CreateTimer(1,
    	function()
    		time = time - 1
    		local str = game.Utils.SecToTime2(time)
    		self._layout_objs["n25"]:SetText(str)

    		if time <= 0 then
    			self:DelTimer()
    		end
    	end)
end

function ArenaView:DelTimer()
	if self.timer then
    	global.TimerMgr:DelTimer(self.timer)
    	self.timer = nil
    end
end

function ArenaView:SetMyRankInfo()

	local my_rank = self.arena_data:GetMyRank()
	self._layout_objs["n16"]:SetText(tostring(my_rank))

	local combat = game.RoleCtrl.instance:GetCombatPower()
	self._layout_objs["n15"]:SetText(tostring(combat))

	self:SetAward(my_rank)
end

function ArenaView:OnClickModel(index)
	if self.template_list[index] then
		self.template_list[index]:OnClick()
	end
end

function ArenaView:GetAwardDropId(rank_num)

    local drop_id

    for key, var in ipairs(config.arena_rank_award) do

        if rank_num >= var.low and rank_num <= var.high then
            drop_id = var.drop_id
            break
        end
    end

    return drop_id
end

function ArenaView:SetAward(idx)

	self:DelItems()
	local drop_id = self:GetAwardDropId(idx)

    if drop_id then

        local index = 1
        local client_goods_list = config.drop[drop_id].client_goods_list

        for key, item_info in pairs(client_goods_list) do

            local item_root = self._layout_objs["award"..index]
            if item_root then
                local item = require("game/bag/item/goods_item").New()
                item:SetVirtual(item_root)
                item:Open()
                table.insert(self.item_list, item)

                item:SetItemInfo({ id = item_info[1], num = item_info[2]})
                item:SetShowTipsEnable(true)
                item_root:SetVisible(true)
            end
        end
    end
end

function ArenaView:DelItems()

	for index = 1,2 do
        self._layout_objs["award"..index]:SetVisible(false)
    end

    for key, var in pairs(self.item_list or {}) do

        var:DeleteMe()
    end

    self.item_list = {}
end

function ArenaView:SelectTab(tab_index)

	if tab_index == 1 then
		self._layout_objs["txt_title"]:SetText(config.words[1711])

		for index = 1, 3 do
			self._layout_objs["click"..index]:SetVisible(true)
		end
	else
		self._layout_objs["txt_title"]:SetText(config.words[1712])

		for index = 1, 3 do
			self._layout_objs["click"..index]:SetVisible(false)
		end
	end
end

function ArenaView:InitWzRole()

	self.wz_model_list = {}

	local main_role = game.Scene.instance:GetMainRole()

    local model_list = {
        [game.ModelType.Body]    = 110101,
        -- [game.ModelType.Wing]    = 101,
        [game.ModelType.Hair]    = 11001,
        [game.ModelType.Weapon]    = 1001,
    }

    for k,v in pairs(model_list) do
        local id = main_role:GetModelID(k)
        model_list[k] = (id>0 and id or v)
    end

	for index = 1, 4 do
		local model = require("game/character/model_template").New()
		model:CreateModel(self._layout_objs["wz_model"..index], game.BodyType.Role, model_list)
	    model:PlayAnim(game.ObjAnimName.Idle)
	    model:SetPosition(0,-1.4,3.2)
	    model:SetRotation(0,180,0)
	    model:SetScale(1.2)

	    table.insert(self.wz_model_list, model)

	    self._layout_objs["wz_model"..index]:SetTouchEnable(false)
	end

	for index = 1, 4 do
		self._layout_objs["wz_click"..index]:AddClickCallBack(function()
			----点击王者对手
			print("---------wz_click----------",index)
		end)
	end

	self:UpdateWzRoleInfo()
end

function ArenaView:UpdateWzRoleInfo()

	for index = 1, 4 do
		local career = 1
	    local model_id = career * 100000 + 10101
	    local hair_id = career * 10000 + 1001
	    local weapon_id = career * 1000 + 1

	    local model = self.wz_model_list[index]
	    model:SetModel(game.ModelType.Body, model_id)
	    model:SetModel(game.ModelType.Hair, hair_id)
	    model:SetModel(game.ModelType.Weapon, weapon_id)

	    model:PlayAnim(game.ObjAnimName.Idle)
	    self._layout_objs["role_group"..index]:SetVisible(true)
	end
end

return ArenaView