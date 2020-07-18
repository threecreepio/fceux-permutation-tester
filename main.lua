require('./utils/tas')
require('./describe')

local log_exists = false
local log = io.open(filename, "r")
if log ~= nil then
    log_exists = true
    log:close()
end

log = io.open(filename, "a+")
if log_exists == false then
    log:write(string.format("%s", prefix_header))
    for i=1,#groups,1 do
        log:write(string.format(",%s", groups[i].name))
    end
    log:write("\n")
    log:flush()
end

function empty_permutation()
    local result = {}
    for i=1,#groups,1 do
        result[i] = groups[i].variations[1].name
    end
    return result
end

function advance_permutation(set)
    local found = false
    local next = {}
    local starting_frame = 0
    for i=1,#set,1 do
        next[i] = set[i]
    end
    for i=#groups,1,-1 do
        local current = set[i]
        local v = groups[i].variations
        if current == nil then
            current = v[1].name
        end
        local idx = array_find(groups[i].variations, function (v) return v.name == current end)
        if idx >= #v then
            next[i] = v[1].name
        else
            next[i] = v[idx + 1].name
            starting_frame = v[idx + 1].insertAt - 1
            found = true
            break
        end
    end
    if found == true then
        return next, starting_frame
    end
end

function run_permutations(current, starting_frame)
    if current ~= nil then
        print("---")
        print(array_join(current, ","))
        log:flush()
        apply_tas_inputs(base, starting_frame, starting_frame)
        for i=1,#groups,1 do
            local group = groups[i]
            local selection = current[i]
            local idx, variation = array_find(group.variations, function (v) return v.name == selection end)
            print(string.format("applying %s at frame %d", variation.inputs.filename, variation.insertAt))
            apply_tas_inputs(variation.inputs, variation.insertAt)
        end
        previous = p
        jump_to_frame(ending_frame, function ()
            log:write(string.format("%s,%s,", prefix_rows, array_join(current, ",")))
            writeresult(log, function()
                log:write("\n")
                log:flush()
                local next, starting_frame = advance_permutation(current)
                run_permutations(next, starting_frame)
            end)
        end)
        return
    end

    log:close()
    print("we only bloody did it.")
    emu.pause()
end

local permutation = empty_permutation()
if log_exists then
    print("restoring position..")
    local target = 0
    local line = ""
    for l in io.lines(filename) do
        if target ~= 0 then
            line = l
        end
        target = 1
    end
    if line ~= "" then
        local v = string.sub(line, string.len(prefix_header) + 2):split(",")
        for i=1,#groups,1 do
            permutation[i] = v[i]
        end
        permutation = advance_permutation(permutation)
    end
end

cachebreak(1)
run_permutations(permutation, 0)
