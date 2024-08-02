function TitleScreen (state)
    local color_timer = 0
    local color_interval = 5
    local color_index = 1
    local rainbow_colors = {8, 9, 10, 11, 12, 13, 14}

    local KEYS = {
        UP = 0,
        DOWN = 1,
        LEFT = 2,
        RIGHT = 3,
        B = 4,
        A = 5,
        START = 6
    }

    local konami_code = { KEYS.UP, KEYS.UP, KEYS.DOWN, KEYS.DOWN, KEYS.LEFT, KEYS.RIGHT, KEYS.LEFT, KEYS.RIGHT, KEYS.B, KEYS.A, KEYS.START}
    local last_keys_pressed = {}
    local konami_code_on = false
    local waiting = false
    local waiting_timer = 0
    local wait_for = 1 * 30
    local music_playing = false

    -- this is to prevent the game from going through the konami code flow
    -- if we return to the title screen from anywhere else
    -- is it a hack? yes. does it work? yes.
    -- is it the best way to do this? probably not.
    -- but it's a game jam so ¯\_(ツ)_/¯
    -- so we're doing it this way.
    -- if you have a better way, you should do it that way.
    -- idgaf. - tired dad
    local should_skip_regular_controls = true

    function go_to_character_select ()
        state.screen = screens.character_select
    
        -- Reset the timer and score upon starting the game
        timer = 0
        timer_frame_counter = 0
        state.score = 0
    end

    function title_screen_controller ()
        -- play title music
        if not music_playing then
            music_playing = true
            music(48)
        end

        -- cycle through colors
        color_timer = color_timer + 1
        if color_timer > color_interval then
            color_timer = 0
            color_index = color_index + 1
            if color_index > #rainbow_colors then
                color_index = 1
            end
        end

        -- track the last keys pressed for the konami code
        local last_key_pressed = nil
        if (btnp(6)) poke(0x5f30,1) --suppress start button for pause
        if (keypress == 'p') poke(0x5f30,1) --suppress 'p' for pause

        if btnp(0) then
            last_key_pressed = KEYS.LEFT
        elseif btnp(1) then
            last_key_pressed = KEYS.RIGHT
        elseif btnp(2) then
            last_key_pressed = KEYS.UP
        elseif btnp(3) then
            last_key_pressed = KEYS.DOWN
        elseif btnp(4) then
            last_key_pressed = KEYS.B
        elseif btnp(5) then
            last_key_pressed = KEYS.A
        elseif btnp(6) then
            last_key_pressed = KEYS.START
            --go_to_character_select()
        end

        -- store the last 11 keys pressed
        if last_key_pressed then
            add(last_keys_pressed, last_key_pressed)
            -- only keep the last 11
            if #last_keys_pressed > 11 then
                deli(last_keys_pressed, 1)
            end
        end

        -- check if the konami code was entered
        if not konami_code_on and #last_keys_pressed >= #konami_code then
            local konami_code_entered = true
            for i = 1, #konami_code do
                if last_keys_pressed[#last_keys_pressed - #konami_code + i] ~= konami_code[i] then
                    konami_code_entered = false
                    break
                end
            end
            konami_code_on = konami_code_entered
        end

        -- if the konami code was entered, wait for a few seconds before going to the character select screen
        if konami_code_on and should_skip_regular_controls then
            if not waiting then
                sfx(58)
            end

            waiting = true
            waiting_timer = waiting_timer + 1

            if waiting_timer > wait_for then
                -- set into game state
                should_skip_regular_controls = false
                state.konami = true
                go_to_character_select()
            else
                return
            end
        end

        game_over_timer = 0
        -- Move to character select screen
        if last_key_pressed == KEYS.START then
            go_to_character_select()
        end
    end

    press_start_blinker = SpecialEffect().blink
    function title_screen_view ()
        local color = rainbow_colors[color_index]
        for i = 1, 6 do
            local x = 5 + (i - 1) * 22
            local y = 40
            spr(i, x, y)
        end
        
        printc("rainbow riders", 0, 53, color)
        press_start_blinker(15, function (on_off, index)
            if on_off == 0 then
                printc("press start to play", x, 86, 7)
            end
        end)
        printc("(c) 1977 dads' games", 0, 120, 1)

        -- Check and set high score
        if state.score > state.high_score then
            state.high_score = state.score
            dset(0, state.high_score)
        end
    end

    return {
        view = title_screen_view,
        controller = title_screen_controller
    }
end