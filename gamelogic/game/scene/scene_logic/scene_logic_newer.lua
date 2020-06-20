
local SceneLogicNewer = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicNewer:_init(scene)
	self.scene = scene
end

function SceneLogicNewer:_delete()

end

function SceneLogicNewer:CanAutoHang()
	return false
end

return SceneLogicNewer
