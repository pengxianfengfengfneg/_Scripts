local RoleTitleAttrView = Class(game.BaseView)

function RoleTitleAttrView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_title_attr_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
    self.data = ctrl.role_data
end

function RoleTitleAttrView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1681])

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

    local attr_list = {}
    for k,v in pairs(attr_map) do
        table.insert(attr_list, {[1] = k, [2] = v})
    end
    table.sort(attr_list, function(a, b)
        return a[1] < b[1]
    end)

    self.ui_list = game.UIList.New(self._layout_objs["attr_list"])
    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/role/role_title_attr_item").New()
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:UpdateData(idx, config_help.ConfigHelpAttr.GetAttrName(attr_list[idx][1]), attr_list[idx][2])
    end)
    self.ui_list:SetVirtual(true)
    self.ui_list:SetItemNum(#attr_list)
end

function RoleTitleAttrView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

return RoleTitleAttrView
