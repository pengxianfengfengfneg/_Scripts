local SceneLogicAngerSkill = Class(require("game/scene/scene_logic/scene_logic_dungeon"))

local handler = handler
local event_mgr = global.EventMgr
local UserDefault = global.UserDefault

function SceneLogicAngerSkill:_init(scene)
	self.scene = scene
end

function SceneLogicAngerSkill:_delete()

end

function SceneLogicAngerSkill:OnStartScene()
	SceneLogicAngerSkill.super.OnStartScene(self)

	self.target_skill_id = 20030105

	self:RegisterAllEvents()
end

function SceneLogicAngerSkill:StopScene()
	local key = string.format("%s_%s", self.main_role:GetUniqueId(), self.target_skill_id)
	UserDefault:SetBool(key, true)

	if game.GuideCtrl.instance then
		game.GuideCtrl.instance:CloseGuideAngerView()
	end

	SceneLogicAngerSkill.super.StopScene(self)

	self:UnRegisterAllEvents()
end

function SceneLogicAngerSkill:RegisterAllEvents()
	local events = {
		{game.SceneEvent.OnSkillSpeak, handler(self,self.OnSkillSpeak)},
	}
	self.ev_list = {}
	for _,v in ipairs(events) do
		local ev = event_mgr:Bind(v[1],v[2])
		table.insert(self.ev_list, ev)
	end
end

function SceneLogicAngerSkill:UnRegisterAllEvents()
	for _,v in ipairs(self.ev_list or {}) do
		event_mgr:UnBind(v)
	end
	self.ev_list = nil
end

function SceneLogicAngerSkill:OnSkillSpeak(speak_name, speak_txt, speak_icon, skill_id)
	if skill_id == self.target_skill_id then
		local cd_ready = self:ShowAngerSkill()

		if cd_ready then
			game.GuideCtrl.instance:OpenGuideAngerView()
		end
	end
end

function SceneLogicAngerSkill:ShowAngerSkill()
	local data = {
		anger = 10000	
	}
	self.main_role:OnNotifyAngerChange(data)

	local main_ui_ctrl = game.MainUICtrl.instance
	main_ui_ctrl:SwitchToFighting()

	local main_view = main_ui_ctrl:GetMainUIView()
	main_view:ForceShowBigSkill()

	return main_view:IsBigSkillCDReady()
end

function SceneLogicAngerSkill:OnNotifyAngerChange(data)
	
end

return SceneLogicAngerSkill
