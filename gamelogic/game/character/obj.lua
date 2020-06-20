local Obj = Class()

local _aoi_mgr = global.AoiMgr
local _render_unit = game.RenderUnit
local _event_mgr = global.EventMgr

local _anim_fade_time = config.custom.default_anim_fade_time
local _fight_ctrl = game.FightCtrl

function Obj:_init()

	Obj.instance = self

	self.update_cd = 0.5
	self.cur_update_cd = 0

	self.dir = cc.vec2(0, 0)
	self.unit_pos = cc.vec2(0, 0)
	self.logic_pos = cc.vec2(0, 0)
end

function Obj:_delete()
	self:Reset()
end

function Obj:Init(scene)
	self.scene = scene
	self.model_visible = true

	self.height = 0
	self.map_height = 0
	cc.pSet(self.unit_pos, 0, 0)
	cc.pSet(self.dir, -0.5, -0.866)
	cc.pSet(self.logic_pos, 0, 0)

	self._pos_dirty = true
	self._rot_dirty = true
	self._aoi_dirty = false

	self.root_obj = game.GamePool.ObjRootPool:Create()

	self.main_root_obj = game.GamePool.GameObjectPool:Create()
	self.root_obj.tran:SetParent(self.main_root_obj.tran)

	_render_unit.instance:AddToObjLayer(self.main_root_obj.tran)
end

function Obj:Reset()
	self:UnRegisterAoiWatcher()
	self:UnRegisterAoiObj()
	self:UnRegisterHud()

	self:ShowShadow(false)
	self:SetSelected(false)
	self:ShowLight(false)
	self:SetClickCallBack()

	_event_mgr:Fire(game.SceneEvent.ObjDelete, self.obj_id, self.uniq_id)

    if self.draw_obj then
    	game.GamePool.DrawObjPool:Free(self.draw_obj)
    	self.draw_obj = nil
    end

	if self.root_obj then
		game.GamePool.ObjRootPool:Free(self.root_obj)
		self.root_obj = nil
	end

	if self.main_root_obj then
		game.GamePool.GameObjectPool:Free(self.main_root_obj)
		self.main_root_obj = nil
	end

	self.scene = nil
	self.uniq_id = nil
end

function Obj:GetRoot()
	return self.root_obj.tran
end

function Obj:CheckUpdate(now_time, elapse_time)
	self:UpdateStateMachine(now_time, elapse_time)
	self:UpdateModel()
	
	self.cur_update_cd = elapse_time + self.cur_update_cd
	if self.cur_update_cd >= self.update_cd then
		self:Update(now_time, self.cur_update_cd)
		self.cur_update_cd = 0
	end
end

function Obj:Update(now_time, elapse_time)
	self:_UpdateAoi()
end

function Obj:UpdateStateMachine(now_time, elapse_time)
	if self.state_machine then
	    self.state_machine:Update(now_time, elapse_time)
    end
end

function Obj:UpdateModel()
	if self._pos_dirty then
		self._pos_dirty = false
		self.map_height = self:CalcMapHeight()
		if self.main_root_obj == nil then
			return
		end
		self.main_root_obj.tran:SetPosition(self.unit_pos.x, self.map_height + self.height, self.unit_pos.y)
	end

	if self._rot_dirty then
		self._rot_dirty = false
		if self.root_obj == nil then
			return
		end
		self.root_obj.tran:SetLookDir(self.dir.x, 0, self.dir.y)
	end
end

function Obj:GetRotation()
	return self.root_obj.tran:GetRotation()
end

function Obj:GetName()
    return self.vo.name
end

function Obj:SetName(name)
	self.vo.name = name
end

function Obj:GetLevel()
    return self.vo.level
end

-- 位置信息
function Obj:SetUnitPos(x, y)
	self.unit_pos.x = x
	self.unit_pos.y = y
	self._pos_dirty = true
	x, y = game.UnitToLogicPos(x, y)
	if self.logic_pos.x ~= x or self.logic_pos.y ~= y then
		self.logic_pos.x, self.logic_pos.y = x, y
		self._aoi_dirty = true
	end
end

