proto.CsFriendSysInfo = {52801,{
}}

proto.ScFriendSysInfo = {52802,{
        "apply_list__T__roleId@L",
        "friend_list__T__roleId@L",
        "ban_list__T__roleId@L",
        "enemy_list__T__roleId@L",
        "focus_list__T__roleId@L",
        "block_list__T__block@U|FriendBlock|",
        "group_list__T__group@U|FriendGroup|",
        "role_info_list__T__unit@U|FriendInfo|",
        "nick_names__T__roleId@L##name@s",
}}

proto.ScFriendSysUpdateRoleIdList = {52803,{
        "update_id_list__T__list@U|FriendUpdateList|",
}}

proto.ScFriendSysUpdateInfoList = {52804,{
        "update_info_list__T__unit@U|FriendInfo|",
}}

proto.ScFriendSysUpdateBlock = {52805,{
        "new_blocks__T__block@U|FriendBlock|",
}}

proto.ScFriendSysUpdateGroup = {52806,{
        "new_group__U|FriendGroup|",
}}

proto.ScFriendSysDelRoleInfo = {52807,{
        "del_list__T__id@L",
}}

proto.ScFriendSysDelBlock = {52808,{
        "id__C",
}}

proto.ScFriendSysDelGroup = {52809,{
        "id__L",
}}

proto.CsFriendSysFindNew = {52810,{
        "search_name__s",
}}

proto.ScFriendSysFindNew = {52811,{
        "role_info_list__T__unit@U|FriendInfo|",
}}

proto.CsFriendSysApplyAdd = {52812,{
        "role_id__L",
}}

proto.CsFriendSysConfirmAdd = {52813,{
        "role_id__L",
        "confirm__C",
}}

proto.CsFriendSysSetNickName = {52814,{
        "role_id__L",
        "nickname__s",
}}

proto.CsFriendSysDelNickName = {52815,{
        "role_id__L",
}}

proto.CsFriendSysFocus = {52816,{
        "role_id__L",
}}

proto.CsFriendSysBanRole = {52817,{
        "role_id__L",
}}

proto.CsFriendSysAddEnemy = {52818,{
        "role_id__L",
}}

proto.CsFriendSysDelFriend = {52820,{
        "del_list__T__role_id@L",
}}

proto.CsFriendSysCreateBlock = {52821,{
        "name__s",
}}

proto.CsFriendSysRenameBlock = {52822,{
        "id__C",
        "name__s",
}}

proto.CsFriendSysDelBlock = {52823,{
        "id__C",
}}

proto.CsFriendSysAdd2Block = {52824,{
        "id__C",
        "role_id_list__T__id@L##op@C",
}}

proto.CsFriendSysFindGroup = {52825,{
        "keyword__s",
        "type__C",
}}

proto.ScFriendSysFindGroup = {52826,{
        "group_list__T__group@U|FriendGroupSimple|",
}}

proto.CsFriendSysCreateGroup = {52827,{
        "type__C",
        "name__s",
        "announce__s",
}}

proto.CsFriendSysApplyInGroup = {52828,{
        "id__L",
}}

proto.CsFriendSysConfirmInGroup = {52829,{
        "id__L",
        "role_id__L",
        "confirm__C",
}}

proto.CsFriendSysChangeGroupInfo = {52830,{
        "id__L",
        "name__s",
        "announce__s",
}}

proto.CsFriendSysLeaveGroup = {52831,{
        "id__L",
}}

proto.CsFriendSysDismissGroup = {52832,{
        "id__L",
}}

proto.CsFriendSysDelGroupMem = {52833,{
        "id__L",
        "role_id__L",
}}

proto.CsFriendSysInviteInGroup = {52834,{
        "id__L",
        "role_id__L",
}}

proto.ScFriendSysInviteInGroup = {52835,{
        "id__L",
        "msg__s",
}}

proto.ScFriendSysSetNickName = {52840,{
        "role_id__L",
        "nickname__s",
}}

proto.ScFriendSysDelNickName = {52841,{
        "role_id__L",
}}

proto.ScFriendOnlineNotice = {52842,{
        "role_id__L",
}}

