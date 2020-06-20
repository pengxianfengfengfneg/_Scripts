
local SceneLogicGuildArenaRest = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicGuildArenaRest:_init(scene)
	self.scene = scene
end

function SceneLogicGuildArenaRest:_delete()

end

function SceneLogicGuildArenaRest:OnStartScene()

	game.GuildArenaCtrl.instance:OpenRestRoomView()
end

function SceneLogicGuildArenaRest:StopScene()
	game.GuildArenaCtrl.instance:CloseRestRoomView()
end

function SceneLogicGuildArenaRest:IsShowLogicExit()
	return true
end

function SceneLogicGuildArenaRest:DoSceneLogicExit()

	local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[4115])

    msg_box:SetOkBtn(function()
        game.GuildArenaCtrl.instance:CsJoustsHallLeaveL()
    end)

    msg_box:SetCancelBtn(function()
    end)

    msg_box:Open()

end

function SceneLogicGuildArenaRest:IsShowLogicDetail()
	return true
end

--积分和奖励排行
function SceneLogicGuildArenaRest:DoSceneLogicDetail()
	game.GuildArenaCtrl.instance:OpenScoreRankView()
end

function SceneLogicGuildArenaRest:IsShowLogicTaskCom()
	return false
end

return SceneLogicGuildArenaRest
