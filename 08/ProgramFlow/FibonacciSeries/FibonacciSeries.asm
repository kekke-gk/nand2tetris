// push argument 1(C_PUSH) 0
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
// pop pointer 1(C_POP) 11
@SP
M=M-1
@SP
A=M
D=M
@4
M=D
// push constant 0(C_PUSH) 18
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop that 0(C_POP) 25
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@THAT
D=M
@0
D=D+A
@R14
M=D
@R13
D=M
@R14
A=M
M=D
// push constant 1(C_PUSH) 43
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop that 1(C_POP) 50
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@THAT
D=M
@1
D=D+A
@R14
M=D
@R13
D=M
@R14
A=M
M=D
// push argument 0(C_PUSH) 68
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
// push constant 2(C_PUSH) 79
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// sub(C_ARITHMETIC) 86
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
// pop argument 0(C_POP) 105
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@ARG
D=M
@0
D=D+A
@R14
M=D
@R13
D=M
@R14
A=M
M=D
// label LOOP(C_LABEL) 123
(LOOP)
// push argument 0(C_PUSH) 123
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
// if-goto COMPUTE_ELEMENT(C_IF) 134
@SP
M=M-1
@SP
A=M
D=M
@COMPUTE_ELEMENT
D;JNE
// goto END(C_GOTO) 141
@END
0;JMP
// label COMPUTE_ELEMENT(C_LABEL) 143
(COMPUTE_ELEMENT)
// push that 0(C_PUSH) 143
@THAT
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
// push that 1(C_PUSH) 154
@THAT
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
// add(C_ARITHMETIC) 165
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
// pop that 2(C_POP) 184
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@THAT
D=M
@2
D=D+A
@R14
M=D
@R13
D=M
@R14
A=M
M=D
// push pointer 1(C_PUSH) 202
@4
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 1(C_PUSH) 209
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
// add(C_ARITHMETIC) 216
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
// pop pointer 1(C_POP) 235
@SP
M=M-1
@SP
A=M
D=M
@4
M=D
// push argument 0(C_PUSH) 242
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
// push constant 1(C_PUSH) 253
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
// sub(C_ARITHMETIC) 260
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
// pop argument 0(C_POP) 279
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@ARG
D=M
@0
D=D+A
@R14
M=D
@R13
D=M
@R14
A=M
M=D
// goto LOOP(C_GOTO) 297
@LOOP
0;JMP
// label END(C_LABEL) 299
(END)
(END)
@END
0;JMP