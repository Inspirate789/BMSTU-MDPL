.386
.model flat,stdcall
option casemap:none
;-----------------------------------------------------
;About      Joe's Alarm/Countdown Timer/StopWatch!
;Author:    farrier jcurran@network-one.com
;Dialog window with the following functions
;   Stopwatch with "1/100 sec accuracy" at least that is what is displayed!
;       immediate lap times can be displayed briefly without stopping SW
;   Countdown Timer (CDT) with drop down box controls for hour, minute, & seconds
;       Upper limit 59 Hours, 59 minutes, & 59 seconds
;       If Repeat After Countdown checkbox is checked CDT will repeat
;   Alarm Clock (AC) using DateTimePicker control to set alarm time and date
;For CDT & AC when time expires, an "alarm" sound is played using
;   multimedia playback "PlaySound" API.  A file picker control is used to
;   allow the user to change the sound played.
;The most recently selected options are saved in a file \Windows\jacts.ini
;   When the program runs the next time, that file is used to set the options
;   for the current session.
;-----------------------------------------------------
;-----------------------------------------------------
;INCLUDES
;______________________________________
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc         ;For GetModuleFileName
include \masm32\include\comctl32.inc        ;For DateTimePicker
include \masm32\include\comdlg32.inc        ;For GetOpenFileName
include \masm32\include\winmm.inc           ;For MultiMedia Playback
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\winmm.lib

;-------------------------------------
;PROTOTYPES
;_____________________________________________
DlgProc        PROTO :HWND,  :DWORD, :DWORD, :DWORD
dwtoa          PROTO :DWORD, :PTR BYTE     ;Converts Double to ASCII
populate_lists PROTO                       ;Populates Hour & Minute Lists
set_ini        PROTO :WORD , :HWND         ;Interacts with JCT.ini file
start_timer    PROTO :HWND
s_length       PROTO :PTR BYTE             ;String length returned
update_display PROTO :HWND                 ;Updates dialog box display

;---------------------------------------------
;CONSTANTS
;_____________________________________________
.CONST
timer_num   equ 10                   ;identifier for timer as used by SetTimer
IDC_CDTB    equ 106                  ;identifier for CountDownTimerButton
IDC_AB      equ 108                  ;identifier for AlarmButton
IDC_SW      equ 109                  ;identifier for StopWatch button
IDC_RAB     equ 111                  ;identifier for RepeatAfter countdown button
IDC_SC      equ 116                  ;identifier for Countdown Seconds
IDC_HC      equ 117                  ;identifier for Countdown Hours
IDC_MC      equ 118                  ;identifier for Countdown Minutes
IDC_PICK    equ 119                  ;identifier for PICK sound button
IDC_START   equ 121                  ;identifier for START button
IDC_CANCEL  equ 122                  ;identifier for CANCEL button
IDC_STOP    equ 123                  ;identifier for STOP button
IDC_LAP     equ 124                  ;identifier for LAP button
IDI_CLOCK   equ 132
IDC_START_DATE  equ 3004             ;identifier for alram time/date button

;----------------------------------------------------------------------------------
;INITIALIZED DATA
;__________________________________________________________________________________
.DATA
AppName     db  "Joe's Alarm/Countdown Timer/StopWatch!", 0
DlgName     db  "MyDialog", 0
IDStr       db  "Joe's Alarm/Countdown Timer/StopWatch (c) 2000-2001 MASM32", 13, 10
hStr        db  "Hours:01", 13, 10              ;initial hours string
mStr        db  "Minutes:30", 13, 10            ;initial minutes string
sStr        db  "Seconds:00", 13, 10            ;initial seconds string
ACorR       db  "ACorR:A", 13, 10               ;initial Alarm,Countdown,Repeat,stopwatch choice
wStr        db  "Wav:"
initial_wav_name    db  "\MEDIA\THE MICROSOFT SOUND.WAV", 0 ;initial sound file
w_buffer    db  MAX_PATH - sizeof initial_wav_name dup(0)   ;place holder to reserve space for a MAX_PATH sized event/file name
lib_name    db  "\comctl32.dll", 0                          ;library for DateTimePicker
dgv         db  "DllGetVersion", 0                              ;function to check version of DLL
lib_err     db  "This Program Requires Version 4.70 of COMCTL32.DLL!", 0    ;warning message
ini_nom     db  "No match with the existing "                   ;warning if existing JCTA.ini is not ours?
JACTS_Name  db  "\JACTS.INI", 0                                 ;name of our .ini file
DateFormat  db  "hh':'mm' 'tt' 'ddd' 'dd' 'MMMM' 'yyyy", 0      ;Format for Time/Date in DateTimePicker
date_error  db  "Starting Date/Time Cannot be The Same as or Prior to Current Date/Time!", 0
                                                                ;Warning that Alarm time cannot be at or before current time
time_up     db  "The Timer has expired!", 0                     ;MessageBox prompt when timer has expired
nocdt       db  "There is No time on Countdown Timer!", 0       ;MessageBox prompt when Hours & Minutes are both zero for Countdown Timer
OurTitle    db  "Pick a WAV File for Your Alarm Sound!", 0      ;Title for file dialog for Pick Sound
FilterString    db  "WAV Files", 0, "*.wav", 0                  ;Template for file dialog
                db  "All Files", 0, "*.*", 0, 0                 ;"   "
hour_str    db  " :Hours"                           ;Strings for time display
minute_str  db  " :Minutes"                         ;"    "
second_str  db  " :Seconds"                         ;"    "
msec_str    db  " :mSecs"                           ;"    "
end_string  db  0                       ;zero to terminate display string
p_cnt       db  0                       ;used for timer to delay lap time display

