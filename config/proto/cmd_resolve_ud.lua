proto.GoodsInfo = {
        "id__I",
        "pos__H",
        "num__H",
        "bind__C",
        "expire__I",
        "paris__C",
        "attr__T__key@H##value@H",
        "sell_time__I",
        "sell_times__C",
        "effect__I",
        "level__C",
        "exp__H",
        "extra__T__field@s",
}

proto.BagInfo = {
        "bag_id__C",
        "name__s",
        "cell_num__H",
        "goods__T__goods@U|GoodsInfo|",
}

proto.BagChange = {
        "bag_id__C",
        "change__T__goods@U|GoodsInfo|",
        "delete__T__pos@H",
}

proto.Item = {
        "type__C",
        "id__I",
        "num__I",
        "bind__C",
}

proto.EquipInfo = {
        "pos__C",
        "id__I",
        "stren__C",
        "stones__T__pos@C##id@I",
        "paris__C",
        "attr__T__key@H##value@H",
        "extra__T__field@s",
}

proto.Dragon = {
        "pos__C",
        "id__I",
        "level__C",
        "exp__H",
}

proto.DragonView = {
        "items__T__item@U|Dragon|",
        "growth_lv__C",
        "growth_hole__C",
        "refine_lv__C",
        "refine_star__C",
        "refine_exp__H",
        "refine_quality__T__id@C##val@H",
}

proto.CltChatRole = {
        "id__L",
        "name__s",
        "svr_num__H",
        "career__C",
        "gender__C",
        "level__H",
        "icon__H",
        "frame__H",
        "bubble__H",
}

proto.CltChatHisItem = {
        "role__C",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
        "time__I",
}

proto.CltChatPublicCache = {
        "channel__C",
        "target__L",
        "history__T__item@U|CltChatPublicItem|",
}

proto.CltChatPublicItem = {
        "sender__U|CltChatRole|",
        "item__U|CltChatHisItem|",
}

proto.CltChatPrivateCache = {
        "sender__U|CltChatRole|",
        "history__T__item@U|CltChatHisItem|",
}

proto.MarryView = {
        "mate_id__L",
        "mate_name__s",
        "bless__C",
}

proto.StateParam = {
        "center_x__H",
        "center_y__H",
        "end_time__I",
}

proto.RoleLoginInfo = {
        "role_id__L",
        "name__s",
        "career__C",
        "gender__C",
        "level__H",
        "fashion__I",
        "artifact__I",
        "icon__H",
        "hair__I",
        "state__C",
        "reg_time__I",
        "last_login_time__I",
}

proto.RoleSceneInfo = {
        "role_id__L",
        "owner_id__L",
        "server_num__I",
        "name__s",
        "career__C",
        "gender__C",
        "level__H",
        "guild__L",
        "guild_name__s",
        "team__L",
        "realm__C",
        "mate_id__L",
        "mate_name__s",
        "cur_pet__L",
        "x__H",
        "y__H",
        "to_x__H",
        "to_y__H",
        "hp__I",
        "hp_lim__I",
        "mp__I",
        "mp_lim__I",
        "move_speed__H",
        "combat_power__I",
        "icon__H",
        "hair__I",
        "fashion__I",
        "title__H",
        "title_extra__s",
        "title_quality__C",
        "header__L",
        "title_honor__I",
        "buffs__T__aid@I##id@I##lv@C##expire@L",
        "state__C",
        "state_params__T__param@U|StateParam|",
        "exteriors__T__type@C##id@C##stat@C",
        "murderous__c",
        "artifact__I",
        "warrior_soul__I",
        "tran_stat__C",
        "fight_team_id__L",
        "prestige__H",
}

proto.MonSceneInfo = {
        "id__L",
        "mid__I",
        "name__s",
        "level__H",
        "owner_id__L",
        "owner_name__s",
        "owner_team__L",
        "move_speed__H",
        "x__H",
        "y__H",
        "to_x__H",
        "to_y__H",
        "hp__I",
        "hp_lim__I",
        "buffs__T__aid@I##id@I##lv@C##expire@L",
        "realm__H",
        "attackable__C",
        "first_att__L",
}

