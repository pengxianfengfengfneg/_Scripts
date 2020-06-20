local CarbonSjzTemplate = Class(game.UITemplate)

function CarbonSjzTemplate:_init()
	self._package_name = "ui_carbon"
    self._com_name = "carbon_sjz_template"
end

function CarbonSjzTemplate:OpenViewCallBack()
	self.item_list = {}

	self:SetLevelInfo()

	self._layout_objs["n12"]:AddClickCallBack(function()
		self:OnClickChallenge()
    end)

	self._layout_objs["n6"]:AddClickCallBack(function()
    	game.CarbonCtrl.instance:OpenRankView(1021)
    end)

	--装备商店
	if game.IsZhuanJia then
		self._layout_objs["n7"]:SetVisible(false)
	end
    self._layout_objs["n7"]:AddClickCallBack(function()
    	game.ShopCtrl.instance:OpenViewByShopId(3)
    end)

    local f = game.CarbonCtrl.instance:GetAutoChan()
    if f then
    	self._layout_objs["n14"]:SetSelected(true)
    else
    	self._layout_objs["n14"]:SetSelected(false)
    end

    self._layout_objs["n14"]:AddClickCallBack(function ()

    	local change_attr = self._layout_objs["n14"]:GetSelected()
    	game.CarbonCtrl.instance:SetAutoChan(change_attr)

    	if not change_attr then
    		self:DelTimer()
    		self._layout_objs["n15"]:SetText(config.words[1418])
    	else
    		game.CarbonCtrl.instance.sjz_carbon_success = true
    		self:AutoChan()
    	end
    end)

    -----排行前三
    self:BindEvent(game.RankEvent.UpdateRightList, function(data)
        self:UpdateList(self.cur_rank_type)
    end)

    self.cur_rank_type = 1021

	game.RankCtrl.instance:GetRankDataReq(self.cur_rank_type, 1)
	-----排行前三

	self:AutoChan()
end

function CarbonSjzTemplate:CloseViewCallBack()

	self:DelTimer()
	self:DelItems()
	self:DelModel()
end

function CarbonSjzTemplate:_delete()

end

function CarbonSjzTemplate:SetLevelInfo()

	local dunge_data = game.CarbonCtrl.instance:GetData()
	local dunge_info = dunge_data:GetDungeDataByID(300)
	local now_lv = dunge_info.now_lv or 0

	if now_lv == 0 then
		now_lv = 1
	end

	self.now_lv = now_lv

	--当前显示副本关卡范围
	local start_level = math.floor(now_lv/3)*3 + 1
	local end_level = start_level + 2

	self:DelModel()
	self.model_list = {}

	for index = 1, 3 do
		self:SetSinglevelInfo(index, start_level)
	end
end

function CarbonSjzTemplate:SetSinglevelInfo(index, start_level)

	--关卡级数
	local lv = start_level + index - 1
	local ui_index = index+15
	local lv_txt = self._layout_objs["n"..ui_index]:GetChild("text")
	lv_txt:SetText(string.format(config.words[1400], lv))

	local chapt, wave = game.CarbonCtrl.instance:GetDungeWaveAward(lv)
	local wave_award_drop = config.dungeon_lv[300][chapt].wave_award[wave][2]
	local client_goods_list = config.drop[wave_award_drop].client_goods_list
	self.chapt = chapt
	self.wave = wave

	for i = 1, 3 do
		local item_info = client_goods_list[i]
		local item_root = self._layout_objs["n"..ui_index]:GetChild("item"..i)

		local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(item_root)
        item:Open()
        table.insert(self.item_list, item)

        if item_info then
        	item:SetItemInfo({ id = item_info[1], num = item_info[2]})
        	item:SetShowTipsEnable(true)
        else
        	item:ResetItem()
        	item:SetShowTipsEnable(false)
        end
	end

	--是否通关标识
	if self.now_lv >= lv then
		self._layout_objs["n"..ui_index]:GetChild("tg_img"):SetVisible(true)
	else
		self._layout_objs["n"..ui_index]:GetChild("tg_img"):SetVisible(false)
	end

	self:SetAnim(ui_index)
end

function CarbonSjzTemplate:DelItems()
	
	for key, var in pairs(self.item_list or {}) do

		var:DeleteMe()
	end

	self.item_list = nil
end

function CarbonSjzTemplate:OnClickChallenge()
	game.CarbonCtrl.instance:DungEnterReq(300, self.now_lv)
end

function CarbonSjzTemplate:SetAnim(ui_index)

    local mon_id = config.dungeon_lv[300][self.chapt].wave_list[self.wave][3][1][1]
    local mon_model_id = config.monster[mon_id].model_id
    local ui_zoom = config.monster[mon_id].ui_zoom

	local model = require("game/character/model_template").New()
    model:CreateDrawObj(self._layout_objs["n"..ui_index]:GetChild("n10"), game.BodyType.Monster)
    model:SetPosition(0, -0.75, 3)
    model:SetScale(ui_zoom)
    model:SetRotation(0,180,0)

    self._layout_objs["n"..ui_index]:GetChild("n10"):SetVisible(true)

    model:SetModel(game.ModelType.Body, mon_model_id)
    model:PlayAnim(game.ObjAnimName.Idle)

    table.insert(self.model_list, model)
end

function CarbonSjzTemplate:DelModel()

	for key, model in pairs(self.model_list or {}) do
		model:DeleteMe()
	end
	self.model_list = nil
end

function CarbonSjzTemplate:UpdateList()

	local rank_data = game.RankCtrl.instance:GetRankData()
	local type_list = rank_data:GetRankDataByType(self.cur_rank_type)

	for index = 1, 3 do

		local item_data = type_list[index]
		if item_data then
		 	local rank = item_data.item.rank
        	self._layout_objs["r_n"..index]:SetText(tostring(rank))
        	self._layout_objs["r_name"..index]:SetText(tostring(item_data.item.columns[1].column))
        	self._layout_objs["r_level"..index]:SetText(tostring(item_data.item.columns[3].column)..config.words[1414])
        end
	end
end

function CarbonSjzTemplate:AutoChan()

	local f = game.CarbonCtrl.instance:GetSjzSuccessFlag()
	local f2 = game.CarbonCtrl.instance:GetAutoChan()

	if f and f2 then
		game.CarbonCtrl.instance:ResetSjzSuccessFlag()

		local limit_time = 11
		self.timer = global.TimerMgr:CreateTimer(1,
	    function()
	        limit_time = limit_time - 1

	        self._layout_objs["n15"]:SetText(config.words[1418] .. "(" .. limit_time .. ")")

	        if limit_time <= 0 then
	            self:DelTimer()
	            self:OnClickChallenge()
	        end
	    end)
	end
end

function CarbonSjzTemplate:DelTimer()

    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function CarbonSjzTemplate:StopCountTime()
	self._layout_objs["n15"]:SetText(config.words[1418])
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

return CarbonSjzTemplate