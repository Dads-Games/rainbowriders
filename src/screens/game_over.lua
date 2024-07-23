function game_over_controller ()
    -- Increment game over timer
    game_over_timer = game_over_timer + 1
    if game_over_timer > game_over_delay then
        screen = screens.title
    end
end

function game_over_view ()
    cls()
    -- Check high score and display if beat
    if score > high_score then
        print("you set the new high score!", 15, 60, 7)
        print("high score: "..score.." great job!", 15, 80, 7)
     
    -- Display the score on the game over screen
    elseif score > 0 then
        print("game over - try again!", 20, 60, 7)
        print("your score: "..score.." great job!", 15, 80, 7)
    else
        print("game over - try again!", 20, 60, 7)
    end

    -- Do not reset the timer and score here;
    -- they will be reset at the start of a new game
end