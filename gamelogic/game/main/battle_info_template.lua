local BattleInfoTemplate = Class(game.UITemplate)

function BattleInfoTemplate:_init(parent_view)
    self.parent_view = parent_view
end

function BattleInfoTemplate:OpenViewCallBack()
    self._layout_objs["add_btn"]:AddClickCallBack(function()
        if self.data then
            game.FriendCtrl.instance:CsFriendSysAddEnemy(self.data.winner_id)
        end
    end)
    self._layout_objs["ignore_btn"]:AddClickCallBack(function()
        if self.data then
            game.MainUICtrl.instance:SendBattleLogDelete(self.data.id)
        end
    end)
end

function BattleInfoTemplate:CloseViewCallBack()

end

function BattleInfoTemplate:SetData(idx, data)
    self.data = data
    self.data_idx = idx
    self._layout_objs["bg1"]:SetVisible(idx % 2 == 1)
    self._layout_objs["bg2"]:SetVisible(idx % 2 == 0)

    local cfg = config.scene[data.scene]
    self._layout_objs["time_txt"]:SetText(game.Utils.SecToTimeEn(data.time, game.TimeFormatEn.HourMinSec))
    self._layout_objs["info_txt"]:SetText(string.format(config.words[519], cfg.name, data.winner_name))
    self._layout_objs["add_btn"]:SetVisible(not game.FriendCtrl.instance:IsMyEnemy(self.data.winner_id))
end

return BattleInfoTemplate

