proto.CsFriendInfo = {41101,{
}}

proto.ScFriendInfo = {41102,{
        "recv_num__C",
        "follow__T__role@U|CltFriend|",
        "follower__T__role@U|CltFriend|",
        "blacklist__T__role@U|CltFriend|",
}}

proto.CsFriendFollow = {41103,{
        "type__C",
        "id__L",
}}

proto.ScFriendFollow = {41104,{
        "type__C",
        "friend__U|CltFriend|",
}}

proto.CsFriendUnfollow = {41105,{
        "id__L",
}}

proto.ScFriendUnfollow = {41106,{
        "id__L",
}}

proto.ScFriendFollowNotify = {41107,{
        "friend__U|CltFriend|",
}}

proto.ScFriendUnfollowNotify = {41108,{
        "id__L",
}}

proto.CsFriendAddBlack = {41109,{
        "id__L",
}}

proto.ScFriendAddBlack = {41110,{
        "id__L",
}}

proto.CsFriendDelBlack = {41111,{
        "id__L",
}}

proto.ScFriendDelBlack = {41112,{
        "id__L",
}}

proto.ScFriendAddBlackNotify = {41113,{
        "id__L",
}}

proto.CsFriendRecommend = {41115,{
}}

proto.ScFriendRecommend = {41116,{
        "list__T__role@U|CltFriend|",
}}

proto.CsFriendSearch = {41117,{
        "name__s",
}}

proto.ScFriendSearch = {41118,{
        "list__T__role@U|CltFriend|",
}}

proto.CsFriendGiveCoin = {41119,{
        "id__L",
}}

proto.ScFriendGiveCoin = {41120,{
        "ids__T__id@L",
}}

proto.CsFriendRecvCoin = {41121,{
        "id__L",
}}

proto.ScFriendRecvCoin = {41122,{
        "recv_num__C",
        "ids__T__id@L",
}}

proto.ScFriendGiveCoinNotify = {41123,{
        "id__L",
}}

proto.ScFriendOnlineNotify = {41124,{
        "id__L",
        "offline__I",
}}

