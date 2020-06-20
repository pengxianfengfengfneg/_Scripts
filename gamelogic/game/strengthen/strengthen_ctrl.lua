local StrengthenCtrl = Class(game.BaseCtrl)

function StrengthenCtrl:_init()
	if StrengthenCtrl.instance ~= nil then
		error("StrengthenCtrl Init Twice!")
	end
	StrengthenCtrl.instance = self
	
	self.data = require("game/strengthen/strengthen_data").New(self)
	self.view = require("game/strengthen/strengthen_view").New(self)
	self.fight_view = require("game/strengthen/strengthen_fight_view").New(self)
end

function StrengthenCtrl:_delete()
    self.data:DeleteMe()
	self.view:DeleteMe()
	self.fight_view:DeleteMe()
	StrengthenCtrl.instance = nil
end

function StrengthenCtrl:OpenView()
	self.view:Open()
end

function StrengthenCtrl:OpenFightView(type)
	self.fight_view:Open(type)
end

function StrengthenCtrl:GetTitleList(type)
    return self.data:GetTitleList(type)
end

function StrengthenCtrl:GetTagList(type)
    return self.data:GetTagList(type)
end

function StrengthenCtrl:GetFuncList(cate_id)
	return self.data:GetFuncList(cate_id)
end

function StrengthenCtrl:GetGrade(type, idx)
	return self.data:GetGrade(type, idx)
end

function StrengthenCtrl:GetTotalFight(type)
	return self.data:GetTotalFight(type)
end

function StrengthenCtrl:GetFuncFight(func_type)
	return self.data:GetFuncFight(func_type)
end

function StrengthenCtrl:GetCateInfo(func_id)
	return self.data:GetCateInfo(func_id)
end

function StrengthenCtrl:GetFuncChildList(func_id)
	return self.data:GetFuncChildList(func_id)
end

function StrengthenCtrl:GetCateList(tag_id)
	return self.data:GetCateList(tag_id)
end

function StrengthenCtrl:IsFinish(func_id, id)
	return self.data:IsFinish(func_id, id)
end

game.StrengthenCtrl = StrengthenCtrl

return StrengthenCtrl