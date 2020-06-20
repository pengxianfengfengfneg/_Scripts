
game.GameNetEvent = {
	NetConnect = "NetConnect",
	NetDisConnect = "NetDisConnect",
}

game.GameEvent = {
	StartPlay = "StartPlay",
    StopPlay = "StopPlay",
	Pause = "Pause",
}

game.LoginEvent = {
    LoginSuccess = "LoginSuccess",
    LoginNoticeChange = "LoginNoticeChange",
    LoginServerChange = "LoginServerChange",
    LoginRoleListRet = "LoginRoleListRet",
    LoginRoleRet = "LoginRoleRet",
    LoginReconnectRet = "LoginReconnectRet",
    LoginCheckResult = "LoginCheckResult",
    LoginReconnectFinish = "LoginReconnectFinish",
}

game.SceneEvent = {
    TargetChange = "TargetChange",
    ObjDelete = "ObjDelete",
    SwitchToFighting = "SwitchToFighting",
    SwitchToMainCity = "SwitchToMainCity",
    MainRoleHpChange = "MainRoleHpChange",
    MainRoleMpChange = "MainRoleMpChange",
    TargetHpChange = "TargetHpChange",
    TargetMpChange = "TargetMpChange",
    TargetOwnerTypeChange = "TargetOwnerTypeChange",
    HangChange = "HangChange",
    FindWay = "SceneEvent_FindWay",
    GatherChange = "GatherChange",
    MainRoleRevive = "MainRoleRevive",
    MainRoleDie = "MainRoleDie",
    MainRoleSkillChange = "MainRoleSkillChange",
    ChangeScene = "SceneEventChangeScene",
    UpdateEnterSceneInfo = "SceneEvent_UpdateEnterSceneInfo",
    ClickNpc = "SceneEvent_ClickNpc",
    CommonlyValueRespon = "SceneEvent_CommonlyValueRespon",
    OpAndMerDayRespon = "SceneEvent_OpAndMerDayRespon",
    PkModeChange = "SceneEvent_PkModeChange",
    OnGetMonPos = "SceneEvent_GetMonPos",
    MainRoleAddBuff = "SceneEvent_MainRoleAddBuff",
    MainRoleDelBuff = "SceneEvent_MainRoleDelBuff",
    MainRolePetChange = "MainRolePetChange",
    MainRolePetHpChange = "MainRolePetHpChange",
    MainRoleCarryChange = "MainRoleCarryChange",
    MainRoleMurderousChange = "MainRoleMurderousChange",
    MonsterDie = "SceneEvent_MonsterDie",
    OperateChangeScene = "SceneEvent_OperateChangeScene",
    MainRolePetDie = "MainRolePetDie",
    MainRoleTargetAddBuff = "MainRoleTargetAddBuff",
    MainRoleTargetDelBuff = "MainRoleTargetDelBuff",
    OnSkillSpeak = "OnSkillSpeak",
    MainRoleIconChange = "MainRoleIconChange",
    BattleInfoChange = "BattleInfoChange",
    FixRoleAttr = "FixRoleAttr",
    MainRoleFightStateChange = "MainRoleFightStateChange",
    OnRoleCommonInfo = "SceneEvent_OnRoleCommonInfo",
    OnPlayBigSkill = "SceneEvent_OnPlayBigSkill",
    FinishFirstJump = "SceneEvent_FinishFirstJump",
}

game.SDKEvent = {
	SDKStatusChange = "SDKStatusChange",
}

game.BagEvent = {
    BagChange = "BagEventBagChange",
    BagAddCell = "BagEventBagAddCell",
    BagItemChange = "BagEventBagItemChange",
    StorageRename = "BagEventStorageRename",
    StorageExtend = "BagEventStorageExtend",
    SelectStorage = "BagEventSelectStorage",
}

game.MoneyEvent = {
    Change = "MoneyEventChange",
    Exchange = "MoneyEventExchange",
}

game.RoleEvent = {
    LevelChange = "RoleEventLevelChange",
    WearEquip = "RoleEventWearEquip",
    UpdateRoleInfo = "SceneEvent_UpdateRoleInfo",
    UpdateMainRoleInfo = "SceneEvent_UpdateMainRoleInfo",
    GodEquipWash = "RoleEventGodEquipWash",
    GodEquipUpgrade = "RoleEventGodEquipUpgrade",
    UpdateRoleAttr = "RoleEvent_UpdateRoleAttr",
    UpdateRoleBaseAttr = "RoleEvent_UpdateRoleBaseAttr",
    PersonalInfoChange = "RoleEvent_PersonalInfoChange",
    RefreshMount = "RoleEvent_RefreshMount",
    HonorUpgrade = "RoleEventHonorUpgrade",
    TitleShowSettingChange = "TitleShowSettingChange",
    RoleTitleChange = "RoleTitleChange",
    LevelUpgrade = "RoleEventLevelUpgrade",

    UpdateBubbleInfo = "RoleEvent_UpdateBubbleInfo",
    UpdateCurBubble = "RoleEvent_UpdateCurBubble",

    UpdateFrameInfo = "RoleEvent_UpdateFrameInfo",
    UpdateCurFrame = "RoleEvnet_UpdateCurFrame",
}

