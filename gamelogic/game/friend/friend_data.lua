local FriendData = Class(game.BaseData)

function FriendData:_init()
	self.all_friend_data = {}
	self.search_data = {}
end

local sort_func = function(a, b)
	local ar_id = a.roleId
	local br_id = b.roleId

	local friend_data = game.FriendCtrl.instance:GetData()
	local a_role_info = friend_data:GetRoleInfoById(ar_id)
	local b_role_info = friend_data:GetRoleInfoById(br_id)

	if a_role_info.unit.offline == b_role_info.unit.offline then
		return a_role_info.unit.level > b_role_info.unit.level
	else
		return a_role_info.unit.offline < b_role_info.unit.offline
	end
end

function FriendData:SetAllData(all_data)
	self.all_friend_data = all_data
end

function FriendData:UpdateRoleIdByType(data)
	
	for k, v in pairs(data.update_id_list) do

		local list_type = v.list.type

		--好友列表
		if list_type == 1 then
			self.all_friend_data.friend_list = v.list.new_list
		--黑名单
		elseif list_type == 2 then
			self.all_friend_data.ban_list = v.list.new_list
		--仇人
		elseif list_type == 3 then
			self.all_friend_data.enemy_list = v.list.new_list
			self:FireEvent(game.FriendEvent.RefreshEnemyList)
		--申请
		elseif list_type == 4 then
			self.all_friend_data.apply_list = v.list.new_list
		--关注
		elseif list_type == 5 then
			self.all_friend_data.focus_list = v.list.new_list
		end
	end
end

function FriendData:UpdateRoleInfo(data)

	local update_info_list = data.update_info_list

	for k, v in pairs(update_info_list) do

		local target_role_id = v.unit.id

		local exist = false
		for i, j in pairs(self.all_friend_data.role_info_list) do
			if j.unit.id == target_role_id then
				j.unit.vip = v.unit.vip
				j.unit.name = v.unit.name
				j.unit.level = v.unit.level
				j.unit.fight = v.unit.fight
				j.unit.offline = v.unit.offline
				j.unit.gender = v.unit.gender
				j.unit.career = v.unit.career
				j.unit.team_id = v.unit.team_id
				j.unit.team_num = v.unit.team_num
				j.unit.guild = v.unit.guild
				j.unit.guild_name = v.unit.guild_name
				j.unit.scene = v.unit.scene
				j.unit.stat = v.unit.stat
				exist = true
				break
			end
		end

		if not exist then
			table.insert(self.all_friend_data.role_info_list, v)
		end
	end

end

function FriendData:UpdateBlock(data)

	for _, new_block in pairs(data.new_blocks) do

		local exist = false
		for k, v in pairs(self.all_friend_data.block_list) do
			if v.block.id == new_block.block.id then
				v.block = new_block.block
				exist = true
				break
			end
		end

		if not exist then
			local t = {}
			t.block = new_block.block
			table.insert(self.all_friend_data.block_list, t)
		end
	end
end

function FriendData:UpdateGroup(data)

	local exist = false

	for k, v in pairs(self.all_friend_data.group_list) do
		if v.group.id == data.new_group.id then
			v.group = data.new_group
			exist = true
			break
		end
	end

	if not exist then
		local t = {}
		t.group = data.new_group
		table.insert(self.all_friend_data.group_list, t)
	end
end

--删除好友信息
function FriendData:RemoveFriendInfo(data)

	for k, v in pairs(data.del_list) do

		local target_role_id = v.id

		for i, j in pairs(self.all_friend_data.role_info_list) do
			if j.unit.id == target_role_id then
				self.all_friend_data.role_info_list[i] = nil
				break
			end
		end
	end
end

function FriendData:RemoveBlock(data)
	
	for k, v in pairs(self.all_friend_data.block_list) do
		if v.block.id == data.id then
			table.remove(self.all_friend_data.block_list, k)
			break
		end
	end

end

function FriendData:RemoveGroup(data)
	
	for k, v in pairs(self.all_friend_data.group_list) do
		if v.group.id == data.id then
			table.remove(self.all_friend_data.group_list, k)
			break
		end
	end
end

function FriendData:GetBlockList()
	return self.all_friend_data.block_list
end

function FriendData:GetGroupList()
	return self.all_friend_data.group_list
end

function FriendData:GetGroupData(group_id)
	
	for k, v in pairs(self.all_friend_data.group_list) do
		if v.group.id == group_id then
			return v.group
		end
	end
end

