local MsgTipsView = Class(game.BaseView)

local handler = handler
local table_insert = table.insert
local string_gsub = string.gsub
local table_remove = table.remove
local type = type
local ipairs = ipairs
local tostring = tostring

local _et = {}

function MsgTipsView:_init(ctrl)
    self._package_name = "ui_game_msg"
    self._com_name = "msg_tips_view"

    self.add_to_view_mgr = false
    self._ui_order = game.UIZOrder.UIZOrder_Tips + 2

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

    self._layer_name = game.LayerName.UIDefault

    self.max_show = 3
    self.tips_item_using_list = {}
    self.tips_item_cache = {}

    self.data_list = {}
end

function MsgTipsView:OpenViewCallBack()
    self:InitItems()

    self:ScheduleUpdate()
end

function MsgTipsView:CloseViewCallBack()
    for _,v in ipairs(self.tips_item_cache or _et) do
        v:DeleteMe()
    end

    for _,v in ipairs(self.tips_item_using_list or _et) do
        v:DeleteMe()
    end
end

function MsgTipsView:InitItems()
    local item_class = require("game/gamemsg/msg_tips_item")
    for i=1,self.max_show do
        local item = item_class.New()
        item:Open()
        item:SetParent(self:GetRoot())

        table_insert(self.tips_item_cache, item)
    end
end

function MsgTipsView:Update(now_time, elapse_time)
    local data = self.data_list[1]
    if data then
        table_remove(self.data_list, 1)

        local item = self:GetTipsItem()
        item:UpdateData(data)

        for k,v in ipairs(self.tips_item_using_list or _et) do
            local posY = 240 - (k-1)*30
            v:GetRoot():SetPosition(0, posY)
        end
    end
end

function MsgTipsView:AddData(data)
    local data = tostring(data)
    data = string_gsub(data, "%b<>", "")

    if #self.data_list >= self.max_show then
        self.data_list[1] = self.data_list[2]
        self.data_list[2] = self.data_list[3]
        self.data_list[3] = data
    else
        table_insert(self.data_list, data)
    end
end

function MsgTipsView:PushMsg(data)
    if type(data) == "table" then
        for _,v in ipairs(data or _et) do
            self:AddData(v.desc)
        end
    else
        self:AddData(data)
    end
end

function MsgTipsView:GetTipsItem()    
    local tips_item = self:PopTipsItem()
    table_insert(self.tips_item_using_list, 1, tips_item)

    local len = #self.tips_item_using_list
    if len > self.max_show then
        local item = self.tips_item_using_list[len]
        item:Stop()
        table_remove(self.tips_item_using_list, len)
        table_insert(self.tips_item_cache, item)
    end

    return tips_item
end

function MsgTipsView:PopTipsItem()
    local tips_item = self.tips_item_cache[1]

    if tips_item then
        table_remove(self.tips_item_cache, 1)
    else
        tips_item = require("game/gamemsg/msg_tips_item").New()
        tips_item:Open()
        tips_item:SetParent(self:GetRoot())
    end
    return tips_item
end

return MsgTipsView
