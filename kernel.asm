[bits 16]
[org 0x1000]

kernel_start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    
	
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x02
    int 0x10

    call clear_screen
    call draw_ui
    mov si, welcome_msg
    call print_string

shell_loop:
    mov si, prompt
    call print_string
    mov di, input_buffer
    call get_string

    mov si, input_buffer
    

    mov di, cmd_ls
    call str_compare
    jc do_ls

    mov di, cmd_dir
    call str_compare
    jc do_ls

    mov di, cmd_fetch
    call str_compare
    jc do_fetch

    mov di, cmd_clear
    call str_compare
    jc do_clear

    mov di, cmd_help
    call str_compare
    jc do_help
    
    mov di, cmd_reboot
    call str_compare
    jc do_reboot
    
    mov di, cmd_date
    call str_compare
    jc do_date
    
    mov di, cmd_time
    call str_compare
    jc do_time
    
    mov di, cmd_mem
    call str_compare
    jc do_mem
    
    mov di, cmd_beep
    call str_compare
    jc do_beep
    
    mov di, cmd_echo
    call str_compare
    jc do_echo
    
    mov di, cmd_matrix
    call str_compare
    jc do_matrix
    
    mov di, cmd_ascii
    call str_compare
    jc do_ascii
    
    mov di, cmd_cpu
    call str_compare
    jc do_cpu
    
    mov di, cmd_osinfo
    call str_compare
    jc do_osinfo
    
    mov di, cmd_credits
    call str_compare
    jc do_credits
    
    mov di, cmd_calc
    call str_compare
    jc do_calc
    
    mov di, cmd_hex
    call str_compare
    jc do_hex
    
    mov di, cmd_bin
    call str_compare
    jc do_bin
    
    mov di, cmd_clock
    call str_compare
    jc do_clock
    
    mov di, cmd_banner
    call str_compare
    jc do_banner
    
    mov di, cmd_pwd
    call str_compare
    jc do_pwd
    
    mov di, cmd_whoami
    call str_compare
    jc do_whoami

    mov al, [input_buffer]
    test al, al
    jz shell_loop

    mov si, unknown_msg
    call print_string
    jmp shell_loop


do_ls:
    mov si, dir_header
    call print_string
    mov si, fat_files
    call print_string
    jmp shell_loop

do_fetch:
    mov si, fetch_art
    call print_string
    jmp shell_loop

do_clear:
    call clear_screen
    call draw_ui
    jmp shell_loop

do_help:
    mov si, help_msg
    call print_string
    jmp shell_loop

do_reboot:
    mov si, reboot_msg
    call print_string
    mov ax, 0x0000
    mov ds, ax
    mov word [0x0472], 0x1234
    jmp 0xffff:0x0000

do_date:
    call show_date
    jmp shell_loop

do_time:
    call show_time
    jmp shell_loop

do_mem:
    call show_memory
    jmp shell_loop

do_beep:
    call do_beep_sound
    jmp shell_loop

do_echo:
    call echo_command
    jmp shell_loop

do_matrix:
    call matrix_effect
    jmp shell_loop

do_ascii:
    call ascii_table
    jmp shell_loop

do_cpu:
    mov si, cpu_msg
    call print_string
    jmp shell_loop

do_osinfo:
    mov si, osinfo_msg
    call print_string
    jmp shell_loop

do_credits:
    mov si, credits_msg
    call print_string
    jmp shell_loop

do_calc:
    call calculator
    jmp shell_loop

do_hex:
    call hex_converter
    jmp shell_loop

do_bin:
    call bin_converter
    jmp shell_loop

do_clock:
    call digital_clock
    jmp shell_loop

do_banner:
    call show_banner
    jmp shell_loop

do_pwd:
    mov si, pwd_msg
    call print_string
    jmp shell_loop

do_whoami:
    mov si, whoami_msg
    call print_string
    jmp shell_loop


clear_screen:
    mov ax, 0x0003
    int 0x10
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x02
    int 0x10
    ret

draw_ui:
    mov si, ui_top
    call print_string
    ret

