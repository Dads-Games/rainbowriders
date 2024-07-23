function Game (state)

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
    local background_y = 96--84
    local clouds = {}
    local cloud_timer = 0
    local cloud_interval = 120

    function draw_stretched_sprite(sprite, x, y, dy)
        local stretch_factor = 1 + abs(dy) * 0.1
        local width = 8 -- Assuming the sprite is 8x8 pixels
        local height = 8

        -- Calculate the new width and height based on the stretch factor
        local new_width = width
        local new_height = height * stretch_factor

        -- Draw the sprite with the new dimensions
        sspr(sprite % 16 * 8, flr(sprite / 16) * 8, width, height, x, y, new_width, new_height)
    end

    function game_controller ()
        if not game_over then
            -- Timer update
            timer_frame_counter = timer_frame_counter + 1
            if timer_frame_counter >= 30 then -- Assuming _update is called 30 times per second
                timer_frame_counter = 0
                timer = timer + 1
                state.score = state.score + 3 -- Increment score by 3 every second
            end
            
            -- Player jump
            if btnp(4) and player.on_ground then
                sfx(4)
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
            if player.on_ground then
                player.y = 104 + sin(player.oscillation)
            end

            -- Spawn obstacles
            spawn_timer = spawn_timer + 1
            if spawn_timer > spawn_interval + rnd(180) then
                spawn_timer = 0
                if not state.debug_mode then
                    add(obstacles, {x = 128, y = 104, width = 8, height = flr(rnd(8) + 16), sprite = flr(rnd(12)) + 192})
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
                if player.x < obstacle.x + obstacle.width and
                    player.x + 8 > obstacle.x and
                    player.y < obstacle.y + obstacle.height and
                    player.y + 8 > obstacle.y then
                    music(1, 0, 0)
                    state.screen = screens.game_over
                    del(obstacles, obstacle)
                end
            end

            -- Update background
            background_x = (background_x - 1) % background_n

            -- Update clouds
            cloud_timer = cloud_timer + 1
            if cloud_timer > cloud_interval then
                cloud_timer = 0
                add(clouds, {x = 128, y = flr(rnd(40)), sprite = flr(rnd(3)) + 66})
            end
            for cloud in all(clouds) do
                cloud.x = cloud.x - rnd(0.25)
                if cloud.x < -32 then
                    del(clouds, cloud)
                end
            end

            -- Update grass
            if (background_x % 16) == 0 then
                add(grass, {x = 128, y = 110 + rnd(15) , sprite = flr(rnd(3)) + 69})
            end
            for blade in all(grass) do
                blade.x = blade.x - 2
                if blade.x < -8 then
                    del(grass, blade)
                end
            end
        end
    end

    function game_view ()
        -- Draw sky
        rectfill(0, 0, 127, 127, 1)
        -- Draw map as background
        map(0, 0, background_x, background_y, background_n/8, 16)
        map(0, 0, background_x - background_n, background_y, background_n/8, 16)

        -- Check for collisions
        for obstacle in all(obstacles) do
            if player.x < obstacle.x + obstacle.width and
                player.x + 8 > obstacle.x and
                player.y < obstacle.y + obstacle.height and
                player.y + 8 > obstacle.y then
                music(1, 0, 0)
                screen = screens.game_over
                del(obstacles, obstacle)
            end
        end

        -- Dimming effect
        -- fillp(0B111111111011111.1) -- 50% fill pattern
        -- rectfill(0, 0, 127, 127 ) -- Color 0 (black) with fill pattern
        -- fillp() -- Reset fill pattern

        --Draw sun
        spr(96, 10, 10)

        -- Draw clouds
        for cloud in all(clouds) do
            spr(cloud.sprite, cloud.x, cloud.y)
        end
        -- Draw background
        rectfill(background_x, 112, background_x + background_n, 128, 3)
        rectfill(background_x - background_n, 112, background_x, 128, 3)
        -- Draw grass
        for blade in all(grass) do
            spr(blade.sprite, blade.x, blade.y)
        end
        -- Draw player
        --spr(player.sprite, player.x, player.y)
        draw_stretched_sprite(player.sprite, player.x, player.y, player.dy)

        -- EXPERIMENTAL FEATURE: Jelly's Rainbow Progression
        rbp_draw_update(player, state.score)

        -- Draw obstacles
        for obstacle in all(obstacles) do
            spr(obstacle.sprite, obstacle.x, obstacle.y)
        end

        -- Draw the timer
        print(timer, 115, 5, 7)

        -- Draw the score at the bottom left
        print("score: " .. state.score, 5, 120, 7)

        --Draw high score at the bottom right
        print("high score: " .. state.high_score, 60, 120, 7)
    end

    return {
        view = game_view,
        controller = game_controller
    }
end