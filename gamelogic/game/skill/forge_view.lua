local ForgeView = Class(game.BaseView)

function ForgeView:_init(ctrl)
    self._package_name = "ui_skill"
    self._com_name = "forge_view"

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function ForgeView:CloseViewCallBack()
	if self.target_item then
		self.target_item:DeleteMe()
		self.target_item = nil
	end

	for k, v in pairs(self.must_item) do
		v:DeleteMe()
	end
	self.must_item = nil

	for k, v in pairs(self.option_item) do
		v:DeleteMe()
	end
	self.option_item = nil
end

function ForgeView:OpenViewCallBack(forge_id)

	self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1272])

	self.forge_id = forge_id

	self:BindEvent(game.SkillEvent.ChangeForgeStar, function(select_index)
		self:ChangeForgeStar(select_index)
    end)
    self:BindEvent(game.MoneyEvent.Change, function(change_list)
        self:SetScore()
    end)

    self:BindEvent(game.FoundryEvent.ForgeSucc, function(data)
        self:RefreshView(data)
        self:PlayEffect()
    end)

    self._layout_objs["btn_left"]:AddClickCallBack(function()
    	self:ReSelect(false)
    end)

    self._layout_objs["btn_right"]:AddClickCallBack(function()
    	self:ReSelect(true)
    end)

    self._layout_objs["n36"]:AddClickCallBack(function()
    	local index = self.select_check_box + 1
    	if self.select_check_box == 2 then
    		index = self.select_star_index + 1
    	end
		game.FoundryCtrl.instance:CsRefineForge(self.forge_id, index, self.use_unbind and 1 or 0)
    end)

	self._layout_objs["btn_change"]:AddClickCallBack(function()
		self.ctrl:OpenForgeSelectStarView(self.select_star_index)
    end)

	--积分按钮
    self._layout_objs["n28/img_red_point"]:SetVisible(false)
    self._layout_objs["n28"]:AddClickCallBack(function()
    	if self.can_score_rotaty then
        	game.FoundryCtrl.instance:OpenScoreRotatyView(20)
        else
        	game.GameMsgCtrl.instance:PushMsg(config.words[1237])
        end
    end)

	self.use_unbind = false
	self.btn_checkbox = self._layout_objs["btn_checkbox"]
	self.btn_checkbox:SetSelected(false)
    self.btn_checkbox:AddChangeCallback(function(event_type)
        local is_selected = (event_type == game.ButtonChangeType.Selected)
        self.use_unbind = is_selected
        self:ChangeByBind()
    end)

	self.target_item = require("game/bag/item/goods_item").New()
	self.target_item:SetVirtual(self._layout_objs["n21"])
    self.target_item:Open()
    self.target_item:ResetItem()
    self.target_item:SetShowTipsEnable(true)

    self.must_item = {}
    for i = 1, 3 do
	    self.must_item[i] = require("game/bag/item/goods_item").New()
		self.must_item[i]:SetVirtual(self._layout_objs["must_item"..i])
	    self.must_item[i]:Open()
	    self.must_item[i]:ResetItem()
	    self.must_item[i]:SetShowTipsEnable(true)
	end

	self.select_check_box = 0
	self.select_star_index = 2
	self.option_item = {}
	self._layout_objs["n39"]:SetVisible(false)
	for i = 1, 2 do
	    self.option_item[i] = require("game/bag/item/goods_item").New()
		self.option_item[i]:SetVirtual(self._layout_objs["option_item"..i])
	    self.option_item[i]:Open()
	    self.option_item[i]:ResetItem()

	    self._layout_objs["btn_checkbox"..i]:SetSelected(false)
	    self._layout_objs["btn_checkbox"..i]:AddChangeCallback(
	    	function(event_type)
		        local is_selected = (event_type == game.ButtonChangeType.Selected)
		        self:OnSelectCheckBox(i, is_selected)
	    	end)
	end

	self:SetInfo()

	self:SetScore()

    if config.equip_forge[self.forge_id].type == 0 then
    	self._layout_objs["type_tip"]:SetText(config.words[1288])
    else
    	self._layout_objs["type_tip"]:SetText(config.words[1289])
    end

    self:SetLeftRightArrow()
end

