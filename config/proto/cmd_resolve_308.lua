proto.CsAuctionInfo = {30801,{
}}

proto.ScAuctionInfo = {30802,{
        "guild__T__aid@L##uid@L##cid@H##value@C##price@I##expire@I##top@L##bid@I",
        "world__T__aid@L##uid@L##cid@H##value@C##price@I##expire@I##top@L##bid@I",
}}

proto.CsAuctionLogs = {30803,{
        "type__C",
}}

proto.ScAuctionLogs = {30804,{
        "type__C",
        "logs__T__time@I##cid@H##price@I##type@C",
}}

proto.CsAuctionBid = {30805,{
        "aid__L",
        "uid__L",
        "type__C",
}}

proto.ScAuctionBid = {30806,{
        "aid__L",
        "uid__L",
        "type__C",
}}

proto.CsAuctionItem = {30807,{
        "aid__L",
        "uid__L",
}}

proto.ScAuctionItem = {30808,{
        "aid__L",
        "uid__L",
        "price__I",
        "top__L",
        "bid__I",
        "state__C",
}}

proto.ScAuctionItemNotify = {30809,{
        "aid__L",
        "uid__L",
        "top__L",
        "price__I",
        "state__C",
}}

proto.ScAuctionNotifyNew = {30810,{
}}

