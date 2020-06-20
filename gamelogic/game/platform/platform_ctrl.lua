local PlatformCtrl = Class(game.BaseCtrl)

function PlatformCtrl:_init()
    if PlatformCtrl.instance ~= nil then
        error("PlatformCtrl Init Twice!")
    end
    PlatformCtrl.instance = self
    
    self:Init()
end

function PlatformCtrl:_delete()

    PlatformCtrl.instance = nil
end

function PlatformCtrl:Init()
    self.target_platform = UnityEngine.Application.platform

    local RuntimePlatform = UnityEngine.RuntimePlatform

    self.is_ios_platform = (self.target_platform==RuntimePlatform.IPhonePlayer)
    self.is_android_platform = (self.target_platform==RuntimePlatform.Android)
    self.is_window_platform = (self.target_platform==RuntimePlatform.WindowsPlayer or self.target_platform==RuntimePlatform.WindowsEditor)

    self.ditch_id = N3DClient.GameConfig.GetClientConfig("DitchID")
    self.app_version = N3DClient.GameConfig.GetClientConfigInt("AppVersion")

    self.root_url_mode = N3DClient.GameConfig.GetClientConfig("RootUrlMode")

    self.device_id = N3DClient.GameTool:GetDeviceID() 

    self.android_index = 1
    self.ios_index = 2
    self.os_index = (self:IsIosPlatform() and self.ios_index or self.android_index)

    self:InitChargeConfig()
end

function PlatformCtrl:InitChargeConfig()
    self.config_recharge_sort = {}
    for _,v in pairs(config.recharge or {}) do
        if not self.config_recharge_sort[v.os] then
            self.config_recharge_sort[v.os] = {}
        end
        table.insert(self.config_recharge_sort[v.os], v)
    end

    for _,v in pairs(self.config_recharge_sort) do
        table.sort(v, function(v1,v2)
            return v1.product_id<v2.product_id
        end)
    end
end

function PlatformCtrl:GetTargetPlatform()
    return self.target_platform
end

function PlatformCtrl:IsWindowsPlatform()
    return self.is_window_platform
end

function PlatformCtrl:IsAndroidPlatform()
    return self.is_android_platform
end

function PlatformCtrl:IsIosPlatform()
    return self.is_ios_platform
end

function PlatformCtrl:GetDitchId()
    return self.ditch_id
end

function PlatformCtrl:GetAppVersion()
    return self.app_version
end

function PlatformCtrl:GetDeviceId()
    return self.device_id
end

-- 是否ios越狱
function PlatformCtrl:IsIosBroken()
    return false
end

-- 扩展方法
-- 充值适配
local Ios2Android = {
    
}
local Android2Ios = {

}

function PlatformCtrl:GetRechargeConfig()
    local recharge_config = self.config_recharge_sort[self.os_index]
    if self:IsIosPlatform() then
        if Ios2Android[self.ditch_id] then
            recharge_config = self.config_recharge_sort[self.android_index]
        end
    end
    return recharge_config
end

-- 海外适配
local HKTW_Ditchs = {
    ["3001"] = 1
}
function PlatformCtrl:IsHKTW()
    return (HKTW_Ditchs[self.ditch_id]~=nil)
end

function PlatformCtrl:IsKorea()

end

function PlatformCtrl:IsVietnam()

end

function PlatformCtrl:IsXinMa()

end

function PlatformCtrl:IsDevMode()
    return (self.root_url_mode=="dev")
end

function PlatformCtrl:IsBaseMode()
    return (self.root_url_mode=="base")
end

game.PlatformCtrl = PlatformCtrl

return PlatformCtrl