;-------------------------------------------------------------------------------------------
;UNINITIALIZED DATA
;___________________________________________________________________________________________
.DATA?
hInstance       HINSTANCE ?
lib_handle      HWND    ?           ;Handle to check for dll version
ab_handle       HWND    ?           ;Handle for alarm button window
cdtb_handle     HWND    ?           ;Handle for count down timer button window
sw_handle       HWND    ?           ;Handle for stopwatch button window
hc_handle       HWND    ?           ;Handle for Hour combo box window
mc_handle       HWND    ?           ;Handle for Minute combo box window
sc_handle       HWND    ?           ;Handle for Second combo box window
rab_handle      HWND    ?           ;Handle for repeat after countdown timer checkbox window
sdc_handle      HWND    ?           ;Hanlde for startdate control window
start_handle    HWND    ?           ;Handle for Start button
cancel_handle   HWND    ?           ;Handle for Cancel button
stop_handle     HWND    ?           ;Handle for Stop button
lap_handle      HWND    ?           ;Handle for Lap button
stat_handle     HWND    ?           ;Handle for Status bar
timer_handle    HWND    ?           ;Handle used to reference the timer
dvi         DLLVERSIONINFO  <>      ;Structure for Dll Version Info
ofn         OPENFILENAME    <>      ;Structure for selecting WAV file
system_time SYSTEMTIME  <>          ;used to gather current time
alarm_time  FILETIME    <>          ;used to keep next alarm time
time_now    FILETIME    <>          ;used to gather current time
tseconds    FILETIME    <>          ;used to store seconds left till alarm
icex        INITCOMMONCONTROLSEX <> ;structure for DateTimePicker
proc_add    DWORD   ?               ;used to store address for DLL
def_hours   DWORD   ?               ;used to set initial value of CD Hours
def_mins    DWORD   ?               ;used to set initial value of CD Minutes
def_secs    DWORD   ?               ;used to set initial value of CD Seconds
repeat_mins DWORD   ?               ;store countdown minutes for repeat
repeat_secs DWORD   ?               ;store countdown minutes for repeat
hc_str      WORD    ?               ;2 bytes for the hour control
mc_str      WORD    ?               ;2 bytes for the minute control
sc_str      WORD    ?               ;2 bytes for the second control
newcw       WORD    ?               ;storage for the updated fpu control word
oldcw       WORD    ?               ;storage for the old FPU control word
def_acorr   BYTE    ?               ;Is the Alarm,Countdown,or Repeat After button pushed
mb_up       BYTE    ?               ;Is MessageBox already up, don't repeat MessageBox is RepeatAfterCountdown
d_buffer    BYTE    MAX_PATH + 1 dup (?)     ;allows us to read MAX filename size and 0
WindowsDir  db MAX_PATH dup(?)
wav_name    db MAX_PATH dup(?)
iniFileName db MAX_PATH dup(?)
;-----------------------------------------------------
;CODE
;_____________________________________________________
.CODE
start:
    invoke  GetModuleHandle, NULL
    mov     hInstance, eax
    ;===========================================
    ; obtain the windows directory
    ;===========================================
    invoke  GetWindowsDirectory, addr WindowsDir, sizeof WindowsDir
    invoke  lstrcpy, addr wav_name, addr WindowsDir
    invoke  lstrcat, addr wav_name, addr initial_wav_name
    invoke  lstrcpy, addr iniFileName, addr WindowsDir
    invoke  lstrcat, addr iniFileName, addr JACTS_Name
    invoke  GetSystemDirectory, addr d_buffer, sizeof d_buffer
    invoke  lstrcat, addr d_buffer, addr lib_name
    invoke  LoadLibrary, addr d_buffer
                ;Load comctl32.dll to see if we have at least version 4.70
    mov lib_handle, eax                 ;save handle
    .if (eax == NULL)                   ;no valid handle returned
        invoke  MessageBox, NULL, addr lib_err, NULL, MB_OK
        invoke  ExitProcess, -1
        ret
    .endif
    invoke  GetProcAddress, lib_handle, addr dgv
                        ;get address of DllGetVersion within comctl32.dll
    mov proc_add, eax
    .if (eax == NULL)                   ;no valid address to Proc returned
        invoke  MessageBox, NULL, addr lib_err, NULL, MB_OK
        invoke  FreeLibrary, lib_handle
        invoke  ExitProcess, -1
        ret
    .endif
    invoke  RtlZeroMemory, addr dvi, sizeof DLLVERSIONINFO
        ;set DLLVERSIONINFO Stru to zeroes
    mov dvi.cbSize, sizeof DLLVERSIONINFO
    push    OFFSET dvi              ;push structure address for DLLGetVersion
    call    proc_add                ;call COMCTL32.DLL's DllGetVersion routine
    cmp dvi.dwMajorVersion, 4       ;major version should be at least 4
    jae @F
        invoke  MessageBox, NULL, addr lib_err, NULL, MB_OK
        invoke  FreeLibrary, lib_handle
        invoke  ExitProcess, -1
        ret
@@: cmp dvi.dwMinorVersion, 70      ;minor version should be at least 70
    jae @F
        invoke  MessageBox, NULL, addr lib_err, NULL, MB_OK
        invoke  FreeLibrary, lib_handle
        invoke  ExitProcess, -1
        ret
@@:
    mov icex.dwSize, sizeof  INITCOMMONCONTROLSEX    ;prepare common control structure
    mov icex.dwICC, ICC_DATE_CLASSES
    invoke  InitCommonControlsEx, addr icex
        ;initialize common controls for DateTimePicker
    finit               ;initialize FPU
    fstcw   oldcw       ;get current FPU control register & save for later
    fwait
    mov ax, oldcw       ;move it to ax
    and ax, 0f3ffh      ;make sure the 2 rounding bits are zero
    or  ax, 0400h       ;set the rounding down bit
    mov newcw, ax       ;save this new setting set in next command
    fldcw   newcw       ;set FPU control register to round down
    invoke  DialogBoxParam, hInstance, addr DlgName, NULL, addr DlgProc, NULL
        ;start the program
    fldcw   oldcw       ;restore old control register
    invoke  FreeLibrary, lib_handle
    invoke  ExitProcess, 1

