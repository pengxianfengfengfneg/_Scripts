local SceneElement = Class(require("game/character/obj"))

local aoi_mgr = global.AoiMgr

function SceneElement:_init()
    self.update_cd = 5
    self.cur_update_cd = 0
end

function SceneElement:_delete()
end

function SceneElement:CheckUpdate(now_time, elapse_time)
    if self.is_show then
        self:UpdateModel()
    end
    
    self.cur_update_cd = elapse_time + self.cur_update_cd
    if self.cur_update_cd >= self.update_cd then
        self:Update(now_time, self.cur_update_cd)
        self.cur_update_cd = 0
    end
end

function SceneElement:Init(scene, vo)
    SceneElement.super.Init(self, scene)

    self.vo = vo
    self.body_type = game.BodyType.None
    self.avatar_id = nil
    self.is_show = false
    self.cur_update_cd = 0

    self:SetLogicPos(vo.x, vo.y)
    self:RegisterAoiWatcher(config.custom.scene_element_aoi_range, config.custom.scene_element_aoi_range, game.AoiMask.MainRole)
end

function SceneElement:Reset()
    self:DestroyDrawObj()
    SceneElement.super.Reset(self)
end

function SceneElement:OnAoiObjEnter()
    if not self.is_show then
        self:CreateDrawObj()
        self:PlayDefaultAnim()
        self.is_show = true
    end
end

function SceneElement:OnAoiObjLeave()
    if self.is_show then
        self:DestroyDrawObj()
        self.is_show = false
    end
end

function SceneElement:CreateDrawObj()
    if self.draw_obj then
        return
    end

    if not self.body_type or self.body_type == game.BodyType.None then
        return 
    end

    self.draw_obj = game.DrawObjPool:Create()
	self.draw_obj:Init(self.body_type)
    self.root:addChild(self.draw_obj.model_obj)
    if self.avatar_id then
        self.draw_obj:SetAvatar(game.DrawObjLayer.Body, self.avatar_id)
    end
    self:SetLogicPos(self.vo.x, self.vo.y)
end

function SceneElement:DestroyDrawObj()
    if self.draw_obj then
        game.DrawObjPool:Free(self.draw_obj)
        self.draw_obj = nil
    end
end

function SceneElement:PlayAnim(anim_name)
    if self.draw_obj then
        self.draw_obj:PlayAnim(anim_name)
    end
end

function SceneElement:PlayDefaultAnim()
    self:PlayAnim("default")
end

function SceneElement:CanBeAttack()
    return false
end

return SceneElement