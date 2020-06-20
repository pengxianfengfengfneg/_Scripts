local ArenaCtrl = Class(game.BaseCtrl)

function ArenaCtrl:_init()
	if ArenaCtrl.instance ~= nil then
		error("ArenaCtrl Init Twice!")
	end
	ArenaCtrl.instance = self
	
	self.arena_data = require("game/arena/arena_data").New()

	self:RegisterAllProtocal()
	self:RegisterAllEvents()
end

function ArenaCtrl:_delete()
	self.arena_data:DeleteMe()
	self.arena_data = nil

	if self.arena_view then
		self.arena_view:DeleteMe()
		self.arena_view = nil
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	if self.result_view then
		self.result_view:DeleteMe()
		self.result_view = nil
	end

	ArenaCtrl.instance = nil
end

function ArenaCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(30202, "ArenaInfoResponse")
	self:RegisterProtocalCallback(30204, "ArenaOpponentResponse")
	self:RegisterProtocalCallback(30206, "ArenaBuyTimesResponse")
	self:RegisterProtocalCallback(30208, "ArenaRankResponse")
	self:RegisterProtocalCallback(30210, "ArenaBattleResponse")
	self:RegisterProtocalCallback(30211, "ArenaBattleResultResponse")
	self:RegisterProtocalCallback(30214, "ScArenaQuit")
end

function ArenaCtrl:RegisterAllEvents()
    local events = {
        -- {game.LoginEvent.LoginSuccess, handler(self, self.ArenaInfoReq)},
         {game.SceneEvent.ChangeScene, handler(self, self.ChangeScene)}
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end


function ArenaCtrl:OpenArenaView(index)
	if not self.arena_view then
		self.arena_view = require("game/arena/arena_view").New(self)
	end

	self.arena_view:Open(index)
end

function ArenaCtrl:CloseArenaView()
	if self.arena_view then
		self.arena_view:DeleteMe()
		self.arena_view = nil
	end
end

function ArenaCtrl:OpenRankView()
	if not self.rank_view then
		self.rank_view = require("game/arena/arena_rank_view").New(self)
	end
	self.rank_view:Open()
end

function ArenaCtrl:OpenResultView(data)
	if not self.result_view then
		self.result_view = require("game/arena/arena_result_view").New(self)
	end
	self.result_view:Open(data)
end

function ArenaCtrl:ArenaInfoReq()
	self:SendProtocal(30201,{})
end

function ArenaCtrl:ArenaInfoResponse(data)
	self.arena_data:SetArenaInfo(data)
end

--刷新对手信息
function ArenaCtrl:ArenaOpponentReq()
	self:SendProtocal(30203,{})
end

function ArenaCtrl:ArenaOpponentResponse(data)
	self.arena_data:SetOppData(data)

	self:FireEvent(game.ArenaEvent.UpdateOpp)
end

--购买次数
function ArenaCtrl:ArenaBuyTimesReq()
	self:SendProtocal(30205,{})
end

function ArenaCtrl:ArenaBuyTimesResponse(data)
	self.arena_data:UpdateBuyTimes(data)

	self:FireEvent(game.ArenaEvent.UpdateTimes)
end

--获取排行信息
function ArenaCtrl:ArenaRankReq()
	self:SendProtocal(30207,{})
end

function ArenaCtrl:ArenaRankResponse(data)

	self.arena_data:SetRankList(data)

	self:FireEvent(game.ArenaEvent.UpdateRankList)
end

--挑战对手
function ArenaCtrl:ArenaBattleReq(o_rank, o_role_id)
	self:SendProtocal(30209,{rank = o_rank, role_id = o_role_id})
end

function ArenaCtrl:ArenaBattleResponse(data)
	self.arena_data:SubLeftTimes()
	self:FireEvent(game.ArenaEvent.UpdateTimes)
end

--挑战结果
function ArenaCtrl:ArenaBattleResultResponse(data)
	self.arena_data:UpdateMyRank(data)

	self:OpenResultView(data)
end

function ArenaCtrl:GetData()
	return self.arena_data
end

function ArenaCtrl:ChangeScene(to_scene_id, from_scene_id)

	if not to_scene_id then return end
	local scene_type = config.scene[to_scene_id].type
	if scene_type == game.SceneType.RobotPvPScene then

		local scene_logic = game.Scene.instance:GetSceneLogic()
		scene_logic:AddSceneStartFunc(function()
			game.MainUICtrl.instance:SwitchToFighting()
			self:OpenFightView()
		end)
	end

	if not from_scene_id then return end
	local scene_type = config.scene[from_scene_id].type
	if scene_type == game.SceneType.RobotPvPScene then

		if from_scene_id == config.sys_config.master_rob_scene.value then
			local scene_logic = game.Scene.instance:GetSceneLogic()
			scene_logic:AddSceneStartFunc(function()
				game.MainUICtrl.instance:SwitchToMainCity()
				self:CloseFightView()
				game.OverlordCtrl.instance:OpenView()
			end)
			return
		end

		local scene_logic = game.Scene.instance:GetSceneLogic()
		scene_logic:AddSceneStartFunc(function()
			game.MainUICtrl.instance:SwitchToMainCity()
			self:CloseFightView()
			self:OpenArenaView()
		end)
	end
end

function ArenaCtrl:OpenFightView()
	if not self.fight_view then
		self.fight_view = require("game/arena/arena_fight_view").New()
	end
	self.fight_view:Open()
end

function ArenaCtrl:CloseFightView()
	if self.fight_view and self.fight_view:IsOpen() then
		self.fight_view:Close()
	end
end

function ArenaCtrl:GetMyRank()
	return self.data:GetMyRank()
end

function ArenaCtrl:CsArenaQuit()
	self:SendProtocal(30213,{})
end

function ArenaCtrl:ScArenaQuit(data)

end

game.ArenaCtrl = ArenaCtrl

return ArenaCtrl