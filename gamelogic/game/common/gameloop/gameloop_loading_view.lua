
local GameLoopLoadingView = Class(game.BaseView)

function GameLoopLoadingView:_init()
	self._package_name = "ui_common"
    self._com_name = "loading_view"
	self._ui_order = game.UIZOrder.UIZOrder_Low
    self._swallow_touch = true
    self._mask_type = game.UIMaskType.None

    self._layer_name = game.LayerName.UI2

    self.not_add_mgr = true
    self.is_first = true

    self.map_id = 0
    self.is_same_map = false
end

function GameLoopLoadingView:_delete()

end

function GameLoopLoadingView:OpenViewCallBack(scene_id, map_id, line_id)
	local name
	local cfg = config.scene[scene_id]
	if cfg then
		name = cfg.name
	end

	self.is_same_map = (self.map_id==map_id)

	self.scene_id = scene_id
	self.map_id = map_id

	self:GetRoot():SetVisible(not self.is_same_map)
	if not self.is_same_map then
		if self.is_first then
			game.LoginCtrl.instance:OpenLoadingViewBG()
			self._layout_objs["loading1"]:SetVisible(false)
			self._layout_objs["loading2"]:SetVisible(true)
			self._layout_objs["load_img"]:SetFillAmount(0)
			self._layout_objs["txt2"]:SetText(string.format(config.words[506], name or "", math.max(line_id,1)))
		else
			self._layout_objs["loading1"]:SetVisible(true)
			self._layout_objs["loading2"]:SetVisible(false)
			self._layout_objs["front_img"]:SetFillAmount(0)
			self._layout_objs["txt1"]:SetText(string.format(config.words[506], name or "", math.max(line_id,1)))
		end
	end
	
	game.RenderUnit:HideUI(game.LayerMask.UI2)

	self.is_first = false
	self.is_done = true

	local scene_camera = game.RenderUnit:GetSceneCamera()
	scene_camera:StartImageEffect(game.MaterialEffect.EffectSnap,1,1,true)
	if self.is_same_map then
		self.is_done = false
		game.PostEffectCtrl.instance:StartEffect(game.MaterialEffect.EffectWave, function()
			self.is_done = true
		end)
	end
end

function GameLoopLoadingView:CloseViewCallBack()
	game.RenderUnit:ShowUI()

	local scene_camera = game.RenderUnit:GetSceneCamera()
	scene_camera:StopImageEffect()

	if self.is_same_map then
		game.PostEffectCtrl.instance:StopEffect()
	end

	if game.LoginCtrl.instance then
		game.LoginCtrl.instance:CloseLoadingViewBG()
	end
end

function GameLoopLoadingView:SetPercent(val)
	self._layout_objs["front_img"]:SetFillAmount(val)
	self._layout_objs["load_img"]:SetFillAmount(val)
end

function GameLoopLoadingView:Reset()
	self.is_first = true
	self.map_id = 0
	self.is_done = false
	self.is_same_map = false
end

function GameLoopLoadingView:IsDone()
	return self.is_done
end

return GameLoopLoadingView
