comment * -------------------------------------------------------------
         This example is written using Pelle's Macro Assembler
         Build this example from the PROJECT menu with MAKEIT.BAT
    ----------------------------------------------------------------- *

      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive
  
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
      include \masm32\include\ole32.inc
      include \masm32\macros\pomacros.asm

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
      includelib \masm32\lib\ole32.lib

      include \masm32\include\dialogs.inc

      DlgProc               PROTO :DWORD,:DWORD,:DWORD,:DWORD
      OpenFileDialogx       PROTO :DWORD,:DWORD,:DWORD,:DWORD
      noext                 PROTO :DWORD
      BrowseForFolder_ex    PROTO :DWORD,:DWORD,:DWORD,:DWORD
      cbBrowse_ex           PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .data?
      hWnd      dd ?
      hInstance dd ?
      hList     dd ?
      hStat1    dd ?
      hEdit1    dd ?
      hEdit2    dd ?
      hButn2    dd ?

      hRslt1    dd ?
      hRslt2    dd ?
      hRslt3    dd ?
      hRslt4    dd ?

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:
  
      mov hInstance, FUNC(GetModuleHandle,NULL)

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    Dialog "Write File to Object Module", \
           "MS Sans Serif",10, \
            WS_OVERLAPPED or \
            WS_SYSMENU or DS_CENTER, \
            15, \
            50,50,229,140, \
            1024

    DlgButton "Select File",WS_TABSTOP,5,5,40,12,IDOK
    DlgButton "Build",WS_TABSTOP,48,5,40,12,150
    DlgButton "Close",WS_TABSTOP,91,5,40,12,IDCANCEL

    DlgStatic "No file selected",SS_LEFT,5,22,100,9,100

    DlgStatic "Data alignment",SS_LEFT,140,8,50,9,101
    DlgCombo CBS_DROPDOWNLIST or CBS_DISABLENOSCROLL or WS_TABSTOP,190,6,30,150,120

    DlgStatic "Output object file name",SS_LEFT,5,37,100,9,102
    DlgEdit ES_LEFT or WS_BORDER or WS_TABSTOP,5,47,100,10,110

    DlgStatic "Data label name",SS_LEFT,120,37,100,9,103
    DlgEdit ES_LEFT or WS_BORDER or WS_TABSTOP,120,47,100,10,111

    DlgGroup " Results ",5,62,215,60,199

    DlgStatic " ",SS_LEFT,15,75,190,9,104
    DlgStatic " ",SS_LEFT,15,85,190,9,105
    DlgStatic " ",SS_LEFT,15,95,190,9,106
    DlgStatic " ",SS_LEFT,15,105,190,9,107

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL patn  :DWORD
    LOCAL fname :DWORD
    LOCAL ppth  :DWORD
    LOCAL pbuf[260]:BYTE

    LOCAL pbuf1 :DWORD
    LOCAL buffer1[260]:BYTE

    .if uMsg == WM_INITDIALOG
        invoke SendMessage,hWin,WM_SETICON,1,
                           FUNC(LoadIcon,NULL,IDI_ASTERISK)

        mov hList, rv(GetDlgItem,hWin,120)
        mov hStat1, rv(GetDlgItem,hWin,100)
        mov hEdit1, rv(GetDlgItem,hWin,110)
        mov hEdit2, rv(GetDlgItem,hWin,111)

        mov hRslt1, rv(GetDlgItem,hWin,104)
        mov hRslt2, rv(GetDlgItem,hWin,105)
        mov hRslt3, rv(GetDlgItem,hWin,106)
        mov hRslt4, rv(GetDlgItem,hWin,107)

        mov hButn2, rv(GetDlgItem,hWin,150)
        invoke EnableWindow,hButn2,FALSE

        fn SendMessage,hList,CB_ADDSTRING,0,"1"
        fn SendMessage,hList,CB_ADDSTRING,0,"2"
        fn SendMessage,hList,CB_ADDSTRING,0,"4"
        fn SendMessage,hList,CB_ADDSTRING,0,"8"
        fn SendMessage,hList,CB_ADDSTRING,0,"16"
        fn SendMessage,hList,CB_ADDSTRING,0,"32"
        fn SendMessage,hList,CB_ADDSTRING,0,"64"
        fn SendMessage,hList,CB_ADDSTRING,0,"128"
        fn SendMessage,hList,CB_ADDSTRING,0,"256"
        fn SendMessage,hList,CB_ADDSTRING,0,"512"
        fn SendMessage,hList,CB_ADDSTRING,0,"1024"
        fn SendMessage,hList,CB_ADDSTRING,0,"2048"
        fn SendMessage,hList,CB_ADDSTRING,0,"4096"
        fn SendMessage,hList,CB_ADDSTRING,0,"8192"

        invoke SendMessage,hList,CB_SETCURSEL,2,0

        m2m hWnd, hWin
        return 1

      .elseif uMsg == WM_COMMAND
        .if wParam == IDOK
            mov patn, chr$("all files",0,"*.*",0,0)
            mov fname, rv(OpenFileDialogx,hWin,hInstance,"Open File ...",patn)
            cmp BYTE PTR [eax], 0
            jne @F
            return 0
          @@:
            invoke SetWindowText,hStat1,fname
            invoke noext,fname
            mov ppth, ptr$(pbuf)
            invoke NameFromPath,fname,ppth
            mov pbuf1, ptr$(buffer1)
            mov pbuf1, cat$(pbuf1,ppth,".obj")
            invoke SetWindowText,hEdit1,pbuf1
            invoke SetWindowText,hEdit2,ppth
            invoke EnableWindow,hButn2,TRUE

          .elseif wParam == 150
            mov pbuf1, ptr$(buffer1)
            fn BrowseForFolder_ex,hWin,pbuf1,"Select Or Create Target Directory", \
                                 "Build object module and include file in this directory"
            test eax, eax
            jnz @F
            return 0
          @@:
            chdir pbuf1
            call write_obj

          .elseif wParam == IDCANCEL
            jmp quit_dialog
        .endif
      .elseif uMsg == WM_CLOSE
        quit_dialog:
        invoke EndDialog,hWin,0
    .endif

    return 0

DlgProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

OpenFileDialogx proc hParent:DWORD,Instance:DWORD,lpTitle:DWORD,lpFilter:DWORD

    LOCAL ofn:OPENFILENAME

    .data?
      openfilebuffer db 260 dup (?)
    .code

    mov eax, OFFSET openfilebuffer
    mov BYTE PTR [eax], 0

  ; --------------------
  ; zero fill structure
  ; --------------------
    push edi
    mov ecx, sizeof OPENFILENAME
    mov al, 0
    lea edi, ofn
    rep stosb
    pop edi

    mov ofn.lStructSize,    sizeof OPENFILENAME
    m2m ofn.hwndOwner,      hParent
    m2m ofn.hInstance,      Instance
    m2m ofn.lpstrFilter,    lpFilter
    m2m ofn.lpstrFile,      offset openfilebuffer
    mov ofn.nMaxFile,       sizeof openfilebuffer
    m2m ofn.lpstrTitle,     lpTitle
    mov ofn.lpstrInitialDir, CurDir$()
    mov ofn.Flags,          OFN_EXPLORER or OFN_FILEMUSTEXIST or \
                            OFN_LONGNAMES or OFN_HIDEREADONLY

    invoke GetOpenFileName,ADDR ofn
    mov eax, OFFSET openfilebuffer
    ret

OpenFileDialogx endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

noext proc src:DWORD

    mov eax, src
    mov ecx, -1
    xor edx, edx

  stlp:
    add ecx, 1
    cmp BYTE PTR [eax+ecx], 0
    je nenxt
    cmp BYTE PTR [eax+ecx], "."
    jne stlp
    mov edx, ecx
    jmp stlp

  nenxt:
    test edx, edx               ; if EDX still zero
    jz neout                    ; jump to exit

    mov BYTE PTR [eax+edx], 0   ; truncate string at last "." location

  neout:
    ret

noext endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

BrowseForFolder_ex proc hParent:DWORD,lpBuffer:DWORD,lpTitle:DWORD,lpString:DWORD

  ; ------------------------------------------------------
  ; hParent  = parent window handle
  ; lpBuffer = 260 byte buffer to receive path
  ; lpTitle  = zero terminated string with dialog title
  ; lpString = zero terminated string for secondary text
  ; ------------------------------------------------------

    LOCAL lpIDList :DWORD
    LOCAL bi  :BROWSEINFO

    mov eax,                hParent         ; parent handle
    mov bi.hwndOwner,       eax
    mov bi.pidlRoot,        0
    mov bi.pszDisplayName,  0
    mov eax,                lpString        ; secondary text
    mov bi.lpszTitle,       eax
    mov bi.ulFlags,         BIF_RETURNONLYFSDIRS or BIF_DONTGOBELOWDOMAIN or \
                            BIF_NEWDIALOGSTYLE or BIF_EDITBOX
    mov bi.lpfn,            offset cbBrowse_ex
    mov eax,                lpTitle         ; main title
    mov bi.lParam,          eax
    mov bi.iImage,          0

    invoke SHBrowseForFolder,ADDR bi
    mov lpIDList, eax

    .if lpIDList == 0
      mov eax, 0            ; if CANCEL return FALSE
      push eax
      jmp @F
    .else
      invoke SHGetPathFromIDList,lpIDList,lpBuffer
      mov eax, 1            ; if OK, return TRUE
      push eax
      jmp @F
    .endif

    @@:
    invoke CoTaskMemFree,lpIDList

    pop eax
    ret

