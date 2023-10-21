bits 16
_begin:
org 0x8000
jmp _start

times 3 - ($ - $$) db 0

; FAT32 BPB
bpb:
.identifier:
db "MSWIN4.1"
.bytes_per_sector:
dw 512
.ignored:
db 0
dw 0
.FAT_count:
db 2
.root_directory_entries:
dw 0
.logical_volume_sectors:
dw 0
.ignored1:
db 0
dw 0
dw 0
dw 0
.hidden_sectors:
dd (_end - _begin) / 512 + 1
.large_sector_count:
dd 0
.sectord_per_FAT:
dd 0
.flags:
dw 0
.FAT_version:
dw 0
.root_cluster_number:
dd 2
.FSInfo_sector:
dw 2
.ignored2:
dw 0
.reserved:
times 12 db 0
.drive_number:
db 0
.reserved1:
db 0
.signature:
db 0x28
.ignored3:
dd 0
.volume_label:
db "EFI        "
.string_identifier:
db "FAT32   "

_start:
    sub eax, 0x10
    mov dword [efi_sector], eax
    mov dword [read_sectors], ebx

error:
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


efi_sector: dd 0

; eax - lba to read
; ebx - pointer to destination
; ecx - number of sectors to read
; mangles - eax, ebx, ecx, edx, edi, esi, bp
read_sectors: dd 0

times 510 - ($ - $$) db 0
dw 0xaa55

_end: