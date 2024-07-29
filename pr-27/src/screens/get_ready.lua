local GET_READY_TEXT = 'rIDERS rEADY!'

function draw_box (properties)
    -- white box
    rect(properties.x, properties.y, properties.x + properties.width, properties.y + properties.height, 7)
end

function draw_intro_text(properties)
    local x = properties.x or 0
    local y = properties.y or 0
    local letter = properties.letter or ''
    local color = properties.color or 7
    
    print(letter, x, y, color)
end

local get_ready_sequence = {}

-- lets add each letter of the text to the sequence one at a time
local letter_rainbow_pallet = {
    8, 9, 10, 11, 12, 13, 14, 15
}
for i = 1, #GET_READY_TEXT do
    local letter = sub(GET_READY_TEXT, i, i)
    add(get_ready_sequence, {
        fn = draw_intro_text,
        properties = {
            -- centered on screen based on the length of the text
            x = 128 / 2 - (#GET_READY_TEXT * 4) / 2 + (i - 1) * 4,
            y = {
                from = -100,
                to = 60,
                ease = Ease.BounceOut,
            },
            letter = letter,
            -- recycle colors if len is greater
            color = letter_rainbow_pallet[(i - 1) % #letter_rainbow_pallet + 1]
        },
        duration = 1 / #GET_READY_TEXT,
        persists = true,
        ending = Ending.Stop
    })
end

local border_box_sequence = {
    {
        fn = draw_box,
        properties = {
            x = {
                from = 128 / 2,
                to = 128 / 2 - 48,
                ease = Ease.BounceOut
            },
            y = {
                from = 128 / 2,
                to = 128 / 2 - 12,
                ease = Ease.BounceOut
            },
            width = {
                from = 0,
                to = 96,
                ease = Ease.BounceOut
            },
            height = {
                from = 0,
                to = 24,
                ease = Ease.BounceOut
            }
        },
        duration = 1,
        persists = true,
        ending = Ending.Stop
    }
}

function GetReady(state)
    local getReady = {}

    -- config
    local screen_delay = 3 * 30 -- 3 seconds

    -- state
    local time_waited = 0

    -- init
    local animator = Sequencer(get_ready_sequence)
    local animator2 = Sequencer(border_box_sequence)

    function ready_to_play() return state.ready_to_play end

    function getReady:view()
        animator()
        animator2()
    end

    function getReady:controller()
        time_waited = time_waited + 1

        if time_waited > screen_delay then
            state.screen = Game(state)
            music(25, 0, 0) -- this really should be in the game screen
        end
    end

    return getReady
end
