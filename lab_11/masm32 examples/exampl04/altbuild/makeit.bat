@echo off

: ------------------------------
: set the environment variables
: ------------------------------
set BIN=\MASM32\BIN\
set INCLUDE=\MASM32\INCLUDE\
set LIB=\MASM32\LIB\

: --------------------
: build the resources
: --------------------
%BIN%rc.exe /v rsrc.rc

: --------------------------------------------------
: build the response file from the modules required
: --------------------------------------------------
echo altbuild.asm > assemble.rsp
echo paint.asm >> assemble.rsp
echo topxy.asm >> assemble.rsp

: -------------------------
: assemble the source file
: -------------------------
%BIN%ml.exe /c /coff @assemble.rsp

: ----------------------------------------------
: build the link response file
: NOTE that the main project file MUST be first
: ----------------------------------------------
echo altbuild.obj > link.rsp
echo paint.obj >> link.rsp
echo topxy.obj >> link.rsp

: --------------------------------------------
: link the object module and set the lib path
: NOTE the RES file is handled by LINK.EXE.
: It automatically calls CVTRES.EXE.
: --------------------------------------------
%BIN%Link.exe /SUBSYSTEM:WINDOWS /LIBPATH:%LIB% @link.rsp rsrc.res

dir altbuild.*

pause
