proto.CsSwornInfo = {54001,{
}}

proto.ScSwornInfo = {54002,{
        "group_id__L",
        "mem_list__T__mem@U|SwornMember|",
        "group_name__s",
        "quality__C",
        "sworn_value__I",
        "enounce__s",
        "open_ui__C",
}}

proto.CsSwornCreateNew = {54003,{
}}

proto.ScSwornConfirmUI = {54004,{
        "type__C",
        "msg__s",
        "cd_time__C",
}}

proto.CsSwornMakeConfirm = {54005,{
        "type__C",
        "choice__C",
}}

proto.CsSwornRecruitMember = {54006,{
}}

proto.ScSwornMemberUpdate = {54007,{
        "mem_list__T__mem@U|SwornMember|",
}}

proto.CsSwornDismissMemberReq = {54008,{
}}

proto.ScSwornDismissMemberReq = {54009,{
}}

proto.CsSwornDismissMember = {54010,{
        "role_id__L",
        "reason__C",
}}

proto.ScSwornDeleteMember = {54011,{
        "role_id__L",
        "sworn_value__I",
}}

proto.CsSwornChangeSenior = {54012,{
}}

proto.ScSwornSeniorSortInfo = {54013,{
        "cur_senior__C",
        "close_time__I",
        "sorted_list__T__info@U|SwornSortInfo|",
        "raw_list__T__info@U|SwornSortInfo|",
}}

proto.CsSwornModifyNameReq = {54014,{
}}

proto.ScSwornModifyNameReq = {54015,{
}}

proto.CsSwornModifyName = {54016,{
        "name_head__s",
        "name_tail__s",
}}

proto.ScSwornModifyName = {54017,{
        "group_name__s",
}}

proto.CsSwornModifyWord = {54018,{
        "word__s",
}}

proto.ScSwornModifyWord = {54019,{
        "word__s",
}}

proto.CsSwornUpQuality = {54020,{
}}

proto.ScSwornUpQuality = {54021,{
        "quality__C",
}}

proto.ScSwornValueUpdate = {54022,{
        "sworn_value__I",
}}

proto.CsSwornModifyEnounce = {54023,{
        "enounce__s",
}}

proto.ScSwornModifyEnounce = {54024,{
        "enounce__s",
}}

proto.CsSwornGatherMember = {54025,{
}}

proto.CsSwornGetPlatformList = {54026,{
        "type__C",
}}

proto.ScSwornGetPlatformList = {54027,{
        "registered__C",
        "greet_num__C",
        "person_list__T__person@U|SwornPersonPlat|",
        "group_list__T__group@U|SwornGroupPlat|",
}}

proto.CsSwornRegister = {54028,{
        "tend_career__C",
        "tend_lv__C",
        "tend_time__C",
}}

proto.ScSwornRegisterUpdate = {54029,{
        "registered__C",
}}

proto.CsSwornCancelRegister = {54030,{
}}

proto.CsSwornGreet = {54031,{
        "type__C",
        "id__L",
}}

proto.ScSwornGreet = {54032,{
        "type__C",
        "id__L",
        "greet_num__C",
}}

proto.CsSwornVoteSenior = {54033,{
        "role_id__L",
}}

proto.ScSwornVoteSenior = {54034,{
        "role_id__L",
}}

proto.CsSwornLeaveGroup = {54035,{
}}

proto.ScSwornLeaveGroup = {54036,{
}}

