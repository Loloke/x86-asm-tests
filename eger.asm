.model small
.186
.stack 100
.data
mouseerror  db 'Mouse INIT Error', 13, 10, '$'
mousepos    db 'Mouse Position X:     Y:     Button:   $'
.code

PRINT_NUMBER PROC NEAR  
    pusha       ; Save all general purpose registers
    push bp     ; We're going to change that.
    mov bp, sp; ; bp := address of the top of a stack
    sub sp, 3*8 ; allocate 3 bytes on stack. Addresses of variables will be
    mov WORD PTR [bp - 2*8], ax ; number = ax;
    mov BYTE PTR [bp - 3*8], 0  ; digitsCount = 0;
    getDigits:          ; do
        mov ax, WORD PTR [bp - 2*8]; number/10: ax = number / 10, dx: number % 10
        mov dx, 0
        mov bx, 10
        div bx
        push dx         ; push number%10
        mov WORD PTR[bp - 2*8], ax; number = number/10;
        inc byte PTR[bp - 3*8]  ; digitsCount++;
        cmp WORD PTR[bp - 2*8], 0; compare number and 0
        je getDigitsEnd     ; if number == 0 goto getDigitsEnd
        jmp getDigits       ; goto getDigits;
    getDigitsEnd:

    printDigits:
        cmp BYTE PTR[bp - 3*8], 0; compare digits count and 0
        je printDigitsEnd   ; if digitsCount == 0 goto printDigitsEnd

        pop ax          ; pop digit into al
        add al, 30h     ; get character from digit into al

        mov ah, 0eh     ; wanna print digit!
        int 10h         ; BIOS, do it!

        dec BYTE PTR[bp - 3*8]  ; digitsCount--

        jmp printDigits     ; goto printDigits
    printDigitsEnd:

    mov sp, bp
    pop bp
    popa
    ret

PRINT_NUMBER ENDP

start:
        call cls
        mov ax, @data
        mov ds, ax
        mov ah, 9h
        lea dx, mousepos
        int 21h
        mov ax, 0h      ; init mouse
        int 33h
        cmp ax, 0
        jz error        ; if mouse failed, goto error handling
        mov ax, 1h      ; display cursor
        int 33h
    egerpoll:
        mov ax, 3       ; poll the mouse driver
        int 33h
        pusha
        mov dh, 0
        mov dl, 18
        mov bh, 0
        mov ah, 2
        int 10h
        popa
        mov ax, cx
        call PRINT_NUMBER
        pusha
        mov dh, 0
        mov dl, 25
        mov bh, 0
        mov ah, 2
        int 10h
        popa
        mov ax, dx
        call PRINT_NUMBER
        pusha
        mov dh, 0
        mov dl, 37
        mov bh, 0
        mov ah, 2
        int 10h
        popa
        mov ax, bx
        call PRINT_NUMBER
        cmp bx, 3       ; check if both button pressed
        jnz egerpoll    ; if not, loop
        jmp vege

    error:
        mov ax, @data
        mov ds, ax
        mov ah, 9h
        lea dx, mouseerror
        int 21h
    vege:
        mov ax, 03h
        int 10h
        mov ax, 4c00h
        int 21h

    cls:
        push ax
        mov ax, 12h
        int 10h
        pop ax
        ret

end start