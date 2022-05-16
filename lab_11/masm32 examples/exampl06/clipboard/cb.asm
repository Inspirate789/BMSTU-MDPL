; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                     Build this  template with
                    "CONSOLE ASSEMBLE AND LINK"

                Read and write text to the clipboard.
        ----------------------------------------------------- *

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL ptxt  :DWORD

  ; ---------------------------
  ; write text to the clipboard
  ; ---------------------------
    print "1. Writing text to the clipboard",13,10,13,10
    fn SetClipboardText,"This is a test of text written to the clipboard folks."

    print "2. Read text back from the clipboard",13,10,13,10
    invoke GetClipboardText     ; read it back off the clipboard
    mov ptxt, eax

    print "3. Displaying text from the clipboard",13,10,13,10,"Text from clipboard =", 62, 32

    print ptxt,13,10,13,10      ; display the results to the console

    invoke GlobalFree,ptxt      ; free the memory for the text

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start






















