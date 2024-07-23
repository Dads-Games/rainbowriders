function TitleScreen (state)
    local color_timer = 0
    local color_interval = 5
    local color_index = 1
    local rainbow_colors = {8, 9, 10, 11, 12, 13, 14}

    function title_screen_controller ()
        -- Cycle through colors
        color_timer = color_timer + 1
        if color_timer > color_interval then
            color_timer = 0
            color_index = color_index + 1
            if color_index > #rainbow_colors then
                color_index = 1
            end
        end
        game_over_timer = 0
        -- Move to character select screen
        if btnp(4) then
            state.screen = screens.character_select
    
            -- Reset the timer and score upon starting the game
            timer = 0
            timer_frame_counter = 0
            score = 0
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

        print("rainbow riders", 33, 53, color)
        press_start_blinker(15, function (on_off, index)
            if on_off == 0 then
                print("press start", 39, 86, 7)
            end
        end)
        print("(c) copyright 1977 - dads' games", 0, 120, 1)

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