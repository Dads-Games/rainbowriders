function printc(text, x, y, color)
    local screen_width = 128
    local char_width = 4
    local space_width = 5

    -- Calculate the total width of the text in pixels
    local text_width = 0
    for i = 1, #text do
        local char = sub(text, i,i)
        if char == " " then
            text_width = text_width + space_width
        else
            text_width = text_width + char_width
        end
    end

    -- Calculate the starting position for the text to be centered
    local xPos = flr((screen_width - text_width) / 2)

    print(text, xPos, y, color)
end