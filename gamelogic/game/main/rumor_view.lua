local RumorView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format

function RumorView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "rumor_view"

    self._cache_time = 300
    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Keep

    self._ui_order = game.UIZOrder.UIZOrder_Tips


    self.ctrl = ctrl
end

function RumorView:OpenViewCallBack()
    self:Init()

    self:RegisterAllEvents()
end

function RumorView:CloseViewCallBack()

end

function RumorView:RegisterAllEvents()
    local events = {
        {game.ChatEvent.UpdateRumor, handler(self, self.OnUpdateRumor)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function RumorView:Init()
    self.rumor_list = {}

    self.rolling_template = self._layout_objs["rolling_template"]
    self.rolling_template:SetVisible(false)
    
    self.rtx_rumor = self._layout_objs["rolling_template/rtx_rumor"]
end

function RumorView:OnUpdateRumor(data)
    if data.rolling == 0 then
        return
    end

    data.time = os.time()
    table.insert(self.rumor_list, data)

    self:DoRumorSort()
end

local function GetSortIndex(data)
    return data.priority*100000 + (data.time - os.time())
end

local function Sort(v1,v2)
    local idx1 = GetSortIndex(v1)
    local idx2 = GetSortIndex(v2)

    return idx1<idx2
end

function RumorView:DoRumorSort()
    table.sort(self.rumor_list, Sort)

    local max_nums = 5
    local to_flit_list = {}
    for _,v in ipairs(self.rumor_list or {}) do
        if v.priority > 1 then
            table.insert(to_flit_list, v)
        end
    end

    local flit_nums = #to_flit_list
    if flit_nums > max_nums then
        local rumor_nums = #self.rumor_list
        table.remove(self.rumor_list, rumor_nums-flit_nums+max_nums,rumor_nums)
    end
end

function RumorView:PopRumor()
    local rumor = self.rumor_list[1]
    table.remove(self.rumor_list, 1)

    return rumor
end

function RumorView:Update(now_time, elapse_time)
    if not self.is_doing_rumor then
        local rumor = self:PopRumor()
        if rumor then
            self:DoRumor(rumor.content)
        end
    end
end

function RumorView:DoRumor(content)
    if self.is_doing_rumor then
        return
    end

    self.is_doing_rumor = true

    self.rolling_template:SetVisible(true)

    local start_x = 600
    self.rtx_rumor:SetText(content)
    self.rtx_rumor:SetPositionX(start_x)

    local rumor_size = self.rtx_rumor:GetSize()
    local move_len = rumor_size[1] + 500 + (start_x-500) + 10
    local move_sp = 100
    local time = (move_len/move_sp)

    self:ClearTween()

    self.tween = DOTween.Sequence()
    self.tween:Append(self.rtx_rumor:TweenMoveX(start_x-move_len, time))
    self.tween:AppendInterval(0.5)
    self.tween:AppendCallback(function()
        self.is_doing_rumor = false
        self:ClearTween()

        self:CheckRolling()
    end)
    self.tween:SetAutoKill(false)
    self.tween:SetLoops(1) 
end

function RumorView:ClearTween()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function RumorView:CheckRolling()
    if #self.rumor_list <= 0 then
        self.rolling_template:SetVisible(false)
    end
end

return RumorView
