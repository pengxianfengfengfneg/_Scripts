local FightView = Class(game.BaseView)

local _ui_mgr = N3DClient.UIManager:GetInstance()

function FightView:_init()
	self._package_name = "ui_scene"
    self._com_name = "fight_view"
	self._cache_time = 600
	self._swallow_touch = false
	self._ui_order = game.UIZOrder.UIZOrder_Scene

	self._mask_type = game.UIMaskType.None
	self._view_level = game.UIViewLevel.Keep

	self._layer_name = game.LayerName.UIDefault
end

function FightView:_delete()
	
end

function FightView:OpenViewCallBack()
	self.camera = game.Scene.instance:GetCamera()

	self.blood_pool = {}
	for i=1,6 do
		local item_name = "blood_item" .. i
		self.blood_pool[i] = global.CollectPool.New(function()
			local item = {}
			item.obj = _ui_mgr:CreateObject("ui_scene", item_name)
			item.txt = item.obj:GetChild("txt")
			item.func = function()
				self.blood_pool[i]:Free(item)
			end
			self._layout_root:AddChild(item.obj)
			return item
		end, function(item)
			item.obj:Dispose()
		end, function(item)
			-- item.obj:SetVisible(false)
		end, 0)
	end

	self.skill_pool = global.CollectPool.New(function()
		local item = {}
		item.obj = _ui_mgr:CreateObject("ui_scene", "skill_item")
		item.img = item.obj:GetChild("n2")
		item.func = function()
			self.skill_pool:Free(item)
		end
		self._layout_root:AddChild(item.obj)
		return item
	end, function(item)
		item.obj:Dispose()
	end, function(item)
		-- item.obj:SetVisible(false)
	end, 0)

	self.pet_skill_pool = global.CollectPool.New(function()
		local item = {}
		item.obj = _ui_mgr:CreateObject("ui_scene", "pet_skill_item")
		item.img = item.obj:GetChild("n2")
		item.func = function()
			self.pet_skill_pool:Free(item)
		end
		self._layout_root:AddChild(item.obj)
		return item
	end, function(item)
		item.obj:Dispose()
	end, function(item)
		-- item.obj:SetVisible(false)
	end, 0)
end

function FightView:CloseViewCallBack()
	for i,v in ipairs(self.blood_pool) do
		v:DeleteMe()
	end
	self.blood_pool = nil

	self.skill_pool:DeleteMe()
	self.skill_pool = nil
	self.pet_skill_pool:DeleteMe()
	self.pet_skill_pool = nil
end

-- harm_type: 0:正常 1:闪避 2:中毒 3:暴击 4:回血吸血 6:不显示 7:免疫 8:护盾 9:加血 10:穿刺 11:穿刺暴击 12:护盾治疗 13:反震伤害 14:血量效果 15:珍兽分担伤害
local _blood_cfg = {
	[0] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[9] = true,
	[12] = true,
	[13] = true,
	[14] = true,
	[15] = true,
}
function FightView:PlayBlood(obj, num, harm_type)
	if _blood_cfg[harm_type] then
		if num == 0 then
			return
		end

		if harm_type == 14 then
			if num > 0 then
				harm_type = 9
			else
				harm_type = 0
			end
		end

		local idx
		if obj:IsMainRole() or obj:IsMainRolePet() then
			if harm_type == 9 or harm_type == 12 or harm_type == 4 then
				idx = 4
			else
				idx = 3
			end
		else
			if harm_type == 3 then
				idx = 2
			elseif harm_type == 9 or harm_type == 12 or harm_type == 4 then
				idx = 4
			else
				idx = 1
			end
		end
		if num > 0 then
			self:PlayNumber(obj, "+" .. num, idx)
		else
			self:PlayNumber(obj, tostring(num), idx)
		end
	elseif harm_type == 1 then
		self:PlayNumber(obj, "b", 6)
	elseif harm_type == 7 or harm_type == 8 then
		self:PlayNumber(obj, "y", 6)
	elseif harm_type == 100 then			--宋辽积分
		self:PlayNumber(obj, "+"..num, 1)
	end
end

function FightView:PlayMp(obj, num)
	if num > 0 then
		num = "+" .. num
	end
	self:PlayNumber(obj, num, 5)
end

function FightView:PlaySkill(obj, id, lv)
	local x, y, z = obj.unit_pos.x, obj:GetRealHeight() + obj:GetModelHeight(), obj.unit_pos.y
	x, y = self.camera:WorldToUIPos(self._layout_root, x, y, z)

	local item = self.skill_pool:Create()
	item.img:SetSprite("ui_scene", tostring(id))
	item.obj:SetPosition(x, y)
	item.obj:PlayTransition("t0", item.func)
end

function FightView:PlayPetSkill(obj, id, lv, icon)
	local x, y, z = obj.unit_pos.x, obj:GetRealHeight() + obj:GetModelHeight(), obj.unit_pos.y
	x, y = self.camera:WorldToUIPos(self._layout_root, x, y, z)

	local item = self.pet_skill_pool:Create()
	item.img:SetText(string.format("%s(%d+)", icon, lv))
	item.obj:SetPosition(x, y)
	item.obj:PlayTransition("t0", item.func)
end

-- 1.一般伤害
-- 2.暴击伤害
-- 3.我方受伤伤害
-- 4.加血
-- 5.加蓝
-- 6.特殊状态文字飘字
function FightView:PlayNumber(obj, num, type)
	local x, y, z = obj.unit_pos.x, obj:GetRealHeight() + obj:GetModelHeight(), obj.unit_pos.y
	x, y = self.camera:WorldToUIPos(self._layout_root, x, y, z)

	local item = self.blood_pool[type]:Create()
	item.txt:SetText(num)
	item.obj:SetPosition(x, y)
	item.obj:PlayTransition("t0", item.func)
end

return FightView
