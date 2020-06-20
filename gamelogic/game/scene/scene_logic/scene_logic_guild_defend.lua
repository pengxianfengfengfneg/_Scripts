
local SceneLogicGuildDefend = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicGuildDefend:_init(scene)
	self.scene = scene
end

function SceneLogicGuildDefend:_delete()

end

function SceneLogicGuildDefend:OnStartScene()
    game.GuildCtrl.instance:OpenGuildDefendSideInfoView()
	game.MainUICtrl.instance:SwitchToFighting()
end

function SceneLogicGuildDefend:StopScene()
	game.GuildCtrl.instance:CloseGuildDefendSideInfoView()
end

function SceneLogicGuildDefend:CanChangeScene(scene_id, notice)
	if notice then
		game.GameMsgCtrl.instance:PushMsgCode(6020)
	end
    return false
end

function SceneLogicGuildDefend:IsShowLogicExit()
	return true
end

function SceneLogicGuildDefend:DoSceneLogicExit()
	game.GuildCtrl.instance:SendGuildDefendLeave()
end

function SceneLogicGuildDefend:IsShowLogicDetail()
	return true
end

function SceneLogicGuildDefend:DoSceneLogicDetail()
	game.GuildCtrl.instance:OpenGuildDefendRewardView()
end

function SceneLogicGuildDefend:IsShowLogicTaskCom()
	return false
end

return SceneLogicGuildDefend
