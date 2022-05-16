' ----------------------------------
' Put your in & out file names here.
' Run this file from the QBASIC
' editor by pressing F5. The example
' asm file uses "list.asm" as in include
' so be sure to put the correct file
' names that you need.
'
' It converts a list of text items
' into the format needed to be added
' in the asm source file.
' ----------------------------------

SourceFile$ = "list.txt"
Destination$ = "list.asm"

OPEN SourceFile$ FOR INPUT AS #1
OPEN Destination$ FOR OUTPUT AS #2

    rf% = 0
    DO
      LINE INPUT #1, a$
      a$ = "db " + CHR$(34) + a$ + CHR$(34) + ",0"

      b$ = "    item" + RIGHT$(STRING$(6, "0") + LTRIM$(STR$(rf%)), 6) + " " + a$
      PRINT #2, b$
      rf% = rf% + 1
    LOOP WHILE NOT EOF(1)

    b$ = "    lastbyte db 0"
    IF b$ <> "" THEN
      PRINT #2, b$
    END IF

CLOSE #2
CLOSE #1

