; ####################################################
;       William F. Cravener updated 7/28/2003
; ####################################################
    
        .486
        .model flat,stdcall
        option casemap:none

        include \masm32\include\windows.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\winmm.inc

        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\winmm.lib

; ####################################################

        MIXER_ERROR equ 0FFFFFFFFh 
        SPEAKEROUTLINEID equ 0FFFF0000h

.data
        MixerHandle    dd 0
        VolCtlIDMtr    dd 0

        mxc MIXERCONTROL <?>
        mxcd MIXERCONTROLDETAILS <?>
        mxcdVol MIXERCONTROLDETAILS_UNSIGNED <?>
        mxlc MIXERLINECONTROLS <?>

        AppName db "Master Volume Control",0

; ####################################################

.code

DllEntry proc hInstance:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov  eax,TRUE
	ret
DllEntry Endp

; ###############################################################

GetMasterVolume proc

        invoke mixerOpen,ADDR MixerHandle,0,0,0,0
        .if eax == MMSYSERR_NOERROR 
            mov mxlc.cbStruct,SIZEOF mxlc
            mov mxlc.dwLineID,SPEAKEROUTLINEID
            mov mxlc.dwControlType,MIXERCONTROL_CONTROLTYPE_VOLUME
            mov mxlc.cControls,1
            mov mxlc.cbmxctrl,SIZEOF mxc
            mov mxlc.pamxctrl,OFFSET mxc
            invoke mixerGetLineControls,MixerHandle,ADDR mxlc,MIXER_GETLINECONTROLSF_ONEBYTYPE
            mov eax,mxc.dwControlID
            mov VolCtlIDMtr,eax
            mov mxcdVol.dwValue,1
            mov mxcd.cbStruct,SIZEOF mxcd
            mov eax,VolCtlIDMtr  
            mov mxcd.dwControlID,eax
            mov mxcd.cChannels,1
            mov mxcd.cMultipleItems,0
            mov mxcd.cbDetails,SIZEOF mxcdVol
            mov mxcd.paDetails,OFFSET mxcdVol
            invoke mixerGetControlDetails,MixerHandle,ADDR mxcd,MIXER_GETCONTROLDETAILSF_VALUE
            mov eax,mxcdVol[0].dwValue
        .else
            mov eax,MIXER_ERROR
        .endif
        ret

GetMasterVolume endp
    
; ###############################################################

SetMasterVolume proc VolValue:DWORD

        mov eax,VolValue
        mov mxcdVol[0].dwValue,eax
        mov mxcd.cbStruct,SIZEOF mxcd
        mov eax,VolCtlIDMtr
        mov mxcd.dwControlID,eax
        mov mxcd.cChannels,1
        mov mxcd.cMultipleItems,0
        mov mxcd.cbDetails,SIZEOF mxcdVol
        mov mxcd.paDetails,OFFSET mxcdVol
        invoke mixerSetControlDetails,MixerHandle,ADDR mxcd,MIXER_GETCONTROLDETAILSF_VALUE
        .if eax == MMSYSERR_NOERROR
            mov eax,0
        .else
            mov eax,MIXER_ERROR
        .endif            
        ret

SetMasterVolume endp

; ###############################################################

CloseMasterVolume proc

        invoke mixerClose,ADDR MixerHandle
        ret

CloseMasterVolume endp

; ###############################################################

End DllEntry
