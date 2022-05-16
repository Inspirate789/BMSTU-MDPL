;;
;; aPLib compression library  -  the smaller the better :)
;;
;; MASM32 include file
;;

aP_pack            proto c, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
aP_workmem_size    proto c, :DWORD
aP_depack_asm      proto c, :DWORD, :DWORD
aP_depack_asm_fast proto c, :DWORD, :DWORD
