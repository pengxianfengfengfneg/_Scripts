local Door = Class(require("game/character/scene_element"))

local aoi_mgr = global.AoiMgr
local global_time = global.Time
local work_aoi_range = config.custom.door_work_aoi_range

function Door:_init()
    self.obj_type = game.ObjType.Door
    self.update_cd = 1
    self.cur_update_cd = 0
end

function Door:_delete()
end

function Door:Init(scene, vo)
    Door.super.Init(self, scene, vo)

    self:RegisterAoiWatcher(config.custom.scene_element_aoi_range, config.custom.scene_element_aoi_range, game.AoiMask.MainRole)
    self:RegisterWorkAoi()
end

function Door:Reset()
    self:UnregisterWorkAoi()
    Door.super.Reset(self)
end

function Door:Update(now_time, elapse_time)
    Door.super.Update(self, now_time, elapse_time)
    if self.is_show and self.enter_door then
        if self.work_time and now_time >= self.work_time then
            self:DoWorkAction()
            self.work_time = nil
        end
    end
end

function Door:RegisterWorkAoi()
    if self.work_aoi_id then
        return
    end
    local enter_func = function()
        self.enter_door = true
        self.work_time = global_time.now_time + config.custom.door_work_dur
    end
    local leave_func = function()
        self.enter_door = false
        self.work_time = nil
    end
    self.work_aoi_id = aoi_mgr:AddWatcher(self.logic_pos.x, self.logic_pos.y, work_aoi_range, work_aoi_range, game.AoiMask.MainRole, enter_func, leave_func)
end

function Door:UnregisterWorkAoi()
    if self.work_aoi_id then
        aoi_mgr:DelWatcher(self.work_aoi_id)
        self.work_aoi_id = nil
    end
end

function Door:CreateDrawObj()
    if self.effect then
        return
    end
    self.effect = game.EffectMgr.instance:CreateEffect(string.format("effect/scene/%s.ab", self.vo.res), 10)
    self.effect:SetLoop(true)
    self.effect:SetParent(self.root_obj.tran)
end

function Door:DestroyDrawObj()
    if self.effect then
        game.EffectMgr.instance:StopEffect(self.effect)
        self.effect = nil
    end
end

function Door:PlayDefaultAnim()

end

function Door:DoWorkAction()
    self.scene:SendSceneTransferReq(self.vo.door_id)
end

function Door:CanBeAttack()
    return false
end

return Door