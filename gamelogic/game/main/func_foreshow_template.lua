local FuncForeshowTemplate = Class(game.UITemplate)

function FuncForeshowTemplate:_init()
    self._package_name = "ui_main"
    self._com_name = "func_foreshow_com"
end

function FuncForeshowTemplate:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(function()
    	game.OpenFuncCtrl.instance:OpenFuncForeshowView()
    end)
end

function FuncForeshowTemplate:CloseViewCallBack()
    
end

function FuncForeshowTemplate:UpdateInfo(cfg)

    local career = game.RoleCtrl.instance:GetCareer()

    if cfg.icon[career] then
        self._layout_objs["n2"]:SetSprite("ui_main", cfg.icon[career], true)
    else
        self._layout_objs["n2"]:SetSprite("ui_main", cfg.icon[1], true)
    end

    if cfg.inner_icon[1] ~= 0 then
        if cfg.inner_icon[career] then
            self._layout_objs["n4"]:SetSprite("ui_main", cfg.inner_icon[career], true)
        else
            self._layout_objs["n4"]:SetSprite("ui_main", cfg.inner_icon[1], true)
        end
        self._layout_objs["n4"]:SetVisible(true)
    else
        self._layout_objs["n4"]:SetVisible(false)
    end

    self._layout_objs["n3"]:SetText(string.format(config.words[4029], cfg.level))
end

function FuncForeshowTemplate:SetVisible(val)
    self:GetRoot():SetVisible(val)
end

return FuncForeshowTemplate
