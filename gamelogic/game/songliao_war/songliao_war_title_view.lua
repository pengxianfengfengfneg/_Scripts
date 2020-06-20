local SongliaoWarTitleView = Class(game.BaseView)

function SongliaoWarTitleView:_init(ctrl)
	self._package_name = "ui_songliao_war"
    self._com_name = "songliao_title_view"
    self.ctrl = ctrl
    self.songliao_data = self.ctrl:GetData()
end

function SongliaoWarTitleView:OpenViewCallBack()
	self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[4116])

    self:InitView()

    self:BindEvent(game.SongliaoWarEvent.UpdateTile, function(data)
        self:UpdateView()
    end)
end

function SongliaoWarTitleView:CloseViewCallBack()

end

function SongliaoWarTitleView:InitView()

    local win_times = self.songliao_data:GetWinTimes()
    local sl_score = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.SongLiao)
    local str1 = sl_score

    for i = 1, 8 do
        local cfg = config.songliao_war_title[i]
        local item_id = cfg.item
        local name = config.goods[item_id].name
        
        local str2 = game.Utils.NumberFormat(cfg.score)

        self._layout_objs["title"..i.."/title_name"]:SetText(name)

        self._layout_objs["title"..i.."/n5"]:SetText(tostring(str1).."/"..tostring(str2))

        self._layout_objs["title"..i.."/times"]:SetText(tostring(win_times).."/"..tostring(cfg.win_times)..config.words[1520])

        if sl_score >= cfg.score then
            self._layout_objs["title"..i.."/n5"]:SetColor(54, 122, 33, 255)
        else
            self._layout_objs["title"..i.."/n5"]:SetColor(255, 0, 0, 255)
        end

        if win_times >= cfg.win_times then
            self._layout_objs["title"..i.."/times"]:SetColor(54, 122, 33, 255)
        else
            self._layout_objs["title"..i.."/times"]:SetColor(255, 0, 0, 255)
        end

        local is_get = self.songliao_data:CheckTitleGet(i)
        if is_get then
            self._layout_objs["title"..i.."/get_btn"]:SetVisible(false)
            self._layout_objs["title"..i.."/n9"]:SetVisible(true)
        else
            self._layout_objs["title"..i.."/get_btn"]:SetVisible(true)
            self._layout_objs["title"..i.."/n9"]:SetVisible(false)
        end

        self._layout_objs["title"..i.."/get_btn"]:AddClickCallBack(function()
            self:OnClickBtn(i)
        end)
    end
end

function SongliaoWarTitleView:OnClickBtn(index)
    self.ctrl:CsDynastyExchange(index)
end

function SongliaoWarTitleView:UpdateView()

    local sl_score = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.SongLiao)
    local win_times = self.songliao_data:GetWinTimes()
	local str1 = sl_score

    for i = 1, 8 do

        local cfg = config.songliao_war_title[i]

        local str2 = game.Utils.NumberFormat(cfg.score)
        self._layout_objs["title"..i.."/n5"]:SetText(tostring(str1).."/"..tostring(str2))

        self._layout_objs["title"..i.."/times"]:SetText(tostring(win_times).."/"..tostring(cfg.win_times)..config.words[1520])

        if sl_score >= cfg.score then
            self._layout_objs["title"..i.."/n5"]:SetColor(54, 122, 33, 255)
        else
            self._layout_objs["title"..i.."/n5"]:SetColor(255, 0, 0, 255)
        end

        if win_times >= cfg.win_times then
            self._layout_objs["title"..i.."/times"]:SetColor(54, 122, 33, 255)
        else
            self._layout_objs["title"..i.."/times"]:SetColor(255, 0, 0, 255)
        end

        local is_get = self.songliao_data:CheckTitleGet(i)
        if is_get then
            self._layout_objs["title"..i.."/get_btn"]:SetVisible(false)
            self._layout_objs["title"..i.."/n9"]:SetVisible(true)
        else
            self._layout_objs["title"..i.."/get_btn"]:SetVisible(true)
            self._layout_objs["title"..i.."/n9"]:SetVisible(false)
        end
    end
end

return SongliaoWarTitleView