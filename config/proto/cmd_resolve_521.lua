proto.CarryInfoReq = {52101,{
}}

proto.CarryInfoResp = {52102,{
        "carry_times__C",
        "rob_times__C",
        "quality__C",
        "line__C",
        "stat__C",
        "expire_time__I",
        "carry_scene__I",
        "carry_x__H",
        "carry_y__H",
        "refresh_times__H",
}}

proto.BookCarryReq = {52103,{
}}

proto.NotifyCarry = {52104,{
        "quality__C",
        "refresh_times__H",
}}

proto.RefreshCarryReq = {52105,{
        "type__C",
}}

proto.StartCarryReq = {52106,{
}}

proto.SubmitCarryReq = {52107,{
}}

proto.TransferToCarryReq = {52108,{
}}

proto.NotifyCarryPos = {52109,{
        "scene_id__I",
        "x__H",
        "y__H",
}}

