function GameOver (state)
    local game_over_timer = 0
    local game_over_timer = 0
    local game_over_delay = 60 -- 1 second (60 frames per second)

    function game_over_controller ()
        -- Increment game over timer
        game_over_timer = game_over_timer + 1
        if game_over_timer > game_over_delay then
            -- reset the game over timer
            game_over_timer = 0
            state.screen = screens.title
        end
    end

    function game_over_view ()
        cls()
        -- Check high score and display if beat
        if state.score > state.high_score then
            printc("you set the new high score!", 15, 60, 7)
            printc("high score: "..state.score.." great job!", 15, 80, 7)
         
        -- Display the score on the game over screen
        elseif state.score > 0 then
            printc("game over - try again!", 20, 60, 7)
            printc("your score: "..state.score.." great job!", 15, 80, 7)
        else
            printc("game over - try again!", 20, 60, 7)
        end

        -- Do not reset the timer and score here;
        -- they will be reset at the start of a new game
    end

    return {
        view = game_over_view,
        controller = game_over_controller
    }
end