print_string:
    mov ah, 0x0e
    mov bh, 0x00
    mov bl, 0x02
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

print_string_white:
    mov ah, 0x0e
    mov bh, 0x00
    mov bl, 0x07
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

get_string:
    xor cx, cx
.loop:
    mov ah, 0x00
    int 0x16
    cmp al, 13
    je .done
    cmp al, 8
    je .backspace
    stosb
    mov ah, 0x0e
    int 0x10
    inc cx
    jmp .loop
.backspace:
    test cx, cx
    jz .loop
    dec cx
    dec di
    mov ah, 0x0e
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .loop
.done:
    mov al, 0
    stosb
    mov si, newline
    call print_string
    ret

str_compare:
    pusha
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .diff
    test al, al
    jz .match
    inc si
    inc di
    jmp .loop
.diff:
    popa
    clc
    ret
.match:
    popa
    stc
    ret

show_date:
    mov si, date_msg
    call print_string
    ret

show_time:
    mov ah, 0x2C
    int 0x21
    mov si, time_msg
    call print_string
    ret

show_memory:
    mov si, mem_msg
    call print_string
    ret

do_beep_sound:
    mov si, beep_msg
    call print_string
    mov ah, 0x0e
    mov al, 0x07
    int 0x10
    ret

echo_command:
    mov si, input_buffer
    add si, 5
    call print_string
    mov si, newline
    call print_string
    ret

matrix_effect:
    call clear_screen
    mov cx, 500
    mov si, matrix_chars
matrix_loop:
    mov ah, 0x0e
    lodsb
    test al, al
    jnz .print
    mov si, matrix_chars
    lodsb
.print:
    int 0x10
    loop matrix_loop
    call wait_key
    call clear_screen
    ret

ascii_table:
    call clear_screen
    mov si, ascii_header
    call print_string
    mov cx, 32
    mov si, ascii_buffer
ascii_loop:
    mov al, cl
    call print_hex_byte
    mov al, ' '
    call print_char
    mov al, cl
    call print_char
    mov al, ' '
    int 0x10
    inc cx
    test cx, 0x07
    jnz .continue
    mov si, newline
    call print_string
.continue:
    cmp cx, 255
    jne ascii_loop
    mov si, newline
    call print_string
    call wait_key
    call clear_screen
    ret

calculator:
    mov si, calc_msg
    call print_string
calc_loop:
    mov si, calc_prompt
    call print_string
    mov di, calc_buffer
    call get_string
    mov si, calc_buffer
    mov al, [si]
    cmp al, 'q'
    je calc_done
    call calculate
    jmp calc_loop
calc_done:
    ret

calculate:
    mov si, calc_result
    call print_string
    ret

hex_converter:
    mov si, hex_msg
    call print_string
    mov di, hex_buffer
    call get_string
    mov si, hex_buffer
    call print_hex_string
    mov si, newline
    call print_string
    ret

bin_converter:
    mov si, bin_msg
    call print_string
    mov di, bin_buffer
    call get_string
    mov si, bin_buffer
    call print_bin_string
    mov si, newline
    call print_string
    ret

digital_clock:
    call clear_screen
    mov si, clock_msg
    call print_string
clock_loop:
    mov ah, 0x2C
    int 0x21
    mov si, clock_buffer
    call print_string
    call wait_second
    jmp clock_loop
    ret

show_banner:
    call clear_screen
    mov si, banner_msg
    call print_string_white
    call wait_key
    call clear_screen
    ret

wait_key:
    mov ah, 0x00
    int 0x16
    ret

wait_second:
    mov cx, 0xFFFF
.delay:
    loop .delay
    ret

print_char:
    mov ah, 0x0e
    int 0x10
    ret

print_hex_byte:
    pusha
    mov ah, al
    shr al, 4
    add al, '0'
    cmp al, '9'
    jle .digit1
    add al, 7
.digit1:
    mov ah, 0x0e
    int 0x10
    popa
    mov al, ah
    and al, 0x0F
    add al, '0'
    cmp al, '9'
    jle .digit2
    add al, 7
.digit2:
    mov ah, 0x0e
    int 0x10
    ret

