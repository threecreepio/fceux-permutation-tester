# FCEUX permutation tester

This is an FCEUX LUA permutation tester, it loads a series of combinations of TAS files, then runs some code to print the result of the test to a CSV file.
The resulting file can be imported into google docs / ms excel or similar for further filtering.

/threecreepio


# Running the script

To run the script, start FCEUX, open the rom you intend to test and a TAS editor, then load "main.lua" into a lua window.

Make sure you have 2 controllers enabled in the TAS!

Run the script and set your emulator speed to turbo.



# Testing results

As the script runs it will create a csv output file with lines that look something like this:

```
LA,H1,H2,CK,CB,PN,GK,result
  ,  ,  ,  ,  ,  ,  ,      ,      
  ,  ,  ,  ,  ,  , B,      ,      
  ,  ,  ,  ,  , B,  ,      ,      
  ,  ,  ,  ,  , B, B,      ,      
  ,  ,  ,  , L,  ,  ,      ,      
  ,  ,  ,  , L,  , B,L-3070,      
  ,  ,  ,  , L, B,  ,      ,      
```

To run a specific line on its own, open a new Lua Script window in FCEUX (with the rom loaded, and tas window opened) select the file "test.lua" and copy+paste the line from the file into "Arguments" in the Lua window, then run the script.

This will load in all the tas files that were used for that particular test.


# Setting up tests

The file "describe.lua" defines the different tas files to load in and how to determine the results of each test.

## Variations

What's most important is the list of variations, these look like:

```
groups = {
    {
        
        name = "1K",
        variations = {
            { name = "  ", insertAt =  320, inputs = load_tas_inputs("tas\\empty.tas") },
            { name = " E", insertAt =  320, inputs = load_tas_inputs("tas\\firstkoop-early.tas") },
            { name = " L", insertAt =  320, inputs = load_tas_inputs("tas\\firstkoop-late.tas") }
        }
    }
```

Each group has a name, in this case "1K" which is printed on the top line of the CSV file, and each variation in that group has a name which is printed on the row.
To make the CSV file more readable I would recommend keeping all of the names the same length within a group.. That way it'll line up nicely!

insertAt is where in the tas file this variation should be inserted, so for this example the inputs from the enter-door-early.tas file
will be written starting on frame 2000.

To create the tas files, select some frames in FCEUX tas editor, copy them, and paste them into a text file and save it as "whatever.tas"

The script that runs the tas will make sure there's only one variation loaded per "group", so if you have two scripts like "enter-door-early" and "enter-door-late"
that conflict with eachother you can place them in the same "Door" group for example and they will never be used at the same time.

## Printing results

There's a function that is run after each test is finished that is used to print results to the csv file.

It can look something like this:

```
function writeresult(log)
    log:write(string.format("%02X,", memory.readbyte(0x300)))
    log:write(string.format("%02X,", memory.readbyte(0x301)))
    log:write(string.format("%02X,", memory.readbyte(0x302)))
end
```

This function would write the bytes at memory address 300, 301 and 302 to the csv file for each permutation.

You can of course make this function as complicated as is needed for the purposes of your test.
