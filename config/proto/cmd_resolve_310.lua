proto.CsMasterInfo = {31001,{
}}

proto.ScMasterInfo = {31002,{
        "state__C",
        "score__I",
        "hp_pert__C",
        "last_rob__I",
        "last_chap__I",
        "last_robbed__I",
}}

proto.CsMasterLog = {31003,{
}}

proto.ScMasterLog = {31004,{
        "role__T__log@s",
        "guild__T__log@s",
}}

proto.CsMasterRank = {31005,{
}}

proto.ScMasterRank = {31006,{
        "role__T__rank@H##id@L##name@s##career@C##guild@s##score@I",
        "guild__T__rank@H##id@L##name@s##num@C##chief@s##score@I",
}}

proto.ScMasterNotifyRank = {31007,{
        "role__T__rank@H##id@L##name@s##career@C##guild@s##score@I",
        "guild__T__rank@H##id@L##name@s##num@C##chief@s##score@I",
}}

proto.ScMasterNotifyHp = {31008,{
        "hp_pert__C",
}}

proto.CsMasterRegister = {31009,{
        "opt__C",
}}

proto.ScMasterRegister = {31010,{
        "opt__C",
}}

proto.CsMasterChap = {31021,{
}}

proto.ScMasterChap = {31022,{
}}

proto.CsMasterQuitChap = {31023,{
}}

proto.ScMasterQuitChap = {31024,{
}}

proto.CsMasterRob = {31025,{
        "id__L",
}}

proto.ScMasterRob = {31026,{
        "id__L",
}}

proto.CsMasterQuitRob = {31027,{
}}

proto.ScMasterQuitRob = {31028,{
}}

proto.ScMasterChapResult = {31029,{
        "score__I",
        "chap_score__I",
}}

proto.ScMasterRobResult = {31030,{
        "id__L",
        "name__s",
        "succ__C",
        "score__I",
        "rob_score__I",
}}

proto.ScMasterNotifyRob = {31031,{
        "id__L",
        "name__s",
        "succ__C",
        "score__I",
        "robbed_score__I",
}}

proto.ScMasterSettle = {31032,{
        "score__I",
}}

