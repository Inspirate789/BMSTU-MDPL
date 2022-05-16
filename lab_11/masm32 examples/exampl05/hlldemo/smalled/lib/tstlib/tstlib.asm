
    .486                       ; create 32 bit code
    .model flat, stdcall       ; 32 bit memory model
    option casemap :none       ; case sensitive

    ReEntryPoint PROTO
    includelib smalled.lib

    .code

start:

    call ReEntryPoint

end start
