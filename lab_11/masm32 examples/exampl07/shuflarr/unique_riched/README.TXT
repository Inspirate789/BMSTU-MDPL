
The purpose of this example is to produce a unique binary image for the project
each time it is built to defeat static patching of a target application disk
file.

it does this by shuffling a range of file names in an include file and both the
entries for the initialised and uninitialised data sections.

Every time the application is built the 3 effected files are shuffled which
changes the order in which they are included in the assembler project which in
turn changes the order of the binary components within the binary image.

The technique defeats binary patches that target specific offsets in the binary
image and forces the patch maker to design a more complex byte matching patch
that must scan and selectively change the code / data at an unknown offset.

Open the MAKEIT.BAT file to see how this technique works.