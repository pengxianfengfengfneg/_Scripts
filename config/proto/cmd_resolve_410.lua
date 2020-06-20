proto.GetPetBagReq = {41001,{
}}

proto.GetPetBagResp = {41002,{
        "pet_list__T__pet@U|CltPet|",
}}

proto.GetPetDepotReq = {41003,{
}}

proto.GetPetDepotResp = {41004,{
        "depot_size__C",
        "dpet_list__T__dpet@U|CltDpet|",
}}

proto.GetDpetDetailReq = {41005,{
        "grid__C",
}}

proto.GetDpetDetailResp = {41006,{
        "pet__U|CltPet|",
}}

proto.ActivePet = {41007,{
        "goods_id__I",
}}

proto.NotifyPetChange = {41008,{
        "type__C",
        "pets__T__pet@U|CltPet|",
}}

proto.NotifyDelPet = {41009,{
        "type__C",
        "grids__T__grid@C",
}}

proto.UpgradeSavvyReq = {41010,{
        "grid__C",
}}

proto.NotifyDpetChange = {41011,{
        "dpets__T__dpet@U|CltDpet|",
}}

proto.FreePetReq = {41012,{
        "grid__C",
}}

proto.WithdrawPetReq = {41013,{
        "grid__C",
}}

proto.DepotPetReq = {41014,{
        "grid__C",
}}

proto.UpgradeGrowupReq = {41015,{
        "grid__C",
}}

proto.PetInheritReq = {41016,{
        "material__C",
        "target__C",
        "type__C",
}}

proto.PetFightReq = {41017,{
        "grid__C",
}}

proto.PetRestReq = {41018,{
}}

proto.UpgradeSavvyResp = {41019,{
        "ret_code__C",
}}

proto.UpgradeGrowupResp = {41020,{
        "ret_code__C",
}}

proto.GetHatchInfoReq = {41021,{
}}

proto.GetHatchInfoResp = {41022,{
        "stat__C",
        "hatch_id__L",
        "data__I",
        "materials__T__role_id@L##cid@H##growup_lv@C",
}}

proto.HatchPetReq = {41023,{
        "type__C",
}}

proto.SyncPetHatchPannel = {41024,{
        "hatch_id__L",
        "type__C",
        "pet_babies__T__role_id@L##is_lock@C##cid@H##name@s##growup_lv@C##growup@H",
}}

proto.PetHatchCancel = {41025,{
        "hatch_id__L",
}}

proto.PetHatchOn = {41026,{
        "hatch_id__L",
        "pet_grid__C",
}}

proto.PetHatchOff = {41027,{
        "hatch_id__L",
}}

proto.PetHatchLock = {41028,{
        "hatch_id__L",
}}

proto.PetHatchUnlock = {41029,{
        "hatch_id__L",
}}

proto.PetHatchStart = {41030,{
        "hatch_id__L",
}}

proto.PetHatchSelf = {41031,{
        "hatch_id__L",
        "grids__T__grid@C",
}}

proto.GetHatchedLuckyReq = {41033,{
}}

proto.GetHatchedLuckyResp = {41034,{
        "lucky__H",
}}

proto.GetHatchedPet = {41035,{
        "hatch_id__L",
}}

proto.LearnPetSkillReq = {41041,{
        "pet_grid__C",
        "skill_grid__C",
        "skill_id__I",
}}

proto.ForgetPetSkillReq = {41042,{
        "pet_grid__C",
        "skill_grid__C",
}}

proto.UpgradePetSkillReq = {41043,{
        "pet_grid__C",
        "skill_grid__C",
        "stone_num__C",
}}

proto.GetPetAttachInfoReq = {41051,{
}}

proto.GetPetAttachInfoResp = {41052,{
        "attach_list__T__attach@U|CltAttach|",
}}

proto.PetAttachReq = {41053,{
        "attach_id__C",
        "pet_grid__C",
}}

proto.PetUnattachReq = {41054,{
        "attach_id__C",
}}

proto.PutonInternalReq = {41055,{
        "attach_id__C",
        "internal_grid__C",
        "internal__C",
}}

proto.UpgradeInternalReq = {41056,{
        "attach_id__C",
        "internal_grid__C",
}}

proto.ClearInternalReq = {41057,{
        "attach_id__C",
        "internal_grid__C",
}}

proto.NotifyAttachChange = {41058,{
        "attach__U|CltAttach|",
}}

proto.PetRenameReq = {41071,{
        "grid__C",
        "name__s",
}}

proto.ActiveGodPetReq = {41072,{
        "pet_cid__H",
}}

proto.GodPetAwakenReq = {41073,{
        "pet_grid__C",
}}

proto.NotifyFightPetLevelExp = {41074,{
        "level__C",
        "exp__L",
        "dl_exp__I",
        "add_exp__L",
}}

