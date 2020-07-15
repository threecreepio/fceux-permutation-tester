require('./utils/smb')
framerule = 551

-- base file to include before all the variations
base = load_tas_inputs("tas\\base.tas")

--- csv file to write results into
filename = string.format("%d.csv", framerule)

variations = {}
variations[1]  = { group = "LA", name = "DE", insertAt =  403, inputs = load_tas_inputs("tas\\lakitu-spiny-despawn.tas") }
variations[2]  = { group = "LA", name = "EB", insertAt =  403, inputs = load_tas_inputs("tas\\lakitu-early-bop.tas") }
variations[3]  = { group = "LA", name = "LB", insertAt =  403, inputs = load_tas_inputs("tas\\lakitu-late-bop.tas") }

variations[4]  = { group = "H1", name = " E", insertAt =  580, inputs = load_tas_inputs("tas\\hallway-1-early.tas") }
variations[5]  = { group = "H1", name = " L", insertAt =  580, inputs = load_tas_inputs("tas\\hallway-1-late.tas") }
variations[5]  = { group = "H2", name = " 1", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-1.tas") }
variations[6]  = { group = "H2", name = " 2", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-2.tas") }
variations[7]  = { group = "H2", name = " 3", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-3.tas") }
variations[8]  = { group = "H2", name = " 4", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-4.tas") }
variations[9]  = { group = "H2", name = " 5", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-5.tas") }

variations[10] = { group = "CK", name = " 1", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-1.tas") }
variations[11] = { group = "CK", name = " 2", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-2.tas") }
variations[12] = { group = "CK", name = " 3", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-3.tas") }
variations[13] = { group = "CK", name = " 4", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-4.tas") }
variations[14] = { group = "CK", name = " 5", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-5.tas") }

variations[15] = { group = "CB", name = " E", insertAt =  927, inputs = load_tas_inputs("tas\\cannonbuzzy-1.tas") }
variations[16] = { group = "CB", name = " L", insertAt =  927, inputs = load_tas_inputs("tas\\cannonbuzzy-2.tas") }

variations[17] = { group = "PN", name = " B", insertAt = 1060, inputs = load_tas_inputs("tas\\pen-1.tas") }

variations[18] = { group = "GK", name = " B", insertAt = 1320, inputs = load_tas_inputs("tas\\gauntlet-1.tas") }


--- final frame where the result is printed
ending_frame = 1529

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
        print(string.format("setting rng to %02X%02X%02X%02X%02X%02X%02X", seed[1], seed[2], seed[3], seed[4], seed[5], seed[6], seed[7]))
        -- and overwrite the games rng values
        smb1rng_apply(seed)
    end
end)