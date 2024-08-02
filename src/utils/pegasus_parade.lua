function PegasusParade (zone)
    local zone = zone or {
        top = 0,
        bottom = 128,
        left = 0,
        right = 128
    }

    local position = {
        x = 0,
        y = 0
    }

    local pegasuses = {}
    local particles = {}
    local rainbow_colors = {8,9,10,11,12,14}  -- PICO-8 rainbow colors

    local origin = {
        x = function (x)
            return x + position.x
        end,
        y = function (y)
            return y + position.y
        end
    }

    local step = 0

    function draw_big_peglette (x, y, flip_x, flip_y)
        x = x or 0
        y = y or 0
        flip_x = flip_x or false
        flip_y = flip_y or false

        local sx = (208 % 16) * 8
        local sy = flr(208 / 16) * 8 + 6
        
        sspr(sx, sy, 24, 22, x, y, 24, 22, flip_x, flip_y)
    end

    function draw_small_peglette (x, y, flip_x, flip_y)
        x = x or 0
        y = y or 0
        flip_x = flip_x or false
        flip_y = flip_y or false

        local sx = (118 % 16) * 8
        local sy = flr(118 / 16) * 8
        
        sspr(sx, sy, 12, 9, x, y, 12, 9, flip_x, flip_y)
    end

    function create_particle(x, y, dx, dy, life, color)
        add(particles, {
            x = x,
            y = y,
            dx = dx,
            dy = dy,
            life = life,
            color = color
        })
    end

    function update_particles()
        for i = #particles, 1, -1 do
            local p = particles[i]
            p.x += p.dx
            p.y += p.dy
            p.life -= 1
            if p.life <= 0 then
                deli(particles, i)
            end
        end
    end

    function draw_particles()
        for p in all(particles) do
            pset(p.x, p.y, p.color)
        end
    end

    function ease_out_quad(t)
        return 1 - (1 - t) * (1 - t)
    end

    function create_pegasus(is_big)
        local config = {
            big = {
                quantity = 2,
                offset_min = zone.left - 80,
                offset_max = zone.left - 40,
                speed_min = 1.5,
                speed_max = 2.5,
                hop_height_min = 8,
                hop_height_max = 16,
                hop_duration_min = 40,
                hop_duration_max = 60,
                draw_func = draw_big_peglette
            },
            small = {
                quantity = flr(rnd(5)) + 4,
                offset_min = zone.left - 60,
                offset_max = zone.left - 20,
                speed_min = 2,
                speed_max = 3,
                hop_height_min = 4,
                hop_height_max = 8,
                hop_duration_min = 30,
                hop_duration_max = 50,
                draw_func = draw_small_peglette
            }
        }

        local c = is_big and config.big or config.small

        for i = 1, c.quantity do
            local initial_y = rnd(zone.bottom - zone.top - 40) + zone.top + 20
            add(pegasuses, {
                big = is_big,
                x = is_big and -rnd(120) or rnd(c.offset_max - c.offset_min) + c.offset_min,
                y = initial_y,
                base_y = initial_y,
                speed = rnd(c.speed_max - c.speed_min) + c.speed_min,
                hop_height = rnd(c.hop_height_max - c.hop_height_min) + c.hop_height_min,
                hop_duration = flr(rnd(c.hop_duration_max - c.hop_duration_min) + c.hop_duration_min),
                hop_timer = rnd(c.hop_duration_max),
                draw = function(self)
                    self.x += self.speed
                    
                    self.hop_timer += 1
                    if self.hop_timer >= self.hop_duration then
                        self.hop_timer = 0
                    end
                    
                    local hop_progress = self.hop_timer / self.hop_duration
                    local hop_height = self.hop_height * ease_out_quad(1 - abs(2 * hop_progress - 1))
                    
                    self.y = self.base_y - hop_height
                    
                    -- Create rainbow trail particles
                    local num_particles = self.big and 3 or 2
                    for i = 1, num_particles do
                        local color = rainbow_colors[flr(rnd(#rainbow_colors)) + 1]
                        create_particle(
                            self.x + rnd(8) - 4,
                            self.y + rnd(8) - 4,
                            -rnd(0.5) - 0.5,
                            rnd(0.2) - 0.1,
                            20 + rnd(10),
                            color
                        )
                    end
                    
                    c.draw_func(self.x, self.y, true, false)
                end
            })
        end
    end

    function draw ()
        draw_particles()
        
        print ('Pegasus On Screen = ' .. #pegasuses, 0, 0, 7)
        
        for i, pegasus in pairs(pegasuses) do
            pegasus.draw(pegasus)
        end
    end

    function update ()
        step = step + 1
        if step > 1000 then step = 0 end
        update_particles()
    end

    function trigger()
        pegasuses = {}
        particles = {}
    
        create_pegasus(true)   -- Create big pegasuses
        create_pegasus(false)  -- Create small pegasuses
    end

    return {
        draw = draw,
        update = update,
        trigger = trigger
    }
end