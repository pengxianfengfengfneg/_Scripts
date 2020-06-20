
local SceneLogicCommon = Class(require("game/scene/scene_logic/scene_logic_base"))

-- 显示任务栏
function SceneLogicCommon:IsShowLogicTaskCom()
	return true
end

function SceneLogicCommon:CanDoCrossOperate()
	
	return true
end

return SceneLogicCommon
