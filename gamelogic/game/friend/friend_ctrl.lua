local FriendCtrl = Class(game.BaseCtrl)
local pnt = function(...)
	-- print(...)
end
function FriendCtrl:_init()
	if FriendCtrl.instance ~= nil then
		error("FriendCtrl Init Twice!")
	end
	FriendCtrl.instance = self
	
	self.data = require("game/friend/friend_data").New()
	self.friend_online_mgr = require("game/friend/friend_online_mgr").New()

	self.friend_notice_view = require("game/friend/friend_notice_view").New()

	self:RegisterAllEvents()
	self:RegisterAllProtocal()

	self.show_friend_nick_name = true
	self.show_captain_suggest = true
end

function FriendCtrl:_delete()
	self.data:DeleteMe()
	self.data = nil

	if self.friend_view then
		self.friend_view:DeleteMe()
		self.friend_view = nil
	end

	if self.friend_search_view then
		self.friend_search_view:DeleteMe()
		self.friend_search_view = nil
	end

	if self.friend_invite_view then
		self.friend_invite_view:DeleteMe()
		self.friend_invite_view = nil
	end

	if self.friend_edit_view then
		self.friend_edit_view:DeleteMe()
		self.friend_edit_view = nil
	end

	if self.friend_create_block_view then
		self.friend_create_block_view:DeleteMe()
		self.friend_create_block_view = nil
	end

	if self.add_to_block_view then
		self.add_to_block_view:DeleteMe()
		self.add_to_block_view = nil
	end

	if self.group_create_view then
		self.group_create_view:DeleteMe()
		self.group_create_view = nil
	end
	
	if self.group_search_view then
		self.group_search_view:DeleteMe()
		self.group_search_view = nil
	end

	if self.group_type_search_view then
		self.group_type_search_view:DeleteMe()
		self.group_type_search_view = nil
	end

	if self.friend_group_invite_view then
		self.friend_group_invite_view:DeleteMe()
		self.friend_group_invite_view = nil
	end

	if self.friend_group_info_view then
		self.friend_group_info_view:DeleteMe()
		self.friend_group_info_view = nil
	end

	if self.group_info_edit_view then
		self.group_info_edit_view:DeleteMe()
		self.group_info_edit_view = nil
	end

	if self.friend_setting_view then
		self.friend_setting_view:DeleteMe()
		self.friend_setting_view = nil
	end

	if self.edit_friend_detail_view then
		self.edit_friend_detail_view:DeleteMe()
		self.edit_friend_detail_view = nil
	end

	if self.friend_online_mgr then
		self.friend_online_mgr:DeleteMe()
		self.friend_online_mgr = nil
	end

	if self.group_invite_friend_view then
		self.group_invite_friend_view:DeleteMe()
		self.group_invite_friend_view = nil
	end

	self.friend_notice_view:DeleteMe()

	FriendCtrl.instance = nil
end

function FriendCtrl:GetData()
	return self.data
end

function FriendCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginRoleRet, function(value)
            if value then
                self:CsFriendSysInfo()
            end
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FriendCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(52802, "ScFriendSysInfo")
	self:RegisterProtocalCallback(52803, "ScFriendSysUpdateRoleIdList")
	self:RegisterProtocalCallback(52804, "ScFriendSysUpdateInfoList")
	self:RegisterProtocalCallback(52805, "ScFriendSysUpdateBlock")
	self:RegisterProtocalCallback(52806, "ScFriendSysUpdateGroup")
	self:RegisterProtocalCallback(52807, "ScFriendSysDelRoleInfo")
	self:RegisterProtocalCallback(52808, "ScFriendSysDelBlock")
	self:RegisterProtocalCallback(52809, "ScFriendSysDelGroup")
	self:RegisterProtocalCallback(52811, "ScFriendSysFindNew")
	self:RegisterProtocalCallback(52826, "ScFriendSysFindGroup")
	self:RegisterProtocalCallback(52835, "ScFriendSysInviteInGroup")
	self:RegisterProtocalCallback(52837, "ScFriendSysChatSingle")
	self:RegisterProtocalCallback(52839, "ScFriendSysChatGroup")
	self:RegisterProtocalCallback(52840, "ScFriendSysSetNickName")
	self:RegisterProtocalCallback(52841, "ScFriendSysDelNickName")
	self:RegisterProtocalCallback(52842, "ScFriendOnlineNotice")
