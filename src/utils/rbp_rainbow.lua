
-- @EXPERIMENTAL FEATURE: Jelly's Rainbow Progression (aka rbp_)
-- How it works: As the score increases, players will accumulate rainbow colors.
-- The colors will be displayed as a trail behind the player.
rbp_enabled = true -- feature toggle
rbp_colors = {RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, DARK_PURPLE} -- the colors of the rainbow
rpb_particle_lifetime = 15
rpb_particles = {}
rbp_score_color_step = 5 -- the score increment at which the rainbow band will grow
rpb_score_threshold = 15 -- the score at which the rainbow band will start to appear

-- @EXPERIMENTAL FEATURE: Jelly's Rainbow Progression (aka rbp_)
-- This creates the default rainbow band state
function rbp_make_rainbow_band (number_of_colors_to_display, x, y, lifetime)
    return {
        x = x,
        y = y,
        lifetime = lifetime,
        colors = {unpack(rbp_colors, 1, number_of_colors_to_display)}
    }
end

-- @EXPERIMENTAL FEATURE: Jelly's Rainbow Progression (aka rbp_)
-- This function renders a rainbow band
-- It will turn off pixels based on the distance from the front of the band so that the band fades out and "sparkles"
function rbp_render_rainbow_band (band)
    for i = 1, #band.colors do
        -- there is a chance this pixel is transparent
        -- this happens more often the further back in the band we go
        local distanceCoefficient = 1 - (band.lifetime / rpb_particle_lifetime)
        if rnd(0.8) < distanceCoefficient then
            -- since lua doesn't support "continue" we have to use goto (see ::continue:: below)
            goto continue
        end

        local x = band.x
        local y = band.y - i
        local width = 1
        local height = 1
        local color = band.colors[i]

        -- draw as rectangle
        rectfill(x, y, x + width, y + height, color)
        ::continue::
    end
end

-- @EXPERIMENTAL FEATURE: Jelly's Rainbow Progression (aka rbp_)
-- This function is called every frame to update the rainbow band and is responsible for rendering the band
function rbp_draw_update()
    -- if not enabled, do nothing
    if not rbp_enabled then
        return
    end
    
    -- calculate where the rainbow band should be
    local top = player.y + 8
    local bottom = player.y + 8
    local left = player.x - 2

    -- the player will see no rainbow until they reach the minimum score threshold of rpb_score_threshold
    -- then every mod of rpb_score_color_step will add a new color to the rainbow band
    -- until the maximum number of colors is reached based on the length of rbp_colors
    local number_of_colors_to_display = 0 + flr((score - rpb_score_threshold) / rbp_score_color_step)
    local test_band = rbp_make_rainbow_band(number_of_colors_to_display, left, top, rpb_particle_lifetime)
    
    -- add it to the list of particles
    add(rpb_particles, test_band)

    -- loop through all patricles
    for i = #rpb_particles, 1, -1 do
        local particle = rpb_particles[i]
        particle.x = particle.x - 1
        rbp_render_rainbow_band(particle)
        particle.lifetime = particle.lifetime - 1
        if particle.lifetime == 0 then
            del(rpb_particles, particle)
        end
    end
end
