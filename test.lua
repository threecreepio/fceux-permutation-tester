require('./utils/tas')
require('./describe')

-- set permutation string from the lua window arguments
permutationstring = arg

---
selections = permutationstring:gsub("\\s+", ""):split_to_numbers(",")
--selections = {}
--selections[1] = 1
--selections[5] = 1
--selections[16] = 1

local prev = nil
prev = emu.registerafter(function ()
    if prev ~= nil then
        prev()
    end
    if emu.framecount() == ending_frame then
        local bullets = {}
        for i=0,5,1 do
            if memory.readbyte(Enemy_ID + i) == BulletBill_CannonVar then
                if memory.readbytesigned(Enemy_X_Speed + i) > 0 then
                    bullets[EnemyY(i)] = EnemyX(i)
                end
            end
        end
        if bullets[56] ~= nil then
            print(string.format("L-%d", bullets[56]))
        end
        if bullets[88] ~= nil then
            print(string.format("H-%d", bullets[88]))
        end
    end
end)

local groups = {}
local group_idx = 1
for i=1,#variations,1 do
    local group = variations[i].group
    if groups[group] == nil then
        groups[group] = { index = group_idx, count = 1 }
        variations[i].group_id = group_idx
        variations[i].group_index = 1
        group_idx = group_idx + 1
    else
        variations[i].group_id = groups[group].index
        variations[i].group_index = groups[group].count
        groups[group].count = groups[group].count + 1
    end
end

local base = load_tas_inputs("tas\\base.tas")
apply_tas_inputs(base, 0)
cachebreak(1)

for v=1,#variations,1 do
    local variant = variations[v]
    if selections[variant.group_id] == variant.name then
        print(string.format("applying %d - %s at frame %d", v, variant.inputs["filename"], variant.insertAt))
        apply_tas_inputs(variant.inputs, variant.insertAt)
    end
end

emu.pause()
