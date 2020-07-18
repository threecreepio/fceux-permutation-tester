require('./utils/tas')
-- set permutation string from the lua window arguments
permutationstring = arg

---
selections = permutationstring:split(",")
framerule = tonumber(selections[1])
require('./describe')

local base = load_tas_inputs("tas\\base.tas")
apply_tas_inputs(base, 0)
for i=1,#groups,1 do
    local selected = selections[i + 1]
    local idx, variant = array_find(groups[i].variations, function (v) return v.name == selected end)
    print(string.format("applying %s at frame %d", variant.inputs.filename, variant.insertAt))
    apply_tas_inputs(variant.inputs, variant.insertAt)
end

cachebreak(1)
