local SongliaoWarCtrl = Class(game.BaseCtrl)

function SongliaoWarCtrl:_init()
	if SongliaoWarCtrl.instance ~= nil then
		error("SongliaoWarCtrl Init Twice!")
	end
	SongliaoWarCtrl.instance = self
	
	self.songliao_war_data = require("game/songliao_war/songliao_war_data").New()
	self.songliao_war_title_view = require("game/songliao_war/songliao_war_title_view").New(self)

	self:RegisterAllProtocal()
	self:RegisterAllEvents()
end

function SongliaoWarCtrl:_delete()
	self.songliao_war_data:DeleteMe()
	self.songliao_war_data = nil

	if self.songliao_war_view then
		self.songliao_war_view:DeleteMe()
		self.songliao_war_view = nil
	end

	if self.songliao_war_fight_view then
		self.songliao_war_fight_view:DeleteMe()
		self.songliao_war_fight_view = nil
	end

	if self.songliao_war_result_view then
		self.songliao_war_result_view:DeleteMe()
		self.songliao_war_result_view = nil
	end

	if self.songliao_war_prepare_view then
		self.songliao_war_prepare_view:DeleteMe()
		self.songliao_war_prepare_view = nil
	end

	if self.songliao_war_rank_view then
		self.songliao_war_rank_view:DeleteMe()
		self.songliao_war_rank_view = nil
	end

	if self.songliao_war_title_view then
		self.songliao_war_title_view:DeleteMe()
		self.songliao_war_title_view = nil
	end

	SongliaoWarCtrl.instance = nil
end

function SongliaoWarCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(30702, "ScDynastyWarEnter")
	self:RegisterProtocalCallback(30704, "ScDynastyWarLeave")
	self:RegisterProtocalCallback(30705, "ScDynastySceneInfo")
	self:RegisterProtocalCallback(30706, "ScDynastyMatch")
	self:RegisterProtocalCallback(30711, "ScDynastyWarStage")
	self:RegisterProtocalCallback(30712, "ScDynastyScore")
	self:RegisterProtocalCallback(30713, "ScDynastyWarRank")
	self:RegisterProtocalCallback(30714, "ScDynastyWarSettleUp")
	self:RegisterProtocalCallback(30715, "ScDynastyRoleScore")
	self:RegisterProtocalCallback(30722, "ScDynastyInfo")
	self:RegisterProtocalCallback(30724, "ScDynastyExchange")
end

function SongliaoWarCtrl:RegisterAllEvents()
    local events = {
        {game.SceneEvent.ChangeScene, handler(self, self.ChangeScene)}
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SongliaoWarCtrl:CsDynastyWarEnter()
	self:SendProtocal(30701,{})
end

function SongliaoWarCtrl:ScDynastyWarEnter(data)
end

function SongliaoWarCtrl:CsDynastyWarLeave()
	self:SendProtocal(30703,{})
end

function SongliaoWarCtrl:ScDynastyWarLeave(data)

end

function SongliaoWarCtrl:ScDynastyWarStage(data)
	self:FireEvent(game.SongliaoWarEvent.UpdateStage, data)
end

function SongliaoWarCtrl:ScDynastyScore(data)
	self:FireEvent(game.SongliaoWarEvent.UpdateScore, data)
end

function SongliaoWarCtrl:ScDynastySceneInfo(data)
	self.songliao_war_data:SetPrepareRoleNum(data)

	self:FireEvent(game.SongliaoWarEvent.UpdateRoleNum, data)
end

function SongliaoWarCtrl:ScDynastyMatch()

end

function SongliaoWarCtrl:ScDynastyWarRank(data)
	self.songliao_war_data:SetRankData(data)
end

function SongliaoWarCtrl:ScDynastyWarSettleUp(data)
	self.songliao_war_data:SetResultData(data)
	self:OpenResultView()
end

function SongliaoWarCtrl:OpenView()

	if not self.songliao_war_view then
		self.songliao_war_view = require("game/songliao_war/songliao_war_view").New(self)
	end
	self.songliao_war_view:Open()
end

function SongliaoWarCtrl:OpenFightView()

	if not self.songliao_war_fight_view then
		self.songliao_war_fight_view = require("game/songliao_war/songliao_war_fight_view").New(self)
	end
	self.songliao_war_fight_view:Open()
end

function SongliaoWarCtrl:CloseFightView()

	if self.songliao_war_fight_view then
		self.songliao_war_fight_view:Close()
	end
end

function SongliaoWarCtrl:OpenResultView()

	if not self.songliao_war_result_view then
		self.songliao_war_result_view = require("game/songliao_war/songliao_war_result_view").New(self)
	end
	self.songliao_war_result_view:Open()
end

function SongliaoWarCtrl:OpenPrepareView()

	if not self.songliao_war_prepare_view then
		self.songliao_war_prepare_view = require("game/songliao_war/songliao_war_prepare_view").New(self)
	end
	self.songliao_war_prepare_view:Open()
end

function SongliaoWarCtrl:ClosePrepareView()
	if self.songliao_war_prepare_view then
		self.songliao_war_prepare_view:Close()
	end
end

function SongliaoWarCtrl:GetData()
	return self.songliao_war_data
end

function SongliaoWarCtrl:OpenRankView()

	if not self.songliao_war_rank_view then
		self.songliao_war_rank_view = require("game/songliao_war/songliao_war_rank_view").New(self)
	end
	self.songliao_war_rank_view:Open()
end

local IsSongliaoPrepareScene = function (scene_id)
    local is = false

    for k, v in pairs(config.sys_config["dynasty_war_prepare_scene"].value) do
        if v == scene_id then
            is = true
            break
        end
    end

    return  is
end

function SongliaoWarCtrl:ChangeScene(to_scene_id, from_scene_id)

	if IsSongliaoPrepareScene(to_scene_id) then
		self:OpenPrepareView()
	elseif to_scene_id == config.sys_config["dynasty_war_battle_scene"].value then
		self:OpenFightView()
	end

	if not IsSongliaoPrepareScene(to_scene_id) then
		self:ClosePrepareView()
	end

	if to_scene_id ~= config.sys_config["dynasty_war_battle_scene"].value then
		self:CloseFightView()
	end
end

function SongliaoWarCtrl:ScDynastyRoleScore(data)
	if not self.last_score then
		self.last_score = 0
	end

	local offset_score = data.score - self.last_score
	self.last_score = data.score
	local str = string.format(config.words[4233], offset_score, offset_score)
	game.GameMsgCtrl.instance:PushMsg(str)
end

function SongliaoWarCtrl:CsDynastyInfo()
	self:SendProtocal(30721,{})
end

function SongliaoWarCtrl:ScDynastyInfo(data)
	self.songliao_war_data:SetTitleData(data)
end

function SongliaoWarCtrl:CsDynastyExchange(title_id)
	self:SendProtocal(30723,{id=title_id})
end

function SongliaoWarCtrl:ScDynastyExchange(data)
	self.songliao_war_data:UpdateTitleData(data.id)
	self:FireEvent(game.SongliaoWarEvent.UpdateTile)
end

function SongliaoWarCtrl:OpenTitleView()
	if not self.songliao_war_title_view:IsOpen() then
		self.songliao_war_title_view:Open()
	end
end

game.SongliaoWarCtrl = SongliaoWarCtrl

return SongliaoWarCtrl