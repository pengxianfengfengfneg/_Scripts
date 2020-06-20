local WeaponSoulCtrl = Class(game.BaseCtrl)

function WeaponSoulCtrl:_init()
    if WeaponSoulCtrl.instance ~= nil then
        error("WeaponSoulCtrl Init Twice!")
    end
    WeaponSoulCtrl.instance = self

    self.weapon_soul_data = require("game/weapon_soul/weapon_soul_data").New()
    self.view = require("game/weapon_soul/weapon_soul_view").New(self)
    self.weapon_soul_change_attr_view = require("game/weapon_soul/weapon_soul_change_attr_view").New(self)
    self.weapon_soul_nh_ten_view = require("game/weapon_soul/weapon_soul_nh_ten_view").New(self)
    self.weapon_soul_skill_preview = require("game/weapon_soul/weapon_soul_skill_preview").New(self)
    self.weapon_soul_showview = require("game/weapon_soul/weapon_soul_showview").New(self)
    self.weapon_soul_jp_attr_view = require("game/weapon_soul/weapon_soul_jp_attr_view").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()
end

function WeaponSoulCtrl:_delete()
	self.weapon_soul_data:DeleteMe()
	self.weapon_soul_data = nil

    self.view:DeleteMe()
    self.view = nil

    self.weapon_soul_change_attr_view:DeleteMe()
    self.weapon_soul_change_attr_view = nil

    self.weapon_soul_nh_ten_view:DeleteMe()
    self.weapon_soul_nh_ten_view = nil

    self.weapon_soul_skill_preview:DeleteMe()
    self.weapon_soul_skill_preview = nil

    self.weapon_soul_showview:DeleteMe()
    self.weapon_soul_showview = nil

    self.weapon_soul_jp_attr_view:DeleteMe()
    self.weapon_soul_jp_attr_view = nil

    WeaponSoulCtrl.instance = nil
end

function WeaponSoulCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(53902, "ScWarriorSoulInfo")
	self:RegisterProtocalCallback(53904, "ScWarriorSoulRefine")
	self:RegisterProtocalCallback(53906, "ScWarriorSoulStarUp")
	self:RegisterProtocalCallback(53908, "ScWarriorSoulConden")
	self:RegisterProtocalCallback(53910, "ScWarriorSoulPartUpdate")
	self:RegisterProtocalCallback(53913, "ScWarriorSoulChangeAvatar")
	self:RegisterProtocalCallback(53914, "ScWarriorSoulRefreshAvatars")
end

function WeaponSoulCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginRoleRet, function(value)
            if value then
                self:CsWarriorSoulInfo()
            end
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function WeaponSoulCtrl:OpenView(tab_index)
	self:CsWarriorSoulInfo()
	self.view:Open(tab_index)
end

function WeaponSoulCtrl:GetData()
	return self.weapon_soul_data
end

function WeaponSoulCtrl:CsWarriorSoulInfo()
	self:SendProtocal(53901,{})
end

function WeaponSoulCtrl:ScWarriorSoulInfo(data)
	self.weapon_soul_data:SetAllData(data)
	self:FireEvent(game.WeaponSoulEvent.RefreshMainUI)
end

--精铸
function WeaponSoulCtrl:CsWarriorSoulRefine()
	self:SendProtocal(53903,{})
end

function WeaponSoulCtrl:ScWarriorSoulRefine(data)
	self.weapon_soul_data:UpdateJzData(data)
	self:FireEvent(game.WeaponSoulEvent.JingZhu)
	self:FireEvent(game.WeaponSoulEvent.RefreshCombat)
end

function WeaponSoulCtrl:CsWarriorSoulStarUp()
	self:SendProtocal(53905,{})
end

function WeaponSoulCtrl:ScWarriorSoulStarUp(data)
	self.weapon_soul_data:UpdateSxData(data)
	self:FireEvent(game.WeaponSoulEvent.ShengXing)
	self:FireEvent(game.WeaponSoulEvent.RefreshCombat)
end

function WeaponSoulCtrl:CsWarriorSoulConden(type_t, batch_t)
	self:SendProtocal(53907,{type = type_t, batch = batch_t})
end

function WeaponSoulCtrl:ScWarriorSoulConden(data)
	self.weapon_soul_data:UpdateNhData(data)

	self:FireEvent(game.WeaponSoulEvent.NingHun, data)
	--批量凝魂
	if next(data.batch_ret) then
		self:OpenNHTenView(data)		
	end
end

function WeaponSoulCtrl:CsWarriorSoulSaveConden(type_t, index_list_t)
	self:SendProtocal(53909,{type = type_t, index_list = index_list_t})
end

function WeaponSoulCtrl:ScWarriorSoulPartUpdate(data)
	self.weapon_soul_data:UpdateSoulData(data)
	self:FireEvent(game.WeaponSoulEvent.RefreshNingHun, data)
	self:FireEvent(game.WeaponSoulEvent.RefreshCombat)
end

function WeaponSoulCtrl:CsWarriorSoulChangeAttr(type_t, cur_attr_id_t, target_attr_id_t)
	self:SendProtocal(53911,{type = type_t, cur_attr_id = cur_attr_id_t, target_attr_id = target_attr_id_t})
end

function WeaponSoulCtrl:CsWarriorSoulChangeAvatar(jp_id)
	self:SendProtocal(53912,{avatar_id = jp_id})
end

function WeaponSoulCtrl:ScWarriorSoulChangeAvatar(data)
	self.weapon_soul_data:UpdateChangeAvatar(data)
	self:FireEvent(game.WeaponSoulEvent.ChangeAvatar)
end

function WeaponSoulCtrl:ScWarriorSoulRefreshAvatars(data)
	self.weapon_soul_data:UpdateAvatar(data)
	self:FireEvent(game.WeaponSoulEvent.RefreshCombat)
end

function WeaponSoulCtrl:OpenChangeAttrView(params)
	if not self.weapon_soul_change_attr_view:IsOpen() then
		self.weapon_soul_change_attr_view:Open(params)
	end
end

--凝魂10次結果
function WeaponSoulCtrl:OpenNHTenView(params)
	if not self.weapon_soul_nh_ten_view:IsOpen() then
		self.weapon_soul_nh_ten_view:Open(params)
	end
end

function WeaponSoulCtrl:GetGpIdList(type)
	return self.weapon_soul_data:GetGpIdList(type)
end

function WeaponSoulCtrl:OpenSkillPreView(params)
	if not self.weapon_soul_skill_preview:IsOpen() then
		self.weapon_soul_skill_preview:Open(params)
	end
end

function WeaponSoulCtrl:CheckRedPoint()

	if self.weapon_soul_data:CanJingZhu() then
		return true
	end

	if self.weapon_soul_data:CanShengXing() then
		return true
	end

	if self.weapon_soul_data:CheckAllNingHunRedPoint() then
		return true
	end

	return false
end

function WeaponSoulCtrl:OpenWeaponSoulShowView()
	if not self.weapon_soul_showview:IsOpen() then
		self.weapon_soul_showview:Open()
	end
end

function WeaponSoulCtrl:OpenWeaponSoulJPAttrView()
	if not self.weapon_soul_jp_attr_view:IsOpen() then
		self.weapon_soul_jp_attr_view:Open()
	end
end

function WeaponSoulCtrl:GetCombatPower()
	local data = self.weapon_soul_data:GetAllData()
	if data then
		return data.combat_power
	end
	return 0
end

game.WeaponSoulCtrl = WeaponSoulCtrl

return WeaponSoulCtrl