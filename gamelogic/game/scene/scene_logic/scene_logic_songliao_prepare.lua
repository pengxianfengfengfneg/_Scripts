
local SceneLogicSongliaoPrepare = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicSongliaoPrepare:_init(scene)
	self.scene = scene
end

function SceneLogicSongliaoPrepare:_delete()

end

function SceneLogicSongliaoPrepare:OnStartScene()

end

function SceneLogicSongliaoPrepare:IsShowLogicExit()
	return true
end

function SceneLogicSongliaoPrepare:DoSceneLogicExit()

	local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[4208])

    msg_box:SetOkBtn(function()
        game.SongliaoWarCtrl.instance:CsDynastyWarLeave()
    end)

    msg_box:SetCancelBtn(function()
    end)

    msg_box:Open()
end

function SceneLogicSongliaoPrepare:IsShowLogicDetail()
	return false
end

function SceneLogicSongliaoPrepare:IsShowLogicTaskCom()
    return false
end

return SceneLogicSongliaoPrepare
