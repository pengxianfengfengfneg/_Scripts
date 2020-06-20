proto.RoleLoginCheckReq = {90000,{
        "accname__s",
        "server_id__I",
        "timestamp__I",
        "ticket__s",
        "device__s",
}}

proto.RoleLoginCheckResp = {90001,{
        "res__c",
        "cur_login__L",
        "timestamp__I",
}}

proto.GetRoleListReq = {90002,{
}}

proto.GetRoleListResp = {90003,{
        "role_list__T__info@U|RoleLoginInfo|",
}}

--查询角色名字请求
proto.RoleNameCheckReq = {90004,{
        "name_list__T__name@s##gender@C",
}}

proto.RoleNameCheckResp = {90005,{
        "name_list__T__name@s##gender@C##role_id@L",
}}

--玩家创建角色
proto.RoleCreateReq = {90006,{
        "name__s",      --角色名
        "gender__C",    --性别
        "career__C",    --职业
        "icon__H",      --头像
        "hair__I",      --发型
        "source__s",    --渠道
        "device__s",    --设备id
        "server_id__I", --服id
}}

proto.RoleCreateResp = {90007,{
        "result__C",     --0:成功 1:失败
        "role_id__L",    --角色ID
        "role_name__s",  --角色名字
        "career__C",     --职业
        "gender__C",     --性别
        "icon__H",       --头像
        "hair__I",       --发型
        "reg_time__I",   --注册时间
}}

--选择角色登陆
proto.SelectRoleLogin = {90008,{
        "role_id__L",
        "timestamp__I",
        "ticket__s",
        "device__s",
}}

proto.HeartBeatReq = {90009,{
        "client_time__I",
}}

proto.HeartBeatResp = {90010,{
        "client_time__I",
        "server_time__L",
}}

--角色登陆结果
proto.SelectRoleLoginResp = {90011,{
        "result__C",
}}

--角色重连请求
proto.RoleReloginReq = {90012,{
        "relogin__C",
}}

--删除角色请求
proto.OperRoleReq = {90013,{
        "role_id__L",
        "timestamp__I",
        "ticket__s",
        "device__s",
        "type__C",      -- 1:删除 0:撤销删除
}}

--删除角色结果
proto.OperRoleResp = {90014, {
        "result__C",    --0:成功 1:失败
}}

proto.OperDeleteRole = {90015,{
        "role_id__L",
}}



