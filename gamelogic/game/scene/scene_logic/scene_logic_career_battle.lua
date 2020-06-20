
local SceneLogicCareerBattle = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicCareerBattle:_init(scene)
    self.scene = scene
    self.ctrl = game.CareerBattleCtrl.instance

    self.scene_config = {
        [config.career_battle_info.lounge_scene] = {
            OnStartScene = function()
                self.ctrl:OpenLoungeSideInfoView()
                self.ctrl:CloseBattleResultView()
            end,
            StopScene = function()
                self.ctrl:CloseLoungeSideInfoView()
            end,
            Exit = function()
                self.ctrl:SendCareerBattleLeave()
            end,
            Detail = function()
                self.ctrl:OpenRewardRankView()
            end,
        },
        [config.career_battle_info.battle_scene] = {
            OnStartScene = function()
                self.ctrl:OpenFightSideInfoView()
                self.ctrl:StartBattleStartCounter()
                self:SetCamera()
            end,
            StopScene = function()
                self.ctrl:CloseFightSideInfoView()
                self.ctrl:StopBattleStartCounter()
                self.ctrl:StopBattleEndCounter()
            end,
            Exit = function()
                self.ctrl:SendCareerBattleLeaveBat()
            end,
            Detail = function()
                 self.ctrl:OpenFightRankView(game.RoleCtrl.instance:GetCareer())
            end,
        }
    }

    self.ctrl:CloseBattleResultView()
    self.ctrl:CloseRewardRankView()
    self.ctrl:CloseFightRankView()
    self.ctrl:CloseFightRankRewardView()
end

function SceneLogicCareerBattle:_delete()
    
end

function SceneLogicCareerBattle:OnStartScene()
    local scene_id = self.scene:GetSceneID()
    self.scene_config[scene_id]:OnStartScene()

    game.MainUICtrl.instance:SwitchToFighting()
end

function SceneLogicCareerBattle:StopScene()
    local scene_id = self.scene:GetSceneID()
    self.scene_config[scene_id]:StopScene()
end

function SceneLogicCareerBattle:OnMainRoleDie(killer_id, killer_name)
    
end

function SceneLogicCareerBattle:CanChangeScene(scene_id, notice)
    if not self.scene_config[scene_id] then
        if notice then
            game.GameMsgCtrl.instance:PushMsgCode(6020)
        end
        return false
    end
    return true
end

function SceneLogicCareerBattle:SetCamera()
    local camera = self.scene:GetCamera()
    local role_pos = self.main_role:GetLogicPos()

    local sys_cfg = config.sys_config
    local red_pos = sys_cfg.career_battle_born_pos_red.value
    local blue_pos = sys_cfg.career_battle_born_pos_blue.value
    local dir = cc.vec2(red_pos[1] - blue_pos[1], red_pos[2] - blue_pos[2])

    if blue_pos[1] == role_pos.x and blue_pos[2] == role_pos.y then
        dir = cc.pMul(dir, -1)
    end

    local angle = math.radian2angle(math.atan(dir.y, dir.x))
    angle = 270-angle
    camera:SetFollowObj(self.main_role, 20, cc.vec3(35, angle, 0))
end

function SceneLogicCareerBattle:IsShowLogicExit()
	return true
end

function SceneLogicCareerBattle:DoSceneLogicExit()
    local scene_id = self.scene:GetSceneID()
    self.scene_config[scene_id]:Exit()
end

function SceneLogicCareerBattle:IsShowLogicDetail()
	return true
end

function SceneLogicCareerBattle:DoSceneLogicDetail()
    local scene_id = self.scene:GetSceneID()
    self.scene_config[scene_id]:Detail()
end

function SceneLogicCareerBattle:IsShowLogicTaskCom()
	return false
end

function SceneLogicCareerBattle:CanBeAttack(obj)
    if self.scene:GetSceneID() == config.career_battle_info.battle_scene then
        local time = self.ctrl:GetBattleStartTime()
        return global.Time:GetServerTime() >= time
    end
    return SceneLogicCareerBattle.super.CanBeAttack(self, obj)
end

return SceneLogicCareerBattle
