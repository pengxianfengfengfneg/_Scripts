proto.CsAnqiGetInfo = {52601,{
}}

proto.ScAnqiGetInfo = {52602,{
        "id__I",
        "q_level__I",
        "combat_power__I",
        "stren__C",
        "stones__T__pos@C##id@I",
        "practice_lv__C",
        "practice_exp__I",
        "cur_plan__C",
        "end_plan_cd_time__I",
        "skill_plans__T__plan@U|AnqiSkillPlan|",
        "origin_attr__T__id@H##value@I",
        "add_attr__T__id@H##value@I",
        "poison_slots__T__slot@U|AnqiPoisonSlot|",
}}

proto.CsAnqiPractice = {52603,{
}}

proto.ScAnqiPractice = {52604,{
        "combat_power__I",
        "practice_lv__C",
        "practice_exp__I",
        "origin_attr__T__id@H##value@I",
        "add_attr__T__id@H##value@I",
}}

proto.CsAnqiForge = {52605,{
}}

proto.ScAnqiForge = {52606,{
        "id__I",
        "combat_power__I",
        "origin_attr__T__id@H##value@I",
        "add_attr__T__id@H##value@I",
}}

proto.CsAnqiLvUp = {52607,{
}}

proto.ScAnqiLvUp = {52608,{
        "q_level__I",
        "combat_power__I",
        "add_attr__T__id@H##value@I",
}}

proto.CsAnqiChangePlan = {52609,{
        "plan__C",
}}

proto.ScAnqiChangePlan = {52610,{
        "plan__C",
        "end_plan_cd_time__I",
}}

proto.CsAnqiUnlockPlan = {52611,{
        "plan__C",
}}

proto.ScAnqiUnlockPlan = {52612,{
        "plan__C",
}}

proto.CsAnqiRefreshPlan = {52613,{
}}

proto.ScAnqiRefreshPlan = {52614,{
        "skill_plan__U|AnqiSkillPlan|",
}}

proto.CsAnqiReplacePlan = {52615,{
        "plan__C",
}}

proto.ScAnqiReplacePlan = {52616,{
        "skill_plan__U|AnqiSkillPlan|",
}}

proto.ScAnqiNewPlanUpdate = {52617,{
        "cur_plan__C",
        "skill_plan__U|AnqiSkillPlan|",
}}

proto.CsAnqiOpenPoisonSlot = {52618,{
        "index__C",
}}

proto.CsAnqiCreatePoison = {52619,{
        "index__C",
}}

proto.CsAnqiReplacePoisonAttr = {52620,{
        "index__C",
}}

proto.ScAnqiPoisonSlotUpdate = {52621,{
        "poison_slot__U|AnqiPoisonSlot|",
}}

