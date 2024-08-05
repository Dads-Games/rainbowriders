function throttle(func, limit)
    local last_call = 0
    return function(...)
        local current_time = time()
        if current_time - last_call >= limit then
            last_call = current_time
            return func(...)
        end
    end
end
