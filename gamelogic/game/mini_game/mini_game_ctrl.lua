local MiniGameCtrl = Class(game.BaseCtrl)

function MiniGameCtrl:_init()
    if MiniGameCtrl.instance ~= nil then
        error("MiniGameCtrl Init Twice!")
    end
    self.rotaty_view = require("game/mini_game/mini_rotaty_view").New(self)
    self.paint_view = require("game/mini_game/paint_view").New(self)

    MiniGameCtrl.instance = self
end

function MiniGameCtrl:_delete()
    self.rotaty_view:DeleteMe()
    self.paint_view:DeleteMe()
    MiniGameCtrl.instance = nil
end

function MiniGameCtrl:OpenRotatyView(task_id)
    self.rotaty_view:Open(task_id)
end

function MiniGameCtrl:OpenPaintView(task_id)
    self.paint_view:Open(task_id)
end

game.MiniGameCtrl = MiniGameCtrl

return MiniGameCtrl