
local SceneLogicGuildArenaFirst = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicGuildArenaFirst:_init(scene)
	self.scene = scene
end

function SceneLogicGuildArenaFirst:_delete()

end

function SceneLogicGuildArenaFirst:OnStartScene()
	game.GuildArenaCtrl.instance:OpenFightViewFirst()

	self:CreatePoisonEffect()
end

function SceneLogicGuildArenaFirst:StopScene()
	game.GuildArenaCtrl.instance:CloseFightViewFirst()

	self:DeletePoisonEffect()
end

function SceneLogicGuildArenaFirst:CreatePoisonEffect()

	self:DeletePoisonEffect()

	self.effect = game.EffectMgr.instance:CreateEffect("effect/scene/poison_area.ab", 10)
	self.effect:SetVisible(false)
    self.effect:SetLoop(true)
    game.RenderUnit.instance:AddToObjLayer(self.effect:GetRoot())
    self.effect:SetPosition(79, 108, 77)
end

function SceneLogicGuildArenaFirst:DeletePoisonEffect()
	if self.effect then
        game.EffectMgr.instance:StopEffect(self.effect)
        self.effect = nil
    end
end

function SceneLogicGuildArenaFirst:SetPoisonVisibel(val)
	if self.effect then
		self.effect:SetVisible(val)
	else
		self:CreatePoisonEffect()
		self.effect:SetVisible(val)
	end
end

function SceneLogicGuildArenaFirst:IsShowLogicExit()
	return true
end

function SceneLogicGuildArenaFirst:DoSceneLogicExit()
	local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[4115])

    msg_box:SetOkBtn(function()
        game.GuildArenaCtrl.instance:CsJoustsHallLeaveB()
    end)

    msg_box:SetCancelBtn(function()
    end)

    msg_box:Open()
end

function SceneLogicGuildArenaFirst:IsShowLogicDetail()
	return true
end

--积分和奖励排行
function SceneLogicGuildArenaFirst:DoSceneLogicDetail()
	game.GuildArenaCtrl.instance:OpenScoreRankView()
end

function SceneLogicGuildArenaFirst:IsShowLogicTaskCom()
	return false
end

return SceneLogicGuildArenaFirst
