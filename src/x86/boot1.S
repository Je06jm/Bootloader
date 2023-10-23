bits 16
_begin:
org 0x8200

_start:
    mov byte [disk.drive], dl

    ; Enable A20
    mov ax, 0x2403
    int 0x15
    mov ebp, bios_error.a20
    jc bios_error
    cmp ah, 0
    jne bios_error
    
    mov ax, 0x2402
    int 0x15
    mov ebp, bios_error.a20
    jc bios_error
    cmp ah, 0
    jne bios_error

    cmp al, 1
    je .a20_active

    mov ax, 0x2401
    int 0x15
    mov ebp, bios_error.a20
    jc bios_error
    cmp ah, 0
    jne bios_error

.a20_active:
    ; Get memory map
    mov di, memory_map
    xor ebx, ebx
    mov edx, 0x534d4150
    mov eax, 0xe820

    mov eax, 0xe820
    mov ecx, 024
    int 0x15
    mov ebp, bios_error.memory_map
    jc bios_error
    
.get_memory_map:
    mov eax, 0xe820
    mov ecx, 024
    int 0x15
    add di, 24
    or bx, bx
    jz .enter_protected_mode
    jnc .get_memory_map

.enter_protected_mode:
    xchg bx, bx
    ; Enable protected mode

    cli

    in al, 0x70
    or al, 0x80
    out 0x70, al

    sgdt [GDT.bios_ptr]
    lgdt [GDT.ptr]

    mov ax, cs
    mov word [GDT.bios_cs], ax
    
    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp 0x08:_protected_start

bios_read_sectors:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

bios_error:
    xor ch, ch
    mov cl, byte [ebp]
    inc bp
    xor al, al
    xor bh, bh
    mov bl, 0x07
    xor cx, cx
    mov es, cx
    int 0x13

.forever:
    hlt
    jmp .forever

.a20: db 29, "Could not enable the A20 line"
.memory_map: db 37, "Could not get the system's memory map"

disk:
.drive: db 0

memory_map:
times 16 * 24 db 0

align 16
GDT:
.null: dq 0
.kcode32:
    dw 0xffff
    dw 0
    db 0
    db 0b10011010
    db 0b11001111
    db 0
.kdata32:
    dw 0xffff
    dw 0
    db 0
    db 0b10010010
    db 0b11001111
    db 0
.kcode16:
    dw 0xffff
    dw 0
    db 0
    db 0b10011010
    db 0b00001111
    db 0
.kdata16:
    dw 0xffff
    dw 0
    db 0
    db 0b10010010
    db 0b00001111
    db 0
.ptr:
    dw GDT.ptr - GDT - 1
    dd GDT
.bios_ptr:
    dw 0
    dd 0
.bios_cs:
    dw 0

bits 32
_protected_start:
    xchg bx, bx
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    xor eax, eax
    mov eax, dword [eax]
    nop