--演武堂

local GuildArenaCtrl = Class(game.BaseCtrl)

function GuildArenaCtrl:_init()
	if GuildArenaCtrl.instance ~= nil then
		error("GuildArenaCtrl Init Twice!")
	end
	GuildArenaCtrl.instance = self

	self.data = require("game/guild_arena/guild_arena_data").New()

	self:RegisterAllProtocal()
end

function GuildArenaCtrl:_delete()

	if self.guild_arena_restroom_view then
		self.guild_arena_restroom_view:DeleteMe()
		self.guild_arena_restroom_view = nil
	end

	if self.guild_arena_fight_view_first then
		self.guild_arena_fight_view_first:DeleteMe()
		self.guild_arena_fight_view_first = nil
	end

	if self.guild_arena_fight_view_second then
		self.guild_arena_fight_view_second:DeleteMe()
		self.guild_arena_fight_view_second = nil
	end

	GuildArenaCtrl.instance = nil
end

function GuildArenaCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(51702, "ScJoustsHallEnter")
	self:RegisterProtocalCallback(51704, "ScJoustsHallLeaveL")
	self:RegisterProtocalCallback(51706, "ScJoustsHallLeaveB")
	self:RegisterProtocalCallback(51711, "ScJoustsHallWaitInfo")
	self:RegisterProtocalCallback(51712, "ScJoustsHallBattleInfo")
	self:RegisterProtocalCallback(51713, "ScJoustsHallBossInfo")
	self:RegisterProtocalCallback(51715, "ScJoustsHallRank")
	self:RegisterProtocalCallback(51716, "ScJoustsHallStageChange")
	self:RegisterProtocalCallback(51718, "ScJoustsHallScore")
end

function GuildArenaCtrl:GetData()
	return self.data
end

function GuildArenaCtrl:OpenRestRoomView()

	if not self.guild_arena_restroom_view then
		self.guild_arena_restroom_view = require("game/guild_arena/guild_arena_restroom_view").New(self)
	end
	self.guild_arena_restroom_view:Open()
end

function GuildArenaCtrl:CloseRestRoomView()

	if self.guild_arena_restroom_view then
		self.guild_arena_restroom_view:Close()
	end
end

function GuildArenaCtrl:OpenFightViewFirst()

	if not self.guild_arena_fight_view_first then
		self.guild_arena_fight_view_first = require("game/guild_arena/guild_arena_fight_view_first").New(self)
	end
	self.guild_arena_fight_view_first:Open()
end

function GuildArenaCtrl:CloseFightViewFirst()

	if self.guild_arena_fight_view_first then
		self.guild_arena_fight_view_first:Close()
	end
end

function GuildArenaCtrl:OpenFightViewSecond()

	if not self.guild_arena_fight_view_second then
		self.guild_arena_fight_view_second = require("game/guild_arena/guild_arena_fight_view_second").New(self)
	end
	self.guild_arena_fight_view_second:Open()
end

function GuildArenaCtrl:CloseFightViewSecond()
	if self.guild_arena_fight_view_second then
		self.guild_arena_fight_view_second:Close()
	end
end

function GuildArenaCtrl:OpenScoreRankView()

	if not self.guild_arena_rank_view then
		self.guild_arena_rank_view = require("game/guild_arena/guild_arena_rank_view").New(self)
	end
	self.guild_arena_rank_view:Open()
end

--进入休息区
function GuildArenaCtrl:CsJoustsHallEnter()
	self:SendProtocal(51701,{})
end

function GuildArenaCtrl:ScJoustsHallEnter(data)
	-- body
end

--离开休息区
function GuildArenaCtrl:CsJoustsHallLeaveL()
	self:SendProtocal(51703,{})
end

function GuildArenaCtrl:ScJoustsHallLeaveL(data)
	-- body
end

--离开战斗场景
function GuildArenaCtrl:CsJoustsHallLeaveB()
	self:SendProtocal(51705,{})
end

function GuildArenaCtrl:ScJoustsHallLeaveB(data)
	-- body
end

--界面信息
function GuildArenaCtrl:CsJoustsHallInfo()
	self:SendProtocal(51710, {})
	-- print("-----------51710------")
end

--休息室信息
function GuildArenaCtrl:ScJoustsHallWaitInfo(data)
	-- print("-----------51711------") PrintTable(data)
	self.data:SetRestRoomData(data)
	self:FireEvent(game.GuildArenaEvent.UpdateViewInfo, data)
end

--前三轮战场信息
function GuildArenaCtrl:ScJoustsHallBattleInfo(data)
	-- print("-----------51712------") PrintTable(data)
	self.data:SetFirstFightData(data)
	self:FireEvent(game.GuildArenaEvent.UpdateViewInfo, data)
end

--第四轮战场信息
function GuildArenaCtrl:ScJoustsHallBossInfo(data)
	-- print("-----------51713------") PrintTable(data)
	self.data:SetSecondFightData(data)
	self:FireEvent(game.GuildArenaEvent.UpdateViewInfoSec, data)
end

--积分排名
function GuildArenaCtrl:CsJoustsHallRank()
	self:SendProtocal(51714, {})
end

function GuildArenaCtrl:ScJoustsHallRank(data)
	self:FireEvent(game.GuildArenaEvent.UpdateRankData, data)
end

--流程变化通知
function GuildArenaCtrl:ScJoustsHallStageChange(data)
	-- print("-----------51716------") PrintTable(data)
	self:FireEvent(game.GuildArenaEvent.UpdateStageChange, data)
end

function GuildArenaCtrl:CsJoustsHallScore()
	self:SendProtocal(51717, {})
end

function GuildArenaCtrl:ScJoustsHallScore(data)
	self:FireEvent(game.GuildArenaEvent.UpdateMyScore, data)
end

game.GuildArenaCtrl = GuildArenaCtrl

return GuildArenaCtrl