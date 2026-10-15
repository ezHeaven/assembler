section .data
    out_name db "output.txt", 0

    hdr_even db 10, "--- EVEN NUMBERS (0-127) ---", 10
    hdr_even_len equ $ - hdr_even

    hdr_odd db 10, "--- ODD NUMBERS (128-255) ---", 10
    hdr_odd_len equ $ - hdr_odd

    hdr_big db 10, "--- NUMBERS >= 50000 (256-383) ---", 10
    hdr_big_len equ $ - hdr_big

    hdr_small db 10, "--- NUMBERS < 10000 (384-511) ---", 10
    hdr_small_len equ $ - hdr_small

section .bss
    tv resd 2
    seed resd 1
    buffer resw 512
    cnt_even resb 1  ; even numbers (0-127)
    cnt_odd resb 1   ; odd numbers (128-255)
    cnt_big resb 1   ; numbers >= 50000 (256-383)
    cnt_small resb 1 ; numbers < 10000 (384-511)

    file_fd resd 1
    numbuf resb 8

section .text
    global _start

_start:
    ; gettimeofday
    mov eax, 78
    mov ebx, tv
    xor ecx, ecx
    int 0x80

    ; seed from time
    mov eax, [tv]
    rol eax, 5
    add eax, [tv+4]
    xor eax, 0x5A5A5A5A
    mov [seed], eax

    ; reset all four counters at once
    mov dword [cnt_even], 0

gen_loop:
    call rand_next
    test al, 1
    jnz store_odd

store_even:
    movzx edx, byte [cnt_even]
    mov [buffer+edx*2], ax
    inc byte [cnt_even]
    jmp range_check

store_odd:
    movzx edx, byte [cnt_odd]
    mov [buffer+edx*2+256], ax
    inc byte [cnt_odd]

range_check:
    cmp eax, 50000
    jb check_small

    movzx edx, byte [cnt_big]
    mov [buffer+edx*2+512], ax
    inc byte [cnt_big]
    jmp limits_check

check_small:
    cmp eax, 10000
    jae limits_check

    movzx edx, byte [cnt_small]
    mov [buffer+edx*2+768], ax
    inc byte [cnt_small]

limits_check:
    cmp byte [cnt_even], 127
    ja output
    cmp byte [cnt_odd], 127
    ja output
    cmp byte [cnt_big], 127
    ja output
    cmp byte [cnt_small], 127
    ja output

    jmp gen_loop

output:
    ; open(output.txt, O_WRONLY|O_CREAT|O_TRUNC, 0644)
    mov eax, 5
    mov ebx, out_name
    mov ecx, 0x241
    mov edx, 420
    int 0x80
    mov [file_fd], eax

    ; even
    mov ecx, hdr_even
    mov edx, hdr_even_len
    call out
    movzx ecx, byte [cnt_even]
    mov esi, buffer
    call print_block

    ; odd
    mov ecx, hdr_odd
    mov edx, hdr_odd_len
    call out
    movzx ecx, byte [cnt_odd]
    lea esi, [buffer+256]
    call print_block

    ; >= 50000
    mov ecx, hdr_big
    mov edx, hdr_big_len
    call out
    movzx ecx, byte [cnt_big]
    lea esi, [buffer+512]
    call print_block

    ; < 10000
    mov ecx, hdr_small
    mov edx, hdr_small_len
    call out
    movzx ecx, byte [cnt_small]
    lea esi, [buffer+768]
    call print_block

    ; close
    mov eax, 6
    mov ebx, [file_fd]
    int 0x80

    ; exit(0)
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_block:
    jecxz block_done
    push ecx
    push esi
    movzx eax, word [esi]
    call num_to_str
    pop esi
    pop ecx
    add esi, 2
    dec ecx
    jmp print_block
block_done:
    ret

num_to_str:
    mov edi, numbuf+7
    mov byte [edi], ' '
    mov ebx, 10
digit_loop:
    dec edi
    xor edx, edx
    div ebx
    or dl, 0x30
    mov [edi], dl
    test eax, eax
    jnz digit_loop

    mov edx, numbuf+8
    sub edx, edi
    mov ecx, edi
    call out
    ret

out:
    push edx
    push ecx
    ; to stdout
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ecx
    pop edx
    ; to file
    mov eax, 4
    mov ebx, [file_fd]
    int 0x80
    ret

rand_next:
    mov eax, [seed]
    imul eax, 1664525
    add eax, 1013904223
    mov [seed], eax
    shr eax, 16
    ret
