function Info(state)
    cls()  -- Clear the screen
    scroll_y = 128  -- Reset the scroll position at initialization
    local scroll_y = 128  -- Starting position off-screen
    local scroll_speed = 1  -- Speed of the scroll
    local objects = {
        { name = "jump over these obstacles!", sprite = -1},
        { name = "poop", sprite = 192 },
        { name = "rock", sprite = 193 },
        { name = "bush", sprite = 194 },
        { name = "traffic cone", sprite = 195 },
        { name = "mailbox", sprite = 196 },
        { name = "trash can", sprite = 197 },
        { name = "fire hydrant", sprite = 198 },
        { name = "balloon", sprite = 199 },
        { name = "no-crossing sign", sprite = 200 },
        { name = "yield sign", sprite = 201 },
        { name = "puddle", sprite = 202 },
        { name = "fence", sprite = 203 },
        { name = "good luck - you can do it!", sprite = -1},
    }

    function view()

            for i = 1, #objects do
                local obj = objects[i]
                local y = scroll_y + (i - 1) * 48
                
                if y > -16 and y < 128 then
                    local x = 64 - 4  -- Center x position of sprite (since sprites are 8x8)
                    
                    -- Display sprite
                    spr(obj.sprite, x, y)
                    
                    -- Calculate text position
                    local text_x = 64 - (#obj.name * 4) / 2  -- Center text
                    local text_y = y + 12  -- Position text below the sprite
                    
                    -- Display name
                    print(obj.name, text_x, text_y, 7)
                end
            end
        

    end

    function controller()
        pause_suppress()

        if (btnp(6)) then
            state.screen = screens.title
        end

        scroll_y = scroll_y - scroll_speed  -- Move the scroll position up
        
        -- Reset to the bottom if the last object has scrolled off-screen
        if scroll_y < -#objects * 48 then
            scroll_y = 128
        end
    end
   
    return {
        view = view,
        controller = controller
    }
end