function Obj:GetUnitPos()
	return self.unit_pos
end

function Obj:GetUnitPosXY()
    return self.unit_pos.x, self.unit_pos.y
end

function Obj:SetLogicPos(x, y)
	if self.logic_pos.x == x and self.logic_pos.y == y then
		return
	end
	
	self.logic_pos.x = x
	self.logic_pos.y = y
	self.unit_pos.x, self.unit_pos.y = game.LogicToUnitPos(x, y)
	self._pos_dirty = true
	self._aoi_dirty = true
end

function Obj:GetLogicPos()
	return self.logic_pos
end

function Obj:GetLogicPosXY()
    return self.logic_pos.x, self.logic_pos.y
end

function Obj:SetHeight(val)
	self.height = val
	self._pos_dirty = true
end

function Obj:GetHeight()
	return self.height
end

function Obj:CalcMapHeight()
	if self.scene == nil then
		return
	end
	return self.scene:GetHeightLerp(self.logic_pos.x, self.logic_pos.y, self.unit_pos.x, self.unit_pos.y, self.map_height)
end

function Obj:GetMapHeight()
	return self.map_height
end

function Obj:GetRealHeight()
	return self.map_height + self.height
end

function Obj:GetDir()
	return self.dir
end

function Obj:GetDirXY()
	return self.dir.x, self.dir.y
end

function Obj:SetDir(x, y)
	if x ~= 0 or y ~= 0 then
		self.dir.x = x
		self.dir.y = y
		self._rot_dirty = true
	end
end

function Obj:SetDirForce(x, y)
	if x ~= 0 or y ~= 0 then
		self.dir.x = x
		self.dir.y = y
		self._rot_dirty = false
		self.root_obj.tran:SetLookDir(self.dir.x, 0, self.dir.y)
	end
end

function Obj:GetLogicDistSq(x, y)
	local dx = self.logic_pos.x - x
	local dy = self.logic_pos.y - y
	return dx * dx + dy * dy
end

function Obj:GetUnitDistSq(x, y)
	local dx = self.unit_pos.x - x
	local dy = self.unit_pos.y - y
	return dx * dx + dy * dy
end

function Obj:GetLogicAngleCos(x, y)
	local tx, ty = cc.pNormalizeV(x - self.logic_pos.x, y - self.logic_pos.y)
	return self.dir.x * tx + self.dir.y * ty
end

function Obj:GetOffsetPos(offset, dist)
	local x, y = self.logic_pos.x, self.logic_pos.y
	local dx, dy = cc.pRotate(offset, self:GetDir())
	dx, dy = cc.pNormalizeV(dx, dy)
	dx, dy = math.floor(x + dx * dist), math.floor(y + dy * dist)
	if self.scene:IsWalkable(dx, dy) then
		return dx, dy
	else
		return x, y
	end
end

-- anim
local _anim_default_layer = game.ModelType.Body
local _anim_repeat_check = {
	[game.ObjAnimName.Idle] = true,
	[game.ObjAnimName.Run] = true,
	[game.ObjAnimName.Die] = true,
	[game.ObjAnimName.RideIdle] = true,
	[game.ObjAnimName.RideRun] = true,
	[game.ObjAnimName.Gather] = true,
	[game.ObjAnimName.Practice] = true,
}

function Obj:PlayAnim(name, speed, fade_time)
	if self.draw_obj then
		self.draw_obj:PlayLayerAnim(_anim_default_layer, name, speed or 1.0, fade_time or _anim_fade_time, not _anim_repeat_check[name])
	end
end

function Obj:PlayLayerAnim(name, layer, speed, fade_time)
	if self.draw_obj then
		self.draw_obj:PlayLayerAnim(layer or _anim_default_layer, name, speed or 1.0, fade_time or _anim_fade_time, not _anim_repeat_check[name])
	end
end

function Obj:GetAnimTime(name)
	return self.draw_obj:GetAnimTime(name)
end

