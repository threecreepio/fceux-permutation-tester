require('./utils/smb')
framerule = 548

-- base file to include before all the variations
base = load_tas_inputs("tas\\base.tas")

--- csv file to write results into
filename = string.format("%d.csv", framerule)

variations = {}
variations[1]  = { groups = {"lakitu"},      insertAt =  403, inputs = load_tas_inputs("tas\\lakitu-spiny-despawn.tas") }
variations[2]  = { groups = {"lakitu"},      insertAt =  403, inputs = load_tas_inputs("tas\\lakitu-early-bop.tas") }
variations[3]  = { groups = {"lakitu"},      insertAt =  403, inputs = load_tas_inputs("tas\\lakitu-late-bop.tas") }
variations[4]  = { groups = {"hallway1"},    insertAt =  580, inputs = load_tas_inputs("tas\\hallway-1-early.tas") }
variations[5]  = { groups = {"hallway1"},    insertAt =  580, inputs = load_tas_inputs("tas\\hallway-1-late.tas") }
variations[5]  = { groups = {"hallway2"},    insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-1.tas") }
variations[6]  = { groups = {"hallway2"},    insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-2.tas") }
variations[7]  = { groups = {"hallway2"},    insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-3.tas") }
variations[8]  = { groups = {"hallway2"},    insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-4.tas") }
variations[9]  = { groups = {"hallway2"},    insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-5.tas") }
variations[10] = { groups = {"cannonkoop1"}, insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoop1-early.tas") }
variations[11] = { groups = {"cannonkoop1"}, insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoop1-late.tas") }
variations[12] = { groups = {"cannonkoop2"}, insertAt =  855, inputs = load_tas_inputs("tas\\cannonkoop2-1.tas") }
variations[13] = { groups = {"cannonbuzzy"}, insertAt =  927, inputs = load_tas_inputs("tas\\cannonbuzzy-1.tas") }
variations[14] = { groups = {"cannonbuzzy"}, insertAt =  927, inputs = load_tas_inputs("tas\\cannonbuzzy-2.tas") }
variations[15] = { groups = {"pen"},         insertAt = 1060, inputs = load_tas_inputs("tas\\pen-1.tas") }
variations[16] = { groups = {"gauntlet"},    insertAt = 1320, inputs = load_tas_inputs("tas\\gauntlet-1.tas") }

--- final frame where the result is printed
ending_frame = 1530

-- called on the final frame to print results to the csv file
function writeresult(log)
    -- mark as failed if mario didnt make it to the end of the stage
    if EnemyX(-1) < 3000 then
        log:write("failed")
        print("failed to reach the end!")
        return
    end

    -- find all currently spawned bullets, storing them based on their y position
    local bullets = {}
    for i=0,5,1 do
        if memory.readbyte(Enemy_ID + i) == BulletBill_CannonVar then
            -- ignore any bullets heading the wrong direction
            if memory.readbytesigned(Enemy_X_Speed + i) > 0 then
                bullets[EnemyY(i)] = EnemyX(i)
            end
        end
    end

    -- write out bullet positions to the log file
    if bullets[56] ~= nil then
        log:write(string.format("L-%d", bullets[56]))
        print(string.format("L-%d", bullets[56]))
    else
        log:write("      ")
    end
    log:write(",")
    if bullets[88] ~= nil then
        log:write(string.format("H-%d", bullets[88]))
        print(string.format("H-%d", bullets[88]))
    else
        log:write("      ")
    end
end

-- run on each frame
emu.registerafter(function ()
    -- set player to have 1 frame of iframes every frame
    memory.writebyte(InjuryTimer, 0x1)

    -- if we're on the frame before the level becomes visible in base.tas
    if emu.framecount() == 250 then
        local seed = smb1rng_init()
        -- step the rng the amount of frames needed to advance to the framerule we want
        -- which is 4 frames before the actual framerule
        seed = smb1rng_advance(seed, (framerule * 21) - 4)
        print(string.format("%02X%02X%02X%02X%02X%02X%02X", seed[1], seed[2], seed[3], seed[4], seed[5], seed[6], seed[7]))
        -- and overwrite the games rng values
        smb1rng_apply(seed)
    end
end)