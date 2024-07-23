function CharacterSelect(state)
    local player = state.player
    local selected_char = 1
    local char_names = {
        "lizzie", "lily", "riker", "lukas", "maverick", "michael"
    }

    function character_select_controller()
        if btnp(0) then
            selected_char = max(1, selected_char - 1)
        elseif btnp(1) then
            selected_char = min(#char_names, selected_char + 1)
        end

        -- Confirm selection and start game
        if btnp(4) then
            player.sprite = selected_char
            state.screen = screens.game
            music(26, 0, 0)
        end
    end

    function character_select_view()
        print("select your character", 20, 20, 7)
        for i = 1, 6 do
            local x = 5 + (i - 1) * 22
            local y = 40
            if i == selected_char then
                rect(x - 2, y - 2, x + 10, y + 10, 7) -- Highlight selected character
            end
            spr(i, x, y)
        end
        print(char_names[selected_char], 50, 65, 7) -- Display character name
        print("press left or right", 20, 90, 7)
        print("then start to confirm", 30, 100, 7)
    end

    return {
        view = character_select_view,
        controller = character_select_controller
    }
end