-- aoi
function Obj:RegisterAoiWatcher(w, h, mask)
	if not self.aoi_id then
		local enter_func = function(data_list)
			for i,v in ipairs(data_list) do
				self:OnAoiObjEnter(v)
			end
		end
		local leave_func = function(data_list)
			for i,v in ipairs(data_list) do
				self:OnAoiObjLeave(v)
			end
		end
		self.aoi_id = _aoi_mgr:AddWatcher(self.logic_pos.x, self.logic_pos.y, w, h, mask, enter_func, leave_func)
	end
end

function Obj:UnRegisterAoiWatcher()
	if self.aoi_id then
		_aoi_mgr:DelWatcher(self.aoi_id)
		self.aoi_id = nil
	end
end

function Obj:RegisterAoiObj(aoi_type)
	if not self.aoi_obj_id then
		self.aoi_obj_id = _aoi_mgr:AddObj(self.logic_pos.x, self.logic_pos.y, aoi_type, self.obj_id)
	end
end

function Obj:UnRegisterAoiObj()
	if self.aoi_obj_id then
		_aoi_mgr:DelObj(self.aoi_obj_id)
		self.aoi_obj_id = nil
	end
end

function Obj:_UpdateAoi()
	if self._aoi_dirty then
		self._aoi_dirty = false

		if self.aoi_id then
			_aoi_mgr:UpdateWatcher(self.aoi_id, self.logic_pos.x, self.logic_pos.y)
		end

		if self.aoi_obj_id then
			_aoi_mgr:UpdateObj(self.aoi_obj_id, self.logic_pos.x, self.logic_pos.y)
		end
	end
end

local _aoi_func = function(target, func, obj, dist)
	if target.obj_id ~= obj.obj_id then
		if obj:GetLogicDistSq(target:GetLogicPosXY()) <= dist then
			func(target, obj)
		end
	end
end

function Obj:ForeachAoiObj(func)
	local dist_sq = 900
	if self.aoi_range then
    	dist_sq = self.aoi_range * self.aoi_range
    end
    self.scene:ForeachObjs(_aoi_func, func, self, dist_sq)
end

function Obj:OnAoiObjEnter(obj_id)
	if obj_id ~= self.obj_id then
		print("OnAoiObjEnter", obj_id)
	end
end

function Obj:OnAoiObjLeave(obj_id)
	if obj_id ~= self.obj_id then
		print("OnAoiObjLeave", obj_id)
	end
end

-- other
function Obj:ShowShadow(enable)
	if enable then
		if not self.shadow_model then
			self.shadow_model = game.GamePool:GetPrefabPool("model/other/shadow.ab", "shadow_quad"):Create()
			self.shadow_model:SetParent(self.root_obj.tran, false)
	        self.shadow_model:SetPosition(0, 0.01, 0)
	        self.shadow_model.transform:SetLayer(game.LayerName.SceneObject, true)
		end
	else
		if self.shadow_model then
			game.GamePool:GetPrefabPool("model/other/shadow.ab", "shadow_quad"):Free(self.shadow_model)
			self.shadow_model = nil
		end
	end
end

function Obj:SetSelected(val)
    self.is_selected = val

	if val then
        if not self.selected_model then
            self.selected_model = game.GamePool:GetPrefabPool("model/other/shadow.ab", "select_quad"):Create()
			self.selected_model:SetParent(self.root_obj.tran, false)
	        self.selected_model:SetPosition(0, 0.01, 0)
        end
    else 
        if self.selected_model then
			game.GamePool:GetPrefabPool("model/other/shadow.ab", "select_quad"):Free(self.selected_model)
            self.selected_model = nil
        end
    end
end

function Obj:ShowLight(val)
	if val then
		if not self.light_model then
			self.light_model = game.GamePool:GetPrefabPool("model/other/light.ab", "light_quad"):Create()
			self.light_model:SetParent(self.root_obj.tran, false)
        	self.light_model:SetScale(7, 1, 7)
		end
	else
		if self.light_model then
			game.GamePool:GetPrefabPool("model/other/light.ab", "light_quad"):Free(self.light_model)
			self.light_model = nil
		end
	end
end

function Obj:SetVisible(is_visible)
    if self.root_obj then
        self.root_obj.tran:SetVisible(is_visible)
    end
end

