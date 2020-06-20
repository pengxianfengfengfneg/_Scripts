
game.LogicTileSize = 0.5
game.LogicTileFactor = 2

local _math_floor = math.floor
local _logic_tile_factor = game.LogicTileFactor
local _logic_tile_size = game.LogicTileSize
-- game.UnitToLogicPos = function(x, y)
--     return _math_floor(_logic_tile_factor * x), _math_floor(_logic_tile_factor * y)
-- end

-- game.LogicToUnitPos = function(x, y)
--     return _logic_tile_size * x, _logic_tile_size * y
-- end

game.UnitToLogicPos = function(x, y)
    return _math_floor(_logic_tile_factor * x)+1, _math_floor(_logic_tile_factor * y)+1
end

game.LogicToUnitPos = function(x, y)
    return _logic_tile_size * (x-1), _logic_tile_size * (y-1)
end

game.UIZOrder = {
    UIZOrder_Scene              = 10,
    UIZOrder_Low                = 1000,
    UIZOrder_Main_UI            = 10000,
    UIZOrder_Common_Below       = 20000,
    UIZOrder_Common             = 30000,
    UIZOrder_Common_Beyond      = 40000,
    UIZOrder_Tips               = 50000,
    UIZOrder_Top                = 100000,
    UIZOrder_Over               = 300000,
}

game.HudItem = {
    Name = "name1",
    GuildName = "name2",
    Title = "img3",
    TeamImg = "img11",
    TeamFollowImg = "img12",
    Murder = "img13",
    NamePrefixImg = "img14",

    TouXian = "img15",
    Empty = "img16",

    TitleTxt = "name3",
    Tips = "name2",
    Title2 = "img4",
    Title2Txt = "name4",
    Title2PrefixImg = "img41",
    Title2SuffixImg = "img42",
}

game.HudColor = {
    [1] = cc.White,
	[2] = cc.Red,
	[3] = cc.Green,
	[4] = cc.Blue,
	[5] = cc.Purple,
	[6] = cc.Orange,
	[7] = cc.Yellow,
    [8] = cc.Pink,
    [9] = cc.NavyBlue,
    [10] = cc.GrayBrown,
}

game.ItemColorToHudIndex = {
    [1] = 1,
    [2] = 3,
    [3] = 4,
    [4] = 5,
    [5] = 6,
    [6] = 2,
}

-- 界面归属场景
game.UIViewType = {
    None = 0,
    Main = 1,
    Fight = 2,
}

game.UIViewLevel = {
    Guide = -2,
    Keep = -1,
    Standalone = 0,
    First = 1,
    Second = 2,
    Third = 3,
    Fouth = 4,
}

game.UIMaskType = {
    None = 0,
    Full = 1,
    FullAlpha = 2,
}

-- local _GetAreaFromName = N3DClient.GameTool.GetNavAreaFromName
-- game.NavArea = {
--     Walkable = 1<<_GetAreaFromName("Walkable"),
--     NotWalkable = 1<<_GetAreaFromName("Not Walkable"),
--     Jump = 1<<_GetAreaFromName("Jump"),
-- }

local _name_to_layer = UnityEngine.LayerMask.NameToLayer
game.LayerName = {
    Default = _name_to_layer("Default"),
    UI = _name_to_layer("UI"),
    UI2 = _name_to_layer("UI2"),
    UIDefault = _name_to_layer("UIDefault"),
    Terrain = _name_to_layer("Terrain"),
    SceneObject = _name_to_layer("SceneObject"),
    MapElementMain = _name_to_layer("MapElementMain"),
    MapElementSub = _name_to_layer("MapElementSub"),
    MapElementMin = _name_to_layer("MapElementMin"),
    MapEffect = _name_to_layer("MapEffect"),
    Height = _name_to_layer("Height"),
    ObjCollider = _name_to_layer("ObjCollider"),
    Lens = _name_to_layer("Lens"),
    Navigation = _name_to_layer("Navigation"),
    Water = _name_to_layer("Water"),
    Effect = _name_to_layer("Effect"),
    MainSceneObject = _name_to_layer("MainSceneObject"),
    SkyBox = _name_to_layer("SkyBox"),
    HeadWidget = _name_to_layer("HeadWidget"),
}

game.LayerMask = {
    Default = 1 << game.LayerName.Default,
    UI = 1 << game.LayerName.UI,
    UI2 = 1 << game.LayerName.UI2,
    UIDefault = 1 <<game.LayerName.UIDefault,
    Terrain = 1 << game.LayerName.Terrain,
    SceneObject = 1 << game.LayerName.SceneObject,
    MapElementMain = 1 << game.LayerName.MapElementMain,
    MapElementSub = 1 << game.LayerName.MapElementSub,
    MapElementMin = 1 << game.LayerName.MapElementMin,
    MapEffect = 1 << game.LayerName.MapEffect,
    Height = 1 << game.LayerName.Height,
    ObjCollider = 1 << game.LayerName.ObjCollider,
    Lens = 1 << game.LayerName.Lens,
    Navigation = 1 << game.LayerName.Navigation,
    Water = 1 << game.LayerName.Water,
    Effect = 1 << game.LayerName.Effect,
    MainSceneObject = 1 << game.LayerName.MainSceneObject,
    SkyBox = 1 << game.LayerName.SkyBox,
    HeadWidget = 1 << game.LayerName.HeadWidget,
}

game.SDKEventName = {
    LoginSuccess = "LoginSuccess",
    LogoutSuccess = "LogoutSuccess",
    AuthSuccess = "AuthSuccess",
    AuthFail = "AuthFail",
    SwitchAccount = "SwitchAccount",
}

game.Career = 
{
    GaiBang = 1,
    XiaoYao = 2,
    EMei = 3,
    TianShan = 4,    
}

game.CareerRes = {
    [game.Career.GaiBang] = "zd_05",
    [game.Career.XiaoYao] = "zd_06",
    [game.Career.EMei] = "zd_04",
    [game.Career.TianShan] = "zd_07",
}

