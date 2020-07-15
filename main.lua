require('./utils/tas')
require('./describe')

local log = io.open(filename, "w")
local permutations = bit.lshift(1, #variations)
local previous = -1

variations_inv = {}
for i=#variations,1,-1 do
    variations_inv[#variations_inv + 1] = variations[i]
    variations[i].column = #variations_inv
    log:write(string.format("%02d,", #variations_inv))
end
log:write(" result\n")

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

function format_bits(num, bits)
    local s = ""
    for i=0,bits,1 do
        rest=math.fmod(num,2)
        if rest > 0 then
            s = string.format(" %d,%s", rest, s)
        else
            s = string.format("  ,%s", s)
        end
        num=(num-rest)/2
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
                if variant.groups ~= nil then
                    for g=1,#variant.groups,1 do
                        if groups[variant.groups[g]] then
                            valid = false
                        end
                    end
                    if valid == false then
                        break
                    end
                    for g=1,#variant.groups,1 do
                        groups[variant.groups[g]] = true
                    end
                end
                configuration[#configuration + 1] = variant
            end
        end
        if valid then
            print("---")
            print(string.format("running #%d", p))

            log:flush()
            log:write(string.format("%s ", format_bits(p, #variations - 1)))
            starting_frame = find_starting_frame(previous, p)
            apply_tas_inputs(base, starting_frame, starting_frame)
            for i=1,#configuration,1 do
                print(string.format("applying %d - %s at frame %d", configuration[i].column, configuration[i].inputs.filename, configuration[i].insertAt))
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
