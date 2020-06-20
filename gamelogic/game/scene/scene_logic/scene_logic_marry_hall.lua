
local SceneLogicMarryHall = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicMarryHall:_init(scene)
	self.scene = scene
end

function SceneLogicMarryHall:_delete()

end

function SceneLogicMarryHall:IsShowLogicExit()
	return true
end

function SceneLogicMarryHall:DoSceneLogicExit()
	game.MarryProcessCtrl.instance:CsMarryHallLeave()
end

return SceneLogicMarryHall
