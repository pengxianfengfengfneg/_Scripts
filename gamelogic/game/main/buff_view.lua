local BuffView = Class(game.BaseView)

local handler = handler

function BuffView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "buff_view"

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function BuffView:OpenViewCallBack(buff_info_list)
    self.buff_list = buff_info_list.buff_list
    self.buff_info_list = buff_info_list
    self:Init()

    global.Runner:AddUpdateObj(self, 2)
end

function BuffView:CloseViewCallBack()
    global.Runner:RemoveUpdateObj(self)

    self.buff_list = nil
    self.buff_info_list = nil
    if self.buff_item_list then
        for i,v in ipairs(self.buff_item_list) do
            v:DeleteMe()
        end
        self.buff_item_list = nil
    end
end

function BuffView:Update(now_time, elapse_time)
    if self.buff_info_list then
        if self.buff_info_list.version ~= self.version then
            self:Refresh()
        end
    end
end

function BuffView:Init()
    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)

    self.list_buff = self._layout_objs["list_buff"]
    local size = self.list_buff:GetSize()
    self.list_buff_width = size[1]

    self.buff_item_list = {}
    self:Refresh()
end

function BuffView:Refresh()
    self.version = self.buff_info_list.version

    if #self.buff_list <= 0 then
        self:Close()
    else
        local item_num = #self.buff_list
        self.list_buff:SetItemNum(item_num)

        local buff_item
        local height = 0
        for i,v in ipairs(self.buff_list) do
            buff_item = self.buff_item_list[i]
            if not buff_item then
                local obj = self.list_buff:GetChildAt(i-1)
                buff_item = require("game/main/buff_show_item").New(self.ctrl)
                buff_item:SetVirtual(obj)
                buff_item:Open()
                self.buff_item_list[i] = buff_item
            end
            buff_item:UpdateData(self.buff_list[i])

            local child = self.list_buff:GetChildAt(i-1)
            local size = child:GetSize()
            height = height + size[2]
        end

        height = height - 10
        self.list_buff:SetSize(self.list_buff_width, height)
    end
end


return BuffView
