proto.CsMarketInfo = {42501,{
}}

proto.ScMarketInfo = {42502,{
        "volume__I",
        "turnover__I",
        "use_gold__I",
        "items__T__item@U|CltMarketGoods|",
        "follow__T__item@U|CltMarketGoods|",
}}

proto.CsMarketLog = {42503,{
}}

proto.ScMarketLog = {42504,{
        "logs__T__action@C##name@s##num@H##mtype@C##money@I##time@I",
}}

proto.CsMarketSearch = {42505,{
        "tag__C",
        "id__I",
        "stat__C",
}}

proto.ScMarketSearch = {42506,{
        "tag__C",
        "id__I",
        "stat__C",
        "items__T__item@U|CltMarketGoods|",
}}

proto.CsMarketRareItem = {42507,{
        "uid__L",
}}

proto.ScMarketRareItem = {42508,{
        "item__U|CltMarketGoods|",
        "goods__U|GoodsInfo|",
}}

proto.CsMarketRarePet = {42509,{
        "uid__L",
}}

proto.ScMarketRarePet = {42510,{
        "item__U|CltMarketGoods|",
        "pet__U|CltPet|",
}}

proto.CsMarketFollow = {42511,{
        "uid__L",
        "opt__C",
}}

proto.ScMarketFollow = {42512,{
        "uid__L",
        "opt__C",
}}

proto.CsMarketPutOn = {42513,{
        "type__C",
        "pos__L",
        "price__I",
        "num__H",
}}

proto.ScMarketPutOn = {42514,{
        "items__T__item@U|CltMarketGoods|",
}}

proto.CsMarketTakeOff = {42515,{
        "uid__L",
}}

proto.ScMarketTakeOff = {42516,{
        "uid__L",
}}

proto.CsMarketResale = {42517,{
        "uid__L",
}}

proto.ScMarketResale = {42518,{
        "items__T__item@U|CltMarketGoods|",
}}

proto.CsMarketBuy = {42519,{
        "uid__L",
        "type__C",
        "id__I",
        "price__I",
        "num__H",
}}

proto.ScMarketBuy = {42520,{
}}

proto.ScMarketRefreshItem = {42521,{
        "item__U|CltMarketGoods|",
}}

