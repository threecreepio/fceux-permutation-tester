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

function apply_tas_inputs(inputs, frame)
    j=frame
    taseditor.stopseeking()
    taseditor.setplayback(0)
    for i=0,1000000,1 do
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

function seek_frame(target)
    local fc = emu.framecount()
    if target < fc then
        taseditor.setplayback(target - 1)
        emu.frameadvance()
    else
        for f=fc,target-1,1 do
            emu.frameadvance()
        end
    end
end

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end