;-----------------------------------------------------
DlgProc PROC hWnd:HWND,iMsg:DWORD,wParam:WPARAM, lParam:LPARAM
;______________________________________________________________
LOCAL   is_zero:BYTE
LOCAL   icon_r:WORD
    .if (iMsg == WM_INITDIALOG)         ;initialize dialog elements
        invoke  GetModuleFileName, NULL, addr WindowsDir, icon_r
        invoke  ExtractIcon, hWnd, addr WindowsDir, 0
        push    eax
        invoke  SendMessage, hWnd, WM_SETICON, ICON_SMALL, eax
        pop eax
        invoke  SendMessage, hWnd, WM_SETICON, ICON_BIG, eax
        mov mb_up, 0                    ;to keep track whether a MessageBox is currently 'up'
        invoke  CreateStatusWindow, WS_CHILD or WS_VISIBLE, NULL, hWnd, NULL
                                        ;create status window at bottom of dialog box
        mov stat_handle, eax                ;get & save handles for controls
        invoke  GetDlgItem, hWnd, IDC_AB    ;AlarmButton
        mov ab_handle, eax
        invoke  GetDlgItem, hWnd, IDC_CDTB  ;CountDownTimer
        mov cdtb_handle, eax
        invoke  GetDlgItem, hWnd, IDC_SW    ;StopWatch
        mov sw_handle, eax
        invoke  GetDlgItem, hWnd, IDC_RAB   ;RepeatAfterButton
        mov rab_handle, eax
        invoke  GetDlgItem, hWnd, IDC_START_DATE ;DateTimePicker Control
        mov sdc_handle, eax
        invoke  GetDlgItem, hWnd, IDC_START     ;START button
        mov start_handle, eax
        invoke  GetDlgItem, hWnd, IDC_CANCEL    ;CANCEL button
        mov cancel_handle, eax
        invoke  GetDlgItem, hWnd, IDC_STOP      ;STOP button
        mov stop_handle, eax
        invoke  GetDlgItem, hWnd, IDC_LAP       ;LAP button
        mov lap_handle, eax
        invoke  GetDlgItem, hWnd, IDC_MC        ;MinutesCountdown
        mov mc_handle, eax
        invoke  GetDlgItem, hWnd, IDC_HC        ;HoursCountdown
        mov hc_handle, eax
        invoke  GetDlgItem, hWnd, IDC_SC        ;SecondsCountdown
        mov sc_handle, eax
        invoke  SendMessage, sdc_handle, DTM_SETFORMAT, NULL, addr DateFormat
            ;set format of DateTime control to string in DateFormat
        invoke  ShowWindow, stop_handle, SW_HIDE    ;hide Stop button until needed
        invoke  ShowWindow, lap_handle, SW_HIDE     ;hide Lap button until needed
        invoke  populate_lists                      ;Set up Hour & Minute list
        invoke  set_ini, 0, hWnd                    ;Read in previous settings
        invoke  SendMessage, hc_handle, CB_SETCURSEL, def_hours, 0
            ;set hour control to setting from last use
        invoke  SendMessage, mc_handle, CB_SETCURSEL, def_mins, 0
            ;set minute control to setting from last use
        invoke  SendMessage, sc_handle, CB_SETCURSEL, def_secs, 0
            ;set second control to setting from last use
        .if (def_acorr == 'A')          ;enable alarm function if set from last use
            invoke  SendMessage, ab_handle, BM_CLICK, 0, 0   ;click the Alarm button
            invoke  EnableWindow, rab_handle, FALSE ;disable repeat after checkbox
            invoke  EnableWindow, sc_handle, FALSE  ;disable second listbox
            invoke  EnableWindow, mc_handle, FALSE  ;disable minute listbox
            invoke  EnableWindow, hc_handle, FALSE  ;disable hour listbox
            invoke  SetFocus, sdc_handle            ;set focus to DateTime control
        .elseif (def_acorr == 'S')     ;enable stopwatch function is set from last use
            invoke  SendMessage, sw_handle, BM_CLICK, 0, 0   ;click the Stopwatch button
            invoke  EnableWindow, sdc_handle, FALSE ;disable DateTime Control
            invoke  EnableWindow, rab_handle, FALSE ;disable Repeat After checkbox
            invoke  EnableWindow, sc_handle, FALSE  ;disable second listbox
            invoke  EnableWindow, mc_handle, FALSE  ;disable minute listbox
            invoke  EnableWindow, hc_handle, FALSE  ;disable hour listbox
        .else                           ;enable Countdown Timer is set from last use
            .if (def_acorr == 'R')
                invoke  EnableWindow, rab_handle, TRUE
                invoke  SendMessage, rab_handle, BM_SETCHECK, 1, 0
            .endif
            invoke  SendMessage, cdtb_handle, BM_SETCHECK, 1, 0 ;click the Countdown Timer button
            invoke  EnableWindow, sdc_handle, FALSE ;disable the DateTime control
            invoke  SetFocus, mc_handle             ;set focus to Minute listbox
        .endif
    .elseif (iMsg == WM_CLOSE)
        invoke  EndDialog, hWnd, NULL
    .elseif (iMsg == WM_COMMAND)
        mov eax, wParam
        mov edx, eax
        shr edx, 16
        .if (dx == BN_CLICKED)              ;If button is clicked
            .if (eax == IDC_AB)             ;Alarm radio button pressed
                mov  def_acorr, 'A'
                invoke  SendMessage, ab_handle, BM_CLICK, 0, 0
                invoke  SetFocus, sdc_handle
                invoke  EnableWindow, rab_handle, FALSE
                invoke  EnableWindow, sc_handle, FALSE   ;disable second listbox
                invoke  EnableWindow, mc_handle, FALSE
                invoke  EnableWindow, hc_handle, FALSE
                invoke  EnableWindow, sdc_handle, TRUE
            .elseif (eax == IDC_CDTB)       ;Countdown timer button pressed
                invoke  EnableWindow, rab_handle, TRUE
                invoke  EnableWindow, sc_handle, TRUE   ;enable second listbox
                invoke  EnableWindow, mc_handle, TRUE
                invoke  EnableWindow, hc_handle, TRUE
                invoke  SendMessage, rab_handle, BM_GETCHECK, 0, 0
                                ;determine if Repeat After button is pushed
                .if( eax )                  ;Repeat After CountDown Checked
                    mov def_acorr, 'R'
                .else
                    mov def_acorr, 'C'
                .endif
                invoke  SetFocus, mc_handle
                invoke  EnableWindow, sdc_handle, FALSE
            .elseif (eax == IDC_SW)         ;StopWatch button pressed
                mov def_acorr, 'S'
                invoke  EnableWindow, rab_handle, FALSE
                invoke  EnableWindow, sc_handle, FALSE
                invoke  EnableWindow, mc_handle, FALSE
                invoke  EnableWindow, hc_handle, FALSE
                invoke  EnableWindow, sdc_handle, FALSE
            .elseif (eax == IDC_PICK)       ;Pick .wav sound button pressed
                mov ofn.lStructSize,sizeof ofn
                push    hWnd
                pop ofn.hWndOwner
                push    hInstance
                pop ofn.hInstance
                mov ofn.lpstrFilter, OFFSET FilterString
                mov ofn.lpstrFile, OFFSET wav_name
                mov ofn.nMaxFile, MAX_PATH
                mov ofn.Flags, OFN_FILEMUSTEXIST or \
                  OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                  OFN_EXPLORER or OFN_HIDEREADONLY
                mov ofn.lpstrTitle, OFFSET OurTitle
                invoke  GetOpenFileName, addr ofn
                .if (eax==TRUE)                 ;valid name retrieved
                    invoke  set_ini, 2, hWnd	;Save new .wav file name
                .endif
            .elseif (eax == IDC_START)
                .if (def_acorr == 'S')          ;Stop Watch
                    invoke  ShowWindow, start_handle, SW_HIDE
                    invoke  ShowWindow, stop_handle, SW_RESTORE
                    invoke  ShowWindow, cancel_handle, SW_HIDE
                    invoke  EnableWindow, cancel_handle, FALSE
                    invoke  ShowWindow, lap_handle, SW_RESTORE
                .endif
                invoke  start_timer, hWnd
            .elseif (eax == IDC_STOP)
                invoke  ShowWindow, stop_handle, SW_HIDE
                invoke  ShowWindow, start_handle, SW_RESTORE
                invoke  ShowWindow, lap_handle, SW_HIDE
                invoke  ShowWindow, cancel_handle, SW_RESTORE
                invoke  EnableWindow, cancel_handle, TRUE
                invoke  KillTimer, hWnd, timer_handle
                mov def_acorr, 'P'              ;stopped stopwatch
                call    recalc
                invoke  update_display, hWnd
                invoke  ShowWindow, hWnd, SW_RESTORE
                invoke  SetForegroundWindow, hWnd
                invoke  EnableWindow, start_handle, TRUE
                invoke  EnableWindow, ab_handle, TRUE
                invoke  EnableWindow, sw_handle, TRUE
                invoke  EnableWindow, cdtb_handle, TRUE
                invoke  SendMessage, hWnd, DM_SETDEFID, IDC_CANCEL, 0
                invoke  SetFocus, cancel_handle
                invoke  SetWindowText, hWnd, addr AppName
                mov def_acorr, 'S'
            .elseif (eax == IDC_LAP)
                mov def_acorr, 'P'              ;stopped stopwatch
                mov p_cnt, 0
                call    recalc
                invoke  update_display, hWnd
            .elseif (eax == IDC_CANCEL)
                invoke  EndDialog,hWnd,NULL
            .endif
        .endif
    .elseif (iMsg == WM_NOTIFY)
        MOV eax,lParam                      ;lParam is a pointer to a NMHDR Struct
        MOV eax, (NMHDR PTR [eax]).code     ; is the code member a NM_SETFOCUS?
        .if (eax == NM_SETFOCUS)            ; If so, make sure time value is at least 1 minute beyond current time
            invoke  GetLocalTime, addr system_time   ;Get current time
            add system_time.wMinute, 1      ;add 1 to minutes
            invoke  SendMessage, sdc_handle, DTM_SETSYSTEMTIME, NULL, addr system_time
                                            ;set the control time to this updated time
        .endif
    .elseif (iMsg == WM_TIMER)
        .if (def_acorr == 'P')      ;If we are in lap function or stop
            add p_cnt, 1            ;pause the display for 2 seconds
            .if (p_cnt >= 2)        ;by adding 1 to p_cnt until = 2
                mov p_cnt, 0        ;reset counter
                mov def_acorr, 'S'  ;set to Stopwatch function to resume timing
                jmp @F              ;restart display
            .endif
            ret
        .endif
        mov is_zero, 0                  ;check if timer has zeroed out
