require('./utils/tas')
require('./describe')

-- copy a full line from the csv file
permutationstring = "  ,  , 1, 5"



---
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


local set_v = permutationstring:split(",")
local base = load_tas_inputs("tas\\base.tas")
apply_tas_inputs(base, 0)
for v=1,#variations,1 do
    if set_v[v] == " 1" then
        local variant = variations[v]
        print(string.format("applying %d - %s at frame %d", v, variant.inputs["filename"], variant.insertAt))
        apply_tas_inputs(variant.inputs, variant.insertAt)
    end
end

emu.pause()
