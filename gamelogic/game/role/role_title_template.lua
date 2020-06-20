local RoleTitleTemplate = Class(game.UITemplate)

require("game/role/role_title_config")

function RoleTitleTemplate:_init(view)
    self.ctrl = game.RoleCtrl.instance
    self.data = self.ctrl.role_data
end

function RoleTitleTemplate:OpenViewCallBack(open_index)
    self:BindEvent(game.RoleEvent.TitleShowSettingChange, function(idx)
        if self.list_idx == idx then
            self:RefreshList(idx)
        end
    end)

    self:BindEvent(game.RoleEvent.RoleTitleChange, function(id)
        self:RefreshTitle(id)
    end)

    self._layout_objs["sel_btn"]:AddClickCallBack(function()
        self.ctrl:OpenTitleQualityView()
    end)

    self._layout_objs["attr_btn"]:AddClickCallBack(function()
        self.ctrl:OpenTitleAttrView()
    end)

    self._layout_objs["wear_btn"]:AddClickCallBack(function()
        if self.title_id then            
            self.ctrl:SendTitleWear(self.title_id)
        end
    end)

    self.ui_list = game.UIList.New(self._layout_objs["title_list"])
    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/role/role_title_item").New()
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:UpdateData(idx, self.title_list[idx])
    end)
    self.ui_list:AddClickItemCallback(function(item)
        self:RefreshTitle(item:GetID())
    end)
    self.ui_list:SetVirtual(true)

    self:InitRoleModel()
    self:RefreshPower()

    self.controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:RefreshList(idx + 1)
    end)

    self:RefreshTabList()

    local title_id = self.data:GetCurTitleID()
    local cfg = config.title[title_id]
    if cfg then
        self.controller:SetSelectedIndexEx(cfg.type - 1)
    else
        self.controller:SetSelectedIndexEx(0)
    end

    self.title_ctrl = self:GetRoot():GetController("c2")

    self:RefreshTitle(title_id)
end

function RoleTitleTemplate:CloseViewCallBack()
    self:ClearRoleModel()
end

function RoleTitleTemplate:RefreshList(idx)
    self.list_idx = idx
    self.title_list = self.title_list or self:GetTitleList(idx)
    self.ui_list:SetItemNum(#self.title_list)
    self.ui_list:RefreshVirtualList()
end

function RoleTitleTemplate:RefreshTitle(id)
    self.title_id = id

    self.ui_list:Foreach(function(item)
        item:SetSelTitleID(id)
    end)

    local cfg = id and config.title[id]
    local wear = cfg and cfg.wear

    if self.data:IsTitleValid(id) and self.data:GetCurTitleID() ~= id and wear == 1 then
        self._layout_objs["wear_btn"]:SetVisible(true)
    else
        self._layout_objs["wear_btn"]:SetVisible(false)
    end

    local title_idx = 1
    if cfg then
        local cfg = config.title[id]
        self._layout_objs["desc_txt"]:SetVisible(true)
        self._layout_objs["desc_txt"]:SetText(cfg.desc)

        local title = cfg.name_func and cfg.name_func() or cfg.name
        local quality = cfg.quality_func and cfg.quality_func() or cfg.quality

        self._layout_objs["title_txt"]:SetText(title)
        local clr = game.ItemColor2[quality]
        self._layout_objs["title_txt"]:SetColor(clr[1], clr[2], clr[3], clr[4])

        self._layout_objs["prefix_img"]:SetSprite("ui_title", cfg.source_id)
        self._layout_objs["prefix_img"]:SetFlipX(cfg.is_flip_x[1]==1)
        self._layout_objs["suffix_img"]:SetSprite("ui_title", cfg.source_id2)
        self._layout_objs["suffix_img"]:SetFlipX(cfg.is_flip_x[2]==1)

        self._layout_objs["prefix_img"]:SetVisible(cfg.source_id ~= "")
        self._layout_objs["suffix_img"]:SetVisible(cfg.source_id2 ~= "")

        local attr = cfg.attr
        for i=1,3 do
            if attr[i] then
                self._layout_objs["attr_txt" .. i]:SetVisible(true)
                self._layout_objs["attr_txt" .. i]:SetText(string.format("%s+%d", config_help.ConfigHelpAttr.GetAttrName(attr[i][1]), attr[i][2]))
            else
                self._layout_objs["attr_txt" .. i]:SetVisible(false)
            end
        end
    else
        self._layout_objs["desc_txt"]:SetVisible(false)
        for i=1,3 do
            self._layout_objs["attr_txt" .. i]:SetVisible(false)
        end
        title_idx = 2
    end
    self.title_ctrl:SetSelectedIndexEx(title_idx)

    local server_time = global.Time:GetServerTime()
    local expire_time = self.data:GetTitleExpire(id)
    if server_time > expire_time then
        self._layout_objs["time_txt"]:SetText()
    else
        self._layout_objs["time_txt"]:SetText(string.format(config.words[5587], game.Utils.SecToTimeCn(expire_time - server_time, game.TimeFormatCn.DayHourMin)))
    end
end

local show_model_type_list = {
    game.ModelType.Body, game.ModelType.Hair, game.ModelType.Weapon, game.ModelType.Weapon2    
}

function RoleTitleTemplate:InitRoleModel()
    local main_role = game.Scene.instance:GetMainRole()

    if main_role == nil then
        return
    end

    local model_list = {}
    for i,v in ipairs(show_model_type_list) do
        local id, anim = main_role:_GetModelID(v)
        if id ~= 0 then
            model_list[v] = id
        end
    end

    local anim = game.ObjAnimName.Idle

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)
    self.role_model:SetModelChangeCallBack(function(model_type)
        if model_type == game.ModelType.Hair then
            local color_hex = main_role:GetHair()
            self.role_model:UpdateHairColorHex(color_hex)
        end
    end)
    self.role_model:PlayAnim(anim, game.ModelType.Body + game.ModelType.Hair)
    self.role_model:SetCameraRotation(9.5,0,0)
    self.role_model:SetPosition(0,-1.8,3.5)
    self.role_model:SetRotation(0,180,0)
    self.role_model:SetScale(1.2)
