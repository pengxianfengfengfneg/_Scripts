proto.CsArtifactGetInfo = {52201,{
}}

proto.ScArtifactGetInfo = {52202,{
        "id__I",
        "cur_avatar__I",
        "avatars__T__id@I",
        "combat_power__I",
        "a_combat_power__I",
        "stren__C",
        "stones__T__pos@C##id@I",
        "extra_attr__T__id@H##value@I",
        "pos_attr__T__pos@C##id@H##value@I",
        "chips__T__lv@C##take@C",
        "open_ui__C",
}}

proto.CsArtifactAddExtraAttr = {52203,{
        "pos__C",
}}

proto.ScArtifactAddExtraAttr = {52204,{
        "pos__C",
        "value__I",
        "combat_power__I",
        "extra_attr__T__id@H##value@I",
}}

proto.CsArtifactLvUp = {52205,{
}}

proto.ScArtifactLvUp = {52206,{
        "id__I",
        "combat_power__I",
}}

proto.CsArtifactChangeAvatar = {52207,{
        "avatar_id__I",
}}

proto.ScArtifactChangeAvatar = {52208,{
        "avatar_id__I",
}}

proto.ScArtifactRefreshAvatars = {52209,{
        "cur_avatar__I",
        "avatars__T__id@I",
        "a_combat_power__I",
}}

proto.CsArtifactTakeAward = {52210,{
        "lv__C",
}}

proto.ScArtifactUpdateNew = {52211,{
        "lv__C",
        "take__C",
}}

proto.CsArtifactActivate = {52212,{
}}

