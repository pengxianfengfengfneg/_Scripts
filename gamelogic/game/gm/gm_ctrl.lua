local GmCtrl = Class(game.BaseCtrl)

function GmCtrl:_init()
    if GmCtrl.instance then
        error("GmCtrl init twice")
    end
    self.view = require("game/gm/gm_view").New(self)
    GmCtrl.instance = self

    require("config/config_gm")
end

function GmCtrl:_delete()

    GmCtrl.instance = nil
    self.view:DeleteMe()
end

function GmCtrl:SendGmRequest(str)
    local proto = {
        content = str
    }
    print("gm", str)
    self:SendProtocal(10601, proto)
end

function GmCtrl:OpenView()
    self.view:Open()
end

function GmCtrl:CloseView()
    self.view:Close()
end

game.GmCtrl = GmCtrl

return GmCtrl