game.RedPointEvent = {
    UpdateRedPoint = "RedPointEvent_UpdateRedPoint",
}

game.TestEvent = {
    TestBagRed = "TestBagRed",
}

game.OpenFuncEvent = {    
    OpenFuncInfo = "OpenFuncEvent_OpenFuncInfo",
    OpenFuncNew = "OpenFuncEvent_OpenFuncNew",
    OpenFuncNewSkill = "OpenFuncEvent_OpenFuncNewSkill",

    SetShowFunc = "OpenFuncEvent_SetShowFunc",
    ShowFuncsEffect = "OpenFuncEvent_ShowFuncsEffect",
}

game.ChatEvent = {
    OnChatPublic = "ChatEvent_OnChatPublic",
    OpenChatView = "ChatEvent_OpenChatView",
    CloseChatView = "ChatEvent_CloseChatView",
    UpdateNewChat = "ChatEvent_UpdateNewChat",
    UpdateRumor = "ChatEvent_UpdateRumor",
    NoticeHorn = "ChatEvent_NoticeHorn",
    UpdatePrivateChat = "ChatEvent_UpdatePrivateChat",
    UpdateChatAt = "ChatEvent_UpdateChatAt",
    RevcieveChatAt = "ChatEvent_RevcieveChatAt",
    AddHisChatData = "ChatEvent_AddHisChatData",
}

game.ShopEvent = {
    Change = "ShopEvent_Change",
    RefreshView = "ShopEvent_RefreshView",
    BuySuccess = "ShopEvent_BuySuccess",
}

game.PetEvent = {
    OnPetInfo = "PetEventOnPetInfo",
    PetChange = "PetEventPetChange",
    StorageChange = "PetEventPetStorageChange",
    BagPetDelete = "PetEventBagPetDelete",
    StoragePetDelete = "PetEventStoragePetDelete",
    HatchInfo = "PetEventHatchInfo",
    PetAdd = "PetEventPetAdd",
    SelectZhenFa = "PetEventSelectZhenFa",
    AttachChange = "PetEventAttachChange",
    Wash = "PetEventWash",
    Savvy = "PetEventSavvy",
    ExpChange = "PetEventExpChange",
}

game.MailEvent = {
    RefreshView = "MailEvent_RefreshView",
    GetAttach = "MailEvent_GetAttach",
    NewMail = "MailEvent_NewMail",
    OpenView = "MailEvent_OpenView",
}

game.MsgEvent = {
    AddChatMsg = "MsgEvent_AddChatMsg",
}

game.CarbonEvent = {
    RefreshMaterial = "CarbonEventRefreshMaterial",
    GetChapterReward = "CarbonEventGetChapterReward",
    GetFirstReward = "CarbonEventGetFirstReward",
    OnDungData = "CarbonEventOnDungData",
    OnDungResult = "CarbonEventOnDungResult",
    OnDungInfo = "CarbonEventOnDungInfo",
    OnDungRefreshMon = "CarbonEventOnDungRefreshMon",

    UpdateDunTeamState = "CarbonEventUpdateDunTeamState",
}

game.FriendEvent = {
    RefreshSearch = "FriendEventRefreshSearch",
    RefreshRoleIdList = "FriendEventRefreshRoleIdList",
    RefreshBlockList = "FriendEventRefreshBlockList",
    RefreshGroupList = "FriendEventRefreshGroupList",
    RefreshGroupSearch = "FriendEventRefreshGroupSearch",
    RemoveGroup = "FriendEventRemoveGroup",
    ChangeNickName = "FriendEventChangeNickName",
    DeleteNickName = "FriendEventDeleteNickName",
    RefreshNickName = "FriendEventRefreshNickName",
    RefreshEnemyList = "FriendEventRefreshEnemyList",
    OpenFriendChat = "FriendEventOpenFriendChat",
    CloseFriendChat = "FriendEventCloseFriendChat",
    ShowFriendDetail = "FriendEventShowFriendDetail",
    ShowGroupDetail = "FriendEventShowGroupDetail",
}

