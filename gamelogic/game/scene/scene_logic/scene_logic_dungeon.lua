
local SceneLogicDungeon = Class(require("game/scene/scene_logic/scene_logic_base"))

local _event_mgr = global.EventMgr

function SceneLogicDungeon:_init(scene)
	self.scene = scene
end

function SceneLogicDungeon:_delete()

end

function SceneLogicDungeon:OnStartScene()
	self.carbon_ctrl = game.CarbonCtrl.instance
	if self.carbon_ctrl then
		self.carbon_ctrl:CloseView()
		--self.carbon_ctrl:OpenFightView()
	end

	game.MainUICtrl.instance:SwitchToFighting()

	game.MakeTeamCtrl.instance:DoFollowReset()
	self.main_role:GetOperateMgr():DoSceneHang()

	self._ev_list = {
        _event_mgr:Bind(game.CarbonEvent.OnDungData, handler(self, self.OnDungData)),
        _event_mgr:Bind(game.CarbonEvent.OnDungRefreshMon, handler(self, self.OnDungRefreshMon)),
    }
end

function SceneLogicDungeon:StopScene()
	if game.CarbonCtrl.instance then
		self.carbon_ctrl:ResetDunFightData()
		self.carbon_ctrl:CloseFightView()
	end

	for k, v in pairs(self._ev_list) do
        _event_mgr:UnBind(v)
    end
    self._ev_list = {}
end

function SceneLogicDungeon:GetHangOperate()
    return game.OperateType.HangDungeon
end

function SceneLogicDungeon:OnMainRoleDie(data_list)
	local dun_id = game.CarbonCtrl.instance.enter_dun_id
	if dun_id and config.dungeon[dun_id].cate == 2 then
		game.FightCtrl.instance:OpenReviveView(self.scene:GetSceneID(), data_list)
	end
end

function SceneLogicDungeon:IsShowLogicExit()
	return true
end

function SceneLogicDungeon:DoSceneLogicExit()
	self.carbon_ctrl:DungLeaveReq()

	local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():ClearOperate()
    end
end

function SceneLogicDungeon:CreateRole(vo)
	local role = self.scene:_CreateRole(vo)

    if role:IsClientObj() then
        role:GetOperateMgr():SetDefaultOper(game.OperateType.HangRobot)
    end

	return role
end

function SceneLogicDungeon:OnDungRefreshMon(data)
	local dung_id = self.carbon_ctrl:GetEnterDungID()
	if dung_id == game.DungeonId.Chess or data.dung_id == game.DungeonId.SingleChess then
		self:NoticeChessInfo(data.wave)
	end
end

function SceneLogicDungeon:OnDungData(data)
	if self.main_role then
		local dun_cfg = config.dungeon[data.dung_id]
		if dun_cfg then
			self.main_role:SetSearchEnemyPriority(dun_cfg.hang_type)
		end
	end

	if data.dung_id == game.DungeonId.Chess or data.dung_id == game.DungeonId.SingleChess then
		self:NoticeChessInfo(data.wave)
	end
end

function SceneLogicDungeon:NoticeChessInfo(wave)
	local max_wave = (#config.dungeon_lv[game.DungeonId.Chess][1].wave_list) - 1
	game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1969], wave, max_wave))
end

return SceneLogicDungeon