end

function FriendCtrl:OpenFriendView()
	if not self.friend_view then
		self.friend_view = require("game/friend/friend_view").New(self)
	end

	self.friend_view:Open()
end

function FriendCtrl:OpenFriendSearchView()
	if not self.friend_search_view then
		self.friend_search_view = require("game/friend/friend_search_view").New(self)
	end

	self.friend_search_view:Open()
end

function FriendCtrl:OpenFriendInviteView()
	if not self.friend_invite_view then
		self.friend_invite_view = require("game/friend/friend_invite_view").New(self)
	end

	self.friend_invite_view:Open()
end

function FriendCtrl:OpenFriendEditView()
	if not self.friend_edit_view then
		self.friend_edit_view = require("game/friend/friend_edit_view").New(self)
	end

	self.friend_edit_view:Open()
end

function FriendCtrl:OpenFriendCreateBlockView()
	if not self.friend_create_block_view then
		self.friend_create_block_view = require("game/friend/friend_create_block_view").New(self)
	end

	self.friend_create_block_view:Open()
end

function FriendCtrl:OpenBlockChangeNameView(block_id, block_name)
	if not self.block_change_name_view then
		self.block_change_name_view = require("game/friend/block_change_name_view").New(self)
	end

	self.block_change_name_view:Open(block_id, block_name)
end

function FriendCtrl:OpenAddToBlockView(role_id_list)
	if not self.add_to_block_view then
		self.add_to_block_view = require("game/friend/add_to_block_view").New(self)
	end

	self.add_to_block_view:Open(role_id_list)
end

function FriendCtrl:OpenCreateGroupView()
	if not self.group_create_view then
		self.group_create_view = require("game/friend/group_create_view").New(self)
	end

	self.group_create_view:Open()
end

function FriendCtrl:OpenGroupSearchView()
	if not self.group_search_view then
		self.group_search_view = require("game/friend/group_search_view").New(self)
	end

	self.group_search_view:Open()
end

function FriendCtrl:OpenGroupTypeSearchView()
	if not self.group_type_search_view then
		self.group_type_search_view = require("game/friend/group_type_search_view").New(self)
	end

	self.group_type_search_view:Open()
end

function FriendCtrl:OpenGroupInviteView(group_info)
	if not self.friend_group_invite_view then
		self.friend_group_invite_view = require("game/friend/friend_group_invite_view").New(self)
	end

	self.friend_group_invite_view:Open(group_info)
end

function FriendCtrl:OpenGroupInfoView(group_info)
	if not self.friend_group_info_view then
		self.friend_group_info_view = require("game/friend/friend_group_info_view").New(self)
	end

	self.friend_group_info_view:Open(group_info)
end

function FriendCtrl:OpenGroupInfoEditView(group_info)
	if not self.group_info_edit_view then
		self.group_info_edit_view = require("game/friend/group_info_edit_view").New(self)
	end

	self.group_info_edit_view:Open(group_info)
end

function FriendCtrl:OpenFriendSettingView()
	if not self.friend_setting_view then
		self.friend_setting_view = require("game/friend/friend_setting_view").New(self)
	end

	self.friend_setting_view:Open()
end

function FriendCtrl:OpenEditFriendDetailView(role_id)
	if not self.edit_friend_detail_view then
		self.edit_friend_detail_view = require("game/friend/edit_friend_detail_view").New(self)
	end

	self.edit_friend_detail_view:Open(role_id)
end

function FriendCtrl:OpenFriendOnlineTipsView(role_id)

	local friend_online_tips_view = require("game/friend/friend_online_tips_view").New(self)

	friend_online_tips_view:Open(role_id)
