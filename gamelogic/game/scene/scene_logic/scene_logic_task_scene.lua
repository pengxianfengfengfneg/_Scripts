
local SceneLogicTaskScene = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicTaskScene:GetHangOperate()
    return game.OperateType.Hang
end

return SceneLogicTaskScene
