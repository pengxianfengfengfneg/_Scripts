local RoleAttrView = Class(game.BaseView)

local handler = handler

function RoleAttrView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_attr_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function RoleAttrView:OpenViewCallBack()
    self:InitInfos()
    self:InitBtns()

    self:RegisterAllEvents()
end

function RoleAttrView:CloseViewCallBack()
    
end

function RoleAttrView:RegisterAllEvents()
    local events = {
        {game.RoleEvent.UpdateRoleAttr, handler(self, self.OnUpdateRoleAttr)}
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function RoleAttrView:InitInfos()
    local list_attr = self._layout_objs["list_attr"]

    local txt_name = self._layout_objs["txt_name"]

    local attr_help = config_help.ConfigHelpAttr
    local attr_sort_list = attr_help.GetAttrSortList()

    local attr_info = self.ctrl:GetRoleAttrInfo() or {}
    local attr = attr_info.attr or {}

    local idx = 0
    local child_idx = 0
    local item_num = math.ceil(#attr_sort_list*0.5)
    list_attr:SetItemNum(item_num)

    self.list_attr_tb = {}
    for i=1,item_num do
        idx = idx + 1
        local v = attr_sort_list[idx]

        local child = list_attr:GetChildAt(child_idx)

        child:GetChild("img_bg"):SetVisible(i%2==1)
        
        local val = attr[v.sign]
        if val then            
            child:GetChild("txt_name"):SetText(v.word .. "：" )
            local txt_attr = child:GetChild("txt_attr")
            txt_attr:SetText(val)

            table.insert(self.list_attr_tb, txt_attr)

            child_idx = child_idx + 1
        end

        idx = idx + 1

        local word = ""
        local val = ""
        local cv = attr_sort_list[idx]
        if cv then
            val = attr[cv.sign]
            if val then
                word = cv.word .. "：" 
            end
            
        end
        child:GetChild("txt_name2"):SetText(word)
        local txt_attr = child:GetChild("txt_attr2")
        txt_attr:SetText(val or "")
        table.insert(self.list_attr_tb, txt_attr)
    end
end

function RoleAttrView:InitBtns()
    local btn_close = self._layout_objs["btn_close"]
    btn_close:AddClickCallBack(function()
        self.ctrl:CloseRoleAttrView()
    end)

    local btn_back = self._layout_objs["btn_back"]
    btn_back:AddClickCallBack(function()
        self.ctrl:CloseRoleAttrView()
    end)
end

function RoleAttrView:OnEmptyClick()
    self.ctrl:CloseRoleAttrView()
end

function RoleAttrView:OnUpdateRoleAttr()
    local attr_info = self.ctrl:GetRoleAttrInfo() or game.EmptyTable
    local attr = attr_info.attr or game.EmptyTable

    local attr_help = config_help.ConfigHelpAttr
    local attr_sort_list = attr_help.GetAttrSortList()

    for k,v in ipairs(attr_sort_list or game.EmptyTable) do
        local txt_attr = self.list_attr_tb[k]
        if txt_attr then
            local val = attr[v.sign]
            txt_attr:SetText(val or "")
        end
    end
end

return RoleAttrView
