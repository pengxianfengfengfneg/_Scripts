local ChoseMountView = Class(game.BaseView)

local handler = handler

function ChoseMountView:_init(ctrl)
	self._package_name = "ui_main"
    self._com_name = "chose_mount_view"

	self._view_level = game.UIViewLevel.Standalone

	self.ctrl = ctrl
end

function ChoseMountView:OpenViewCallBack()
	self:Init()
	self:InitBg()
end

function ChoseMountView:CloseViewCallBack()
	if self.mount_model_left then
		self.mount_model_left:DeleteMe()
		self.mount_model_left = nil
	end

	if self.mount_model_right then
		self.mount_model_right:DeleteMe()
		self.mount_model_right = nil
	end
end

function ChoseMountView:Init()
	self.task_item_id = 32010000
	self:InitLeft()
	self:InitRight()
end

function ChoseMountView:InitLeft(effect_id)
	local mount_id = 1
	local mount_cfg = config.exterior_mount[mount_id]

	self.btn_get_left = self._layout_objs["btn_get_left"]
	self.btn_get_left:AddClickCallBack(function()
        self:ChoseMount(1)
	end)

	self.txt_name_left = self._layout_objs["txt_name_left"]
	self.txt_name_left:SetText(mount_cfg.name)

	self.wrapper_left = self._layout_objs["wrapper_left"]

	self.mount_model_left = require("game/character/model_template").New()
    self.mount_model_left:CreateDrawObj(self.wrapper_left, game.BodyType.Body)
    self.mount_model_left:SetPosition(0, -1.6, 5)
    self.mount_model_left:SetModelChangeCallBack(function()
        self.mount_model_left:SetRotation(0, 140, 0)
    end)

    self.mount_model_left:SetModel(game.ModelType.Mount, mount_cfg.model_id)
    self.mount_model_left:PlayAnim(game.ObjAnimName.RideIdle, game.ModelType.Mount)
end

function ChoseMountView:InitRight()
	local mount_id = 2
	local mount_cfg = config.exterior_mount[mount_id]

	self.btn_get_right = self._layout_objs["btn_get_right"]
	self.btn_get_right:AddClickCallBack(function()
		self:ChoseMount(2)
	end)

	self.txt_name_right = self._layout_objs["txt_name_right"]
	self.txt_name_right:SetText(mount_cfg.name)

	self.wrapper_right = self._layout_objs["wrapper_right"]

	self.mount_model_right = require("game/character/model_template").New()
    self.mount_model_right:CreateDrawObj(self.wrapper_right, game.BodyType.Body)
    self.mount_model_right:SetPosition(0, -1.7, 5)
    self.mount_model_right:SetModelChangeCallBack(function()
        self.mount_model_right:SetRotation(0, 140, 0)
    end)

    self.mount_model_right:SetModel(game.ModelType.Mount, mount_cfg.model_id)
    self.mount_model_right:PlayAnim(game.ObjAnimName.RideIdle, game.ModelType.Mount)
end

function ChoseMountView:InitBg()
	self:GetBgTemplate("common_bg"):SetTitleName(config.words[1676]):SetBtnCloseVisible(false)
end

function ChoseMountView:ChoseMount(id)
	local bag_ctrl = game.BagCtrl.instance
	if bag_ctrl:GetNumById(self.task_item_id) > 0 then
		local pos = bag_ctrl:GetPosById(self.task_item_id)
		game.BagCtrl.instance:SendUseGoods(pos, 1, id)
		self:Close()
	else
		game.GameMsgCtrl.instance:PushMsg(config.words[5518])
	end
end

return ChoseMountView