game.CareerSchool = {
    [game.Career.GaiBang] = config.words[127],
    [game.Career.XiaoYao] = config.words[128],
    [game.Career.EMei] = config.words[129],
    [game.Career.TianShan] = config.words[130],
}

game.CareerSpineId = {
    [game.Career.GaiBang] = 12,
    [game.Career.XiaoYao] = 29,
    [game.Career.EMei] = 9,
    [game.Career.TianShan] = 24,
}

game.CareerBigSkill = {
    [game.Career.GaiBang] = 10010099,
    [game.Career.XiaoYao] = 10020099,
    [game.Career.EMei] = 10030099,
    [game.Career.TianShan] = 10040099,
}

game.Gender = 
{
    Male = 1,
    Female = 2,
}

game.ModelType = {
    Body = 1,
    Mount = 1 << 1,
    Wing = 1 << 2,
    Hair = 1 << 3,
    Weapon = 1 << 4,
    Weapon2 = 1 << 5,
    WeaponUI = 1 << 9,
    WingUI = 1 << 11,
    Camera = 1 << 12,
    AnQi = 1 << 13,
    WuHunUI = 1 << 14,
    WeaponSoul = 1 << 15,
    DragonDesign = 1 << 16,
    WeaponCreate = 1 << 17,
    WeaponCreate2 = 1 << 18,
    HairCreate = 1 << 19,
}

game.BodyType = {
    Role = 1,
    Monster = 2,
    Mount = 3,
    Wing = 4,
    Hair = 5,
    Weapon = 6,
    Npc = 7,
    Gather = 8,
    WeaponUI = 9,
    HairCreate = 10,
    RoleCreate = 11,
    Carry = 12,
    AnQi = 13,
    ModelSp = 14,
    JumpPoint = 15,
    Camera = 16,
    WingUI = 17,
    WeaponSoul = 18,
    Firework = 19,
    WeaponCreate = 20,
    WeaponCreate2 = 21,
}

game.ModelBodyMap = {
    [game.ModelType.Mount] = game.BodyType.Mount,
    [game.ModelType.Wing] = game.BodyType.Wing,
    [game.ModelType.Hair] = game.BodyType.Hair,
    [game.ModelType.Weapon] = game.BodyType.Weapon,
    [game.ModelType.Weapon2] = game.BodyType.Weapon,
    [game.ModelType.WeaponUI] = game.BodyType.WeaponUI,
    [game.ModelType.WeaponCreate] = game.BodyType.WeaponCreate,
    [game.ModelType.WeaponCreate2] = game.BodyType.WeaponCreate,
    [game.ModelType.AnQi] = game.BodyType.AnQi,
    [game.ModelType.WingUI] = game.BodyType.WingUI,
}

game.ModelNodeName = {
    Root = "root",
    RightHand = "re",
    LeftHand = "le",
    Back = "back",
    Head = "head",
    Mount = "mount",
    Camera = "camera",
    Effect1 = "tx1",
    Effect2 = "tx2",
    Effect3 = "tx3",
    Effect4 = "tx4",
    Effect5 = "tx5",
}

game.ObjState = {
    Invalid = 0,
    Idle = 1,
    Move = 2,
    Die = 3,
    Attack = 4,
    Beattack = 5,
    PreAttack = 6,
    Gather = 7,
    Jump = 8,
    Practice = 10,
    ChangeScene = 11,
    CallPet = 12,
    PlayAction = 13,
    SeatMove = 14,
}

game.ObjStateTransfer = {
    [game.ObjState.Idle] = {
        --[game.ObjState.Idle] = 1,
    },
}

game.ObjType = {
    MainRole = 1,
    Role = 2,
    Pet = 3,
    Monster = 4,
    Npc = 5,
    Gather = 6,
    Door = 7,
    Carry = 8,
    FlyItem = 9,
    JumpPoint = 10,
    WeaponSoul = 11,
    Firework = 12,
    FollowObj = 13,
}

game.ObjServerType = {
    Monster = 1,
    Role = 2,
    Pet = 3,
}

game.AoiMask = {
    Monster = 1,
    Role = 2,
    MainRole = 4,
    All = 0xff,
}

game.ObjAnimName = {
    Idle = "idle",
    Run = "run",
    Rush = "rush",
    Die = "die",
    Beattack = "beattack",
    Gather = "caiji",
    Practice = "liangong",
    ChangeScene = "caiji",
    Jump1 = "fly1",
    Jump2 = "fly2",
    Jump3 = "fly3",
    Jump4 = "fly4",
    ShowFly1 = "show_fly1",
    ShowFly2 = "show_fly2",
    Show1 = "show1",
    Show2 = "show2",
    Show3 = "show3",
    Show4 = "show4",
    Show5 = "show5",
    ShowIdle = "show_idle",
    Skill1 = "skill1",
    Skill2 = "skill2",
    Skill3 = "skill3",
    Skill4 = "skill4",
    Skill5 = "skill5",
    Skill6 = "skill6",
    Skill7 = "skill7",
    Skill8 = "skill8",
    Skill9 = "skill9",
    Skill10 = "skill10",
    Skill11 = "skill11",
    Skill12 = "skill12",
    Skill13 = "skill13",
    Skill14 = "skill14",
    Skill15 = "skill15",
    LoopSkill1 = "loop_skill1",
    LoopSkill2 = "loop_skill2",
    LoopSkill3 = "loop_skill3",
    LoopSkill4 = "loop_skill4",
    LoopSkill5 = "loop_skill5",
    LoopSkill6 = "loop_skill6",
    LoopSkill7 = "loop_skill7",
    LoopSkill8 = "loop_skill8",
    LoopSkill9 = "loop_skill9",
    LoopSkill10 = "loop_skill10",
    RideIdle = "ride_idle",
    RideIdle1 = "ride_idle1",
    RideIdle2 = "ride_idle2",
    RideIdle3 = "ride_idle3",
    RideIdle4 = "ride_idle4",
    RideIdle5 = "ride_idle5",
    RideIdle6 = "ride_idle6",
    RideIdle7 = "ride_idle7",
    RideIdle8 = "ride_idle8",
    RideIdle9 = "ride_idle9",
    RideRun = "ride_run",
    RideRun1 = "ride_run1",
    RideRun2 = "ride_run2",
    RideRun3 = "ride_run3",
    RideRun4 = "ride_run4",
    RideRun5 = "ride_run5",
    RideRun6 = "ride_run6",
    RideRun7 = "ride_run7",
    RideRun8 = "ride_run8",
    RideRun9 = "ride_run9",
    Perform_d1 = "perform_d1",
    Perform_d2 = "perform_d2",
    Perform_d3 = "perform_d3",
    Perform_d4 = "perform_d4",
    Perform_d5 = "perform_d5",
    Perform_d6 = "perform_d6",
    Perform_d7 = "perform_d7",
    Perform_d8 = "perform_d8",
    Perform_d9 = "perform_d9",
    Perform_d10 = "perform_d10",
    Perform_d11 = "perform_d11",
    Perform_d12 = "perform_d12",
    Perform_d13 = "perform_d13",
    Perform_d14 = "perform_d14",
    Perform_d15 = "perform_d15",
    Perform_d16 = "perform_d16",
    Perform_d17 = "perform_d17",
    Perform_d18 = "perform_d18",
    Perform_d19 = "perform_d19",
    Perform_d20 = "perform_d20",
    Perform_s1 = "perform_s1",
    Perform_s2 = "perform_s2",
    Perform_s3 = "perform_s3",
    Perform_s4 = "perform_s4",
    Perform_s5 = "perform_s5",
    Perform_s6 = "perform_s6",
    Perform_s7 = "perform_s7",
    Perform_s8 = "perform_s8",
    Perform_s9 = "perform_s9",
    Perform_s10 = "perform_s10",
    Perform_s11 = "perform_s11",
    Perform_s12 = "perform_s12",
    Perform_s13 = "perform_s13",
    Perform_s14 = "perform_s14",
    Perform_s15 = "perform_s15",
    Perform_s16 = "perform_s16",
    Perform_s17 = "perform_s17",
    Perform_s18 = "perform_s18",
    Perform_s19 = "perform_s19",
    Perform_s20 = "perform_s20",
}

