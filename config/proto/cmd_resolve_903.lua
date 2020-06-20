proto.AttackReq = {90300,{
        "role_id__L",
        "defer_type__C",
        "defer_id__L",
        "skill_id__I",
        "assist_x__H",
        "assist_y__H",
}}

proto.BcastAttack = {90301,{
        "atter_type__C",
        "atter_id__L",
        "defer_type__C",
        "defer_id__L",
        "skill_id__I",
        "skill_lv__C",
        "hero__C",
        "legend__C",
        "is_trig__C",
        "assist_x__H",
        "assist_y__H",
}}

proto.BcastBattleHarm = {90302,{
        "atter_type__C",
        "atter_id__L",
        "atter_x__H",
        "atter_y__H",
        "skill_id__I",
        "skill_lv__C",
        "hero__C",
        "legend__C",
        "assist_x__H",
        "assist_y__H",
        "defer_list__T__defer@U|UdDefer|",
}}

proto.PreSkillReq = {90303,{
        "role_id__L",
        "defer_type__C",
        "defer_id__L",
        "skill_id__I",
        "assist_x__H",
        "assist_y__H",
        "op__C",
}}

proto.BcastPreSkill = {90304,{
        "atter_type__C",
        "atter_id__L",
        "defer_type__C",
        "defer_id__L",
        "skill_id__I",
        "skill_lv__C",
        "hero__C",
        "legend__C",
        "assist_x__H",
        "assist_y__H",
        "op__C",
}}

proto.PetAttackReq = {90305,{
        "id__L",
        "owner_id__L",
        "defer_type__C",
        "defer_id__L",
        "skill_id__I",
        "skill_lv__C",
        "assist_x__H",
        "assist_y__H",
}}

proto.PetPreSkillReq = {90306,{
        "id__L",
        "owner_id__L",
        "defer_type__C",
        "defer_id__L",
        "skill_id__I",
        "skill_lv__C",
        "assist_x__H",
        "assist_y__H",
        "op__C",
}}

proto.ReviveReq = {90307,{
        "type__C",
}}

proto.BcastRevive = {90308,{
        "obj_type__C",
        "obj_id__L",
        "hp__I",
        "hp_lim__I",
        "x__H",
        "y__H",
}}

proto.NotifyBattleStatistics = {90309,{
        "harm_statistics__T__obj_type@C##obj_id@L##harm@L",
        "recover_statistics__T__obj_type@C##obj_id@L##recover@L",
}}

proto.NotifyClearSkillCd = {90310,{
        "skill_ids__T__skill_id@I",
}}

proto.CollectReq = {90320,{
        "coll_id__L",
        "coll_type_id__L",
}}

proto.BcastCollect = {90321,{
        "role_id__L",
        "coll_id__L",
        "op__C",
}}

proto.UseSpecialSkillReq = {90322,{
}}

proto.UseMarrySkillReq = {90330,{
        "skill_id__L",
}}

proto.NotifyPassiveTransfer = {90331,{
        "scene_id__I",
}}

proto.AckPassiveTransfer = {90332,{
        "reply__C",
        "scene_id__I",
}}

proto.GetMarrySkillCdReq = {90333,{
}}

proto.GetMarrySkillCdResp = {90334,{
        "cd_list__T__skill_id@I##last_use@I",
}}

proto.NotifyUpdateMarrySkillCd = {90335,{
        "skill_id__I",
}}

proto.NotifyPassiveRevive = {90336,{
}}

proto.AckPassiveRevive = {90337,{
        "reply__C",
}}

