' ###########################################################################

    #COMPILE DLL

    #INCLUDE "d:\pb6\winapi\win32api.inc"

' ###########################################################################

FUNCTION LibMain(BYVAL hInst    AS LONG, _
                 BYVAL Reason   AS LONG, _
                 BYVAL Reserved AS LONG) EXPORT AS LONG

    FUNCTION = 1

END FUNCTION

' ###########################################################################

FUNCTION Sqrt alias "Sqrt"(ByVal value as LONG) EXPORT as LONG

    FUNCTION = sqr(value)

END FUNCTION

' ###########################################################################

FUNCTION ShowValue alias "ShowValue"(ByVal value as LONG) EXPORT as LONG

    FUNCTION = MessageBox(0,ByCopy str$(value),"Show Value",%MB_OK)

END FUNCTION

' ###########################################################################

FUNCTION Add_1 alias "Add_1"(ByVal value as LONG) EXPORT as LONG

    FUNCTION = value + 1

END FUNCTION

' ###########################################################################

FUNCTION Minus_1 alias "Minus_1"(ByVal value as LONG) EXPORT as LONG

    FUNCTION = value - 1

END FUNCTION

' ###########################################################################
