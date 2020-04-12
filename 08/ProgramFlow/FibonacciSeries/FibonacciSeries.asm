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

//pop pointer 1           
@SP
AM=M-1
D=M
@4
M=D             
//push constant 0
//------push constant num -------
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop that 0              
     
@THAT
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
//push constant 1
//------push constant num -------
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop that 1              
     
@THAT
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

//push constant 2
//------push constant num -------
@2
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
//label MAIN_LOOP_START
(FibonacciSeries$MAIN_LOOP_START)
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

//if-goto COMPUTE_ELEMENT 
@SP
AM=M-1
D=M
@FibonacciSeries$COMPUTE_ELEMENT
D;JNE
//goto END_PROGRAM        
@FibonacciSeries$END_PROGRAM
0;JMP
//label COMPUTE_ELEMENT
(FibonacciSeries$COMPUTE_ELEMENT)
//push that 0
//--------push------
@0
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

//push that 1
//--------push------
@1
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
//push pointer 1
@4
D=M             
@SP
A=M
M=D
@SP
M=M+1
//push constant 1
//------push constant num -------
@1
D=A
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
//pop pointer 1           
@SP
AM=M-1
D=M
@4
M=D             
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
//goto MAIN_LOOP_START
@FibonacciSeries$MAIN_LOOP_START
0;JMP
//label END_PROGRAM
(FibonacciSeries$END_PROGRAM)
