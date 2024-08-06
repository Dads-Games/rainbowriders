function pause_suppress()
    if btnp(6) then poke(0x5f30,1) end --suppress start button for pause
    if keypress == 'p' then poke(0x5f30,1) end --suppress 'p' for pause
end