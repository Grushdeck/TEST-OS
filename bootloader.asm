;======================================
; File name: bootloader.asm
; Project: TEST-OS
; Author: Copyright (c) 2026 Grushdeck
; Description: Bootloader
;======================================

[bits 16]
[org 0x7c00]

jmp short start
nop
bdb_oem:                    db "TEST4"
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 224
bdb_total_sectors:          dw 2880
bdb_media_descriptor_type:  db 0xF0
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sectors:          dd 0

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00


    mov ah, 0x02
    mov al, 15
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov bx, 0x1000
    int 0x13

    jc disk_error
    jmp 0x0000:0x1000

disk_error:
    mov ah, 0x0e
    mov al, '!'
    int 0x10
    jmp $

times 510-($-$$) db 0
dw 0xaa55
