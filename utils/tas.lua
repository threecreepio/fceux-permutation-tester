function tasline_to_input(line)
    local inp = 0
    for c in line:gmatch(".") do
        if c == "A" then
            inp = OR(inp, 1)
        end
        if c == "B" then
            inp = OR(inp, 2)
        end
        if c == "S" then
            inp = OR(inp, 4)
        end
        if c == "T" then
            inp = OR(inp, 8)
        end
        if c == "U" then
            inp = OR(inp, 16)
        end
        if c == "D" then
            inp = OR(inp, 32)
        end
        if c == "L" then
            inp = OR(inp, 64)
        end
        if c == "R" then
            inp = OR(inp, 128)
        end
    end
    return inp
end

function load_tas_inputs(filename)
    local f = io.open(filename,'r')
    if f == nil then
        print(string.format("could not open file %s.", filename))
    end
    f:read()
    result = {}
    for i=0,1000000,1 do
        line = f:read()
        if line == nil then
            break
        end
        result[i] = tasline_to_input(line)
    end
    result["filename"] = filename
    return result
end

function cachebreak(frame)
    local new_inputs = bit.band(0xFF, taseditor.getinput(frame, 1) + 1)
    taseditor.stopseeking()
    taseditor.setplayback(0)
    taseditor.submitinputchange(frame, 1, new_inputs)
    taseditor.applyinputchanges()
    taseditor.setplayback(10000)
end

function apply_tas_inputs(inputs, dest_frame, starting_frame, ending_frame)
    j=dest_frame
    taseditor.stopseeking()
    taseditor.setplayback(0)
    local max = 1000000
    local start = 0
    if starting_frame ~= nil then
        start = starting_frame
    end
    if ending_frame ~= nil then
        max = ending_frame - starting_frame
    end
    for i=start,max,1 do
        line = inputs[i]
        if line == nil then
            break
        end
        taseditor.submitinputchange(j, 1, line)
        j = j + 1
    end
    taseditor.applyinputchanges()
    taseditor.setplayback(10000)
    return j
end

function jump_to_frame(target, after)
    local prev = nil
    prev = emu.registerafter(function ()
        if prev ~= nil then
            prev()
        end
        if emu.framecount() >= target then
            emu.registerafter(prev)
            if after ~= nil then
                after()
            end
        end
    end)
    taseditor.setplayback(target)
    emu.unpause()
end

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c)
        fields[#fields+1] = c
    end)
    return fields
end
