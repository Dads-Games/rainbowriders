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

function drawMyBox(properties)
    local x = properties.x
    local y = properties.y
    local width = properties.width
    local height = properties.height
    local background = properties.background or 7
    rect(x, y, x + width, y + height, background)
end

function Sequencer(sequence)
    local t = 0
    local currentIndex = 1
    local direction = 1
    local done = false
    local persistentItems = {}

    local function applyProperties(item, progress)
        local props = {}
        for key, value in pairs(item.properties) do
            if type(value) == "table" and value.from and value.to then
                -- Animated property
                local eased_progress = value.ease(progress)
                props[key] = value.from + (value.to - value.from) * eased_progress
            else
                -- Static property
                props[key] = value
            end
        end
        return props
    end

    return function()
        if done and #persistentItems == 0 then return false end

        -- Handle persistent items
        for _, item in ipairs(persistentItems) do
            item.fn(item.finalProps)
        end

        if done then return true end

        local item = sequence[currentIndex]
        local itemDuration = item.duration * 30  -- Convert seconds to frames (assuming 30 FPS)

        t = t + direction
        
        if t >= itemDuration then
            if item.ending == Ending.Stop then
                t = itemDuration
                done = true
            elseif item.ending == Ending.ReverseAndStop then
                if direction < 0 then
                    done = true
                else
                    direction = -1
                    t = itemDuration
                end
            elseif item.ending == Ending.ReverseAndLoop then
                direction = -direction
                t = itemDuration
            elseif item.ending == Ending.Reset then
                t = 0
                currentIndex = currentIndex % #sequence + 1
            elseif item.ending == Ending.Loop then
                t = 0
            else
                done = true
            end
        end

        local progress = mid(0, t / itemDuration, 1)
        local props = applyProperties(item, progress)
        item.fn(props)

        if t >= itemDuration then
            if item.persists then
                add(persistentItems, {fn = item.fn, finalProps = props})
            end
            if currentIndex < #sequence then
                currentIndex = currentIndex + 1
                t = 0
                direction = 1
                done = false
            else
                done = true
            end
        end

        return true
    end
end

Ending = {
    Stop = 0,  -- New addition
    ReverseAndStop = 1,
    Loop = 2,
    ReverseAndLoop = 3,
    Reset = 4,
}
