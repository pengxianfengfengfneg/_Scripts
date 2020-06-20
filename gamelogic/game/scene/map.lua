local Map = Class()

local _asset_loader = global.AssetLoader
local _gameobject = UnityEngine.GameObject

function Map:_init()

end

function Map:_delete()
    self:ClearMap()
end

function Map:LoadMap(id)
    if self.map_id == id then
        return
    end

    self.map_id = id
    self.load_finish = false

    local path = string.format("map/%d/scene.ab", id)
    self.req_id = _asset_loader:LoadScene(path, tostring(id), function()
        self:InitMapInfo()
        self.load_finish = true
    end)
end

function Map:ClearMap(to_map_id)
    if self.map_id == to_map_id then
        return
    end

    if self.req_id then
        _asset_loader:UnLoad(self.req_id)
        self.req_id = nil
    end

    self:EnableRealTimeShadow(false)
end

function Map:GetLoadState()
    return self.load_finish, 1
end

function Map:Start()

end

function Map:Update(now_time, elapse_time)

end

function Map:Stop()

end

function Map:GetMapId()
    return self.map_id
end

function Map:InitMapInfo()
    self.map_root = UnityEngine.GameObject.Find(self.map_id)
    if self.map_root then
        self.map_shader_info = self.map_root:GetComponent(ShaderInfo)
    end
end

function Map:GetObjMainLightDir()
    local rot_x, rot_y, rot_z = UnityEngine.Shader.GetGlobalVector("_GlobalObjMainLightDir")
    return UnityEngine.Quaternion.FromToRotation(0, 0, 1, -rot_x, -rot_y, -rot_z)
end

function Map:EnableRealTimeShadow(val)
    if val then
        if not self.shadow_cam then
            self.shadow_cam = global.AssetLoader:CreateGameObject("model/other/shadow.ab", "shadow_cam")
            local cam = self.shadow_cam:GetComponent(UnityEngine.Camera)
            cam:EnableColliderCheck(false)
            
            if self.shadow_cam then
                UnityEngine.Shader.EnableKeyword("_G_REALTIME_SHADOW_ON")
            end
        end
    else
        if self.shadow_cam then
            UnityEngine.GameObject.Destroy(self.shadow_cam)
            UnityEngine.Shader.DisableKeyword("_G_REALTIME_SHADOW_ON")
            self.shadow_cam = nil
        end
    end
end

function Map:SetRealTimeShadowTarget(tran)
    if self.shadow_cam then
        local x, y, z = self:GetObjMainLightDir()
        local cam = self.shadow_cam:GetComponent(UnityEngine.Camera)
        cam:SetLookAtTarget(tran, 20, x, y, z)
    end
end

return Map
