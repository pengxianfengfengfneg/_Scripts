local DailyTaskChessTipsView = Class(game.BaseView)

function DailyTaskChessTipsView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "daily_task_chess_tips_view"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function DailyTaskChessTipsView:_delete()
    
end

function DailyTaskChessTipsView:OpenViewCallBack(index)
    self.index = index
    self:Init()
    self:RegisterAllEvents()
end

function DailyTaskChessTipsView:CloseViewCallBack()
end

function DailyTaskChessTipsView:Init()
    self.tips_config = {
        [1] = {
            content = string.format(config.words[1924], self.ctrl:GetChessOneKeyGoldMoney()),
            click_func = function()
                self.ctrl:SendChessOneKeyFinish()
            end,
            events = {
                [game.DailyTaskEvent.UpdateChessState] = function(state)
                    if state ~= 0 then
                        self:Close()
                    end
                end,
            }
        },
        [2] = {
            content = string.format(config.words[1916], config.sys_config["chess_refresh_star_gold"].value),
            click_func = function()
                self.ctrl:SendChessRefresh()
            end,
            events = {
                [game.DailyTaskEvent.UpdateChessStar] = function(star)
                    if star == 7 then
                        self:Close()
                    end
                end
            }
        },
    }

    self:SetContentText()
    self._layout_objs["btn_concern"]:AddClickCallBack(function()
        self:OnConcernClick()
    end)
    self._layout_objs["btn_cancel"]:AddClickCallBack(function()
        self:Close()
    end)
end

function DailyTaskChessTipsView:RegisterAllEvents()
    local events = self.tips_config[self.index].events
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function DailyTaskChessTipsView:SetContentText()
    self._layout_objs["txt_content"]:SetText(self.tips_config[self.index].content)
end

function DailyTaskChessTipsView:OnEmptyClick()
    self:Close()
end

function DailyTaskChessTipsView:OnConcernClick()
    self.tips_config[self.index].click_func()
end

return DailyTaskChessTipsView
