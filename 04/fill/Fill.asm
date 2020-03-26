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

// Put your code here.
 

//lastval = 0
@lastval
M=0


//fill = 0
@fill
M=0


//add = SCREEN
@SCREEN
D=A
@addr
M=D

//end = SCREEN + 8192
@8192
D=A
@addr
D=M+D
@end
M=D

(LOOP)
//if(add[KBD] != 0)
@KBD
D=M
@NOKEY
D;JEQ

@lastval
D=M
M=1
@SETSCREEN
D-1;JEQ

@SCREEN
D=A
@addr
M=D

@fill
M=-1

@SETSCREEN
0;JMP

//  if(lastval == 0) {add = SCREEN; fill = -1;}
//  if(lastval == 1) {add =SCREEN; fill = 0;}
(NOKEY)
@lastval
D=M
M=0
@SETSCREEN
D;JEQ

@SCREEN
D=A
@addr
M=D

@fill
M=0

(SETSCREEN)
//if(addr < end)
// {M[addr] = fill; add +=1;}
@addr
D=M
@end
D=M-D
@LOOP
D;JLE

@fill
D=M
@addr
A=M
M=D
@addr
M=M+1

@LOOP
0;JMP
 



