@17
D=A
@SP
A=M
M=D
@SP
M=M+1
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@JUMPTRUE1
D;JEQ
D=0
@JUMPEND1
0;JMP
(JUMPTRUE1)
D=-1
(JUMPEND1)
@SP
A=M
M=D
@SP
M=M+1
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
@16
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@JUMPTRUE2
D;JEQ
D=0
@JUMPEND2
0;JMP
(JUMPTRUE2)
D=-1
(JUMPEND2)
@SP
A=M
M=D
@SP
M=M+1
@16
D=A
@SP
A=M
M=D
@SP
M=M+1
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@JUMPTRUE3
D;JEQ
D=0
@JUMPEND3
0;JMP
(JUMPTRUE3)
D=-1
(JUMPEND3)
@SP
A=M
M=D
@SP
M=M+1
@892
D=A
@SP
A=M
M=D
@SP
M=M+1
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@JUMPTRUE4
D;JLT
D=0
@JUMPEND4
0;JMP
(JUMPTRUE4)
D=-1
(JUMPEND4)
@SP
A=M
M=D
@SP
M=M+1
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
@892
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@JUMPTRUE5
D;JLT
D=0
@JUMPEND5
0;JMP
(JUMPTRUE5)
D=-1
(JUMPEND5)
@SP
A=M
M=D
@SP
M=M+1
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@JUMPTRUE6
D;JLT
D=0
@JUMPEND6
0;JMP
(JUMPTRUE6)
D=-1
(JUMPEND6)
@SP
A=M
M=D
@SP
M=M+1
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@JUMPTRUE7
D;JGT
D=0
@JUMPEND7
0;JMP
(JUMPTRUE7)
D=-1
(JUMPEND7)
@SP
A=M
M=D
@SP
M=M+1
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@JUMPTRUE8
D;JGT
D=0
@JUMPEND8
0;JMP
(JUMPTRUE8)
D=-1
(JUMPEND8)
@SP
A=M
M=D
@SP
M=M+1
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@JUMPTRUE9
D;JGT
D=0
@JUMPEND9
0;JMP
(JUMPTRUE9)
D=-1
(JUMPEND9)
@SP
A=M
M=D
@SP
M=M+1
@57
D=A
@SP
A=M
M=D
@SP
M=M+1
@31
D=A
@SP
A=M
M=D
@SP
M=M+1
@53
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@112
D=A
@SP
A=M
M=D
@SP
M=M+1
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
@SP
M=M-1
@SP
A=M
D=M
D=-D
@SP
A=M
M=D
@SP
M=M+1
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
D=D&M
@SP
A=M
M=D
@SP
M=M+1
@82
D=A
@SP
A=M
M=D
@SP
M=M+1
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
D=D|M
@SP
A=M
M=D
@SP
M=M+1
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
(END)
@END
0;JMP