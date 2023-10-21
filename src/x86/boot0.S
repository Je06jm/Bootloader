bits 16
org 0x7c00
jmp 0x0:_start

_start:
    cli

    mov byte [disk.drive], dl

    xor ax, ax
    mov es, ax
    mov di, ax
    mov ah, 0x08
    int 13
    
    jc forever

    mov byte [disk.heads], dh

    mov al, cl
    and al, 0x1f
    mov byte [disk.sectors], al

    shr cx, 6
    mov al, cl
    shr cx, 2
    shl ax, 8
    mov al, cl

    mov byte [disk.cyliders], al

    ; Load efi partition table header
    xor eax, eax
    inc al
    xor ebx, ebx
    mov bx, 0x8000
    mov ecx, eax
    call read_sectors

    ; Load partitions
    mov eax, dword [0x8000 + 0x50]
    mov ebx, dword [0x8000 + 0x54]
    mul ebx
    xor ebx, ebx
    mov edx, ebx
    mov bx, 512
    div ebx
    or edx, edx

    jz .skip_incr_sectors

    inc eax
    mov ecx, eax

.skip_incr_sectors:

    mov eax, dword [0x8000 + 0x48]
    mov ebx, 0x8200
    call read_sectors

    ; Search partitions
.find_efi_partition:
    mov ebx, efi_signature
.check_partition:
    mov cl, 16
    mov eax, 0x8200
.compare_sigatures:
    mov dl, byte [eax]
    cmp dl, byte [ebx]
    jne .next_partition
    inc eax
    inc ebx
    dec cl
    or cl, cl
    jnz .compare_sigatures

    mov esi, eax
    mov eax, [esi + 0x10]
    mov ebx, 0x8000
    xor ecx, ecx
    inc ecx
    call read_sectors
    mov ebx, read_sectors
    jmp 0x8000

.next_partition:
    add eax, dword [0x8000 + 0x54]
    jmp .check_partition

; eax - lba to read
; ebx - pointer to destination
; ecx - number of sectors to read
; mangles - eax, ebx, ecx, edx, edi, esi, bp
read_sectors:
    ; Calculate the CHS
    push ecx
    mov edi, ebx

    push eax

    ; Calculate C
    xor eax, eax
    mov al, byte [disk.cyliders]
    xor ebx, ebx
    mov bl, byte [disk.sectors]

    mul ebx
    mov ebx, eax
    mov eax, dword [esp+4]
    xor edx, edx

    div ebx
    mov cx, ax
    shl ecx, 16

    ; Calculate H
    mov eax, dword [esp+4]
    
    xor edx, edx
    div ebx

    mov bl, byte [disk.heads]
    div ebx
    
    mov ch, dl

    ; Calculate S
    pop eax
    mov bl, byte [disk.sectors]
    xor edx, edx
    div ebx
    inc eax

    mov ah, ch
    shr ecx, 16
    mov ch, al
    shl ecx, 16
    mov ch, ah
    mov cl, al

    pop esi

.read_loop:
    push ecx
    push edi
    push esi
    mov eax, esi
    and eax, 0xff
    mov ebx, edi
    mov ah, 0x2
    mov edx, ecx
    shr edx, 8
    mov dl, [disk.drive]

    push ebx
    xor bx, bx
    shr ebx, 4
    mov es, bx
    pop ebx
    and ebx, 0xffff

    int 0x13
    pop esi
    pop edi
    pop ecx
    
    jc forever

    xor ebx, ebx
    mov bl, al
    sub edi, ebx
    add esi, ebx

    add ecx, ebx

    cmp cl, byte [disk.sectors]
    jl .next_loop

    sub cl, byte [disk.sectors]
    inc ch

    cmp ch, byte [disk.cyliders]
    jl .next_loop

    sub ch, byte [disk.cyliders]
    mov eax, ecx
    shr eax, 16
    inc eax
    shl eax, 16
    mov ax, cx
    mov ecx, eax

.next_loop:
    or edi, edi
    jnz .read_loop
    ret


forever:
    hlt
    jmp forever

disk:
.cyliders: db 1
.heads: db 1
.sectors: db 1
.drive: db 1

efi_signature: db 0xc1, 0x2a, 0x73, 0x28, 0xf8, 0x1f, 0x11, 0xd2, 0xba, 0x4b, 0x00, 0xa0, 0xc9, 0x3e, 0xc9, 0x3b

times 0x1b8 - ($ - $$) db 0

MBR:
.disk_id:
dd 0
dw 0
.first_drive_attributes:
db 0
.first_drive_starting_chs:
db 0x0, 0x2, 0x0
.first_drive_os_type:
db 0xee
.first_drive_ending_chs:
db 0xff, 0xff, 0xff
.first_drive_starting_lba:
dd 0x1
.first_drive_ending_lba:
dd 0xffffffff
.second_drive:
times 0x10 db 0
.third_drive:
times 0x10 db 0
.fourth_drive:
times 0x10 db 0

dw 0xaa55