local BattleInfoView = Class(game.BaseView)

function BattleInfoView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "battle_info_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
    self.data = ctrl:GetData()
end

function BattleInfoView:OpenViewCallBack()
    self:InitBg()

    local ui_list = game.UIList.New(self._layout_objs["list"])
    ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/main/battle_info_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    ui_list:SetRefreshItemFunc(function(item, idx)
        item:SetData(idx, self.battle_list[idx])
    end)
    ui_list:SetVirtual(true)
    self.ui_list = ui_list

    self:Refresh()

    self:BindEvent(game.SceneEvent.BattleInfoChange, function()
        self:Refresh()
    end)
    self:BindEvent(game.FriendEvent.RefreshEnemyList, function()
        self:Refresh()
    end)
end

function BattleInfoView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function BattleInfoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1679])
end

function BattleInfoView:Refresh()
    self.data:SortBattleInfo()
    self.battle_list = self.data:GetBattleInfo()
    self.ui_list:SetItemNum(#self.battle_list)
end

return BattleInfoView
