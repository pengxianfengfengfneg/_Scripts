proto.CsGuildInfo = {41401,{
}}

proto.ScGuildInfo = {41402,{
        "guild__U|CltGuild|",
}}

proto.CsGuildList = {41403,{
}}

proto.ScGuildList = {41404,{
        "list__T__guild@U|CltGuildBrief|",
}}

proto.CsGuildGetDetail = {41405,{
        "id__L",
}}

proto.ScGuildGetDetail = {41406,{
        "guild__U|CltGuild|",
}}

proto.CsGuildGetMembers = {41407,{
}}

proto.ScGuildGetMembers = {41408,{
        "members__T__mem@U|CltGuildMember|",
}}

proto.CsGuildGetJoinReq = {41409,{
}}

proto.ScGuildGetJoinReq = {41410,{
        "list__T__request@U|CltGuildRequest|",
}}

proto.CsGuildCreate = {41411,{
        "type__C",
        "name__s",
        "announce__s",
}}

proto.ScGuildCreate = {41412,{
        "id__L",
}}

proto.CsGuildJoinReq = {41413,{
        "id__L",
}}

proto.ScGuildJoinReq = {41414,{
        "id__L",
}}

proto.CsGuildCancelReq = {41415,{
        "id__L",
}}

proto.ScGuildCancelReq = {41416,{
        "id__L",
}}

proto.ScGuildNotifyJoinReq = {41417,{
        "id__L",
        "name__s",
        "level__H",
        "fight__I",
}}

proto.ScGuildNotifyCancelReq = {41418,{
        "list__T__id@L",
}}

proto.CsGuildHandleReq = {41419,{
        "approve__C",
        "id__L",
}}

proto.ScGuildHandleReq = {41420,{
        "approve__C",
        "list__T__id@L",
}}

proto.CsInviteJoinGuild = {41421,{
        "role_id__L",
}}

proto.ScInviteJoinGuild = {41422,{
        "role_id__L",
}}

proto.ScGuildApproveResult = {41423,{
        "id__L",
        "name__s",
        "approve__C",
}}

proto.ScNewGuildInvite = {41424,{
        "role_id__L",
        "role_name__s",
        "guild_id__L",
        "guild_name__s",
}}

proto.CsGuildLeave = {41425,{
}}

proto.ScGuildLeave = {41426,{
}}

proto.ScGuildNotifyJoin = {41427,{
        "list__T__mem@U|CltGuildMember|",
}}

proto.ScGuildNotifyLeave = {41428,{
        "id__L",
}}

proto.CsGuildKickMember = {41429,{
        "id__L",
}}

proto.ScGuildKickMember = {41430,{
        "id__L",
}}

proto.ScGuildNotifyKick = {41431,{
        "id__L",
}}

proto.CsGuildRename = {41433,{
        "name__s",
}}

proto.ScGuildRename = {41434,{
        "name__s",
}}

proto.CsGuildAppointPos = {41435,{
        "role_id__L",
        "pos__C",
}}

proto.ScGuildAppointPos = {41436,{
}}

proto.ScGuildNotifyRename = {41437,{
        "guild_id__L",
        "guild_name__s",
}}

proto.ScGuildNotifyPos = {41438,{
        "change__T__id@L##pos@C",
}}

proto.CsGuildChangeAnnounce = {41439,{
        "announce__s",
}}

proto.ScGuildChangeAnnounce = {41440,{
}}

proto.CsGuildChangeAcceptType = {41441,{
        "type__C",
        "auto__C",
}}

proto.ScGuildChangeAcceptType = {41442,{
        "type__C",
        "auto__C",
}}

proto.ScGuildNotifyAnnounce = {41443,{
        "announce__s",
}}

proto.ScGuildNotifyLevelUp = {41444,{
        "level__C",
        "funds__I",
}}

proto.ScGuildNotifyOnline = {41445,{
        "role_id__L",
        "time__I",
}}