game.DailyTaskEvent = {
    UpdateKillMonNum = "DailyTaskEvent_UpdateKillMonNum",
    UpdateJhexpRewardState = "DailyTaskEvent_UpdateJhexpRewardState",
    FinishJhexpReward = "DailyTaskEvent_FinishJhexpReward",

    UpdateChess = "DailyTaskEvent_UpdateChess",
    UpdateChessState = "DailyTaskEvent_UpdateChessState",
    UpdateChessStar = "DailyTaskEvent_UpdateChessStar",

    UpdateMustDoInfo = "DailyTaskEvent_UpdateMustDoInfo",

    UpdateThiefInfo = "DailyTaskEvent_UpdateThiefInfo",
    ThiefExpAdven = "DailyTaskEvent_ThiefExpAdven",
    ThiefRoratyAdven = "DailyTaskEvent_ThiefRoratyAdven",

    GuildTaskInfo = "DailyTaskEvent_GuildTaskInfo",
    GuildTaskFinish = "DailyTaskEvent_GuildTaskFinish",
    GuildTaskGet = "DailyTaskEvent_GuildTaskGet",

    UpdateCxdtInfo = "DailyTaskEventUpdateCxdtInfo",

    UpdateExamineInfo = "DailyTaskEvent_UpdateExamineInfo",
    UpdateExamineRankInfo = "DailyTaskEvent_UpdateExamineRankInfo",
    OnExamineAnswer = "DailyTaskEvent_OnExamineAnswer",
    UpdateExamineHelpState = "DailyTaskEvent_UpdateExamineHelpState",
    UpdateExamineTipsText = "DailyTaskEvent_UpdateExamineTipsText",
    OnExamineGuide = "DailyTaskEvent_OnExamineGuide",

    UpdateTreasureMapInfo = "DailyTaskEvent_UpdateTreasureMapInfo",

    SelectHero = "DailyTaskEventSelectHero",

    UpdateDailyTaskInfo = "DailyTaskEvent_UpdateDailyTaskInfo",
}


game.GuideEvent = {
    FocusOnFightGround = "GuideEvent_FocusOnFightGround",
    FocusOffFightGround = "GuideEvent_FocusOffFightGround",

    FocusOnMainGround = "GuideEvent_FocusOnMainGround",
    FocusOffMainGround = "GuideEvent_FocusOffMainGround",

    FocusOnView = "GuideEvent_FocusOnView",
    FocusOffView = "GuideEvent_FocusOffView",

    ClickButton = "GuideEvent_ClickButton",

    NetRespond = "GuideEvent_NetRespond",

    AcceptTask = "GuideEvent_AcceptTask",
    CompleteTask = "GuideEvent_CompleteTask",
    RoleLevelUp = "GuideEvent_RoleLevelUp",
    OpenFunc = "GuideEvent_OpenFunc",
}

game.FashionEvent = {
    ActiveFashion = "FashionEvent_ActiveFashion",
    WearFashion = "FashionEvent_WearFashion",
    DyeingFashion = "FashionEvent_DyeingFashion",
    SwitchHairId = "FashionEvent_SwithHairId",
    ChangeHair = "FashionEvent_ChangeHair",
}

game.TaskEvent = {
    UpdateTask = "TaskEvent_UpdateTask",

    OnUpdateTaskInfo = "TaskEvent_OnUpdateTaskInfo",
    OnAcceptTask = "TaskEvent_OnAcceptTask",
    OnFinishTask = "TaskEvent_OnFinishTask",
    OnGetTaskReward = "TaskEvent_OnGetTaskReward",

    OnDoneTaskTalk = "TaskEvent_OnDoneTaskTalk",

    HangTask = "TaskEvent_HangTask",
    HangTaskSeeking = "TaskEvent_HangTaskSeeking",

    OnCircleWilful = "TaskEvent_OnCircleWilful",
    OnCircleQuick = "TaskEvent_OnCircleQuick",
    OnCircleHelp = "TaskEvent_OnCircleHelp",
}

game.PassBossEvent = {
    UpdatePass = "PassBossEvent_UpdatePass",
    UpdateReward = "PassBossEvent_UpdateReward",
    BossComing = "PassBossEvent_BossComing",
}

game.SkillEvent = {
    SkillUpgrade = "SkillEvent_SkillUpgrade",
    SkillOneKeyUp = "SkillEvent_SkillOneKeyUp",
    SkillNew = "SkillEvent_SkillNew",
    UpdateSkillInfo = "SkillEvent_UpdateSkillInfo",
    ChangeForgeStar = "SkillEvent_ChangeForgeStar",
    UpdateSkillAnger = "SkillEvent_UpdateSkillAnger",
    SkillBloodSettingChange = "SkillBloodSettingChange",
    PetSkillBloodSettingChange = "PetSkillBloodSettingChange",
}

game.BossEvent = {
    BuyTreasureTimes = "BossEventBuyTreasureTimes",
    TreasureBossRank = "BossEventTreasureBossRank",
    TreasureBossRefresh = "BossEventTreasureBossRefresh",
}

game.ArenaEvent = {
    UpdateOpp = "ArenaEventUpdateOpp",
    UpdateRankList = "ArenaEventUpdateRankList",
    UpdateTimes = "ArenaEventUpdateTimes",
    GetRoleInfo = "ArenaEventGetRoleInfo",
    InitOppInfo = "ArenaEventInitOppInfo",
}

game.GuideEndEvent = {
    ClickButton = "GuideEndEventClickButton"
}

