proto.RoleWalkReq = {90200,{
        "scene_id__I",
        "role_id__L",
        "cx__H",
        "cy__H",
        "x__H",
        "y__H",
        "move__C",
        "reset_index__H",
}}

proto.BcastObjWalk = {90201,{
        "type__C",
        "id__L",
        "cx__H",
        "cy__H",
        "x__H",
        "y__H",
        "move__C",
}}

proto.PetWalkReq = {90202,{
        "pet_id__L",
        "scene_id__I",
        "cx__H",
        "cy__H",
        "x__H",
        "y__H",
        "move__C",
        "reset_index__H",
}}

proto.ResetPoint = {90203,{
        "obj_type__C",
        "obj_id__L",
        "x__H",
        "y__H",
        "reset_type__C",
        "reset_index__I",
}}

proto.GetMonPosReq = {90204,{
        "mids__T__mid@I",
}}

proto.GetMonPosResp = {90205,{
        "pos_list__T__mid@I##x@H##y@H",
}}

proto.SceneInfoReq = {90207,{
}}

proto.ChangeSceneReq = {90208,{
        "scene_id__I",
        "line_id__L",
}}

proto.SceneTransferReq = {90209,{
        "door__C",
}}

proto.GetSceneLineInfoReq = {90210,{
}}

proto.GetSceneLineInfoResp = {90211,{
        "scene_id__I",
        "line_info__T__line_id@C##role_num@C",
}}

proto.BcastBuffChange = {90230,{
        "caster_type__C",
        "caster_id__L",
        "to_type__C",
        "to_id__L",
        "buff_aid__I",
        "buff_id__I",
        "buff_lv__C",
        "buff_expire__L",
        "change_type__C",
}}

proto.BcastAddRoleSceneInfo = {90232,{
        "role_list__T__role@U|RoleSceneInfo|",
}}

proto.BcastDelRole = {90233,{
        "role_ids__T__role_id@L",
}}

proto.BcastAddMonSceneInfo = {90234,{
        "mon_list__T__mon@U|MonSceneInfo|",
}}

proto.BcastDelMon = {90235,{
        "mon_ids__T__mon_id@L",
}}

proto.BcastAddPetSceneInfo = {90236,{
        "pet_list__T__pet@U|PetSceneInfo|",
}}

proto.BcastDelPet = {90237,{
        "pet_ids__T__pet_id@L",
}}

proto.BcastAddCollSceneInfo = {90239,{
        "coll_list__T__coll@U|CollSceneInfo|",
}}

proto.BcastDelColl = {90240,{
        "coll_ids__T__coll_id@L",
}}

proto.BcastMonChangeModle = {90241,{
        "id__L",
        "mid__I",
        "res_id__I",
}}

proto.BcastObjHpChange = {90243,{
        "type__C",
        "id__L",
        "hp__I",
        "hp_lim__I",
}}

proto.BcastMpChange = {90244,{
        "role_id__L",
        "mp__I",
        "mp_lim__I",
}}

proto.BcastRoleChangeName = {90245,{
        "role_id__L",
        "nickname__s",
}}

proto.BcastRoleChangeIcon = {90246,{
        "role_id__L",
        "icon__H",
}}

proto.NotifyKillRole = {90247,{
        "dead_type__C",
        "dead_id__L",
        "dead_name__s",
}}

proto.BcastObjDie = {90248,{
        "type__C",
        "id__L",
}}

proto.BcastMoveSpeedChange = {90249,{
        "obj_type__C",
        "obj_id__L",
        "move_speed__H",
}}

proto.BcastCollectSt = {90250,{
        "coll_id__L",
        "stat__C",
        "realm__C",
}}

proto.BcastRoleInfoChange = {90251,{
        "role_id__L",
        "level__H",
        "combat_power__I",
        "hp__L",
        "hp_lim__L",
        "move_speed__H",
}}

proto.BcastObjSpecState = {90252,{
        "type__C",
        "id__L",
        "state__C",
        "state_params__T__param@U|StateParam|",
}}

proto.BcastAddCarrySceneInfo = {90253,{
        "carry_list__T__carry@U|CarrySceneInfo|",
}}

proto.BcastDelCarry = {90254,{
        "carry_ids__T__carry_id@L",
}}

proto.BcastExteriorChange = {90255,{
        "role_id__L",
        "type__C",
        "id__C",
        "stat__C",
}}

proto.BcastMurderousChange = {90256,{
        "role_id__L",
        "murderous__c",
}}

proto.BcastAddFlyitemSceneInfo = {90257,{
        "flyitem_list__T__flyitem@U|FlyitemSceneInfo|",
}}

proto.BcastDelFlyitem = {90258,{
        "flyitem_ids__T__flyitem_id@L",
}}

proto.BcastArtifactChangeAvatar = {90259,{
        "role_id__L",
        "artifact__I",
}}

proto.BcastGuildInfoChange = {90260,{
        "role_id__L",
        "guild__L",
        "guild_name__s",
}}

proto.BcastWarriorSoulChangeAvatar = {90261,{
        "role_id__L",
        "warrior_soul__I",
}}

proto.BcastTransformStat = {90262,{
        "role_id__L",
        "tran_stat__H",
}}

proto.BcastMonFirstAtt = {90263,{
        "id__L",
        "mid__I",
        "first_att__L",
}}

