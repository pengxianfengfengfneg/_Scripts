local BossIconItem = Class(game.UITemplate)

local config_world_boss_level = config.world_boss_level

function BossIconItem:_init(idx, boss_id, born_pos)
	self.idx = idx
    self.boss_id = boss_id
    self.born_pos = born_pos
end

function BossIconItem:OpenViewCallBack()
	self:Init()
end

function BossIconItem:CloseViewCallBack()
    
end

function BossIconItem:Init()
	self.txt_content = self._layout_objs["txt_content"]	

	self.group_name = self._layout_objs["group_name"]	

	self.icon_loader = self._layout_objs["icon_loader"]	
	self.flag_loader = self._layout_objs["flag_loader"]	
	
	self.txt_name = self._layout_objs["txt_name"]	
	self.img_kill = self._layout_objs["img_kill"]	
	self.img_select = self._layout_objs["img_select"]	
	self.img_hp = self._layout_objs["img_hp"]

	self:InitInfo()
end

function BossIconItem:InitInfo()
	if not self.boss_id then return end

	local boss_cfg = config.monster[self.boss_id]
	self.boss_name = boss_cfg.name
	self.boss_lv = boss_cfg.level

	local flag_res = "fb2_13"	
	self.flag_loader:SetUrl("ui_common", flag_res)

	self.txt_name:SetText(config.words[4457])

	self.icon_loader:SetUrl("ui_headicon", boss_cfg.model_id)

	self.is_assign = false

	self.boss_hp_lmt = 100
	self.cur_boss_hurt = self.boss_hp_lmt

	self:SetGray(true)
end

function BossIconItem:UpdateData(data)
	self.is_assign = true

	self.boss_hp_lmt = data.boss_hp_lmt
	self.cur_boss_hurt = data.total_harm

	self.rank_list = data.rank_list

	self:SetGray(false)

	self:SetHpFillAmount(self:GetHpPercent()*0.01)

	self:SetBossId(data.boss_id)

	self:UpdateBossState()
end

function BossIconItem:SetBossId(boss_id)
	self.boss_id = boss_id
	local boss_cfg = config.monster[boss_id]
	self.boss_name = boss_cfg.name
	self.boss_lv = boss_cfg.level

	if not self.flag_loader then
		return
	end

	local flag_res = "fb2_12"
	if self:IsRealyBoss() then
		flag_res = "fb2_11"
	end

	if not self.is_assign then
		flag_res = "fb2_13"
	end

	self.flag_loader:SetUrl("ui_common", flag_res)

	self.txt_name:SetText(self.boss_name)
end

function BossIconItem:GetBossId()
	return self.boss_id
end

function BossIconItem:SetAssign(val)
	self.is_assign = val
end

function BossIconItem:GetAssign()
	return self.is_assign
end

function BossIconItem:HideName()
	self.group_name:SetVisible(false)
end

function BossIconItem:IsRealyBoss()
	local boss_id = self:GetBossId()
	local cfg = config_world_boss_level[boss_id]
	local awrad_cfg = cfg[1] or {}

	return awrad_cfg.reward_show[1]
end

function BossIconItem:GetBossName()
	return self.boss_name
end

function BossIconItem:GetBossLv()
	return self.boss_lv
end

function BossIconItem:GetHpPercent()
	local hurt = self.cur_boss_hurt or 0
	local hp_lmt = self.boss_hp_lmt or 1

	local percent = math.floor((hp_lmt-hurt)/hp_lmt*100 * 100)
	return (percent*0.01)
end

function BossIconItem:GetTopGuildData()
	local info = self.rank_list or {}
	return info[1]
end

function BossIconItem:UpdateRealy()
	local flag_res = "fb2_12"
	if self:IsRealyBoss() then
		flag_res = "fb2_11"
	end
	self.flag_loader:SetUrl("ui_common", flag_res)
end

function BossIconItem:GetBornPos()
	return self.born_pos
end

function BossIconItem:SetBornPos(pos)
	self.born_pos = pos
end

function BossIconItem:IsInBornPos(x, y)
	return (math.abs(self.born_pos[1]-x)<=1 and math.abs(self.born_pos[2]-y)<=1)
end

function BossIconItem:GetIdx()
	return self.idx
end

function BossIconItem:SetIdx(idx)
	self.idx = idx
end

function BossIconItem:IsDead()
	if not self.cur_boss_hurt or not self.is_assign then
		return false
	end
	return (self.cur_boss_hurt>=self.boss_hp_lmt)
end

function BossIconItem:SetDeadFlag(val)
	self.img_kill:SetVisible(val)
end

function BossIconItem:UpdateBossState()
	self:SetDeadFlag(self:IsDead())
end

function BossIconItem:SetSelect(val)
	if self.is_selected == val then
		return
	end

	self.is_selected = val
	self.img_select:SetVisible(val)
end

function BossIconItem:ResetItem()
	self.cur_boss_hurt = 100
	self.boss_hp_lmt = self.cur_boss_hurt

	self:SetAssign(false)
	self:SetBossId(self:GetBossId())
	self:SetDeadFlag(false)

	self.txt_name:SetText("")
	self:SetGray(true)

	self.rank_list = nil
	self.is_selected = nil
end

function BossIconItem:GetRankList()
	return self.rank_list
end

function BossIconItem:GetBossHpLmt()
	return self.boss_hp_lmt
end

function BossIconItem:IsGray()
	return self.is_gray
end

function BossIconItem:SetGray(val)
	if self.is_gray == val then
		return
	end
	self.is_gray = val
	self.icon_loader:SetGray(val)
	self.img_hp:SetVisible(not val)
end

function BossIconItem:SetHpFillAmount(val)
	self.img_hp:SetFillAmount(val)
end

return BossIconItem
