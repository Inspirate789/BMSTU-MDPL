POASM richedit.

Over the couple of years they have ben posted, there has been many requests
for the source code for both Quick Editor and TheGun. Neither were ever
intended as release code and as a service to 21st century assembler
programming, both will go to the grave with the author. This partially
finished editor based on a rich edit control is aimed among other things to
satisfy the requests for code of this type.

This is a miniature coding editor that is designed to be modified to suit
the individual programmers requirements. It performs most of the basic
functions like file IO, File & Edit menu functions and will accept files
from the command line. It has a standard toolbar that is fully functional.

Features.

1.  Option to build as richedit 1 or 2.
2.  Selectable right click menu at build.
3.  2 system fonts selection at build.
4.  Autoscaling window to screen resolution.
5.  Command line file support.
6.  Drag & Drop enabled.
7.  Large file capacity on both Open & Save.
8.  Merge File support.
9.  Multi option search.
10. Modular design for easier editing.
11. Exit on pressing ESC.
12. Manual keystroke processing in the main message loop for menu hotkeys.
13. Shows how to use conditional assembly directives.
14. Tool tips displayed on the status bar.

RICHEDIT has been build with a middle size application architecture based
on the capacity of MASM to use the "include" directive. This allows the
application to be divided into files that group similar functions so that
they can be found and edited in a more convenient manner.

It is modular style programming in a simple form and can be written into a
more complicated and larger application while keeping related procedures
together. This aids navigation and maintainance of the code.

In its current form, the procedures are listed below under the files that
they are in.

Procedure map.

RICHEDIT.ASM
~~~~~~~~~~~~
WinMain
WndProc
TopXY
EditControl
hEditProc

FILEDLGS.ASM
~~~~~~~~~~~~
GetFileName
SaveFileName

FILEIO.ASM
~~~~~~~~~~
ofCallBack
sfCallBack
StreamFileIn
StreamFileOut
MergeFile

MISC.ASM
~~~~~~~~
Select_All
Confirmation

SEARCH.ASM
~~~~~~~~~~
CallSearchDlg
SearchProc
TextFind

STATUSBR.ASM
~~~~~~~~~~~~
Do_Status

TOOLBAR.ASM
~~~~~~~~~~~
Do_ToolBar
SetBmpColor