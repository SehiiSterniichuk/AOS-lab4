%include "io.inc"

section .data
    M dw 2,1,7,1,0,9,1,0
    R dw 0,0,0,0,0,0,0,0
    size equ ($ - M)/4
    a equ 16
    msg1  db "Start Massive: %X", 10, 0
    msg2  db "Result Massive: %X", 10, 0
    message db "Element = %X", 10, 0
section .text
global CMAIN
extern printf
CMAIN:
    mov ebp, esp; for correct debugging
    xor eax, eax
    
    mov ebx, 1
    push ebx
    push msg1 
    call printf
    add esp, 8
    mov esi, M
    mov edi, R
    mov ecx, 0; increment
    call f_print_massive
    call f_do_lab
    
    call set_default_values
    mov ebx, 2
    push ebx
    push msg2 
    call printf
    add esp, 8
    call set_default_values
    
    mov esi, R
    call f_print_massive
    ret

f_do_lab:
    call set_default_values
    call main_loop
    call set_default_values
    ret
set_pointer_M_to_eax_value:
    mov esi, M
    mov ecx, 0
    call setter_a_loop
    mov ecx, 0
    call part_after_set_eax
    ret

setter_a_loop:
    add esi, 2
    inc ecx
    cmp ecx, eax
    jb setter_a_loop
    ret

main_loop: ; eax == i, ebx == j // for(int i = 0; i < size; ++i)
    cmp eax, 1
    jnb set_pointer_M_to_eax_value ; eax >= 1
    call part_after_set_eax
    ret
    
part_after_set_eax:
    mov bl, [esi]
    mov [edi], bl ; R[i] = M[i]; edi = esi
    mov edx, eax
    sub edx, 3 ; j = i - 3
    cmp eax, 3 ; if(i < 3)
    jb less_than_three; j = 0
    call second_part_main_loop
    ret

second_part_main_loop:
    call set_pointer_M_to_edx_value1 ; ebx >= 1
    call part_after_set_pointer1
    ret
    
part_after_set_pointer1:
    cmp edx, eax ; if (j < i)
    jb first_slave_loop ;for(; j < i; ++j)
    call part_after_first_slave
    ret
    
set_pointer_M_to_edx_value1:
    mov esi, M
    mov ecx, 0
    cmp edx, 1
    jnb setter_loop1
    mov ecx, 0
    call part_after_set_pointer1
    ret

setter_loop1:
    add esi, 2
    inc ecx
    cmp ecx, edx
    jb setter_loop
    ret

part_after_first_slave:
    mov edx, eax
    add edx, 3 ; j = (i + 3);
    mov ecx, size
    sub ecx, 1 ; ecx = size - 1
    cmp ecx, edx ; if(size - 1 < j)
    jb get_last_index_value; ; j = size - 1
    call set_pointer_M_to_edx_value
    call part_after_index_value
    ret

part_after_index_value:    
    mov bl, [edi]
    call verification_esi 
    call part_after_verif
    ret
    
part_after_verif:
    cmp eax, edx ;if(i < j)
    jb second_slave_loop   ;for(; i < j; --j)
    call part_main_after_second_slave

verification_esi:
    mov esi, M
    mov ecx, 0
    cmp edx, 1
    jnb verif_loop
    mov ecx, 0
    call part_after_verif
    ret

verif_loop:
    add esi, 2
    inc ecx
    cmp ecx, edx
    jb verif_loop
    ret
    
part_main_after_second_slave:
    call go_up_pointer_R
    inc eax ; ++i
    add esi, 2
    cmp eax, size ; if(i < size)
    jb main_loop
    ret

less_than_three:; if(i < 3)
    mov edx, 0; j = 0
    call second_part_main_loop
    ret

first_slave_loop:;for(; j < i; ++j)
  ;  call set_pointer_M_to_edx_value
    mov bl, [esi]
    add [edi], bl ; R[i] += M[j];
    add esi, 2
    inc edx ; ++j
    cmp edx, eax ;if(j < i)
    jb first_slave_loop  
    
    cmp edx, eax 
    je part_after_first_slave
    ret
    

set_default_values:
    mov ecx, 0
    mov eax, 0
    mov edx, 0
    mov ebx, 0
    mov esi, M
    mov edi, R
    ret

get_last_index_value: ; if(size - 1 < j)
    mov edx, ecx ; j = size - 1
    call part_after_index_value
    ret

go_up_pointer_M:
    add esi, 2
    ret

go_up_pointer_R:
    add edi, 2
    ret

go_down_pointer_R:
    sub edi, 2
    ret

set_pointer_M_to_edx_value:
    mov esi, M
    mov ecx, 0
    cmp edx, 1
    jnb setter_loop
    mov ecx, 0
    ret

setter_loop:
    add esi, 2
    inc ecx
    cmp ecx, edx
    jb setter_loop
    ret

second_slave_loop: ;for(; i < j; --j)
    mov bl, [edi]
    mov bl, [esi]
    add [edi], bl ; R[i] += M[j];
    sub edx, 1
    sub esi, 2
    mov bl, [edi]
    cmp eax, edx ;if(i < j)
    jb second_slave_loop  
    call part_main_after_second_slave 
    ret


f_print_massive: ; esi is address of printed massive 
    inc ecx
    mov bl, [esi] ; write from massive to ebx
    call f_print
    add esi, 2; one step
    cmp ecx, size
    jb f_print_massive
    ret 
    
f_print: ; print ebx
    push ebx
    mov ebx, ecx ;save ecx
    push message
    call printf
    add esp, 8
    mov ecx, ebx
    ret