local _string_to_hash = UnityEngine.Animator.StringToHash
game.ObjAnimHash = {}
for k,v in pairs(game.ObjAnimName) do
    game.ObjAnimHash[v] = _string_to_hash(v)
end

game.TweenEase =
{
    Unset = 0,
    Linear = 1,
    InSine = 2,
    OutSine = 3,
    InOutSine = 4,
    InQuad = 5,
    OutQuad = 6,
    InOutQuad = 7,
    InCubic = 8,
    OutCubic = 9,
    InOutCubic = 10,
    InQuart = 11,
    OutQuart = 12,
    InOutQuart = 13,
    InQuint = 14,
    OutQuint = 15,
    InOutQuint = 16,
    InExpo = 17,
    OutExpo = 18,
    InOutExpo = 19,
    InCirc = 20,
    OutCirc = 21,
    InOutCirc = 22,
    InElastic = 23,
    OutElastic = 24,
    InOutElastic = 25,
    InBack = 26,
    OutBack = 27,
    InOutBack = 28,
    InBounce = 29,
    OutBounce = 30,
    InOutBounce = 31,
    Flash = 32,
    InFlash = 33,
    OutFlash = 34,
    InOutFlash = 35,
    INTERNAL_Zero = 36,
    INTERNAL_Custom = 37,
}

game.NameFilterList = {
    '"', "'", "&", "?", "\\", "/", "-", ";", "%(", ")", "%[", "]", "{", "}", "<", ">", "%%", "@", "*", "!","系统","消息","官方","官网","公众号","公告"
}

game.MoneyType = {
    Exp         = 1,
    Gold        = 2,
    BindGold    = 3,
    Copper      = 4,
    Friend      = 9,
    GuildCont   = 10,
    Prestige    = 11,
    GuildGold   = 12,   -- 帮会通宝
    BindGoldFirst = 13, -- 绑元优先
    ForgeScore  = 14,   -- 打造积分
    Essence  = 15,      -- 百炼精华
    XiaYi       = 16,   -- 侠义值
    Silver      = 17,   -- 银两
    BackupGold  = 18,   -- 储备元宝
    WFuit = 19,         -- 许愿果
    TBall = 20,         -- 宝珠
    JiFen = 21,         -- 积分
    PeachValue = 22,    -- 桃李值
    LoveValue = 23,     -- 历史恩爱值
    FateToken = 24,     -- 天命印记
    BackupGoldFirst = 25,  -- 储备元宝优先
    SongLiao = 26,      -- 宋辽积分
    DragonDesign = 32,      -- 龙元晶粹

    -- 客户端定义
    PetExp = 100,     -- 宠物经验
}

game.MoneyIcon = {
    [game.MoneyType.Gold] = "023",
    [game.MoneyType.BindGold] = "024",
    [game.MoneyType.Copper] = "022",
}

game.MoneyGoodsId = {
    [game.MoneyType.Exp] = 16160101,
    [game.MoneyType.Gold] = 16160102,
    [game.MoneyType.BindGold] = 16160103,
    [game.MoneyType.Copper] = 16160104,
    [game.MoneyType.Friend] = 16160106,
    [game.MoneyType.GuildCont] = 16160107,
    [game.MoneyType.Prestige] = 16160108,
    [game.MoneyType.Silver] = 16160115,
}

game.ButtonChangeType = {
    UnSelected = 0,
    Selected = 1,
}

