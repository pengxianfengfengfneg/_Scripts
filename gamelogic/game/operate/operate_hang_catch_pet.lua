local OperateHangCatchPet = Class(require("game/operate/operate_base"))

local HangCatchPetState = {
    KillMonster = 1,
    Gather = 2,
    FindWay = 3,
    WaitItem = 4,
}

local item_id = config.sys_config["catch_pet_cost_item"].value

function OperateHangCatchPet:_init()
    self.oper_type = game.OperateType.HangCatchPet
end

function OperateHangCatchPet:Reset()
    self:ClearCurOperate()
    self.obj:SetSearchFliterFunc(nil)
    OperateHangCatchPet.super.Reset(self)
end

function OperateHangCatchPet:Init(obj, gather_id, monster_id, callback)
    OperateHangCatchPet.super.Init(self, obj)

    self.gather_id = gather_id
    self.monster_id = monster_id
    self.callback = callback

    self.target_monster_pos = nil
    local scene_cfg = self.obj:GetScene():GetSceneConfig()
    local monster_list = scene_cfg.monster_list
    for _,v in pairs(monster_list or {}) do
        for _,cv in pairs(v or {}) do
            if cv.monster_id == self.monster_id then
                local ux,uy = game.LogicToUnitPos(cv.x,cv.y)
                self.target_monster_pos = {x=ux, y=uy}
                break
            end
        end
    end

    local main_role_id = game.Scene.instance:GetMainRoleID()

    self.gather_fliter_func = function(obj)
        if obj:GetGatherId() == gather_id then
            return (main_role_id==obj.vo.owner_id)
        end
        return false
    end

    self.obj:SetSearchFliterFunc(function(obj)
        if obj:GetObjType() == game.ObjType.Monster then
            return (obj:GetMonsterId() == self.monster_id)
        end
        return false
    end)
end

function OperateHangCatchPet:Start()
    self.state = nil

    if game.PetCtrl.instance:IsFullBag() then
        game.GameMsgCtrl.instance:PushMsg(config.words[1973])
        return false,true
    end

    local cur_scene_id = game.Scene.instance:GetSceneID()
    local target_scene_id = config.sys_config.scene_pet_catch_show.value
    if cur_scene_id ~= target_scene_id then
        self.cur_oper = self:CreateOperate(game.OperateType.ChangeScene, self.obj, target_scene_id)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false,true
        end
    end

    return true
end

function OperateHangCatchPet:Update(now_time, elapse_time)
    local ret = self:UpdateCurOperate(now_time, elapse_time)
    if ret ~= nil then
        if self.state == HangCatchPetState.Gather then
            if ret then
                return true
            else
                self.state = HangCatchPetState.None
            end
        end
    end

    if not self.cur_oper then
        if self.state == HangCatchPetState.WaitItem then
            local item_num = game.BagCtrl.instance:GetNumById(item_id)
            if item_num > 0 then
                self.state = HangCatchPetState.None
            end
            return
        end

        local gather_obj_list = self.obj.scene:GetObjByType(game.ObjType.Gather, self.gather_fliter_func)
        local gather_obj_num = #gather_obj_list
        if gather_obj_num > 0 then
            local gather_obj = gather_obj_list[math.random(1,gather_obj_num)]

            local scene_logic = self.obj.scene:GetSceneLogic()
            local can_catch_pet, ret_code = scene_logic:CanDoGather(gather_obj)
            if not can_catch_pet then
                if ret_code == game.CatchPetCode.LackRope then
                    self.state = HangCatchPetState.WaitItem
                elseif ret_code == game.CatchPetCode.FullBag then
                    return false, true
                end
                return
            end

            self.cur_oper = self:CreateOperate(game.OperateType.GoToGather, self.obj, gather_obj.obj_id, 2)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
                return false
            else
                self.state = HangCatchPetState.Gather
            end
            return
        end

        if not self.obj:CanDoAttack() then
            return
        end

        local skill_id, skill_lv, is_enemy_skill, target, hero_id, legend = self.obj:GetNextSkill(true)
        if skill_id then
            if not target then
                target = self.obj:GetSkillTarget(skill_id)
            end

            if target then
                self.cur_oper = self:CreateOperate(game.OperateType.MoveAttack, self.obj, skill_id, skill_lv, target.obj_id, hero_id, legend)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                    self.state = nil
                else
                    self.is_enemy_skill = is_enemy_skill
                end

                self.state = HangCatchPetState.KillMonster
            else
                if self.target_monster_pos then
                    self.state = HangCatchPetState.FindWay
                    self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, self.target_monster_pos.x, self.target_monster_pos.y)
                    if not self.cur_oper:Start() then
                        self:ClearCurOperate()
                        self.state = nil
                    end
                else
                    return false,true
                end                
            end
        end
    else
        if self.is_enemy_skill and self.state == HangCatchPetState.KillMonster then
            if not self.obj:CanAttackObj(self.obj:GetTarget()) then
                self:ClearCurOperate()
                self.state = nil
            end
        end
    end
end

function OperateHangCatchPet:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
        return ret
    end
end

function OperateHangCatchPet:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangCatchPet:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type, self.gather_id, self.monster_id, self.callback)
end

return OperateHangCatchPet
