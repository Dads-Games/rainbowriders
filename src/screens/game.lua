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
    local background_y = 96 - 16 - 12 -- 84
    local grace_period = 30 * 3 -- 3 seconds
    local grace_period_counter = 0
    local animation = 0
    local clouds = CloudSystem()
    local enterprise = Enterprise()
    local xwing = Xwing()
    local crafts = AircraftSystem()
    local parade = PegasusParade({
        top = 0,
        bottom = 80,
        left = 0,
        right = 128,
    })
    
    local enterpriseScoreMod = 30
    local xwingScoreMod = 60
    local ufoScoreMod = 90
    local paradeScoreMod = 120
    local scoreThreshold = 5

    -- throttle triggers
    local paradeTrigger = throttle(parade.trigger, 5)
    local enterpriseTrigger = throttle(enterprise.trigger, 5)
    local xwingTrigger = throttle(xwing.trigger, 5)


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
        xwing.controller()
        parade.update()

        -- if state.score > 1000 then trigger parade
        if (state.score > 20) then
            if state.score % paradeScoreMod < scoreThreshold then
                paradeTrigger()

                -- else if state.score > 500 then trigger enterprise
            elseif state.score % ufoScoreMod < scoreThreshold then
                enterpriseTrigger()
                xwingTrigger()
            elseif state.score % xwingScoreMod < scoreThreshold then
                xwingTrigger()
            elseif state.score % enterpriseScoreMod < scoreThreshold then
                enterpriseTrigger()
            end
        end

        crafts.update()

        -- Increment grace period counter
        if is_grace_period() then
            grace_period_counter = grace_period_counter + 1
        end

        -- Check for collisions
        for obstacle in all(obstacles) do
            if (player.x < obstacle.x + obstacle.width and player.x + 8 >
                obstacle.x and player.y < obstacle.y + obstacle.height and
                player.y + 8 > obstacle.y) then
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
                    --sfx(61) -- play poop sfx for poop spawn
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
            -- add(grass, {x = 128, y = 93 + rnd(4), sprite = flr(rnd(3)) + 82})
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
            pal({[0] = 0, 140, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
                1)
        end

        -- Draw map as background
        map(0, 0, background_x, background_y, background_n / 8, 32)
        map(0, 0, background_x - background_n, background_y, background_n / 8,
            32)

        crafts.draw()

        -- Draw clouds
        clouds.draw()

        -- PURRRADE YOOO
        parade.draw()

        -- Draw top grass
        rectfill(0, 112 - 12, 128, 128, 3)
        -- Draw street
        rectfill(0, 112 - 8, 128, 128, 0)
        -- Draw top curb
        rectfill(0, 112 - 8, 128, 112 - 8, 5)
        -- Draw bottom grass
        rectfill(0, 112 + 8, 128, 128, 3)
        -- Draw bottom curb
        rectfill(0, 112 + 8, 128, 112 + 8, 5)

        -- Draw grass
        for blade in all(grass) do spr(blade.sprite, blade.x, blade.y) end

        -- Draw player
        local rider_sprite = RIDERS[player.rider].sprite
        --if rider_sprite == 13 then
            if animation < 30/2 then
                draw_stretched_sprite(rider_sprite+16, player.x, player.y, player.dy)
            else
                draw_stretched_sprite(rider_sprite, player.x, player.y, player.dy)
            end
        --else
        --  draw_stretched_sprite(rider_sprite, player.x, player.y, player.dy)
        --end
        if player.on_ground == true then
            if rider_sprite >= 13 then timing = 30 else timing = 60 end
            if animation == timing then
                animation = 0
            else
                animation += 1
            end
        end
        

        -- EXPERIMENTAL FEATURE: Jelly's Rainbow Progression
        rbp_draw_update(player, state.score)

        -- Draw obstacles
        for obstacle in all(obstacles) do
            spr(obstacle.sprite, obstacle.x, obstacle.y)
        end

        -- Draw the timer
        --print(timer, 115, 5, 7)

        enterprise.view()
        xwing.view()

        -- Draw the score at the bottom left
        print("score: " .. state.score, 5, 122, 7)

        -- Draw high score at the bottom right
        print("high score: " .. state.high_score, 60, 122, 7)
    end

    return {view = game_view, controller = game_controller}
end
