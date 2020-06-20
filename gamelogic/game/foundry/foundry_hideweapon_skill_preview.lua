local FoundryHideweaponSkillPreview = Class(game.BaseView)

function FoundryHideweaponSkillPreview:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_hideweapon_skill_preview"
    self.ctrl = ctrl
    self.foundry_data = self.ctrl:GetData()
    self._view_level = game.UIViewLevel.Second
end

function FoundryHideweaponSkillPreview:_delete()
end

function FoundryHideweaponSkillPreview:OpenViewCallBack()

	self:GetBgTemplate("common_bg"):SetTitleName(config.words[1503])

    self:InitTabList()
end

function FoundryHideweaponSkillPreview:CloseViewCallBack()

    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function FoundryHideweaponSkillPreview:InitTabList()

    local list = self.foundry_data:GetHWPreviewSkillList()
    local num = #list
    self.list_data = list

	self.list = self._layout_objs["n10"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(false)

    self.ui_list:SetCreateItemFunc(function(obj, idx)
    	local item = require("game/foundry/foundry_hideweapon_skill_item").New(self)
	    item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)
 
    self.ui_list:AddClickItemCallback(function(item)
        self:OnSelect(item:GetIdx())
    end)

    self.ui_list:SetItemNum(num)
    
    self:OnSelect(1)

    self:InitTopFive()
end

function FoundryHideweaponSkillPreview:OnSelect(index)

    self.ui_list:Foreach(function(v)
        if v:GetIdx() ~= index then
            v:SetSelect(false)
        else
            v:SetSelect(true)
        end
    end)

    self.select_index = index

    self:InitTopData(self.list_data[index])
end

function FoundryHideweaponSkillPreview:GetListData()
    return self.list_data
end

function FoundryHideweaponSkillPreview:InitTopFive()

    for i = 1, 5 do
        self._layout_objs["top_item"..i.."/n0"]:SetTouchDisabled(false)
        self._layout_objs["top_item"..i.."/n0"]:AddClickCallBack(function()
            self:OnSelectTop(i)
        end)
    end
end

function FoundryHideweaponSkillPreview:OnSelectTop(index)

    for i = 1, 5 do
        self._layout_objs["top_item"..i.."/select_img"]:SetVisible(i==index)
    end

    local bottom_skill_id = self.list_data[self.select_index]
    local target_skill_id = bottom_skill_id + index - 1
    local target_skill_cfg = config.skill[target_skill_id][1]

    self._layout_objs["skill_name"]:SetText(target_skill_cfg.name)
    self._layout_objs["skill_desc"]:SetText(target_skill_cfg.desc)
end

function FoundryHideweaponSkillPreview:InitTopData(skill_id)

    local start_skill_id = skill_id
    local end_skill_id = skill_id + 4

    local count = 1
    for i = start_skill_id, end_skill_id do

        local skill_cfg = config.skill[i][1]
        local skill_icon = skill_cfg.icon
        local skill_color = skill_cfg.color
        local bg = "item"..skill_color
        self._layout_objs["top_item"..count.."/skill_icon"]:SetSprite("ui_skill_icon", skill_icon)
        self._layout_objs["top_item"..count.."/n0"]:SetSprite("ui_common", bg)

        count = count + 1
    end

    self:OnSelectTop(1)
end

return FoundryHideweaponSkillPreview
