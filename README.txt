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
01,02,03,04, result
  ,  ,  ,  , 1
  ,  ,  , 1, 12
  ,  , 1,  , 1
  ,  , 1, 1, 4
  , 1,  ,  , 1
  , 1,  , 1, 1
```

To get a tas file set up for any particular combination, copy the full line, for example: "  ,  , 1, 1, 4" into the top of the file "test.lua" in the line that says permutationstring.
So for this example it would say:

```
permutationstring = "  ,  , 1, 1, 4"
```

Then run the test.lua script in FCEUX with the correct rom + tas opened, and it will load in the tas files that were used for that permutation.



# Setting up tests

The file "describe.lua" defines the different tas files to load in and how to determine the results of each test.

## Variations

What's most important is the list of variations, these look like:

```
variations[1] = {
    groups = {"enter-door"},
    insertAt = 2000,
    inputs = load_tas_inputs("tas\\enter-door-early.tas")
}
```

The number in 'variantions[1]' is which column in the resulting csv file will indicate if this tas file was loaded or not
so the very first column in the output file will be 1 if that permutation used this tas file.

insertAt is where in the tas file this variation should be inserted, so for this example the inputs from the enter-door-early.tas file
will be written starting on frame 2000.

To create the tas files, select some frames in FCEUX tas editor, copy them, and paste them into a text file and save it as "whatever.tas"

The script that runs the tas will make sure there's only one variation loaded per "group", so if you have two scripts like "enter-door-early" and "enter-door-late"
that conflict with eachother you can place them in an "enter-door" group for example and they will never be used at the same time.

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
