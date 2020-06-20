local JumpState = Class()

local _send_dist = 5
local _logic_tile_size = game.LogicTileSize

local table_insert = table.insert
local table_remove = table.remove
local math_min = math.min
local math_cos = math.cos

function JumpState:_init(obj)
	self.obj = obj
	self.start_pos = cc.vec2(0, 0)
	self.target_pos = cc.vec2(0, 0)
	self.target_logic_pos = cc.vec2(0, 0)
	self.dir = cc.vec2(0, 0)
	self.last_send_pos = cc.vec2(0, 0)
end

function JumpState:_delete()

end

function JumpState:AddOnePoint(x,y,h)
	table_insert(self.jump_point_list, {x=x,y=y,h=h})
end

function JumpState:GetHeight()
	
end

function JumpState:AddOneJump(point, next_point)
	table_insert(self.jump_list, {point, next_point})
end

function JumpState:PopOneJump()
	local jump = self.jump_list[1]
	table_remove(self.jump_list,1)
	return jump
end

function JumpState:StateEnter(x, y, fx, fy, mid_list)
	self.is_jump_finish = false

	self.obj:ShowShadow(false)
	
	self.is_jump_show = self:CheckJumpShowFly(x, y, fx, fy, mid_list)
	if self.is_jump_show then
		--self.obj:SetLogicPos(x, y)
		return
	end

	self.obj:SetCalcMapHeightFunc(function()
		local per = self.cur_x/self.dist
		local height = (self.start_height + self.delta_height*per)
		return height
	end)

	-- 下坐骑
	self.obj:SetMountState(0)

	if self.obj:IsClientObj() then
		self.obj:SendJumpReq(x, y, fx, fy)
	end

	self.jump_point_list = {}
	local f_h = game.Scene.instance:GetHeightForLogicPos(fx, fy)
	local t_h = game.Scene.instance:GetHeightForLogicPos(x, y)
	self:AddOnePoint(fx,fy, f_h)

	for _,v in ipairs(mid_list or {}) do
		local lx,ly = game.UnitToLogicPos(v.x,v.z)
		self:AddOnePoint(lx,ly,v.y)
	end

	self:AddOnePoint(x,y,t_h)

	self.jump_list = {}
	for i=1,#self.jump_point_list do
		local next_point = self.jump_point_list[i+1]
		if next_point then
			local point = self.jump_point_list[i]

			self:AddOneJump(point, next_point)
		end
	end

	-- 禁止移动
	self.obj.mute_move = self.obj.mute_move + 1

	self:StartOneJump()
end

function JumpState:StartOneJump()
	local jump = self:PopOneJump()
	if not jump then
		return false
	end

	global.AudioMgr:PlaySound("qt009")

	local from_point = jump[1]
	local to_point = jump[2]

	self.target_logic_pos.x, self.target_logic_pos.y = to_point.x, to_point.y
	self.start_pos.x, self.start_pos.y = game.LogicToUnitPos(from_point.x, from_point.y)
	self.target_pos.x, self.target_pos.y = game.LogicToUnitPos(to_point.x, to_point.y)

	self.start_height = from_point.h
	self.target_height = to_point.h

	self.delta_height = self.target_height - self.start_height
	self.cur_height = 0
	self.jump_height = 0--math.abs(self.target_height - self.start_height)-6.8
	self.is_jump_up = self.target_height>=self.start_height

	local delta = cc.pSub_static(self.target_pos, self.start_pos)
	self.dist = cc.pGetLength(delta)
	self.dir.x, self.dir.y = delta.x / self.dist, delta.y / self.dist
	self.cur_dist = 0

	self.cur_x = 0
	self.cur_y = 0

	self._g = -9.8*0.75
	self.time_counter = 0
	self.speed_x = (self.dist/2.5) --15--self.obj:GetSpeed()*1.5

	local a = self._g
	local s = self.jump_height
	local t = self.dist/self.speed_x
	local v0 = (s-0.5*a*t*t)/t

	self.speed_y = v0

	self.jump_time = t

	self.obj:SetDir(self.dir.x, self.dir.y)

	local animSeq = {
		{game.ObjAnimName.Jump1,false,1.6},
		{game.ObjAnimName.Jump2,true},
		{game.ObjAnimName.Jump1,false,0.9},
	}

	local no_jumping_time = 0
	self.anim_list = {}
	for _,v in ipairs(animSeq) do
		local speed = v[3] or 1
		local anim = {
			name = v[1],
			time = (self.obj:GetAnimTime(v[1])-0.0)/speed,
			jumping = v[2],
			speed = speed,
		}

		if not anim.jumping then
			no_jumping_time = no_jumping_time + (anim.time)
		end
		table_insert(self.anim_list, anim)
	end

	local jumping_time = self.jump_time - no_jumping_time
	for _,v in ipairs(self.anim_list) do
		if v.jumping then
			v.time = jumping_time
			break
		end
	end

	return true
end

