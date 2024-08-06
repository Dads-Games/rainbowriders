function BlinkingPixel (color1, color2, on_duration, off_duration)
    color1 = color1 or 7
    color2 = color2 or 0
    on_duration = on_duration or 30
    off_duration = off_duration or 30
    endless = endless or true

    local time = 0
    local blinkingPixel = {}
    
    function blinkingPixel:update ()
        time = time + 1
        if time > 1000 then
            time = 0
        end
    end

    function blinkingPixel:draw (x, y)
        local color = color1
        local duration = on_duration

        if time % (on_duration + off_duration) > on_duration then
            color = color2
            duration = off_duration
        end

        pset(x, y, color)
    end

    return blinkingPixel
end

function WarpDriveTrail ()
    local warpDriveTrail = {}
    local colors_over_lifetime = {
        -- first 10% is white
        { color = 8, percent = 0.1 },
        -- then an analog for light blue
        { color = 11, percent = 0.3 },
        -- then an analog for dark blue
        { color = 12, percent = 0.6 },
        -- then a darker purple color
        { color = 9, percent = 0.9 },
    }
    -- reverse colors_over_lifetime
    
    local particles = {}

    function warpDriveTrail:Particle (x, y)
        local starting_life = rnd(0.25) + 0.5
        return {
            x = x,
            y = y,
            speed = rnd(0.075) + 0.25,
            life = starting_life,
            starting_life = starting_life
        }
    end
    
    function warpDriveTrail:update (x, y)
        -- loop through all particles
        for particle in all(particles) do
            particle.life = particle.life - rnd(0.1)
            particle.x = particle.x + particle.speed

            if particle.life <= 0 then
                del(particles, particle)
                add(particles, warpDriveTrail:Particle(x, y))
            end
        end
    end
    
    function warpDriveTrail:draw ()
        -- debug: particles drawon top right
        -- print(#particles, 30, 1, 7)
        -- print(#colors_over_lifetime, 30, 20, 8)

        -- loop through all particles
        for i, particle in pairs(particles) do
            -- render particle
            local percent = 1 - (particle.life / particle.starting_life) -- 0 to 1
            local color_index = 1
            
            -- loop over colors_over_lifetime to find the index where the percent is less than the current percent - 1
            for i = 1, #colors_over_lifetime do
                if percent < colors_over_lifetime[i].percent then
                    color_index = i
                    break
                end
            end

            -- print("color index: " .. color_index, 30, 10, 7)

            color_based_on_percent = colors_over_lifetime[color_index].color
            
            local x = particle.x
            local y = particle.y + flr(rnd((1 - percent) * 3) - 1)

            -- if the y is above or below the particles y, offset the x by + 2
            if y < particle.y or y > particle.y then
                x = x + 1 + rnd(3)
            end

            pset(x, y, color_based_on_percent)
        end
    end

    -- init: spawn 20 particles to start
    for i = 1, 550 do
        add(particles, warpDriveTrail:Particle(-30, -30))
    end
    
    return warpDriveTrail
end

function Enterprise (triggerThreshold)
    local triggerThreshold = triggerThreshold or 100
    local animation_system = {
        position = {
            x = -100,
            y = 50,
        },
    }

    local active = false
    local blinking_pixel = BlinkingPixel(7, 14, 5, 30)
    local wdt = WarpDriveTrail()
    local triggerDelta = nil -- default to nil since first trigger should be immediate

    -- helps to calculate the position of the sprite on screen relative to the animation system
    local origin = {
        x = function (relative_x) return animation_system.position.x + relative_x end,
        y = function (relative_y) return animation_system.position.y + relative_y end,
    }

    function controller ()
        animation_system.position.x = animation_system.position.x - 5
        
        -- track how many frames have passed since the last trigger
        if triggerDelta ~= nil then
            triggerDelta = triggerDelta + 1
        end

        if active and animation_system.position.x < -64 then
            animation_system.position.x = 200
            active = false
        end

        blinking_pixel:update()
        wdt:update(origin.x(30), origin.y(4))
    end

    function view ()
        -- Calculate sprite sheet coordinates for sprite ID 106
        local sx = (120 % 16) * 8
        local sy = flr(120 / 16) * 8
        
        -- Draw the 24x16 sprite
        sspr(sx, sy, 32, 14, origin.x(0), origin.y(0))

        -- Draw the blinking pixel
        blinking_pixel:draw(origin.x(14), origin.y(4))
        wdt:draw()
    end

    function tryToTrigger ()
        if triggerDelta == nil or triggerDelta > triggerThreshold then
            active = true
            triggerDelta = 0
        end
    end

    return {
        view = view,
        controller = controller,
        trigger = tryToTrigger
    }
end