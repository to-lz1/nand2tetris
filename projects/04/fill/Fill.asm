// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed.
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

(LOOP) // infinite loop
@KBD
D=M
@FILL
D;JGT

(CLEAR) // dummy
@i
M=0
(CLEARINNER)
@SCREEN
D=A
@i
D=D+M
@target
M=D
@KBD
D=D-A
@LOOP
D;JGE
@target
A=M
M=0
@i
M=M+1
@CLEARINNER
0;JMP

(FILL)
@i
M=0
(FILLINNER)
@SCREEN
D=A
@i
D=D+M
@target
M=D
@KBD
D=D-A
@LOOP
D;JGE
@target
A=M
M=-1
@i
M=M+1
@FILLINNER
0;JMP
