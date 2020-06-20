local ImperialExamineCtrl = Class(game.BaseCtrl)

function ImperialExamineCtrl:_init()
	if ImperialExamineCtrl.instance ~= nil then
		error("ImperialExamineCtrl Init Twice!")
	end
	ImperialExamineCtrl.instance = self
	
    self.view = require("game/imperial_examine/imperial_examine_view").New(self)
    self.task_view = require("game/imperial_examine/imperial_examine_task_view").New(self)
end

function ImperialExamineCtrl:_delete()
    self.view:DeleteMe()

	ImperialExamineCtrl.instance = nil
end

function ImperialExamineCtrl:OpenView()
    self.view:Open()
end

function ImperialExamineCtrl:OpenTaskView()
	self.task_view:Open()
end

game.ImperialExamineCtrl = ImperialExamineCtrl

return ImperialExamineCtrl