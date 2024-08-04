function EngineTrail()
    local warpDriveTrail = {}
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

    function warpDriveTrail:update(x, y)
        for p in all(particles) do
            p.life -= rnd(0.1)
            p.x += p.speed
            if p.life <= 0 then
                p.x, p.y, p.speed, p.life, p.starting_life = x, y, rnd(0.075) + 0.25, rnd(0.25) + 0.5, rnd(0.25) + 0.5
            end
        end
    end

    function warpDriveTrail:draw()
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

    for i = 1, 333 do
        add(particles, Particle(-30, -30))
    end
    
    return warpDriveTrail
end

function Xwing(triggerThreshold)
    triggerThreshold = triggerThreshold or 100
    local animation_system = { position = { x = -100, y = 50 } }
    local active, triggerDelta = false, nil
    local wdt1, wdt2 = EngineTrail(), EngineTrail()

    local function origin(relative_x, relative_y)
        return animation_system.position.x + relative_x, animation_system.position.y + relative_y
    end

    local function controller()
        animation_system.position.x -= 3
        if triggerDelta then triggerDelta += 1 end
        if active and animation_system.position.x < -64 then
            animation_system.position.x = 200
            active = false
        end
        wdt1:update(origin(30, 6))
        wdt2:update(origin(30, 10))
    end

    local function view()
        local sx, sy = (124 % 16) * 8, flr(124 / 16) * 8
        local ox, oy = origin(0, 0)
        sspr(sx, sy, 32, 16, ox, oy)
        wdt1:draw()
        wdt2:draw()
    end

    local function tryToTrigger()
        if not triggerDelta or triggerDelta > triggerThreshold then
            active, triggerDelta = true, 0
        end
    end

    return { view = view, controller = controller, trigger = tryToTrigger }
end