proto.CsGuildRecruit = {41447,{
}}

proto.ScGuildRecruit = {41448,{
        "recruit_time__I",
}}

proto.CsGuildLogs = {41449,{
}}

proto.ScGuildLogs = {41450,{
        "logs__T__time@I##log@s",
}}

proto.CsGuildSkillList = {41451,{
}}

proto.ScGuildSkillList = {41452,{
        "skills__T__id@I##lv@C",
}}

proto.CsGuildUpSkill = {41453,{
}}

proto.ScGuildUpSkill = {41454,{
        "skill__I",
        "level__C",
}}

proto.CsGuildLiveInfo = {41455,{
}}

proto.ScGuildLiveInfo = {41456,{
        "level__C",
        "exp__H",
        "daily__C",
        "reward__T__id@C",
        "tasks__T__id@C##times@C",
}}

proto.CsGuildGetLiveReward = {41457,{
        "id__C",
}}

proto.ScGuildGetLiveReward = {41458,{
        "id__C",
}}

proto.CsGuildLiveUpgrade = {41459,{
}}

proto.ScGuildLiveUpgrade = {41460,{
        "level__C",
        "exp__H",
}}

proto.ScGuildLiveNotify = {41461,{
        "exp__H",
        "daily__C",
}}

proto.CsGuildCookInfo = {41463,{
}}

proto.ScGuildCookInfo = {41464,{
        "num__C",
        "type__C",
        "total__C",
        "reward__T__id@C",
        "logs__T__time@I##id@L##name@s##type@C",
}}

proto.CsGuildCook = {41465,{
        "type__C",
}}

proto.ScGuildCook = {41466,{
        "type__C",
}}

proto.CsGuildGetCookReward = {41467,{
        "id__C",
}}

proto.ScGuildGetCookReward = {41468,{
        "id__C",
}}

proto.CsGuildEnterSeat = {41471,{
}}

proto.ScGuildEnterSeat = {41472,{
}}

proto.CsGuildLeaveSeat = {41473,{
}}

proto.ScGuildLeaveSeat = {41474,{
}}

proto.CsGuildExInfo = {41475,{
}}

proto.ScGuildExInfo = {41476,{
        "items__T__id@H##num@C",
        "refresh__I",
        "manual__C",
}}

proto.CsGuildExchange = {41477,{
        "id__H",
}}

proto.ScGuildExchange = {41478,{
        "id__H",
}}

proto.CsGuildExRefresh = {41479,{
}}

proto.ScGuildExRefresh = {41480,{
}}

proto.CsGuildUpgrade = {41481,{
}}

proto.ScGuildCostDenf = {41482,{
        "funds__I",
}}

proto.CsGuildPracticeInfo = {41483,{
}}

proto.ScGuildPracticeInfo = {41484,{
        "prac_max_lv__H",
        "practice_skill__T__id@C##lv@H",
}}

proto.CsGuildPracticeUp = {41485,{
        "id__C",
}}

proto.ScGuildPracticeUp = {41486,{
        "id__C",
        "lv__H",
}}

proto.CsGuildBanquet = {41487,{
}}

proto.ScGuildBanquet = {41488,{
}}

proto.CsGuildMetallInfo = {41489,{
}}

proto.ScGuildMetallInfo = {41490,{
        "metall_lively__H",
}}

proto.CsGuildMetallTask = {41491,{
        "type__C",
}}

proto.ScGuildMetallTask = {41492,{
        "task_id__I",
        "metall_lively__H",
}}

proto.CsGuildBuildUp = {41493,{
        "id__H",
}}

proto.ScGuildBuildUp = {41494,{
        "build__T__id@H##lv@C",
}}

proto.CsGuildStudyUp = {41495,{
        "id__H",
}}

proto.ScGuildStudyUp = {41496,{
        "study__T__id@H##lv@C",
}}

