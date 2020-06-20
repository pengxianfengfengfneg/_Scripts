local AngerBossView = Class(game.BaseView)

function AngerBossView:_init(ctrl)
	self._package_name = "ui_anger_boss"
    self._com_name = "anger_boss_view"

    self._view_level = game.UIViewLevel.Standalone
    self._mask_type = game.UIMaskType.None

	self.ctrl = ctrl
end

function AngerBossView:OnPreOpen(anger_boss_id)
    self.boss_asset_name = anger_boss_id
    self.boss_bundle_name = string.format("anger_boss_%s", anger_boss_id)
    self.boss_bundle_path = string.format("anger_boss/%s", self.boss_bundle_name)
    self:AddPackage(self.boss_bundle_path)
end

function AngerBossView:OpenViewCallBack(anger_boss_id)
    self.img_icon = self._layout_objs["img_icon"]
	self.img_icon:SetSprite(self.boss_bundle_name, self.boss_asset_name)

    self.txt_name = self._layout_objs["txt_name"]
    self.txt_name:SetText(string.format(config.words[1450], config.words[1430+anger_boss_id]))

    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)

    self:PlayTransition("t0", function()
        self:Close()
    end)
end

function AngerBossView:CloseViewCallBack()
    self:GetRoot():StopAllTransition()
end

return AngerBossView