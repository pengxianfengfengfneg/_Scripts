local FoundryHideWeaponShowView = Class(game.BaseView)

function FoundryHideWeaponShowView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_godweapon_showview"
    self._view_level = game.UIViewLevel.Second
end

function FoundryHideWeaponShowView:OpenViewCallBack()

	-- self._layout_objs["model"]:SetVisible(false)

	self:InitList()

	self:ShowItem(1)

	--图鉴
    self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
    end)
end

function FoundryHideWeaponShowView:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function FoundryHideWeaponShowView:InitList()

	local cfg = config.anqi_model
	self.cfg = cfg

	self.ui_list = game.UIList.New(self._layout_objs["list"])
	self.ui_list:SetVirtual(false)
	self.ui_list:SetCreateItemFunc(function(obj)
		local item = require("game/bag/item/goods_item").New()
		item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        item:AddClickEvent(function()
        	self:ShowItem(item.idx)
        end)
        return item
	end)

	self.ui_list:SetRefreshItemFunc(function(item, idx)
		item.idx = idx
		local item_id = cfg[idx].icon
		item:SetItemInfo({ id = item_id, num = 0})
	end)

	self.ui_list:AddClickItemCallback(function(item)
		self:ShowItem(item.idx)
	end)

	self.ui_list:SetItemNum(#cfg)
end

function FoundryHideWeaponShowView:ShowItem(index)

	self.ui_list:Foreach(function(item)
        if item.idx ~= index then
        	item:SetSelect(false)
        else
        	item:SetSelect(true)
        end
    end)

	self.select_index = index


	local cfg = self.cfg[index]
	local logo = cfg.logo
	local model = cfg.model

    --图鉴名称显示
	self._layout_objs["weapon_name"]:SetSprite("ui_foundry",logo)

	self:ShowWeapon(model)
end

function FoundryHideWeaponShowView:ShowWeapon(weapon_id)

    self._layout_objs["model"]:SetVisible(true)

    if not self.model then
	    self.model = require("game/character/model_template").New()
	    self.model:CreateDrawObj(self._layout_objs["model"], game.BodyType.Weapon)
	    self.model:SetPosition(-0.04, -2.09, 5.48)
	    self.model:SetRotation(0.57, 191, -2.76)
	    self.model:SetScale(5)
	    self.model:SetAlwaysAnim(true)
	end

    self.model:SetModel(game.ModelType.AnQi, weapon_id, true)
    self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.AnQi)
end

return FoundryHideWeaponShowView
