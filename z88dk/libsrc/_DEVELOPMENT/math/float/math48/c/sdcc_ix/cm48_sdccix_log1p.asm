
; float log1p(float x)

SECTION code_clib
SECTION code_fp_math48

PUBLIC cm48_sdccix_log1p

EXTERN cm48_sdccix_log1p_fastcall

cm48_sdccix_log1p:

   pop af
   pop hl
   pop de
   
   push de
   push hl
   push af
   
   jp cm48_sdccix_log1p_fastcall
