  hi MACRO
    .486                       ; create 32 bit code
    .model flat, stdcall       ; 32 bit memory model
    option casemap :none       ; case sensitive
    ReEntryPoint PROTO
    includelib smalled.lib
    .data
      MASM32Object MASM32OBJECT <ReEntryPoint,0,0,0>
    .code
    application:
  ENDM

  MASM32OBJECT STRUCT
    editor      dd  ?
    notwritten1 dd  ?
    notwritten2 dd  ?
    notwritten3 dd  ?
    notwritten4 dd  ?
  MASM32OBJECT ENDS

  bye MACRO
    end application
  ENDM
