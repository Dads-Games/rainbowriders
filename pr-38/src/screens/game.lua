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
            particle.life -= rnd(0.1)
            particle.x += particle.speed

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
                x += 1+ rnd(3)
            end

            pset(x, y, color_based_on_percent)
        end
    end

    -- init: spawn 20 particles to start
    for i = 1, 550 do
        add(particles, warpDriveTrail:Particle(30, 30))
    end
    
    return warpDriveTrail
end

function Enterprise (triggerThreshold)
    local triggerThreshold = triggerThreshold or 100
    local animation_system = {
        position = {
            x = 200,
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

function Game(state)

    -- game state
    local player = state.player

    -- local state
    local grass = {}
    local obstacles = {}
    local spawn_timer = 0
    local spawn_interval = 20
    local title_screen = true
    local char_select_screen = false
    local game_over = false
    local background_x = 0
    local background_n = 128 * 8 -- number of tiles wide for the background in the map * 8
    local background_y = 96 - 16 - 12-- 84
    local grace_period = 30 * 3 -- 3 seconds
    local grace_period_counter = 0
    local clouds = CloudSystem()
    local enterprise = Enterprise()

    function is_grace_period() return grace_period_counter < grace_period end

    function draw_stretched_sprite(sprite, x, y, dy)
        local stretch_factor = 1 + abs(dy) * 0.1
        local width = 8 -- Assuming the sprite is 8x8 pixels
        local height = 8

        -- Calculate the new width and height based on the stretch factor
        local new_width = width
        local new_height = height * stretch_factor

        -- Draw the sprite with the new dimensions
        sspr(sprite % 16 * 8, flr(sprite / 16) * 8, width, height, x, y,
             new_width, new_height)
    end

    function game_controller()
        clouds.update()
        enterprise.controller()

        local scoreMod = 100
        local scoreThreshold = 5
        -- if scoreMod is within scoreThreshold of the score, trigger the enterprise
        if state.score > 75 and state.score % scoreMod < scoreThreshold then
            enterprise.trigger()
        end 
        

        -- Increment grace period counter
        if is_grace_period() then
            grace_period_counter = grace_period_counter + 1
        end

        -- Check for collisions
        for obstacle in all(obstacles) do
            if (
                player.x < obstacle.x + obstacle.width 
                and player.x + 8 > obstacle.x 
                and player.y < obstacle.y + obstacle.height 
                and player.y + 8 > obstacle.y
            ) then
                music(1, 0, 0)
                screen = screens.game_over
                del(obstacles, obstacle)
            end
        end

        -- Timer update
        timer_frame_counter = timer_frame_counter + 1
        if timer_frame_counter >= 30 then -- Assuming _update is called 30 times per second
            timer_frame_counter = 0
            timer = timer + 1
            state.score = state.score + 3 -- Increment score by 3 every second
        end

        -- Player jump
        if btnp(4) and player.on_ground or btnp(5) and player.on_ground then
            sfx(62)
            player.dy = player.jump_strength
            player.on_ground = false
        end

        -- Apply gravity
        player.dy = player.dy + player.gravity
        player.y = player.y + player.dy

        -- Prevent player from falling off screen
        if player.y > 104 then
            player.y = 104
            player.dy = 0
            player.on_ground = true
        end

        -- Update oscillation
        player.oscillation = player.oscillation + 0.1
        if player.oscillation > 2 * MATH.PI then
            player.oscillation = player.oscillation - 2 * MATH.PI
        end

        -- Apply oscillation to player's y-position when on the ground
        if player.on_ground then player.y = 104 + sin(player.oscillation) end

        -- Spawn obstacles
        spawn_timer = spawn_timer + 1
        if not is_grace_period() and spawn_timer > spawn_interval + rnd(180) then
            spawn_timer = 0
            if not state.debug_mode then
                sprite_obstacle = flr(rnd(12)) + 192
                if sprite_obstacle == 192 then
                    sfx(61) -- play poop sfx for poop spawn
                end
                add(obstacles, {
                    x = 128,
                    y = 104,
                    width = 8,
                    height = flr(rnd(8) + 16),
                    sprite = sprite_obstacle
                })
            end
        end

        -- Update obstacles
        for obstacle in all(obstacles) do
            obstacle.x = obstacle.x - 2
            if obstacle.x < -obstacle.width then
                del(obstacles, obstacle)
                state.score = state.score + 2 -- Increment score by 2 for clearing an obstacle
            end
        end

        -- Check for collisions
        for obstacle in all(obstacles) do
            if player.x < obstacle.x + obstacle.width and player.x + 8 >
                obstacle.x and player.y < obstacle.y + obstacle.height and
                player.y + 8 > obstacle.y then
                music(-1) -- game over track
                state.screen = screens.game_over
                del(obstacles, obstacle)
            end
        end

        -- Update background
        background_x = (background_x - 1) % background_n

        -- Update grass
        if (background_x % 16) == 0 then
            add(grass, {x = 128, y = 114 + rnd(8), sprite = flr(rnd(3)) + 82})
        end
        if (background_x % 24) == 0 then
            --add(grass, {x = 128, y = 93 + rnd(4), sprite = flr(rnd(3)) + 82})
        end
        for blade in all(grass) do
            blade.x = blade.x - 2
            if blade.x < -8 then del(grass, blade) end
        end

    end

    function game_view()
        -- Draw sky
        rectfill(0, 0, 127, 127, 1)

        if state.daytime == false then
            -- Draw moon & stars
            spr(99, 2, 10)
            spr(98, 10, 10)
            spr(100, 18, 10)
            pal()
        else
            -- Draw sun
            spr(96, 10, 10)
            -- color palette hack for a brighter blue background
            pal({[0] = 0, 140, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}, 1)
        end

        -- Draw map as background
        map(0, 0, background_x, background_y, background_n / 8, 32)
        map(0, 0, background_x - background_n, background_y, background_n / 8, 32)

        -- Draw clouds
        clouds.draw()

        -- Draw top grass
        rectfill(0, 112-12, 128, 128, 3)
        -- Draw street
        rectfill(0, 112-8, 128, 128, 0)
        -- Draw top curb
        rectfill(0, 112-8, 128, 112-8, 5)
        -- Draw bottom grass
        rectfill(0, 112+8, 128, 128, 3)
         -- Draw bottom curb
        rectfill(0, 112+8, 128, 112+8, 5)

        -- Draw grass
        for blade in all(grass) do spr(blade.sprite, blade.x, blade.y) end

        -- Draw player
        local rider_sprite = RIDERS[player.rider].sprite
        draw_stretched_sprite(rider_sprite, player.x, player.y, player.dy)

        -- EXPERIMENTAL FEATURE: Jelly's Rainbow Progression
        rbp_draw_update(player, state.score)

        -- Draw obstacles
        for obstacle in all(obstacles) do
            spr(obstacle.sprite, obstacle.x, obstacle.y)
        end

        -- Draw the timer
        print(timer, 115, 5, 7)

        enterprise.view()

        -- Draw the score at the bottom left
        print("score: " .. state.score, 5, 122, 7)

        -- Draw high score at the bottom right
        print("high score: " .. state.high_score, 60, 122, 7)
    end

    return {view = game_view, controller = game_controller}
end
