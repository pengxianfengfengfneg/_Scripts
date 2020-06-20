local FoundryGodWeaponShowView = Class(game.BaseView)

function FoundryGodWeaponShowView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_godweapon_showview"
    self._view_level = game.UIViewLevel.Second
end

function FoundryGodWeaponShowView:OpenViewCallBack()

	-- self._layout_objs["model"]:SetVisible(false)

	self:InitList()

	self:ShowItem(1)

	--图鉴
    self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
    end)
end

function FoundryGodWeaponShowView:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end

    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function FoundryGodWeaponShowView:InitList()
	local career = game.RoleCtrl.instance:GetCareer()
	local cfg = config.artifact_base[career]
	self.career = career
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
		local item_id = cfg[career*100+idx].item_id
		item:SetItemInfo({ id = item_id, num = 0})
		item:SetNum()
	end)

	self.ui_list:AddClickItemCallback(function(item)
		self:ShowItem(item.idx)
	end)

	self.ui_list:SetItemNum(7)
end

function FoundryGodWeaponShowView:ShowItem(index)

	self.ui_list:Foreach(function(item)
        if item.idx ~= index then
        	item:SetSelect(false)
        else
        	item:SetSelect(true)
        end
    end)

	self.select_index = index


	local cfg = self.cfg[self.career*100+index]
	local name = cfg.name
	local model = cfg.model

	self._layout_objs["weapon_name"]:SetSprite("ui_foundry", cfg.icon)

	self:ShowWeapon(model)
end

function FoundryGodWeaponShowView:ShowWeapon(weapon_id)

    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end

    self._layout_objs["model"]:SetVisible(true)

    if not self.model then
	    self.model = require("game/character/model_template").New()
	    self.model:CreateDrawObj(self._layout_objs["model"], game.ModelType.WeaponUI, self._layout_objs["n8"])
	    self.model:SetPosition(-0.04, -2.09, 5.48)
	    self.model:SetRotation(0.57, 191, -2.76)
	    self.model:SetAlwaysAnim(true)
	end

    self.model:SetModel(game.ModelType.WeaponUI, weapon_id, true)
    self.model:PlayAnim(game.ObjAnimName.Show1, game.ModelType.WeaponUI)
    self.model:SetModelChangeCallBack(function()
    	local cfg = config.artifact_show[weapon_id]
    	local pos = cfg.pos
	self._layout_objs["model"]:SetPosition(pos[1], pos[2])
    	--self.model:SetPosition(pos[1], pos[2], pos[3])
    	self.model:SetScale(cfg.show_ratio)

	    local show_effct = cfg.show_effect
	    for k, v in pairs(show_effct) do
	    	self.model:SetEffect(v[1], v[2], game.ModelType.WeaponUI, true)
	    end

	    self.tween = DOTween.Sequence()
	    self.tween:AppendInterval(3)
	    self.tween:AppendCallback(function()
	        self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.WeaponUI)
	        local idle_effect = cfg.idle_effect
		    for k, v in pairs(idle_effect) do
		    	self.model:SetEffect(v[1], v[2], game.ModelType.WeaponUI, true)
		    end
	    end)
    end)    
end

return FoundryGodWeaponShowView