game.GuildEvent = {
    UpdateGuildInfo = "GuildEvent_UpdateGuildInfo",
    UpdateGuildList = "GuildEvent_UpdateGuildList",
    UpdateMemberList = "GuildEvent_UpdateMemberList",
    UpdateAppList = "GuildEvent_UpdateAppList",
    CreateGuild = "GuildEvent_CreateGuild",
    UpdateGuildName = "GuildEvent_UpdateGuildName",
    RenameSuccess = "GuildEvent_RenameSuccess",
    UpdateAnnounce = "GuildEvent_UpdateAnnounce",
    ChangeAnnounce = "GuildEvent_ChangeAnnounce",
    GuildHandleReq = "GuildEvent_GuildHandleReq",

    KickMember = "GuildEvent_KickMember",
    LeaveGuild = "GuildEvent_LeaveGuild",
    AppointPos = "GuildEvent_AppointPos",
    UpdateMemberPos = "GuildEvent_UpdateMemberPos",
    UpdateLogsList = "GuildEvent_UpdateLogsList",
    UpdateMemberOffline = "GuildEvent_UpdateMemberOffline",
    UpdateGuildLevel = "GuildEvent_UpdateGuildLevel",
    GuildRecruit = "GuildEvent_GuildRecruit",
    ApproveResult = "GuildEvent_ApproveResult",
    ChangeApply = "GuildEvent_ChangeApply",
    OnGuildGetDetail = "GuildEvent_OnGuildGetDetail",

    ChangeAcceptType = "GuildEvent_ChangeAcceptType",
    UpdateGuildLiveInfo = "GuildEvent_UpdateGuildLiveInfo",
    GetLiveReward = "GuildEvent_GetLiveReward",
    UpdateGuildCookInfo = "GuildEvent_UpdateGuildCookInfo",
    GuildCook = "GuildEvent_GuildCook",
    GetCookReward = "GuildEvent_GetCookReward",
    UpdateContribute = "GuildEvent_UpdateContribute",
    UpdateGuildSkillList = "GuildEvent_UpdateGuildSkillList",
    UpdateGuildExchangeInfo = "GuildEvent_UpdateGuildExchangeInfo",
    GuildExchange = "GuildEvent_GuildExchange",

    NewGuildInvite = "GuildEvent_NewGuildInvite",
    UpdateQuestionInfo = "GuildEvent_UpdateQuestionInfo",
    AnswerQuestion = "GuildEvent_AnswerQuestion",
    UpdateDailyTaskInfo = "GuildEvent_UpdateDailyTaskInfo",
    UpdatePracticeInfo = "GuildEvent_UpdatePracticeInfo",

    UpdateDefendPanelInfo = "GuildEvent_UpdateDefendPanelInfo",
    UpdateDefendScoreInfo = "GuildEvent_UpdateDefendScoreInfo",
    DefendTripodHurt = "GuildEvent_DefendTripodHurt",
    DefendRefresh = "GuildEvent_DefendRefresh",
    DefendPublish = "GuildEvent_DefendPublish",
    UpdateDefendMonInfo = "GuildEvent_UpdateDefendMonInfo",
    UpdateDefendCurNum = "GuildEvent_UpdateDefendCurNum",
    OnGuildDefendClose = 'GuildEvent_OnGuildDefendClose',

    UpdateWineInfo = "GuildEvent_UpdateWineInfo",
    UpdateWineCommentInfo = "GuildEvent_UpdateWineCommentInfo",
    UpdateWineCommentRoleInfo = "GuildEvent_UpdateWineCommentRoleInfo",
    OnWineDice = "GuildEvent_OnWineDice",
    UpdateWineExp = "GuildEvent_UpdateWineExp",
    UpdateWineNumber = "GuildEvent_UpdateWineNumber",
    UpdateWineNextSubject = "GuildEvent_UpdateWineNextSubject",

    OnActStateChange = "GuildEvent_OnActStateChange",

    YunbiaoInfoChange = "GuildEvent_YunbiaoInfoChange",
    YunbiaoStateChange = "GuildEvent_YunbiaoStateChange",

    UdpateBuildInfo = "GuildEvent_UdpateBuildInfo",
    OnGuildWagesInfo = "GuildEvent_OnGuildWagesInfo",
    UdpateResearchInfo = "GuildEvent_UdpateResearchInfo",
    OnGuildDeclareList = "GuildEvent_OnGuildDeclareList",
    OnGuildHostileList = "GuildEvent_OnGuildHostileList",
    UpdateMetallTaskInfo = "GuildEvent_UpdateMetallTaskInfo",
    UpdateBlessInfo = "GuildEvent_UpdateBlessInfo",

    OnGuildMoneyChange = "GuildEvent_OnGuildMoneyChange",
    UpdateGuildLuckyMoneyList = "GuildEvent_UpdateGuildLuckyMoneyList",
    RemoveGuildLuckyMoney = "GuildEvent_RemoveGuildLuckyMoney",
    UpdateGuildLuckyMoneyReceiveNum = "GuildEvent_UpdateGuildLuckyMoneyReceiveNum",
}

game.OpenActivityEvent = {
    UpdateChargeInfo = "OpenActivityEvent_UpdateChargeInfo",
    UpdateAdvanceInfo = "OpenActivityEvent_UpdateAdvanceInfo",
    DisCountStoreInfo = "OpenActivityEvent_DisCountStoreInfo",
    DisCountStoreBuy = "OpenActivityEvent_DisCountStoreBuy",
}