proto.PetSceneInfo = {
        "id__L",
        "pet_cid__H",
        "title_c__C",
        "title_s__s",
        "name__s",
        "level__H",
        "star__C",
        "awaken__C",
        "owner_id__L",
        "owner_name__s",
        "guild__L",
        "team__L",
        "realm__C",
        "move_speed__H",
        "x__H",
        "y__H",
        "to_x__H",
        "to_y__H",
        "hp__I",
        "hp_lim__I",
        "buffs__T__aid@I##id@I##lv@C##expire@L",
}

proto.CollSceneInfo = {
        "id__L",
        "coll_cid__H",
        "owner_id__L",
        "belonger_id__L",
        "belonger_name__s",
        "stat__C",
        "x__H",
        "y__H",
        "realm__C",
}

proto.CarrySceneInfo = {
        "id__L",
        "cid__H",
        "owner_id__L",
        "owner_name__s",
        "guild_name__s",
        "x__H",
        "y__H",
        "to_x__H",
        "to_y__H",
        "type__C",
        "couples__T__id@L",
}

proto.FlyitemSceneInfo = {
        "id__L",
        "cid__H",
        "x__H",
        "y__H",
        "to_x__H",
        "to_y__H",
}

proto.ObjSkill = {
        "type__C",
        "id__L",
        "skill_cd__T__id@I##cd@L",
        "skill_list__T__id@I##lv@C",
}

proto.BaseAttr = {
        "power__I",
        "anima__I",
        "energy__I",
        "concent__I",
        "method__I",
        "basic__I",
        "adef__H",
        "adef_red__H",
        "aatt__I",
        "adef_min__H",
}

proto.BtAttr = {
        "hp_lim__I",
        "hp_rec__I",
        "mp_lim__I",
        "mp_rec__I",
        "outer_att__I",
        "inner_att__I",
        "outer_def__I",
        "inner_def__I",
        "hit__I",
        "dodge__I",
        "crit_hurt__I",
        "crit_def__I",
        "att_speed__H",
        "move_speed__H",
        "igndef_hurt__I",
        "igndef_def__I",
        "hurt_add__H",
        "hurt_red__H",
        "crit_add__H",
        "crit_red__H",
        "aatt_ice__I",
        "aatt_fire__I",
        "aatt_dark__I",
        "aatt_poison__I",
        "adef_ice__H",
        "adef_fire__H",
        "adef_dark__H",
        "adef_poison__H",
        "adef_red_ice__H",
        "adef_red_fire__H",
        "adef_red_dark__H",
        "adef_red_poison__H",
        "adef_min_ice__H",
        "adef_min_fire__H",
        "adef_min_dark__H",
        "adef_min_poison__H",
        "ahurt_add_ice__H",
        "ahurt_add_fire__H",
        "ahurt_add_dark__H",
        "ahurt_add_poison__H",
        "ahurt_add__H",
        "ahurt_red__H",
        "penetrate_att__I",
        "penetrate_def__I",
        "penetrate_crit__I",
        "penetrate_crit_def__I",
        "penetrate_speed__H",
        "penetrate_hurt_add__H",
        "penetrate_hurt_red__H",
        "ahurt_red_ice__H",
        "ahurt_red_fire__H",
        "ahurt_red_dark__H",
        "ahurt_red_poison__H",
        "ahurt_perc_ice__I",
        "ahurt_perc_fire__I",
        "ahurt_perc_dark__I",
        "ahurt_perc_poison__I",
        "aaffect_perc_ice__I",
        "aaffect_perc_fire__I",
        "aaffect_perc_dark__I",
        "aaffect_perc_poison__I",
}

proto.UdDefer = {
        "defer_type__C",
        "defer_id__L",
        "defer_x__H",
        "defer_y__H",
        "defer_hp__I",
        "hurt_seq__T__harm_type@C##injury@i",
}

proto.CltMailGoods = {
        "type__C",
        "id__I",
        "num__I",
        "bind__C",
}

proto.CltMailGoodsList = {
        "list__T__goods@U|CltMailGoods|",
}