@@:     call    recalc                  ;tseconds holds # of seconds left
        invoke  update_display, hWnd    ;update staus and title bar
        .if (def_acorr == 'S')          ;if stopwatch function 
            ret                         ;don't worry about timer expiration
        .endif
        cmp tseconds.dwLowDateTime, 0   ;check for zero in low order DWORD or tseconds
        .if (ZERO?)                     ;if this is zero
            mov is_zero, 1              ;remember
        .endif
        cmp tseconds.dwHighDateTime, 0  ;finish the subtraction from above
        .if !(ZERO? && is_zero)         ;if tseconds is != 0
            ret                         ;keep counting
        .endif
        invoke  ShowWindow, hWnd, SW_RESTORE    ;if tseconds is == 0
        invoke  SetForegroundWindow, hWnd       ;restore dialog
        invoke  PlaySound, addr wav_name, 0, SND_ASYNC or SND_NODEFAULT or SND_FILENAME
        .if (def_acorr == 'A')          ;If we just finished an alarm function
            invoke  KillTimer, hWnd, timer_handle   ;stop timer
            invoke  MessageBox, hWnd, addr time_up, addr AppName, MB_OK  ;display MessageBox
            invoke  EnableWindow, ab_handle, TRUE   ;reenable buttons
            invoke  EnableWindow, cdtb_handle, TRUE
            invoke  EnableWindow, start_handle, TRUE
            invoke  EnableWindow, sw_handle, TRUE
            invoke  EnableWindow, sdc_handle, TRUE  ;reenable DateTime control
            invoke  SetWindowText, hWnd, addr AppName
            invoke  SendMessage, hWnd, DM_SETDEFID, IDC_CANCEL, 0
            invoke  SetFocus, cancel_handle
        .else                               ;If we just finished a Countdown Timer function
            .if (def_acorr == 'R')          ;Should we repeat countdown
                mov eax, repeat_mins        ;reload # of mins for countdown
                mov eax, repeat_secs        ;reload # of mins for countdown
                mov ebx, 10000000           ;conversion for minutes to filetime units
                mul ebx                     ;edx:eax holds filetime units to be added to time_now
                add alarm_time.dwLowDateTime, eax   ;add to original alarm time low order DWORD
                adc alarm_time.dwHighDateTime, edx  ;high order DWORD
                call    recalc
                invoke  update_display, hWnd
                .if (mb_up == 0)            ;Is the Timer Expiration MB already up
                    mov mb_up, 1            ;If not, do it now
                    invoke  MessageBox, hWnd, addr time_up, addr AppName, MB_OK
                    mov mb_up, 0            ;When we return clear flag
                .endif
            .else                           ;No repeat countdown
                invoke  KillTimer, hWnd, timer_handle    ;kill Timer
                invoke  MessageBox, hWnd, addr time_up, addr AppName, MB_OK
                invoke  EnableWindow, ab_handle, TRUE    ;reenable buttons
                invoke  EnableWindow, cdtb_handle, TRUE
                invoke  EnableWindow, start_handle, TRUE
                invoke  EnableWindow, sw_handle, TRUE
                invoke  EnableWindow, rab_handle, TRUE   ;reenable checkbox
                invoke  EnableWindow, sc_handle, TRUE    ;reenable listboxes
                invoke  EnableWindow, mc_handle, TRUE
                invoke  EnableWindow, hc_handle, TRUE
                invoke  SendMessage, hWnd, DM_SETDEFID, IDC_CANCEL, 0
                invoke  SetFocus, cancel_handle
                invoke  SetWindowText, hWnd, addr AppName
            .endif
        .endif
    .else
        mov eax, FALSE
        ret
    .endif
    mov eax, TRUE
    ret
DlgProc endp

;-----------------------------------------------------
populate_lists  PROC 
;____________________________________________________________________
LOCAL z_str:BYTE                ;Byte to hold a 0 'end of string'
LOCAL in_side:BYTE              ;Byte for inside loop, 1's
LOCAL out_side:BYTE             ;Byte for the outside loop, 10's
    mov in_side, '0'            ;initialize 1's
    mov out_side, '0'           ;initialize 10's
    mov z_str, 0                ;set end of string
an_os:                          ;do another 10's
    cmp out_side, '5'           ;max value for 10's
    jg  dpl                     ;if done, jump to done populating list
an_is:                          ;do another 1's
    cmp in_side, '9'            ;max value for 1's
    jg  dis                     ;if done, jump to do inside
    invoke  SendMessage, hc_handle, CB_ADDSTRING, 0, addr out_side
                                ;add to hour list
    invoke  SendMessage, mc_handle, CB_ADDSTRING, 0, addr out_side
                                ;add to minute list
    invoke  SendMessage, sc_handle, CB_ADDSTRING, 0, addr out_side
                                ;add to second list
    inc in_side                 ;increment 1's
    jmp an_is                   ;jump to another inside, 1's