BrowseForFolder_ex endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

cbBrowse_ex proc hWin:DWORD,uMsg:DWORD,lParam:DWORD,lpData:DWORD

    .if uMsg == BFFM_INITIALIZED
      invoke SendMessage,hWin,BFFM_SETSELECTION,1,CurDir$()
      invoke SetWindowText,hWin,lpData
    .endif

    ret

cbBrowse_ex endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

write_obj proc

    LOCAL pinput        :DWORD              ; 1st argument pointer
    LOCAL poutput       :DWORD              ; 2nd argument pointer
    LOCAL pname         :DWORD              ; 3rd argument pointer
    LOCAL pspare        :DWORD              ; spare buffer pointer
    LOCAL pdata         :DWORD              ; pointer to file data
    LOCAL flen          :DWORD              ; variable for file length
    LOCAL hout          :DWORD              ; output file handle
    LOCAL wcnt          :DWORD
    LOCAL hinc          :DWORD              ; file handle for output include file
    LOCAL pftr          :DWORD
    LOCAL paln          :DWORD
    LOCAL aflag         :DWORD              ; alignment flag
    LOCAL alind         :DWORD              ; variable to hold alignment choice
    LOCAL buffer1[260]  :BYTE               ; source file name buffer
    LOCAL buffer2[260]  :BYTE               ; target file name buffer
    LOCAL buffer3[260]  :BYTE               ; external data item name buffer
    LOCAL buffer4[260]  :BYTE               ; spare buffer
    LOCAL alnbuff[32]   :BYTE               ; buffer for alignment size
    LOCAL ifh           :IMAGE_FILE_HEADER
    LOCAL ish           :IMAGE_SECTION_HEADER
    LOCAL ist           :IMAGE_SYMBOL

    mov pinput,  ptr$(buffer1)              ; cast buffers to pointers
    mov poutput, ptr$(buffer2)
    mov pname,   ptr$(buffer3)
    mov pspare,  ptr$(buffer4)
    mov paln,    ptr$(alnbuff)

  ; ********************
  ; load alignment value
  ; ********************

    invoke SendMessage,hList,CB_GETCURSEL,0,0
    mov edx, eax
    invoke SendMessage,hList,CB_GETLBTEXT,edx,paln  ; get alignment fom combo box

    invoke GetWindowText,hStat1,pinput,260          ; get the input file name
    invoke GetWindowText,hEdit1,poutput,260         ; get the output file name
    invoke GetWindowText,hEdit2,pname,260           ; get the label name

    mov pname, cat$(pspare,"_",pname)               ; prepend leading underscore for
                                                    ; object module internal name
    push paln
    call image_align                        ; call procedure to set alignment flag
    mov aflag, eax

    invoke atodw,paln                       ; convert to integer for later display
    mov alind, eax

    mov pdata, InputFile(pinput)
    mov flen, ecx
    mov hout, fcreate(poutput)

  ; ----------------------------------------------
  ; calculate the start offset of the symbol table
  ; ----------------------------------------------
    mov edx, SIZEOF IMAGE_FILE_HEADER
    add edx, SIZEOF IMAGE_SECTION_HEADER
    add edx, flen

  ; -----------------
  ; IMAGE_FILE_HEADER
  ; -----------------
    mov ifh.Machine,                IMAGE_FILE_MACHINE_I386         ; dw
    mov ifh.NumberOfSections,       1                               ; dw
    mov ifh.TimeDateStamp,          0                               ; dd
    mov ifh.PointerToSymbolTable,   edx                             ; dd
    mov ifh.NumberOfSymbols,        1                               ; dd
    mov ifh.SizeOfOptionalHeader,   0                               ; dw
    mov ifh.Characteristics,        IMAGE_FILE_RELOCS_STRIPPED or \
                                    IMAGE_FILE_LINE_NUMS_STRIPPED   ; dw
  ; --------------------
  ; IMAGE_SECTION_HEADER
  ; --------------------
    lea eax, ish.Name1
    mov DWORD PTR [eax], "tad."     ; write ".data" to Name1 member
    mov DWORD PTR [eax+4], "a"

    mov ish.Misc.PhysicalAddress,   0           ; dd
    mov ish.VirtualAddress,         0           ; dd
    m2m ish.SizeOfRawData,          flen        ; dd

    mov edx, SIZEOF IMAGE_FILE_HEADER
    add edx, SIZEOF IMAGE_SECTION_HEADER
    mov ish.PointerToRawData,       edx         ; dd

    mov ish.PointerToRelocations,   0           ; dd
    mov ish.PointerToLinenumbers,   0           ; dd
    mov ish.NumberOfRelocations,    0           ; dw
    mov ish.NumberOfLinenumbers,    0           ; dw

    mov eax, IMAGE_SCN_CNT_INITIALIZED_DATA or IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE
    or eax, aflag
    mov ish.Characteristics, eax                ; dd

  ; -----------------
  ; COFF SYMBOL TABLE
  ; -----------------
    lea eax, ist.N.LongName
    mov DWORD PTR [eax], 0                      ; zero fill 1st 4 bytes
    mov DWORD PTR [eax+4], 4                    ; OFFSET is 4th byte into the string table

    mov ist.Value, 0
    mov ist.SectionNumber, 1
    mov ist.Type1, 0
    mov ist.StorageClass, IMAGE_SYM_CLASS_EXTERNAL
    mov ist.NumberOfAuxSymbols, 0

  ; --------------------
  ; write result to file
  ; --------------------
    mov wcnt, fwrite(hout,ADDR ifh,SIZEOF IMAGE_FILE_HEADER)
    mov wcnt, fwrite(hout,ADDR ish,SIZEOF IMAGE_SECTION_HEADER)
    mov wcnt, fwrite(hout,pdata,flen)           ; write the file data
    mov wcnt, fwrite(hout,ADDR ist,SIZEOF IMAGE_SYMBOL)

  ; ------------
  ; string table
  ; ------------
    mov wcnt, 64
    mov wcnt, fwrite(hout,ADDR wcnt,4)          ; write the table length to 1st DWORD

    mov edx, len(pname)
    mov wcnt, fwrite(hout,pname,edx)            ; write the data label name after it.

    mov edx, len(pname)                         ; length of name
    add edx, 4                                  ; add 4 for 1st DWORD
    mov wcnt, 65
    sub wcnt, edx

    .data
      filler db 128 dup (0)
    .code

    mov wcnt, fwrite(hout,ADDR filler,wcnt)

    fclose hout
    free pdata
    free pftr

  ; ---------------------------------
  ; write the EXTERNDEF statement and
  ; length equate to the include file
  ; ---------------------------------
    mov pspare, ptr$(buffer1)                   ; reuse buffer
    mov pspare, cat$(pspare,"Module file '",poutput,"' written to disk")
    invoke SetWindowText,hRslt4,pspare

    mov poutput, lcase$(poutput)                ; ensure lower case
    mov poutput, remove$(poutput,".obj")        ; strip extension
    mov poutput, cat$(poutput,".inc")           ; add new extension

    mov pinput, ptr$(buffer1)                   ; reuse buffer
    mov pinput, cat$(pinput,"Include file '",poutput,"' written to disk")
    invoke SetWindowText,hRslt3,pinput

    mov hinc, fcreate(poutput)

    fprint hinc,"; -----------------------------------------------------"
    fprint hinc,"; Include the contents of this file in your source file"
    fprint hinc,"; to access the data as an OFFSET and use the equate as"
    fprint hinc,"; the byte count for the file data in the object module"
    fprint hinc,"; -----------------------------------------------------"

    mov edx, len(pname)
    sub edx, 1
    mov pname, right$(pname,edx)

    mov poutput, ptr$(buffer2)
    mov poutput, cat$(poutput,"EXTERNDEF ",pname,":DWORD")
    fprint hinc,poutput

    mov poutput, ptr$(buffer2)

    mov edx, str$(flen)
    mov ecx, chr$(60)
    mov eax, chr$(62)
    mov poutput, cat$(poutput,"ln_",pname," equ ",ecx,edx,eax)
    fprint hinc, poutput

    fclose hinc

    mov pinput, ptr$(buffer1)                   ; reuse buffer
    mov edx, str$(flen)
    mov pinput, cat$(pinput,"Raw data size : ",edx," bytes")
    invoke SetWindowText,hRslt1,pinput

    mov pinput, ptr$(buffer1)                   ; reuse buffer
    mov edx, str$(alind)
    mov pinput, cat$(pinput,"Module written with ",edx," byte alignment")
    invoke SetWindowText,hRslt2,pinput

  ; -----------------------------------------

    ret

