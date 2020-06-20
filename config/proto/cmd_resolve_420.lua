proto.CsTeamGetInfo = {42001,{
}}

proto.ScTeamGetInfo = {42002,{
        "team__U|CltTeam|",
}}

proto.CsTeamGetNearby = {42003,{
}}

proto.ScTeamGetNearby = {42004,{
        "teams__T__team@U|CltTeamBrief|",
}}

proto.CsTeamTargetList = {42005,{
        "target__H",
}}

proto.ScTeamTargetList = {42006,{
        "target__H",
        "teams__T__team@U|CltTeamBrief|",
}}

proto.CsTeamCreate = {42007,{
        "target__H",
}}

proto.ScTeamCreate = {42008,{
        "team__U|CltTeam|",
}}

proto.CsTeamApplyList = {42009,{
}}

proto.ScTeamApplyList = {42010,{
        "roles__T__id@L##name@s##level@H##career@C",
}}

proto.CsTeamMatch = {42011,{
        "target__H",
}}

proto.ScTeamMatch = {42012,{
        "target__H",
}}

proto.CsTeamApplyFor = {42013,{
        "team_id__L",
}}

proto.ScTeamApplyFor = {42014,{
        "team_id__L",
}}

proto.CsTeamAcceptApply = {42015,{
        "role_id__L",
        "accept__C",
}}

proto.ScTeamAcceptApply = {42016,{
        "role_id__L",
        "accept__C",
}}

proto.ScTeamNotifyApply = {42017,{
        "role_id__L",
        "role_name__s",
        "level__H",
        "career__C",
}}

proto.ScTeamApplyReject = {42018,{
        "team_id__L",
}}

proto.ScTeamNewMember = {42019,{
        "member__U|CltTeamMember|",
}}

proto.ScTeamJoinNew = {42020,{
        "team__U|CltTeam|",
}}

proto.CsTeamInviteJoin = {42021,{
        "target__L",
}}

proto.ScTeamInviteJoin = {42022,{
        "target__L",
}}

proto.CsTeamAcceptInvite = {42023,{
        "team_id__L",
        "role_id__L",
        "accept__C",
}}

proto.ScTeamAcceptInvite = {42024,{
        "team_id__L",
        "role_id__L",
        "accept__C",
}}

proto.ScTeamNewInvite = {42025,{
        "team_id__L",
        "role_id__L",
        "name__s",
}}

proto.ScTeamInviteReject = {42026,{
        "role_id__L",
        "name__s",
}}

proto.CsTeamLeave = {42027,{
}}

proto.ScTeamLeave = {42028,{
}}

proto.CsTeamKickOut = {42029,{
        "target__L",
}}

proto.ScTeamKickOut = {42030,{
        "target__L",
}}

proto.ScTeamMemberLeave = {42031,{
        "role_id__L",
}}

proto.ScTeamNotifyKickOut = {42032,{
}}

proto.CsTeamRecruit = {42033,{
}}

proto.ScTeamRecruit = {42034,{
}}

proto.CsTeamSetTarget = {42035,{
        "target__H",
        "min__H",
        "max__H",
}}

proto.ScTeamSetTarget = {42036,{
        "target__H",
        "min__H",
        "max__H",
}}

proto.CsTeamSetMatch = {42037,{
        "match__C",
}}

proto.ScTeamSetMatch = {42038,{
        "match__C",
        "match_beg__I",
}}

proto.CsTeamDemiseLeader = {42039,{
        "target__L",
}}

proto.ScTeamDemiseLeader = {42040,{
        "target__L",
}}

proto.CsTeamPromoteRequest = {42041,{
}}

proto.ScTeamPromoteRequest = {42042,{
}}

proto.CsTeamAcceptPromote = {42043,{
        "role_id__L",
        "opt__C",
}}

proto.ScTeamAcceptPromote = {42044,{
        "role_id__L",
        "opt__C",
}}

proto.ScTeamNotifyLeaderDemise = {42045,{
        "leader__L",
}}

proto.ScTeamNotifyPromoteRequest = {42046,{
        "role_id__L",
        "name__s",
}}

proto.ScTeamNotifyAcceptPromote = {42047,{
        "role_id__L",
        "name__s",
        "opt__C",
}}

proto.CsTeamFollow = {42049,{
        "opt__C",
}}

proto.ScTeamFollow = {42050,{
        "opt__C",
}}

proto.CsTeamSyncState = {42051,{
        "state__C",
}}

proto.ScTeamSyncState = {42052,{
        "state__C",
}}

proto.ScTeamNotifyFollow = {42053,{
        "opt__C",
}}

proto.ScTeamNotifySyncState = {42054,{
        "role_id__L",
        "state__C",
}}

proto.CsTeamMemPos = {42055,{
        "role_id__L",
}}

proto.ScTeamMemPos = {42056,{
        "role_id__L",
        "scene_id__I",
        "line_id__L",
        "x__H",
        "y__H",
}}

proto.CsTeamAssist = {42057,{
        "assist__C",
}}

proto.ScTeamAssist = {42058,{
        "role_id__L",
        "assist__C",
}}

proto.ScTeamMemberAttr = {42059,{
        "role_id__L",
        "list__T__type@C##value@L",
}}

proto.ScTeamChange = {42060,{
        "role_id__L",
        "team_id__L",
}}

proto.CsTeamCommand = {42061,{
        "command__s",
}}

proto.ScTeamCommand = {42062,{
        "command__s",
}}

proto.CsTeamSetLevel = {42063,{
        "min__H",
        "max__H",
}}

proto.ScTeamSetLevel = {42064,{
        "min__H",
        "max__H",
}}

proto.ScTeamSyncPos = {42065,{
        "role_id__L",
        "x__H",
        "y__H",
}}

proto.CsKickRobot = {42071,{
        "robot_cid__C",
}}

proto.ScKickRobot = {42072,{
        "robot_cid__C",
}}

proto.CsAddRobot = {42073,{
}}

proto.ScAddRobot = {42074,{
        "ids__T__robot_cid@C",
}}

