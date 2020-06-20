
local FollowObj = Class(require("game/character/character"))
local _model_type = game.ModelType

function FollowObj:_init()
    self.obj_type = game.ObjType.FollowObj
    self.update_cd = 0.5 + math.random(10) * 0.03
end

function FollowObj:_delete()

end

function FollowObj:Init(scene, vo)
    FollowObj.super.Init(self, scene)

    self.model_id = vo.model_id
    self.owner = vo.owner
    self.offset = vo.offset or 6
    self.vo = vo
    self:CreateDrawObj()
end

function FollowObj:Reset()
	FollowObj.super.Reset(self)
end

-- 外观形象相关
function FollowObj:CreateDrawObj()
    local cur_x, cur_y = self.owner:GetLogicPosXY()
    local dir = self.owner:GetDir()
    local angle = math.atan(-dir.y, -dir.x)
    local offset = self.offset

    self:SetDirForce(dir.x, dir.y)
    self:SetLogicPos(cur_x + math.floor(offset * math.cos(angle)), cur_y + math.floor(offset * math.sin(angle)))
    
    self.draw_obj = game.GamePool.DrawObjPool:Create()
    self.draw_obj:Init(game.BodyType.Monster)
    self.draw_obj:SetParent(self.root_obj.tran)
    self.draw_obj:SetModelID(_model_type.Body, self.model_id)

    self:ShowShadow(true)

    self:SetFollowTarget(self.owner.obj_id)
end

function FollowObj:SetModelID(id)
	if self.draw_obj then
    	self.draw_obj:SetModelID(_model_type.Body, id)
	end
end

function FollowObj:GetOwner()
	return self.owner
end

function FollowObj:SetOwner(owner)
	self.owner = owner
end

function FollowObj:CanDoMove()
	return true
end

function FollowObj:CanBeAttack()
    return false
end

function FollowObj:SetFollowTarget(target_id)
    self:GetOperateMgr():DoFollow(target_id, self.offset)
end

function FollowObj:GetSpeed()
    return self.owner:GetSpeed() * 0.9
end

return FollowObj