game.VipEvent = {
    UpdateVipInfo = "VipEvent_UpdateVipInfo",
    UpdateVipReward = "VipEvent_UpdateVipReward",
    UpdateTodayRecharge = "VipEvent_UpdateTodayRecharge",
    UpdateTodayRechargeMoney = "VipEvent_UpdateTodayRechargeMoney",
    UpdateCaculateRecharge = "VipEvent_UpdateCaculateRecharge",
    UpdateCaculateRechargeMoney = "VipEvent_UpdateCaculateRechargeMoney",
    UpdateRechargeInfo = "VipEvent_UpdateRechargeInfo",
}

game.RankEvent = {
    UpdateRightList = "RankEventUpdateRightList",
    UpdateMainViewRankInfo = "RankEventUpdateMainViewRankInfo",
}

game.MarryEvent = {
    MarryInfo = "MarryEventMarryInfo",
    SkillUpgrade = "MarryEventSkillUpgrade",
    Bless = "MarryEventBless",
    UpdateHallBTClick = "MarryEventUpdateHallBTClick",
    UpdateSkillCD = "MarryEventUpdateSkillCD",
    MateDie = "MarryEventMateDie",
    MateNear = "MarryEventMateNear",
}

game.ActivityEvent = {
    ActivityInfo = "ActivityEvent_ActivityInfo",
    UpdateActivity = "ActivityEvent_UpdateActivity",
    StopActivity = "ActivityEvent_StopActivity",
    ChangeActiveExp = "ActivityEvent_ChangeActiveExp",
    TodayOnlineTime = "ActivityEventTodayOnlineTime",
    MainUIRedpoint = "ActivityEventMainUIRedpoint",
}

game.SurfaceSuitEvent = {
    UpdateSuitInfo = "SurfaceSuitEvent_UpdateSuitInfo"
}


game.HeroGuideEvent = {
    UpdateHeroGuide = "HeroGuideEvent_UpdateHeroGuide",
}

game.HeroEvent = {
    HeroActive = "HeroEventHeroActive",
    HeroUpgrade = "HeroEventHeroUpgrade",
    HeroUpgradeAll = "HeroEventHeroUpgradeAll",
    ComposeItem = "HeroEventComposeItem",
    HeroActiveSenior = "HeroEventHeroActiveSenior",
    GuideChange = "HeroEventGuideChange",
    HeroSetGuide = "HeroEventHeroSetGuide",
    HeroGuideEdit = "HeroEventHeroGuideEdit",
    HeroUseGuide = "HeroEventHeroUseGuide",
    HeroPulseSelect = "HeroEventHeroPulseSelect",
    HeroPotentialSelect = "HeroEventHeroPotentialSelect",
    HeroAttrSelect = "HeroEventHeroAttrSelect",
    HeroPulseActive = "HeroEventHeroPulseActive",
    HeroPulseTrain = "HeroEventHeroPulseTrain",
    HeroChangePotential = "HeroEventHeroChangePotential",
    HeroPulseWearEquip = "HeroEventHeroPulseWearEquip",
    PulseTreasureDraw = "HeroEventPulseTreasureDraw",
}

game.RewardHallEvent = {
    UpdateAccInfo = "RewardHallEventUpdateAccInfo",
    UpdateSignInfo = "RewardHallEventUpdateSignInfo",
    UpdateLevelGift = "RewardHallEventUpdateLevelGift",
    UpdateWeekMonthCard = "RewardHallEventUpdateWeekMonthCard",
    UpdateOnlineInfo = "RewardHallEventUpdateOnlineInfo",
    UpdateOnlinePray = "RewardHallEventUpdateOnlinePray",
    UpdateGrowthFundInfo = "RewardHallEventUpdateGrowthFundInfo",
    UpdatePayBackInfo = "RewardHallEventUpdatePayBackInfo",
    UpdateDailyGiftInfo = "RewardHallEventUpdateDailyGiftInfo",
    UpdateGetBackInfo = "RewardHallEventUpdateGetBackInfo",
    OnSevenLoginInfo = "RewardHallEventOnSevenLoginInfo",
    OnSevenLoginGet = "RewardHallEventOnSevenLoginGet",
    UpdateDividendInfo = "RewardHallEventUpdateDividendInfo",
    OnDividendLvGet = "RewardHallEventOnDividendLvGet",
    OnDividendStoneChange = "RewardHallEventOnDividendStoneChange",
    OnDividendLuckyInfo = "RewardHallEventOnDividendLuckyInfo",
    StopDividendAct = "RewardHallEventOnStopDividendAct",
}

game.SongliaoWarEvent = {
    UpdateRoleNum = "SongliaoWarEventUpdateRoleNum",
    UpdateStage  = "SongliaoWarEventUpdateStage",
    UpdateScore = "SongliaoWarEventUpdateScore",
    UpdateTile = "SongliaoWarEventUpdateTile",
}

game.AuctionEvent = {
    UpdateList = "AuctionEventUpdateList",
    UpdateLog = "AuctionEventUpdateLog",
    UpdateInfo = "AuctionEventUpdateInfo",
}

game.LuckyTruningEvent = {
    LuckyRoratyInfo = "LuckyTruningEvent_LuckyRoratyInfo",
    LuckyRoraty = "LuckyTruningEvent_LuckyRoraty",
}

