local HeroGuideView = Class(game.BaseView)

function HeroGuideView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "hero_guide_view"

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function HeroGuideView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitListItems()
    self:InitListTabs()   
    self:InitBtns() 
    self:UpdateTabNamme()

    self:RegisterAllEvents()
end

function HeroGuideView:CloseViewCallBack()
    self:DoSaveGuide()
end

function HeroGuideView:RegisterAllEvents()
    local events = {
        {game.HeroEvent.HeroSetGuide, handler(self,self.OnHeroSetGuide)},
        {game.HeroEvent.HeroGuideEdit, handler(self,self.OnHeroGuideEdit)},
        {game.HeroEvent.HeroUseGuide, handler(self,self.OnHeroUseGuide)},
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function HeroGuideView:OnEmptyClick()
    self:Close()
end

function HeroGuideView:Init()    
    self.txt_desc = self._layout_objs["txt_desc"]

    self.role_career = game.RoleCtrl.instance:GetCareer()

    self:InitSaveGuideInfo()    
end

function HeroGuideView:InitListTabs()
    self.list_tabs = self._layout_objs["list_tabs"]
    local item_num = self.list_tabs:GetItemNum()

    self.list_tab_objs = {}
    for i=1,item_num do
        local item_obj = self.list_tabs:GetChildAt(i-1)
        table.insert(self.list_tab_objs, item_obj)
    end    

    local item_ctrl = self:GetRoot():AddControllerCallback("item_ctrl", function(idx)
        self:OnClickTab(idx+1)
    end)

    item_ctrl:SetSelectedIndexEx(0)

    self:UpdateGuideTabs()
end

function HeroGuideView:InitListItems()
    self.list_items = self._layout_objs["list_items"]

    local item_num = self.list_items:GetItemNum()

    self.list_guide_items = {}
    local item_class = require("game/skill/hero_guide_item")
    for i=1,item_num do
        local item_obj = self.list_items:GetChildAt(i-1)
        local item = item_class.New(i)
        item:SetVirtual(item_obj)
        item:Open()

        table.insert(self.list_guide_items, item)
    end

    self:InitSkillName()
end

function HeroGuideView:InitSkillName()
    local career = game.RoleCtrl.instance:GetCareer()
    local skill_career_cfg = config.skill_career[career] or {}

    local config_skill = config.skill
    for k,v in ipairs(skill_career_cfg) do
        local item = self.list_guide_items[k]
        if item then
            local cfg = config_skill[v.skill_id][1]
            item:SetSkillInfo(v.skill_id, cfg.name)
        end
    end
end

function HeroGuideView:InitBtns()
    self.btn_one_key = self._layout_objs["btn_one_key"]
    self.btn_one_key:AddClickCallBack(function()
        self:OnClickBtnOneKey()
    end)

    self.btn_modify = self._layout_objs["btn_modify"]
    self.btn_modify:AddClickCallBack(function()
        local save_info = self.save_guide_info[self.cur_guide_idx]
        self.ctrl:OpenHeroGuideEditView(save_info.name, save_info.desc)
    end)
end

function HeroGuideView:ClearGuideItems()
    for _,v in ipairs(self.list_guide_items or {}) do
        v:DeleteMe()
    end
    self.list_guide_items = {}
end

function HeroGuideView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1666])
end

function HeroGuideView:OnClickTab(idx)
    self:UpdateGuide(idx)

end

function HeroGuideView:UpdateGuide(idx)
    self.cur_guide_idx = idx

    self:UpdateGuideInfos()
end

function HeroGuideView:UpdateGuideTabs()
    
end

function HeroGuideView:InitSaveGuideInfo()
    self.save_guide_info = {}

    for i=1,3 do
        local info = {
            id = i,
            name = "",
            desc = "",
            plan = {},
            dirty = false,
        }
        table.insert(self.save_guide_info, info)
    end

    local hero_ctrl = game.HeroCtrl.instance
    for k,v in ipairs(self.save_guide_info) do
        local dirty = nil
        local guide_info = hero_ctrl:GetHeroGuideInfo(k)
        if not guide_info then
            dirty = true
            guide_info = config.hero_guide[k][self.role_career]
        end

        v.id = guide_info.id
        v.name = guide_info.name
        v.desc = guide_info.desc
        v.dirty = dirty            

        for ck,cv in ipairs(guide_info.plan) do
            local info = {
                id = cv.id or cv[2],
                skill = cv.skill or cv[1],
            }
            table.insert(v.plan,info)
        end


    end
end

function HeroGuideView:UpdateGuideInfos()
    local guide_info = self.save_guide_info[self.cur_guide_idx]
    self.txt_desc:SetText(guide_info.desc)

    for k,v in ipairs(self.list_guide_items) do
        local update_info = nil
        local skill_id = v:GetSkillId()
        for _,cv in pairs(guide_info.plan) do
            if skill_id == cv.skill then
                update_info = cv
                break
            end
        end

        if not update_info then
            update_info = {
                id = -1,
                skill = skill_id,
            }
        end

        v:UpdateGuideInfo(update_info)
    end
end

function HeroGuideView:DoSaveGuide()
    local hero_ctrl = game.HeroCtrl.instance
    if hero_ctrl then
        for _,v in ipairs(self.save_guide_info) do
            if v.dirty then
                v.dirty = nil

                if #v.plan > 0 then
                    hero_ctrl:SendHeroModifyGuide(v)
                end
            end
        end
    end
end

function HeroGuideView:OnHeroSetGuide(skill_id, hero_id)
    local guide_info = self.save_guide_info[self.cur_guide_idx] or {}
    for _,cv in ipairs(guide_info.plan or {}) do
        if cv.skill == skill_id and cv.id~=hero_id then
            cv.id = hero_id
            guide_info.dirty = true
            break
        end
    end

    for k,v in ipairs(self.list_guide_items) do
        if skill_id == v:GetSkillId() and hero_id~=v:GetHeroId() then
            local info = {
                id = hero_id,
                skill = skill_id,
            }
            v:UpdateGuideInfo(info)

            break
        end
    end
end

function HeroGuideView:OnClickBtnOneKey()
    local hero_ctrl = game.HeroCtrl.instance
    self:DoSaveGuide()
    hero_ctrl:SendHeroUseGuide(self.cur_guide_idx)
end

function HeroGuideView:OnHeroGuideEdit(name, desc)
    local save_info = self.save_guide_info[self.cur_guide_idx]
    if save_info then
        save_info.name = name
        save_info.desc = desc
        save_info.dirty = true

        self.txt_desc:SetText(save_info.desc)
    end

    self:UpdateTabNamme()
end

function HeroGuideView:UpdateTabNamme()
    for k,v in ipairs(self.list_tab_objs) do
        local info = self.save_guide_info[k]
        if info then
            v:SetText(info.name)
        end
    end
end

function HeroGuideView:OnHeroUseGuide(skill_list, guide_id)
    local save_info = self.save_guide_info[guide_id]
    if save_info then
        game.GameMsgCtrl.instance:PushMsg(config.words[2232])
        
        for k,v in ipairs(self.list_guide_items) do
            for ck,cv in ipairs(skill_list or {}) do
                if cv.id == v:GetSkillId() then
                    if cv.hero == v:GetHeroId() then
                        local info = {
                            id = cv.hero,
                            skill = cv.id,
                        }
                        v:UpdateGuideInfo(info)

                        break
                    end
                end
            end
        end
    end
end

return HeroGuideView
