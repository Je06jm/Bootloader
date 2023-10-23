bits 16
org 0x7c00
jmp 0x0:_start

_start:
    mov byte [disk.drive], dl

    ; Load efi partition table header
    xor ax, ax
    mov es, ax
    mov bx, 0x8000
    mov ah, 0x2
    mov al, 1
    mov cx, 2
    mov dh, 0
    mov dl, byte [disk.drive]
    int 0x13

    jc forever

    ; Load boot1.S
    mov eax, dword [0x8000 + 0x28]
    mov ebx, BOOT1_SIZE
    sub eax, ebx
    inc al
    mov ah, 0x2
    mov ch, 0
    mov cl, al
    mov al, bl
    mov dh, 0,
    mov dl, byte [disk.drive]
    mov bx, 0x8200
    int 0x13

    jc forever

    mov dl, byte [disk.drive]
    jmp 0x8200

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

.skip_incr_sectors:
    mov ah, 0x2
    xor ch, ch
    mov cl, 3

    ;call read_sectors

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
    ;call read_sectors
    ;mov ebx, read_sectors
    jmp 0x8000

.next_partition:
    add eax, dword [0x8000 + 0x54]
    jmp .check_partition

forever:
    hlt
    jmp forever

disk:
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