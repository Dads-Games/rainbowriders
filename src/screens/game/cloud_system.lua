function CloudSystem ()
    -- constructor
    local cloudSystem = {}

    -- config
    local max_clouds_on_screen = 3
    local cloud_speed = { min = 0.025, max = 0.1 }
    local zone = {
        top = 0,
        right = 128,
        bottom = 50,
        left = 0
    }

    --state
    local round_robin_divisions = 4
    local round_robin_iteration = 0
    local clouds = {}

    -- helper function to ensure a fair distribution of clouds
    -- during the initial spawn of clouds on screen
    -- this was implemented because rnd sometimes clusters them
    -- too close together
    function round_robin_distribution ()
        round_robin_iteration = (round_robin_iteration + 1) % round_robin_divisions
        return round_robin_iteration
    end

    function Cloud (on_screen)
        -- constructor
        local cloud = {}

        -- defaults
        on_screen = on_screen or false
        
        -- state
        local sprite = flr(rnd(3)) + 66
        local position = { x = 0, y = 0 }
        local delta_x = rnd(cloud_speed.max - cloud_speed.min) + cloud_speed.min
        
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

        function cloud:draw ()
            local x = flr(position.x)
            local y = flr(position.y)
            spr(sprite, x, y)
        end

        function cloud:update ()
            position.x = position.x - delta_x

            -- if this is off screen, reset it off screen on the right
            if position.x < zone.left - 10 then
                position.x = zone.right + rnd(5) + 5
                position.y = rnd(zone.bottom)
            end
        end

        return cloud
    end

    function init ()
        for i = 1, max_clouds_on_screen do
            add(clouds, Cloud(true))
        end
    end

    function cloudSystem:draw ()
        for cloud in all(clouds) do
            cloud.draw()
        end
    end

    function cloudSystem:update ()
        for cloud in all(clouds) do
            cloud.update()
        end
    end

    init()

    return cloudSystem
end