dis:
    inc out_side                ;increment 10's
    mov in_side, '0'            ;reset 1's
    jmp an_os                   ;jump to another outside, 10's
dpl:                            ;done populating list
    ret
populate_lists  ENDP

;-----------------------------------------------------
start_timer PROC hWnd:HWND
;   Timer used in this program simply to update display of the dialog.
;   Originally tried to use timer as counting mechanism, but quickly
;       saw that timer gets 'distacted' by the doing other things and
;       timer function would not 'fire' every 1000 milliseconds.
;_____________________________________________________
LOCAL st_hour:WORD
LOCAL st_min:WORD
LOCAL st_sec:WORD
LOCAL timer_min:DWORD
LOCAL timer_sec:DWORD
;For both Alarm and Countdown Timer, we will calculate expiration time
;   For Alarm, this will be the value returned by DTM_GETSYSTEMTIME message
;   For Countdown Timer, we will add the number of hours & minutes to the
;        GetLocalTime value to get expiration time.
;   Each time a Timer event is triggered, the number of remaining seconds
;       will be recalculated.  Expiration - GetLocalTime and stored in
;       alarm_time FILETIME structure
;       time_now FILETIME holds the current time
;For StopWatch, we will set the time_now and reset the alarm_time each
;   timer event ~1 sec., the display will be updated by subtracting
;   time_now (starting_time) from the alarm_now to calculate elapsed time!
;
    invoke  GetLocalTime, addr system_time               ;Get Local Time
    invoke  SystemTimeToFileTime, addr system_time, addr time_now
        ;convert that system time into a file time to make comparison easier
    invoke  SendMessage, ab_handle, BM_GETCHECK, 1, 0    ;find out if Alarm Button is selected
    .if (eax)                               ;Alarm Button is Selected
        invoke  SendMessage, sdc_handle, DTM_GETSYSTEMTIME, 0, addr system_time
                                            ;get the date time from that control
        mov system_time.wSecond, 0          ;zero out the seconds
        mov system_time.wMilliseconds, 0    ;and milliseconds
        invoke  SystemTimeToFileTime, addr system_time, addr alarm_time
                                            ;convert to filetime for comparison
        mov eax, alarm_time.dwHighDateTime
        sub eax, time_now.dwHighDateTime    ;subtract time now from DT time
        jb  er_td                           ;quit if alarm.high < now.high
        jne @F                              ;jump if alarm.high > now.high
        mov eax, alarm_time.dwLowDateTime   ;here if alarm.high = now.high
        sub eax, time_now.dwLowDateTime
        jb  er_td                           ;quit if alarm.low < now.low
;Subtract Time_Now from Alarm_time to calculate the number of seconds to time
@@:     mov eax, 1000                       ;timer trips every second
        invoke  SetTimer, hWnd, timer_num, eax, NULL    ;start timer
        mov timer_handle, eax
        mov def_acorr, 'A'
        call    recalc
        invoke  update_display, hWnd
        invoke  set_ini, 1, hWnd            ;save the current settings 
        invoke  EnableWindow, ab_handle, FALSE  ;disable buttons
        invoke  EnableWindow, cdtb_handle, FALSE
        invoke  EnableWindow, rab_handle, FALSE
        invoke  EnableWindow, sw_handle, FALSE
        invoke  EnableWindow, start_handle, FALSE
        invoke  EnableWindow, sc_handle, FALSE  ;disable listboxes
        invoke  EnableWindow, mc_handle, FALSE
        invoke  EnableWindow, hc_handle, FALSE
        invoke  EnableWindow, sdc_handle, FALSE ;disable DT controls
        ret
er_td:
        invoke  MessageBox, hWnd, addr date_error, NULL, MB_OK
                                                ;report DateTime error
        ret
    .else                   ;Countdown timer Button or StopWatch checked
        invoke  SendMessage, sw_handle, BM_GETCHECK, 1, 0    ;find out if StopWatch button is selected
        .if (eax)           ;StopWatch function
            mov eax, 1000
            invoke  SetTimer, hWnd, timer_num, eax, NULL
            mov timer_handle, eax
            mov def_acorr, 'S'
            call    recalc
            invoke  update_display, hWnd
            invoke  set_ini, 1, hWnd                    ;save current settings
            invoke  EnableWindow, ab_handle, FALSE      ;disable buttons
            invoke  EnableWindow, cdtb_handle, FALSE
            invoke  EnableWindow, rab_handle, FALSE
            invoke  EnableWindow, start_handle, FALSE
            invoke  EnableWindow, sw_handle, FALSE
            invoke  EnableWindow, sc_handle, FALSE      ;disable listboxes
            invoke  EnableWindow, mc_handle, FALSE
            invoke  EnableWindow, hc_handle, FALSE
            invoke  EnableWindow, sdc_handle, FALSE     ;disable DT control
            ret
        .endif
                            ;we are here if CountDown fuction is selected
        invoke  GetDlgItemText, hWnd, IDC_HC, addr d_buffer, 256
                            ;determine setting of Timer Hour listbox
        mov ax, word ptr d_buffer
        mov hc_str, ax                      ;get 2 digit setting into hc_str
        xor eax, eax
        mov al, d_buffer                    ;significant char of Timer Hours
        sub al, '0'                         ;convert to number
        imul    ax, 10                      ;mul by 10
        mov st_hour, ax
        xor eax, eax
        mov al, d_buffer + 1                ;second char of Timer Hours
        sub al, '0'
        add st_hour, ax                     ;add minutes to hours
        mov ax, st_hour
        cwde                                ;convert timer hours WORD to DWORD
        mov ebx, 60
        mul ebx                             ;Multiply by 60 to get minutes
        mov timer_min, eax                  ;# of minutes from the Timer Hours
        invoke  GetDlgItemText, hWnd, IDC_MC, addr d_buffer, 256
            ;determine setting of Timer Miunte listbox
        mov ax, word ptr d_buffer
        mov mc_str, ax
        xor eax, eax
        mov al, d_buffer                ;significant char of Timer Minutes
        sub al, '0'
        imul    ax, 10
        mov st_min, ax
        mov al, d_buffer + 1            ;second char of Timer Minutes
        sub al, '0'
        add st_min, ax
        mov ax, st_min
        cwde
        add eax, timer_min              ;Add # of minutes from Hour control
        mov repeat_mins, eax            ;store timer minutes incase repeat after
        imul    eax, 60
        mov timer_sec, eax              ;# of seconds from Hour & Minute controls
        mov repeat_secs, eax
        invoke  GetDlgItemText, hWnd, IDC_SC, addr d_buffer, 256
            ;determine setting of Timer Second listbox
        mov ax, word ptr d_buffer
        mov sc_str, ax
        xor eax, eax
        mov al, d_buffer                ;significant char of Timer Minutes
        sub al, '0'
        imul    ax, 10
        mov st_sec, ax
        mov al, d_buffer + 1            ;second char of Timer Minutes
        sub al, '0'
        add st_sec, ax
        mov ax, st_sec
        cwde
        add eax, repeat_secs        ;store timer seconds incase repeat after
        mov repeat_secs, eax
        push    eax                 ;temporarily save seconds
        invoke  GetLocalTime, addr system_time
        invoke  SystemTimeToFileTime, addr system_time, addr time_now
        pop eax                     ;restore timer seonds
        mov ebx, 10000000           ;conversion for seonds to filetime units
        mul ebx                     ;edx:eax holds filetime units to be added to time_now
        mov ebx, time_now.dwLowDateTime
        add ebx, eax                ;add time_now low WORD to timer low WORD
        mov alarm_time.dwLowDateTime, ebx   ;save in alarm time
        mov ebx, time_now.dwHighDateTime
        adc ebx, edx                ;add with carry, time now high WORD to timer high WORD
        mov alarm_time.dwHighDateTime, ebx  ;save in alarm time
        invoke  SendMessage, rab_handle, BM_GETCHECK, 0, 0
            ;determine if Repeat After button is pushed
        .if (eax)                   ;Repeat After CountDown Checked
            mov def_acorr, 'R'
        .else
            mov def_acorr, 'C'
        .endif
        mov eax, 1000               ;start Timer for 1 second
        invoke  SetTimer, hWnd, timer_num, eax, NULL
        mov timer_handle, eax
        call    recalc
        invoke  update_display, hWnd
        invoke  set_ini, 1, hWnd    ;save current settings
        invoke  EnableWindow, ab_handle, FALSE   ;disable buttons
        invoke  EnableWindow, cdtb_handle, FALSE
        invoke  EnableWindow, rab_handle, FALSE
        invoke  EnableWindow, start_handle, FALSE
        invoke  EnableWindow, sw_handle, FALSE
        invoke  EnableWindow, sc_handle, FALSE   ;disable listboxes
        invoke  EnableWindow, mc_handle, FALSE
        invoke  EnableWindow, hc_handle, FALSE
        invoke  EnableWindow, sdc_handle, FALSE  ;disable control
    .endif
    jmp @F
