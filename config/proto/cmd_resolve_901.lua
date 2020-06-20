proto.RoleEnterSceneInfoReq = {90100,{
}}

proto.RoleEnterSceneInfoResp = {90101,{
        "role_id__L",
        "server_num__I",
        "server_time__L",
        "name__s",
        "career__C",
        "gender__C",
        "guild__L",
        "guild_name__s",
        "team__L",
        "level__H",
        "exp__L",
        "scene_id__I",
        "line_id__L",
        "x__H",
        "y__H",
        "reset_index__H",
        "hp__I",
        "mp__I",
        "anger__C",
        "combat_power__I",
        "icon__H",
        "hair__I",
        "title__H",
        "title_extra__s",
        "title_quality__C",
        "fashion__I",
        "murderous__c",
        "base_attr__U|BaseAttr|",
        "attr__U|BtAttr|",
        "state__C",
        "state_params__T__param@U|StateParam|",
        "skill_list__T__id@I##lv@H##hero@C##legend@C",
        "skill_cd__T__id@I##cd@L",
        "exteriors__T__type@C##id@C##stat@C",
        "title_honor__I",
        "artifact__I",
        "warrior_soul__I",
        "header__L",
        "frame__H",
        "bubble__H",
        "tran_stat__H",
        "mate_id__L",
        "mate_name__s",
        "fight_team_id__L",
        "prestige__H",
}}

proto.NotifyRoleSceneAttr = {90102,{
        "hp__I",
        "hp_lim__I",
        "mp__I",
        "mp_lim__I",
        "move_speed__H",
        "mode__C",
        "realm__C",
        "header__L",
}}

proto.NotifyRoleDie = {90106,{
        "killer_type__C",
        "killer_id__L",
        "killer_name__s",
        "die_time__I",
}}

proto.NotifyRoleRevive = {90107,{
        "hp__I",
        "mp__I",
        "x__H",
        "y__H",
        "bt_attr__U|BtAttr|",
}}

proto.NotifyPetRevive = {90108,{
        "id__L",
        "x__H",
        "y__H",
        "hp__I",
        "hp_lim__I",
}}

proto.NotifyObjBasic = {90110,{
        "obj_id__L",
        "mp__I",
        "mp_lim__I",
}}

proto.NotifyObjSkills = {90111,{
        "obj_skills__T__obj_skill@U|ObjSkill|",
}}

proto.ChangeSceneModeReq = {90112,{
        "scene_mode__C",
}}

proto.ChangeSceneModeResp = {90113,{
        "scene_mode__C",
        "next_mode__C",
        "next_mode_cd__H",
}}

proto.DeclareWarReq = {90114,{
        "rival_id__L",
}}

proto.NotifyRivals = {90115,{
        "rival_ids__T__rival_id@L",
}}

proto.NotifyAddRival = {90116,{
        "rival_id__L",
}}

proto.NotifyDelRival = {90117,{
        "rival_id__L",
}}

proto.NotifyBeDeclareWar = {90118,{
        "role_id__L",
        "name__s",
}}

proto.NotifyBtAttrChange = {90120,{
        "scene_bt_attr__U|BtAttr|",
}}

proto.NotifyBaseAttrChange = {90121,{
        "base_attr__U|BaseAttr|",
}}

proto.CsBattleLogInfo = {90122,{
}}

proto.ScBattleLogInfo = {90123,{
        "logs__T__log@U|BattleLoseLog|",
}}

proto.CsBattleLogDelete = {90124,{
        "id__C",
}}

proto.ScBattleLogDelete = {90125,{
        "id__C",
}}

proto.ScBattleLogNew = {90126,{
        "new_log__U|BattleLoseLog|",
}}

proto.NotifyAngerChange = {90128,{
        "anger__C",
}}

proto.NotifyPetLeave = {90129,{
        "pet_id__L",
}}

