local JumpPoint = Class(require("game/character/scene_element"))

local aoi_mgr = global.AoiMgr
local _obj_state = game.ObjState

function JumpPoint:_init()
    self.update_cd = 0.3
end

function JumpPoint:_delete()
	self:UnRegisterJumpAoi()
end

function JumpPoint:Init(scene, vo)
	JumpPoint.super.Init(self, scene, vo)
	self.is_enabled = true
	self.is_enter_jump_point = false
    self.obj_type = game.ObjType.JumpPoint
    self.body_type = game.BodyType.JumpPoint
    self.avatar_id = self.vo.model_id

    self:UpdateModel()

    self:GetRoot():AddOffMeshLink(self.vo.to_pos.x, self.vo.to_pos.y, self.vo.to_pos.z or 0)

    self:RegisterJumpAoi()
end

function JumpPoint:Reset()
	self:UnRegisterJumpAoi()

    self:GetRoot():RemoveOffMeshLink()

    JumpPoint.super.Reset(self)
end

function JumpPoint:RegisterJumpAoi()
	if self.work_aoi_id then
		return
	end

    local function work_aoi_enter_func()
        if self.is_enabled then
            self.is_enter_jump_point = false
            self.enter_jump_point_time = nil

            local main_role = self.scene:GetMainRole()
            if main_role and main_role:CanDoJump() then
                self.is_enter_jump_point = true
                self.enter_jump_point_time = 0
            end            
        end
    end

    local function work_aoi_leave_func()
        self.is_enter_jump_point = false
        self.enter_jump_point_time = nil
    end
    self.work_aoi_id = aoi_mgr:AddWatcher(self.vo.x, self.vo.y, config.custom.jump_point_work_aoi_range, config.custom.jump_point_work_aoi_range, game.AoiMask.MainRole, work_aoi_enter_func, work_aoi_leave_func)
end

function JumpPoint:UnRegisterJumpAoi()
	if not self.work_aoi_id then
		return
	end

	aoi_mgr:DelWatcher(self.work_aoi_id)
	self.work_aoi_id = nil
end

function JumpPoint:SetEnabled(is_enabled)
    self.is_enabled = is_enabled
end

function JumpPoint:DoActiveAction()
    -- 激活动作
    if self.active_func then
        return self.active_func(self)
    end

    local main_role = self.scene:GetMainRole()
    if main_role then
        local flx,fly = game.UnitToLogicPos(self.vo.from_pos.x, self.vo.from_pos.z)
        local lx,ly = game.UnitToLogicPos(self.vo.to_pos.x, self.vo.to_pos.z)
        main_role:GetOperateMgr():DoJump(lx,ly,flx,fly, self.vo.mid_list)
    end
end

function JumpPoint:SetActiveAction(active_func)
    self.active_func = active_func
end

function JumpPoint:GetTargetSceneID()
    return self.vo.target_scene_id
end

function JumpPoint:CreateDrawObj()
    if self.vo.is_effect then
        if not self.jump_effect then
            self.jump_effect = game.EffectMgr.instance:CreateEffect(string.format("effect/scene/%s.ab", "jump"), 10)
            self.jump_effect:SetLoop(true)
            self.jump_effect:SetParent(self.root_obj.tran)
        end
    end
end

function JumpPoint:DestroyDrawObj()
    if self.jump_effect then
        game.EffectMgr.instance:StopEffect(self.jump_effect)
        self.jump_effect = nil
    end
end

local jump_point_work_dur = config.custom.jump_point_work_dur
function JumpPoint:Update(now_time, elapse_time)
	JumpPoint.super.Update(self, now_time, elapse_time)
    if self.is_enter_jump_point then
        if self.enter_jump_point_time then
            local main_role = self.scene:GetMainRole()
            local state_id = main_role:GetCurStateID()
            if state_id == _obj_state.Idle then
                self.enter_jump_point_time = self.enter_jump_point_time + elapse_time
                if self.enter_jump_point_time >= jump_point_work_dur then
                    self.enter_jump_point_time = nil
                    self:DoActiveAction()
                end
            end
        end
    end
end

return JumpPoint