game.OpenFuncId = {
    PassTask = 0,   -- 特殊定义id，不要更改
    LevelHang = 1,  -- 特殊定义id，不要更改
    HuntNpc = 2,    -- 特殊定义id, 不要更改
    HuntMonster = 3,-- 特殊定义id，不要更改

    Fighting = 100,                     -- 战斗
    MainCity = 101,                     -- 主城
    Role = 102,                         -- 角色
    Forging = 103,                      -- 锻造
    Pet = 105,                          -- 珍兽

    GoldShop = 1000,                    -- 元宝商店
    EquipShop = 1001,                   -- 装备商店
    DecorateShop = 1002,                -- 装扮商店
    ArenaShop = 1003,                   -- 竞技商店
    Marray = 1005,                      -- 三生三世
    TaoZhuang = 1006,                   -- 套装
    Tutoo = 1007,                       -- 图腾
    Marry = 1009,                       -- 姻缘
    Hero = 1010,                        -- 英雄谱
    ShenWeapon = 1011,                  -- 神器(新)
    HideWeapon = 1012,                  -- 暗器
    Exterior = 1013,                    -- 外观
    Skill = 1014,                       -- 技能
    WeaponSoul = 1015,                  -- 武魂
    DragonDesign = 1016,                -- 龙纹

    DailyFirstCharge = 1100,            -- 每日首充
    DailyBigGift = 1101,                -- 今日豪礼
    HappyActivity = 1102,               -- 狂欢活动
    HolidayActivity = 1103,             -- 节日活动
    WonderfullActivity = 1104,          -- 精彩活动
    BenifitHall = 1105,                 -- 福利大厅
    LuckyTruning = 1106,                -- 幸运转盘
    GodPetComing = 1107,                -- 神宠来袭
    LuckyGift = 1108,                   -- 幸运好礼
    OpenActivity = 1112,                -- 开服活动
    Auction = 1113,                     -- 拍卖行
    LakeExp = 1115,                     -- 江湖历练
    Market = 1116,                      -- 商会
    Recharge = 1117,                    -- 充值
    FirstRecharge = 1118,               -- 首冲
    BlackSociety = 1119,               -- 江湖之路

    Friend = 1200,                      -- 好友
    Mail_Main = 1201,                   -- 邮件（主城）

    GodweaponPiece = 1129,              --神器碎片
    DailyTask = 1300,                   -- 日常
    Bag = 1301,                         -- 背包
    Mail_Fight = 1302,                  -- 邮件（战斗）
    WeeklyCard = 1303,                  -- 周卡
    MonthlyCard = 1304,                 -- 月卡
    FirstCharge = 1305,                 -- 首充
    CaculateCharge = 1306,              -- 累充回馈
    Rank = 1308,                        -- 排行榜

    Carbon = 1401,                      -- 副本
    Arena = 1402,                       -- 竞技场
    Guild = 1403,                       -- 帮会
    Boss = 1404,                        -- BOSS
    ActivityHall = 1405,                -- 活动大厅
    Feedback = 1406,                    -- 意见反馈

    RoleMount = 2001,                   -- 坐骑
    RoleWing = 2002,                    -- 翅膀

    PetPossessed = 2004,                -- 珍兽附体
    PetIntelligent = 2005,              -- 珍兽悟性
    PetSkill = 2006,                    -- 珍兽技能

    Achieve = 2015,                     -- 成就

    RoleSkill = 2201,                   -- 角色技能

    FoundryCuilian = 2301,              -- 锻造淬炼
    FoundryDuanlian = 2302,             -- 锻造锻炼
    FoundryJinglian = 2303,             -- 锻造精炼

    Carbon_SiJueZhuang = 2401,          -- 四绝庄副本
    Carbon_Material = 2402,             -- 材料副本

    ZhenLongQiJu = 2501,                -- 珍珑棋局

    ChosePet = 3001,                    -- 选择珍兽

    HeroGuide = 3301,                   -- 英雄指点
    Sworn = 3302,                       -- 结拜
    Mentor = 3303,                      -- 师徒
}

game.Color = {
    White =         {255,255,255,255},
    Black =         {0,0,0,255},

    Brown =         {0x42,0x2e,0x19,255},
    GrayBrown =     {0x70,0x53,0x34,255},
    DarkGreen =     {0x36,0x7a,0x21,255},
    NavyBlue =      {0x31,0x71,0xf5,255},
    Purple =        {0xa2,0x30,0xe3,255},
    Orange =        {0xd5,0x72,0x2d,255},
    Red =           {0xdb,0x47,0x34,255},
    Yellow =        {0xfe,0xc8,0x32,255},
    PaleYellow =    {0xff,0xff,0x54,255},
    GrayWhite =     {0xe0,0xd6,0xbd,255},
    YeallowWhite =  {0xfe,0xf4,0xad,255},
    Green =         {0x5f,0xc9,0x34,255},
    PaleBlue =      {0x52,0x98,0xe3,255},
}

game.ColorString = {
    White       = "ffffff",     -- 白色
    Black       = "000000",     -- 黑色

    Brown       = "422e19",
    GrayBrown   = "705334",
    DarkGreen   = "367a21",
    NavyBlue    = "3171f5",
    Purple      = "a230e3",
    Orange      = "d5722d",
    Red         = "db4734",
    Yellow      = "FEC832",
    PaleYellow  = "FFFF54",
    GrayWhite   = "e0d6bd",
    YeallowWhite = "fef4ad",
    Green       = "5fc934",
    PaleBlue    = "5298e3",
}

game.ChatBodyType = {
    None = 0,
    Left = 1,
    Right = 2,
    Sys = 3,
}

game.ChatChannel = {
    Sys = 0,            -- 系统
    World = 1,          -- 世界
    Guild = 2,          -- 帮会
    Team = 3,           -- 队伍
    TeamRecruit = 4,    -- 组队传闻
    Private = 5,        -- 私聊
    Group = 6,          -- 群聊天
    Nearby = 7,         -- 附近
    Cross = 8,          -- 跨服
    City = 9,           -- 同城
    Horn = 10,          -- 传闻
    Friend = 11,        -- 好友

    Combine = 20,       -- 综合
}

game.ChatChannelWord = {
    [game.ChatChannel.World] = config.words[1302],
    [game.ChatChannel.Guild] = config.words[1303],
    [game.ChatChannel.Team] = config.words[1304],
    [game.ChatChannel.Private] = config.words[1305],
    [game.ChatChannel.Group] = config.words[1306],
    [game.ChatChannel.Friend] = config.words[1307],
    [game.ChatChannel.Cross] = config.words[1308],
    [game.ChatChannel.Horn] = config.words[1309],
    [game.ChatChannel.Combine] = config.words[1300],
    [game.ChatChannel.Sys] = config.words[1301],
    [game.ChatChannel.TeamRecruit] = config.words[1310],
    [game.ChatChannel.Nearby] = config.words[1311],
    [game.ChatChannel.City] = config.words[1312],
}

