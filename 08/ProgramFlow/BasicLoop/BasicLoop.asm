//push constant 0    
//------push constant num -------
@0
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
//label LOOP_START
(BasicLoop$LOOP_START)
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

//add
//add            
@SP
M=M-1
A=M
D=M
A=A-1
M=D+M
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

//push constant 1
//------push constant num -------
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
//sub
//sub
@SP
M=M-1
A=M
D=M
A=A-1
M=M-D
//pop argument 0      
     
@ARG
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

//if-goto LOOP_START  
@SP
AM=M-1
D=M
@BasicLoop$LOOP_START
D;JNE
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

