; #########################################################################

;     include files
;     ~~~~~~~~~~~~~
      include \masm32\include\windows.inc
      include \masm32\include\masm32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\oleaut32.inc

;     libraries
;     ~~~~~~~~~
      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib

; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        WinMain          PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc          PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY            PROTO :DWORD,:DWORD
        Paint_Proc       PROTO :DWORD
        RegisterWinClass PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        MsgLoop          PROTO
        Main             PROTO

      ;=============
      ; Local macros
      ;=============

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

      stralloc MACRO ln
        invoke SysAllocStringByteLen,0,ln
      ENDM

      strfree MACRO strhandle
        invoke SysFreeString,strhandle
      ENDM

      QUAD MACRO name,value
        .data
          name QWORD value
        .code
      ENDM

    ; Switch/Case emulation
    ; ---------------------
    $casflg equ <>
    $casvar equ <>
    $casstk equ <>
    
    switch macro _var:req, _reg:=<eax>
        mov _reg, _var
        $casstk catstr <_reg>, <#>, $casflg, <#>, $casstk
        $casvar equ _reg
        $casflg equ <0>         ;; 0 = emit an .if, 1 an .elseif
    endm
    
    case macro _args:vararg     ;; like Pascal: case id1. id4 .. id8, lparam, ...
                                ;; does an or (case1 || case2 || case3...)
      $cas textequ <>
      irp $v, <_args>         ;; for each case
          t@ instr <$v>, <..> ;; range ?
          if t@               ;; yes
              $LB substr <$v>, 1, t@-1                  ;; lbound = left portion
              $LB catstr <(>, $casvar, <!>=>, $LB, <)>  ;; ($casvar >= lbound)
              $UB substr <$v>, t@+2                     ;; ubound = right portion
              $UB catstr <(>, $casvar, <!<=>, $UB, <)>  ;; ($casvar <= ubound)
              $t catstr <(>, $LB, <&&> , $UB,<)>        ;; (($casvar >= $lb) && ($casvar <= $ub))
          else    ;; no, it's a value (var/const)
              $t catstr <(>, $casvar, <==>, <$v>, <)>   ;; ($casvar == value)
          endif
          $cas catstr <|| >, $t, $cas                   ;; or this case w/ others
      endm
      $cas substr $cas, 3 ;; lose the extra "|| " in front
        ifidn $casflg, <0> ;; 0 = 1'st case
            % .if $cas ;; emit ".if"
        else ;; all others
            % .elseif $cas ;; emit ".elseif"
        endif
        $casflg equ <1> ;; NOT 1'st
    endm
    
    default macro _default:vararg
        .else
        _default
    endm
    
    endsw macro _cmd:vararg
        ifidn $casstk, <>
            .err <Endsw w/o Switch>
        else
            t@ instr $casstk, <#>
            $casvar substr $casstk, 1, t@-1
            $casstk substr $casstk, t@+1
            t@ instr $casstk, <#>
            $casflg substr $casstk, 1, t@-1
            ifidn $casstk, <#>
                $casstk equ <>
            else
                $casstk substr $casstk, t@+1
            endif
            .endif
        endif
    endm

  ; ------------------------------------------
  ; equates for case variation in macro names
  ; ------------------------------------------
    Case equ <case>
    CASE equ <case>
    Switch equ <switch>
    SWITCH equ <switch>
    Endsw equ <endsw>
    EndSw equ <endsw>
    ENDSW equ <endsw>
    Default equ <default>
    DEFAULT equ <default>


; --------------------------------------------------
; Macro for placing an assembler instruction either
; within another or within a procedure call
; --------------------------------------------------

    ASM MACRO parameter1,source
      LOCAL mnemonic
      LOCAL dest
      LOCAL poz

      % poz INSTR 1,<parameter1>,< >             ;; get the space position
      mnemonic SUBSTR <parameter1>, 1, poz-1     ;; get the mnemonic
      dest SUBSTR <parameter1>, poz+1            ;; get the first argument

      mnemonic dest, source

      EXITM <dest>
    ENDM

; ------------------------------------------------------------
; Macro for nesting function calls in other invoke statements
; ------------------------------------------------------------

      FUNC MACRO parameters:VARARG
        invoke parameters
        EXITM <eax>
      ENDM

;  -----------------------------------------------------
;   Macros for declaring named floating point variables
;  -----------------------------------------------------

      FLOAT4 MACRO name,value
        .data
          name REAL4 value
        .code
      ENDM

      FLOAT8 MACRO name,value
        .data
          name REAL8 value
        .code
      ENDM

      FLOAT10 MACRO name,value
        .data
          name REAL10 value
        .code
      ENDM

