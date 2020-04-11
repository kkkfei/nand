//push constant 3030
//------push constant num -------
@3030
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop pointer 0
@SP
AM=M-1
D=M
@3
M=D             
//push constant 3040
//------push constant num -------
@3040
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop pointer 1
@SP
AM=M-1
D=M
@4
M=D             
//push constant 32
//------push constant num -------
@32
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop this 2
     
@THIS
D=M
@2
D=D+A

@SP
A=M
M=D
A=A-1
D=M
A=A+1
A=M
M=D
@SP
M=M-1
//push constant 46
//------push constant num -------
@46
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop that 6
     
@THAT
D=M
@6
D=D+A

@SP
A=M
M=D
A=A-1
D=M
A=A+1
A=M
M=D
@SP
M=M-1
//push pointer 0
@3
D=M             
@SP
A=M
M=D
@SP
M=M+1
//push pointer 1
@4
D=M             
@SP
A=M
M=D
@SP
M=M+1
//add
//add            
@SP
M=M-1
A=M
D=M
A=A-1
M=D+M
//push this 2
//--------push------
@2
D=A             
@THIS
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
//push that 6
//--------push------
@6
D=A             
@THAT
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
