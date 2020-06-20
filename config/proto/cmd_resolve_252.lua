proto.CsDungInfo = {25201,{
}}

proto.ScDungInfo = {25202,{
        "dungs__T__dung@U|CltDungeon|",
}}

proto.CsDungReset = {25203,{
        "dung_id__H",
}}

proto.ScDungReset = {25204,{
        "dung__U|CltDungeon|",
}}

proto.CsDungWipe = {25205,{
        "dung_id__H",
}}

proto.ScDungWipe = {25206,{
        "mul__I",
        "dung__U|CltDungeon|",
        "rewards__T__reward@U|DundWipeDropInfo|",
}}

proto.CsDungGetFirstRwd = {25207,{
        "dung_id__H",
        "level__H",
        "wave__C",
}}

proto.ScDungGetFirstRwd = {25208,{
        "dung_id__H",
        "level__H",
        "wave__C",
        "first_reward__T__lv@H##wave@C",
}}

proto.CsDungGetChapterRwd = {25209,{
        "dung_id__H",
        "chapter__C",
        "star__C",
}}

proto.ScDungGetChapterRwd = {25210,{
        "dung_id__H",
        "chapter__C",
        "star__C",
        "chapter_reward__T__id@H##star@H",
}}

proto.CsDungSingle = {25211,{
        "dung_id__H",
}}

proto.ScDungSingle = {25212,{
        "dung__U|CltDungeon|",
}}

proto.CsDungHeroInfo = {25213,{
}}

proto.ScDungHeroInfo = {25214,{
        "dung_id__H",
}}

proto.CsDungEnter = {25221,{
        "dung_id__H",
        "prefer_lv__H",
}}

proto.ScDungEnter = {25222,{
        "dung_id__H",
        "prefer_lv__H",
}}

proto.CsDungEnterTeam = {25223,{
        "dung_id__H",
}}

proto.ScDungEnterTeam = {25224,{
        "dung_id__H",
}}

proto.CsDungLeave = {25225,{
}}

proto.ScDungLeave = {25226,{
}}

proto.ScDungResult = {25227,{
        "dung_id__H",
        "mul__I",
        "level__H",
        "succeed__C",
        "stars__T__star@C",
        "cost_time__H",
        "die_times__C",
        "rewards__T__type@H##gid@I##gnum@I",
        "hurt_list__T__name@s##hurt@I",
        "chapter_reward__T__id@H##star@H",
        "is_first_chal__C",
}}

proto.ScDungData = {25228,{
        "dung_id__H",
        "level__H",
        "wave__C",
        "begin_time__I",
        "members__T__id@L##assist@C",
}}

proto.ScDungTeamStatus = {25229,{
        "status__T__role_id@L##name@s##distance@C##level@C##assist@C##times@C##alive@C##online@C",
}}

proto.ScDungRefreshMon = {25230,{
        "wave__C",
        "mons__T__id@L##type@I##x@I##y@I##special@C",
}}

