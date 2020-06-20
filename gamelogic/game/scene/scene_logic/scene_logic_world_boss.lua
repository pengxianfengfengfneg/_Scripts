
local SceneLogicWorldBoss = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicWorldBoss:_init(scene)
	self.scene = scene

	self.ctrl = game.WorldBossCtrl.instance
end

function SceneLogicWorldBoss:_delete()

end

function SceneLogicWorldBoss:StartScene()
	self.main_role = self.scene:GetMainRole()
	
	self.ctrl:OpenSideInfoView()
    game.MainUICtrl.instance:SwitchToFighting()

    local main_ui_view = game.MainUICtrl.instance:GetMainUIView()
    self.target_com = main_ui_view:GetTargetCom()

    self.orign_x,self.orign_y = self.target_com:GetPosition()
    self.target_com:SetPosition(self.orign_x, self.orign_y + 130)
end

function SceneLogicWorldBoss:StopScene()
	self.ctrl:CloseSideInfoView()
	self.ctrl:CloseHurtRankView()
	self.ctrl:CloseShieldView()

	if game.MainUICtrl.instance then
		self.target_com:SetPosition(self.orign_x, self.orign_y)
	end
end

function SceneLogicWorldBoss:CreateMonster(vo)
	local monster = self.scene:_CreateMonster(vo)
	monster:SetSelected(true)

	return monster
end

function SceneLogicWorldBoss:CreateMainRole(vo)
	local main_role = self.scene:_CreateMainRole(vo)
	local FireSelectTarget = main_role.FireSelectTarget 
	main_role.FireSelectTarget = function(role, obj)
		local target_obj = nil
		if obj and obj:GetObjType() == game.ObjType.Role then
			target_obj = obj
		end
		FireSelectTarget(role, target_obj)
	end

	return main_role
end

return SceneLogicWorldBoss