;  -----------------------------------------------------
;   Macros for directly inserting floating point values
;   into floating point instructions and as parameters
;  -----------------------------------------------------

      FP4 MACRO value
        LOCAL vname
        .data
          vname REAL4 value
        .code
        EXITM <vname>
      ENDM

      FP8 MACRO value
        LOCAL vname
        .data
          vname REAL8 value
        .code
        EXITM <vname>
      ENDM

      FP10 MACRO value
        LOCAL vname
        .data
          vname REAL10 value
        .code
        EXITM <vname>
      ENDM

    ; -------------------------
    ; initialised GLOBAL value
    ; -------------------------
      IGLOBAL MACRO variable:VARARG
      .data
        variable
      .code
      ENDM

    ; --------------------------------
    ; initialised GLOBAL string value
    ; --------------------------------
      STRING MACRO variable:REQ,args:VARARG
      .data
        variable db args,0
      .code
      ENDM

    ; ---------------------
    ; literal string MACRO
    ; ---------------------
      literal MACRO quoted_text:VARARG
        LOCAL local_text
        .data
          local_text db quoted_text,0
        .code
        EXITM <local_text>
      ENDM
    ; --------------------------------
    ; string address in INVOKE format
    ; --------------------------------
      SADD MACRO quoted_text:VARARG
        EXITM <ADDR literal(quoted_text)>
      ENDM
    ; --------------------------------
    ; string OFFSET for manual coding
    ; --------------------------------
      CTXT MACRO quoted_text:VARARG
        EXITM <offset literal(quoted_text)>
      ENDM

      ShellAboutBox MACRO handle,IconHandle,quoted_Text_1,quoted_Text_2:VARARG
        LOCAL AboutTitle,AboutMsg,buffer
          .data
            AboutTitle db quoted_Text_1,0
            AboutMsg   db quoted_Text_2,0
            buffer db 128 dup (0)
          .code
        mov esi, offset AboutTitle
        mov edi, offset buffer
        mov ecx, lengthof AboutTitle
        rep movsb
        invoke ShellAbout,handle,ADDR buffer,ADDR AboutMsg,IconHandle
      ENDM

      AppModel MACRO Processor
        Processor             ;; Processor type
        .model flat, stdcall  ;; 32 bit memory model
        option casemap :none  ;; case sensitive
      ENDM

      DisplayMenu MACRO handl, IDnum
        invoke LoadMenu,hInstance,IDnum
        invoke SetMenu,handl,eax
      ENDM

      DisplayWindow MACRO handl, ShowStyle
        invoke ShowWindow,handl, ShowStyle
        invoke UpdateWindow,handl
      ENDM

      AutoScale MACRO swidth, sheight
        invoke GetPercent,sWid,swidth
        mov Wwd, eax
        invoke GetPercent,sHgt,sheight
        mov Wht, eax

        invoke TopXY,Wwd,sWid
        mov Wtx, eax

        invoke TopXY,Wht,sHgt
        mov Wty, eax
      ENDM

      SingleInstanceOnly MACRO lpClassName
        invoke FindWindow,lpClassName,NULL
        cmp eax, 0
        je @F
          push eax
          invoke ShowWindow,eax,SW_RESTORE
          pop eax
          invoke SetForegroundWindow,eax
          mov eax, 0
          ret
        @@:
      ENDM

      GLOBAL MACRO var1,var2,var3,var4,var5,var6,var7,var8,var9,var0,
                   varA,varB,varC,varD,varE,varF,varG,varH,varI,varJ
        .data?
          var1
          var2
          var3
          var4
          var5
          var6
          var7
          var8
          var9
          var0
          varA
          varB
          varC
          varD
          varE
          varF
          varG
          varH
          varI
          varJ
        .code
      ENDM

    ; --------------------------------------------
    ; equates to use directly in the message loop
    ; --------------------------------------------
        m_hWnd   equ <msg.hwnd>
        m_Msg    equ <msg.message>
        m_wParam equ <msg.wParam>
        m_lParam equ <msg.lParam>

    .data
        szDisplayName db "Test switch MACRO",0

    .data?
        hInstance dd ?
        CommandLine dd ?
        hIcon dd ?
        hCursor dd ?
        sWid dd ?
        sHgt dd ?
        hWnd dd ?


; ########################### Inserted modules ############################

      include tbmacros.asm
      include toolbar.asm
      include Statusbr.asm
      include Filedlgs.asm

; #########################################################################

