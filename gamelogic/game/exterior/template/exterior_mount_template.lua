local ExteriorMountTemplate = Class(game.UITemplate)

local EffectType = {
    Scene = 1,
    ShowIdle = 2,
}

function ExteriorMountTemplate:_init()
    self.ctrl = game.ExteriorCtrl.instance   
end

function ExteriorMountTemplate:OpenViewCallBack()
    self:Init()
    self:InitMountList()
    self:InitModel()
    self:RegisterAllEvents()
    self.ctrl:SendExteriorMountInfo()
end

function ExteriorMountTemplate:CloseViewCallBack()
    self.select_mount = nil
    self:ClearEffect()
    self:ClearModel()
end

function ExteriorMountTemplate:RegisterAllEvents()
    local events = {
        {game.ExteriorEvent.OnExteriorMountInfo, handler(self, self.UpdateMountList)},
        {game.ExteriorEvent.OnMountSettingChange, handler(self, self.UpdateMountList)},
        {game.RoleEvent.RefreshMount, handler(self, self.OnRefreshMount)},
        {game.ExteriorEvent.OnExteriorMountChoose, handler(self, self.OnExteriorMountChoose)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ExteriorMountTemplate:Init()
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_desc = self._layout_objs["txt_desc"]
    self.txt_fight = self._layout_objs["txt_fight"]
    self.txt_speed = self._layout_objs["txt_speed"]
    self.txt_require = self._layout_objs["txt_require"]

    self.txt_require2 = self._layout_objs["txt_require2"]
    self.txt_require2:AddClickCallBack(handler(self, self.OnRequireClick))

    self.btn_operate = self._layout_objs["btn_operate"]
    self.btn_operate:SetText(config.words[5502])
    self.btn_operate:AddClickCallBack(handler(self, self.OnOperateClick))

    self.btn_setting = self._layout_objs["btn_setting"]
    self.btn_setting:SetText(config.words[5503])
    self.btn_setting:AddClickCallBack(function()
        self.ctrl:OpenMountSettingView()
    end)

    self._layout_objs.txt_require_label:SetText(config.words[5504])

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role)

    self.ctrl_mount = self:GetRoot():GetController("ctrl_mount")
end

function ExteriorMountTemplate:InitModel()
    self.model_list = {
        [game.ModelType.Body]    = 0,
        [game.ModelType.Wing]    = 0,
        [game.ModelType.Hair]    = 0,
        [game.ModelType.Weapon]  = 0,
        [game.ModelType.Mount]   = 0,
    }

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    for k,v in pairs(self.model_list) do
        local id = main_role:GetModelID(k)
        self.model_list[k] = id
    end
end

function ExteriorMountTemplate:UpdateModel(id)
    self:ClearModel()
    self:ClearEffect()

    local is_ride = true
    local mount_cfg = config.exterior_mount[id]
    local df_model_attr = {0,-1.5,5,110}

    if mount_cfg.is_wing == 0 then
        self.model_list[game.ModelType.Mount] = mount_cfg.model_id
        self.model_list[game.ModelType.Wing] = 0
    else
        self.model_list[game.ModelType.Mount] = 0
        self.model_list[game.ModelType.Wing] = mount_cfg.model_id
        df_model_attr = {0,-1.2,4, 180}
    end

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, self.model_list)

    local model_pos = nil
    local model_rorate_y = nil

    local show_attr = mount_cfg.show_attr
    if #show_attr > 0 then
        model_pos = {show_attr[1], show_attr[2], show_attr[3]}
        model_rorate_y = show_attr[4]
    else
        model_pos = df_model_attr
        model_rorate_y = df_model_attr[4]
    end

    self.role_model:SetPosition(model_pos[1], model_pos[2], model_pos[3])
    self.role_model:SetRotation(0,model_rorate_y,0)

    for k, v in pairs(self.model_list) do
        self.role_model:SetModelVisible(k, k == game.ModelType.Mount or is_ride)
    end
    self.role_model:PlayAnim(config_help.ConfigHelpModel.GetMountIdleAnimName(mount_cfg.ani), game.ModelType.Body + game.ModelType.Wing + game.ModelType.Hair + game.ModelType.Mount + game.ModelType.Weapon)

    self.role_model:SetModelChangeCallBack(function()
	    self.tween_idle_effect = DOTween.Sequence()
	    self.tween_idle_effect:AppendCallback(function()
            local effect_cfg = config.mount_effect[id]
            local idle_effect = effect_cfg and effect_cfg[EffectType.ShowIdle]
            local model_type = (mount_cfg.is_wing == 0) and game.ModelType.Mount or game.ModelType.Wing
            for k, v in ipairs(idle_effect or game.EmptyTable) do
                local effect = string.format("%s", v.effect)
		    	self.role_model:SetEffect(v.hang_node, effect, model_type, true)
		    end
        end)
        self.tween_idle_effect:SetAutoKill(true)
    end)    
end

function ExteriorMountTemplate:ClearModel()
    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
end

