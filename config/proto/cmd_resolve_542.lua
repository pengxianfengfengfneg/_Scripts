proto.CsMentorInfo = {54201,{
}}

proto.ScMentorInfo = {54202,{
        "mentor_id__L",
        "mentor_quiz_list__T__index@C##choice@C",
        "tudi_quiz_list__T__index@C##choice@C",
        "open_ui__C",
        "info_list__T__info@U|MentorBaseInfo|",
        "tudi_list__T__tudi@U|MentorTudiInfo|",
        "morality__I",
        "mentor_lv__C",
        "registered__C",
}}

proto.CsMentorBegin = {54203,{
}}

proto.ScMentorBegin = {54204,{
        "mentor_name__s",
}}

proto.CsMentorBeginConfirm = {54205,{
        "choice__C",
}}

proto.CsMentorAnswerQuiz = {54206,{
        "type__C",
        "quiz_list__T__index@C##choice@C",
}}

proto.CsMentorRegister = {54207,{
        "registered__C",
}}

proto.ScMentorRegister = {54208,{
        "registered__C",
}}

proto.CsMentorFind = {54209,{
}}

proto.ScMentorFind = {54210,{
        "mentors__T__mentor@U|MentorBaseInfo|",
}}

proto.CsMentorSendPost = {54211,{
        "role_id__L",
        "enounce__s",
}}

proto.ScMentorBaseInfoListUpdate = {54212,{
        "info_list__T__info@U|MentorBaseInfo|",
}}

proto.ScMentorTudiInfoListUpdate = {54213,{
        "tudi_list__T__tudi@U|MentorTudiInfo|",
}}

proto.CsMentorSetTasks = {54214,{
        "role_id__L",
        "task_id_list__T__id@I",
}}

proto.ScMentorTaskListUpdate = {54215,{
        "role_id__L",
        "replace__C",
        "mentor_tasks__T__id@H##progress@H",
}}

proto.ScMentorLearnTaskListUpdate = {54216,{
        "role_id__L",
        "replace__C",
        "learn_tasks__T__id@H##progress@H",
}}

proto.ScMentorTaixueTaskListUpdate = {54217,{
        "role_id__L",
        "replace__C",
        "taixue_tasks__T__id@H##progress@H",
}}

proto.ScMentorCommentUi = {54218,{
}}

proto.CsMentorComment = {54219,{
        "comment__C",
}}

proto.ScMentorComment = {54220,{
        "role_id__L",
        "comment__C",
}}

proto.CsMentorFinishLearning = {54221,{
        "role_id__L",
}}

proto.ScMentorRefreshNew = {54222,{
        "mentor_id__L",
        "morality__I",
        "mentor_lv__C",
}}

proto.ScMentorSeniorTudiUi = {54223,{
        "msg__s",
}}

proto.CsMentorSeniorTudiConfirm = {54224,{
        "choice__C",
}}

proto.CsMentorBeginPractice = {54225,{
}}

proto.ScMentorBeginPractice = {54226,{
        "role_id__L",
        "practice_num__C",
}}

proto.CsMentorKickOffTudi = {54227,{
        "role_id__L",
        "reason__C",
}}

proto.ScMentorDelBaseInfoUpdate = {54228,{
        "del_id_list__T__id@L",
}}

proto.ScMentorDelTudiInfoUpdate = {54229,{
        "del_id_list__T__id@L",
}}

proto.CsMentorSayGoodbye = {54230,{
}}

proto.CsMentorTakeTaskAward = {54231,{
        "role_id__L",
}}

proto.ScMentorTakeTaskAward = {54232,{
        "role_id__L",
        "award_taken__C",
}}