function ForgeView:ReSelect(val)

	local forge_id

	if val then
		forge_id = self.forge_id + 1
	else
		forge_id = self.forge_id - 1
	end

	if not config.equip_forge[forge_id] then
		game.GameMsgCtrl.instance:PushMsg(config.words[1290])
		return
	end

	self.forge_id = forge_id

	self._layout_objs["n28/img_red_point"]:SetVisible(false)

	self.use_unbind = false
	self.btn_checkbox:SetSelected(false)
	self.target_item:ResetItem()
	for i = 1, 3 do
	    self.must_item[i]:ResetItem()
	end

	self.select_check_box = 0
	self.select_star_index = 2
	self._layout_objs["n39"]:SetVisible(false)
	for i = 1, 2 do
	    self.option_item[i]:ResetItem()
	    self._layout_objs["btn_checkbox"..i]:SetSelected(false)
	end

	self:SetInfo()

	self:SetScore()

    if config.equip_forge[self.forge_id].type == 0 then
    	self._layout_objs["type_tip"]:SetText(config.words[1288])
    else
    	self._layout_objs["type_tip"]:SetText(config.words[1289])
    end

    self:SetLeftRightArrow()
end

function ForgeView:OnSelectCheckBox(index, is_selected)

	for i = 1, 2 do
		self._layout_objs["btn_checkbox"..i]:SetSelected(false)
	end

	if is_selected then
		self._layout_objs["btn_checkbox"..index]:SetSelected(true)
		self.select_check_box = index
	else
		self.select_check_box = 0
	end

	--星级随机
	local index = self.select_check_box+1
	if self.select_star_index == 3 and self.select_check_box == 2 then
		index = index + 1
	end

	local cfg = config.equip_forge_ratio[index]
	local ratios = cfg.ratios
	local min = ratios[1][1]
	local max = ratios[#ratios][1]

	self._layout_objs["n23"]:SetText(string.format(config.words[1229],min,max))

	if self.select_check_box == 1 then
		local score = config.equip_forge[self.forge_id].score
		self._layout_objs["n39"]:SetText(string.format(config.words[1287], score))
		self._layout_objs["n39"]:SetVisible(true)
	else
		self._layout_objs["n39"]:SetVisible(false)
	end
end

function ForgeView:ChangeForgeStar(select_star_index)

	self.select_star_index = select_star_index

	local cfg = config.equip_forge[self.forge_id]["select_material_"..select_star_index]
	self.option_item[2]:SetItemInfo({id = cfg[1], num = cfg[2]})

	local cur_num
	--只使用非绑定
	if self.use_unbind then
		cur_num = game.BagCtrl.instance:GetBindNumById(cfg[1], 0)
	else
		cur_num = game.BagCtrl.instance:GetNumById(cfg[1])
	end

	self.option_item[2]:SetNumText(cur_num.."/"..cfg[2])

	if cur_num >= cfg[2] then
		self._layout_objs["option_item2/jh_img"]:SetVisible(false)
		self.option_item[2]:SetColor(224, 214, 189)
		self.option_item[2]:SetShowTipsEnable(true)
		self.option_item[2]:SetGrayImgCover(false)
	else
		self._layout_objs["option_item2/jh_img"]:SetVisible(true)
		self.option_item[2]:SetColor(255, 0, 0)
		self.option_item[2]:SetShowTipsEnable(true)
		self.option_item[2]:SetGrayImgCover(true)
	end

	if self.select_check_box == 2 then

		local index = self.select_check_box+1
		if self.select_star_index == 3 then
			index = index + 1
		end

		--星级随机
		local cfg = config.equip_forge_ratio[index]
		local ratios = cfg.ratios
		local min = ratios[1][1]
		local max = ratios[#ratios][1]

		self._layout_objs["n23"]:SetText(string.format(config.words[1229],min,max))
	end
end

function ForgeView:ChangeByBind()

	--选项
	for i = 1, 2 do

		local cfg = config.equip_forge[self.forge_id]["select_material_"..i]
		if i == 2 and self.select_star_index == 3 then
			cfg = config.equip_forge[self.forge_id]["select_material_"..3]
		end

		self.option_item[i]:SetItemInfo({id = cfg[1], num = cfg[2]})

		local cur_num
		--只使用非绑定
		if self.use_unbind then
			cur_num = game.BagCtrl.instance:GetBindNumById(cfg[1], 0)
		else
			cur_num = game.BagCtrl.instance:GetNumById(cfg[1])
		end

		self.option_item[i]:SetNumText(cur_num.."/"..cfg[2])

		if cur_num >= cfg[2] then
			self._layout_objs["option_item"..i.."/jh_img"]:SetVisible(false)
			self.option_item[i]:SetColor(224, 214, 189)
			self.option_item[i]:SetShowTipsEnable(true)
			self.option_item[i]:SetGrayImgCover(false)
		else
			self._layout_objs["option_item"..i.."/jh_img"]:SetVisible(true)
			self.option_item[i]:SetColor(255, 0, 0)
			self.option_item[i]:SetShowTipsEnable(true)
			self.option_item[i]:SetGrayImgCover(true)
		end
	end
end

--打造积分
function ForgeView:SetScore()

	local role_lv = game.Scene.instance:GetMainRoleLevel()
	local index = 1
	for k, v in ipairs(config.equip_forge_wheel) do

		if v.level > role_lv then
			break
		end

		index = k
	end

	local cfg = config.equip_forge_wheel[index]

	local score = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.ForgeScore)

	if score >= cfg.score then
		self.can_score_rotaty = true
		self._layout_objs["n28/img_red_point"]:SetVisible(true)
	else
		self.can_score_rotaty = false
		self._layout_objs["n28/img_red_point"]:SetVisible(false)
	end
	self._layout_objs["n27"]:SetProgressValue(score/cfg.score*100)
	self._layout_objs["n27"]:GetChild("title"):SetText(score.."/"..cfg.score)
end

function ForgeView:RefreshView(data)

	self:SetScore()

	self:SetInfo()

	local forge_id = data.id
	local item_info = data.item
	item_info.not_show_wear = true

	self.target_item:SetItemInfo(item_info)
	self.target_item:AddClickEvent(
		function()
			game.BagCtrl.instance:OpenBagEquipInfoView(item_info)
		end)
end

function ForgeView:SetInfo()

	local forge_id = self.forge_id

	local item_id = config.equip_forge[forge_id].items[1][2]
	self.target_item:SetItemInfo({ id = item_id})
	self._layout_objs["equip_name"]:SetText(config.goods[item_id].name)

	--星级随机
	local cfg = config.equip_forge_ratio[self.select_check_box+1]
	local ratios = cfg.ratios
	local min = ratios[1][1]
	local max = ratios[#ratios][1]

	self._layout_objs["n23"]:SetText(string.format(config.words[1229],min,max))
	
	--必选
	local must_material = config.equip_forge[forge_id].must_material

	for k, v in ipairs(must_material) do
		self.must_item[k]:SetItemInfo({id = v[1], num = v[2]})

		local cur_num = game.BagCtrl.instance:GetNumById(v[1])

		self.must_item[k]:SetNumText(cur_num.."/"..v[2])

		if cur_num >= v[2] then
			self._layout_objs["must_item"..k.."/jh_img"]:SetVisible(false)
			self.must_item[k]:SetColor(224, 214, 189)
			self.must_item[k]:SetShowTipsEnable(true)
			self.must_item[k]:SetGrayImgCover(false)
		else
			self._layout_objs["must_item"..k.."/jh_img"]:SetVisible(true)
			self.must_item[k]:SetColor(255, 0, 0)
			self.must_item[k]:SetShowTipsEnable(true)
			self.must_item[k]:SetGrayImgCover(true)
		end
	end

	--选项
	for i = 1, 2 do
		local cfg = config.equip_forge[forge_id]["select_material_"..i]
		if i == 2 and self.select_star_index == 3 then
			cfg = config.equip_forge[self.forge_id]["select_material_"..3]
		end

		self.option_item[i]:SetItemInfo({id = cfg[1], num = cfg[2]})

		local cur_num
		--只使用非绑定
		if self.use_unbind then
			cur_num = game.BagCtrl.instance:GetBindNumById(cfg[1], 0)
		else
			cur_num = game.BagCtrl.instance:GetNumById(cfg[1])
		end

		self.option_item[i]:SetNumText(cur_num.."/"..cfg[2])

		if cur_num >= cfg[2] then
			self._layout_objs["option_item"..i.."/jh_img"]:SetVisible(false)
			self.option_item[i]:SetColor(224, 214, 189)
			self.option_item[i]:SetShowTipsEnable(true)
			self.option_item[i]:SetGrayImgCover(false)
		else
			self._layout_objs["option_item"..i.."/jh_img"]:SetVisible(true)
			self.option_item[i]:SetColor(255, 0, 0)
			self.option_item[i]:SetShowTipsEnable(true)
			self.option_item[i]:SetGrayImgCover(true)
		end
	end
end

function ForgeView:SetLeftRightArrow()

	local right_id = self.forge_id + 1
	if config.equip_forge[right_id] then
		self._layout_objs["btn_right"]:SetVisible(true)
	else
		self._layout_objs["btn_right"]:SetVisible(false)
	end

	local left_id = self.forge_id - 1
	if config.equip_forge[left_id] then
		self._layout_objs["btn_left"]:SetVisible(true)
	else
		self._layout_objs["btn_left"]:SetVisible(false)
	end
end

function ForgeView:PlayEffect()
    self._layout_objs.effect:SetVisible(true)
    self:CreateUIEffect(self._layout_objs.effect, "effect/ui/zb_dadzao.ab")
end

return ForgeView
