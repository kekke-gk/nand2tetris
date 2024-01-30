// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen
// by writing 'black' in every pixel;
// the screen should remain fully black as long as the key is pressed.
// When no key is pressed, the program clears the screen by writing
// 'white' in every pixel;
// the screen should remain fully clear as long as no key is pressed.

@current            // @current=0: white, @current=-1: black
M=0
(LOOP)
    @current
    D=M
    @LOOP1
    D;JNE
    (LOOP0)
        @KBD
        D=M
        @COLOR
        D;JNE       // @current=0 and key pushed => blacken
        @LOOP
        0;JMP
    (LOOP1)
        @KBD
        D=M
        @COLOR
        D;JEQ       // @current=-1 and key released => whiten
        @LOOP
        0;JMP

(COLOR)
    @current
    M=!M           // toggle @current
    @i
    M=0
    (COLORLOOP)
        @8192
        D=A
        @i
        D=D-M
        @LOOP
        D;JEQ
        @i
        D=M
        @SCREEN
        D=A+D
        @R0
        M=D
        @current
        D=M
        @R0
        A=M
        M=D
        @i 
        M=M+1
        @COLORLOOP
        0;JMP
