local FoundryGodweaponHuanhuaItem = Class(game.UITemplate)

function FoundryGodweaponHuanhuaItem:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "huanhua_item_template"
    self.parent = parent
    self.foundry_data = game.FoundryCtrl.instance:GetData()
end

function FoundryGodweaponHuanhuaItem:OpenViewCallBack()

    self._layout_objs["n1"]:SetTouchDisabled(false)
    self._layout_objs["n1"]:AddClickCallBack(function()
        self.parent:SelectItem(self.index)
    end)
end

function FoundryGodweaponHuanhuaItem:CloseViewCallBack()
    if self.goods_item then
        self.goods_item:DeleteMe()
        self.goods_item = nil
    end
end

function FoundryGodweaponHuanhuaItem:RefreshItem(index)
    
    self.index = index
    
    local data_list = self.parent:GetDataList()
    local avatar_cfg = data_list[index]
    self.avatar_id = avatar_cfg.id

    local cur_avatar_id = self.foundry_data:GetAvatarId()

    self._layout_objs["name"]:SetText(avatar_cfg.name)

    self.have_flag = self.foundry_data:CheckHaveAvatar(self.avatar_id)
    if self.have_flag then
        self._layout_objs["n4"]:SetText(config.words[1256])
    else
        self._layout_objs["n4"]:SetText(config.words[1255])
    end

    if self.avatar_id == cur_avatar_id then
       self._layout_objs["wear_img"]:SetVisible(true) 
    else
       self._layout_objs["wear_img"]:SetVisible(false) 
    end

    if not self.goods_item then
        self.goods_item = require("game/bag/item/goods_item").New()
        self.goods_item:SetVirtual(self._layout_objs["n2"])
        self.goods_item:Open()
    end

    self.goods_item:SetItemInfo({ id = avatar_cfg.item_id, num = 1})

    local item_id = avatar_cfg.item_id
    --特殊加入（铸造装备）
    if index == 1 then
        local data = self.foundry_data:GetGodweaponData()
        local gw_id = data.id
        local career = math.floor(gw_id/100)
        local gw_cfg = config.artifact_base[career][gw_id]
        self._layout_objs["name"]:SetText(gw_cfg.name)
        self._layout_objs["n4"]:SetText(config.words[1256])
        item_id = item_id+ (gw_id%100) - 1
        self.goods_item:SetItemInfo({ id = item_id, num = 1})
    end
end

function FoundryGodweaponHuanhuaItem:SetSelect(val)
    self._layout_objs["n5"]:SetVisible(val)
end

function FoundryGodweaponHuanhuaItem:GetIdx()
    return self.index
end

return FoundryGodweaponHuanhuaItem