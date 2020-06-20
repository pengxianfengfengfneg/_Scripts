local ChurchView = Class(game.BaseView)

function ChurchView:_init(ctrl)
    self._package_name = "ui_marry"
    self._com_name = "church_view"

    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function ChurchView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2622])

    self:InitList()

    self._layout_objs.btn:AddClickCallBack(function()
        if self.select_item then
        	self.select_item:DoEnter()
        	self:Close()
        end
    end)
end

function ChurchView:CloseViewCallBack()
	if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function ChurchView:InitList()

	self.hall_list = game.MarryProcessCtrl.instance:GetMarryHallList()

	self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/marry/item/church_item").New(self)
        item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddClickItemCallback(function(item)
    	self.select_item = item
    	self.ui_list:Foreach(function(v)
            if v.idx ~= item.idx then
                v:SetSelect(false)
            else
                v:SetSelect(true)
            end
        end)
    end)

    self.ui_list:SetItemNum(#self.hall_list)
end

function ChurchView:GetListData()
	return self.hall_list
end

return ChurchView
