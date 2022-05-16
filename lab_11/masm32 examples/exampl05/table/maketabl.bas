CLS

lead$ = " db "

OPEN "dbtable.txt" FOR OUTPUT AS #1

cnt% = 0
lct% = 0

PRINT #1, lead$;

DO
PRINT #1, CHR$(34) + RIGHT$("---" + LTRIM$(STR$(cnt%)), 3) + CHR$(34) + ",44,";
cnt% = cnt% + 1
lct% = lct% + 1
  IF lct% = 8 THEN
    PRINT #1, CHR$(13) + CHR$(10) + lead$;
    lct% = 0
  END IF
LOOP WHILE cnt% < 256

CLOSE #1

SHELL "edit.com dbtable.txt"

