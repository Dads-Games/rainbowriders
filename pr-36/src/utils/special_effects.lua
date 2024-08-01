-- A collection of special effects that are easy to use
-- This is a factory function that returns an object with special effects
function SpecialEffect ()
    local interval = 0

    -- a function that iterates the interval
    local iterate = function ()
        interval = interval + 1
        if interval > 1000 then
            interval = 0
        end
    end

    -- Example Usage:
    -- local effect = SpecialEffect() -- store this globally
    -- effect.cycle({RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, DARK_PURPLE}, 10, function (color, index)
    --     print("color: " .. color .. " index: " .. index)
    -- end)
    local cycle = function (list, rate, callback)
        -- iterate the interval
        iterate()
        -- return the item in the list based on the interval
        local item = list[flr(interval / rate) % #list + 1]
        -- call the callback with the item and the index
        callback(item, flr(interval / rate) % #list + 1)
    end

    -- Example Usage:
    -- local effect2 = SpecialEffect() -- store this globally
    -- effect2.blink(10, function (on_off, index)
    --     if on_off == 0 then
    --         print("off")
    --     else
    --         print("on")
    --     end
    -- end)
    local blink = function (rate, callback)
        -- iterate the interval
        iterate()
        -- return the item in the list based on the interval
        local on_off = flr(interval / rate) % 2
        -- call the callback with the item and the index
        callback(on_off, flr(interval / rate) % 2)
    end

    return {
        cycle = cycle,
        blink = blink
    }
end