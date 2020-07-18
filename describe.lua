require('./utils/smb')
-- which framerule to test
if framerule == nil then
    framerule = arg
end
prefix_header = " FR"
prefix_rows = string.format("%3d", framerule)

-- base file to include before all the variations
base = load_tas_inputs("tas\\base.tas")

--- csv file to write results into
filename = string.format("%s.csv", framerule)

variations = {
    { group = "1K", name = " E", insertAt =  320, inputs = load_tas_inputs("tas\\firstkoop-early.tas") },
    { group = "1K", name = " L", insertAt =  320, inputs = load_tas_inputs("tas\\firstkoop-late.tas") },
    
    { group = "2K", name = " B", insertAt =  370, inputs = load_tas_inputs("tas\\secondkoop-bop.tas") },

    { group = "LA", name = " D", insertAt =  419, inputs = load_tas_inputs("tas\\lakitu-spiny-despawn.tas") },
    { group = "LA", name = " E", insertAt =  419, inputs = load_tas_inputs("tas\\lakitu-early-bop.tas") },
    { group = "LA", name = " L", insertAt =  419, inputs = load_tas_inputs("tas\\lakitu-late-bop.tas") },

    { group = "H1", name = " E", insertAt =  580, inputs = load_tas_inputs("tas\\hallway-1-early.tas") },
    { group = "H1", name = " L", insertAt =  580, inputs = load_tas_inputs("tas\\hallway-1-late.tas") },
    
    { group = "H2", name = " 1", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-1.tas") },
    { group = "H2", name = " 2", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-2.tas") },
    { group = "H2", name = " 3", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-3.tas") },
    { group = "H2", name = " 4", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-4.tas") },
    { group = "H2", name = " 5", insertAt =  640, inputs = load_tas_inputs("tas\\hallway-2-5.tas") },
    
    { group = "CK", name = " 1", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-1.tas") },
    { group = "CK", name = " 2", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-2.tas") },
    { group = "CK", name = " 3", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-3.tas") },
    { group = "CK", name = " 4", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-4.tas") },
    { group = "CK", name = " 5", insertAt =  800, inputs = load_tas_inputs("tas\\cannonkoops-5.tas") },
    
    { group = "CB", name = " E", insertAt =  927, inputs = load_tas_inputs("tas\\cannonbuzzy-1.tas") },
    { group = "CB", name = " L", insertAt =  927, inputs = load_tas_inputs("tas\\cannonbuzzy-2.tas") },
    
    { group = "PN", name = " B", insertAt = 1060, inputs = load_tas_inputs("tas\\pen-1.tas") },
    
    { group = "GK", name = " B", insertAt = 1320, inputs = load_tas_inputs("tas\\gauntlet-1.tas") },
}

--- final frame where the result is printed
ending_frame = 1529


function write_bullet_positions(log)
    -- mark as failed if mario didnt make it to the end of the stage
    if EnemyX(-1) < 3000 then
        log:write("   FAILED,   FAILED,")
        print("failed to reach the end!")
        return
    end

    -- find all currently spawned bullets, storing them based on their y position
    local bullets = {}
    for i=0,5,1 do
        if memory.readbyte(Enemy_ID + i) == BulletBill_CannonVar then
            -- ignore any bullets heading the wrong direction
            if memory.readbytesigned(Enemy_X_Speed + i) > 0 then
                bullets[EnemyY(i)] = i
            end
        end
    end

    -- write out bullet positions to the log file
    if bullets[56] ~= nil then
        local id = bullets[56]
        local mf = memory.readbyte(Enemy_X_MoveForce + id)
        local mfi = 0
        if mf >= 0x80 then mfi = 1 end
        log:write(string.format(" L-%X-%04d,", bit.ror(mf, 4), EnemyX(id)))
        print(string.format("L-%X-%04d", bit.ror(mf, 4), EnemyX(id)))
    else
        log:write("         ,")
    end
    if bullets[88] ~= nil then
        local id = bullets[88]
        local mf = memory.readbyte(Enemy_X_MoveForce + id)
        local mfi = 0
        if mf >= 0x80 then mfi = 1 end
        log:write(string.format(" H-%X-%04d,", bit.ror(mf, 4), EnemyX(id)))
        print(string.format("H-%X-%04d", bit.ror(mf, 4), EnemyX(id)))
    else
        log:write("         ,")
    end
end

-- called on the final frame to print results to the csv file
function writeresult(log, finish)
    local ofs = 0
    function delay()
        if ofs >= 3 then
            for i=1,4,1 do
                taseditor.submitinputchange(1243 + i, 1, tasline_to_input("BA"))
            end
            taseditor.applyinputchanges()
            return finish()
        end
        ofs = ofs + 1
        for i=1,ofs,1 do
            taseditor.submitinputchange(1243 + i, 1, tasline_to_input("BLA"))
        end
        taseditor.applyinputchanges()
        jump_to_frame(ending_frame, function ()
            write_bullet_positions(log)
            delay()
        end)
    end
    write_bullet_positions(log)
    cachebreak(1257)
    jump_to_frame(1258, delay)
end

-- attempts to move mario out of harms way..
function hacky_move_mario()
    -- move player up to ground if we're falling to our death
    if memory.readbyte(Player_Y_Position) > 178 and memory.readbyte(Player_Y_HighPos) > 0 then
        memory.writebyte(Player_Y_Position, 176)
    end

    -- simulate slow pipe clear??
    --if emu.framecount() == 1280 then
    --    memory.writebyte(Player_X_Position, memory.readbyte(Player_X_Position) - offset_mario_px)
    --end

    -- move player up to skip the gauntlet section
    if emu.framecount() == 1351 then
        memory.writebyte(Player_Y_Position, 0)
    end

    -- move player down in the cannon section if he bounces up to a platform
    if emu.framecount() == 895 then
        memory.writebyte(Player_Y_Position, 170)
    end

    -- move player to just above the first koop if it's time to wail on him
    if emu.framecount() == 835 then
        local koopy = memory.readbyte(Enemy_Y_Position + getclosestenemy())
        local playery = memory.readbyte(Player_Y_Position)
        if playery < koopy then
            memory.writebyte(Player_Y_Position, koopy - 20)
        end
    end

    -- move player up in the cannon section to the cannon after the first koop
    if emu.framecount() == 847 then
        memory.writebyte(Player_Y_Position, 120)
    end
end

-- run on each frame
emu.registerafter(function ()
    -- set player to have 1 frame of iframes every frame
    memory.writebyte(InjuryTimer, 0x02)
    hacky_move_mario()
    -- if we're on the frame before the level becomes visible in base.tas
    if emu.framecount() == 250 then
        local seed = smb1rng_init()
        -- step the rng the amount of frames needed to advance to the framerule we want
        -- which is 4 frames before the actual framerule
        seed = smb1rng_advance(seed, (tonumber(framerule) * 21) - 4)
        print(string.format("setting rng to %02X%02X%02X%02X%02X%02X%02X", seed[1], seed[2], seed[3], seed[4], seed[5], seed[6], seed[7]))
        -- and overwrite the games rng values
        smb1rng_apply(seed)
    end
end)