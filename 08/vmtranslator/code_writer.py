import itertools
from typing import TextIO
from pathlib import Path

from vm_parser import parse_all, Command


class CodeWriter:
    def __init__(self, target_path: Path) -> None:
        self.filename: str = ""
        self.label_num: int = 0
        self.return_label_num: int = 0
        self.current_pc: int = 0

        self.file: TextIO = open(target_path, "w")

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

    def write_files_with_bootstrap(self, vm_files: list[Path]) -> None:
        asmcodes: list[str] = self.bootstrap_asmcodes()
        self.write_asmcodes(asmcodes)

        for vm_file in vm_files:
            self.write_file(vm_file)

    def write_file_with_endloop(self, vm_file: Path) -> None:
        self.write_file(vm_file)

        self.write_asmcodes(self.asmcodes_end)

    def write_file(self, vm_file: Path) -> None:
        with vm_file.open("r") as f:
            lines: list[str] = f.readlines()

            assert lines

        commands: list[Command] = parse_all(lines)

        self.filename = vm_file.stem
        self.write_commands(commands)

    def write_commands(self, commands: list[Command]) -> None:
        asmcodes: list[str] = self.commands2asmcodes(commands)
        self.write_asmcodes(asmcodes)

    def write_asmcodes(self, asmcodes: list[str]) -> None:
        asmcodes_: list[str] = self.add_addr_to_comment(asmcodes)
        self.file.writelines(map(lambda x: x + "\n", asmcodes_))

    def add_addr_to_comment(self, asmcodes: list[str]) -> list[str]:
        asmcodes_: list[str] = []
        for asmcode in asmcodes:
            if asmcode.startswith("//"):
                asmcodes_.append(asmcode + f" {self.current_pc}")
            elif asmcode.startswith("("):
                asmcodes_.append(asmcode)
            else:
                self.current_pc += 1
                asmcodes_.append(asmcode)
        return asmcodes_

    def commands2asmcodes(self, commands: list[Command]) -> list[str]:
        asmcodes_list: list[list[str]] = list(map(self.command2asmcodes, commands))

        asmcodes: list[str] = list(itertools.chain.from_iterable(asmcodes_list))

        return asmcodes

    def command2asmcodes(self, command: Command) -> list[str]:
        translate_funcs = {
            Command.Type.C_PUSH: self.__command2asmcodes_push,
            Command.Type.C_POP: self.__command2asmcodes_pop,
            Command.Type.C_ARITHMETIC: self.__command2asmcodes_arithmetic,
            Command.Type.C_LABEL: self.__command2asmcodes_label,
            Command.Type.C_GOTO: self.__command2asmcodes_goto,
            Command.Type.C_IF: self.__command2asmcodes_if,
            Command.Type.C_FUNCTION: self.__command2asmcodes_function,
            Command.Type.C_RETURN: self.__command2asmcodes_return,
            Command.Type.C_CALL: self.__command2asmcodes_call,
        }

        asmcodes: list[str] = translate_funcs[command.type](command)

        return [f"// {command}"] + asmcodes

    def __command2asmcodes_push(self, command: Command) -> list[str]:
        segment = command.args[1]
        i = command.args[2]

        asmcodes = []

        if segment in ["local", "argument", "this", "that"]:
            asmcodes = [
                # addr = segmentPointer + i
                f"@{self.segment_table[segment]}",
                "D=M",
                f"@{i}",
                "D=D+A",
                # D = RAM[addr]
                "A=D",
                "D=M",
            ]

        elif segment == "constant":
            asmcodes = [
                # D = i
                f"@{i}",
                "D=A",
            ]

        elif segment in ["static", "temp", "pointer"]:
            symbol_table: dict[str, str] = {
                "static": f"{self.filename}.{i}",
                "temp": str(5 + int(i)),
                "pointer": str(3 + int(i)),
            }
            asmcodes = [
                f"@{symbol_table[segment]}",
                "D=M",
            ]

        else:
            raise Exception(f"Invalid segment: {segment}")

        return asmcodes + self.asmcodes_push

    def __command2asmcodes_pop(self, command: Command) -> list[str]:
        segment = command.args[1]
        i = command.args[2]

        asmcodes = []

        if segment in ["local", "argument", "this", "that"]:
            asmcodes = [
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

        elif segment in ["static", "temp", "pointer"]:
            symbol_table: dict[str, str] = {
                "static": f"{self.filename}.{i}",
                "temp": str(5 + int(i)),
                "pointer": str(3 + int(i)),
            }
            asmcodes = [
                f"@{symbol_table[segment]}",
                "M=D",
            ]

        else:
            raise Exception(f"Invalid segment: {segment}")

        return self.asmcodes_pop + asmcodes

    def __command2asmcodes_arithmetic(self, command: Command) -> list[str]:
        f = command.args[0]

        def f2asmcodes() -> list[str]:
            if f == "neg":
                return ["D=-D"]

            if f == "not":
                return ["D=!D"]

            # R13 = D
            asmcodes = [
                "@R13",
                "M=D",
            ]

            asmcodes += self.asmcodes_pop

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
                return asmcodes + asmcodes_ope

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
                return asmcodes + asmcodes_jump

            raise Exception(f"Invalid function: {f}")

        return self.asmcodes_pop + f2asmcodes() + self.asmcodes_push

    def __command2asmcodes_function(self, command: Command) -> list[str]:
        func_name = command.args[1]
        num_vars = int(command.args[2])

        asmcodes = [
            f"({func_name})",
        ]

        for _ in range(num_vars):
            asmcodes += self.command2asmcodes(Command("push constant 0"))

        return asmcodes

    def __command2asmcodes_return(self, command: Command) -> list[str]:
        asmcodes = []

        # R13 = LCL
        asmcodes += [
            "@LCL",
            "D=M",
            "@R13",
            "M=D",
        ]
        # retAddr = *(R13 - 5)
        asmcodes += [
            "@R13",
            "D=M",
            "@5",
            "D=D-A",
            "A=D",
            "D=M",
            "@R14",
            "M=D",
        ]

        # *ARG = pop()
        asmcodes += self.asmcodes_pop
        asmcodes += [
            "@ARG",
            "A=M",
            "M=D",
        ]

        # SP = ARG + 1
        asmcodes += [
            "@ARG",
            "D=M+1",
            "@SP",
            "M=D",
        ]

        # THAT = *(R13 - 1)
        # THIS = *(R13 - 2)
        # ARG = *(R13 - 3)
        # LCL = *(R13 - 4)
        for i, segment in enumerate(reversed(self.segment_table.values())):
            asmcodes += [
                "@R13",
                "D=M",
                f"@{i+1}",
                "D=D-A",
                "A=D",
                "D=M",
                f"@{segment}",
                "M=D",
            ]

        # goto retAddr
        asmcodes += [
            "@R14",
            "A=M",
            "0;JMP",
        ]

        return asmcodes

    def __command2asmcodes_call(self, command: Command) -> list[str]:
        func_name = command.args[1]
        num_args = int(command.args[2])
        self.return_label = f"{func_name}ret{self.return_label_num}"

        self.return_label_num += 1

        asmcodes = []

        # push retAddrLabel
        asmcodes += [
            f"@{self.return_label}",
            "D=A",
        ]
        asmcodes += self.asmcodes_push

        # push LCL
        # push ARG
        # push THIS
        # push THAT
        for segment in self.segment_table.values():
            asmcodes += [
                f"@{segment}",
                "D=M",
            ]
            asmcodes += self.asmcodes_push

        # ARG = SP - 5 - nArgs
        asmcodes += [
            "@SP",
            "D=M",
            "@5",
            "D=D-A",
            f"@{num_args}",
            "D=D-A",
            "@ARG",
            "M=D",
        ]

        # LCL = SP
        asmcodes += [
            "@SP",
            "D=M",
            "@LCL",
            "M=D",
        ]

        asmcodes += self.__command2asmcodes_goto(Command(f"goto {func_name}"))

        asmcodes += [f"({self.return_label})"]

        return asmcodes

    def __command2asmcodes_label(self, command: Command) -> list[str]:
        label = command.args[1]

        return [f"({label})"]

    def __command2asmcodes_goto(self, command: Command) -> list[str]:
        label = command.args[1]

        return [
            f"@{label}",
            "0;JMP",
        ]

    def __command2asmcodes_if(self, command: Command) -> list[str]:
        label = command.args[1]

        asmcodes = [
            f"@{label}",
            "D;JNE",
        ]

        return self.asmcodes_pop + asmcodes

    def bootstrap_asmcodes(self) -> list[str]:
        asmcodes = [
            "// bootstrap",
            # SP = 256
            "@256",
            "D=A",
            "@SP",
            "M=D",
        ]

        asmcodes += self.command2asmcodes(Command("call Sys.init 0"))

        return asmcodes
