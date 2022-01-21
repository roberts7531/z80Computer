
; char *fzx_string_partition(struct fzx_font *ff, char *s, uint16_t allowed_width)

SECTION code_font
SECTION code_font_fzx

PUBLIC _fzx_string_partition

EXTERN l0_fzx_string_partition_callee

_fzx_string_partition:

   pop af
   pop bc
   pop de
   pop hl
   
   push hl
   push de
   push bc
   push af

   jp l0_fzx_string_partition_callee
