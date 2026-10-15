section .text
    global _start

_start:
    mov eax, 0x12345678
    mov ebx, 0xCAFEBABE
    mov edx, eax
    mov eax, ebx
    mov ebx, edx

    xchg eax, ebx

    lea edx, [eax]
    lea eax, [ebx]
    lea ebx, [edx]

    push eax
    push ebx
    pop eax
    pop ebx




    mov dx, 0x1A2B
    mov cx, 0x3C4D
    mov bp, dx
    mov dx, cx
    mov cx, bp

    xchg dx, cx

    lea bp, [edx]
    lea dx, [ecx]
    lea cx, [ebp]

    push dx
    push cx
    pop dx
    pop cx




    mov ah, 0x5E
    mov al, 0x7F
    mov ch, ah
    mov ah, al
    mov al, ch

    xchg ah, al

    xchg ch, ah
    movzx eax, al
    movzx ebx, ch
    lea ecx, [eax]
    lea eax, [ebx]
    lea ebx, [ecx]

    push eax
    push ebx
    pop eax
    pop ebx

mov eax, 1
int 0x80
