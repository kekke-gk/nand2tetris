// function SimpleFunction.test 2(C_FUNCTION) 0
(SimpleFunction.test)
// push constant 0(C_PUSH) 0
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 0(C_PUSH) 7
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// push local 0(C_PUSH) 14
@LCL
D=M
@0
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// push local 1(C_PUSH) 25
@LCL
D=M
@1
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// add(C_ARITHMETIC) 36
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@SP
M=M-1
@SP
A=M
D=M
@R13
D=D+M
@SP
A=M
M=D
@SP
M=M+1
// not(C_ARITHMETIC) 55
@SP
M=M-1
@SP
A=M
D=M
D=!D
@SP
A=M
M=D
@SP
M=M+1
// push argument 0(C_PUSH) 66
@ARG
D=M
@0
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// add(C_ARITHMETIC) 77
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@SP
M=M-1
@SP
A=M
D=M
@R13
D=D+M
@SP
A=M
M=D
@SP
M=M+1
// push argument 1(C_PUSH) 96
@ARG
D=M
@1
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// sub(C_ARITHMETIC) 107
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@SP
M=M-1
@SP
A=M
D=M
@R13
D=D-M
@SP
A=M
M=D
@SP
M=M+1
// return(C_RETURN) 126
@LCL
D=M
@R13
M=D
@R13
D=M
@5
D=D-A
A=D
D=M
@R14
M=D
@SP
M=M-1
@SP
A=M
D=M
@ARG
A=M
M=D
@ARG
D=M+1
@SP
M=D
@R13
D=M
@1
D=D-A
A=D
D=M
@THAT
M=D
@R13
D=M
@2
D=D-A
A=D
D=M
@THIS
M=D
@R13
D=M
@3
D=D-A
A=D
D=M
@ARG
M=D
@R13
D=M
@4
D=D-A
A=D
D=M
@LCL
M=D
@R14
A=M
0;JMP
(END)
@END
0;JMP