game.ChatChannelImg = {
    [game.ChatChannel.World] = "lt_14",
    [game.ChatChannel.Guild] = "lt_15",
    [game.ChatChannel.Team] = "lt_13",
    [game.ChatChannel.Private] = "lt_13",
    [game.ChatChannel.Group] = "lt_13",
    [game.ChatChannel.Friend] = "lt_13",
    [game.ChatChannel.Cross] = "lt_18",
    [game.ChatChannel.Horn] = "lt_14",
    [game.ChatChannel.Combine] = "lt_18",
    [game.ChatChannel.Sys] = "lt_17",
    [game.ChatChannel.TeamRecruit] = "lt_13",
    [game.ChatChannel.Nearby] = "lt_16",
    [game.ChatChannel.City] = "lt_16",
}

game.ChatChannelColor = {
    [game.ChatChannel.World] = game.ColorString.Yellow,
    [game.ChatChannel.Guild] = game.ColorString.Green,
    [game.ChatChannel.Team] = game.ColorString.White,
    [game.ChatChannel.Private] = game.ColorString.Purple,
    [game.ChatChannel.Group] = game.ColorString.White,
    [game.ChatChannel.Friend] = game.ColorString.White,
    [game.ChatChannel.Cross] = game.ColorString.White,
    [game.ChatChannel.Horn] = game.ColorString.Orange,
    [game.ChatChannel.Combine] = game.ColorString.Cyan,
    [game.ChatChannel.Sys] = game.ColorString.NavyBlue,
    [game.ChatChannel.TeamRecruit] = game.ColorString.Yellow,

    [game.ChatChannel.Nearby] = game.ColorString.Yellow,
    [game.ChatChannel.City] = game.ColorString.Yellow,
}

game.ChatChannelColorRGBA = {
    [game.ChatChannel.World] = game.Color.Yellow,
    [game.ChatChannel.Guild] = game.Color.Green,
    [game.ChatChannel.Team] = game.Color.White,
    [game.ChatChannel.Private] = game.Color.Purple,
    [game.ChatChannel.Group] = game.Color.White,
    [game.ChatChannel.Friend] = game.Color.White,
    [game.ChatChannel.Cross] = game.Color.White,
    [game.ChatChannel.Horn] = game.Color.Orange,
    [game.ChatChannel.Combine] = game.Color.Cyan,
    [game.ChatChannel.Sys] = game.Color.NavyBlue,
    [game.ChatChannel.TeamRecruit] = game.Color.Yellow,

    [game.ChatChannel.Nearby] = game.Color.Yellow,
    [game.ChatChannel.City] = game.Color.Yellow,
}

game.ChatGenderColor = {
    [game.Gender.Male] = game.ColorString.NavyBlue,
    [game.Gender.Female] = game.ColorString.Purple,
}

game.ChatChannelSort = {
    {game.ChatChannel.Combine, false},
    {game.ChatChannel.Sys, false},
    {game.ChatChannel.World, true},
    {game.ChatChannel.Guild, true},
    {game.ChatChannel.Team, true},
    {game.ChatChannel.TeamRecruit, false},
    {game.ChatChannel.Nearby, true},
}

game.ChatAtChannel = {
    [game.ChatChannel.Team] = 1,
    [game.ChatChannel.Guild] = 1,
    [game.ChatChannel.Group] = 1,
}

game.TextInputType = {
    FocusIn = 1,
    FocusOut = 2,
    Change = 3,
    Submit = 4,
}

game.SkillType = {
    Normal = 1,
    Active = 2,
    Passive = 3,
    PetPassive = 4,
}

game.SkillCategory = {
    Career = 1,
    State = 2,
    Growup = 3,
    Pet = 4,
    XiaKe = 5,
    ShiMei = 6,
}

game.GrowupType = {
    Mount = 1,
    Wing = 2,
    Weapon = 3,
}

game.ExteriorType = {
    Mount = 1,
}

game.MaterialEffect = {
    Default = "default",
    Occlusion = "mat_occlusion",
    Beattack = "mat_beattack",
    EffectBlur = "mat_eff_blur",
    EffectSnap = "mat_eff_snap",
    Transparent = "mat_transparent",
    Outline = "mat_outline",
    EffectCommon = "mat_eff_common",
    EffectWave = "mat_eff_wave",
    ModelGray = "mat_modelgray"
}

local _property_to_id = UnityEngine.Shader.PropertyToID
game.MaterialProperty = {
    RimPower = _property_to_id("_RimPower"),
    RimColor = _property_to_id("_RimColor"),
    Color = _property_to_id("_Color"),
    FlashIntensity = _property_to_id("_FlashIntensity"),
}

game.CarbonType = {
    MatrialCarbon = 1,
    YanziwuCarbon = 2,
    SjzCarbon = 3,
    HeroTestCarbon = 4,
    GodMonsterCarbon = 5,
    ZlqjCarbon = 6,
    HeroTrialCarbon = 7,
    TaskCarbon = 8,
}

game.PetType = {
    Normal = 1,
    Paladin = 2,
    Sister = 3,
}

game.DesignWidth = 720
game.DesignHeight = 1280

game.UIWidth = FairyGUI.GRoot.inst.width
game.UIHeight = FairyGUI.GRoot.inst.height

game.UIScaleW = game.UIWidth / game.DesignWidth
game.UIScaleH = game.UIHeight / game.DesignHeight

game.ScreenWidth = UnityEngine.Screen.width
game.ScreenHeight = UnityEngine.Screen.height

game.SceneType = {
    NormalScene = 1,
    OutSideScene = 2,
    DungeonScene = 3,
    Special = 4,        -- 特殊 监狱、地府
    Activity = 5,       -- 活动
    RobotPvPScene = 6,
    GuildScene = 7,
    Hanging = 8,    -- 挂机场景
    Hanging_Tomb = 9,   -- 古墓挂机
    ActReady = 10,      -- 活动准备场景
}

