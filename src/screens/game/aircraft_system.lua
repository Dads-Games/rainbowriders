function AircraftSystem ()
    -- constructor
    local aircraftSystem = {}

    -- config
    local max_crafts_on_screen = 1
    local craft_speed = { min = 0.5, max = 0.75 } --{ min = 0.025, max = 0.1 }
    local craft_sprites = {
        plane = {
            x=0,
            y=56,
            xw=16,
            yw=16
        },
        jet = {
            x=16,
            y=56,
            xw=16,
            yw=16
        }
    }
    local zone = {
        top = 0,
        right = 128,
        bottom = 16,
        left = 0
    }

    --state
    local round_robin_divisions = 4
    local round_robin_iteration = 0
    local crafts = {}

    -- helper function to ensure a fair distribution of crafts
    -- during the initial spawn of crafts on screen
    -- this was implemented because rnd sometimes clusters them
    -- too close together
    function round_robin_distribution ()
        round_robin_iteration = (round_robin_iteration + 1) % round_robin_divisions
        return round_robin_iteration
    end

    function craft (on_screen)
        -- constructor
        local craft = {}

        -- defaults
        on_screen = on_screen or false
        
        -- state
        local sprite = {
            
        }
        local position = { x = 0, y = 0 }
        local delta_x = rnd(craft_speed.max - craft_speed.min) + craft_speed.min
        local lifespan = flr(rnd(128))

        -- init
        if on_screen then
            local round_robin = round_robin_distribution()
            local x = rnd(zone.right / round_robin_divisions) + (zone.right / round_robin_divisions) * round_robin
            local y = rnd(zone.bottom)

            position = {
                x = x,
                y = y
            }
        else
            local x = zone.right + 10
            local y = rnd(zone.top + zone.bottom) + zone.top

            position = {
                x = x,
                y = y
            }
        end

        function craft:draw ()
            local x = flr(position.x)
            local y = flr(position.y)

            local flight = craft_sprites.plane
            if y % 2 == 0 then
                flight = craft_sprites.jet
            end
            
            sspr(flight.x,flight.y,flight.xw,flight.yw, x, y)
        end


        function craft:update ()
            position.x = position.x - delta_x

            -- if this is off screen, reset it off screen on the right
            if position.x < zone.left - 128 - lifespan then
                position.x = zone.right + rnd(5) + 5
                position.y = rnd(zone.bottom)
            end
        end

        return craft
    end

    function init ()
        for i = 1, max_crafts_on_screen do
            add(crafts, craft(true))
        end
    end

    function aircraftSystem:draw ()
        for craft in all(crafts) do
            craft.draw()
        end
    end

    function aircraftSystem:update ()
        for craft in all(crafts) do
            craft.update()
        end
    end

    init()

    return aircraftSystem
end
