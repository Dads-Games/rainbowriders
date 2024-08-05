function AlienShip (backDropSpeed)
    backDropSpeed = backDropSpeed or -0.1
    
    local enabled
    local position
    local secondaryPosition
    local origin

    -- backdrop offset for the alien ship
    local backdropOffset

    -- track the step in the sequence and the seconds in the timeline
    local step
    local timeline

    -- clipping state for the alien beam in the sprite sheet
    local clipY
    local renderParticles

    -- an ordered table of functions
    local sequence

    function init ()
        enabled = false

        sequence = {
            {
                runUntil = 3,
                fn = function ()
                    hover()
                    moveIntoView()
                end,
            },
            -- rotate the hover
            {
                runUntil = 4,
                fn = function ()
                    hover()
                    renderParticles = false
                end,
            },
            -- move to drop zone
            {
                runUntil = 6,
                fn = function ()
                    moveToDropZone()
                end,
            },
            -- extend the beam
            {
                runUntil = 15,
                fn = function ()
                    moveToDropZone()
                    beamExtend()
                    renderParticles = true
                end,
            },
            -- retract the beam
            {
                runUntil = 16,
                fn = function ()
                    disable()
                end,
            },
        }

        position = {
            x = 200,
            y = 30
        }
    
        secondaryPosition = {
            x = 0,
            y = 0
        }
    
        origin = {
            x = function (x)
                return x + position.x + secondaryPosition.x
            end,
            y = function (y)
                return y + position.y + secondaryPosition.y
            end
        }
    
        -- backdrop offset for the alien ship
        backdropOffset = 0
    
        -- track the step in the sequence and the seconds in the timeline
        step = 1
        timeline = 0
    
        -- clipping state for the alien beam in the sprite sheet
        clipY = 8
        renderParticles = false
    end

    local dropZone = { 100, 88 }
    function moveToDropZone ()
        backdropOffset = backdropOffset + backDropSpeed

        -- using step and ease to move the alien to the drop zone
        local ease = 0.1
        local dx = dropZone[1] - position.x
        local dy = dropZone[2] - position.y
        position.x = position.x + dx * ease + backdropOffset
        position.y = position.y + dy * ease
    end

    local viewZone = { 60, 30 }
    function moveIntoView ()
        -- using step and ease to move the alien into view
        local ease = 0.1
        local dx = viewZone[1] - position.x
        local dy = viewZone[2] - position.y
        position.x = position.x + dx * ease
        position.y = position.y + dy * ease
    end

    function hover ()
        secondaryPosition.x = sin(step / 40) * 14
        secondaryPosition.y = cos(step / 40) * 14
    end

    function beamExtend ()
        if clipY < 16 then
            clipY = clipY + 0.2
        end
    end

    function drawShip (clipY)
        local sx = (116 % 16) * 8
        local sy = flr(116 / 16) * 8
        clipY = clipY or 16

        sspr(
            sx,
            sy, 
            16,
            clipY, 
            origin.x(0),
            origin.y(0)
        )
    end

    function view ()
        if not enabled then
            return
        end

        drawShip(flr(clipY))

        -- particles on? lets render some random colored psets
        if renderParticles then
            local x = origin.x(rnd(16))
            local y = origin.y(rnd(8)) + 8
            local color = rnd({ WHITE, RED, YELLOW })
            pset(x, y, color)
        end
    end

    function controller ()
        -- if not enabled, return
        if not enabled then
            return
        end

        -- increment the step
        step = step + 1
        if step > 10000 then
            step = 1
        end

        -- there are 30 steps in a second
        timeline = flr(step / 30)

        -- let's check if we need to move to the next sequence
        local activeSequence = sequence[1]

        -- if the activeSequence has an until and the step is greater than the runUntil
        -- remove the first item from the table and set the next sequence to the first item
        if (
            activeSequence.runUntil 
            and timeline > activeSequence.runUntil 
            and #sequence > 1
        ) then
            del(sequence, activeSequence)
            activeSequence = sequence[1]
        end

        -- call the function in the sequence
        activeSequence.fn()
    end

    function disable ()
        enabled = false
    end

    function trigger ()
        init()
        enabled = true
    end

    init()

    return {
        view = view,
        controller = controller,
        disable = disable,
        trigger = trigger,
        init = init -- use this to reset the alien ship
    }
end