no_cdt: 
    invoke  MessageBox, hWnd, addr nocdt, NULL, MB_OK
                        ;display no time in hours and minutes listbox error
@@:
    ret
start_timer ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ini File description:
;   Header 50 bytes long including cr/lf
;0  Joe's Alarm/Countdown Timer/StopWatch (c) 2000-2001 MASM32  ;plus 13, 10
;   Body
;60     Hours:xx            ;previous hours setting plus 13, 10
;70     Minutes:xx          ;previous minutes setting plus 13, 10
;82     Seconds:xx          ;previous seconds settingplus 13, 10
;94     ACorR:x             ;previous function setting Alarm, Countdown, Repeat after, or Stopwatch
;103    Wav:
;107    file name of default wav file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-----------------------------------------------------
set_ini PROC   fType:WORD, hWnd:HWND
;_____________________________________________________
LOCAL iniHandle:HWND
LOCAL bRead:DWORD
LOCAL temp_dw:DWORD
    invoke  CreateFile, addr iniFileName, GENERIC_READ or GENERIC_WRITE, \
        0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, NULL
                                            ;try to create a new ini file
    mov iniHandle, eax
    invoke  GetLastError                    ;error will show if file exists
    .if (eax != ERROR_ALREADY_EXISTS)       ;File Needs to be Created or
                                            ;   error opening file
        .if (eax == 0)                      ;New File Created
            lea eax, w_buffer
            lea ebx, IDStr
            sub eax, ebx
            mov temp_dw, eax                ;length of IDStr & other values in temp_dw
            invoke  WriteFile, iniHandle, addr IDStr, temp_dw, addr bRead, NULL
                                            ;write IDStr to new file
            mov def_hours, 1                ;establish abrtrary defaults
            mov def_mins, 30
            mov def_secs, 0
            mov def_acorr, 'A'
            invoke  CloseHandle, iniHandle  ;close new ini file
            ret
        .else                               ;Error opening file
            invoke  CloseHandle, iniHandle
            invoke  MessageBox, hWnd, addr iniFileName, addr AppName, MB_OK
                                            ;display error opening file dialog
            mov def_hours, 1                ;establish abrtrary defaults
            mov def_mins, 30
            mov def_secs, 0
            mov def_acorr, 'A'
            ret
        .endif
    .endif
