proto.GetVipInfoReq = {10900,{
}}

proto.GetVipInfoResp = {10901,{
        "vip_level__C",
        "vip_exp__I",
        "got_gifts__T__level@C",
}}

proto.GetVipGiftReq = {10902,{
        "level__C",
}}

proto.GetVipGiftResp = {10903,{
        "ret__C",
        "level__C",
}}

proto.GetRechargeInfoReq = {10940,{
}}

proto.GetRechargeInfoResp = {10941,{
        "today_recharge__I",
        "today_recharge_money__I",
        "recharged_an__T__product_id@C",
        "recharged_ios__T__product_id@C",
}}

