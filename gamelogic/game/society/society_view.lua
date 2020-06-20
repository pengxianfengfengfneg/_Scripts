local SocietyView = Class(game.BaseView)

function SocietyView:_init(ctrl)
	self._package_name = "ui_society"
    self._com_name = "society_view"

    self._show_money = true
    
    self.ctrl = ctrl
end

function SocietyView:OpenViewCallBack()

	self._layout_objs["list_page"]:SetHorizontalBarTop(true)

    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5900])

    self:SetOpenLimit()

    self.template_list = {}
    for i = 1, 5 do
        if i <= self.max_index then
        	local root = self._layout_objs["list_page"]:GetChildAt(i-1)
        	local template = require("game/society/society_template").New(i)
        	template:SetVirtual(root)
        	template:Open()
        	table.insert(self.template_list, template)
        end
    end

    self._layout_objs.list_page:SetLastPageCallBack(self.max_index, function()

    end)

    for i = 1, 6 do
        self._layout_objs["award_img"..i]:SetTouchDisabled(false)
        self._layout_objs["award_img"..i]:AddClickCallBack(function()
            local star = config.society_star[i].star
            self.ctrl:CsSocietyStarReward(star)
        end)
    end

    self:InitAwardProgress()

    self:SetPetInfo()

    self:SetTabsHd()

    self:BindEvent(game.SocietyEvent.RefreshTaskState, function()
        self:SetTabsHd()
    end)

    self:BindEvent(game.SocietyEvent.RefreshStarAward, function()
        self:InitAwardProgress()
    end)
end

function SocietyView:CloseViewCallBack()
	for k,v in pairs(self.template_list) do
		v:DeleteMe()
	end
	self.template_list = nil

    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

local step_to_progress = {
    [0] = 0,
    [1] = 4,
    [2] = 27,
    [3] = 52,
    [4] = 74,
    [5] = 98,
    [6] = 100,
}

function SocietyView:InitAwardProgress()

    local society_data = self.ctrl:GetData()
    local cur_star = society_data:GetStar()
    local cur_step = 0
    local cur_got_list = society_data:GetCurGotList()

    for index, v in ipairs(config.society_star) do

        self._layout_objs["award_value"..index]:SetText(v.star)

        local item_id = config.drop[v.reward].client_goods_list[1][1]
        self._layout_objs["award_img"..index]:SetSprite("ui_item", tostring(config.goods[item_id].icon))

        local item_num = config.drop[v.reward].client_goods_list[1][2]
        self._layout_objs["num"..index]:SetText(tostring(item_num))

        local bg_img = "ndk_0"..tostring(config.goods[item_id].color)
        self._layout_objs["award_bg"..index]:SetSprite("ui_common",bg_img)

        if cur_star>= v.star then
            cur_step = index
        end

        if cur_star >= v.star then

            local got_flag = false
            for i, j in pairs(cur_got_list) do
                if j.star == v.star then
                    got_flag = true
                    break
                end
            end

            if got_flag then
                self._layout_objs["hd_img"..index]:SetVisible(false)
                self._layout_objs["get_img"..index]:SetVisible(true)
            else
                self._layout_objs["hd_img"..index]:SetVisible(true)
                self._layout_objs["get_img"..index]:SetVisible(false)
            end
        else
            self._layout_objs["hd_img"..index]:SetVisible(false)
            self._layout_objs["get_img"..index]:SetVisible(false)
        end
    end

    self._layout_objs["n12"]:SetProgressValue(step_to_progress[cur_step])
    self._layout_objs["n12"]:GetChild("title"):SetText("")
    self._layout_objs["total_star"]:SetText(cur_star)
end

function SocietyView:SetOpenLimit()

    local society_data = game.SocietyCtrl.instance:GetData()
    local open_time = society_data:GetOpenTime() + 28800
    local cur_time = global.Time:GetServerTime() + 28800
    local open_day = math.floor(open_time/86400)
    local cur_day = math.floor(cur_time/86400)
    local off_day = cur_day - open_day + 1      --现在是开启的第几天

    local max_index = 0
    for k, v in ipairs(config.society_tag) do
        if off_day >= v.open_day then
            max_index = k
        else

        end
    end

    self.max_index = max_index

    for i = 1, 5 do
        if i <= max_index then
            self._layout_objs["lock"..i]:SetVisible(false)
        else
            self._layout_objs["lock"..i]:SetVisible(true)
        end
    end
end

function SocietyView:SetPetInfo()
    
    local pet_id = config.sys_config["society_show_pet"].value
    local pet_cfg = config.pet[pet_id]
    local model_id = pet_cfg.model_id[1]

    self._layout_objs["n73"]:SetText(config.words[5901]..pet_cfg.name)
    self._layout_objs["n57"]:SetText(config.words[5902]..pet_cfg.name)

    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs["model"], game.BodyType.Monster)
    self.model:SetPosition(0, -1.2, 2.39)
    self.model:SetScale(0.6)
    self.model:SetModelChangeCallBack(function()
        self.model:SetRotation(0, 140, 0)
    end)
    self.model:SetModel(game.ModelType.Body, model_id)
    self.model:PlayAnim(game.ObjAnimName.Idle)
    self._layout_objs["model"]:SetVisible(true)

    local v1 = pet_cfg.power[2][1][2]
    self._layout_objs["attrvalue1"]:SetText(tostring(v1))

    local v2 = pet_cfg.anima[2][1][2]
    self._layout_objs["attrvalue2"]:SetText(tostring(v2))

    local v3 = pet_cfg.energy[2][1][2]
    self._layout_objs["attrvalue3"]:SetText(tostring(v3))

    local v4 = pet_cfg.concent[2][1][2]
    self._layout_objs["attrvalue4"]:SetText(tostring(v4))

    local v5 = pet_cfg.method[2][1][2]
    self._layout_objs["attrvalue5"]:SetText(tostring(v5))
end

function SocietyView:SetTabsHd()
    local society_data = game.SocietyCtrl.instance:GetData()
    local open_time = society_data:GetOpenTime()
    local cur_time = global.Time:GetServerTime()
    local open_day = math.floor(open_time/86400)
    local cur_day = math.floor(cur_time/86400)
    local off_day = cur_day - open_day + 1      --现在是开启的第几天

    local max_index = 0
    for k, v in ipairs(config.society_tag) do
        if off_day >= v.open_day then
            max_index = k
        end
    end

    for i = 1, 5 do
        if i <= max_index then
            if society_data:CheckHdByTab(i) then
                self._layout_objs["hd_tab"..i]:SetVisible(true)
            else
                self._layout_objs["hd_tab"..i]:SetVisible(false)
            end
        end
    end
end

return SocietyView