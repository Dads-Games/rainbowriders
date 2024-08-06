function Credits (state)
  local scroll_pos = 128 -- Start from the bottom of the screen
  local speed = .50 -- Scroll speed
  local color_timer = 0
  local color_interval = 5
  local color_index = 1

 local credits_text = {
  developers = {
    header = "developers",
    entities = {'jon', 'michael', 'francis'}
  },
  children = {
    header = "children",
    entities = {'riker', 'lily', 'lizzie', 'maverick', 'lukas'}
  },
  betaTesters = {
    header = "beta testers",
    entities = {'imadabes', 'kenny', 'sara', 'amanda', 'berekley', 'maverick', 'gavin', 'lukas', 'lily', 'riker', 'lizzie'}
  },
  specialThanks = {
    header= 'special thanks',
    entities = {'level 15', 'ihop', 'the love house', 'the mommies', 'pico-8', 'uncrustables'}
  },
}
  local rainbow_colors = {8, 9, 10, 11, 12, 13, 14}

  local total_credits_height = 0
  for _, section in pairs(credits_text) do
    total_credits_height = total_credits_height + 10 -- For header
    total_credits_height = total_credits_height + (#section.entities * 10) +10-- For entities
  end

  function credits_controller()
    pause_suppress()
      -- Scroll down
      scroll_pos = scroll_pos - speed
      -- Return to title screen if credits finish or upon pressing a button
      if scroll_pos < -total_credits_height or btnp(6) then -- 'Z'
          state.screen = screens.title
      end
      color_timer = color_timer + 1
      if color_timer > color_interval then
          color_timer = 0
          color_index = color_index + 1
          if color_index > #rainbow_colors then
              color_index = 1
          end
      end
  end

  function credits_view()
    cls()
    local y_offset = scroll_pos
    
    for _, section in pairs(credits_text) do
      printc(section.header, x, y_offset, rainbow_colors[color_index])
      
      y_offset = y_offset + 10 -- Adjust spacing after header
      
      for _, entity in ipairs(section.entities) do
        printc(entity, x, y_offset, 7) -- Use calculated x position
        y_offset = y_offset + 10
      end
      
      y_offset = y_offset + 10 -- Extra spacing between sections
    end
  end

  return {
      controller = credits_controller,
      view = credits_view
  }
end