--[[
	float quadEaseInOut(float time)
	{
	    time = time*2;
	    if (time < 1)
	        return 0.5f * time * time;
	    --time;
	    return -0.5f * (time * (time - 2) - 1);
	}
]]

function JumpState:CalcTween(factor)
	-- factor = factor * 2
	-- if factor < 1 then
	-- 	return 0.5*factor*factor
	-- end

	-- factor = factor - 1
	-- return -0.5*(factor*(factor-2)-1)

	factor = factor * 2
	if factor < 1 then
		return 0.5*factor*factor*factor
	end

	factor = factor - 2
	return 0.5*(factor*factor*factor+2)

	-- factor = factor * 2
	-- if factor < 1 then
	-- 	return 0.5*factor*factor*factor*factor
	-- end

	-- factor = factor - 2
	-- return -0.5*(factor*factor*factor*factor-2)
end

function JumpState:StateUpdate(now_time, elapse_time)	
	if self.is_jump_show then
		if game.JumpCtrl.instance:Update(now_time, elapse_time) then
			self.is_jump_finish = true
			self.obj:DoIdle()
		end
		return
	end

	if not self.idle_time then
		self.time_counter = self.time_counter + elapse_time 
		if self.time_counter < 0 then
			return
		end

		local factor = math_min(self.time_counter/self.jump_time,1)
		local sin = 1-math_cos(factor*math.pi*0.5)
		local sin = self:CalcTween(factor)
		local time = self.time_counter * sin 
		self.cur_x = self.speed_x * time 

		self.cur_y = self.speed_y*self.time_counter + self._g*time*time*0.5

		if self.cur_x > self.dist then
			self.cur_x = self.dist
			--self.obj:SetCalcMapHeightFunc(nil)
		end

		if self.time_counter < self.jump_time then
			self.obj:SetUnitPos(self.start_pos.x + self.dir.x * self.cur_x, self.start_pos.y + self.dir.y * self.cur_x)
			self.obj:SetHeight(self.cur_y)

			for _,v in ipairs(self.anim_list) do
				if v.time > 0 then
					v.time = v.time - elapse_time
					if not v.is_play then
						v.is_play = true
						self.obj:PlayAnim(v.name, v.speed)
					end
					break
				end
			end
		else
			if self:StartOneJump() then
				self.obj:PlayAnim(game.ObjAnimName.Idle, 1)
				self.time_counter = -0.05
			else
				self.obj:SetUnitPos(self.start_pos.x + self.dir.x * self.cur_x, self.start_pos.y + self.dir.y * self.cur_x)

				if self.obj.logic_pos.x ~= self.target_logic_pos.x or self.obj.logic_pos.y ~= self.target_logic_pos.y then
					self.obj:SetLogicPos(self.target_logic_pos.x, self.target_logic_pos.y)
				end

				self.obj:SetHeight(0)
				self.obj:SetCalcMapHeightFunc(nil)

				self.idle_time = now_time + 0.1
			end
		end
	else
		if now_time >= self.idle_time then
			self.idle_time = nil
			self.obj:DoIdle()
		end
	end
end

function JumpState:StateQuit(next_state)
	self.obj:ShowShadow(true)

	if self.is_jump_show then

		return
	end

	self.obj:SetCalcMapHeightFunc(nil)

    if self.obj:IsClientObj() then
		if next_state ~= game.ObjState.Jump then
			if self.obj.logic_pos.x ~= self.target_logic_pos.x or self.obj.logic_pos.y ~= self.target_logic_pos.y then
				local x, y = self.obj:GetLogicPosXY()
				--self.obj:SendJumpReq(x, y, 7)
			end
		end
	else
		if next_state ~= game.ObjState.Jump then
			self.obj:SetLogicPos(self.target_logic_pos.x, self.target_logic_pos.y)
		end
	end

	self.obj:SetHeight(0)

	self.idle_time = nil

	-- 解除禁止移动
	self.obj.mute_move = self.obj.mute_move - 1

	self.is_jump_finish = true
end

function JumpState:IsDone()
	return self.is_jump_finish
end

function JumpState:CheckJumpShowFly(x, y, fx, fy, mid_list)
	local scene_cfg = self.obj:GetScene():GetSceneConfig()
	local jump_list = scene_cfg.jump_list
	local show_jump_idx = nil
	for k,v in ipairs(jump_list) do
		local from_x,from_y = game.UnitToLogicPos(v.from.x, v.from.z)
		if from_x==fx and from_y==fy then
			local to_x,to_y = game.UnitToLogicPos(v.to.x, v.to.z)
			if to_x==x and to_y==y then
				show_jump_idx = k
				break
			end
		end
	end

	if show_jump_idx then
		local uid = self.obj:GetUniqueId()
		return game.JumpCtrl.instance:DoJumpShow(scene_cfg.scene_id, show_jump_idx, {
				id = uid,
				fx = fx,
				fy = fy,
				x = x,
				y = y,
			})
	end
	return false
end

return JumpState
