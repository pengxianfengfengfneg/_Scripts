local MsgNoticeView = Class(game.BaseView)

local handler = handler
local config_msg_notice = config.msg_notice

local MsgNoticeType = game.MsgNoticeType

local TypeTitleName = {
    [MsgNoticeType.System] = config.words[6350],
    [MsgNoticeType.Activity] = config.words[6351],
    [MsgNoticeType.Social] = config.words[6352],
}

local MsgNoticeConfig = require("game/msg_notice/msg_notice_config")

function MsgNoticeView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "msg_notice_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Standalone

    self:AddPackage("ui_activity")

    self.ctrl = ctrl
end

function MsgNoticeView:OpenViewCallBack(msg_notice_type)
    self:Init()
    self:InitBg()
    self:InitList()
    self:InitController(msg_notice_type)

    self:RegisterAllEvents()
end

function MsgNoticeView:CloseViewCallBack()
    
end

function MsgNoticeView:RegisterAllEvents()
    local events = {
        {game.MsgNoticeEvent.AddMsgNotice, handler(self,self.OnAddMsgNotice)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

function MsgNoticeView:Init()
    self.msg_sys_template = self:GetTemplate("game/msg_notice/msg_sys_template", "msg_sys_template")
    self.msg_activity_template = self:GetTemplate("game/msg_notice/msg_activity_template", "msg_activity_template")
    self.msg_social_template = self:GetTemplate("game/msg_notice/msg_social_template", "msg_social_template")

    self.txt_title = self._layout_objs["txt_title"]

    self.list_operate = self._layout_objs["list_operate"]
    self.list_operate.foldInvisibleItems = true

    self.btn_left = self._layout_objs["list_operate/btn_left"]
    self.btn_left:AddClickCallBack(function()
        if self.cur_msg_item then
            self.ctrl:ClearMsgNoticeByIdTime(self.cur_msg_item:GetId(), self.cur_msg_item:GetTimeStamp())

            if self.ctrl:IsMsgNoticeTypeEmpty(self.cur_msg_type) then
                self:Close()
                return
            end

            self:UpdateList()
        end
    end)

    self.btn_right = self._layout_objs["list_operate/btn_right"]
    self.btn_right:AddClickCallBack(function()
        local cfg = MsgNoticeConfig[self.cur_msg_item:GetId()]
        if cfg then
            cfg.click_func(self.cur_msg_item:GetCfg(), self.cur_msg_item:GetMsgParams())

            self:Close()
        end
    end)

    self.btn_ignore = self._layout_objs["btn_ignore"]
    self.btn_ignore:AddClickCallBack(function()
        self.ctrl:ReadAllTypeMsgNotice(self.cur_msg_type)

        self:Close()
    end)
end

function MsgNoticeView:InitBg()
    self.view_bg = self:GetBgTemplate("common_bg")
end

function MsgNoticeView:InitController(msg_notice_type)
    self.tab_ctrl = self:GetRoot():AddControllerCallback("c1", function(idx)
        local new_type = idx + 1
        local is_empty = self.ctrl:IsMsgNoticeTypeEmpty(new_type)
        if is_empty then
            self.tab_ctrl:SetSelectedIndex(self.cur_msg_type-1)

            game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6353], TypeTitleName[new_type]))
            return
        end

        self.cur_msg_type = new_type

        self.view_bg:SetTitleName(TypeTitleName[self.cur_msg_type] or TypeTitleName[MsgNoticeType.System])

        self:UpdateList()
    end)

    self.cur_msg_type = msg_notice_type or MsgNoticeType.System
    self.tab_ctrl:SetSelectedIndexEx(self.cur_msg_type-1)
end

function MsgNoticeView:InitList()
    self.ui_list = self:CreateList("list_item", "game/msg_notice/msg_notice_item", true)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetData(idx)
        item:UpdateData(data)
    end)

    self.ui_list:AddClickItemCallback(function(item)
        self:OnClickItem(item)
    end)
end

function MsgNoticeView:GetData(idx)
    return self.notice_data[idx]
end

function MsgNoticeView:OnClickItem(item)
    self.cur_msg_item = item

    local msg_cfg = item:GetCfg()
    

    self.txt_title:SetText(msg_cfg.title)

    self:UpdateMsgType(item)

    item:SetReadFlag()

    self:UpdateOperate()
end

function MsgNoticeView:UpdateMsgType(item)
    local type = item:GetType()
    if type == MsgNoticeType.System then
        self.msg_sys_template:UpdateData(item)
        return
    end

    if type == MsgNoticeType.Activity then
        self.msg_activity_template:UpdateData(item)
        return
    end

    if type == MsgNoticeType.Social then
        self.msg_social_template:UpdateData(item)
        return
    end
end

function MsgNoticeView:OnAddMsgNotice(id)
    local cfg = config_msg_notice[id]
    if cfg and cfg.type==self.cur_msg_type then
        self:UpdateList()
    end
end

function MsgNoticeView:UpdateList()
    self.notice_data = self.ctrl:GetMsgNoticeByType(self.cur_msg_type)

    table.sort(self.notice_data, function(v1,v2)
        local time1 = tonumber(v1[2])
        local time2 = tonumber(v2[2])

        local read_flag1 = tonumber(v1[3])
        local read_flag2 = tonumber(v2[3])

        return (time1*(2-read_flag1)>time2*(2-read_flag2))
    end)

    local item_num = #self.notice_data
    self.ui_list:SetItemNum(item_num)

    self.cur_msg_item = nil
    if item_num > 0 then
        local item = self.ui_list:GetItemByIdx(0)
        if item then
            self.ui_list:AddSelection(0,true)
            self:OnClickItem(item)
        end
    else
        -- 没有消息，关闭界面
        self:Close()
    end
end

function MsgNoticeView:UpdateOperate()
    local cfg = self.cur_msg_item:GetCfg()
    local is_activity = (cfg.type==MsgNoticeType.Activity)
    self.btn_left:SetVisible(not is_activity)

    local name = cfg.func_name
    if name == "" then
        name = config.words[6355]
    end
    self.btn_right:SetText(name)

    local enable = cfg.check_enable_func(cfg)
    self.btn_right:SetGray(not enable)
    self.btn_right:SetTouchEnable(enable)
    
    local visible = cfg.check_visible_func(cfg)
    self.btn_right:SetVisible(visible)
end

return MsgNoticeView