print_hex_string:
    pusha
.hex_loop:
    lodsb
    test al, al
    jz .hex_done
    call print_hex_byte
    mov al, ' '
    call print_char
    jmp .hex_loop
.hex_done:
    popa
    ret

print_bin_string:
    pusha
.bin_loop:
    lodsb
    test al, al
    jz .bin_done
    call print_bin_byte
    mov al, ' '
    call print_char
    jmp .bin_loop
.bin_done:
    popa
    ret

print_bin_byte:
    pusha
    mov cx, 8
    mov ah, al
.bin_bit:
    shl ah, 1
    mov al, '0'
    jnc .bit0
    mov al, '1'
.bit0:
    call print_char
    loop .bin_bit
    popa
    ret

cmd_reboot    db "reboot", 0
cmd_date      db "date", 0
cmd_time      db "time", 0
cmd_mem       db "mem", 0
cmd_beep      db "beep", 0
cmd_echo      db "echo", 0
cmd_matrix    db "matrix", 0
cmd_ascii     db "ascii", 0
cmd_cpu       db "cpu", 0
cmd_osinfo    db "osinfo", 0
cmd_credits   db "credits", 0
cmd_calc      db "calc", 0
cmd_hex       db "hex", 0
cmd_bin       db "bin", 0
cmd_clock     db "clock", 0
cmd_banner    db "banner", 0
cmd_pwd       db "pwd", 0
cmd_whoami    db "whoami", 0


help_msg      db "¦==========================================================¦", 13, 10
              db "¦  UNIX-16 COMMANDS                                        ¦", 13, 10
              db "¦==========================================================¦", 13, 10
              db "¦  ls/dir   - show files                                   ¦", 13, 10
              db "¦  fetch    - OS info                                      ¦", 13, 10
              db "¦  clear    - clear screen                                 ¦", 13, 10
              db "¦  help     - this help                                    ¦", 13, 10
              db "¦  reboot   - restart system                               ¦", 13, 10
              db "¦  date     - show date                                    ¦", 13, 10
              db "¦  time     - show time                                    ¦", 13, 10
              db "¦  mem      - memory info                                  ¦", 13, 10
              db "¦  beep     - sound beep                                   ¦", 13, 10
              db "¦  echo     - print text                                   ¦", 13, 10
              db "¦  matrix   - falling code effect                          ¦", 13, 10
              db "¦  ascii    - ASCII table                                  ¦", 13, 10
              db "¦  calc     - simple calculator                            ¦", 13, 10
              db "¦  hex      - hex converter                                ¦", 13, 10
              db "¦  bin      - binary converter                             ¦", 13, 10
              db "¦  clock    - digital clock                                ¦", 13, 10
              db "¦  banner   - cool ASCII art                               ¦", 13, 10
              db "¦  cpu      - CPU info                                     ¦", 13, 10
              db "¦  osinfo   - OS information                               ¦", 13, 10
              db "¦  credits  - show credits                                 ¦", 13, 10
              db "¦----------------------------------------------------------¦", 13, 10, 0

date_msg      db "Date: 2026-04-12", 13, 10, 0
time_msg      db "Time: ", 0
mem_msg       db "Memory: 640KB Conventional / 16MB Extended", 13, 10, 0
beep_msg      db "d", 13, 10, 0
reboot_msg    db "REBOOTING...", 13, 10, 0
unknown_msg   db "Command not found. Type 'help'", 13, 10, 0

calc_msg      db "CALCULATOR - Type 'q' to quit", 13, 10, 0
calc_prompt   db "calc> ", 0
calc_result   db "Result: 42", 13, 10, 0
calc_buffer   times 32 db 0

hex_msg       db "HEX CONVERTER - Enter number: ", 0
bin_msg       db "BIN CONVERTER - Enter number: ", 0
hex_buffer    times 16 db 0
bin_buffer    times 16 db 0

clock_msg     db "DIGITAL CLOCK - Press any key to exit", 13, 10, 0
clock_buffer  db "00:00:00", 13, 10, 0

