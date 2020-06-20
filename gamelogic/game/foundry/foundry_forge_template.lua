local FoundryForgeTemplate = Class(game.UITemplate)

function FoundryForgeTemplate:_init()
	self._package_name = "ui_foundry"
    self._com_name = "foundry_forge_template"
end

function FoundryForgeTemplate:OpenViewCallBack()

	self.use_unbind = false
	self.btn_checkbox = self._layout_objs["btn_checkbox"]
	self.btn_checkbox:SetSelected(false)
    self.btn_checkbox:AddChangeCallback(function(event_type)
        local is_selected = (event_type == game.ButtonChangeType.Selected)
        self.use_unbind = is_selected
        self:SetBottomInfo(self.forge_id)
    end)

	self.target_item = require("game/bag/item/goods_item").New()
	self.target_item:SetVirtual(self._layout_objs["n21"])
    self.target_item:Open()
    self.target_item:ResetItem()
    self.target_item:SetShowTipsEnable(true)

    self.must_item = {}
    for i = 1, 2 do
	    self.must_item[i] = require("game/bag/item/goods_item").New()
		self.must_item[i]:SetVirtual(self._layout_objs["must_item"..i])
	    self.must_item[i]:Open()
	    self.must_item[i]:ResetItem()
	    self.must_item[i]:SetShowTipsEnable(true)
	end

	self.select_check_box = 0
	self.option_item = {}
    for i = 1, 3 do
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

	self:InitTopList()

	self.tab_index = 1
	self.level_index = 50

    self._layout_objs["n41"]:AddChangeCallback(function()
    	local t = self._layout_objs["n41"]:GetSelectIndex()
    	self.level_index = (t+5)*10
    	self:UpdateTopListData()
    end)

    self._layout_objs["n41"]:SetSelectIndex(0)

	self.tab_controller = self:GetRoot():AddControllerCallback("tab", function(idx)
		self.tab_index = idx + 1
		self:UpdateTopListData()
    end)
    self.tab_controller:SetSelectedIndexEx(0)


    self._layout_objs["n36"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:CsRefineForge(self.forge_id, self.select_check_box+1, self.use_unbind and 1 or 0)
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

    self._layout_objs["n17"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenCollectView()
    end)

    self:BindEvent(game.FoundryEvent.ForgeSucc, function(data)
        self:RefreshView(data)
    end)

     self:BindEvent(game.MoneyEvent.Change, function(change_list)
        self:SetScore()
    end)

    self:SetScore()
end

function FoundryForgeTemplate:InitTopList()

	self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/foundry/foundry_item_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddClickItemCallback(function(item)
    	self:OnClickTopItem(item:GetIdx())
    end)

    self.ui_list:SetItemNum(0)
end

function FoundryForgeTemplate:UpdateTopListData()

	local foundry_data = game.FoundryCtrl.instance:GetData()
	self.top_item_list = foundry_data:GetForgeItems(self.tab_index, self.level_index)

	self.ui_list:SetItemNum(#self.top_item_list)

	self:OnClickTopItem(1)
end

function FoundryForgeTemplate:GetTopItemList()
	return self.top_item_list
end

function FoundryForgeTemplate:SetBottomInfo(forge_id)

	local item_id = config.equip_forge[forge_id].items[1][2]
	self.target_item:SetItemInfo({ id = item_id})
	self._layout_objs["n21/name2"]:SetText("")

	--星级随机
	local cfg = config.equip_forge_ratio[self.select_check_box+1]
	local ratios = cfg.ratios
	local min = ratios[1][1]
	local max = ratios[#ratios][1]

	self._layout_objs["n23"]:SetText(string.format(config.words[1229],min,max))

	local must_material = config.equip_forge[forge_id].must_material

	for k, v in ipairs(must_material) do
		self.must_item[k]:SetItemInfo({id = v[1], num = v[2]})

		local cur_num = game.BagCtrl.instance:GetNumById(v[1])

		self.must_item[k]:SetNumText(cur_num.."/"..v[2])

		if cur_num >= v[2] then
			self._layout_objs["must_item"..k.."/jh_img"]:SetVisible(false)
			self.must_item[k]:SetColor(224, 214, 189)
			self.must_item[k]:SetShowTipsEnable(true)
		else
			self._layout_objs["must_item"..k.."/jh_img"]:SetVisible(true)
			self.must_item[k]:SetColor(255, 0, 0)
			self.must_item[k]:SetShowTipsEnable(true)
		end
	end

	for i = 1, 3 do
		local cfg = config.equip_forge[forge_id]["select_material_"..i]
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
		else
			self._layout_objs["option_item"..i.."/jh_img"]:SetVisible(true)
			self.option_item[i]:SetColor(255, 0, 0)
			self.option_item[i]:SetShowTipsEnable(true)
		end
	end
end

function FoundryForgeTemplate:OnClickTopItem(idx)

	self.ui_list:Foreach(function(v)
		if v:GetIdx() ~= idx then
        	v:SetSelect(false)
        else
        	v:SetSelect(true)
        end
    end)

	self.forge_id = self.top_item_list[idx]

	self:SetBottomInfo(self.forge_id)
end

function FoundryForgeTemplate:OnSelectCheckBox(index, is_selected)

	for i = 1, 3 do
		self._layout_objs["btn_checkbox"..i]:SetSelected(false)
	end

	if is_selected then
		self._layout_objs["btn_checkbox"..index]:SetSelected(true)
		self.select_check_box = index
	else
		self.select_check_box = 0
	end

	--星级随机
	local cfg = config.equip_forge_ratio[self.select_check_box+1]
	local ratios = cfg.ratios
	local min = ratios[1][1]
	local max = ratios[#ratios][1]

	self._layout_objs["n23"]:SetText(string.format(config.words[1229],min,max))
end

function FoundryForgeTemplate:RefreshView(data)

	self:SetScore()

	self:SetBottomInfo(self.forge_id)

	local forge_id = data.id
	local item_info = data.item
	item_info.not_show_wear = true

	self.target_item:SetItemInfo(item_info)
	self.target_item:AddClickEvent(
		function()
			game.BagCtrl.instance:OpenBagEquipInfoView(item_info)
		end)
end

--打造积分
function FoundryForgeTemplate:SetScore()

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

return FoundryForgeTemplate