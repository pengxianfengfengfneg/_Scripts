local RankSubView = Class(game.BaseView)

function RankSubView:_init(ctrl)
	self._package_name = "ui_rank"
    self._com_name = "sub_rank_view"
    self.ctrl = ctrl
    self._show_money = true
    self._view_level = game.UIViewLevel.Second
    self.rank_data = self.ctrl:GetRankData()
end

function RankSubView:OpenViewCallBack(main_type, rank_id)
	self.main_type = main_type
	self.rank_id = rank_id

	self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
		self.select_page = idx

        local index = self.select_page-1
        if index < 0 then
            index = 0
        end

        self._layout_objs["list_tab"]:ScrollToView(index, true, true)
    end)

	self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1413])

	self._layout_objs["list_page"]:AddScrollEndCallback(function()

        local index = self.select_page-1
        if index < 0 then
            index = 0
        end

		self._layout_objs["list_tab"]:ScrollToView(index, true, true)
	end)

    self:InitPages()

	self:InitTabs()

    local time = 1
    self.timer = global.TimerMgr:CreateTimer(0.5,
        function()
            time = time - 1
            if time <= 0 then
                self:OpenScrollToTarget()
                self:DelTimer()
            end
        end)
end

function RankSubView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function RankSubView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end

    if self.ui_page_list then
        self.ui_page_list:DeleteMe()
        self.ui_page_list = nil
    end

    self:DelTimer()
end

function RankSubView:InitTabs()

	local rank_id_list = self.rank_data:GetSubTypeList(self.main_type)
	local num = #rank_id_list

	self.list = self._layout_objs["list_tab"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(false)

    self.ui_list:SetCreateItemFunc(function(obj, idx)
    	local rank_id = rank_id_list[idx+1]
    	local rank_cfg = config.rank_ex[rank_id]
    	obj:GetChild("title"):SetText(rank_cfg.name)
    	return obj
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
    end)

    self.ui_list:SetItemNum(num)
end

function RankSubView:InitPages()

	local rank_id_list = self.rank_data:GetSubTypeList(self.main_type)
	local num = #rank_id_list

	self.page_list = self._layout_objs["list_page"]
    self.ui_page_list = game.UIList.New(self.page_list)
    self.ui_page_list:SetVirtual(false)

    self.ui_page_list:SetCreateItemFunc(function(obj, idx)
    	
    	local rank_id = rank_id_list[idx+1]

    	local item = require("game/rank/rank_page_template").New(self)
    	item:SetRankId(rank_id)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_page_list:SetRefreshItemFunc(function (item, idx)

    end)

    self.ui_page_list:SetItemNum(num)
end

function RankSubView:OpenScrollToTarget()

    local rank_id_list = self.rank_data:GetSubTypeList(self.main_type)
    local index = 0

    for k, rank_id in pairs(rank_id_list) do

        if rank_id == self.rank_id then
            index = k - 1
            break
        end
    end

    self.select_page = index
    self.tab_controller:SetSelectedIndexEx(index)
end

return RankSubView