proto.CltArtifact = {
        "id__I",
        "cur_avatar__I",
        "avatars__T__id@I",
        "combat_power__I",
        "stren__C",
        "stones__T__pos@C##id@I",
        "extra_attr__T__id@H##value@I",
}

proto.CltAnqi = {
        "id__I",
        "q_level__I",
        "combat_power__I",
        "stren__C",
        "stones__T__pos@C##id@I",
        "practice_lv__C",
        "origin_attr__T__id@H##value@I",
        "add_attr__T__id@H##value@I",
        "poison_slots__T__slot@U|AnqiPoisonSlot|",
}

proto.WarriorSoulView = {
        "lv__C",
        "star_lv__C",
        "stren__C",
        "stones__T__pos@C##id@I",
        "combat_power__I",
        "soul_parts__T__part@U|SoulPartInfo|",
        "skills__T__id@I",
        "cur_avatar__I",
}

proto.CltRoleView = {
        "id__L",
        "name__s",
        "server_num__I",
        "server_id__I",
        "level__H",
        "career__C",
        "gender__C",
        "icon__C",
        "hair__I",
        "frame__H",
        "bubble__H",
        "fashion__I",
        "title__H",
        "title_honor__I",
        "scene_id__I",
        "offline__I",
        "guild_name__s",
        "mate_name__s",
        "stat__C",
        "team_id__L",
        "team_num__C",
        "introduction__s",
        "equips__T__equip@U|EquipInfo|",
        "anqi__U|CltAnqi|",
        "artifact__U|CltArtifact|",
        "dragon__U|DragonView|",
        "warrior_soul__U|WarriorSoulView|",
        "marriage__U|MarryView|",
}

proto.CltRankItem = {
        "rank__H",
        "id__L",
        "server_num__I",
        "columns__T__column@s",
}

proto.CltRankInfo = {
        "type__H",
        "page__C",
        "total__C",
        "items__T__item@U|CltRankItem|",
        "relative__T__item@U|CltRankItem|",
}

proto.CltTitle = {
        "id__I",
        "expire__I",
        "valid__C",
}

proto.CltShop = {
        "id__I",
        "items__T__item@U|CltShopItem|",
}

proto.CltShopItem = {
        "id__I",
        "num__I",
}

proto.CltDungeon = {
        "id__H",
        "now_lv__H",
        "now_wave__H",
        "max_lv__H",
        "max_wave__H",
        "max_lv_yday__H",
        "max_wave_yday__H",
        "enter_times__H",
        "reset_times__C",
        "chal_times__H",
        "wipe_times__H",
        "assist_times__H",
        "daily_his__T__lv@H##times@C",
        "daily_wipe__T__lv@H##times@C",
        "daily_reward__T__lv@H##times@C",
        "life_his__T__lv@H##times@C",
        "star_info__T__lv@H##star@C",
        "chapter_reward__T__id@H##star@H",
        "first_reward__T__lv@H##wave@C",
}

proto.PetPoten = {
        "power__H",
        "anima__H",
        "energy__H",
        "concent__H",
        "method__H",
}

proto.CltPet = {
        "grid__C",
        "cid__H",
        "name__s",
        "stat__C",
        "level__C",
        "exp__L",
        "hp__I",
        "star__C",
        "savvy_lv__C",
        "growup_lv__C",
        "growup_rate__H",
        "awaken__C",
        "potential__U|PetPoten|",
        "init_attr__T__type@C##value@I",
        "bt_attr__T__type@C##value@I",
        "skills__T__grid@C##id@I##lv@C",
        "sell_time__I",
        "sell_times__C",
}

proto.CltDpet = {
        "grid__C",
        "cid__H",
        "name__s",
        "level__C",
        "star__C",
        "savvy_lv__C",
        "growup_lv__C",
        "growup_rate__H",
        "awaken__C",
}

proto.CltAttach = {
        "attach_id__C",
        "pet_grid__C",
        "internals__T__grid@C##internal@C##lv@C",
        "bt_attr__T__type@C##value@I",
        "fight__I",
}

