
local SceneLogicTerritoryPrepare = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicTerritoryPrepare:_init(scene)
    self.scene = scene
end

function SceneLogicTerritoryPrepare:_delete()
    
end

function SceneLogicTerritoryPrepare:OnStartScene()
    self.main_role = self.scene.main_role

    game.MainUICtrl.instance:SwitchToFighting()
    game.GuildCtrl.instance:CloseView()
	game.FieldBattleCtrl.instance:OpenPrepareView()

	self.main_ui_view = game.MainUICtrl.instance:GetMainUIView()
    --self.main_ui_view:DoTerritoryBattleHide(true)
end

function SceneLogicTerritoryPrepare:StopScene()
    if game.FieldBattleCtrl.instance then
    	game.FieldBattleCtrl.instance:ClosePrepareView()
    end
    
    --self.main_ui_view:DoTerritoryBattleHide(false)
end

function SceneLogicTerritoryPrepare:IsShowLogicExit()
    return true
end

function SceneLogicTerritoryPrepare:DoSceneLogicExit()
    game.FieldBattleCtrl.instance:SendTerritoryLeave()
end

function SceneLogicTerritoryPrepare:IsShowLogicDetail()
    return false
end

function SceneLogicTerritoryPrepare:DoSceneLogicDetail()
    
end

return SceneLogicTerritoryPrepare
