local PostEffectCtrl = Class(game.BaseCtrl)

local Shader = UnityEngine.Shader
local SetGlobalFloat = Shader.SetGlobalFloat
local GetGlobalFloat = Shader.GetGlobalFloat

local RenderTexture = UnityEngine.RenderTexture

function PostEffectCtrl:_init()
    if PostEffectCtrl.instance ~= nil then
        error("PostEffectCtrl Init Twice!")
    end
    PostEffectCtrl.instance = self

    self:RegisterAllEvents()

    global.Runner:AddUpdateObj(self, 2)
end

function PostEffectCtrl:_delete()
    global.Runner:RemoveUpdateObj(self)

    PostEffectCtrl.instance = nil
end

function PostEffectCtrl:RegisterAllEvents()
    local events = {
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

local EffectParams = {
    
}

local EffectUpdateFunc = {
    [game.MaterialEffect.EffectWave] = 
    {
        init = function(self, now_time, callback)
            EffectParams.wave_start_time = now_time
            EffectParams.wave_end_time = now_time + 1.2
            EffectParams.wave_callback = callback
        end,
        update = function(self, now_time, elapse_time)
            if EffectParams.wave_start_time then
                local curWaveDist = (now_time-EffectParams.wave_start_time)*0.3
                SetGlobalFloat("_GlobalCurWaveDist", curWaveDist)

                if now_time >= EffectParams.wave_end_time then
                    self:StopEffect()
                    EffectParams.wave_start_time = nil

                    if EffectParams.wave_callback then
                        EffectParams.wave_callback()
                    end
                end
            end
        end,
    }
}

function PostEffectCtrl:StartEffect(mat_name, callback, downSample, renderNum, snapMode)
    if not self.scene_camera then
        self.scene_camera = game.RenderUnit:GetUICamera()
    end
    
    self.cur_mat_name = mat_name

    local func_cfg = EffectUpdateFunc[self.cur_mat_name]
    if func_cfg then
        func_cfg.init(self, global.Time.now_time, callback)
    end

    self.scene_camera:StartImageEffect(mat_name, downSample or 0, renderNum or 0, snapMode or false)
end

function PostEffectCtrl:StopEffect()
    self.cur_mat_name = nil

    if self.scene_camera then
        self.scene_camera:StopImageEffect()
    end
end

function PostEffectCtrl:Update(now_time, elapse_time)
    local func_cfg = EffectUpdateFunc[self.cur_mat_name]
    if func_cfg then
        func_cfg.update(self, now_time, elapse_time)
    end
end

game.PostEffectCtrl = PostEffectCtrl

return PostEffectCtrl