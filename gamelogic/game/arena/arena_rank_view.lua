local ArenaRankView = Class(game.BaseView)

function ArenaRankView:_init(ctrl)
	self._package_name = "ui_arena"
    self._com_name = "arena_rank"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function ArenaRankView:OpenViewCallBack()
	self:GetBgTemplate("common_bg"):SetTitleName(config.words[2500])

	self:InitList()

	self.ctrl:ArenaRankReq()

	self:BindEvent(game.ArenaEvent.UpdateRankList, function(data)
        self:OnUpdateList()
    end)

    local arena_data = self.ctrl:GetData()
    local my_rank = arena_data:GetMyRank()
    self._layout_objs["n16"]:SetText(tostring(my_rank))

end

function ArenaRankView:CloseViewCallBack()

end

function ArenaRankView:InitList()

	local arena_data = self.ctrl:GetData()
	local rank_list = arena_data:GetRankList()

	self.list = self._layout_objs["n12"]
	self.ui_list = game.UIList.New(self.list)
	self.ui_list:SetVirtual(true)

	self.ui_list:SetCreateItemFunc(function(obj)
		local item = require("game/arena/arena_rank_template").New(1)
        item:SetVirtual(obj)
        item:Open()
        return item
	end)

	self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_arena:arena_rank_item"
    end)

    self:OnUpdateList()
end

function ArenaRankView:OnUpdateList()
    local arena_data = self.ctrl:GetData()
	local rank_list = arena_data:GetRankList()

    self.ui_list:SetItemNum(#rank_list)
end

return ArenaRankView