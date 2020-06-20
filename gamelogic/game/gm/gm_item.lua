local GmItem = Class(game.UITemplate)

function GmItem:_init(ctrl)
    self.ctrl = ctrl
end

function GmItem:OpenViewCallBack()
    self._layout_objs["n0"]:AddClickCallBack(function()
        local param1 = self._layout_objs["t1"]:GetText()
        local param2 = self._layout_objs["t2"]:GetText()
        if not self.cfg.func then
            self.ctrl:SendGmRequest(string.format(self.cfg.cheat, param1, param2))
        else
            self.cfg.func(param1, param2)
        end
    end)
end

function GmItem:Refresh(data)
    self.cfg = data
    self._layout_objs["name"]:SetText(data.desc)
    for i = 1, 2 do
        self._layout_objs["t" .. i]:SetVisible(data.param >= i)
        self._layout_objs["n" .. i]:SetVisible(data.param >= i)
    end
end

return GmItem
