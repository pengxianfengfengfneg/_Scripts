proto.CsChatInfo = {40201,{
}}

proto.ScChatInfo = {40202,{
        "channels__T__id@C##times@I",
}}

proto.CsChatPublic = {40203,{
        "channel__C",
        "target__L",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
}}

proto.ScChatPublic = {40204,{
        "channel__C",
        "target__L",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
}}

proto.CsChatPrivate = {40205,{
        "id__L",
        "svr_num__I",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
}}

proto.ScChatPrivate = {40206,{
        "target__U|CltChatRole|",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
}}

proto.ScChatPublicNotify = {40207,{
        "channel__C",
        "target__L",
        "sender__U|CltChatRole|",
        "time__I",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
}}

proto.ScChatPrivateNotify = {40208,{
        "sender__U|CltChatRole|",
        "time__I",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
}}

proto.CsChatHorn = {40209,{
        "content__s",
        "extra__s",
        "type__C",
}}

proto.ScChatHorn = {40210,{
        "content__s",
        "extra__s",
        "type__C",
}}

proto.ScChatHornNotify = {40211,{
        "sender__U|CltChatRole|",
        "time__I",
        "content__s",
        "extra__s",
}}

proto.CsChatCache = {40213,{
}}

proto.ScChatCache = {40214,{
        "offline_time__I",
        "pub__T__cache@U|CltChatPublicCache|",
        "pri__T__cache@U|CltChatPrivateCache|",
}}

proto.CsChatClearCache = {40215,{
        "id__L",
}}

proto.ScChatClearCache = {40216,{
        "id__L",
}}

