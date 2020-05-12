.model small
.186
.stack 100
.data
mouseerror  db 'Mouse INIT Error', 13, 10, '$'
mousepos    db 'Mouse Position X:     Y:     Button:   $'
.code

PRINT_NUMBER PROC NEAR ; function is from: https://stackoverflow.com/questions/15621258/assembly-printing-ascii-number
    pusha              ; I just removed the HelloWorld, and comments from it, and formatted slightly.
    push bp     
    mov bp, sp; 
    sub sp, 3*8 
    mov WORD PTR [bp - 2*8], ax
    mov BYTE PTR [bp - 3*8], 0
    getDigits:
        mov ax, WORD PTR [bp - 2*8]
        mov dx, 0
        mov bx, 10
        div bx
        push dx
        mov WORD PTR[bp - 2*8], ax
        inc byte PTR[bp - 3*8]
        cmp WORD PTR[bp - 2*8], 0
        je getDigitsEnd
        jmp getDigits
    getDigitsEnd:

    printDigits:
        cmp BYTE PTR[bp - 3*8], 0
        je printDigitsEnd
        pop ax
        add al, 30h
        mov ah, 0eh
        int 10h
        dec BYTE PTR[bp - 3*8]
        jmp printDigits
    printDigitsEnd:
    mov sp, bp
    pop bp
    popa
    ret

PRINT_NUMBER ENDP

start:
        call cls         ; clear screen
        mov ax, @data    ; memory address of data to ax
        mov ds, ax       ; memory address to data segment
        mov ah, 9h       ; String to STDOut
        lea dx, mousepos ; Load effective address of mousepos to dx
        int 21h          ; write out the string
        mov ax, 0h       ; init mouse
        int 33h          ; call mouse interrupt
        cmp ax, 0        ; check, if ax=0, then mouse not loaded
        jz error         ; if mouse failed, goto error handling
        mov ax, 1h       ; display cursor
        int 33h          ; call mouse interrupt
    egerpoll:
        mov ax, 3       ; get mouse parameters (X, Y, Button)
        int 33h         ; call mouse interrupt
        pusha           ; save all registers
        mov dh, 0       ; cursor Y (row) to 0
        mov dl, 18      ; cursor X (collumn) to 18
        mov bh, 0       ; page to 0
        mov ah, 2       ; set the cursor
        int 10h         ; call DOS interrupt to set cursor
        popa            ; restore registers
        mov ax, cx      ; mouse X position to ax
        call PRINT_NUMBER ; call decimal printout function
        pusha           ; save all registers
        mov dh, 0       ; cursor Y to 0
        mov dl, 25      ; cursor X to 25
        mov bh, 0       ; page 0
        mov ah, 2       ; set the cursor
        int 10h         ; call DOS interrupt to set cursor
        popa            ; restore registers
        mov ax, dx      ; mouse Y position to ax
        call PRINT_NUMBER ; call decimal printout function
        pusha           ; save all registers
        mov dh, 0       ; cursor Y to 0
        mov dl, 37      ; cursor X to 37
        mov bh, 0       ; page 0
        mov ah, 2       ; set the cursor
        int 10h         ; call DOS interrupt to set cursor
        popa            ; restore registers
        mov ax, bx      ; mouse Button to ax
        call PRINT_NUMBER ; call decimal printout function
        cmp bx, 3       ; check if both button pressed
        jnz egerpoll    ; if not, loop
        jmp vege        ; if both pressed, jump to end

    error:
        mov ax, @data   ; memory address of data to ax
        mov ds, ax      ; memory address to data segment
        mov ah, 9h      ; string to STDOut
        lea dx, mouseerror ; load effective address of mouseerror to dx
        int 21h         ; call DOS interrupt to print out the string
    vege:
        mov ax, 03h     ; set the video mode to 80x25 (standard DOS videomode)
        int 10h         ; call it
        mov ax, 4c00h   ; exit program
        int 21h         ; call DOS interrupt to exit

    cls:
        push ax         ; save AX
        mov ax, 12h     ; set videomode to 12h (640x480x256color, VGA mode)
        int 10h         ; call dos interrupt to set videomode
        pop ax          ; restore AX
        ret             ; return

end start