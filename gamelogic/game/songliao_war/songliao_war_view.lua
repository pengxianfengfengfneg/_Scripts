local SongliaoWarView = Class(game.BaseView)

function SongliaoWarView:_init(ctrl)
	self._package_name = "ui_songliao_war"
    self._com_name = "songliao_war_view"
    self.ctrl = ctrl

    self._show_money = true
end

function SongliaoWarView:OpenViewCallBack()

	

	self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[4100])

	self._layout_objs["n15"]:AddClickCallBack(function()
        if game.IsZhuanJia then
            local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[5050])
            msg_box:SetOkBtn(function()
                self.ctrl:CsDynastyWarEnter()
                self:Close()
                msg_box:Close()
                msg_box:DeleteMe()
            end)
            msg_box:Open()
        else
    		self.ctrl:CsDynastyWarEnter()
            self:Close()
        end
    end)

    self:SetAward()
end

function SongliaoWarView:CloseViewCallBack()
	if self.top_ui_list then
		self.top_ui_list:DeleteMe()
		self.top_ui_list = nil
	end
end

function SongliaoWarView:SetAward()

	local drop_id = config.sys_config["dynasty_war_show_reward"].value
	local items = config.drop[drop_id].client_goods_list

	self.top_list = self._layout_objs["list"]
    self.top_ui_list = game.UIList.New(self.top_list)
    self.top_ui_list:SetVirtual(true)
    self.top_ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(obj)
        item:Open()
        item:SetShowTipsEnable(true)
        return item
    end)

    self.top_ui_list:SetRefreshItemFunc(function (item, idx)
    	local item_id = items[idx][1]
    	local item_num = items[idx][2]
        item:SetItemInfo({id = item_id, num = item_num})
    end)

    self.top_ui_list:SetItemNum(#items)
end

return SongliaoWarView