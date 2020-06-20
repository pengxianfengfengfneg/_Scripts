local WeaponSoulShowView = Class(game.BaseView)

function WeaponSoulShowView:_init(ctrl)
    self._package_name = "ui_weapon_soul"
    self._com_name = "weapon_soul_showview"
    self._view_level = game.UIViewLevel.Second
end

function WeaponSoulShowView:OpenViewCallBack()

	self:InitList()

	self:ShowItem(1)

	--图鉴
    self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
    end)
end

function WeaponSoulShowView:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function WeaponSoulShowView:InitList()

	local cfg = config.weapon_soul_show
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
		local item_id = cfg[idx].item_id
		item:SetItemInfo({ id = item_id, num = 0})
	end)

	self.ui_list:AddClickItemCallback(function(item)
		self:ShowItem(item.idx)
	end)

	self.ui_list:SetItemNum(#cfg)
end

function WeaponSoulShowView:ShowItem(index)

	self.ui_list:Foreach(function(item)
        if item.idx ~= index then
        	item:SetSelect(false)
        else
        	item:SetSelect(true)
        end
    end)

	self.select_index = index


	local cfg = self.cfg[index]
	local name = config.goods[cfg.item_id].name
	local model = cfg.model

	self._layout_objs["weapon_name"]:SetText(name)

	if cfg.star[1] == cfg.star[2] then
		self._layout_objs["star_txt"]:SetText(string.format(config.words[6119], cfg.star[1]))
	else
		self._layout_objs["star_txt"]:SetText(string.format(config.words[6118], cfg.star[1], cfg.star[2]))
	end

	self:ShowWeapon(model)
end

function WeaponSoulShowView:ShowWeapon(weapon_id)

    self._layout_objs["model"]:SetVisible(true)

    if not self.model then
	    self.model = require("game/character/model_template").New()
	    self.model:CreateDrawObj(self._layout_objs["model"], game.BodyType.Weapon)
	    self.model:SetPosition(-0.04, -0.84, 5.48)
	    self.model:SetRotation(0.57, 191, -2.76)
	    self.model:SetScale(5)
	    self.model:SetAlwaysAnim(true)
	end

    self.model:SetModel(game.ModelType.WuHunUI, weapon_id, true)
    self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.WuHunUI)
end

return WeaponSoulShowView
