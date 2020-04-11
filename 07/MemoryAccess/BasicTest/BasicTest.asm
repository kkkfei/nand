//push constant 10
//------push constant num -------
@10
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop local 0
     
@LCL
D=M
@0
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
//push constant 21
//------push constant num -------
@21
D=A
@SP
A=M
M=D
@SP
M=M+1
//push constant 22
//------push constant num -------
@22
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop argument 2
     
@ARG
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
//pop argument 1
     
@ARG
D=M
@1
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
//push constant 36
//------push constant num -------
@36
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop this 6
     
@THIS
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
//push constant 42
//------push constant num -------
@42
D=A
@SP
A=M
M=D
@SP
M=M+1
//push constant 45
//------push constant num -------
@45
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop that 5
     
@THAT
D=M
@5
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
//pop that 2
     
@THAT
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
//push constant 510
//------push constant num -------
@510
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop temp 6
@SP
AM=M-1
D=M
@11
M=D             
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

//push that 5
//--------push------
@5
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
//push this 6
//--------push------
@6
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

//push this 6
//--------push------
@6
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

//add
//add            
@SP
M=M-1
A=M
D=M
A=A-1
M=D+M
//sub
//sub
@SP
M=M-1
A=M
D=M
A=A-1
M=M-D
//push temp 6
@11
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
