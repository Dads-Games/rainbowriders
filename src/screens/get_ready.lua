local GET_READY_TEXT = 'gET rEADY!'

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
            x = {
                from = 128,
                to = 128 / 2 - #GET_READY_TEXT * 4 + i * 5 + 16,
                ease = Ease.QuadOut
            },
            y = 128 / 2 - 4,
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

function draw_horizontal_line(y, color)
    line(0, y, 128, y, color)
end

function draw_diag_line(properties)
    local x1 = properties.x1
    local y1 = properties.y1
    local x2 = properties.x2
    local y2 = properties.y2
    local horizontal_thickness = properties.horizontal_thickness
    local color = properties.color

    for i = 0, horizontal_thickness do
        line(x1 + i, y1, x2 + i, y2, color)
    end
end

local top_mid_line_y = 128/2 - 16
local bottom_mid_line_y = 128/2 + 16

function draw_rainbow_race_stripes_top (x, step)
    local max_stripes = 64
    local thickness = 8
    local space_between_stripes = 4
    local slant = 24

    for i = 0, max_stripes do
        local color = i % 8 + 8
        -- incorporate i so they happen in a sequence
        draw_diag_line({
            x1 = x + i * (thickness + space_between_stripes),
            y1 = 1,
            x2 = x + i * (thickness + space_between_stripes) + slant,
            y2 = top_mid_line_y - 2,
            horizontal_thickness = thickness,
            color = color
        })
    end
end

function draw_rainbow_race_stripes_bottom (x)
    local max_stripes = 64
    local thickness = 8
    local space_between_stripes = 4
    local slant = -24

    for i = 0, max_stripes do
        local color = i % 8 + 8
        draw_diag_line({
            x1 = x + i * (thickness + space_between_stripes),
            y1 = bottom_mid_line_y + 2,
            x2 = x + i * (thickness + space_between_stripes) + slant,
            y2 = 128,
            horizontal_thickness = thickness,
            color = color
        })
    end
end

function GetReady(state)
    local getReady = {}

    -- config
    local screen_delay = 3 * 30 -- 3 seconds

    -- state
    local time_waited = 0

    function ready_to_play() return state.ready_to_play end
    local animation = Sequencer(get_ready_sequence)

    function getReady:view()
        local rider = RIDERS[state.player.rider]        

        draw_horizontal_line(top_mid_line_y, 7)
        draw_horizontal_line(bottom_mid_line_y, 7)

        -- draw players scootie
        local rider_bounce = sin(time_waited / 20) / 2
        spr(rider.sprite, 128/2 - 32, 128 / 2 - 1 + rider_bounce)

        -- draw the name next to the scootie
        print(rider.name, 128/2 + 5 - #rider.name * 4, 128/2 + 3, 7)

        -- GET READY blinking
        animation()

        draw_rainbow_race_stripes_top(-500 + time_waited)
        draw_rainbow_race_stripes_bottom(-32 - time_waited)
    end

    function getReady:controller()
        time_waited = time_waited + 1

        -- if time_waited > screen_delay then
        --     state.screen = Game(state)
        --     music(25, 0, 0) -- this really should be in the game screen
        -- end
    end

    return getReady
end
