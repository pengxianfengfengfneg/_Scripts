local CommonFullBg = Class(game.UITemplate)

function CommonFullBg:_init(view)
    self.parent_view = view
end

function CommonFullBg:OpenViewCallBack()
    self:Init()
end

function CommonFullBg:CloseViewCallBack()

end

function CommonFullBg:Init()
    self.txt_title = self._layout_objs["txt_title"]

    self.btn_close = self._layout_objs["btn_close"]
    self.btn_close:AddClickCallBack(function()
        game.ViewMgr:CloseAllView()
    end)

    self.btn_back = self._layout_objs["btn_back"]
    self.btn_back:AddClickCallBack(function()
        self.parent_view:Close()
    end)

    self.btn_wh = self._layout_objs["btn_wh"]
    if self.btn_wh then
        self.btn_wh:AddClickCallBack(function()
            if self.wh_callback then
                self.wh_callback()
            end
        end)
    end
end

function CommonFullBg:SetTitleName(name)
    self.txt_title:SetText(name or "")
    return self
end

function CommonFullBg:SetInfoCallback(callback)
    self.wh_callback = callback
    return self
end

function CommonFullBg:HideBtnBack()
    self.btn_back:SetVisible(false)
    return self
end

function CommonFullBg:SetBtnWhVisible(val)
    if self.btn_wh then
        self.btn_wh:SetVisible(val)
    end
    return self
end

return CommonFullBg