proto.CltGuild = {
        "id__L",
        "name__s",
        "rank__H",
        "level__C",
        "funds__I",
        "fight__L",
        "announce__s",
        "chief_id__L",
        "chief_name__s",
        "accept_type__C",
        "auto_accept__C",
        "members__T__mem@U|CltGuildMember|",
        "denf_state__C",
        "pause_denf_time__I",
        "recently_live__I",
        "bonus__T__id@C##times@I",
        "build__T__id@H##lv@C",
        "study__T__id@H##lv@C",
        "battle__I",
        "lucky_money__T__info@U|CltLuckyMoney|",
        "num__I",
        "sh_dung__T__id@C##chal_times@C##reward_times@C",
        "sh_cur_page__C",
        "recruit_time__I",
}

proto.CltGuildMember = {
        "id__L",
        "pos__C",
        "name__s",
        "level__H",
        "gender__C",
        "fight__I",
        "career__C",
        "contri__I",
        "vip_lv__C",
        "offline__I",
        "weekly_live__I",
        "weekly_funds__I",
        "weekly_cont__I",
        "icon__H",
        "frame__H",
}

proto.CltGuildRequest = {
        "id__L",
        "name__s",
        "level__H",
        "fight__I",
        "frame__H",
        "icon__H",
}

proto.CltGuildBrief = {
        "id__L",
        "rank__H",
        "name__s",
        "level__C",
        "mem_num__C",
        "fight__L",
        "apply__C",
        "chief_name__s",
        "accept_type__C",
        "auto_accept__C",
        "denf_state__C",
        "max_num__I",
        "num__I",
}

proto.CltGuildDonate = {
        "id__L",
        "name__s",
        "contri__I",
}

proto.GuildCommentRole = {
        "role_id__L",
        "role_name__s",
        "career__C",
        "gender__C",
        "like_num__I",
        "dislike_num__I",
        "dice_num__C",
        "reward_id__I",
}

proto.CltSurface = {
        "id__C",
        "num__C",
        "fashion__H",
        "mount__H",
        "wing__H",
        "god__H",
}

proto.CltHero = {
        "id__C",
        "level__C",
        "exp__H",
        "legend__C",
}

proto.CltHeroGuide = {
        "id__C",
        "name__s",
        "desc__s",
        "plan__T__id@C##skill@I",
}

proto.WbGuildRank = {
        "boss_id__I",
        "total_harm__L",
        "boss_hp_lmt__L",
        "rank_list__T__guild_id@I##guild_name@s##harm@L",
}

proto.CltDiceVal = {
        "role_id__L",
        "role_name__s",
        "val__C",
}

proto.CltTeam = {
        "id__L",
        "match__C",
        "target__H",
        "follow__C",
        "leader__L",
        "min_lv__H",
        "max_lv__H",
        "members__T__member@U|CltTeamMember|",
        "robots__T__robot_cids@C",
        "match_beg__I",
}

proto.CltTeamBrief = {
        "id__L",
        "name__s",
        "level__H",
        "career__C",
        "leader__L",
        "mem_num__C",
}

proto.CltTeamMember = {
        "id__L",
        "name__s",
        "hp__I",
        "hp_lim__I",
        "level__H",
        "state__C",
        "scene__I",
        "line__L",
        "career__C",
        "gender__C",
        "offline__I",
        "icon__H",
        "frame__H",
        "assist__C",
}

proto.CltChannel = {
        "id__C",
        "hero__C",
        "level__C",
        "equips__T__pos@C##id@I",
        "potentials__T__type@C##id@H##val@H",
}

proto.AnqiSkillPlan = {
        "index__C",
        "skill1__I",
        "skill2__I",
        "skill3__I",
}

proto.AnqiPoisonSlot = {
        "index__C",
        "lv__C",
        "exp__H",
        "attr__T__id@H##value@I",
        "sub_attr__T__id@H##value@I",
}

proto.CltTask = {
        "id__I",
        "stat__C",
        "masks__T__current@H##total@H",
}

proto.CltMarketGoods = {
        "uid__L",
        "tag__C",
        "id__I",
        "num__I",
        "stat__C",
        "price__I",
        "follower__H",
        "end_time__I",
        "following__C",
}

