function CharacterSelect(state)
    local player = state.player

    function character_select_controller()
        local selected_rider_index = state.player.rider
        local next_rider_index = min(#RIDERS, selected_rider_index + 1)
        local prev_rider_index = max(1, selected_rider_index - 1)
        if (btnp(6)) poke(0x5f30,1) --suppress start button for pause

        -- button: left
        if btnp(0) then
            state.player.rider = prev_rider_index
            sfx(60) -- character switching sfx

        -- button: right
        elseif btnp(1) then
            state.player.rider = next_rider_index
            sfx(60) -- character switching sfx
        end

        -- Confirm selection and start game
        if btnp(4) or btnp (5) or btnp (6) then
            state.screen = GetReady(state)
            sfx(59) -- character selected sfx
        end
    end

    function character_select_view()

        local selected_rider_index = state.player.rider
        if state.konami == true then
            RIDERS = PRIDERS
        elseif state.konami == false then
            RIDERS = KRIDERS
        end
        printc("select your character", 20, 20, 7)
        for i = 1, #RIDERS do

            local x = 5 + (i - 1) * 22
            local y = 40
            if i == selected_rider_index then
                rect(x - 2, y - 2, x + 10, y + 10, 7) -- Highlight selected character
            end
            spr(RIDERS[i].sprite, x, y)
        end
        printc(RIDERS[selected_rider_index].name, 50, 65, 7) -- Display character name
        printc("press left or right", 20, 90, 7)
        printc("then start to confirm", 30, 100, 7)

    end

    return {
        view = character_select_view,
        controller = character_select_controller
    }
end
