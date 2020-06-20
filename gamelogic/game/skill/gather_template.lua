local GatherTemplate = Class(game.UITemplate)

local config_gather_skill = config.gather_skill
local config_drop = config.drop
local config_goods = config.goods

function GatherTemplate:_init(view)
    self.ctrl = game.GatherCtrl.instance
    
    self.parent_view = view
end

function GatherTemplate:OpenViewCallBack()
	self:Init()

	self:RegisterAllEvents()
end

function GatherTemplate:CloseViewCallBack()
   	for _,v in ipairs(self.gather_tab_item_list or {}) do
   		v:DeleteMe()
   	end
   	self.gather_tab_item_list = nil

   	for _,v in ipairs(self.item_gather_guide_list or {}) do
   		v:DeleteMe()
   	end
   	self.item_gather_guide_list = nil

   	if self.cost_item then
   		self.cost_item:DeleteMe()
   		self.cost_item = nil
   	end
end

function GatherTemplate:RegisterAllEvents()
    local events = {
    	{game.GatherEvent.OnGatherColl, handler(self,self.OnGatherColl)},
    	{game.GatherEvent.OnGatherUpgrade, handler(self,self.OnGatherUpgrade)},
    	{game.GatherEvent.OnGatherInfo, handler(self,self.OnGatherInfo)},    	
    	
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GatherTemplate:Init()
	self:InitCommon()
	self:InitGatherUpgrade()
	self:InitGatherGuide()
	self:InitGatherTab()
end

function GatherTemplate:InitCommon()
	self.bar_energy = self._layout_objs["bar_energy"]
	self.bar_energy:SetMax(self.ctrl:GetMaxVitality())
	
	local btn_checkbox = self._layout_objs["btn_checkbox"]
	btn_checkbox:AddChangeCallback(function(event_type)
		local is_selected = (event_type==game.ButtonChangeType.Selected)
		local flag = (is_selected and 1 or 0)
		self.ctrl:SendSetQuickGather(flag)
	end)

	btn_checkbox:SetSelected(self.ctrl:IsQuickGather())

	self:UpdateCommon()
end

function GatherTemplate:InitGatherUpgrade()
	self.txt_gather_lv = self._layout_objs["txt_gather_lv"]
	self.rtx_gather = self._layout_objs["rtx_gather"]
	self.rtx_upgrade = self._layout_objs["rtx_upgrade"]
	self.txt_max = self._layout_objs["txt_max"]

	self.bar_exp = self._layout_objs["bar_exp"]
	self.bar_exp_title = self.bar_exp:GetChild("title")

	self.btn_upgrade = self._layout_objs["btn_upgrade"]
	self.btn_upgrade:AddClickCallBack(function()
		if self.is_max then
			game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5457], self.gather_skill_name))
			return
		end

		if self.upgrade_item_num <= 0 then
			game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5452], self.cost_item_name))
			return
		end
		self.ctrl:SendGatherUpgrade(self.cur_gather_id, self.upgrade_item_num)
	end)

	self.goods_item_obj = self._layout_objs["goods_item"]

	self.cost_item = game_help.GetGoodsItem(self.goods_item_obj, true)
end

function GatherTemplate:InitGatherGuide()
	self.list_gather_guide = self._layout_objs["list_gather_guide"]
	self.guide_item_num = self.list_gather_guide:GetItemNum()


	self.item_gather_guide_list = {}
	local item_class = require("game/skill/gather_guide_item")
	for i=1,self.guide_item_num do
		local obj = self.list_gather_guide:GetChildAt(i-1)
		local item = item_class.New()
		item:SetVirtual(obj)
		item:Open()

		table.insert(self.item_gather_guide_list, item)
	end
end

function GatherTemplate:InitGatherTab()
	local list_gather_tab = self._layout_objs["list_gather_tab"]
	local item_num = list_gather_tab:GetItemNum()

	self.gather_tab_item_list = {}
	local item_class = require("game/skill/gather_tab")
	for i=1,item_num do
		local obj = list_gather_tab:GetChildAt(i-1)
		local item = item_class.New(self.ctrl, i)
		item:SetVirtual(obj)
		item:Open()

		table.insert(self.gather_tab_item_list, item)
	end

	self.gather_tab_ctrl = self:GetRoot():AddControllerCallback("c2", function(idx)
		self:OnClickGatherTab(idx+1)
	end)

	self.gather_tab_ctrl:SetSelectedIndexEx(0)
end

function GatherTemplate:OnClickGatherTab(idx)
	self:UpdateGatherUpgrade(idx)
	self:UpdateGatherGuide(idx)
end

function GatherTemplate:UpdateGatherUpgrade(idx)
	local cfg = config_gather_skill[idx]
	if not cfg then return end

	local info = self.ctrl:GetGatherSkillInfo(idx)

	local gather_lv = info.level
	local lv_cfg = cfg[gather_lv]
	self.gather_skill_name = lv_cfg.name

	self.txt_gather_lv:SetText(string.format(config.words[5451], self.gather_skill_name, gather_lv))

	self.rtx_gather:SetText(lv_cfg.produce_desc or "")
	self.rtx_upgrade:SetText(lv_cfg.upgrade_desc or "")

	local cost_item_id = lv_cfg.item
	local goods_cfg = config_goods[cost_item_id]

	self.is_max = gather_lv>=#cfg
	self.txt_max:SetVisible(self.is_max)
	self.goods_item_obj:SetVisible(not self.is_max)

	if not self.is_max then
		self.bar_exp:SetValue(info.exp)
		self.bar_exp:SetMax(lv_cfg.proficiency*1.0)
	else
		self.bar_exp:SetValue(100)
		self.bar_exp:SetMax(100*1.0)
		self.bar_exp_title:SetText(config.words[2201])
	end

	if self.is_max then
		self.btn_upgrade:SetGray(true)
		return
	end
	
	self.cost_item:SetItemInfo({id=cost_item_id, num=0})

	self.cur_gather_id = idx
	self.upgrade_item_num = game.BagCtrl.instance:GetNumById(cost_item_id)
	self.cost_item_name = config_goods[cost_item_id].name

	self.btn_upgrade:SetGray(self.upgrade_item_num<=0)
end

function GatherTemplate:UpdateGatherGuide(idx)
	local cfg = config_gather_skill[idx]
	if not cfg then return end

	local info = self.ctrl:GetGatherSkillInfo(idx)
	for k,v in ipairs(self.item_gather_guide_list) do
		v:UpdateData(cfg[k], info)
	end
end

function GatherTemplate:UpdateCommon()
	local energy = self.ctrl:GetGatherVitality()
	self.bar_energy:SetValue(energy)
end

function GatherTemplate:OnGatherColl(energy)
	self.bar_energy:SetValue(energy)
end

function GatherTemplate:OnGatherUpgrade(data)
	self:UpdateGatherUpgrade(data.id)
	self:UpdateGatherGuide(data.id)

	for _,v in ipairs(self.gather_tab_item_list) do
		if v:GetGatherId() == data.id then
			v:UpdateData(data)
		end
	end
end

function GatherTemplate:OnGatherInfo()
	self:UpdateCommon()
end

function GatherTemplate:CheckRedPoint()
	
end

return GatherTemplate