proto.FriendInfo = {
        "id__L",
        "vip__C",
        "name__s",
        "level__H",
        "fight__I",
        "offline__I",
        "gender__C",
        "career__C",
        "icon__H",
        "frame__H",
        "team_id__L",
        "team_num__C",
        "guild__L",
        "guild_name__s",
        "scene__I",
        "stat__C",
}

proto.FriendBlock = {
        "id__C",
        "name__s",
        "mem_list__T__roleId@L",
}

proto.FriendGroup = {
        "id__L",
        "type__C",
        "max_num__C",
        "name__s",
        "announce__s",
        "owner__L",
        "mem_list__T__roleId@L",
        "apply_list__T__roleId@L",
}

proto.FriendGroupSimple = {
        "id__L",
        "type__C",
        "max_num__C",
        "num__C",
        "name__s",
        "announce__s",
        "owner_role__U|CltChatRole|",
}

proto.FriendUpdateList = {
        "type__C",
        "new_list__T__roleId@L",
}

proto.DundWipeDropInfo = {
        "lv__H",
        "rewards__T__type@C##id@I##num@I",
}

proto.CltForgeSoul = {
        "level__C",
        "exp__H",
        "soul__T__id@C##lv@C",
}

proto.BattleLoseLog = {
        "id__C",
        "time__I",
        "scene__I",
        "winner_id__L",
        "winner_name__s",
}

proto.CltLuckyMoney = {
        "id__I",
        "cid__H",
        "sender__s",
        "list__T__rank@H##role_id@L##name@s##value@I",
        "expire_time__I",
        "icon__I",
}

proto.CondenSoulResult = {
        "index__C",
        "recommend__C",
        "alters__T__id@H##value@c",
}

proto.SoulPartInfo = {
        "type__C",
        "attr__T__id@H##value@I",
        "conden_ret__U|CondenSoulResult|",
}

proto.SwornMember = {
        "role_id__L",
        "name__s",
        "title_honor__I",
        "lv__C",
        "career__C",
        "gender__C",
        "icon__H",
        "frame__H",
        "senior__C",
        "word__s",
        "scene__I",
}

proto.SwornSortInfo = {
        "role_id__L",
        "name__s",
        "icon__H",
        "frame__H",
        "senior__C",
        "votes__C",
}

proto.SwornPersonPlat = {
        "role_id__L",
        "name__s",
        "title_honor__I",
        "lv__C",
        "career__C",
        "icon__H",
        "frame__H",
        "guild_name__s",
        "tend_career__C",
        "tend_lv__C",
        "tend_time__C",
}

proto.SwornMemberSimple = {
        "role_id__L",
        "name__s",
        "lv__C",
        "career__C",
        "gender__C",
}

proto.SwornGroupPlat = {
        "group_id__L",
        "mem_list__T__mem@U|SwornMemberSimple|",
        "sworn_value__I",
        "tend_career__C",
        "tend_lv__C",
        "tend_time__C",
}

proto.CltDeedList = {
        "day__C",
        "list__T__id@H##times@C",
}

proto.MentorBaseInfo = {
        "role_id__L",
        "name__s",
        "senior__C",
        "lv__C",
        "career__C",
        "gender__C",
        "icon__H",
        "frame__H",
        "offline_time__I",
        "scene__I",
        "morality__I",
}

proto.MentorTudiInfo = {
        "role_id__L",
        "senior__C",
        "type__C",
        "mark__H",
        "practice_num__C",
        "begin_time__I",
        "comment__C",
        "learn_tasks__T__id@H##progress@H",
        "mentor_tasks__T__id@H##progress@H",
        "taixue_tasks__T__id@H##progress@H",
        "award_taken__C",
}

proto.CltFightTeam = {
        "id__L",
        "name__s",
        "prestige__H",
        "leader__L",
        "members__T__member@U|CltFightTeamMember|",
}

proto.CltFightTeamMember = {
        "id__L",
        "name__s",
        "fight__I",
        "level__H",
        "career__C",
        "frame__H",
        "icon__H",
        "prestige__H",
}

proto.CltSwordRes = {
        "svr_name__s",
        "fight_team_name__s",
        "members__T__name@s##career@C##role_id@L##kill_num@C",
}

