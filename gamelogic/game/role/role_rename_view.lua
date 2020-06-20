local RoleRenameView = Class(game.BaseView)

function RoleRenameView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_rename_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function RoleRenameView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function RoleRenameView:Init()
    self.label_desc = self._layout_objs["label_desc"]
    self.label_goods = self._layout_objs["label_goods"]

    self.txt_guild_name = self._layout_objs["txt_guild_name"]
    self.txt_goods = self._layout_objs["txt_goods"]
    self.txt_carry_nums = self._layout_objs["txt_carry_nums"]

    self.btn_rename = self._layout_objs["btn_rename"]
    self.btn_cancel = self._layout_objs["btn_cancel"]

    self.rename_item_id = config.sys_config.rename_item_id.value

end

function RoleRenameView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1685])

    self.label_desc:SetText(config.words[2321])
    self.label_goods:SetText(config.words[2322])
    self.btn_rename:SetText(config.words[2325])
    self.btn_cancel:SetText(config.words[2326])

    self:SetGoodsText(1)
    self:SetCarryNumsText()

    self.btn_rename:AddClickCallBack(function()
        local new_name = self.txt_guild_name:GetText()
        if game.Utils.CheckMaskWords(new_name) then
            game.GameMsgCtrl.instance:PushMsg(config.words[1005])
        else
            game.RoleCtrl.instance:SendRename(new_name)
            self:Close()
        end
    end)
    self.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)
end

function RoleRenameView:SetGuildNameText(guild_name)
    self.txt_guild_name:SetText(guild_name)
end

function RoleRenameView:SetGoodsText(need_nums)
    local goods_name = config.goods[self.rename_item_id].name
    self.txt_goods:SetText(string.format(config.words[2323], goods_name, need_nums))
end

function RoleRenameView:SetCarryNumsText()
    local carry_nums = game.BagCtrl.instance:GetNumById(self.rename_item_id)
    self.txt_carry_nums:SetText(string.format(config.words[2324], carry_nums))
end

function RoleRenameView:OnEmptyClick()
    self:Close()
end

return RoleRenameView