end

function RoleTitleTemplate:ClearRoleModel()
    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
end

function RoleTitleTemplate:RefreshPower()
    local attr_map = {}
    for k,v in pairs(config.title) do
        if self.data:IsTitleValid(v.id) then
            for k1,v1 in ipairs(v.attr) do
                if not attr_map[v1[1]] then
                    attr_map[v1[1]] = 0
                end
                attr_map[v1[1]] = attr_map[v1[1]] + v1[2]
            end
        end
    end

    local power = config_help.ConfigHelpAttr.CalcCombatPower(attr_map)
    self._layout_objs["power_txt"]:SetText(power)
end

function RoleTitleTemplate:RefreshTabList()
    local list_tab = self._layout_objs["n10"]
    for i=0, 3 do
        list_tab:GetChildAt(i):AddClickCallBack(function()
            local title_list = self:GetTitleList(i+1)
            if i==0 or #title_list > 0 then
                self.title_list = title_list
                self.controller:SetSelectedIndexEx(i)
            else
                game.GameMsgCtrl.instance:PushMsg(config.words[1686])
            end
        end)
    end
end

function RoleTitleTemplate:GetTitleList(idx)
    local show_val = self.data:GetTitleShow(idx)
    local career = game.Scene.instance:GetMainRoleCareer()

    local title_list = {}
    local cfg = config.title
    for k,v in pairs(cfg) do
        if v.type == idx then
            local is_valid = self.data:IsTitleValid(v.id)
            if (v.job == 0 or v.job == career) 
                and (show_val & (1 << v.quality) > 0) 
                and (is_valid or ((show_val & (1 << 6) > 0) and v.time == 0 and v.lack_hide == 0)) then

                v.valid = is_valid and 1 or 0
                if v.name_func then
                    v.name = v.name_func()
                end
                if v.quality_func then
                    v.quality = v.quality_func()
                end
                table.insert(title_list, v)
            end
        end
    end

    table.sort(title_list, function(a, b)
        if a.valid ~= b.valid then
            return a.valid > b.valid
        else
            return a.id < b.id
        end
    end)

    return title_list
end

return RoleTitleTemplate