-- index为空则不插入角色信息
-- oper_type 0是系统创建  1是玩家创建
function FriendData:GetContactsData(index, oper_type)

	table.sort(self.all_friend_data.friend_list, sort_func)
	table.sort(self.all_friend_data.ban_list, sort_func)
	table.sort(self.all_friend_data.focus_list, sort_func)
	table.sort(self.all_friend_data.enemy_list, sort_func)

	local data_list = {}

	local block_num = #self.all_friend_data.block_list

	--系统创建大类(type_index 1:全部好友  2:好友关注 3:黑名单 4:仇人)
	for i = 1, 4 do
		local t = {}
		t.type = 1
		t.oper_type = 0
		t.type_index = i
		table.insert(data_list, t)
	end

	--玩家创建大类(type_index 分组索引)
	for j = 1, block_num do
		local t = {}
		t.type = 1
		t.oper_type = 1
		t.type_index = j
		table.insert(data_list, (j+2), t)
	end

	--插入自建分组角色信息
	if index and oper_type == 1 then

		local block_data = self.all_friend_data.block_list[index]
		local mem_list = block_data.block.mem_list

		local insert_pos = index + 3
		for k, v in ipairs(mem_list) do
			local t = {}
			t.type = 2
			t.role_id = v.roleId
			t.block_id = block_data.block.id
			table.insert(data_list, insert_pos, t)
			insert_pos = insert_pos + 1
		end

		return data_list
	--插入系统分组角色信息
	elseif index and oper_type == 0 then

		local insert_pos = 0
		for k, v in pairs(data_list) do
			if v.oper_type == 0 and v.type_index == index then
				insert_pos = k + 1
				break
			end
		end

		--全部好友
		if index == 1 then
			for k, v in ipairs(self.all_friend_data.friend_list) do
				local t = {}
				t.type = 2
				t.role_id = v.roleId
				t.type_index = 1
				table.insert(data_list, insert_pos, t)
				insert_pos = insert_pos + 1
			end
		--关注好友
		elseif index == 2 then
			for k, v in ipairs(self.all_friend_data.focus_list) do
				local t = {}
				t.type = 2
				t.role_id = v.roleId
				t.type_index = 2
				table.insert(data_list, insert_pos, t)
				insert_pos = insert_pos + 1
			end
		--黑名单
		elseif index == 3 then
			for k, v in ipairs(self.all_friend_data.ban_list) do
				local t = {}
				t.type = 2
				t.role_id = v.roleId
				t.type_index = 3
				table.insert(data_list, insert_pos, t)
				insert_pos = insert_pos + 1
			end
		--仇人
		elseif index == 4 then
			for k, v in ipairs(self.all_friend_data.enemy_list) do
				local t = {}
				t.type = 2
				t.role_id = v.roleId
				t.type_index = 4
				table.insert(data_list, insert_pos, t)
				insert_pos = insert_pos + 1
			end
		end

		return data_list
	else
		return data_list
	end
end

function FriendData:GetApplyList()
	return self.all_friend_data.apply_list
end

function FriendData:GetRoleInfoById(role_id)

	local  role_info

	--self.all_friend_data.role_info_list 没有玩家自己的信息,单独处理
	local my_role_vo = game.Scene.instance:GetMainRoleVo()
	if role_id == my_role_vo.role_id then

		role_info = {}
		role_info.unit = {
			gender = my_role_vo.gender,
			career = my_role_vo.career,
			level = my_role_vo.level,
			name = my_role_vo.name,
			offline = 0,
			id = my_role_vo.role_id,
			icon = my_role_vo.icon,
			frame = my_role_vo.frame,
		}

		return role_info
	end

	for k,v in pairs(self.all_friend_data.role_info_list) do
		if v.unit.id == role_id then
			role_info = v
			break
		end
	end

	return role_info
end

--0是全部分组
function FriendData:GetBlockOnlineNum(block_index, oper_type)

	local total_num = 0
	local online_num = 0

	if oper_type == 0 then
		--全部好友
		if block_index == 1 then
			for k, v in pairs(self.all_friend_data.friend_list) do

				local role_id = v.roleId
				local role_info = self:GetRoleInfoById(role_id)

				if role_info.unit.offline == 0 then
					online_num = online_num + 1
				end

				total_num = total_num + 1
			end
		elseif block_index == 2 then
			for k, v in pairs(self.all_friend_data.focus_list) do

				local role_id = v.roleId
				local role_info = self:GetRoleInfoById(role_id)
				if role_info.unit.offline == 0 then
					online_num = online_num + 1
				end

				total_num = total_num + 1
			end
		elseif block_index == 3 then
			for k, v in pairs(self.all_friend_data.ban_list) do

				local role_id = v.roleId
				local role_info = self:GetRoleInfoById(role_id)
				if role_info.unit.offline == 0 then
					online_num = online_num + 1
				end

				total_num = total_num + 1
			end
		elseif block_index == 4 then
			for k, v in pairs(self.all_friend_data.enemy_list) do

				local role_id = v.roleId
				local role_info = self:GetRoleInfoById(role_id)
				if role_info.unit.offline == 0 then
					online_num = online_num + 1
				end

				total_num = total_num + 1
			end
		end
	--分组好友
	else

		local block_data = self.all_friend_data.block_list[block_index]
		local mem_list = block_data.block.mem_list

		for k, v in pairs(mem_list) do

			local role_id = v.roleId
			local role_info = self:GetRoleInfoById(role_id)

			if role_info.unit.offline == 0 then
				online_num = online_num + 1
			end

			total_num = total_num + 1
		end
	end

	return total_num, online_num
