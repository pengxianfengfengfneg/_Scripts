local ChosePetView = Class(game.BaseView)

function ChosePetView:_init(ctrl)
	self._package_name = "ui_main"
    self._com_name = "chose_pet_view"

	self._view_level = game.UIViewLevel.Standalone

	self.ctrl = ctrl
end

function ChosePetView:OpenViewCallBack(info)
	self.info = info
	self.pet_list = config.goods_effect[info.id].effect
	self:Init()
	self:InitBg()
end

function ChosePetView:CloseViewCallBack()
	if self.pet_model_left then
		self.pet_model_left:DeleteMe()
		self.pet_model_left = nil
	end

	if self.pet_model_right then
		self.pet_model_right:DeleteMe()
		self.pet_model_right = nil
	end
end

function ChosePetView:Init()
	self.img_vip_bg = self._layout_objs["img_vip_bg"]
	
	self:InitLeft()
	self:InitRight()
end

function ChosePetView:InitLeft()
	local pet_cfg = self:GetPetByItem(self.pet_list[1])

	self.btn_get_left = self._layout_objs["btn_get_left"]
	self.btn_get_left:AddClickCallBack(function()
		game.BagCtrl.instance:SendUseGoods(self.info.pos, 1, 1)
		self:Close()
	end)

	self.txt_name_left = self._layout_objs["txt_name_left"]
	self.txt_name_left:SetText(pet_cfg.name)

	self.wrapper_left = self._layout_objs["wrapper_left"]

	self.pet_model_left = require("game/character/model_template").New()
    self.pet_model_left:CreateDrawObj(self.wrapper_left, game.BodyType.Monster)
    self.pet_model_left:SetPosition(0, -0.9, 3)
	self.pet_model_left:SetRotation(0, 140, 0)
	self.pet_model_left:SetScale(pet_cfg.scale)

    self.pet_model_left:SetModel(game.ModelType.Body, pet_cfg.model_id[1])
    self.pet_model_left:PlayAnim(game.ObjAnimName.Idle)
end

function ChosePetView:InitRight()
	local pet_cfg = self:GetPetByItem(self.pet_list[2])

	self.btn_get_right = self._layout_objs["btn_get_right"]
	self.btn_get_right:AddClickCallBack(function()
		game.BagCtrl.instance:SendUseGoods(self.info.pos, 1, 2)
		self:Close()
	end)

	self.txt_name_right = self._layout_objs["txt_name_right"]
	self.txt_name_right:SetText(pet_cfg.name)

	self.wrapper_right = self._layout_objs["wrapper_right"]

	self.pet_model_right = require("game/character/model_template").New()
    self.pet_model_right:CreateDrawObj(self.wrapper_right, game.BodyType.Monster)
    self.pet_model_right:SetPosition(0, -0.9, 3)
	self.pet_model_right:SetRotation(0, 140, 0)
	self.pet_model_right:SetScale(pet_cfg.scale)

    self.pet_model_right:SetModel(game.ModelType.Body, pet_cfg.model_id[1])
    self.pet_model_right:PlayAnim(game.ObjAnimName.Idle)
end

function ChosePetView:InitBg()
	local bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1662])
	bg:SetBtnCloseVisible(false)
end

function ChosePetView:GetPetByItem(item_id)
	for _, v in pairs(config.pet) do
		if v.active_item == item_id then
			return v
		end
	end
end

return ChosePetView
