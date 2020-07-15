require('./utils/tas')
require('./describe')

local log = io.open(filename, "w")
local permutations = bit.lshift(1, #variations)
local previous = -1

local groups = {}
local group_idx = 1
for i=1,#variations,1 do
    local group = variations[i].group
    if groups[group] == nil then
        groups[group] = { index = group_idx, count = 1 }
        variations[i].group_id = group_idx
        variations[i].group_index = 1
        group_idx = group_idx + 1
        log:write(string.format("%s,", group))
    else
        variations[i].group_id = groups[group].index
        variations[i].group_index = groups[group].count
        groups[group].count = groups[group].count + 1
    end
end
log:write("result\n")

variations_inv = {}
for i=#variations,1,-1 do
    variations_inv[#variations_inv + 1] = variations[i]
    variations[i].variation_index = i
end

function find_starting_frame(previous, next)
    local diff = bit.bxor(previous, next)
    local start = 1000000
    if previous > -1 then
        for m=0,#variations_inv,1 do
            if bit.band(diff, bit.lshift(1, m)) > 0 then
                local t = variations_inv[m + 1].insertAt - 1
                if t < start then
                    start = t
                end
            end
        end
    end
    if start == 1000000 then
        start = 1
    end
    return start
end

function format_row(cfg)
    s = ""
    for i=1,group_idx-1,1 do
        found = "  "
        for j=1,#cfg,1 do
            if cfg[j].group_id == i then
                found = cfg[j].name
                break
            end
        end
        s = string.format("%s%s,", s, found)
    end
    return s
end

function continue_permutations()
    for p=previous+1,permutations-1,1 do
        local valid = true
        local configuration = {}
        local groups = {}
        for v=0,#variations_inv,1 do
            if bit.band(p, bit.lshift(1, v)) > 0 then
                local variant = variations_inv[v + 1]
                if variant.group_id ~= nil and groups[variant.group_id] then
                    valid = false
                    break
                end
                groups[variant.group_id] = true
                configuration[#configuration + 1] = variant
            end
        end
        if valid then
            print("---")
            print(string.format("running #%d", p))
            log:flush()
            log:write(format_row(configuration))
            starting_frame = find_starting_frame(previous, p)
            apply_tas_inputs(base, starting_frame, starting_frame)
            for i=1,#configuration,1 do
                print(string.format("applying %d - %s at frame %d", configuration[i].variation_index, configuration[i].inputs.filename, configuration[i].insertAt))
                apply_tas_inputs(configuration[i].inputs, configuration[i].insertAt)
            end
            previous = p
            jump_to_frame(ending_frame, function ()
                writeresult(log)
                log:write("\n")
                log:flush()
                continue_permutations()
            end)
            return
        end
    end

    log:close()
    emu.pause()
end

cachebreak(1)
continue_permutations()