end

function FriendData:GetFriendList()
	return self.all_friend_data.friend_list
end

function FriendData:GetBlockName(block_index, oper_type)

	if oper_type == 0 then
		if block_index == 1 then
			return config.words[1739]
		elseif block_index == 2 then
			return config.words[1740]
		elseif block_index == 3 then
			return config.words[1741]
		elseif block_index == 4 then
			return config.words[1742]
		end
	else
		local name = self.all_friend_data.block_list[block_index].block.name
		return name
	end
end

function FriendData:GetBlockNameByRoleId(role_id)

	local block_name

	for k, v in pairs(self.all_friend_data.block_list) do

		for i, j in pairs(v.block.mem_list) do
			if j.roleId == role_id then
				block_name = v.block.name
				break
			end
		end
	end

	return block_name
end

function FriendData:GetBlockIdByRoleId(role_id)

	local block_name

	for k, v in pairs(self.all_friend_data.block_list) do

		for i, j in pairs(v.block.mem_list) do
			if j.roleId == role_id then
				block_name = v.block.id
				break
			end
		end
	end

	return block_name
end

function FriendData:GetGroupOnlineNum(group_id)

	local total_num = 5
	local online_num = 0
	local my_role_id = game.Scene.instance:GetMainRoleID()

	for k, v in pairs(self.all_friend_data.group_list) do

		if v.group.id == group_id then
			for i, j in pairs(v.group.mem_list) do
				online_num = online_num + 1
			end
		end
	end

	if group_id < 10 then
		total_num = config.sys_config["friend_user_group_num_limit"].value
	end

	return total_num, online_num
end

function FriendData:SetFriendNickName(data)

	for k, v in pairs(self.all_friend_data.nick_names) do
		if v.roleId == data.role_id then
			v.name = data.nickname
			break
		end
	end

	local t = {}
	t.roleId = data.role_id
	t.name = data.nickname

	table.insert(self.all_friend_data.nick_names, t)
end

function FriendData:ReSetFriendNickName(data)

	for k, v in pairs(self.all_friend_data.nick_names) do
		if v.roleId == data.role_id then
			v.name = ""
			break
		end
	end
end

function FriendData:GetFriendNickName(role_id)
	
	for k, v in pairs(self.all_friend_data.nick_names) do
		if v.roleId == role_id then
			return v.name
		end
	end

	return ""
end

function FriendData:IsJoinedGroup(group_id)
	local group_list = self:GetGroupList()
	for _,v in ipairs(group_list) do
		if v.group.id == group_id then
			return true
		end
	end
	return false
end

function FriendData:CheckRedPoint()

	local flag = false

	if self.all_friend_data and #self.all_friend_data.apply_list > 0 then
		flag = true
	end

	return flag
end

function FriendData:IsMyFocus(role_id)

	local is_true = false

	for k, v in pairs(self.all_friend_data.focus_list) do
		if v.roleId == role_id then
			is_true = true
			break
		end
	end

	return is_true
end

function FriendData:IsMyEnemy(role_id)

	local flag = false

	if self.all_friend_data then
		for k, v in pairs(self.all_friend_data.enemy_list) do
			if v.roleId == role_id then
				flag = true
				break
			end
		end
	end

	return flag
end

--可以邀请入群组的好友列表
function FriendData:GetGroupInviteList(group_id)

	local role_list = {}

	local group_data = self:GetGroupData(group_id)

	for k, v in pairs(self.all_friend_data.friend_list) do

		local role_id = v.roleId
		local role_info = self:GetRoleInfoById(role_id)
		if role_info.unit.offline == 0 and role_info.unit.level >= 30 then

			local in_group = false
			for k, v in pairs(group_data.mem_list) do
				if role_id == v.roleId then
					in_group = true
					break
				end
			end

			if not in_group then
				table.insert(role_list, role_id)
			end
		end
	end

	return role_list
end

function FriendData:IsMyFriend(role_id)

	local flag = false

	if self.all_friend_data then
		for k, v in pairs(self.all_friend_data.friend_list) do
			if v.roleId == role_id then
				flag = true
				break
			end
		end
	end

	return flag
end

function FriendData:AddMsg()
	global.EventMgr:Fire(game.MsgNoticeEvent.AddMsgNotice, game.MsgNoticeId.AddFriend)
end

function FriendData:CheckContactRedpoint()

	local is_red = false

	if self.all_friend_data then
		if #self.all_friend_data.apply_list > 0 then
			is_red = true
		end
	end

	return is_red
end

return FriendData