;We're here if the file was opened as already existing
; Check to see if this is a valid file
; And read in default values!
    invoke  ReadFile, iniHandle, addr d_buffer, sizeof IDStr, addr bRead, NULL
        ;read IDStr into d+buffer
    lea edi, d_buffer       ;String read from .ini file in d_buffer
    lea esi, IDStr          ;Compare with the one built into this program
    mov ecx, sizeof IDStr   ;How many character to compare
    cld
    repe    cmpsb           ;Compare
    .if (!ZERO?)            ;Strings did not compare
        invoke  MessageBox, hWnd, addr ini_nom, addr AppName, MB_OK
        invoke  CloseHandle, iniHandle
        mov def_hours, 1                ;establish abrtrary defaults
        mov def_mins, 30
        mov def_acorr, 'A'
        ret
    .endif
        ;fType is parameter passed to this routine
        ;   0 - Read in settings saved from previous use at program start
        ;   1 - Save current timer settings
        ;   2 - Save new wave file name
        ;FilePointer is currently pointing to "Hours:"
    .if (fType == 0)                            ;Read in initial values
        invoke  SetFilePointer, iniHandle, 6, NULL, FILE_CURRENT
                                                ;skips string "Hours:"
        invoke  ReadFile, iniHandle, addr d_buffer, 2, addr bRead, NULL
                                                ;reads 2 digit Hour string
        xor eax, eax
        mov al, d_buffer                    ;significant char of Timer Hours
        mov byte ptr hc_str, al
        sub al, '0'
        imul    ax, 10
        mov def_hours, eax
        xor eax, eax
        mov al, d_buffer + 1                ;second char of Timer Hours
        mov byte ptr hc_str+1, al
        sub al, '0'
        add def_hours, eax      ;timer hours in def_hours, used to set listbox
        invoke  SetFilePointer, iniHandle, 10, NULL, FILE_CURRENT
                                ;skips CR, LF, & string "Minutes:"
        invoke  ReadFile, iniHandle, addr d_buffer, 2, addr bRead, NULL
                                ;reads 2 digit Minute string
        xor eax, eax
        mov al, d_buffer        ;first char of Timer Minutes
        mov byte ptr mc_str, al
        sub al, '0'
        imul    ax, 10
        mov def_mins, eax
        xor eax, eax
        mov al, d_buffer + 1    ;second char of Timer Minutes
        mov byte ptr mc_str+1, al
        sub al, '0'
        add def_mins, eax       ;timer minutes in def_mins, used to set listbox
        invoke  SetFilePointer, iniHandle, 10, NULL, FILE_CURRENT
                                ;skips CR, LF, & string "Seconds:"
        invoke  ReadFile, iniHandle, addr d_buffer, 2, addr bRead, NULL
                                ;reads 2 digit Second string
        xor eax, eax
        mov al, d_buffer        ;first char of Timer Minutes
        mov byte ptr sc_str, al
        sub al, '0'
        imul    ax, 10
        mov def_secs, eax
        xor eax, eax
        mov al, d_buffer + 1    ;second char of Timer Minutes
        mov byte ptr sc_str+1, al
        sub al, '0'
        add def_secs, eax       ;timer minutes in def_mins, used to set listbox
        invoke  SetFilePointer, iniHandle, 8, NULL, FILE_CURRENT
                                ;skips CR, LF, & string "CRorR:"
        invoke  ReadFile, iniHandle, addr d_buffer, 1, addr bRead, NULL
                                ;reads 1 char CRorR string
        mov al, byte ptr d_buffer
        mov def_acorr, al           ;previous value A,C,R, or S in def_acorr
        invoke  SetFilePointer, iniHandle, 6, NULL, FILE_CURRENT
                                    ;skips CR, LF, & string "Wav:"
        invoke  ReadFile, iniHandle, addr d_buffer, MAX_PATH, addr bRead, NULL
                                    ;reads wav file name
        invoke  lstrcpy, addr wav_name, addr d_buffer
                                    ;copies file name into wav_name variable
        invoke  CloseHandle, iniHandle
        ret
    .elseif (fType == 1)            ;save timer settings
        mov eax, sizeof IDStr
        add eax, sizeof hStr
        sub eax, 4
        invoke  SetFilePointer, iniHandle, eax, NULL, FILE_BEGIN
                                    ;sets file pointer to just after "Hours:"
        invoke  WriteFile, iniHandle, addr hc_str, 2, addr bRead, NULL
                                    ;writes Hour string
        invoke  SetFilePointer, iniHandle, 10, NULL, FILE_CURRENT
                        ;sets file pointer to just after CR, LF, & "Minutes:"
        invoke  WriteFile, iniHandle, addr mc_str, 2, addr bRead, NULL
                        ;writes Minute string
        invoke  SetFilePointer, iniHandle, 10, NULL, FILE_CURRENT
                        ;sets file pointer to just after CR, LF, & "Seconds:"
        invoke  WriteFile, iniHandle, addr sc_str, 2, addr bRead, NULL
                        ;writes Second string
        invoke  SetFilePointer, iniHandle, 8, NULL, FILE_CURRENT
                        ;sets file pointer to just after CR,LF,&"CRorR:"
        invoke  WriteFile, iniHandle, addr def_acorr, 1, addr bRead, NULL
        invoke  CloseHandle, iniHandle
        ret
    .elseif (fType == 2)                    ;Save new wav file name
        lea eax, initial_wav_name
        lea ecx, IDStr
        sub eax, ecx
        invoke  SetFilePointer, iniHandle, eax, NULL, FILE_BEGIN
        invoke  SetEndOfFile, iniHandle
        invoke s_length, addr wav_name
        mov temp_dw, eax
        invoke  WriteFile, iniHandle, addr wav_name, temp_dw, addr bRead, NULL
        mov temp_dw, 0
        invoke  WriteFile, iniHandle, addr temp_dw, 1, addr bRead, NULL
        invoke  CloseHandle, iniHandle
        ret
    .endif
set_ini ENDP

;----------------------------------------------------------------------
update_display  PROC hWnd:HWND
;_______________________________________________________________________
;Uses tseconds.dwHighDateTime & tseconds.dwLowDateTime
;   this 64 bit number contains the number of seconds until the alarm
;   expires.  Divide the number by 3600 to calculate the number of hours
;   remaining, the remainder-(minutes)-is divided by 60 to calculate
;   the number of seconds remaining.  Display Hours:minutes:seconds!
;If def_acorr == 'P' show final time with decimal seconds
LOCAL   rhours:FILETIME     ;Max = 2^64 / 3600 = 5.1241 x 10 ^ 15
;                                = 5,124,100,000,000,000    possible 22 chars long with commas
LOCAL   rmins:DWORD         ;Max = 59
LOCAL   rsecs:DWORD         ;Max = 59
LOCAL   rmsecs:DWORD        ;Max = 999
LOCAL   secs_p_hours        ;Set to 3600 for secs, 3600000 for msecs
LOCAL   dhours[22]:BYTE
LOCAL   dmins[3]:BYTE
LOCAL   dsecs[3]:BYTE
LOCAL   dmsecs[4]:BYTE
LOCAL   stat_str[60]:BYTE
LOCAL   jact[5]:BYTE
    cld
    mov al, 0
    mov ecx, sizeof stat_str
    lea edi, stat_str
    rep stosb
    mov ecx, sizeof dhours
    lea edi, dhours
    rep stosb               ;make sure space for hour string is blank
    mov ecx, sizeof dmins
    lea edi, dmins
    rep stosb               ;make sure space for minute string is blank
    mov ecx, sizeof dsecs
    lea edi, dsecs
    rep stosb               ;make sure space for second string is blank
    mov ecx, sizeof dmsecs
    lea edi, dmsecs
    rep stosb               ;make sure space for milli-second string is blank
    .if (def_acorr != 'P')  ;tseconds structure holds # of seconds to display
        mov rmins, 3600
        mov rsecs, 60
        fild    tseconds    ;dividend
        fidiv   rmins
        frndint
        fistp   rhours      ;store hour number in rhours
        fild    rmins
        fild    tseconds
        fprem               ;remainder in st(0)? this is minutes & seconds
        ffree   st(1)
        fild    rsecs
        fxch    st(1)
        fld     st(1)       ;make a copy for the remainder
        fld     st(1)
        fdivrp  st(1),st(0) ;divide minutes & seconds by 60
        frndint
        fistp   rmins
        fprem
        fistp   rsecs
        ffree   st(0)
    .else                   ;tseconds structure holds # of milliseconds to display
        mov rmins, 3600000  ;msecs / hour
        mov rsecs, 60000    ;msecs / minute
        mov rmsecs, 1000    ;msecs / sec
        fild    tseconds
        fidiv   rmins       ;divides msecs by msecs/hour to give hours
        frndint             ;rounds down to lower integer
        fistp   rhours      ;store hour number in rhours
        fild    rmins
        fild    tseconds
        fprem               ;remainder in st(0)? this is minutes & seconds remaining in msecs
        ffree   st(1)
        fild    rsecs       ;loads msecs/minute
        fxch    st(1)       ;swaps st(0) & st(1) - msecs/minute in 1 remainder in 0
        fld     st(1)       ;make a copy for the remainder
        fld     st(1)
        fdivrp  st(1),st(0) ;divide minutes & seconds by 60000
        frndint             ;rounds down to lower integer
        fistp   rmins       ;store rmins
        fprem               ;remainder in st(0) - seconds in msecs
        ffree   st(1)
        fild    rmsecs      ;loads msecs/sec
        fxch    st(1)       ;swaps st(0) & st(1)
        fld     st(1)       ;make a copy for the remainder
        fld     st(1)
        fdivrp  st(1),st(0) ;divide seconds & millisecond by 1000
        frndint             ;rounds down to lower integer
        fistp   rsecs       ;store rsecs
        fprem               ;remainder in st(0) - msecs
        fistp   rmsecs
        ffree   st(0)
    .endif
    fwait
