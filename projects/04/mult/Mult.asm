// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
//
// This program only needs to handle arguments that satisfy
// R0 >= 0, R1 >= 0, and R0*R1 < 32768.

// @R0
// D=A
// @a
// M=D
// @R1
// D=A
// @b
// M=D
@i
M=1
@R2
M=0
(LOOP)
@i // if i > b goto END
D=M
@R1
D=D-M
@END
D;JGT
@R0
D=M
@R2
M=D+M
@i // i++
M=M+1
@LOOP // goto LOOP
0;JMP
(END) // infinite loop
@END
0;JMP