function Obj:SetModelVisible(is_visible)
	self.model_visible = is_visible
	if self.draw_obj then
		self.draw_obj:SetVisible(is_visible)
	end
end

function Obj:IsModelVisible()
    return self.model_visible
end

function Obj:SetLayer(model_type)
	if self.draw_obj then
		self.draw_obj:SetLayer(model_type)
	end
end

function Obj:SetModelChangeCallBack(callback)
	if self.draw_obj then
		self.draw_obj:SetModelChangeCallBack(callback)
	end
end

function Obj:GetModelHeight()
    return 2.0
end

-- hud
function Obj:RegisterHud()
	if not self.hud_id then
		self.hud_id = _fight_ctrl.instance:RegisterHud(self.main_root_obj.tran, self:GetModelHeight())
	end
	return self.hud_id
end

function Obj:UnRegisterHud()
	if self.hud_id then
		_fight_ctrl.instance:UnRegisterHud(self.hud_id)
		self.hud_id = nil
	end
end

function Obj:SetHudText(name, val, color_idx)
	local hud_id = self:RegisterHud()
	_fight_ctrl.instance:SetHudText(hud_id, name, val, color_idx)
end

function Obj:SetHudTextColor(name, color_idx)
	local hud_id = self:RegisterHud()
	_fight_ctrl.instance:SetHudTextColor(hud_id, name, color_idx)
end

function Obj:SetHudImg(name, sp_name, scale, is_flip_x)
	local hud_id = self:RegisterHud()
	_fight_ctrl.instance:SetHudImg(hud_id, name, sp_name, scale, is_flip_x)
end

function Obj:SetHudItemVisible(name, val)
	local hud_id = self:RegisterHud()
	_fight_ctrl.instance:SetHudItemVisible(hud_id, name, val)
end

function Obj:SetSpeakBubble(txt, time, bubble_id)
	local hud_id = self:RegisterHud()
	_fight_ctrl.instance:SetSpeakBubble(hud_id, txt, time, bubble_id)
end

function Obj:ShowHud(val)
	if self.hud_id then
		_fight_ctrl.instance:SetHudVisible(self.hud_id, val)
	end
end

function Obj:ResetHudPos()
	if self.hud_id then
		_fight_ctrl.instance:SetOwner(self.hud_id, self.main_root_obj.tran, self:GetModelHeight())
	end
end

function Obj:RefreshNameColor()
end

-- blood
function Obj:PlayBlood(num, harm_type)
	if self:CanPlayBlood() then
		_fight_ctrl.instance:PlayBlood(self, num, harm_type)
	end
end

function Obj:PlayMp(num)
	_fight_ctrl.instance:PlayMp(self, num)
end

function Obj:PlaySkill(id, lv)
	_fight_ctrl.instance:PlaySkill(self, id, lv)
end

function Obj:CanPlayBlood()
	return false
end

-- collider
function Obj:SetClickCallBack(func, r)
	if func then
		self:GetRoot():SetSphereCollider(true, r)
		self:GetRoot():SetObjInfo(self.obj_id)
	else
		if self.click_callback then
			self:GetRoot():SetSphereCollider(false, 0)
			self:GetRoot():SetObjInfo(0)
		end
	end
	self.click_callback = func
end

function Obj:OnClick()
	if self.click_callback then
		self.click_callback()
	end
end

-- obj type
function Obj:GetObjType()
	return self.obj_type
end

function Obj:GetObjID()
	return self.obj_id
end

function Obj:IsMainRole()
	return false
end

function Obj:IsMainRolePet()
	return false
end

function Obj:IsRole()
	return false
end

function Obj:IsClientObj()
	return false
end

function Obj:IsMonster()
	return false
end

function Obj:IsPet()
	return false
end

function Obj:IsBoss()
	return false
end

function Obj:RefreshShow()
	
end

function Obj:IsSettingVisible()
	return true
end

function Obj:GetUniqueId()
	return self.uniq_id
end

function Obj:GetScene()
	return self.scene
end

function Obj:SetRotation(x, y, z)
	self.draw_obj:SetRotation(x, y, z)
end

game.Obj = Obj

return Obj
