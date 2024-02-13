import itertools

from vm_parser import Command


class CodeWriter:
    def __init__(self, filename: str) -> None:
        self.filename: str = filename
        self.label_num = 0

    segment_table: dict[str, str] = {
        "local": "LCL",
        "argument": "ARG",
        "this": "THIS",
        "that": "THAT",
    }

    asmcodes_push: list[str] = [
        # RAM[SP] = D
        "@SP",
        "A=M",
        "M=D",
        # SP++
        "@SP",
        "M=M+1",
    ]

    asmcodes_pop: list[str] = [
        # SP--
        "@SP",
        "M=M-1",
        # D = RAM[SP]
        "@SP",
        "A=M",
        "D=M",
    ]

    asmcodes_end: list[str] = [
        "(END)",
        "@END",
        "0;JMP",
    ]

    def commands2asmcodes(self, commands: list[Command]) -> list[str]:
        asmcodes_list: list[list[str]] = list(map(self.command2asmcodes, commands))

        asmcodes: list[str] = list(itertools.chain.from_iterable(asmcodes_list))

        return asmcodes + self.asmcodes_end

    def command2asmcodes(self, command: Command) -> list[str]:
        if command.type == Command.Type.C_PUSH:
            # D = RAM[addr]
            asmcodes = self.__command2asmcodes_push(command)
            return asmcodes + self.asmcodes_push

        if command.type == Command.Type.C_POP:
            # RAM[addr] = D
            asmcodes = self.__command2asmcodes_pop(command)
            return self.asmcodes_pop + asmcodes

        if command.type == Command.Type.C_ARITHMETIC:
            asmcodes = self.__command2asmcodes_arithmetic(command)
            return self.asmcodes_pop + asmcodes + self.asmcodes_push

        raise Exception(f"Invalid command type: {command.type}")

    def __command2asmcodes_push(self, command: Command) -> list[str]:
        segment = command.args[1]
        i = command.args[2]

        if segment in ["local", "argument", "this", "that"]:
            return [
                # addr = segmentPointer + i
                f"@{self.segment_table[segment]}",
                "D=M",
                f"@{i}",
                "D=D+A",
                # D = RAM[addr]
                "A=D",
                "D=M",
            ]

        if segment == "constant":
            return [
                # D = i
                f"@{i}",
                "D=A",
            ]

        symbol_table: dict[str, str] = {
            "static": f"{self.filename}.{i}",
            "temp": str(5 + int(i)),
            "pointer": str(3 + int(i)),
        }

        if segment in ["static", "temp", "pointer"]:
            return [
                f"@{symbol_table[segment]}",
                "D=M",
            ]

        raise Exception(f"Invalid segment: {segment}")

    def __command2asmcodes_pop(self, command: Command) -> list[str]:
        segment = command.args[1]
        i = command.args[2]

        if segment in ["local", "argument", "this", "that"]:
            return [
                # R13 = D
                "@R13",
                "M=D",
                # R14 = segmentPointer + i
                f"@{self.segment_table[segment]}",
                "D=M",
                f"@{i}",
                "D=D+A",
                "@R14",
                "M=D",
                # RAM[R14] = R13
                "@R13",
                "D=M",
                "@R14",
                "A=M",
                "M=D",
            ]

        symbol_table: dict[str, str] = {
            "static": f"{self.filename}.{i}",
            "temp": str(5 + int(i)),
            "pointer": str(3 + int(i)),
        }

        if segment in ["static", "temp", "pointer"]:
            return [
                f"@{symbol_table[segment]}",
                "M=D",
            ]

        raise Exception(f"Invalid segment: {segment}")

    def __command2asmcodes_arithmetic(self, command: Command) -> list[str]:
        f = command.args[0]

        if f == "neg":
            return ["D=-D"]

        if f == "not":
            return ["D=!D"]

        # R13 = D
        asmcodes = [
            "@R13",
            "M=D",
        ]

        f2operator = {
            "add": "+",
            "sub": "-",
            "and": "&",
            "or": "|",
        }

        if f in f2operator:
            asmcodes_ope = [
                "@R13",
                f"D=D{f2operator[f]}M",
            ]
            return asmcodes + self.asmcodes_pop + asmcodes_ope

        f2jump = {
            "eq": "JEQ",
            "gt": "JGT",
            "lt": "JLT",
        }

        if f in f2jump:
            self.label_num += 1

            label_true = f"JUMPTRUE{self.label_num}"
            label_end = f"JUMPEND{self.label_num}"
            asmcodes_jump = [
                "@R13",
                "D=D-M",
                f"@{label_true}",
                f"D;{f2jump[f]}",
                "D=0",
                f"@{label_end}",
                "0;JMP",
                f"({label_true})",
                "D=-1",
                f"({label_end})",
            ]
            return asmcodes + self.asmcodes_pop + asmcodes_jump

        raise Exception(f"Invalid function: {f}")
