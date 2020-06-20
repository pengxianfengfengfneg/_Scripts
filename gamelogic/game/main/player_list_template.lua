local PlayerListTemplate = Class(game.UITemplate)

function PlayerListTemplate:_init(parent_view, type_idx)
    self.type_idx = type_idx
end

function PlayerListTemplate:OpenViewCallBack()
    self.data_list = {}
    local ui_list = game.UIList.New(self._layout_objs["list"])
    ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/main/player_template").New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    ui_list:SetRefreshItemFunc(function(item, idx)
        item:SetData(idx, self.data_list[idx])
    end)
    ui_list:AddClickItemCallback(function(item)
        if item then
            item:OnClick()
        end
    end)
    ui_list:SetVirtual(true)
    ui_list:SetItemNum(#self.data_list)
    self.ui_list = ui_list

    self:Refresh()
end

function PlayerListTemplate:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function PlayerListTemplate:SetSeqOrder(val)
    self.seq_order = val
    self:Sort()
    self.ui_list:RefreshVirtualList()
end

local function get_relation(main_role, obj)
    if main_role.vo.guild_id == obj.vo.guild_id then
        return config.words[513]
    else
        return config.words[518]
    end
end

function PlayerListTemplate:Refresh()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        self.data_list = {}

        local get_data = function(obj)
            local vo = obj.vo
            local data = {}
            data.id = vo.role_id
            data.career = vo.career
            data.name = vo.name
            data.lv = vo.level
            data.guild_name = vo.guild_name
            data.is_rival = main_role:IsRival(vo.role_id) or false
            data.relation = get_relation(main_role, obj)
            return data
        end

        if self.type_idx == 1 then
            game.Scene.instance:ForeachObjs(function(obj, ls)
                if obj.obj_type == game.ObjType.Role and main_role:IsEnemy(obj) then
                    table.insert(ls, get_data(obj))
                end
            end, self.data_list)
        else
            game.Scene.instance:ForeachObjs(function(obj, ls)
                if obj.obj_type == game.ObjType.Role and not main_role:IsEnemy(obj) then
                    table.insert(ls, get_data(obj))
                end
            end, self.data_list)
        end

        self:Sort()

        self.ui_list:SetItemNum(#self.data_list)
        self.ui_list:RefreshVirtualList()
    end
end

local com_func = N3DClient.GameTool.CampareString
function PlayerListTemplate:Sort()
    local ret = self.seq_order and -1 or 1
    table.sort(self.data_list, function(a, b)
        return com_func(a.name, b.name)  == ret
    end)
end

return PlayerListTemplate