game.WorldBossEvent = {
    UpdateHurtRank = "WorldBossEvent_UpdateHurtRank",
    OnGetWorldBossSeq = "WorldBossEvent_OnGetWorldBossSeq",
    RolldiceCallback = "WorldBossEvent_RolldiceCallback",
    UpdateRolldice = "WorldBossEvent_UpdateRolldice",
}

game.DailyRechargeEvent = {
    GetReward = "GetRewardDailyRechargeEvent",
}

game.OverlordEvent = {
    Rank = "OverlordEventRank",
    Info = "OverlordEventInfo",
    Log = "OverlordEventLog",
    BossHP = "OverlordEventBossHP",
}

game.VoiceEvent = {
    OnStartRecord = "VoiceEvent_OnStartRecord",
    OnStopRecord = "VoiceEvent_OnStopRecord",
    OnStartPlay = "VoiceEvent_OnStartPlay",
    OnStopPlay = "VoiceEvent_OnStopPlay",
    OnSpeechText = "VoiceEvent_OnSpeechText",
}

game.CareerBattleEvent = {
    UpdateLoungeInfo = "CareerBattleEvent_UpdateLoungeInfo",
    UpdateBattleRankInfo = "CareerBattleEvent_UpdateBattleRankInfo",
    EnterBattleScene = "CareerBattleEvent_EnterBattleScene",
    BattleUpdateHurt = "CareerBattleEvent_BattleUpdateHurt",
    BattleEnd = "CareerBattleEvent_BattleEnd",
    CareerBattleReward = "CareerBattleEvent_CareerBattleReward",
    UpdateTopInfo = "CareerBattleEvent_UpdateTopInfo",
}

game.FoundryEvent = {
    ComposeSucc = "FoundryEventComposeSucc",
    StrenSucc = "FoundryEventStrenSucc",
    OneKeyStrenSucc = "FoundryEventOneKeyStrenSucc",
    InlaySucc = "FoundryEventInlaySucc",
    ForgeSucc = "FoundryEventForgeSucc",
    EquipRefresh = "FoundryEventEquipRefresh",
    GatherUpgrade = "FoundryEventGatherUpgrade",
    ScoreRotaty = "FoundryEventScoreRotaty",
    UpdateSmeltInfo = "FoundryEventUpdateSmeltInfo",
    UpdateSmeltColor = "FoundryEventUpdateSmeltColor",
    UpdateInlayStren = "FoundryEventUpdateInlayStren",
    UpdateStrip = "FoundryEventUpdateStrip",
    UpdateGodweaponInfo = "FoundryEventUpdateGodweaponInfo",
    UpdateGodweaponInfoPos = "FoundryEventUpdateGodweaponInfoPos",
    UpdateGodweaponTupo = "FoundryEventUpdateGodweaponTupo",
    ChangeAvatar = "FoundryEventChangeAvatar",
    UpdateHWPractice = "FoundryEventUpdateHWPractice",
    UpdateHWForge = "FoundryEventUpdateHWForge",
    UpdateHWUpgrade = "FoundryEventUpdateHWUpgrade",
    ChangeHWSkillPlan = "FoundryEventChangeHWSkillPlan",
    RefreshSkillPlan = "FoundryEventRefreshSkillPlan",
    ReplaceSkillPlan = "FoundryEventReplaceSkillPlan",
    UnlockSkillPlan = "FoundryEventUnlockSkillPlan",
    UpdateHWPoison = "FoundryEventUpdateHWPoison",
    OpenFirstPlan = "FoundryEventOpenFirstPlan",
    GodweaponCollect = "FoundryEventGodweaponCollect",
    MainUIRedpoint = "FoundryEventMainUIRedpoint",
}

game.LakeBanditsEvent = {
    DragonBelong = "LakeBanditsEvent_DragonBelong",
    OnLineChange = "LakeBanditsEvent_OnLineChange",
    UpdateDragonMon = "LakeBanditsEvent_UpdateDragonMon",
    UpdateLineRole = "LakeBanditsEvent_UpdateLineRole",
    UpdateDragonPosInfo = "LakeBanditsEvent_UpdateDragonPosInfo",
}

