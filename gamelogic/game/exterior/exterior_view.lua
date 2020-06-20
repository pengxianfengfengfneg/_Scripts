local ExteriorView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/mount_template",
        item_class = "game/exterior/template/exterior_mount_template",
    },
    {
        item_path = "list_page/fashion_template",
        item_class = "game/exterior/template/exterior_fashion_template",
    },
    {
        item_path = "list_page/action_template",
        item_class = "game/exterior/template/exterior_action_template",
    },
    {
        item_path = "list_page/frame_template",
        item_class = "game/exterior/template/exterior_frame_template",
    },
    {
        item_path = "list_page/bubble_template",
        item_class = "game/exterior/template/exterior_bubble_template",
    },
}

function ExteriorView:_init(ctrl)
    self._package_name = "ui_exterior"
    self._com_name = "exterior_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function ExteriorView:_delete()
    
end

function ExteriorView:OpenViewCallBack(open_idx)
    self:Init(open_idx)
    self:InitBg()
    self:SetTips()
end

function ExteriorView:CloseViewCallBack()
    game.ExteriorCtrl.instance:SetActionTips(false)
end

function ExteriorView:Init(open_idx)
    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true, 21)
    self:InitView()
    self.page_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
    end)

    open_idx = open_idx or 1
    self.page_controller:SetSelectedIndexEx(open_idx-1)
end

function ExteriorView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5500])
end

function ExteriorView:InitView()
    for _, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path)
    end
end

function ExteriorView:SetTips()
    for i = 0, 4 do
        local btn = self._layout_objs.list_tab:GetChildAt(i)
        if i == 1 then
            game.Utils.SetTip(btn, game.FashionCtrl.instance:GetAllFashionNewActionState() == true, {x = 115, y = 0})
        end
        if i == 2 then
            game.Utils.SetTip(btn, game.ExteriorCtrl.instance:GetActionTips() == true, {x = 115, y = 0})
        end
    end
end

return ExteriorView
