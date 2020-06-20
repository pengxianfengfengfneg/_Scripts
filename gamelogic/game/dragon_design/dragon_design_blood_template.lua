local DragonDesignBloodTemplate = Class(game.UITemplate)

function DragonDesignBloodTemplate:_init(parent)
	self.parent = parent
	self.ctrl = game.DragonDesignCtrl.instance
	self.dragon_design_data = self.ctrl:GetData()
end

function DragonDesignBloodTemplate:_delete()
end

function DragonDesignBloodTemplate:OpenViewCallBack()

	self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs["cost_item"])
    self.cost_item:Open()

	self:InitView()

	self:InitNewQuality()

	self._layout_objs["xl_btn"]:AddClickCallBack(function()
		if self.dragon_design_data:CanSaveRefine() then
			local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[6157])
	        msg_box:SetOkBtn(function()
	            self.ctrl:CsDragonRefine()
	            msg_box:DeleteMe()
	        end)
	        msg_box:SetCancelBtn(function()
	        end)
	        msg_box:Open()
		else
			self.ctrl:CsDragonRefine()
		end
    end)

    self._layout_objs["save_btn"]:AddClickCallBack(function()
    	if not self.dragon_design_data:CanSaveRefine() then
			local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[6167])
	        msg_box:SetOkBtn(function()
	            self.ctrl:CsDragonReplace()
	            msg_box:DeleteMe()
	        end)
	        msg_box:SetCancelBtn(function()
	        end)
	        msg_box:Open()
		else
			self.ctrl:CsDragonReplace()
		end
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateRefine, function(data)
    	self:InitNewQuality()
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateReplace, function(data)
    	self:InitView()
    	self:InitNewQuality()
    end)
end

function DragonDesignBloodTemplate:CloseViewCallBack()
	if self.cost_item then
        self.cost_item:DeleteMe()
        self.cost_item = nil
    end
end

function DragonDesignBloodTemplate:InitView()

	local all_data = self.dragon_design_data:GetAllData()
	local refine_star = all_data.refine_star	--星级
	local refine_lv = all_data.refine_lv		--品阶
	local refine_quality = all_data.refine_quality		--当前资质
	local refine_cfg = config.dragon_refine[refine_star][refine_lv]
	local quality_range = refine_cfg.quality_range

	self._layout_objs["qua_txt1"]:SetText(string.format(config.words[6123], refine_star, refine_lv))

	for i = 1, 9 do
		self._layout_objs["left_xing"..i]:SetVisible(i <= refine_star)
	end

	for i = 1, 5 do
		local qua_data
		for k, v in pairs(refine_quality) do
			if v.id == i then
				qua_data = v
				break
			end
		end

		if qua_data then

			local quality_max = quality_range[i][3]

			self._layout_objs["qua_up"..i]:SetText(config.dragon_map[i].desc)
			self._layout_objs["bar_up"..i]:SetProgressValue(qua_data.val/quality_max*100)
			self._layout_objs["bar_up"..i]:GetChild("title"):SetText(qua_data.val.."/"..quality_max)
		end
	end
end

function DragonDesignBloodTemplate:InitNewQuality()

	local all_data = self.dragon_design_data:GetAllData()
	local refine_star = all_data.refine_star_r	--星级
	local refine_lv = all_data.refine_lv_r		--品阶
	local refine_refresh = all_data.refine_quality_r		--血炼资质
	local refine_cfg = config.dragon_refine[refine_star][refine_lv]
	local quality_range = refine_cfg.quality_range

	--消耗
	local cost_item_id = refine_cfg.cost[1]
    local cost_item_num = refine_cfg.cost[2]
    local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

    self.cost_item:SetItemInfo({ id = cost_item_id, num = cost_item_num})
    self.cost_item:SetNumText(cur_num.."/"..cost_item_num)
    self.cost_item:SetShowTipsEnable(true)

    if cur_num >= cost_item_num then
        self.cost_item:SetColor(224, 214, 189)
    else
        self.cost_item:SetColor(255, 0, 0)
    end

    --剩余血炼值
    local max_refine_times = config.sys_config["dragon_refine_week_times"].value
    local left_refine_times = max_refine_times - all_data.refine_times
    self._layout_objs["n126"]:SetText(string.format(config.words[6124], left_refine_times))

    --血炼值
    self._layout_objs["xl_img"]:SetFillAmount(all_data.refine_exp/refine_cfg.limit)

    if self.dragon_design_data:CanSaveRefine() then
		self._layout_objs["save_btn/hd"]:SetVisible(true)
	else
		self._layout_objs["save_btn/hd"]:SetVisible(false)
	end

    --是否有血炼值
	if not next(refine_refresh) then
		self._layout_objs["tips"]:SetVisible(true)
		self._layout_objs["qua_txt2"]:SetVisible(false)
		self._layout_objs["n156"]:SetVisible(false)
		for i = 1, 9 do
			self._layout_objs["right_xing"..i]:SetVisible(false)
			self._layout_objs["right_bg"..i]:SetVisible(false)
		end

		return
	else
		self._layout_objs["tips"]:SetVisible(false)
		self._layout_objs["qua_txt2"]:SetVisible(true)
		self._layout_objs["n156"]:SetVisible(true)
		for i = 1, 9 do
			self._layout_objs["right_bg"..i]:SetVisible(true)
		end
	end

	self._layout_objs["qua_txt2"]:SetText(string.format(config.words[6123], refine_star, refine_lv))

	for i = 1, 9 do
		self._layout_objs["right_xing"..i]:SetVisible(i <= refine_star)
	end

	for i = 1, 5 do
		local qua_data
		for k, v in pairs(refine_refresh) do
			if v.id == i then
				qua_data = v
				break
			end
		end

		if qua_data then

			local quality_max = quality_range[i][3]

			self._layout_objs["qua_down"..i]:SetText(config.dragon_map[i].desc)
			self._layout_objs["bar_down"..i]:SetProgressValue(qua_data.val/quality_max*100)
			self._layout_objs["bar_down"..i]:GetChild("title"):SetText(qua_data.val.."/"..quality_max)
		end
	end
end

return DragonDesignBloodTemplate