game.MakeTeamEvent = {
    OnTeamGetInfo = "MakeTeamEvent_OnTeamGetInfo",
    UpdateTeamCreate = "MakeTeamEvent_UpdateTeamCreate",
    UpdateTargetList = "MakeTeamEvent_UpdateTargetList",
    TeamLeave = "MakeTeamEvent_TeamLeave",
    TeamMemberLeave = "MakeTeamEvent_TeamMemberLeave",    
    UpdateApplyList = "MakeTeamEvent_UpdateApplyList",
    UpdateAcceptApply = "MakeTeamEvent_UpdateAcceptApply",
    UpdateTeamNewMember = "MakeTeamEvent_UpdateTeamNewMember",
    ChangeLeader = "MakeTeamEvent_ChangeLeader",
    UpdateJoinTeam = "MakeTeamEvent_UpdateJoinTeam",
    UpdateKickOut = "MakeTeamEvent_UpdateKickOut",
    NotifyKickOut = "MakeTeamEvent_NotifyKickOut",
    InviteJoinCallback = "MakeTeamEvent_InviteJoinCallback",
    TeamNotifyApply = "MakeTeamEvent_TeamNotifyApply",
    OnTeamMatch = "MakeTeamEvent_OnTeamMatch",
    OnTeamSetMatch = "MakeTeamEvent_OnTeamSetMatch",
    CallTeamFollow = "MakeTeamEvent_CallTeamFollow",
    OnTeamMemPos = "MakeTeamEvent_OnTeamMemPos",
    OnTeamMemberAttr = "MakeTeamEvent_OnTeamMemberAttr",
    OnTeamSetTarget = "MakeTeamEvent_OnTeamSetTarget",
    OnTeamGetNearby = "MakeTeamEvent_OnTeamGetNearby",
    OnTeamNotifySyncState = "MakeTeamEvent_OnTeamNotifySyncState",
    OnTeamNotifyFollow = "MakeTeamEvent_OnTeamNotifyFollow",
    OnUpdateAssist = "MakeTeamEvent_OnUpdateAssist",
    OnTeamSetLevel = "MakeTeamEvent_OnTeamSetLevel",
    OnTeamSyncPos = "MakeTeamEvent_OnTeamSyncPos",
}

game.GuildArenaEvent = {
    UpdateViewInfo = "GuildArenaEventUpdateViewInfo",
    UpdateViewInfoSec = "GuildArenaEventUpdateViewInfoSec",
    UpdateStageChange = "GuildArenaEventUpdateStageChange",
    UpdateRankData = "GuildArenaEventUpdateRankData", 
    UpdateMyScore = "GuildArenaEventUpdateMyScore",
}

game.FieldBattleEvent = {
    OnTerritoryInfo = "FieldBattleEvent_OnTerritoryInfo",
    OnTerritoryScenePrepare = "FieldBattleEvent_OnTerritoryScenePrepare",
    OnTerritoryNotifySelect = "FieldBattleEvent_OnTerritoryNotifySelect",
    OnTerritoryProgress = "FieldBattleEvent_OnTerritoryProgress",
    OnTerritoryRank = "FieldBattleEvent_OnTerritoryRank",
    OnTerritoryBeatDrum = "FieldBattleEvent_OnTerritoryBeatDrum",
    OnTerritorySceneBattle = "FieldBattleEvent_OnTerritorySceneBattle",
    OnTerritoryNotifyFlag = "FieldBattleEvent_OnTerritoryNotifyFlag",
    OnTerritoryNotifyDrum = "FieldBattleEvent_OnTerritoryNotifyDrum",
}

game.LakeExpEvent = {
    UpdateKillMonNum = "LakeExpEvent_UpdateKillMonNum",
    UpdateLakeExpInfo = "LakeExpEvent_UpdateLakeExpInfo",
    OnLakeExperienceUse = "LakeExpEvent_OnLakeExperienceUse",
}

game.ExteriorEvent = {
    OnExteriorMountInfo = "ExteriorEvent_OnExteriorMountInfo",
    OnMountSettingChange = "ExteriorEvent_OnMountSettingChange",
    OnExteriorMountChoose = "ExteriorEvent_OnExteriorMountChoose",
    OnFashionSettingChange = "ExteriorEvent_OnFashionSettingChange",
    OnActionSettingChange = "ExteriorEvent_OnActionSettingChange",
    OnFrameSettingChange = "ExteriorEvent_OnFrameSettingChange",
    OnBubbleSettingChange = "ExteriorEvent_OnBubbleSettingChange",
}

game.GatherEvent = {
    OnGatherColl = "GatherEvent_OnGatherColl",
    OnGatherUpgrade = "GatherEvent_OnGatherUpgrade",
    OnGatherInfo = "GatherEvent_OnGatherInfo",
}

game.ViewEvent = {
    OpenView = "ViewEvent_OpenView",
    CloseView = "ViewEvent_CloseView",

    MainViewReady = "ViewEvent_MainViewReady",
    ShowSkillCom = "ViewEvent_ShowSkillCom",
}

game.MarketEvent = {
    OnMarketInfo = "MarketEvent_OnMarketInfo",
    OnMarketLog = "MarketEvent_OnMarketLog",
    OnMarketSearchInfo = "MarketEvent_OnMarketSearchInfo",
    OnMarketRareItem = "MarketEvent_OnMarketRareItem",
    OnMarketRarePet = "MarketEvent_OnMarketRarePet",
    OnMarketFollow = "MarketEvent_OnMarketFollow",
    OnMarketPutOn = "MarketEvent_OnMarketPutOn",
    OnMarketTakeOff = "MarketEvent_OnMarketTakeOff",
    OnMarketResale = "MarketEvent_OnMarketResale",
    OnMarketBuy = "MarketEvent_OnMarketBuy",
    UpdatePutList = "MarketEvent_UpdatePutList",
    OnMarketRefreshItem = "MarketEvent_OnMarketRefreshItem",
}

