
cc = cc or {}

function cc.vec2(_x, _y)
    return { x = _x, y = _y }
end

function cc.vec3(_x, _y, _z)
    return { x = _x, y = _y, z = _z }
end

function cc.vec4(_x, _y, _z, _w)
    return { x = _x, y = _y, z = _z, w = _w }
end

-- 2
function cc.pSet(pt,x,y)
    pt.x = x
    pt.y = y
end

function cc.pAdd(pt1,pt2)
    return {x = pt1.x + pt2.x, y = pt1.y + pt2.y }
end

function cc.pSub(pt1,pt2)
    return {x = pt1.x - pt2.x, y = pt1.y - pt2.y }
end

function cc.pMul(pt1,factor)
    return { x = pt1.x * factor , y = pt1.y * factor }
end

function cc.pMidpoint(pt1,pt2)
    return { x = (pt1.x + pt2.x) / 2.0 , y = ( pt1.y + pt2.y) / 2.0 }
end

function cc.pGetLength(pt)
    return math.sqrt( pt.x * pt.x + pt.y * pt.y )
end

function cc.pGetLengthXY(x, y)
    return math.sqrt(x * x + y * y)
end

function cc.pNormalize(pt)
    local length = cc.pGetLength(pt)
    if 0 == length then
        return { x = 1.0,y = 0.0 }
    end

    return { x = pt.x / length, y = pt.y / length }
end

function cc.pGetDistance(startP,endP)
    return cc.pGetLengthXY(startP.x - endP.x, startP.y - endP.y)
end

function cc.pDistanceSQ(pt1,pt2)
    local x = pt1.x - pt2.x
    local y = pt1.y - pt2.y
    return x * x + y * y
end

function cc.pNormalizeV(x, y)
    local len = math.sqrt(x * x + y * y)
    if 0 == len then
        return 1.0, 0.0
    end
    return x / len, y / len
end

function cc.pRotate(pt1, pt2)
    return pt1.x * pt2.x - pt1.y * pt2.y, pt1.x * pt2.y + pt1.y * pt2.x
end

function cc.pForAngle(a)
    return { x = math.cos(a), y = math.sin(a) }
end
--

-- 3
function cc.pSet3(pt,x,y,z)
    pt.x = x
    pt.y = y
    pt.z = z
end

function cc.pAdd3(pt1,pt2)
    return {x = pt1.x + pt2.x, y = pt1.y + pt2.y , z = pt1.z + pt2.z }
end

function cc.pSub3(pt1,pt2)
    return {x = pt1.x - pt2.x, y = pt1.y - pt2.y , z = pt1.z - pt2.z }
end

function cc.pMul3(pt1,factor)
    return { x = pt1.x * factor , y = pt1.y * factor , z = pt1.z * factor }
end

function cc.pMidpoint3(pt1,pt2)
    return { x = (pt1.x + pt2.x) / 2.0 , y = ( pt1.y + pt2.y) / 2.0 , z = ( pt1.z + pt2.z) / 2.0 }
end

function cc.pGetLength3(pt)
    return math.sqrt( pt.x * pt.x + pt.y * pt.y + pt.z * pt.z )
end

function cc.pNormalize3(pt)
    local length = cc.pGetLength3(pt)
    if 0 == length then
        return { x = 1.0,y = 0.0 }
    end

    return { x = pt.x / length, y = pt.y / length, z = pt.z / length }
end

function cc.pGetDistance3(startP,endP)
    return cc.pGetLength3(cc.pSub3(startP,endP))
end

function cc.pNormalize3V(x, y, z)
    local len = math.sqrt(x * x + y * y + z * z)
    if 0 == len then
        return 1.0, 0.0, 0.0
    end
    return x / len, y / len, z / len
end
--

function cc.pFuzzyEqual(pt1,pt2,variance)
    if (pt1.x - variance <= pt2.x) and (pt2.x <= pt1.x + variance) and (pt1.y - variance <= pt2.y) and (pt2.y <= pt1.y + variance) then
        return true
    else
        return false
    end
end

local math_abs = math.abs
function cc.pGetManhattanDistance(p1, p2)
    return math_abs(p1.x - p2.x) + math_abs(p1.y - p2.y)
end

function cc.isFaceTo(my_pt, target_pt, dir)
    local dx = target_pt.x - my_pt.x
    local dy = target_pt.y - my_pt.y
    if dir.x * dx + dir.y * dy > 0 then
        return true
    end
end


--
local tmp_vec = cc.vec2(0, 0)
function cc.vec2_static(x, y)
    tmp_vec.x = x
    tmp_vec.y = y
    return tmp_vec
end

local tmp_add_vec = cc.vec2(0, 0)
function cc.pAdd_static(pt1, pt2)
    tmp_add_vec.x = pt1.x + pt2.x
    tmp_add_vec.y = pt1.y + pt2.y
    return tmp_add_vec
end

local tmp_sub_vec = cc.vec2(0, 0)
function cc.pSub_static(pt1,pt2)
    tmp_sub_vec.x = pt1.x - pt2.x
    tmp_sub_vec.y = pt1.y - pt2.y
    return tmp_sub_vec
end

local tmp_vec3 = cc.vec3(0, 0)
function cc.vec3_static(x, y, z)
    tmp_vec3.x = x
    tmp_vec3.y = y
    tmp_vec3.z = z
    return tmp_vec3
end

local tmp_add_vec3 = cc.vec3(0, 0)
function cc.pAdd3_static(pt1, pt2)
    tmp_add_vec3.x = pt1.x + pt2.x
    tmp_add_vec3.y = pt1.y + pt2.y
    tmp_add_vec3.z = pt1.z + pt2.z
    return tmp_add_vec3
end

local tmp_sub_vec3 = cc.vec3(0, 0)
function cc.pSub3_static(pt1,pt2)
    tmp_sub_vec3.x = pt1.x - pt2.x
    tmp_sub_vec3.y = pt1.y - pt2.y
    tmp_sub_vec3.z = pt1.z - pt2.z
    return tmp_sub_vec3
end

cc.Red = cc.vec3(255, 0, 0)
cc.Yellow = cc.vec3(255, 255, 0)
cc.Green = cc.vec3(0,255,0)
cc.Blue = cc.vec3(58,206,255)
cc.Black = cc.vec3(0,0,0)
cc.White = cc.vec3(255,255,255)
cc.Gray = cc.vec3(192,192,192)
cc.Purple = cc.vec3(255,0,255)
cc.Pink = cc.vec3(255,0,124)
cc.Orange = cc.vec3(255,153,0)
cc.NavyBlue = cc.vec3(49,113,245)
cc.GrayBrown = cc.vec3(112,83,52)

-- 物品颜色
-- white,green,blue,pruple,orange,red
cc.GoodsColor = {
    cc.vec4(112, 83, 52, 255),
    cc.vec4(54, 122, 33, 255),
    cc.vec4(49, 113, 245, 255),
    cc.vec4(162, 48, 227, 255),
    cc.vec4(206, 96, 19, 255),
    cc.vec4(219, 71, 52, 255),
}

cc.GoodsColor2 = {
    "#705334",
    "#367A21",
    "#3171F5",
    "#A230E3",
    "#CE6013",
    "#DB4734",
}

cc.GoodsColor_light = {
    cc.vec4(254, 244, 173, 255),
    cc.vec4(95, 201, 52, 255),
    cc.vec4(82, 152, 227, 255),
    cc.vec4(197, 78, 244, 255),
    cc.vec4(213, 112, 29, 255),
    cc.vec4(219, 71, 52, 255),
}
