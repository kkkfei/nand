//function SimpleFunction.test 2
@SP
A=M
M=0
@SP
M=M+1    
@SP
A=M
M=0
@SP
M=M+1    
//push local 0
//--------push------
@0
D=A             
@LCL
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
//--------end push------

//push local 1
//--------push------
@1
D=A             
@LCL
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
//--------end push------

//add
//add            
@SP
M=M-1
A=M
D=M
A=A-1
M=D+M
//not
//not            
@SP
A=M
A=A-1
M=!M
//push argument 0
//--------push------
@0
D=A             
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
//--------end push------

//add
//add            
@SP
M=M-1
A=M
D=M
A=A-1
M=D+M
//push argument 1
//--------push------
@1
D=A             
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
//--------end push------

//sub
//sub
@SP
M=M-1
A=M
D=M
A=A-1
M=M-D
//return
//Save return addr in R14
//Save return value addr in R15
@ARG
D=M
@R15
M=D
@LCL
A=M-1
D=A
@R13 
M=D
//Restore THAT
A=D
D=M
@THAT
M=D
//Restore THIS
@R13
AM=M-1
D=M
@THIS
M=D
//Restore ARG
@R13
AM=M-1
D=M
@ARG
M=D
//Restore LCL
@R13
AM=M-1
D=M
@LCL
M=D
//Get Return addr
@R13
A=M-1
D=M
@R14
M=D
//Set return value
@SP
A=M-1
D=M
@R15
A=M
M=D
//Set SP
@R15
D=M+1
@SP
M=D
//JMP back to caller
@R14
A=M
0;JMP
