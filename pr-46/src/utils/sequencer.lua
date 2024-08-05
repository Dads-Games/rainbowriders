Ease = {
    -- Ease functions for different types of easing effects
    Linear = function(t) return t end,
    QuadIn = function(t) return t * t end,
    QuadOut = function(t) return 1 - (1 - t) * (1 - t) end,
    QuadInOut = function(t) return t < 0.5 and 2 * t * t or 1 - (-2 * t + 2)^2 / 2 end,
    CubicIn = function(t) return t * t * t end,
    CubicOut = function(t) return 1 - (1 - t)^3 end,
    CubicInOut = function(t) return t < 0.5 and 4 * t * t * t or 1 - (-2 * t + 2)^3 / 2 end,
    QuartIn = function(t) return t * t * t * t end,
    QuartOut = function(t) return 1 - (1 - t)^4 end,
    QuartInOut = function(t) return t < 0.5 and 8 * t * t * t * t or 1 - (-2 * t + 2)^4 / 2 end,
    ExpoIn = function(t) return t == 0 and 0 or 2^(10 * t - 10) end,
    ExpoOut = function(t) return t == 1 and 1 or 1 - 2^(-10 * t) end,
    ExpoInOut = function(t) return t == 0 and 0 or t == 1 and 1 or t < 0.5 and 2^(20 * t - 10) / 2 or (2 - 2^(-20 * t + 10)) / 2 end,
    SineIn = function(t) return 1 - cos((t * 3.1415927) / 2) end,
    SineOut = function(t) return sin((t * 3.1415927) / 2) end,
    SineInOut = function(t) return -(cos(3.1415927 * t) - 1) / 2 end,
    BackIn = function(t) local c1 = 1.70158; local c3 = c1 + 1; return c3 * t * t * t - c1 * t * t end,
    BackOut = function(t) local c1 = 1.70158; local c3 = c1 + 1; return 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2 end,
    BackInOut = function(t) local c1 = 1.70158; local c2 = c1 * 1.525; return t < 0.5 and ((2 * t)^2 * ((c2 + 1) * 2 * t - c2)) / 2 or ((2 * t - 2)^2 * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2 end,
    ElasticIn = function(t) local c4 = (2 * 3.1415927) / 3; return t == 0 and 0 or t == 1 and 1 or -2^(10 * t - 10) * sin((t * 10 - 10.75) * c4) end,
    ElasticOut = function(t) local c4 = (2 * 3.1415927) / 3; return t == 0 and 0 or t == 1 and 1 or 2^(-10 * t) * sin((t * 10 - 0.75) * c4) + 1 end,
    ElasticInOut = function(t) local c5 = (2 * 3.1415927) / 4.5; return t == 0 and 0 or t == 1 and 1 or t < 0.5 and -(2^(20 * t - 10) * sin((20 * t - 11.125) * c5)) / 2 or (2^(-20 * t + 10) * sin((20 * t - 11.125) * c5)) / 2 + 1 end,
    BounceIn = function(t) return 1 - Ease.BounceOut(1 - t) end,
    BounceOut = function(t) local n1 = 7.5625; local d1 = 2.75; return t < 1 / d1 and n1 * t * t or t < 2 / d1 and n1 * (t - 1.5 / d1) * (t - 1.5 / d1) + 0.75 or t < 2.5 / d1 and n1 * (t - 2.25 / d1) * (t - 2.25 / d1) + 0.9375 or n1 * (t - 2.625 / d1) * (t - 2.625 / d1) + 0.984375 end,
    BounceInOut = function(t) return t < 0.5 and (1 - Ease.BounceOut(1 - 2 * t)) / 2 or (1 + Ease.BounceOut(2 * t - 1)) / 2 end
}

function Sequencer(a)local b=0;local c=1;local d=1;local e=false;local f={}local function g(h,i)local j={}for k,l in pairs(h.properties)do if type(l)=="table"and l.from and l.to then local m=l.ease(i)j[k]=l.from+(l.to-l.from)*m else j[k]=l end end;return j end;return function()if e and#f==0 then return false end;for n,h in ipairs(f)do h.fn(h.finalProps)end;if e then return true end;local h=a[c]local o=h.duration*30;b=b+d;if b>=o then if h.ending==Ending.Stop then b=o;e=true elseif h.ending==Ending.ReverseAndStop then if d<0 then e=true else d=-1;b=o end elseif h.ending==Ending.ReverseAndLoop then d=-d;b=o elseif h.ending==Ending.Reset then b=0;c=c%#a+1 elseif h.ending==Ending.Loop then b=0 else e=true end end;local i=mid(0,b/o,1)local j=g(h,i)h.fn(j)if b>=o then if h.persists then add(f,{fn=h.fn,finalProps=j})end;if c<#a then c=c+1;b=0;d=1;e=false else e=true end end;return true end end

Ending = {
    Stop = 0,  -- New addition
    ReverseAndStop = 1,
    Loop = 2,
    ReverseAndLoop = 3,
    Reset = 4,
}
