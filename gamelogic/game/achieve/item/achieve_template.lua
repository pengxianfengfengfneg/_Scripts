local AchieveTemplate = Class(game.UITemplate)

function AchieveTemplate:OpenViewCallBack()
    self._layout_objs["bar/bar"]:SetSprite("ui_common", "jyt_06")
    self._layout_objs.bar.titleType = 0
    self:BindEvent(game.AchieveEvent.AchieveInfo, function()
        self:SetAchieveList(self.cur_type)
        self:SetProgress(config.achieve_type[self.cur_type])
        self:SetBtnTips()
    end)
end

function AchieveTemplate:SetTemplateInfo(idx)
    local type_list = {}
    for k, v in pairs(config.achieve_type) do
        if v.cate == idx then
            v.type = k
            table.insert(type_list, v)
        end
    end
    table.sort(type_list, function(a, b)
        return a.type < b.type
    end)

    self.achieve_list = self:CreateList("achieve_list", "game/achieve/item/achieve_item")
    self.achieve_list:SetRefreshItemFunc(function(item, index)
        item:SetItemInfo(self.achieve_cfg[index])
        item:SetBG(index % 2 == 1)
    end)

    self._layout_objs.btn_list:SetItemNum(#type_list)
    self.btn_list = {}
    self.btn_data = {}
    for i = 1, #type_list do
        local item = self._layout_objs.btn_list:GetChildAt(i - 1)
        table.insert(self.btn_data, type_list[i])
        table.insert(self.btn_list, item)
        item:SetText(type_list[i].name)
        item:GetChild("icon_up"):SetSprite("ui_achieve", type_list[i].icon_up, true)
        item:GetChild("icon_down"):SetSprite("ui_achieve", type_list[i].icon_down, true)
        item:AddClickCallBack(function()
            self:SetAchieveList(type_list[i].type)
            self:SetTitle(type_list[i])
            self:SetProgress(type_list[i])
            for _, v in ipairs(self.btn_list) do
                v:SetSelected(false)
            end
            item:SetSelected(true)
        end)
        item:SetSelected(i == 1)
    end
    self:SetBtnTips()

    self:SetAchieveList(type_list[1].type)
    self:SetTitle(type_list[1])
    self:SetProgress(type_list[1])
end

function AchieveTemplate:SetAchieveList(type)
    self.cur_type = type
    self.achieve_cfg = {}
    for k, v in pairs(config.achieve_task) do
        v.id = k
        if math.floor(k / 100) == type then
            table.insert(self.achieve_cfg, v)
        end
    end
    table.sort(self.achieve_cfg, function(a, b)
        local a_info = game.AchieveCtrl.instance:GetAchieveTaskInfo(a.id)
        local b_info = game.AchieveCtrl.instance:GetAchieveTaskInfo(b.id)
        if a_info.state == b_info.state then
            return a.id < b.id
        else
            if a_info.state == 3 then
                return true
            elseif b_info.state == 3 then
                return false
            elseif a_info.state == 4 then
                return false
            else
                return true
            end
        end
    end)
    self.achieve_list:SetItemNum(#self.achieve_cfg)
end

function AchieveTemplate:SetTitle(cfg)
    self._layout_objs.img_achieve:SetSprite("ui_achieve", cfg.achieve_icon, true)
    if config.title[cfg.title] then
        self._layout_objs.title:SetText(string.format(config.words[3402], config.title[cfg.title].name))
    else
        self._layout_objs.title:SetText("")
    end
end

function AchieveTemplate:SetProgress(cfg)
    local type_info = game.AchieveCtrl.instance:GetAchieveTypeInfo(cfg.type)
    if type_info then
        self._layout_objs.bar:SetProgressValue(type_info.star / cfg.star * 100)
    else
        self._layout_objs.bar:SetProgressValue(0)
    end
end

function AchieveTemplate:SetBtnTips()
    for i, v in ipairs(self.btn_list) do
        local tips = game.AchieveCtrl.instance:GetAchieveTypeTips(self.btn_data[i].type)
        game.Utils.SetTip(v, tips, {x = 90, y = 0})
    end
end

return AchieveTemplate