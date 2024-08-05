-- Define the laser class
function Laser(x, y)
    return {
        x = x,
        y = y,
        speed = 4,
        update = function(self)
            self.x -= self.speed
        end,
        draw = function(self)
            rectfill(self.x, self.y, self.x + 2, self.y + 1, 8)
        end,
        is_off_screen = function(self)
            return self.x < 0
        end
    }
end

-- Define the EngineTrail class
function EngineTrail()
    local eTrail = {}
    local colors_over_lifetime = {
        { color = 7, percent = 0.1 },
        { color = 10, percent = 0.3 },
        { color = 9, percent = 0.6 },
        { color = 8, percent = 0.9 },
    }
    
    local particles = {}

    local function Particle(x, y)
        local starting_life = rnd(0.25) + 0.5
        return {
            x = x,
            y = y,
            speed = rnd(0.075) + 0.25,
            life = starting_life,
            starting_life = starting_life
        }
    end

    function eTrail:update(x, y)
        for p in all(particles) do
            p.life -= rnd(0.5)
            p.x += p.speed
            if p.life <= 0 then
                p.x, p.y, p.speed, p.life, p.starting_life = x, y, rnd(0.075) + 0.25, rnd(0.25) + 0.5, rnd(0.25) + 0.5
            end
        end
    end

    function eTrail:draw()
        for p in all(particles) do
            local percent = 1 - (p.life / p.starting_life)
            local color = 8
            for i = 1, #colors_over_lifetime do
                if percent < colors_over_lifetime[i].percent then
                    color = colors_over_lifetime[i].color
                    break
                end
            end
            pset(p.x + rnd(3) * (rnd(1) > 0.5 and 1 or -1), p.y + flr(rnd((1 - percent) * 3) - 1), color)
        end
    end

    for i = 1, 30 do
        add(particles, Particle(-30, -30))
    end
    
    return eTrail
end

-- Define the Xwing class
function Xwing(triggerThreshold)
    local triggerThreshold = triggerThreshold or 100
    local animation_system = { position = { x = -100, y = 50 } }
    local active, triggerDelta = false, nil
    local wdt1, wdt2 = EngineTrail(), EngineTrail()
    local lasers = {}
    local swoop_amplitude = 8
    local swoop_frequency = 0.0125

    local function origin(relative_x, relative_y)
        return animation_system.position.x + relative_x, animation_system.position.y + relative_y
    end

    local function controller()
        if active then
            animation_system.position.x -= 2
            animation_system.position.y = 50 + sin(animation_system.position.x * swoop_frequency) * swoop_amplitude
            
            if triggerDelta then triggerDelta += 1 end
            if active and animation_system.position.x < -64 then
                animation_system.position.x = 200
                active = false
            end
            
            wdt1:update(origin(30, 6))
            wdt2:update(origin(30, 10))
            
            -- Update lasers
            for laser in all(lasers) do
                laser:update()
                if laser:is_off_screen() then
                    del(lasers, laser)
                end
            end

            -- Shoot laser every 30 frames
            if (triggerDelta % 30 == 0) then
                add(lasers, Laser(origin(-8, 8)))
            end
        end
    end

    local function view()
        local sx, sy = (124 % 16) * 8, flr(124 / 16) * 8
        local ox, oy = origin(0, 0)
        sspr(sx, sy, 32, 16, ox, oy)
        if ox > -128 and ox < 128 then
            wdt1:draw()
            wdt2:draw()
        end

        -- Draw lasers
        for laser in all(lasers) do
            laser:draw()
        end
    end

    local function tryToTrigger()
        if not triggerDelta or triggerDelta > triggerThreshold then
            active, triggerDelta = true, 0
        end
    end

    return { view = view, controller = controller, trigger = tryToTrigger }
end
