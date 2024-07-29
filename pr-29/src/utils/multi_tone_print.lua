--[[
    multi_tone_print: Prints text with multiple color tones

    @param text (string): The text to print
    @param x (number): X-coordinate for text position
    @param y (number): Y-coordinate for text position
    @param tone_settings (table): A table of color and height settings

    Each entry in tone_settings should be a table with:
    - color: PICO-8 color index (0-15)
    - height: Relative height of this tone (percentages will be calculated)

    Example usage:
    multi_tone_print("PICO-8", 10, 10, {
        {color = 8, height = 1},  -- Red (20%)
        {color = 12, height = 2}, -- Light blue (40%)
        {color = 1, height = 2}   -- Dark blue (40%)
    })

    This will print "PICO-8" at (10, 10) with:
    - Top 20% in red (color 8)
    - Middle 40% in light blue (color 12)
    - Bottom 40% in dark blue (color 1)

    The function calculates percentages based on the sum of all heights,
    so you can use any relative numbers for height.
]]
function multi_tone_print(text, x, y, tone_settings)
    local text_width = #text * 4
    local text_height = 5
    local total_height = 0
    local current_height = 0

    -- Calculate total height percentage
    for _, setting in ipairs(tone_settings) do
        total_height += setting.height
    end

    -- Print text for each tone setting
    for i, setting in ipairs(tone_settings) do
        local color = setting.color
        local height_percent = setting.height / total_height
        local pixels = flr(text_height * height_percent + 0.5)
        
        -- Ensure last section fills remaining pixels
        if i == #tone_settings then
            pixels = text_height - current_height
        end

        -- Create clipping region
        clip(x, y + current_height, text_width, pixels)
        
        -- Print text in current color
        print(text, x, y, color)

        -- Update current height
        current_height += pixels
    end

    -- Reset clipping
    clip()
end
