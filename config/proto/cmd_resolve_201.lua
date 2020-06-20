proto.CsBagGetInfo = {20101,{
}}

proto.ScBagGetInfo = {20102,{
        "bags__T__bag@U|BagInfo|",
}}

proto.CsBagClean = {20103,{
        "bag_id__C",
}}

proto.ScBagClean = {20104,{
        "bag_id__C",
}}

proto.CsBagSellItem = {20105,{
        "bag_id__C",
        "poses__T__pos@H",
}}

proto.ScBagSellItem = {20106,{
        "bag_id__C",
        "poses__T__pos@H",
}}

proto.CsBagExtendCell = {20107,{
        "bag_id__C",
        "num__H",
}}

proto.ScBagExtendCell = {20108,{
        "bag_id__C",
        "cell_num__H",
}}

proto.CsBagClear = {20109,{
        "bag_id__C",
}}

proto.ScBagClear = {20110,{
        "bag_id__C",
}}

proto.ScBagChange = {20111,{
        "changes__T__change@U|BagChange|",
}}

proto.CsBagExtendBag = {20113,{
        "bag_id__C",
}}

proto.ScBagExtendBag = {20114,{
        "bag__U|BagInfo|",
}}

proto.CsBagChangeName = {20115,{
        "bag_id__C",
        "name__s",
}}

proto.ScBagChangeName = {20116,{
        "bag_id__C",
        "name__s",
}}

proto.CsBagTransfer = {20117,{
        "src_bag__C",
        "dst_bag__C",
        "pos__H",
}}

proto.ScBagTransfer = {20118,{
        "src_bag__C",
        "dst_bag__C",
        "pos__H",
}}

proto.CsBagGetBag = {20119,{
        "bag_id__C",
}}

proto.ScBagGetBag = {20120,{
        "bag__U|BagInfo|",
}}

proto.CsUseGoods = {20141,{
        "pos__H",
        "num__H",
        "arg__C",
}}