;At this point the # of Hours is in the Qword @ rhours
;              the # of Minutes is in the Dword @ rmins
;              the # of Seconds is in the Dword @ rsec
    cmp rhours.dwHighDateTime, 0
    je  @F
    mov dhours, 'M'
    mov dhours+1, 'a'
    mov dhours+2, 'n'
    mov dhours+3, 'y'
    mov dhours+4, '!'
    mov dhours+5, 0
    jmp print_d
@@: invoke dwtoa, rhours.dwLowDateTime, addr dhours
    invoke dwtoa, rmins, addr dmins
    invoke dwtoa, rsecs, addr dsecs
    .if (def_acorr != 'P')
        mov rmsecs, 0
    .endif
    invoke  dwtoa, rmsecs, addr dmsecs
print_d:
    lea edi, stat_str
    push    edi
    invoke  s_length, addr dhours
    mov ecx, eax
    pop edi
    lea esi, dhours
    cld
    rep movsb
    lea esi, hour_str
    mov ecx, sizeof hour_str
    cld
    rep movsb
    mov word ptr [edi], '  '
    add edi, 2
    push edi
    invoke  s_length, addr dmins
    mov ecx, eax
    pop edi
    lea esi, dmins
    cld
    rep movsb
    lea esi, minute_str
    mov ecx, sizeof minute_str
    cld
    rep movsb
    mov word ptr [edi], '  '
    add edi, 2
    push    edi
    invoke  s_length, addr dsecs
    mov ecx, eax
    pop edi
    lea esi, dsecs
    cld
    rep movsb
    lea esi, second_str
    mov ecx, sizeof second_str
    cld
    rep movsb
    .if (def_acorr == 'P')
        mov word ptr [edi], '  '
        add edi, 2
        push    edi
        invoke  s_length, addr dmsecs
        mov ecx, eax
        pop edi
        lea esi, dmsecs
        cld
        rep movsb
        lea esi, msec_str
        mov ecx, sizeof msec_str
        cld
        rep movsb
    .endif
    mov byte ptr[edi], 0
    invoke  SendMessage, stat_handle, SB_SETTEXT, 0, addr stat_str
    mov byte ptr jact, 'J'
    mov byte ptr jact+1, 'A'
    mov byte ptr jact+2, 'C'
    mov byte ptr jact+3, 'T'
    mov byte ptr jact+4, ' '
    invoke  SetWindowText, hWnd, addr jact
    ret
update_display ENDP

; -------------------------------------------------------------------
dwtoa proc public uses esi edi dwValue:DWORD, lpBuffer:PTR BYTE
;____________________________________________________________________
    ; -----------------------------------------
    ; This procedure was written by Tim Roberts
    ; -----------------------------------------
    ; Modified slightly by Farrier to return a '0' when dwValue = 0
    ; -------------------------------------------------------------
    ; convert DWORD to ascii string
    ; dwValue is value to be converted
    ; lpBuffer is the address of the receiving buffer
    ; EXAMPLE:
    ; invoke dwtoa,edx,addr buffer
    ;
    ; Uses: eax, ecx, edx.
    ; -------------------------------------------------------------

    mov eax, dwValue
    mov edi, [lpBuffer]
    .if (eax == 0)
        mov byte ptr [edi], '0'
        inc edi
        mov byte ptr [edi], 0
        ret
    .endif
    ; Is the value negative?
    .if (sdword ptr eax < 0)
      mov byte ptr [edi], '-'   ;store a minus sign
      inc edi
      neg eax                   ;and invert the value
    .endif
    mov esi, edi                ;save pointer to first digit
    mov ecx, 10
    .while (eax > 0)            ;while there is more to convert...
      xor edx, edx
      div ecx                   ;put next digit in edx
      add dl, '0'               ;convert to ASCII
      mov [edi], dl             ;store it
      inc edi
    .endw
    mov byte ptr [edi], 0       ;terminate the string
    ; We now have all the digits, but in reverse order.
    .while (esi < edi)
      dec edi
      mov al, [esi]
      mov ah, [edi]
      mov [edi], al
      mov [esi], ah
      inc esi
    .endw
    ret
dwtoa endp

;-----------------------------
s_length PROC s_addr:PTR BYTE
;_____________________________
    mov edi, [s_addr]
    xor al, al
    mov ecx, -1
    cld
    repne   scasb
    not ecx
    dec ecx
    mov eax, ecx
    ret
s_length ENDP

;-----------------------------------------------------
recalc PROC
;_____________________________________________________
LOCAL ft_comp:DWORD
;uses alarm_time - time_now FILETIME structures to calculate the number of seconds left
    invoke  GetLocalTime, addr system_time
    .if (def_acorr == 'S')             ;StopWatch Function
        invoke  SystemTimeToFileTime, addr system_time, addr alarm_time
    .elseif (def_acorr == 'P')         ;Final StopWatch recalc
        invoke  SystemTimeToFileTime, addr system_time, addr alarm_time
    .else
        invoke  SystemTimeToFileTime, addr system_time, addr time_now
    .endif
;Subtract Time_Now from Alarm_time to calculate the number of seconds to time
    mov eax, alarm_time.dwLowDateTime
    sub eax, time_now.dwLowDateTime
    mov tseconds.dwLowDateTime, eax
    mov eax, alarm_time.dwHighDateTime
    sbb eax, time_now.dwHighDateTime
    jb  @f
    mov tseconds.dwHighDateTime, eax    ;tseconds now contains # of 100 nanoseconds remaining
    .if (def_acorr == 'P')              ;leave tseconds with milliseconds
        mov ft_comp, 10000              ;correction factor for 100 nanoseconds to msecs
    .else
        mov ft_comp, 10000000           ;correction factor for 100 nanoseconds to seconds
    .endif
    fild    qword ptr tseconds          ;load tseconds into FPU
    fidiv   ft_comp                     ;divide by correction factor
    frndint                             ;round down to next lowest integer
    fistp   qword ptr tseconds          ;store result in seconds back to tseconds
    fwait                               ;make sure all floating point ops are done
    ret
@@: mov tseconds.dwHighDateTime, 0      ;we're here if time has expired
    mov tseconds.dwLowDateTime, 0       ;so set everything to zero
    ret
recalc ENDP

end start