write_obj endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

image_align:  

    mov eax, [esp+4]

    cmp BYTE PTR [eax+0], "1"
    jne lbl0
    cmp BYTE PTR [eax+1], 0
    jne lbl1
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_1BYTES ; 1
    ret 4
    ; -------------------
  lbl1:
    cmp BYTE PTR [eax+1], "0"
    jne lbl2
    cmp BYTE PTR [eax+2], "2"
    jne notfound
    cmp BYTE PTR [eax+3], "4"
    jne notfound
    cmp BYTE PTR [eax+4], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_1024BYTES ; 1024
    ret 4
    ; -------------------
  lbl2:
    cmp BYTE PTR [eax+1], "2"
    jne lbl3
    cmp BYTE PTR [eax+2], "8"
    jne notfound
    cmp BYTE PTR [eax+3], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_128BYTES ; 128
    ret 4
    ; -------------------
  lbl3:
    cmp BYTE PTR [eax+1], "6"
    jne notfound
    cmp BYTE PTR [eax+2], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_16BYTES ; 16
    ret 4
    ; -------------------
  lbl0:
    cmp BYTE PTR [eax+0], "2"
    jne lbl4
    cmp BYTE PTR [eax+1], 0
    jne lbl5
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_2BYTES ; 2
    ret 4
    ; -------------------
  lbl5:
    cmp BYTE PTR [eax+1], "0"
    jne lbl6
    cmp BYTE PTR [eax+2], "4"
    jne notfound
    cmp BYTE PTR [eax+3], "8"
    jne notfound
    cmp BYTE PTR [eax+4], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_2048BYTES ; 2048
    ret 4
    ; -------------------
  lbl6:
    cmp BYTE PTR [eax+1], "5"
    jne notfound
    cmp BYTE PTR [eax+2], "6"
    jne notfound
    cmp BYTE PTR [eax+3], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_256BYTES ; 256
    ret 4
    ; -------------------
  lbl4:
    cmp BYTE PTR [eax+0], "3"
    jne lbl7
    cmp BYTE PTR [eax+1], "2"
    jne notfound
    cmp BYTE PTR [eax+2], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_32BYTES ; 32
    ret 4
    ; -------------------
  lbl7:
    cmp BYTE PTR [eax+0], "4"
    jne lbl8
    cmp BYTE PTR [eax+1], 0
    jne lbl9
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_4BYTES ; 4
    ret 4
    ; -------------------
  lbl9:
    cmp BYTE PTR [eax+1], "0"
    jne notfound
    cmp BYTE PTR [eax+2], "9"
    jne notfound
    cmp BYTE PTR [eax+3], "6"
    jne notfound
    cmp BYTE PTR [eax+4], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_4096BYTES ; 4096
    ret 4
    ; -------------------
  lbl8:
    cmp BYTE PTR [eax+0], "5"
    jne lbl10
    cmp BYTE PTR [eax+1], "1"
    jne notfound
    cmp BYTE PTR [eax+2], "2"
    jne notfound
    cmp BYTE PTR [eax+3], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_512BYTES ; 512
    ret 4
    ; -------------------
  lbl10:
    cmp BYTE PTR [eax+0], "6"
    jne lbl11
    cmp BYTE PTR [eax+1], "4"
    jne notfound
    cmp BYTE PTR [eax+2], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_64BYTES ; 64
    ret 4
    ; -------------------
  lbl11:
    cmp BYTE PTR [eax+0], "8"
    jne notfound
    cmp BYTE PTR [eax+1], 0
    jne lbl12
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_8BYTES ; 8
    ret 4
    ; -------------------
  lbl12:
    cmp BYTE PTR [eax+1], "1"
    jne notfound
    cmp BYTE PTR [eax+2], "9"
    jne notfound
    cmp BYTE PTR [eax+3], "2"
    jne notfound
    cmp BYTE PTR [eax+4], 0
    jne notfound
    ; -------------------
    mov eax, IMAGE_SCN_ALIGN_8192BYTES ; 8192
    ret 4
    ; -------------------

  notfound:
    xor eax, eax
    ret 4

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start























