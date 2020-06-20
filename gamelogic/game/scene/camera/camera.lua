
local Camera = Class()

local _render_unit = game.RenderUnit

function Camera:_init()
    self.camera_obj = game.RenderUnit:GetSceneCameraObj()
    self.camera = game.RenderUnit:GetSceneCamera()
end

function Camera:_delete()
    self:Stop()
end

function Camera:Start()

end

function Camera:Stop()
    self:Reset()
end

function Camera:GetCameraPos()
    return self.camera_obj:GetGlobalPosition()
end

-- actions
function Camera:SetFollowObj(obj, dist, rot)
    self.camera:SetLookAtTarget(obj:GetRoot(), dist, rot.x, rot.y, rot.z)
end

function Camera:ChangeFollowDist(dist)
    self.camera:ChangeLookAtDistance(dist)
end

function Camera:ChangeFollowRotation(x, y)
    self.camera:ChangeLookAtRotation(x, y, 0)
end

function Camera:SetLookAtOffset(x, y, z)
    self.camera:SetLookAtOffset(x, y, z)
end

function Camera:StartLerp(interval, speed)
    if self.is_lock then
        return
    end
    
    self.camera:EnableLookAtLerp(true, interval or 2, speed or 0.8)
end

function Camera:StopLerp()
    self.camera:EnableLookAtLerp(false, 0, 0)
end

function Camera:SetCameraLock(val)
    self.is_lock = val
    if val then
        self.camera:EnableLookAtLerp(false, 0, 0)
    end
end

function Camera:EnableColliderCheck(val)
    self.camera:EnableColliderCheck(val)
end

function Camera:Reset()
    self.camera:SetLookAtTarget(nil, 0, 0, 0, 0)
end

-- shake
--[[
摄像机抖动
@x,y,z : 振动方向
@shake_cycle_num : 振动的周期数
@shake_cycle_time: 每个周期的时间长度，单位秒
]]
function Camera:StartShake(x, y, z, cycle_num, cycle_time)
    self.camera:StartShake(x, y, z, cycle_num, cycle_time)
end

function Camera:StopShake()
    self.camera:StopShake()
end

-- translate
function Camera:CameraToWorldDir2D(x, y)
    return _render_unit:CameraToWorldDir2D(self.camera, x, y)
end

function Camera:ScreenToWorldPos(x, y)
    return _render_unit:ScreenToWorldPos(self.camera, x, y)
end

function Camera:WorldToScreenPos(x, y, z)
    return _render_unit:WorldToScreenPos(self.camera, x, y, z)
end

function Camera:Raycast(x, y, dist, layer_mask)
    return _render_unit:RaycastFromScreenPos(self.camera, x, y, dist, layer_mask)
end

function Camera:WorldToUIPos(obj, x, y, z)
    return _render_unit:WorldToUIPos(self.camera, obj, x, y, z)
end

function Camera:CheckRaycastObj(x, y, dist, layer_mask)
    return self.camera:CheckRaycastObj(x, y, dist, layer_mask)
end

return Camera
