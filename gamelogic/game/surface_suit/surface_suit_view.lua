local SurfaceSuitView = Class(game.BaseView)

function SurfaceSuitView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "surface_suit_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function SurfaceSuitView:OpenViewCallBack()
    self:Init()    
    self:InitBg()
    self:InitListSuitItems()

    self:RegisterAllEvents()
end

function SurfaceSuitView:CloseViewCallBack()
    self:ClearModel()

    for _,v in ipairs(self.suit_item_cache or {}) do
        v:DeleteMe()
    end
    self.suit_item_cache = {}

    self:ClearSuitSubItems()
end

function SurfaceSuitView:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SurfaceSuitView:Init()
    self.txt_name = self._layout_objs["txt_name"]
    
    self.btn_look = self._layout_objs["role_fight_com/btn_look"]
    self.btn_look:AddClickCallBack(function()
        self:OnClickBtnLook()
    end)

    self.txt_fight = self._layout_objs["role_fight_com/txt_fight"]

    self.list_suit_sub_items = self._layout_objs["list_suit_sub_items"]
    
    self.suit_config = {}
    for _,v in pairs(config.surface_suit or {}) do
        table.insert(self.suit_config, v)
    end
    table.sort(self.suit_config, function(v1,v2)
        return v1.seq<v2.seq
    end)
end

function SurfaceSuitView:InitListSuitItems()
    self.img_arrow_r = self._layout_objs["img_arrow_r"]
    self.img_arrow_l = self._layout_objs["img_arrow_l"]

    local item_nums = #self.suit_config    

    local item_ctrl = self:GetRoot():AddControllerCallback("item_ctrl",function(idx)
        for k,v in ipairs(self.suit_item_cache) do
            local is_selected = (k==(idx+1))
            v:SetSelected(is_selected)

            if is_selected then
                self:OnClickSuitItem(v)
            end
        end
    end)
    item_ctrl:SetPageCount(item_nums)

    self.list_suit_items = self._layout_objs["list_suit_items"]
    self.list_suit_items:SetItemNum(item_nums)

    self.suit_item_cache = {}
    local item_class = require("game/surface_suit/surface_suit_item")
    for k,v in ipairs(self.suit_config or {}) do
        local child = self.list_suit_items:GetChildAt(k-1)
        local item = item_class.New(v)
        item:SetVirtual(child)
        item:Open()

        table.insert(self.suit_item_cache, item)
    end

    item_ctrl:SetSelectedIndexEx(0)

    self.list_suit_items:ScrollToView(0)
end

function SurfaceSuitView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1664])
end

function SurfaceSuitView:UpdateInfo(data)
    self.txt_name:SetText(data.name)

    local id_list = self:CalcIdList(data)
    self:UpdateListSuitSubItems(id_list, data.id)

    local model_list = self:CalcModelList()
    self:UpdateModel(model_list)

    local power = self.ctrl:CalcSuitPower(data.id)
    self.txt_fight:SetText(power)
end

function SurfaceSuitView:ClearSuitSubItems()
    for _,v in ipairs(self.suit_sub_item_cache or {}) do
        v:DeleteMe()
    end
    self.suit_sub_item_cache = {}
end


local advance_skin_sort = {}

local SuitItemConfig = {
    {
        model_type = game.ModelType.Body, 
        key = "fashion",
        cfg = config.fashion, 
        id = function(cfg) return cfg.id end,
        name = function(cfg) return cfg.name end, 
        item_id = function(cfg) return cfg.item_id end,
        model_id = function(cfg) return cfg.model_id end,
        click_func = function(id) 
            game.FashionCtrl.instance:OpenView(1, id)
        end,
    },

    {
        model_type = game.ModelType.Hair,
        key = "hair", 
        cfg = config.hair_style, 
        id = function(cfg) return cfg.id end,
        name = function(cfg) return cfg.name end, 
        item_id = function(cfg) return cfg.item_id end,
        model_id = function(cfg) return cfg.model_id end,
        click_func = function(id) 
            game.FashionCtrl.instance:OpenView(2, id)
        end,
    },
}

function SurfaceSuitView:CalcIdList(data)
    local hair_id = nil
    local career = 1--game.Scene.instance:GetMainRoleCareer()
    for _,v in ipairs(data.hair) do
        if v[1] == career then
            hair_id = v[2]
            break
        end
    end

    local id_list = {
        [game.ModelType.Body]    = (data.fashion>0 and data.fashion or nil),
        [game.ModelType.Wing]    = (data.wing>0 and data.wing or nil),
        [game.ModelType.Hair]    = (hair_id>0 and hair_id or nil),
        [game.ModelType.Weapon]    = (data.god>0 and data.god or nil),
        [game.ModelType.Mount]  = (data.mount>0 and data.mount or nil),
    }

    return id_list
end

function SurfaceSuitView:CalcModelList()
    local model_list = {}
    for _,v in ipairs(self.suit_sub_item_cache or {}) do
        model_list[v:GetModelType()] = v:GetModelId()
    end
    return model_list
end

function SurfaceSuitView:UpdateListSuitSubItems(id_list, suit_id)
    self:ClearSuitSubItems()

    local item_num = table.nums(id_list)
    self.list_suit_sub_items:SetItemNum(item_num)

    local idx = 0
    local item_class = require("game/surface_suit/surface_suit_sub_item")
    for k,v in ipairs(SuitItemConfig) do
        local id = id_list[v.model_type]
        if id then
            local cfg = v.cfg[id]

            local info = {
                id = id,
                suit_id = suit_id,
                type = k,
                key = v.key,
                name = v.name(cfg),
                item_id = v.item_id(cfg),
                model_id = v.model_id(cfg),
                model_type = v.model_type,
                click_func = v.click_func,
            }

            idx = idx + 1
            local child = self.list_suit_sub_items:GetChildAt(idx-1)
            local item = item_class.New(info)
            item:SetVirtual(child)
            item:Open()

            table.insert(self.suit_sub_item_cache, item)
        end
    end
end

function SurfaceSuitView:UpdateModel(model_list)
    self:ClearModel()

    self.show_model = require("game/character/model_template").New()
    self.show_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)        
    self.show_model:SetCameraRotation(0,0,0)
    self.show_model:SetPosition(0,-1.55,3.8)
    self.show_model:SetRotation(0,139,0)

    self.show_model:PlayAnim(game.ObjAnimName.RideIdle, game.ModelType.Body + game.ModelType.Wing + game.ModelType.Hair + game.ModelType.Mount + game.ModelType.Weapon)    
end

function SurfaceSuitView:ClearModel()
    if self.show_model then
        self.show_model:DeleteMe()
        self.show_model = nil
    end
end

function SurfaceSuitView:OnClickSuitItem(item)
    self.cur_suit_item = item

    self:UpdateInfo(item:GetData())
end

function SurfaceSuitView:OnClickBtnLook()
    if self.cur_suit_item then
        local data = self.cur_suit_item:GetData()
        self.ctrl:OpenSuitAttrView(data.id)
    end
end

return SurfaceSuitView
