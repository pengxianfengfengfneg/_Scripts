
local SceneLogicSongliao = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicSongliao:_init(scene)
	self.scene = scene
end

function SceneLogicSongliao:_delete()

end

function SceneLogicSongliao:OnStartScene()
    self:SetCamera()
end

function SceneLogicSongliao:IsShowLogicExit()
	return true
end

function SceneLogicSongliao:DoSceneLogicExit()

	local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[4208])

    msg_box:SetOkBtn(function()
        game.SongliaoWarCtrl.instance:CsDynastyWarLeave()
    end)

    msg_box:SetCancelBtn(function()
    end)

    msg_box:Open()
end

function SceneLogicSongliao:IsShowLogicDetail()
	return true
end

function SceneLogicSongliao:DoSceneLogicDetail()
	game.SongliaoWarCtrl.instance:OpenRankView()
end

function SceneLogicSongliao:IsShowLogicTaskCom()
    return false
end

local pos_map = {
    [1] = {x=86.96, y= 131.43, z =161.82},
    [2] = {x=156.41, y= 131.43, z =181.77},
    [3] = {x=121.8, y= 131.43, z =166.71},
}
function SceneLogicSongliao:CreateBattleEffect(pos_index)

    self.effect2 = game.EffectMgr.instance:CreateEffect("effect/scene/battle_area.ab", 10)
    self.effect2:SetVisible(true)
    self.effect2:SetLoop(true)
    self.effect2:SetScale(0.8,0.8,0.8)
    game.RenderUnit.instance:AddToObjLayer(self.effect2:GetRoot())

    local cfg = pos_map[pos_index]
    self.effect2:SetPosition(cfg.x, cfg.y, cfg.z)
end

function SceneLogicSongliao:CreatePrepareEffect(pos_index)

    self.effect = game.EffectMgr.instance:CreateEffect("effect/scene/prepare_area.ab", 10)
    self.effect:SetVisible(true)
    self.effect:SetLoop(true)
    self.effect:SetScale(0.8,0.8,0.8)
    game.RenderUnit.instance:AddToObjLayer(self.effect:GetRoot())

    local cfg = pos_map[pos_index]
    self.effect:SetPosition(cfg.x, cfg.y, cfg.z)
end

function SceneLogicSongliao:DeletePoisonEffect()
    if self.effect then
        game.EffectMgr.instance:StopEffect(self.effect)
        self.effect = nil
    end

    if self.effect2 then
        game.EffectMgr.instance:StopEffect(self.effect2)
        self.effect2 = nil
    end
end

function SceneLogicSongliao:StopScene()
    self:DeletePoisonEffect()
end

function SceneLogicSongliao:SetCamera()
    local camera = self.scene:GetCamera()
    local role_pos = self.main_role:GetLogicPos()

    local sys_cfg = config.sys_config
    local song_pos = sys_cfg.dynasty_war_born_pos_song.value
    local liao_pos = sys_cfg.dynasty_war_born_pos_liao.value
    local angle = 0

    if song_pos[1] == role_pos.x and role_pos.y == song_pos[2] then
        angle = 180
    end

    camera:SetFollowObj(self.main_role, 20, cc.vec3(35, angle, 0))
end

return SceneLogicSongliao
