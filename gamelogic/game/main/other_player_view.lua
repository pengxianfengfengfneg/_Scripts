local OtherPlayerView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/enemy_list",
        item_class = "game/main/player_list_template",
        param = 1,
    },
    {
        item_path = "list_page/friend_list",
        item_class = "game/main/player_list_template",
        param = 2,
    },
}

function OtherPlayerView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "other_player_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function OtherPlayerView:OpenViewCallBack(open_idx)
    self.seq_order = false
    self._layout_objs["sort_btn"]:SetText(config.words[510])
    self._layout_objs["sort_btn"]:AddClickCallBack(function()
        self.seq_order = not self.seq_order
        if self.seq_order then
            self._layout_objs["sort_btn"]:SetText(config.words[511])
        else
            self._layout_objs["sort_btn"]:SetText(config.words[510])
        end

        for i,v in ipairs(self.template_list) do
            v:SetSeqOrder(self.seq_order)
        end
    end)

    self._layout_objs["refresh_btn"]:AddClickCallBack(function()
        self:Refresh()
    end)

    self:Init(open_idx)
    self:InitBg()
    self:InitPage()

    self:Refresh()
end

function OtherPlayerView:CloseViewCallBack()
    self.template_list = nil
end

function OtherPlayerView:Init(open_idx)
    local list_tab = self._layout_objs["list_tab"]

    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)

    self.page_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:OnClickPage(idx)
    end)

    local open_idx = open_idx or 1
    self.page_controller:SetSelectedIndexEx(open_idx-1)
end

function OtherPlayerView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1678])
end

function OtherPlayerView:InitPage()
    self.template_list = {}
    for k,v in ipairs(PageConfig) do
        local temp = self:GetTemplate(v.item_class, v.item_path, v.param)
        temp:SetSeqOrder(self.seq_order)
        table.insert(self.template_list, temp)
    end
end

function OtherPlayerView:OnClickPage(idx)
    
end

function OtherPlayerView:Refresh()
    local num = 0
    game.Scene.instance:ForeachObjs(function(obj)
        if obj.obj_type == game.ObjType.Role then
            num = num + 1
        end
    end)

    self._layout_objs["num_txt"]:SetText(string.format(config.words[512], num))
    for i,v in ipairs(self.template_list) do
        v:Refresh()
    end
end

return OtherPlayerView