function ExteriorMountTemplate:InitMountList()
    self.list_mount = self:CreateList("list_mount", "game/exterior/item/mount_item")
    self.list_mount:SetRefreshItemFunc(function(item, idx)
        local item_info = self.mount_list_data[idx]
        local main_role = game.Scene.instance:GetMainRole()
        if not main_role then
            return
        end
        local mount_id = main_role:GetExteriorID(game.ExteriorType.Mount)
        item:SetItemInfo(item_info)
        item:SetClickFunc(function()
            self:OnItemClick(item_info)
            self.ctrl_mount:SetSelectedIndex(idx-1)
        end)
        item:SetEquipState(mount_id == item_info.id)
    end)
end

function ExteriorMountTemplate:UpdateMountList()
    self.mount_list_data = self.ctrl:GetMountSortList()

    local item_num = #self.mount_list_data
    self.list_mount:SetItemNum(item_num)
    self.ctrl_mount:SetPageCount(item_num)

    self:OnItemClick(self.mount_list_data[1])
    if item_num > 0 then
        self._layout_objs["list_mount"]:GetChildAt(0):SetSelected(true)
        self.ctrl_mount:SetSelectedIndex(0)
    end
end

function ExteriorMountTemplate:SetOperateBtnText()
    local mount_data = self.select_mount

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local mount_id = main_role:GetExteriorID(game.ExteriorType.Mount)
    local mount_state = main_role:GetMountState()

    local str = ""
    if not mount_data or mount_id ~= mount_data.id then
        str = config.words[5505]
    elseif mount_state == 0 then
        str = config.words[5502]
    elseif mount_state == 1 then
        str = config.words[5506]
    end
    self.btn_operate:SetText(str)
end

function ExteriorMountTemplate:OnItemClick(item_info)
    self.select_mount = item_info
    local mount_data = item_info

    self:SetOperateBtnText()

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local mount_id = main_role:GetExteriorID(game.ExteriorType.Mount)
    local mount_state = main_role:GetMountState()

    if mount_data then
        local mount_config = config.exterior_mount[mount_data.id]
        self.txt_name:SetText(mount_config.name)
        self.txt_desc:SetText(mount_config.desc)
        self.txt_speed:SetText(string.format(config.words[5511], mount_config.speed_add))
        self:SetRequireText(mount_config.require, mount_config.jump_way)
        self:UpdateModel(mount_data.id)
    else
        self.txt_name:SetText("")
        self.txt_desc:SetText("")
        self.txt_speed:SetText(string.format(config.words[5511], 0))
        self:SetRequireText("")
        self:ClearModel()
    end
end

function ExteriorMountTemplate:OnOperateClick()
    local mount_data = self.select_mount

    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end
    
    local mount_id = main_role:GetExteriorID(game.ExteriorType.Mount)
    local mount_state = main_role:GetMountState()

    if not mount_data then
        game.GameMsgCtrl.instance:PushMsg(config.words[5507])
        return
    -- 坐骑未激活
    elseif not mount_data.expire_time then
        game.GameMsgCtrl.instance:PushMsg(config.words[5508])
        return
    -- 坐骑超时
    elseif mount_data.expire_time ~= 0 and global.Time:GetServerTime() > mount_data.expire_time then
        self:UpdateMountList()
        game.GameMsgCtrl.instance:PushMsg(config.words[5519])
        return
    -- 装备坐骑
    elseif mount_data.id ~= mount_id then
        self.ctrl:SendExteriorMountChoose(mount_data.id)
        return
    -- 上马
    elseif mount_state == 0 then
        if game.Scene.instance:GetMainRole():CanRideMount(1, true) then
            mount_state = 1
        else
            return
        end
    -- 下马
    elseif mount_state == 1 then
        if game.Scene.instance:GetMainRole():CanRideMount(0, true) then
            mount_state = 0
        else
            return
        end
    end

    self.ctrl:SendExteriorMountOpe()
end

function ExteriorMountTemplate:OnRefreshMount(model_id)
    self:SetOperateBtnText()
end

function ExteriorMountTemplate:OnExteriorMountChoose(id)
    self.list_mount:Foreach(function(item)
        item:SetEquipState(id == item:GetItemInfo().id)
    end)
    self:SetOperateBtnText()
end

function ExteriorMountTemplate:ClearEffect()
    if self.tween_idle_effect then
        self.tween_idle_effect:Kill(false)
        self.tween_idle_effect = nil
    end
end

function ExteriorMountTemplate:OnRequireClick()
    local mount_info = self.select_mount
    if not mount_info then
        return
    end
    local mount_cfg = config.exterior_mount[mount_info.id]
    if mount_cfg.jump_way == 1 then
        game.ShopCtrl.instance:OpenViewByShopId(2, mount_cfg.buy_item_id)
    end
end

function ExteriorMountTemplate:SetRequireText(require, jump_way)
    self.txt_require:SetText(require)
    self.txt_require:SetVisible(jump_way~=1)
    self.txt_require2:SetText(require)
    self.txt_require2:SetVisible(jump_way==1)
end

return ExteriorMountTemplate