cpu_msg       db "CPU: Intel 8086 compatible", 13, 10
              db "Mode: 16-bit Real Mode", 13, 10
              db "Speed: ~4.77 MHz", 13, 10, 0

osinfo_msg    db "OS: Unix-16 v2.0", 13, 10
              db "Architecture: 16-bit x86", 13, 10
              db "Filesystem: FAT12", 13, 10
              db "Shell: Unix-16 CLI", 13, 10, 0

credits_msg   db "¦================================================¦", 13, 10
              db "¦                    CREDITS                     ¦", 13, 10
              db "¦================================================¦", 13, 10
              db "¦  OS Name: TEST OS v4.0                         ¦", 13, 10
              db "¦  Language: NASM Assembly                       ¦", 13, 10
              db "¦  Made by: MrCode                               ¦", 13, 10
              db "¦================================================¦", 13, 10, 0

pwd_msg       db "A:\", 13, 10, 0
whoami_msg    db "root", 13, 10, 0

banner_msg    db "==========================================================", 13, 10
              db "  --------¬-------¬-------¬--------¬     ------¬ -------¬ ", 13, 10
              db "  L==--ã==---ã====---ã====-L==--ã==-    --ã===--¬--ã====- ", 13, 10
              db "     --¦   -----¬  -------¬   --¦       --¦   --¦-------¬ ", 13, 10
              db "     --¦   --ã==-  L====--¦   --¦       --¦   --¦L====--¦ ", 13, 10
			  db "     --¦   -------¬-------¦   --¦       L------ã--------¦ ", 13, 10
              db "     L=-   L======-L======-   L=-        L=====- L======- ", 13, 10
              db "                                                          ", 13, 10
              db "                |OPERATING SYSTEM v4.0|                   ", 13, 10
              db "        ======================================            ", 13, 10
              db "        =        |16-bit Real Mode |         =            ", 13, 10
              db "        ======================================            ", 13, 10
			  db "==========================================================", 13, 10, 0

ascii_header  db "DEC HEX CHR  DEC HEX CHR  DEC HEX CHR  DEC HEX CHR", 13, 10
              db "==================================================", 13, 10, 0
ascii_buffer  times 4 db 0

matrix_chars  db "01", 0

ui_top        db " [ Unix-16 v4.0 - BIOS Style Interface ] ", 13, 10
              db "===========================================", 13, 10, 0
welcome_msg   db " System ready. Type 'help' for commands.", 13, 10, 0
prompt        db "# ", 0
newline       db 13, 10, 0

cmd_ls        db "ls", 0
cmd_dir       db "dir", 0
cmd_fetch     db "fetch", 0
cmd_clear     db "clear", 0
cmd_help      db "help", 0

dir_header    db " Volume in drive A is UNIX-16", 13, 10
              db " Volume Serial Number is 16D2-0412", 13, 10
              db " Directory of A:\ ", 13, 10
              db 13, 10, 0
fat_files     db "KERNEL   SYS   8,192  04-12-26  12:00p", 13, 10
              db "COMMAND  COM     512  04-12-26  12:00p", 13, 10
              db "CONFIG   SYS      64  04-12-26  12:00p", 13, 10
              db "AUTOEXEC BAT      32  04-12-26  12:00p", 13, 10
              db "README  TXT     128  04-12-26  12:00p", 13, 10
              db 13, 10
              db "       5 file(s)      8,928 bytes", 13, 10
              db "                         free", 13, 10, 0

fetch_art     db "  --------¬-------¬-------¬--------¬     ------¬ -------¬        ", 13, 10
              db "  L==--ã==---ã====---ã====-L==--ã==-    --ã===--¬--ã====-        ", 13, 10
              db "     --¦   -----¬  -------¬   --¦       --¦   --¦-------¬        ", 13, 10
              db "     --¦   --ã==-  L====--¦   --¦       --¦   --¦L====--¦        ", 13, 10
              db "     --¦   -------¬-------¦   --¦       L------ã--------¦        ", 13, 10
              db "     L=-   L======-L======-   L=-        L=====- L======-    v4.0", 13, 10, 0

input_buffer times 128 db 0