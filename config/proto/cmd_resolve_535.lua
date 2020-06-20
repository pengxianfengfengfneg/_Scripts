proto.CsGuildDeclare = {53501,{
        "guild_id__L",
}}

proto.ScGuildDeclare = {53502,{
        "guild_id__L",
        "expire_time__I",
        "exploit__I",
        "num__I",
        "guild_name__s",
        "type__C",
}}

proto.CsGuildHostile = {53503,{
        "guild_id__L",
}}

proto.ScGuildHostile = {53504,{
        "guild_id__L",
        "rob__C",
        "num__I",
        "guild_lv__H",
        "guild_name__s",
}}

proto.CsGuildDeclareList = {53505,{
}}

proto.ScGuildDeclareList = {53506,{
        "declare__T__num@I##time@I##exploit@I##guild_name@s##guild_id@L",
        "back__T__num@I##time@I##exploit@I##guild_name@s##guild_id@L",
}}

proto.CsGuildHostileList = {53507,{
}}

proto.ScGuildHostileList = {53508,{
        "hostile__T__num@I##rob@C##guild_lv@H##guild_name@s##guild_id@L",
}}

proto.ScGuildDeclareExpire = {53509,{
        "list__T__guild_id@L",
}}

proto.CsGuildBlessInfo = {53510,{
}}

proto.ScGuildBlessInfo = {53511,{
        "bless__T__id@H##expire@I",
}}

proto.CsGuildBless = {53512,{
        "id__C",
}}

proto.ScGuildBless = {53513,{
        "id__C",
        "expire__I",
}}

proto.ScGuildMoneyChange = {53515,{
        "lucky_money__T__info@U|CltLuckyMoney|",
        "type__C",
}}

proto.CsGuildMoneyGet = {53516,{
        "id__I",
}}

proto.ScGuildMoneyRemove = {53517,{
        "remove_list__T__id@I",
}}

proto.ScGuildShDungChange = {53518,{
        "sh_dung__T__id@C##chal_times@C##reward_times@C",
        "sh_cur_page__C",
}}

proto.CsGuildHostileCancel = {53519,{
        "guild_id__L",
}}

proto.ScGuildHostileCancel = {53520,{
        "guild_id__L",
}}