game.RechargeEvent = {
    OnConsumeInfo = "RechargeEvent_OnConsumeInfo",
    OnConsumeRoraty = "RechargeEvent_OnConsumeRoraty",
    OnConsumeChange = "RechargeEvent_OnConsumeChange",
    OnConsumeFlagChange = "RechargeEvent_OnConsumeFlagChange",
    OnGetCharge = "RechargeEvent_OnGetCharge",
    OnGetConsume = "RechargeEvent_OnGetConsume",
    OnConsumeRoratyGet = "RechargeEvent_OnConsumeRoratyGet",
}

game.WulinRewardEvent = {
    WulinRewardChange = "WulinRewardChange",
}

game.NumberKeyboardEvent = {
    Number = "NumberKeyboardEvent",
    Close = "NumberKeyboardEvent_Close",
}

game.SocietyEvent = {
    RefreshTaskState = "SocietyEvent_RefreshTaskState",
    RefreshStarAward = "SocietyEvent_RefreshStarAward",
    RefreshMainUI = "SocietyEvent_RefreshMainUI",
}

game.ObjStateEvent = {
    MoveState = "ObjStateEvent_MoveState",
}

game.MapEvent = {
    OnMapLineInfo = "MapEvent_OnMapLineInfo",
    LoadMapFinish = "MapEvent_LoadMapFinish",
}

game.FirstLoadingEvent = {
    NetCallback = "FirstLoadingEvent_NetCallback",
}

game.AchieveEvent = {
    AchieveInfo = "AchieveEventAchieveInfo",
}

game.WeaponSoulEvent = {
    JingZhu = "WeaponSoulEventJingZhu",
    ShengXing = "WeaponSoulEventShengXing",
    NingHun = "WeaponSoulEventNingHun",
    RefreshNingHun = "WeaponSoulEventRefreshNingHun",
    ChangeAvatar = "WeaponSoulEventChangeAvatar",
    RefreshCombat = "WeaponSoulEventRefreshCombat",
    RefreshMainUI = "WeaponSoulEventRefreshMainUI",
}

game.SwornEvent = {
    UpdateSwornInfo = "SwornEvent_UpdateSwornInfo",
    UpdatePlatformInfo = "SwornEvent_UpdatePlatformInfo",
    OnSwornGreet = "SwornEvent_OnSwornGreet",
    OnSwornModifyEnounce = "SwornEvent_OnSwornModifyEnounce",
    UpdateSeniorSortInfo = "SwornEvent_UpdateSeniorSortInfo",
    OnSwornVoteSenior = "SwornEvent_OnSwornVoteSenior",
    UpdateMemberList = "SwornEvent_UpdateMemberList",
    UpdateSwornValue = "SwornEvent_UpdateSwornValue",
    UpdateQuality = "SwornEvent_UpdateQuality",
    OnSwornModifyWord = "SwornEvent_OnSwornModifyWord",
    DeleteMember = "SwornEvent_DeleteMember",
    ModifyGroupName = "SwornEvent_ModifyGroupName",
}

game.DragonDesignEvent = {
    UpdateRefine = "DragonDesignEventUpdateRefine",
    UpdateReplace = "DragonDesignEventUpdateReplace",
    UpdateGrowth = "DragonDesignEventUpdateGrowth",
    UpdateEquip = "DragonDesignEventUpdateEquip",
    UpdateSetColor = "DragonDesignEventUpdateSetColor",
    UpdateEat = "DragonDesignEventUpdateEat",
    UpdateGetDragon = "DragonDesignEventUpdateGetDragon",
}

game.MentorEvent = {
    UpdateMentorInfo = "MentorEvent_UpdateMentorInfo",
    OnMentorRegister = "MentorEvent_OnMentorRegister",
    OnMentorFind = "MentorEvent_OnMentorFind",
    UpdateMemberList = "MentorEvent_UpdateMemberList",
    UpdatePrentice = "MentorEvent_UpdatePrentice",
}

game.MsgNoticeEvent = {
    AddMsgNotice = "MsgNoticeEvent_AddMsgNotice",
    UpdateMsgNotice = "MsgNoticeEvent_UpdateMsgNotice",
}

game.VowEvent = {
    UpdatgeVowInfo = "VowEventUpdatgeVowInfo",
    GetMyVow = "VowEventGetMyVow",
    GetOtherVow = "VowEventGetOtherVow",
    UpdateOtherAgree = "VowEventUpdateOtherAgree",
    UpdateGetReward = "VowEventUpdateGetReward"
}

game.FireworkEvent = {
    OnFireworkUse = "FireworkEvent_OnFireworkUse",
    ShowFireworkUIEffect = "FireworkEvent_ShowFireworkUIEffect",
}

game.NpcEvent = {
    UpdateEventList = "NpcEvent_UpdateEventList",
}

game.SysSettingEvent = {
    OnGetSettingInfo = "SysSettingEvent_OnGetSettingInfo",
    OnSetSettingInt = "SysSettingEvent_OnSetSettingInt",
    OnSetSettingString = "SysSettingEvent_OnSetSettingString",
}