game.NoDunAssistSceneType = {
    [game.SceneType.DungeonScene] = 1,
    [game.SceneType.Activity] = 1,
    [game.SceneType.RobotPvPScene] = 1,
    [game.SceneType.ActReady] = 1,
}

game.OperateType = {
    -- 基础操作 
    Stop = 1,
    Move = 2,
    Attack = 3,
    Talk = 4,
    ChangeScene = 5,
    Callback = 6,
    Gather = 7,
    Jump = 8,
    Practice = 9,
    Empty = 10,
    GetItem = 11,
    GetTaskReward = 12,
    OpenView = 13,
    Follow = 14,

    -- 复合操作
    Sequence = 100,
    MoveAttack = 101,
    AttackTarget = 102,
    FindWay = 103,
    Hang = 110,
    HangFindWay = 111,
    HangAttack = 112,
    HangPet = 113,
    HangRobot = 114,
    TalkToNpc = 123,
    HangMonster = 124,
    KillMonster = 125,
    HangSequence = 126,
    ClickNpc = 127,
    Joystick = 128,
    HangJoystick = 129,
    HangStay = 130,
    GoToNpc = 131,
    MakeTeamFollow = 132,
    GoToScenePos = 135,
    GoToGather = 136,
    Carry = 137,
    HangGather = 138,
    HangCatchPet = 139,
    HangTask = 140,
    HangGuildCarry = 141,
    HangTaskDungeon = 142,
    HangTaskMonster = 143,
    HangTaskGather = 144,
    HangGuildTask = 145,
    HangGuildTaskPet = 146,
    HangGuildTaskVisit = 147,
    HangGuildTaskTreasure = 148,
    HangTaskCxdt   = 149,
    HangTaskTreasureMap = 150,
    UseTreasureMap = 151,
    GoToTalkNpc = 152,
    JoystickAttack = 153,
    HangTaskCatchPet = 154,
    HangTaskThief = 155,
    GoToMonsterPos = 156,
    HangTaskExamineNew = 157,
    HangGatherQueue = 160,
    HangTaskGatherQueue = 161,
    HangDailyTask = 162,
    HangMainSubTask = 163,
    HangWeaponSoul = 164,
    HangRunloopTask = 165,
    HangDungeon = 166,
}

game.CommonlyKey = {
    JhexpKillMonNum = 1,
    JhexpRewardState = 2,
    DailyOutsideKillMon = 20,
    DailyGetLuckyMoneyTimes = 21,
    GuildTeamCarbonChallengeTimes = 22,

    CaculateRecharge = 2001,
    CaculateRechargeMoney = 2013,
    GuildTeamCarbonHelpTimes = 2023,

    -- 自定义设置保存 4001-5000
    -- int设置
    SettingIntStart = 4001,
    FirstEnter = 4001,
    SkillSetting = 4002,
    SysSetting = 4003,
    SysSetVolume = 4004,
    SmeltColor = 4005,
    MountSetting = 4006,
    QuickGahterFlag = 4007,
    GuildTaskNpcId = 4008,
    AutoUseItem = 4009,
    ExamineNewTaskNum = 4010,
    ExamineNewTaskRight = 4011,
    MentorNoticeTime = 4012,

    -- sring设置
    SettingStringStart = 4500,
    OpenFuncRecord = 4501,
    CommonlyKeyEnd = 5000,
}

game.ActivityState = {
    ACT_STATE_UNDEFINE = 0, --没定义
    ACT_STATE_PREPARE = 1, -- 准备
    ACT_STATE_ONGOING = 2, -- 进行中
    ACT_STATE_FINISH = 3, -- 已结束
    ACT_STATE_REMOVE = 4, -- 待结束
}

game.ActivityType = {
    Daily = 1,
    Open = 2,
    Merge = 3,
    Opera = 4,
    Permanent = 8,
}

game.ActivityId = {
    Overlord            = 1001,         -- 武林盟主
    GuildQuestion       = 1003,         -- 答题
    WorldBoss           = 1004,         -- 世界BOSS
    GuildDefend         = 1005,         -- 帮会守卫战
    CareerBattle        = 1006,         -- 门派竞技
    LakeBandits         = 1007,         -- 镜湖剿匪
    GuildWine           = 1008,         -- 帮会行酒令
    GuildArena          = 1009,         -- 演武堂
    Territory_1         = 1010,         -- 领地战第一阶段
    Territory_2         = 1011,         -- 领地战第二阶段
    Territory_3         = 1012,         -- 领地战第三阶段
    GuildPractice       = 1013,         -- 帮会练功
    Chess               = 1014,         -- 珍珑棋局
    GuildCarry          = 1015,         -- 帮会运镖
    LakeExp             = 1016,         -- 江湖历练
    XunQing             = 1017,         -- 众里寻卿

    CaculateCharge      = 2001,         -- 累计充值
    DiscountStore       = 2014,         -- 神秘商店
    Dividend            = 2016,         -- 开服红利

    LuckyTruning        = 4001,         -- 幸运转盘

    SongLiao            = 6001,         -- 宋辽战争
}

-- 首次loading需等待的网络返回
game.FirstLoadingRecv = {
    [30102] = 1,        -- 活动数据
    [42302] = 1,        -- 任务数据
    [25102] = 1,        -- 功能开放数据
    [25142] = 1,        -- 新手数据
    [11002] = 1,        -- 设置数据
    [20102] = 1,        -- 背包数据
}

game.PkMode = {
    Peace = 1,
    Guild = 2,
    Justice = 3,
    Team = 4,
    Server = 5,
}

game.RankId = {
    TreasureCarbon = 1022,   -- (旧)燕子坞
    TrialCarbon = 1023,   -- (旧)英雄试练
    HeroTrialCarbon = 1024,   -- 英雄试练
    OverlordRole = 1051,   -- 武林盟主-个人
    OverlordGuild = 1052,  -- 武林盟主-帮会
    MarryLove = 5001,    -- 恩爱排行榜
}

game.EmptyTable = {}

