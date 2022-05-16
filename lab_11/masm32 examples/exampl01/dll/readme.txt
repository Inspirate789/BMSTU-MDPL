Notes on tstdll.dll

tstdll.asm and the assembled dynamic link library uses a standard LibMain
function that is called by the operating system when the DLL is called by
an application. This function should not be called by the application, it
performs initialisation and exit code which you can write into the LibMain
depending on the application.

Note that the only return value that is used in LibMain is for the
DLL_PROCESS_ATTACH constant passed to the LibMain function by the operating
system. If the DLL initialises correctly, the return value should be TRUE,
if there is an error of some type, the value returned should be zero [ 0 ]
which will abort the loading of the DLL.

The DLL is to be assembled with the batch file "BldDLL.bat". The linker
also produces a library which is to be used in an application that loads
the DLL at startup. A normal prototype is required if the DLL is used this
way.

There are two examples of how to use this same DLL, one uses the library
and a prototype at startup, the other uses LoadLibrary(), GetProcAddress()
and FreeLibrary() functions to call the DLL directly.

Please not that the DLL MUST use a definition file for its EXPORTS, this is
the DEF file in the directory. The syntax is as follows

LIBRARY tstdll
EXPORTS TestProc

The LIBRARY controls the NAME of the DLL, the EXPORTS controls the content
of the EXPORTS table in the DLL file header. You MUST have an EXPORTS entry
in the definition file for each function you wish to EXPORT.

Private functions within the DLL are not exported so they should NOT be put
in the definition file.

                              ---===o===---
