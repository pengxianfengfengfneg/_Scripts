
local SceneLogicGuildArenaSecond = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicGuildArenaSecond:_init(scene)
	self.scene = scene
end

function SceneLogicGuildArenaSecond:_delete()

end

function SceneLogicGuildArenaSecond:OnStartScene()
	game.GuildArenaCtrl.instance:OpenFightViewSecond()

	self:CreatePoisonEffect()
end

function SceneLogicGuildArenaSecond:StopScene()
	game.GuildArenaCtrl.instance:CloseFightViewSecond()

	self:DeletePoisonEffect()
end

function SceneLogicGuildArenaSecond:CreatePoisonEffect()

	self:DeletePoisonEffect()

	self.effect = game.EffectMgr.instance:CreateEffect("effect/scene/poison_area.ab", 10)
	self.effect:SetVisible(false)
    self.effect:SetLoop(true)
    game.RenderUnit.instance:AddToObjLayer(self.effect:GetRoot())
    self.effect:SetPosition(79, 108, 77)
end

function SceneLogicGuildArenaSecond:DeletePoisonEffect()
	if self.effect then
        game.EffectMgr.instance:StopEffect(self.effect)
        self.effect = nil
    end
end

function SceneLogicGuildArenaSecond:SetPoisonVisibel(val)
	if self.effect then
		self.effect:SetVisible(val)
	else
		self:CreatePoisonEffect()
		self.effect:SetVisible(val)
	end
end

function SceneLogicGuildArenaSecond:IsShowLogicExit()
	return true
end

function SceneLogicGuildArenaSecond:DoSceneLogicExit()
	local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[4115])

    msg_box:SetOkBtn(function()
        game.GuildArenaCtrl.instance:CsJoustsHallLeaveB()
    end)

    msg_box:SetCancelBtn(function()
    end)

    msg_box:Open()
end

function SceneLogicGuildArenaSecond:IsShowLogicDetail()
	return true
end

--积分和奖励排行
function SceneLogicGuildArenaSecond:DoSceneLogicDetail()
	game.GuildArenaCtrl.instance:OpenScoreRankView()
end

function SceneLogicGuildArenaSecond:IsShowLogicTaskCom()
	return false
end

return SceneLogicGuildArenaSecond