game.SysSettingKey = {
    UserSettingFlag     = 1<<0,    -- 是否已设置标记位
    ImageQuality_Low    = 1<<1,    -- 低画质
    ImageQuality_Mid    = 1<<2,    -- 中画质
    ImageQuality_High   = 1<<3,    -- 高画质

    MusicOn             = 1<<4,    -- 背景音乐开关
    SoundOn             = 1<<5,    -- 音效开关

    LowPowerMode        = 1<<6,    -- 省电模式

    MaskMonster         = 1<<7,    -- 屏蔽怪物
    MaskFriend          = 1<<8,    -- 屏蔽友方
    MaskPlayer          = 1<<9,    -- 屏蔽所有玩家
    MaskPet             = 1<<10,   -- 屏蔽珍兽
    MaskShake           = 1<<11,   -- 屏蔽震屏
    MaskPlayerTitle     = 1<<12,   -- 屏蔽玩家称号
    MaskPlayerEffect    = 1<<13,   -- 屏蔽玩家特效

    AutoUseKeepExp      = 1<<14,   -- 自动使用天灵丹
}

game.DefaultSysSetting = {
    [game.SysSettingKey.UserSettingFlag]        = 1,
    [game.SysSettingKey.ImageQuality_Mid]       = 1,
    [game.SysSettingKey.MusicOn]                = 1,
    [game.SysSettingKey.SoundOn]                = 1,
    [game.SysSettingKey.MaskPlayerEffect]       = 1,
}

game.ItemColor = {
    [1] = game.ColorString.White,
    [2] = game.ColorString.Green,
    [3] = game.ColorString.NavyBlue,
    [4] = game.ColorString.Purple,
    [5] = game.ColorString.Orange,
    [6] = game.ColorString.Red,
}

game.ItemColor2 = {
    [1] = game.Color.White,
    [2] = game.Color.Green,
    [3] = game.Color.NavyBlue,
    [4] = game.Color.Purple,
    [5] = game.Color.Orange,
    [6] = game.Color.Red,
}

game.TitleUIColor = {
    [1] = game.ColorString.GrayBrown,
}
setmetatable(game.TitleUIColor, {__index = game.ItemColor})

game.TitleUIColor2 = {
    [1] = game.Color.GrayBrown,
}
setmetatable(game.TitleUIColor2, {__index = game.ItemColor2})

game.OwnerType = {
    None = 0,
    Self = 1,
    Others = 2,
}

game.TeamFollowState = {
    None        = 0,    -- 默认空值
    NoFollow    = 1,    -- 非跟随
    CloseTo     = 2,    -- 靠近
    Follow      = 3,    -- 跟随
}

game.AiType = {
    TeamFollow = 1,
}

game.AiClassConfig = {
    [game.AiType.TeamFollow] = require("game/ai/ai_team_follow"),
}

game.FieldBattlePkConfig = 
{
    [1] = {2,3},
    [2] = {4,5},
    [3] = {6,7},
    [4] = {8,9},
    [5] = {10,11},
    [6] = {12,13},
    [7] = {14,15}
}

game.TimeFormatCn = {
    DayHourMinSec = 1,
    DayHourMin = 2,
    DayHour = 3,
    Day = 4,
    HourMinSec = 5,
    HourMin = 6,
    Hour = 7,
    MinSec = 8,
    Min = 9,
    Sec = 10
}

game.TimeFormatEn = {
    HourMinSec = 1,
    HourMin = 2,
    MinSec = 3,
    Sec = 4,
}

-- 任务状态
game.TaskState = {
    NotAcceptable = 0,
    Acceptable = 1,
    Accepted = 2,
    Finished = 3,
    GetReward = 4,
}

game.TaskStateWord = {
    [game.TaskState.Acceptable] = "",
    [game.TaskState.Accepted] = "",
    [game.TaskState.Finished] = config.words[2193],
    [game.TaskState.GetReward] = "",
}

-- 任务分类
game.TaskCate = {
    Main        = 1,    -- 主线
    Branch      = 2,    -- 支线
    Daily       = 3,    -- 日常
    RunLoop     = 4,    -- 跑环
}

game.TaskType = {
    Main            = 11,   -- 主线
    Branch          = 21,   -- 支线
    GuildTask       = 31,   -- 帮会任务
    BanditTask      = 32,   -- 马贼任务
    TreasureTask    = 33,   -- 藏宝图
    RobberTask      = 34,   -- 惩凶打图
    YunbiaoTask     = 35,   -- 帮会运镖
    WulinReward     = 36,   -- 武林悬赏令
    DailyTask       = 37,   -- 每日任务
    Metall          = 38,   -- 小金矿任务
    BigMetall       = 39,   -- 大金矿任务
    MentorStudy     = 41,   -- 修学录目标
    MentorTask      = 42,   -- 师门任务
    MentorAdvance   = 43,   -- 太学册目标
    RunLoop1         = 401,   -- 跑环1
    RunLoop2         = 402,   -- 跑环2
    RunLoop3         = 403,   -- 跑环3
    RunLoop4         = 404,   -- 跑环4
    RunLoop5         = 405,   -- 跑环5
}

game.TaskCateName = {
    [game.TaskCate.Main] = config.words[2161],
    [game.TaskCate.Branch] = config.words[2162],
    [game.TaskCate.Daily] = config.words[2163],
    [game.TaskCate.RunLoop] = config.words[2164],
}

game.TaskTypeName = {
    [game.TaskType.Main] = config.words[2161],
    [game.TaskType.Branch] = config.words[2162],
    [game.TaskType.GuildTask] = config.words[2187],
    [game.TaskType.BanditTask] = config.words[2188],
    [game.TaskType.TreasureTask] = config.words[2188],
    [game.TaskType.RobberTask] = config.words[2163],
    [game.TaskType.YunbiaoTask] = config.words[2188],
    [game.TaskType.RunLoop1] = config.words[2164],
    [game.TaskType.RunLoop2] = config.words[2164],
    [game.TaskType.RunLoop3] = config.words[2164],
    [game.TaskType.RunLoop4] = config.words[2164],
    [game.TaskType.RunLoop5] = config.words[2164],
    [game.TaskType.DailyTask] = config.words[2197],
    [game.TaskType.WulinReward] = config.words[2163],
    [game.TaskType.Metall] = config.words[2187],
    [game.TaskType.BigMetall] = config.words[2187],
}