end

function FriendCtrl:OpenGroupInviteFriendView(group_id)

	if not self.group_invite_friend_view then
		self.group_invite_friend_view = require("game/friend/group_invite_friend_view").New(self)
	end

	self.group_invite_friend_view:Open(group_id)
end

function FriendCtrl:OpenFriendNoticeView(announce)
	self.friend_notice_view:Open(announce)
end

function FriendCtrl:CsFriendSysInfo()
	self:SendProtocal(52801,{})
end

function FriendCtrl:ScFriendSysInfo(data)
	self.data:SetAllData(data)
end

--更新列表id
function FriendCtrl:ScFriendSysUpdateRoleIdList(data)
	self.data:UpdateRoleIdByType(data)
	self:FireEvent(game.FriendEvent.RefreshRoleIdList, data)
end

--更新好友信息
function FriendCtrl:ScFriendSysUpdateInfoList(data)
	self.data:UpdateRoleInfo(data)
end

--更新分组
function FriendCtrl:ScFriendSysUpdateBlock(data)
	self.data:UpdateBlock(data)
	self:FireEvent(game.FriendEvent.RefreshBlockList, data)
end

--更新群组
function FriendCtrl:ScFriendSysUpdateGroup(data)
	self.data:UpdateGroup(data)
	self:FireEvent(game.FriendEvent.RefreshGroupList, data)
end

--移除好友信息
function FriendCtrl:ScFriendSysDelRoleInfo(data)
	self.data:RemoveFriendInfo(data)
end

--移除分组
function FriendCtrl:ScFriendSysDelBlock(data)
	self.data:RemoveBlock(data)
	self:FireEvent(game.FriendEvent.RefreshBlockList, data)
end

--移除群组
function FriendCtrl:ScFriendSysDelGroup(data)
	self.data:RemoveGroup(data)
	self:FireEvent(game.FriendEvent.RemoveGroup, data)
end

--查找好友
function FriendCtrl:CsFriendSysFindNew(name)
	self:SendProtocal(52810, {search_name = name})
end

function FriendCtrl:ScFriendSysFindNew(data)
	self:FireEvent(game.FriendEvent.RefreshSearch, data)
end

--申请添加好友
function FriendCtrl:CsFriendSysApplyAdd(id)
	self:SendProtocal(52812, {role_id = id})
end

--确认添加好友请求
function FriendCtrl:CsFriendSysConfirmAdd(id, con)
	self:SendProtocal(52813, {role_id = id, confirm = con})
end

--备注好友名字
function FriendCtrl:CsFriendSysSetNickName(id, detail)
	self:SendProtocal(52814, {role_id = id, nickname = detail})
end

--删除好友备注名字
function FriendCtrl:CsFriendSysDelNickName(id)
	self:SendProtocal(52815, {role_id = id})
end

--关注好友，如果已经关注过就取消关注
function FriendCtrl:CsFriendSysFocus(id)
	self:SendProtocal(52816, {role_id = id})
end

--拉黑玩家，如果已经拉黑就取消拉黑
function FriendCtrl:CsFriendSysBanRole(id)
	self:SendProtocal(52817, {role_id = id})
end

-- 添加仇人，如果已经结仇就取消仇人关系
function FriendCtrl:CsFriendSysAddEnemy(id)
	self:SendProtocal(52818, {role_id = id})
end

-- 删除好友
function FriendCtrl:CsFriendSysDelFriend(del_roleId_list)
	self:SendProtocal(52820, {del_list = del_roleId_list})
end

-- 新建分组
function FriendCtrl:CsFriendSysCreateBlock(name_t)
	self:SendProtocal(52821, {name = name_t})
end

-- 分组改名
function FriendCtrl:CsFriendSysRenameBlock(id_t, name_t)
	self:SendProtocal(52822, {id = id_t, name = name_t})
end

-- 删除分组
function FriendCtrl:CsFriendSysDelBlock(block_id)
	self:SendProtocal(52823, {id = block_id})
end

