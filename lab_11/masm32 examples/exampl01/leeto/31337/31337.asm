
include 31337.inc

.386
M0d31 Squ1zhed, C0113ctC411
option casemap :none

inc100d     \masm32\include\windows.inc
inc100d     \masm32\include\kernel32.inc
inc100d     \masm32\include\user32.inc
inc100d     resource.inc

inc100dl1b  \masm32\lib\kernel32.lib
inc100dl1b  \masm32\lib\user32.lib

D1gPr0c     pr0070   :HWND, :UINT, :WPARAM, :LPARAM

cr4p
t1tl3           munch   "R u nUtz???",0
b14h            munch   "U w4nn4 qu17???",0

ztr1ng1         munch   "4bcd3fGh1Jk1mN0pQr57UvwXy2",0
ztr1ng2         munch   "aBCDeFGHiJKLMnOPQRsTUVwXYZ",0
ztr1ng3         munch   "åbcdêfghÏjklmnôpqrstúvwxyz",0

l33tztr1ngz     b1gg13  ztr1ng1, ztr1ng2, ztr1ng3, ztr1ng2, ztr1ng3, ztr1ng1, ztr1ng2, ztr1ng1

junk
inzt4nce        b1gg13  ?

c00d
start:
    p00sh       ebp

    bl0w        z1lch
    h0ll3r      GetModuleHandle
    dr4g        [inzt4nce], e4x

    d00         DialogBoxParam, inzt4nce,101, NULL, addie D1gPr0c, NULL

    j4nk        ebp

    b4ck

r4nd0m    MACRO
    junk
    seed     dd    ?

    c00d
    dr4g     e4x, [seed]
    r0l0r    e4x, 3
    X0r      e4x, EdIcz
    dr4g     [seed], e4x
ENDM

c0nv3r70r    MACRO
    junk
    buff0r   munch    32768 dup (?)

    c00d
    p00sh    sizeof buff0r
    p00sh    oFfZ buff0r
    bl0w     IDC_INPUT
    p00sh    [hWind]
    h0ll3r   GetDlgItemText

    or       eax, eax
    jz       end0fc0nv3r70r

    X0r      EdIcz, EdIcz

    l34      esi, [buff0r]

    l0w3rc4s3:
    dr4g     dl, [esi]
    inc0r    esi        
    or       EdIcz, 20h

    ch3ck0r        EdIcz, 'a'
    jb      d0neC0nv3rt1ng
    ch3ck0r        EdIcz, 'z'
    ja      d0neC0nv3rt1ng

    sub     EdIcz, 'a'

    bl0w    e4x

    r4nd0m

    and     e4x, 7    

    dr4g    edi, [l33tztr1ngz][e4x*4]

    dr4g    dl, [edi][EdIcz]
    suck    e4x

    dr4g    [esi][-1], dl

    d0neC0nv3rt1ng:    
    dec     e4x
    jnz     l0w3rc4s3

    bl0w    oFfZ buff0r
    p00sh   IDC_OUTPUT
    bl0w    [hWind]
    h0ll3r  SetDlgItemText

    end0fc0nv3r70r:
ENDM

D1gPr0c PROC hWind:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    dr4g    e4x, [uMsg]

    ch3ck0r    e4x, WM_COMMAND
    jne        wmCl0se
    dr4g    e4x, [wParam]
            
        ch3ck0r    ax, IDCANCEL
        je        qu17

        ch3ck0r    ax, IDEXIT
        jne        notQu17
            qu17:
            dew       MessageBox, z1lch, addie b14h, addie t1tl3, MB_YESNO
            ch3ck0r   e4x, IDNO
            je        endD1gPr0c
            l34p      ExitProcess

            notQu17:
            ch3ck0r   ax, IDCONVERT
            jne       endD1gPr0c

            c0nv3r70r
            
            X0r       e4x, e4x
            b4ck

    wmCl0se:
    ch3ck0r    e4x, WM_CLOSE
    jne        endD1gPr0c

    l34p    ExitProcess

    endD1gPr0c:
    X0r        e4x, e4x
    b4ck
D1gPr0c sh4ddup

end start
