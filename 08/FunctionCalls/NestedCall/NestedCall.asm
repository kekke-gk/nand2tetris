// bootstrap 0
@256
D=A
@SP
M=D
// call Sys.init 0 4
@Sys.initret
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@0
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Sys.init
0;JMP
(Sys.initret)
// function Sys.init 0(C_FUNCTION) 53
(Sys.init)
// push constant 4000(C_PUSH) 53
@4000
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 0(C_POP) 60
@SP
M=M-1
@SP
A=M
D=M
@3
M=D
// push constant 5000(C_PUSH) 67
@5000
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 1(C_POP) 74
@SP
M=M-1
@SP
A=M
D=M
@4
M=D
// call Sys.main 0(C_CALL) 81
@Sys.mainret
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@0
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Sys.main
0;JMP
(Sys.mainret)
// pop temp 1(C_POP) 130
@SP
M=M-1
@SP
A=M
D=M
@6
M=D
// label LOOP(C_LABEL) 137
(LOOP)
// goto LOOP(C_GOTO) 137
@LOOP
0;JMP
// function Sys.main 5(C_FUNCTION) 139
(Sys.main)
// push constant 0(C_PUSH) 139
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 0(C_PUSH) 146
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 0(C_PUSH) 153
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 0(C_PUSH) 160
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 0(C_PUSH) 167
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 4001(C_PUSH) 174
@4001
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 0(C_POP) 181
@SP
M=M-1
@SP
A=M
D=M
@3
M=D
// push constant 5001(C_PUSH) 188
@5001
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 1(C_POP) 195
@SP
M=M-1
@SP
A=M
D=M
@4
M=D
// push constant 200(C_PUSH) 202
@200
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop local 1(C_POP) 209
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@LCL
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
// push constant 40(C_PUSH) 227
@40
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop local 2(C_POP) 234
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@LCL
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
// push constant 6(C_PUSH) 252
@6
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop local 3(C_POP) 259
@SP
M=M-1
@SP
A=M
D=M
@R13
M=D
@LCL
D=M
@3
D=D+A
@R14
M=D
@R13
D=M
@R14
A=M
M=D
// push constant 123(C_PUSH) 277
@123
D=A
@SP
A=M
M=D
@SP
M=M+1
// call Sys.add12 1(C_CALL) 284
@Sys.add12ret
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@1
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Sys.add12
0;JMP
(Sys.add12ret)
// pop temp 0(C_POP) 333
@SP
M=M-1
@SP
A=M
D=M
@5
M=D
// push local 0(C_PUSH) 340
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
// push local 1(C_PUSH) 351
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
// push local 2(C_PUSH) 362
@LCL
D=M
@2
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// push local 3(C_PUSH) 373
@LCL
D=M
@3
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// push local 4(C_PUSH) 384
@LCL
D=M
@4
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// add(C_ARITHMETIC) 395
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
// add(C_ARITHMETIC) 414
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
// add(C_ARITHMETIC) 433
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
// add(C_ARITHMETIC) 452
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
// return(C_RETURN) 471
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
// function Sys.add12 0(C_FUNCTION) 530
(Sys.add12)
// push constant 4002(C_PUSH) 530
@4002
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 0(C_POP) 537
@SP
M=M-1
@SP
A=M
D=M
@3
M=D
// push constant 5002(C_PUSH) 544
@5002
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 1(C_POP) 551
@SP
M=M-1
@SP
A=M
D=M
@4
M=D
// push argument 0(C_PUSH) 558
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
// push constant 12(C_PUSH) 569
@12
D=A
@SP
A=M
M=D
@SP
M=M+1
// add(C_ARITHMETIC) 576
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
// return(C_RETURN) 595
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