--把好友添加到分组
function FriendCtrl:CsFriendSysAdd2Block(block_id, role_id_list_t)
	self:SendProtocal(52824, {id = block_id, role_id_list = role_id_list_t})
end

--查找玩家群组
function FriendCtrl:CsFriendSysFindGroup(keyword_t, type_t)
	self:SendProtocal(52825, {keyword = keyword_t, type = type_t})
end

function FriendCtrl:ScFriendSysFindGroup(data)
	self:FireEvent(game.FriendEvent.RefreshGroupSearch, data)
end

--新建玩家群组
function FriendCtrl:CsFriendSysCreateGroup(type_t, name_t, announce_t)
	self:SendProtocal(52827, {name = name_t, type = type_t, announce = announce_t})
end

--申请进入玩家群组
function FriendCtrl:CsFriendSysApplyInGroup(group_id)
	self:SendProtocal(52828, {id = group_id})
end

--确认申请进入玩家群组
function FriendCtrl:CsFriendSysConfirmInGroup(group_id, role_id_t, con)
	self:SendProtocal(52829, {id = group_id, role_id = role_id_t, confirm = con})
end

--修改玩家群组信息
function FriendCtrl:CsFriendSysChangeGroupInfo(group_id, name_t, announce_t)
	self:SendProtocal(52830, {id = group_id, name = name_t, announce = announce_t})
end

--退出玩家群组
function FriendCtrl:CsFriendSysLeaveGroup(group_id)
	self:SendProtocal(52831, {id = group_id})
end

--删除解散玩家群组
function FriendCtrl:CsFriendSysDismissGroup(group_id)
	self:SendProtocal(52832, {id = group_id})
end

--移除玩家群组成员
function FriendCtrl:CsFriendSysDelGroupMem(group_id, role_id_t)
	self:SendProtocal(52833, {id = group_id, role_id = role_id_t})
end

--邀请好友进入玩家群组
function FriendCtrl:CsFriendSysInviteInGroup(group_id, role_id_t)
	self:SendProtocal(52834, {id = group_id, role_id = role_id_t})
end

--下发邀请好友进入玩家群组提示
function FriendCtrl:ScFriendSysInviteInGroup(data)

	local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], data.msg)
    msg_box:SetOkBtn(function()
        self:CsFriendSysApplyInGroup(data.id)
        msg_box:Close()
        msg_box:DeleteMe()
    end)
    msg_box:SetCancelBtn(function()
        end)
    msg_box:Open()
end

--与单个玩家一对一聊天
function FriendCtrl:CsFriendSysChatSingle(send_t, msg_t)
	self:SendProtocal(52836, {send = send_t, msg = msg_t})
end

function FriendCtrl:ScFriendSysChatSingle(data)
	
end

--在群组里聊天
function FriendCtrl:CsFriendSysChatGroup(group_id, msg_t)
	self:SendProtocal(52838, {id = group_id, msg = msg_t})
end

function FriendCtrl:ScFriendSysChatGroup(data)
	
end

function FriendCtrl:ScFriendSysSetNickName(data)
	self.data:SetFriendNickName(data)
	self:FireEvent(game.FriendEvent.ChangeNickName, data)
end

function FriendCtrl:ScFriendSysDelNickName(data)
	self.data:ReSetFriendNickName(data)
	self:FireEvent(game.FriendEvent.DeleteNickName, data)
end

function FriendCtrl:ScFriendOnlineNotice(data)
	self.friend_online_mgr:Add(data.role_id)
	self.friend_online_mgr:Start()
end

function FriendCtrl:PrintData()
	PrintTable(self.data.all_friend_data)
end

function FriendCtrl:IsJoinedGroup(group_id)
	return self.data:IsJoinedGroup(group_id)
end

function FriendCtrl:IsMyEnemy(role_id)
	return self.data:IsMyEnemy(role_id)
end

function FriendCtrl:IsMyFriend(role_id)
	return self.data:IsMyFriend(role_id)
end

game.FriendCtrl = FriendCtrl

return FriendCtrl