game.DailyTaskId = {
    GuildTask = 30001,
    BanditTask = 30002,
    TreasureTask = 30003,
    RobberTask = 30004,
    YunbiaoTask = 30005,
    RunLoop = 30006,
    WulinReward = 30007,
    DailyTask = 30101,
    Metall = 30201,
}

game.GuildTaskType = {
    Collection      = 1,    -- 收集资源
    FightCrime      = 2,    -- 除暴安良
    VisitFamous     = 3,    -- 拜访名士
    HuntPet         = 4,    -- 奇珍异物
    RareTreasure    = 5,    -- 稀世之宝
}

game.MetallTaskType = {
    Explore = 1,            -- 探索金矿
    Carry = 2,              -- 运回金矿
    Gather = 3,             -- 采集金矿
}

game.FriendGroupTypeName = {
    [1] = config.words[1723],
    [2] = config.words[1724],
    [3] = config.words[1725],
    [4] = config.words[1726],
    [5] = config.words[1727],
    [6] = config.words[1728],
    [7] = config.words[1729],
    [8] = config.words[1730],
    [11] = config.words[1731],
    [12] = config.words[1732],
}

game.FriendRelationName = {
    [0] = config.words[1745],
    [1] = config.words[1746],
    [2] = config.words[1747],
    [3] = config.words[1748],
    [4] = config.words[1749],
    [5] = config.words[1750],
    [6] = config.words[1769],
}

game.FriendRelationColor = {
    [0] = game.Color.White,
    [1] = game.Color.Yellow,
    [2] = game.Color.Blue,
    [3] = game.Color.Purple,
    [4] = game.Color.Orange,
    [5] = game.Color.DarkGreen,
    [6] = game.Color.Black,
}

game.GuildPos = {
    Mass = 1,
    Elite = 2,
    Elder = 3,
    ViceChief = 4,
    Chief = 5,
}

local MoneyItemMap = {}
for _,v in ipairs(config.money_type or {}) do
    MoneyItemMap[v.goods] = v
end
game.MoneyItemMap = MoneyItemMap

local total_exp = 0
local RoleLvTotalExp = {}
for k,v in ipairs(config.level) do
    RoleLvTotalExp[k] = total_exp
    total_exp = total_exp + v.exp
end
game.RoleLvTotalExp = RoleLvTotalExp
game.RoleMaxExp = total_exp

local total_exp = 0
local PetLvTotalExp = {}
for k,v in ipairs(config.pet_level) do
    PetLvTotalExp[k] = total_exp
    total_exp = total_exp + v.exp
end
game.PetLvTotalExp = PetLvTotalExp
game.PetMaxExp = total_exp

game.GetViewRoleType = {
    Arena = 1,
    Rank = 2,
    Guild = 3,
    ViewOthers = 4,
    ViewPet = 5,
    ViewEquip1 = 11,
    ViewEquip2 = 12,
    ViewEquip3 = 13,
    ViewEquip4 = 14,
    ViewEquip5 = 15,
    ViewEquip6 = 16,
    ViewEquip7 = 17,
    ViewEquip8 = 18,
}

game.OpType = {
    MonDrop = 43,       --怪物死亡掉落
}

game.TeamMemAttrTypes = {
    Hp = 1,
    MaxHp = 2,
    Lv = 3,
    Career = 4,
    Offline = 5,
    Scene = 6,
    Line = 7,
}

game.GetSkillTypeName = {
    [1] = config.words[6114],
    [2] = config.words[6115],
    [3] = config.words[6116],
    [4] = config.words[6117],
}

game.MsgNoticeType = {
    System = 1,
    Activity = 2,
    Social = 3,
}

game.MsgNoticeId = {
    -- 系统消息
    GoodsExpired = 1001,

    TeamInvite = 1004,
    FindMentor = 1011,
    FindMentorSp = 1012,

    -- 活动消息
    WuLin             = 2001,
    SongLiao          = 2002,
    Overlord          = 2003,
    GuildDefend       = 2004,
    CareerBattle      = 2005,
    LakeBandits       = 2006,
    GuildWine         = 2007,
    GuildArena        = 2008,
    GuildPractice     = 2009,
    ZhenLongQiJu      = 2010,
    GuildCarry        = 2011,
    Territory_1       = 2012,
    Territory_2       = 2012,
    Territory_3       = 2012,
    XunQing           = 2013,

    -- 社交消息
    AddFriend   = 3001,
}

game.ActToMsgNoticeId = {
    [game.ActivityId.WorldBoss]             = 2001,
    [game.ActivityId.SongLiao]          = 2002,
    [game.ActivityId.Overlord]          = 2003,
    [game.ActivityId.GuildDefend]       = 2004,
    [game.ActivityId.CareerBattle]      = 2005,
    [game.ActivityId.LakeBandits]       = 2006,
    [game.ActivityId.GuildWine]         = 2007,
    [game.ActivityId.GuildArena]        = 2008,
    [game.ActivityId.GuildPractice]     = 2009,
    [game.ActivityId.Chess]      = 2010,
    [game.ActivityId.GuildCarry]        = 2011,
    [game.ActivityId.Territory_1]       = 2012,
    [game.ActivityId.Territory_2]       = 2012,
    [game.ActivityId.Territory_3]       = 2012,
    [game.ActivityId.XunQing]           = 2013,
}

game.ShopId = {
    Gold = 1,
    BindGold = 2,
    Silver = 3,
    PrenticeGift = 39,
}

game.MakeTeamCommand = {
    LakeExp = "command_lake_exp",
    Cxdt = "command_cxdt",
    Dbmz = "command_dbmz",
}

game.DungeonId = {
    Chess = 1200,
    SingleChess = 3004,
}

game.CatchPetCode = {
    FullPet = 1,
    LackRope = 2,
}

game.RoleSizeCfg = require("anim/model/config_role_size")
game.MonsterSizeCfg = require("anim/model/config_monster_size")